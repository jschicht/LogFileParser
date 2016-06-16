
CREATE TABLE LogFile_UpdateFilename_I30(
	Id					INT(11) NOT NULL AUTO_INCREMENT
	,lf_Offset			VARCHAR(18) NOT NULL
	,lf_LSN				BIGINT NOT NULL
	,lf_CTime			DATETIME(6) NOT NULL
	,lf_ATime			DATETIME(6) NOT NULL
	,lf_MTime			DATETIME(6) NOT NULL
	,lf_RTime			DATETIME(6) NOT NULL
	,lf_AllocSize		BIGINT NOT NULL
	,lf_RealSize		BIGINT NOT NULL
	,lf_FileFlags		VARCHAR(128) NOT NULL
	,lf_ReparseTag		VARCHAR(32) NOT NULL
	,lf_IsRedo          TINYINT(1) NOT NULL
	,PRIMARY KEY (Id)
);
