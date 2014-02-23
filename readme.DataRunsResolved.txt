MFTReference is the file ref as founf in MFT. The rows are sorted by MFTReference. 
MFTBaseRecRef if present tells you that this line belongs an attribute list type of record and that the MFTBaseRecRef is the MFTReference of the base file. 
Filename comes from $FILE_NAME attribute. If filename is empty it just means that the filename was not present in $LogFile. By also using $UsnJrnl, more filenames may be identified. 
LSN is the Logfile Sequence Number of the last relevant transaction relating to that file ref's $data.
OffsetInMft tells you the offset of the attribute within the MFT record. So if the $DATA attribute for a given fileref have several rows with different numbers here, it means there may be several $DATA attributes (ADS). 
DataName is the name of the attribute. For regular files it will be empty. If any name is present, it means we are dealing with an ADS.
Flags will be present here if file is compressed or sparse. This is important information in order to extract correctly.
Non-Resident tells whether the $DATA are resident or not. If a given file was small (resident), and then size increased so it became non-resident, there will be a new row.
Compression Unit Size is information given if the file was ever compressed.
FileSize is the actual size of the file, as reserved (but not initialized) on disk.
Initialized Stream Size is the relevant file size to extract from.
DataRuns are the actual reconstructed datarun list.

Note
Sometimes when a new file is created on the volume and a new MFT is created (found in InitializeFileRecordSegment), the $DATA attribute is not yet added. It will be created shortly after in a CreateAttribute. It will therefore have no filename association in that transaction left alone. The filename will there actually be that of the previous row (with same file ref). If the MFTRef has been reused by a new file, a new filename will be visible. A new row for a given MFTRef can also occur when a file went from being resident -> non-resident, or any ADS operations occurred on the file.

Walkthrough and explanation of evidence from the sample partition image.

MFTReference 32
The first referenced file was named "Tulips.jpg". It was first created with a complete MFT record with $DATA attribute (some have the $DATA added right after) and content being non-resident. We can read that the real and initialized size of the file was 620888 bytes and its datarun list has been complete reconstructed to 22BD04CA22000000FFFFFFFF82794711. The last bytes are not always relevant and by interpreting it we get that 22BD04CA2200 is the relevant bytes (the program resolves this anyway so it does not matter).
Then a new file appears with the same ref but a different name, file8.txt. This file is resident.

MFTReference 33
The first referenced file was named "suspicious.zip". It was first created with a complete MFT record and data being non-resident. The real and initialized size of the file was 1365580 bytes and its datarun list has been complete reconstructed to 22700A872700FFFF. 
Then the file changed to being compressed and its datarun list changed to 210F6712010122500A3015210DDFEA010300900AA0F8FFFF (file size remain the same). We see that the offset the attribute remains the same, so we know it's the same attribute being changed. 
Then a new file, file4.txt, appears with the same MFT ref. It is resident. If you look into LogFile.csv and find LSN 1067158 you will see the DeallocateFileRecordSegment for suspicious.zip. Then at LSN 1067827 you find the InitializeFileRecordSegment for file4.txt.
Most software will not be able to recover the file suspicious.zip because its MFT record is overwritten and also fail at any signature based recovery since file is fragmented.

Explanation of run lists
For MFT ref 32 we found 22BD04CA2200 as datarun list. We interpret that as:
0x4bd clusters at LCN 0x22ca
00 indicates end of runs.
But since that is all information in the data run, we don't have enough information to extract the file. We need to know SectorsPerCluster (found in $Boot) in order to get the exact offset and also the exact number of bytes to extract. In this simple example there is only 1 run so we can just get the initialized stream size and extract that. The remaining bytes in the last cluster of the run, is what may be refrerred to as file slack (slack data after eof in the cluster). Actually file slack equals (1213*512)-620888=168 bytes.

For MFT ref 33 we found 210F6712010122500A3015210DDFEA010300. This run list is slightly more complicated since we are dealing with compression. Transforming it into a standard run list will look like this:
210F6712
0101
22500A3015
210DDFEA
0103
00

However, since the file was marked as compressed we need to redo it into compression units (chunks of 16 clusters each)
210F67120101
22500A3015
210DDFEA0103
00

Which resolves into:
0x0f clusters at LCN 0x1267. This data may be compressed and have 1 clusters of sparse data appended (size 0).
0xa50 clusters at LCN 0x2797 (0x1267+0x1530). This data is not compressed.
0x0d clusters at LCN 0x1276 (0x2797-Xor(0xeadf-1,0xffff)). This data may be compressed and have 3 clusters of sparse data appended (size 0). Also note we are dealing with a negative run.

In order to manually recover this file you must extract the first run and decompress it (LZNT1), then extract run 2 without decompression, then extract run 3 and decompress it (LZNT1), and finally merge together the 3 parts. Also remember to extract to correct size of chunk, otherwise you will get lots of leftover appended at end of chunk. No wonder no program can automate the recovery of such fragmented files without knowing the datarun list. 


Final note
The last file you see for a given MFTReference is most likely the one you will find by examining $MFT (since it contains no history).








