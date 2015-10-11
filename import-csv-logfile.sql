LOAD DATA INFILE "__PathToCsv__"
INTO TABLE logfile
CHARACTER SET 'latin1'
COLUMNS TERMINATED BY '|'
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`lf_Offset`,@lf_MFTReference,@lf_RealMFTReference,@lf_MFTBaseRecRef,@lf_LSN,@lf_LSNPrevious,`lf_RedoOperation`,`lf_UndoOperation`,@lf_OffsetInMft,`lf_FileName`,`lf_CurrentAttribute`,`lf_TextInformation`,`lf_UsnJrnlFileName`,@lf_UsnJrnlMFTReference,@lf_UsnJrnlMFTParentReference,@lf_UsnJrnlTimestamp,`lf_UsnJrnlReason`,@lf_UsnJrnlUsn,@lf_SI_CTime,@lf_SI_ATime,@lf_SI_MTime,@lf_SI_RTime,`lf_SI_FilePermission`,@lf_SI_MaxVersions,@lf_SI_VersionNumber,@lf_SI_ClassID,@lf_SI_SecurityID,@lf_SI_QuotaCharged,@lf_SI_USN,`lf_SI_PartialValue`,@lf_FN_CTime,@lf_FN_ATime,@lf_FN_MTime,@lf_FN_RTime,@lf_FN_AllocSize,@lf_FN_RealSize,`lf_FN_Flags`,`lf_FN_Namespace`,@lf_DT_StartVCN,@lf_DT_LastVCN,@lf_DT_ComprUnitSize,@lf_DT_AllocSize,@lf_DT_RealSize,@lf_DT_InitStreamSize,`lf_DT_DataRuns`,`lf_DT_Name`,`lf_FileNameModified`,@lf_RedoChunkSize,@lf_UndoChunkSize,@lf_client_index,@lf_record_type,@lf_transaction_id,@lf_flags,@lf_target_attribute,@lf_lcns_to_follow,@lf_attribute_offset,@lf_MftClusterIndex,@lf_target_vcn,@lf_target_lcn,@InOpenAttributeTable,@FromRcrdSlack,@IncompleteTransaction)
SET 
lf_MFTReference = nullif(@lf_MFTReference,''),
lf_RealMFTReference = nullif(@lf_RealMFTReference,''),
lf_MFTBaseRecRef = nullif(@lf_MFTBaseRecRef,''),
lf_LSN = nullif(@lf_LSN,''),
lf_LSNPrevious = nullif(@lf_LSNPrevious,''),
lf_OffsetInMft = nullif(@lf_OffsetInMft,''),
lf_UsnJrnlMFTReference = nullif(@lf_UsnJrnlMFTReference,''),
lf_UsnJrnlMFTParentReference = nullif(@lf_UsnJrnlMFTParentReference,''),
lf_UsnJrnlTimestamp = nullif(@lf_UsnJrnlTimestamp,''),
lf_UsnJrnlUsn = nullif(@lf_UsnJrnlUsn,''),
lf_SI_CTime = nullif(@lf_SI_CTime,''),
lf_SI_ATime = nullif(@lf_SI_ATime,''),
lf_SI_MTime = nullif(@lf_SI_MTime,''),
lf_SI_RTime = nullif(@lf_SI_RTime,''),
lf_SI_MaxVersions = nullif(@lf_SI_MaxVersions,''),
lf_SI_VersionNumber = nullif(@lf_SI_VersionNumber,''),
lf_SI_ClassID = nullif(@lf_SI_ClassID,''),
lf_SI_SecurityID = nullif(@lf_SI_SecurityID,''),
lf_SI_QuotaCharged = nullif(@lf_SI_QuotaCharged,''),
lf_SI_USN = nullif(@lf_SI_USN,''),
lf_FN_CTime = nullif(@lf_FN_CTime,''),
lf_FN_ATime = nullif(@lf_FN_ATime,''),
lf_FN_MTime = nullif(@lf_FN_MTime,''),
lf_FN_RTime = nullif(@lf_FN_RTime,''),
lf_FN_AllocSize = nullif(@lf_FN_AllocSize,''),
lf_FN_RealSize = nullif(@lf_FN_RealSize,''),
lf_DT_StartVCN = nullif(@lf_DT_StartVCN,''),
lf_DT_LastVCN = nullif(@lf_DT_LastVCN,''),
lf_DT_ComprUnitSize = nullif(@lf_DT_ComprUnitSize,''),
lf_DT_AllocSize = nullif(@lf_DT_AllocSize,''),
lf_DT_RealSize = nullif(@lf_DT_RealSize,''),
lf_DT_InitStreamSize = nullif(@lf_DT_InitStreamSize,''),
lf_RedoChunkSize = nullif(@lf_RedoChunkSize,''),
lf_UndoChunkSize = nullif(@lf_UndoChunkSize,''),
lf_client_index = nullif(@lf_client_index,''),
lf_record_type = nullif(@lf_record_type,''),
lf_transaction_id = nullif(@lf_transaction_id,''),
lf_flags = nullif(@lf_flags,''),
lf_target_attribute = nullif(@lf_target_attribute,''),
lf_lcns_to_follow = nullif(@lf_lcns_to_follow,''),
lf_attribute_offset = nullif(@lf_attribute_offset,''),
lf_MftClusterIndex = nullif(@lf_MftClusterIndex,''),
lf_target_vcn = nullif(@lf_target_vcn,''),
lf_target_lcn = nullif(@lf_target_lcn,''),
InOpenAttributeTable = nullif(@InOpenAttributeTable,''),
FromRcrdSlack = nullif(@FromRcrdSlack,''),
IncompleteTransaction = nullif(@IncompleteTransaction,'')
;

