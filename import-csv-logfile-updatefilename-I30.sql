LOAD DATA LOCAL INFILE "__PathToCsv__"
INTO TABLE LogFile_UpdateFilename_I30
CHARACTER SET 'latin1'
COLUMNS TERMINATED BY '|'
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(lf_Offset,@lf_LSN,lf_CTime,lf_ATime,lf_MTime,lf_RTime,@lf_AllocSize,@lf_RealSize,lf_FileFlags,lf_ReparseTag,@lf_IsRedo)
SET 
lf_LSN = nullif(@lf_LSN,''),
lf_AllocSize = nullif(@lf_AllocSize,''),
lf_RealSize = nullif(@lf_RealSize,''),
lf_IsRedo = nullif(@lf_IsRedo,'')
;

