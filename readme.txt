Features
Decode and dump $LogFile records.
Decode many attribute changes.
Optionally resolve all datarun list information available in $LogFile.
Configurable verbose mode (does not affect logging).
Logs to csv and imports to sqlite database with several tables.
Optionally import csv output of mft2csv into db.
Choose timestamp format and precision.
Choose region adjustment for timestamps. Default is UTC 0.0.
Choose separator.
Configurable UNICODE or ANSI output.
Optionally decode $UsnJrnl (deactivated - no longer needed).
Configurable MFT record size (1024 or 4096).

Background
NTFS is designed as a recoverable filesystem. This done through logging of all transactions that alters volume structure. So any change to a file on the volume will require something to be logged to the $LogFile too, so that it can be reversed in case of system failure at any time. Therefore a lot of information is written to this file, and since it is circular, it means new transactions are overwriting older records in the file. Thus it is somewhat limited how much historical data can be retrieved from this file. Again, that would depend on the type of volume, and the size of the $LogFile. On the systemdrive of a frequently used system, you will likely only get a few hours of history, whereas an external/secondary disk with backup files on, would likely contain more historical information. And a 2MB file will contain far less history than a 256MB one. So in what size range can this file be configured to? Anything from 256 KB and up. Configure the size to 2 GB can be done like this, "chkdsk D: /L:2097152". How a large sized logfile impacts on performance is beyond the scope of this text. Setting it lower than 2048 is normally not possible. However it is possble by patching untfs.dll: http://code.google.com/p/mft2csv/wiki/Tiny_NTFS

Intro
This parser will decode and dump lots of transaction information from the $LogFile on NTFS. There are several csv's generated as well as an sqlite database named ntfs.db containing all relevant information.
The currently handled Redo transaction types are:

InitializeFileRecordSegment
CreateAttribute
DeleteAttribute
UpdateResidentValue
UpdateNonResidentValue
UpdateMappingPairs
SetNewAttributeSizes
AddindexEntryRoot
DeleteindexEntryRoot
AddIndexEntryAllocation
DeleteIndexEntryAllocation
ResetAllocation
ResetRoot
SetIndexEntryVcnAllocation
UpdateFileNameRoot
OpenNonresidentAttribute


The list of currently supported attributes:
$STANDARD_INFORMATION
$FILE_NAME
$OBJECT_ID
$VOLUME_NAME
$VOLUME_INFORMATION
$DATA
$INDEX_ROOT
$INDEX_ALLOCATION
$REPARSE_POINT
$EA_INFORMATION
$EA
$LOGGED_UTILITY_STREAM

So basically there's only 3 missing in the decode; $ATTRIBUTE_LIST, $SECURITY_DESCRIPTOR and $BITMAP. However, $ATTRIBUTE_LIST is kind of implemented as records from attribute lists are processed through InitializeFileRecordSegment as separate MFT records, and information about base ref is already logged.


Explanation of the different output generated:

LogFile.csv:
The main csv generated from the parser.

LogFile_DataRuns.csv
The input information needed for reconstructing dataruns

LogFile_DataRunsResolved.csv
The final output of reconstructed dataruns

LogFile_INDX.csv
All dumped and decoded index records (IndexRoot/IndexAllocation)

LogFileJoined.csv
Same as LogFile.csv, but have filename information joined in from the $UsnJrnl or csv of mft2csv.

UsnJrnl.csv
The output of the $UsnJrnl parser module. File will not be created if not the USN journal is to be analyzed.

MFTRecords.bin
Dummy $MFT recreated based on found MFT records in InitializeFileRecordSegment transactions. Can use mft2csv on this one (remember to configure "broken MFT" and "Fixups" properly).

LogFile_lfUsnJrnl.csv
Records for the $UsnJrnl that has been decoded within $LogFile

LogFile_UndoWipe_INDX.csv
All undo operations for clearing of directory indexes (INDX)

Ntfs.db
An sqlite database file with tables almost equivalent to the above csv's. The database contains 5 tables:
DataRuns
IndexEntries
LogFile
LogFileTmp (temp table used when recreating dataruns).
UsnJrnl



Timestamps
Defaults are presented in UTC 0.00, and with nanosecond precision. The default format is YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS. These can be configured. The different timestamps refer to:
CTime means File Create Time. 
ATime means File Modified Time. 
MTime means MFT Entry modified Time. 
RTime means File Last Access Time. 


Reconstructing dataruns.

Many operations on the filesystem, will trigger a transaction into the $LogFile. Those relating to the $DATA attribute, ie a file's content are so far identified as;

InitializeFileRecordSegment
CreateAttribute
UpdateMappingPairs
SetNewAttributeSizes

They all leave different information in the $LogFile. Resident data modifications behave differently and can not be reconstructed just like that, at least on NTFS volumes originating from modern Windows versions. 

InitializeFileRecordSegment is when a new file is created. Thus it will have the $FILE_NAME attribute, as well as the original $DATA atribute content, including dataruns. Since the $LogFile is circular, and older events gets overwritten by newer, the challenge with the $LogFile is to get information long enough back in time. However, if InitializeFileRecordSegment is present, then we should be able to reconstruct everything, since all records written after that will also be available. We will also have information about the offset to the datarun list. This is a relative offset calculated from the beginning of the $DATA attribute. This is important information to have when calculating where in the datarun list the UpdateMappingPairs have done its modification. 

CreateAttribute is the original attribute when it was first created (if not written as part of InitializeFileRecordSegment). With this one too, we should be able to reconstruct dataruns since we have all transactions available to us. However, this one will not in itself provide us with the file name. Here too, we have the offset to the datarun list available which is extremely useful when solving UpdateMappingPairs.

UpdateMappingPairs is a transaction when modifications to the $DATA/dataruns are performed (file content has changed). The information found in this transaction is not complete, and it contains just the new values added to the existing datarun list. It also contains a relative offset that tells us where in the datarun list the changes have been written. This offset is used in combination with the offset to datarun as found in InitializeFileRecordSegment and CreateAttribute. 

SetNewAttributeSizes is a transaction that contains information about any size value related modifications done to the $DATA attribute. This is tightly connected to UpdateMappingPairs which only contains datarun changes.

With the above 4 different redo operations can for a given reference number (distinct file) reconstruct some of the filesystem change history of file. Because of the circularity of it, we only have part of the history, the most recent. The extent of the history we can retrieve highly depends on what kind of volume the target is. If it is a system volume, then a week of history is probably more than you could expect, while a removable or external or secondary disk will contain far more history. Thus we may reconstruct the full history of a deleted file (having it's $MFT record overwritten), and in turn recreate the datarun list to perform recovery upon. In other cases we may not be able to reconstruct the full history, so only a partial datarun list can be reconstructed. The final csv file with the adjusted dataruns, LogFile_DatarunsModified.csv, will have the dataruns displayed differently. 

Explanation:
Those starting with a "!" indicates the complete datarun list has been recreated.
Those starting with a "?" indicates a partial recovery, with the number of "**" representing missing bytes off the original datarun list.

To simplify recovery of a file based on a datarun, one can use the attached PoC called ExtractFromDataRuns. It is quite self explanatory. Just fill in the complete datarun list, the real size and init size, and a name for the output file. Optionally choose to process image files (disk or partition). Also tick off if any compressed/sparse flag have been detected. Feeding it with a partially reconstructed datarun list will not work! Please note that alternate data streams can be distinguished by the presence of a dataname and also by a differing OffsetInMft values for a given fileref.

The separate download package "SampleTinyNtfsVolume.zip" have a partition image with a small NTFS volume to test it on. On the volume there are 2 deleted non-resident files which both have their MFT record overwritten by new files. Any decent recovery software based on signature searching should be able to recover the jpg file (Tulips.jpg), because it is contigous. However, they most likely will not identify its filename, or anything other about the file. The second file will likely not be recoverable using standard tools, because it is fragmented (compressed), and by having its MFT record overwritten, resoving the file without the datarun list is impossible. Using the PoC we can identify the filename (suspicious.zip) and extract it into perect shape (don't worry it only contains one of the sample images shipped with Windows). Read the file readme.DataRunsResolved.txt for the details about the sample image and how to interpret output and recover the files.


What we have achieved with this is to recover fragmented files which have their MFT record overwritten. Since we have reconstructed partial/complete datarun history, we can with certainty (at least if full history is reconstructed) determine whether file slack data have belonged to the given file or not.


Limitation.
Datarun reconstruction is broken with UNICODE (ANSI is ok).
Importing og Mft2Csv output is broken if csv is UNICODE (ANSI is ok).
Partial updates to IndexRecords (IndexRoot/IndexAllocation) are very hard to interpret, as we likely do not have knowledge of the original index. Complete records are OK though.
Circularity of a 65 MB file poses inherent and absolute restriction on how many historical FS transtions. Systemdrives thus have limited history in $LogFile, whereas external/secondary drives have more histrocal transtions stored. Can increase size of $LogFile with chkdsk (chkdsk c: /L:262144).
Changes to the data of resident files are not stored within $LogFile, only information that a change was done is stored.

Note
The $UsnJrnl contains information in a more human friendly way. For instance each record contains fileref, filename, timestamp and explanation of what occurred. It also contains far more historical information than $LogFile, though without a lot of details. 

Todo
Implement more analysis of data present in ntfs.db.


References:
Windows Internals 6th Edition
http://www.opensource.apple.com/source/ntfs/ntfs-80/kext/ntfs_logfile.h
http://forensicinsight.org/wp-content/uploads/2012/05/INSIGHT_A-Dig-into-the-LogFile.pdf
https://dl.dropbox.com/s/c0u980a53ipaq7h/CEIC-2012_Anti-Anti_Forensics.pptx?dl=1
