Features
Decode and dump $LogFile records and transaction entries.
Decode NTFS attribute changes.
Optionally resolve all datarun list information available in $LogFile. Option: "Reconstruct data runs".
Recover transactions from slack space within $LogFile.
Choose to reconstruct missing or damaged headers of transactions found in slack. Option: "Rebuild header". 
Optionally also finetune result with a LSN error level value. Option: "LSN error level".
Logs to csv and imports to sqlite database with several tables.
Optionally import csv output of mft2csv into db.
Choose timestamp format, precision and millisec/precision separator. Option "Precision separator".
Choose region adjustment for timestamps. Default is UTC 0.0.
Choose output separator. Option: "Set separator".
Configurable UNICODE or ANSI output. Option "Unicode".
Configurable MFT record size (1024 or 4096). Option "MFT record size".
Optionally decode transaction fragment. Deactivated until fully implemented.
Detailed verbose output into debug.log.
Configuration for Nt5.x (XP,2003).
Configuration for binary data extraction of resident data updates.

Background
NTFS is designed as a recoverable filesystem. This done through logging of all transactions that alters volume structure. So any change to a file on the volume will require something to be logged to the $LogFile too, so that it can be reversed in case of system failure at any time. Therefore a lot of information is written to this file, and since it is circular, it means new transactions are overwriting older records in the file. Thus it is somewhat limited how much historical data can be retrieved from this file. Again, that would depend on the type of volume, and the size of the $LogFile. On the systemdrive of a frequently used system, you will likely only get a few hours of history, whereas an external/secondary disk with backup files on, would likely contain more historical information. And a 2MB file will contain far less history than a 256MB one. So in what size range can this file be configured to? Anything from 256 KB and up. Configure the size to 2 GB can be done like this, "chkdsk D: /L:2097152". How a large sized logfile impacts on performance is beyond the scope of this text. Setting it lower than 2048 is normally not possible. However it is possble by patching untfs.dll: http://code.google.com/p/mft2csv/wiki/Tiny_NTFS

Intro
This parser will decode and dump lots of transaction information from the $LogFile on NTFS. There are several csv's generated as well as an sqlite database named ntfs.db containing all relevant information. The output is extremely detailed and very low level, meaning it requires some decent NTFS knowledge in order to understand it. The currently handled Redo transaction types with meaningfull output decode are:

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
WriteEndOfIndexBuffer
SetIndexEntryVcnRoot
SetIndexEntryVcnAllocation
UpdateFileNameRoot
UpdateFileNameAllocation
SetBitsInNonresidentBitMap
ClearBitsInNonresidentBitMap
OpenNonresidentAttribute
OpenAttributeTableDump
AttributeNamesDump
DirtyPageTableDump
TransactionTableDump
UpdateRecordDataRoot
UpdateRecordDataAllocation

The list of currently supported attributes:
$STANDARD_INFORMATION
$ATTRIBUTE_LIST
$FILE_NAME
$OBJECT_ID
$SECURITY_DESCRIPTOR
$VOLUME_NAME
$VOLUME_INFORMATION
$DATA
$INDEX_ROOT
$INDEX_ALLOCATION
$REPARSE_POINT
$EA_INFORMATION
$EA
$LOGGED_UTILITY_STREAM


So basically all attributes are supported.

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

MFTRecords.bin
Dummy $MFT recreated based on found MFT records in InitializeFileRecordSegment transactions. Can use mft2csv on this one (remember to configure "broken MFT" and "Fixups" properly).

LogFile_lfUsnJrnl.csv
Records for the $UsnJrnl that has been decoded within $LogFile

LogFile_UndoWipe_INDX.csv
All undo operations for clearing of directory indexes (INDX).

LogFile_AllTransactionHeaders.csv
All headers of decoded transactions.

LogFile_BitsInNonresidentBitMap.csv
All decoded SetBitsInNonresidentBitMap operations.

LogFile_DirtyPageTable.csv
All entries in every decoded DirtyPageTableDump operation.

LogFile_ObjIdO.csv
All decodes from system file $ObjId:$O.

LogFile_OpenAttributeTable.csv
All entries in every decoded OpenAttributeTableDump operation.

LogFile_QuotaO.csv
All decodes from system file $Quota:$O.

LogFile_QuotaQ.csv
All decodes from system file $Quota:$Q.

LogFile_RCRD.csv
All headers of decoded RCRD records.

LogFile_ReparseR.csv
All decodes from system file $Reparse:$R.

LogFile_SecureSDH.csv
All decodes from system file $Secure:$SDH.

LogFile_SecureSII.csv
All decodes from system file $Secure:$SII.

LogFile_SecurityDescriptors.csv
Decoded security descriptors. Source can be from $SECURITY_DESCRIPTOR or $Secure:$SDS.

LogFile_SlackAttributeNamesDump.csv
All entries from decoded AttributeNamesDump transactions found in slack space.

LogFile_SlackOpenAttributeTable.csv
All entries from decoded OpenAttributeTableDump transactions found in slack space.

LogFile_TransactionTable.csv
Decoded TransactionTableDump transactions.

LogFile_Filenames.csv
All resolved filenames with MftRef, MftRefSeqNo and Lsn.

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
The $UsnJrnl contains information in a more human friendly way. For instance each record contains fileref, filename, timestamp and explanation of what occurred. It also contains far more historical information than $LogFile, though without a lot of details. If $UsnJrnl is active, then all transactions written to it during the recycle life of the $LogFile are also present within $LogFile. This means that there is no reason to decode the $UsnJrnl in order to understand $LogFile any better.

Todo
Implement more analysis of data present in ntfs.db. Currently it will require a certain level of NTFS knowledge in order to understand the output.

Slack space
In this context slack space means the space within a RCRD record that is the leftover in the record beyond the last transaction. I don't think this has been described before, so let me explain. Volume slack is the unused space between the end of file system and end of the partition where the file system resides. MFT record slack is kind of the same, but refers to the space found after the record end signature (0xFFFFFFFF) up to the physical record end (0x400 or 0x1000). And slack space within the $LogFile is thus the space found beyond the last transaction and up to the RCRD record end (usually 0x1000). These transactions from slack are actually there from before the $LogFile was recycled (overwriten). There is also an algorithm identifying valid transactions from slack space. In addition there may also exist several layers of such slack space. 
Example:
Lets say last transaction in a given RCRD record ended at offset 0x00007D27. From this offset and up to 0x00007FFF we have 0x2D8 bytes of slack space. It could then be that the bytes starting at 0x00007D28 is not a valid transaction header because it is in the middle of a transaction. The program will then (if configured to) attempt to rebuild a pseudo header with valid values in order to decode the transaction. If it fails at rebuild any valid header, it considers to much information from the original header is lost, and it will consider these bytes as lost, and continue scanning the rest of the slack space for any valid transaction header. The lost bytes will be logged to debug.log for you to investigate. On the other hand, if it was able rebuild a valid header, the information about this would be found in the lf_TextInformation field. Lets say it identified a transaction starting at offset 0x00007D48 and with size 0xB0. Then another good transactions was identified immediately following at offset 0x00007DF8 with size 0xE0. However at offset 0x00007ED8 there was no valid transaction header. This means we are now at the seond layer of slack space within that RCRD record. Now lets say the program, after re-scanning, was able to identify a valid transaction header at offset 0x00007F18. This transaction would be marked in the csv with a value of 2 in the FromRcrdSlack field. However, consider the transaction total size pushing the offset beyong the RCRD record size. In essensce, this would be a partially recovered transaction, which could decode fine, but will be found with a value of 1 in the IncompleteTransaction field. Remember the debug.log is very detailed and will help understanding the decoded output, especially what comes from slack space.

Nt5.x configuration.
By nt5.x I mean XP or Server 2003. This setting is important to set correctly. It means which OS has handled the target volume. The point is that handling of OpenAttributeTable differ from nt5.x to nt6.x (Vista and later). There might of course be cases (for instance usb disk) where the volume has been handled by several different OS's, in which case it might be tricky to get this setting 100% correct. For such cases, it might be useful to run tool twice, with one for each setting of Nt5.x (on/off). In any way, it may be usefull to look into the LogFile_OpenAttributeTable.csv to evaluate the output. If you see entries with columns containing strange values, then this particular setting might be wrong. If so, then most values are way off. For instance most AttributeType fields are UNKNOWN, Lsn is not within the current range, MftRef is too high and MftRefSeqNo of 0. If such output is observed, re-run the tool the opposite Nt5.x setting. Beware that AttributeType is resolved as UNKNOWN for unitialized entries in the table, but these are easy to spot as all values after AllocatedOrNextFree are 0 and is perfectly valid.

Extraction of resident attribute updates (UpdateResidentValue).
The UpdateResidentValue operation is for updates to the content of resident attributes. The configuration of "Extract resident updates of min size" will let you extract the binary modification to the resident attribute. The input field is for the minimum size in bytes to extract. The likely most interesting use of this feature is with volumes handled by Nt5.x (XP,2003), where the complete updates to $DATA attribute (normal file content) are stored in the redo and undo fields with UpdateResidentValue. Files with a resident $DATA content, are smaller sized files, at most 744 bytes (with MFT record size of 1024) but usually less. The extracted data is written to a subfolder named ResidentExtract. The output files are named with a logic like this; MFT($MFTRef)_$OffsetInMft_$AttributeOffset_LSN($Lsn)$Operation.bin. For example MFT(1643)_0x0098_0x00B8_LSN(1415242628)redo.bin would mean MFT record number 1643, the offset of target attribute in MFT is 0x98, the offset of the modification within target attribute is 0xB8, the LSN of the transaction is 1415242628, and this was for a redo operation. The extracts for undo operations are thus containing the data at that offset before the modification. The activation of this feature, will trigger som irrelevant and non-interesting output. Most false positives are automatically filtered, but some are unavoidable. For instance updates of $INDEX_ROOT, $ATTRIBUTE_LIST and $BITMAP may be included. It is possible though to manually trace back the attributes to filter out non-$DATA but comparing the OffsetInMft with what is found in the relevanr InitializeFileRecordSegment or if applicable in $MFT itself.

Filenames csv
From version 2.0.0.6 there was implemented a new feature to dump all identified filenames. The source of these entries come from InitializeFileRecordSegment, UpdateNonResidentValue, AddindexEntryRoot, DeleteindexEntryRoot, AddIndexEntryAllocation, DeleteIndexEntryAllocation and WriteEndOfIndexBuffer. The csv with these filenames, LogFile_FileNames.csv, thus contains a rebuilt history of all filename, MftRef and MftRefSeqNo for the duration of the $LogFile hostory. You will thus be able to see all the various filenames a given Mft Record have had during the timespan that the $LogFile covered. When a file is renamed, the MftrefSeqNo is not incremented. When a MFT record is marked as deleted, and later reused, the MftRefSeqNo is incremented by one with the new initialization.


References:
Windows Internals 6th Edition
http://www.opensource.apple.com/source/ntfs/ntfs-80/kext/ntfs_logfile.h
http://forensicinsight.org/wp-content/uploads/2012/05/INSIGHT_A-Dig-into-the-LogFile.pdf
https://dl.dropbox.com/s/c0u980a53ipaq7h/CEIC-2012_Anti-Anti_Forensics.pptx?dl=1
