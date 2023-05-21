LOAD DATA LOCAL INFILE "__PathToCsv__"
INTO TABLE LogFile_INDX_I30
CHARACTER SET 'latin1'
COLUMNS TERMINATED BY '|'
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(lf_Offset,@lf_LSN,@lf_EntryNumber,@lf_MFTReference,@lf_MFTReferenceSeqNo,@lf_IndexFlags,@lf_MFTParentReference,@lf_MFTParentReferenceSeqNo,lf_CTime,lf_ATime,lf_MTime,lf_RTime,@lf_AllocSize,@lf_RealSize,lf_FileFlags,@lf_ReparseTag,@lf_EaSize,lf_FileName,@lf_FileNameModified,lf_NameSpace,@lf_SubNodeVCN,@IsRedo)
SET 
lf_LSN = nullif(@lf_LSN,''),
lf_EntryNumber = nullif(@lf_EntryNumber,''),
lf_MFTReference = nullif(@lf_MFTReference,''),
lf_MFTReferenceSeqNo = nullif(@lf_MFTReferenceSeqNo,''),
lf_IndexFlags = nullif(@lf_IndexFlags,''),
lf_MFTParentReference = nullif(@lf_MFTParentReference,''),
lf_MFTParentReferenceSeqNo = nullif(@lf_MFTParentReferenceSeqNo,''),
lf_AllocSize = nullif(@lf_AllocSize,''),
lf_RealSize = nullif(@lf_RealSize,''),
lf_ReparseTag = nullif(@lf_ReparseTag,''),
lf_EaSize = nullif(@lf_EaSize,''),
lf_FileNameModified = nullif(@lf_FileNameModified,''),
lf_SubNodeVCN = nullif(@lf_SubNodeVCN,0),
IsRedo = nullif(@IsRedo,'')
;

