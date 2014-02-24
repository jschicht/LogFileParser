#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Comment=$LogFile parser utility for NTFS
#AutoIt3Wrapper_Res_Description=$LogFile parser utility for NTFS
#AutoIt3Wrapper_Res_Fileversion=1.0.0.18
#AutoIt3Wrapper_Res_LegalCopyright=Joakim Schicht
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#Obfuscator_Parameters=/cn 0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GuiEdit.au3>
#Include <WinAPIEx.au3>
#include <Array.au3>
#Include <String.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <File.au3>

Global $VerboseOn = 0, $CharReplacement=":", $de="|", $DoSplitCsv=False, $csvextra, $InputLogFile,$TargetMftCsvFile, $UsnJrnlFile, $SectorsPerCluster, $DoReconstructDataRuns=False, $debuglogfile, $csvextra, $CurrentTimestamp, $EncodingWhenOpen=2, $ReconstructDone=False
Global $begin, $ElapsedTime, $CurrentRecord, $i, $PreviousUsn,$PreviousUsnFileName, $PreviousRedoOp, $PreviousAttribute, $PreviousUsnReason, $undo_length, $RealMftRef, $PreviousRealRef
Global $ProgressLogFile, $ProgressReconstruct, $CurrentProgress=-1, $ProgressStatus, $ProgressUsnJrnl, $ProgressSize
Global $CurrentFileOffset, $InputFileSize, $MaxRecords, $Record_Size=4096, $Remainder = "", $_COMMON_KERNEL32DLL=DllOpen("kernel32.dll"), $PredictedRefNumber, $LogFileCsv, $LogFileIndxCsv, $LogFileDataRunsCsv, $LogFileDataRunsCsvFile, $LogFileDataRunsModCsv, $NtfsDbFile, $LogFileCsvFile, $LogFileIndxCsvfile, $LogFileDataRunsModCsvfile, $LogFileUndoWipeIndxCsv, $LogFileUndoWipeIndxCsvfile,$LogFileUsnJrnlCsv,$LogFileUsnJrnlCsvFile
Global $RecordOffset, $PredictedRefNumber, $this_lsn, $client_previous_lsn, $redo_operation, $undo_operation, $record_offset_in_mft, $attribute_offset, $hOutFileMFT, $tBuffer, $nBytes2, $HDR_BaseRecord, $FilePath
Global $nBytes, $rFile, $IRArr[12][2], $RPArr[11][2], $LUSArr[3][2],$EAInfoArr[5][2],$EAArr[8][2], $DataRunArr[2][18], $NewDataRunArr[1][18], $RowsProcessed, $MaxRows, $hQuery, $aRow, $aRow2, $iRows, $iColumns, $aRes, $sOutputFile
Global $RSTRsig = "52535452", $RCRDsig = "52435244", $BAADsig = "44414142", $CHKDsig = "444b4843", $Emptysig = "ffffffff"
Global $SI_CTime, $SI_ATime, $SI_MTime, $SI_RTime, $SI_FilePermission, $SI_MaxVersions, $SI_VersionNumber, $SI_ClassID, $SI_SecurityID, $SI_QuotaCharged, $SI_USN, $SI_PartialValue
Global $SI_CTime_Core,$SI_ATime_Core,$SI_MTime_Core,$SI_RTime_Core,$SI_CTime_Precision,$SI_ATime_Precision,$SI_MTime_Precision,$SI_RTime_Precision
Global $FN_CTime, $FN_ATime, $FN_MTime, $FN_RTime, $FN_AllocSize, $FN_RealSize, $FN_Flags, $FN_Name, $FN_NameType
Global $FN_CTime_Core,$FN_ATime_Core,$FN_MTime_Core,$FN_RTime_Core,$FN_CTime_Precision,$FN_ATime_Precision,$FN_MTime_Precision,$FN_RTime_Precision
Global $UsnJrnlFileReferenceNumber, $UsnJrnlParentFileReferenceNumber, $UsnJrnlTimestamp, $UsnJrnlReason, $UsnJrnlFileName, $FileNameModified, $UsnJrnlUsn, $UsnJrnlRef
Global $UsnJrnlCsv, $UsnJrnlCsvFile, $AttributeString, $KeptRef=-1, $TextInformation, $RedoChunkSize, $UndoChunkSize, $KeptRefTmp
Global $DT_NonResidentFlag, $DT_Flags, $DT_ComprUnitSize, $DT_RealSize, $DT_DataRuns, $DT_InitStreamSize, $DT_OffsetToDataRuns, $DT_StartVCN, $DT_LastVCN, $DT_AllocSize, $DT_Name
Global $FN_CTime_Core,$FN_CTime_Precision,$FN_ATime_Core,$FN_ATime_Precision,$FN_MTime_Core,$FN_MTime_Precision,$FN_RTime_Core,$FN_RTime_Precision
Global $SI_CTime_Core,$SI_CTime_Precision,$SI_ATime_Core,$SI_ATime_Precision,$SI_MTime_Core,$SI_MTime_Precision,$SI_RTime_Core,$SI_RTime_Precision
;Global $GlobalCounter = 1,$AttrArray[$GlobalCounter][2]

Global $RUN_VCN[1], $RUN_Clusters[1], $MFT_RUN_Clusters[1], $MFT_RUN_VCN[1], $DataQ[1], $AttrQ[1], $BytesPerCluster
Global $IsCompressed = False, $IsSparse = False
Global $outputpath=@ScriptDir, $hDisk, $sBuffer, $DataRun, $DATA_InitSize, $DATA_RealSize, $ImageOffset = 0, $ADS_Name
Global $TargetImageFile, $Entries, $IsImage=False, $IsPhysicalDrive=False, $ComboPhysicalDrives, $Combo

Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_CHECKED = 1
Global Const $GUI_UNCHECKED = 4
;Global Const $ES_AUTOVSCROLL = 64
Global Const $WS_VSCROLL = 0x00200000
Global Const $DT_END_ELLIPSIS = 0x8000
Global Const $GUI_DISABLE = 128

Global Const $STANDARD_INFORMATION = '10000000'
Global Const $ATTRIBUTE_LIST = '20000000'
Global Const $FILE_NAME = '30000000'
Global Const $OBJECT_ID = '40000000'
Global Const $SECURITY_DESCRIPTOR = '50000000'
Global Const $VOLUME_NAME = '60000000'
Global Const $VOLUME_INFORMATION = '70000000'
Global Const $DATA = '80000000'
Global Const $INDEX_ROOT = '90000000'
Global Const $INDEX_ALLOCATION = 'A0000000'
Global Const $BITMAP = 'B0000000'
Global Const $REPARSE_POINT = 'C0000000'
Global Const $EA_INFORMATION = 'D0000000'
Global Const $EA = 'E0000000'
Global Const $PROPERTY_SET = 'F0000000'
Global Const $LOGGED_UTILITY_STREAM = '00010000'
Global Const $ATTRIBUTE_END_MARKER = 'FFFFFFFF'

Global $tDelta = _WinTime_GetUTCToLocalFileTimeDelta()
Global $DateTimeFormat,$ExampleTimestampVal = "01CD74B3150770B8",$TimestampPrecision, $UTCconfig, $ParserOutDir

$Form = GUICreate("LogFile Parser 1.0.0.18", 540, 460, -1, -1)

$LabelLogFile = GUICtrlCreateLabel("$LogFile:",20,10,80,20)
$LogFileField = GUICtrlCreateInput("manadatory",70,10,350,20)
GUICtrlSetState($LogFileField, $GUI_DISABLE)
$ButtonLogFile = GUICtrlCreateButton("Select $LogFile", 430, 10, 100, 20)

$LabelUsnJrnl = GUICtrlCreateLabel("$UsnJrnl:",20,35,80,20)
$UsnJrnlField = GUICtrlCreateInput("No longer needed",70,35,350,20)
GUICtrlSetState($UsnJrnlField, $GUI_DISABLE)
$ButtonUsnJrnl = GUICtrlCreateButton("Select $UsnJrnl", 430, 35, 100, 20)
GUICtrlSetState($ButtonUsnJrnl, $GUI_DISABLE)

$LabelMFT = GUICtrlCreateLabel("MFT:",20,60,80,20)
$MFTField = GUICtrlCreateInput("optional (output of latest mft2csv)",70,60,350,20)
GUICtrlSetState($MFTField, $GUI_DISABLE)
$ButtonMFT = GUICtrlCreateButton("Get MFT csv", 430, 60, 100, 20)

$LabelTimestampFormat = GUICtrlCreateLabel("Timestamp format:",20,85,90,20)
$ComboTimestampFormat = GUICtrlCreateCombo("", 110, 85, 30, 25)
$LabelTimestampPrecision = GUICtrlCreateLabel("Precision:",150,85,50,20)
$ComboTimestampPrecision = GUICtrlCreateCombo("", 200, 85, 70, 25)
$CheckCsvSplit = GUICtrlCreateCheckbox("split csv", 280, 85, 60, 20)
GUICtrlSetState($CheckCsvSplit, $GUI_UNCHECKED)
$InputExampleTimestamp = GUICtrlCreateInput("",340,85,190,20)
GUICtrlSetState($InputExampleTimestamp, $GUI_DISABLE)

$Label1 = GUICtrlCreateLabel("Set decoded timestamps to specific region:",20,110,230,20)
$Combo2 = GUICtrlCreateCombo("", 230, 110, 85, 25)

$Label2 = GUICtrlCreateLabel("Set sectors per cluster:",320,110,120,20)
$InputSectorPerCluster = GUICtrlCreateInput("8",440,110,40,20)

$LabelSeparator = GUICtrlCreateLabel("Set separator:",20,135,70,20)
$SaparatorInput = GUICtrlCreateInput($de,90,135,20,20)
$SaparatorInput2 = GUICtrlCreateInput($de,120,135,30,20)
GUICtrlSetState($SaparatorInput2, $GUI_DISABLE)

$CheckReconstruct = GUICtrlCreateCheckbox("Reconstruct data runs", 280, 135, 150, 20)
GUICtrlSetState($CheckReconstruct, $GUI_UNCHECKED)

$CheckUnicode = GUICtrlCreateCheckbox("Unicode", 200, 135, 70, 20)
GUICtrlSetState($CheckUnicode, $GUI_UNCHECKED)

$ButtonStart = GUICtrlCreateButton("Start", 430, 135, 100, 30)
$myctredit = GUICtrlCreateEdit("", 0, 170, 540, 110, BitOr($ES_AUTOVSCROLL,$WS_VSCROLL))
_GUICtrlEdit_SetLimitText($myctredit, 128000)

_InjectTimeZoneInfo()
_InjectTimestampFormat()
_InjectTimestampPrecision()
_TranslateTimestamp()

GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Sleep(100)
	_TranslateSeparator()
	_TranslateTimestamp()
	Select
		Case $nMsg = $ButtonLogFile
			_SelectLogFile()
		Case $nMsg = $ButtonMFT
			_SelectMftCsv()
		Case $nMsg = $ButtonUsnJrnl
			_SelectUsnJrnl()
		Case $nMsg = $ButtonStart
			_Main()
		Case $nMsg = $GUI_EVENT_CLOSE
			Exit
	EndSelect
WEnd

Func _Main()
Global $DataRunArr[2][18], $NewDataRunArr[1][18]
Global $GlobalCounter = 1,$AttrArray[$GlobalCounter][2], $DoReconstructDataRuns=False
GUICtrlSetData($ProgressLogFile, 0)
GUICtrlSetData($ProgressUsnJrnl, 0)
GUICtrlSetData($ProgressReconstruct, 0)

If GUICtrlRead($CheckCsvSplit) = 1 Then
	$DoSplitCsv = True
EndIf

If FileExists($InputLogFile)=0 Then
	_DisplayInfo("Error: LogFile could not be found." & @CRLF)
	Return
EndIf

$SectorsPerCluster = GUICtrlRead($InputSectorPerCluster)
if StringIsDigit($SectorsPerCluster)=0 Then
	_DisplayInfo("Error: SectorsPerCluster not given in expected format (decimal)." & @CRLF)
	Return
EndIf
$BytesPerCluster=$SectorsPerCluster*512

If GUICtrlRead($CheckUnicode) = 1 Then
	$EncodingWhenOpen = 2+32
EndIf

If GUICtrlRead($CheckReconstruct) = 1 Then
	$DoReconstructDataRuns = True
	If $EncodingWhenOpen=34 Then
		MsgBox(0,"Warning","Reconstruct of dataruns is not supported with UNICODE. Continuing with ANSI")
		GUICtrlSetState($CheckUnicode, $GUI_UNCHECKED)
		$EncodingWhenOpen = 2
	EndIf
	If $ReconstructDone Then
		MsgBox(0,"Error","Reconstruct of dataruns requires a restart of the program")
		Return
	EndIf
EndIf

If $TargetMftCsvFile And FileGetEncoding($TargetMftCsvFile,2)>0 Then
	MsgBox(0,"Warning","Skipping import of $MFT csv because it is unicode")
	$TargetMftCsvFile = ""
	_DisplayInfo("Warning: Skipping import of $MFT csv because it is unicode" & @CRLF)
EndIf

$tDelta = _GetUTCRegion()-$tDelta
If @error Then
	_DisplayInfo("Error: Timezone configuration failed." & @CRLF)
	Return
EndIf
$tDelta = $tDelta*-1 ;Since delta is substracted from timestamp later on
_PrepareOutput()
_WriteCSVHeader()
If $DoSplitCsv Then _WriteCSVExtraHeader()

_DebugOut("Timestamps presented in UTC: " & $UTCconfig)
_DebugOut("Sectors per cluster: " & $SectorsPerCluster)
_DebugOut("DataRun reconstruct configuration: " & $DoReconstructDataRuns)

$tBuffer = DllStructCreate("byte[" & $Record_Size & "]")
$hFile = _WinAPI_CreateFile("\\.\" & $InputLogFile,2,2,7)
If $hFile = 0 Then
	_DebugOut("Error: Creating handle on $LogFile: " & _WinAPI_GetLastErrorMessage())
	Exit
EndIf

_DebugOut("Using $LogFile: " & $InputLogFile)
If FileExists($UsnJrnlFile) Then _DebugOut("Using $UsnJrnl: " & $UsnJrnlFile)
If $TargetMftCsvFile Then _DebugOut("Using MFT csv: " & $TargetMftCsvFile)
_DebugOut("Using DateTime format: " & $DateTimeFormat)
_DebugOut("Using timestamp precision: " & $TimestampPrecision)

$Progress = GUICtrlCreateLabel("Decoding $LogFile info and writing to csv", 10, 280,540,20)
GUICtrlSetFont($Progress, 12)
$ProgressStatus = GUICtrlCreateLabel("", 10, 310, 520, 20)
$ElapsedTime = GUICtrlCreateLabel("", 10, 325, 520, 20)
$ProgressLogFile = GUICtrlCreateProgress(10, 350, 520, 30)
$ProgressUsnJrnl = GUICtrlCreateProgress(10,  385, 520, 30)
$ProgressReconstruct = GUICtrlCreateProgress(10, 420, 520, 30)
$begin = TimerInit()
AdlibRegister("_LogFileProgress", 500)
$InputFileSize = _WinAPI_GetFileSizeEx($hFile)
$MaxRecords = Ceiling($InputFileSize/$Record_Size)
$RCRDRecord=""
$ConcatenatedRCRD=""
$DataUnprocessed = ""

For $i = 0 To $MaxRecords-1
	$CurrentRecord=$i
	_WinAPI_SetFilePointerEx($hFile, $i*$Record_Size, $FILE_BEGIN)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $Record_Size, $nBytes)
	$LogFileRecord = DllStructGetData($tBuffer, 1)
	$CurrentFileOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', 0, 'int64*', 0, 'dword', 1)
	$CurrentFileOffset = $CurrentFileOffset[3]-$Record_Size
	$Magic = StringMid($LogFileRecord,3,8)
	If $Magic = $RCRDsig Then
		$RCRDRecord = _DoFixup($LogFileRecord)
		If $RCRDRecord = "" then
			_DebugOut("Error: Record corrupt. The fixup failed at: " & $CurrentFileOffset)
			$Remainder = ""
			ContinueLoop
		EndIf
		$last_lsn = StringMid($RCRDRecord,19,16)
		$page_count = Dec(_SwapEndian(StringMid($RCRDRecord,43,4)),2)
		$page_position = Dec(_SwapEndian(StringMid($RCRDRecord,47,4)),2)
		$next_record_offset = StringMid($RCRDRecord,51,4)
		$last_end_lsn = StringMid($RCRDRecord,67,16)
		$RCRDHeader = StringMid($RCRDRecord,1,130)
		$RCRDRecord = $RCRDHeader&$Remainder&StringMid($RCRDRecord,131)
		$DataUnprocessed = _DecodeRCRD($RCRDRecord, $CurrentFileOffset, StringLen($Remainder))
		If ($last_lsn = $last_end_lsn) Or ($i < 4) Then
			$Remainder = ""
		Else
			$Remainder = $DataUnprocessed
		EndIf
		ContinueLoop
	ElseIf $Magic = $RSTRsig Then
		If $VerboseOn Then ConsoleWrite("RSTR record" & @CRLF)
		_DecodeRSTR($LogFileRecord)
		ContinueLoop
	ElseIf $Magic = $BAADsig Then
		ConsoleWrite("BAAD record" & @CRLF)
		ContinueLoop
	ElseIf $Magic = $CHKDsig Then
		ConsoleWrite("CHKD record" & @CRLF)
		ContinueLoop
	ElseIf $Magic = $Emptysig Then
		If $VerboseOn Then ConsoleWrite("Empty/Unitialized record" & @CRLF)
		ContinueLoop
	ElseIf $Magic <> $RSTRsig And $Magic <> $RCRDsig And $Magic <> $Emptysig Then
		ConsoleWrite("Invalid record signature" & @CRLF)
		ContinueLoop
	EndIf
Next
_WinAPI_CloseHandle($hFile)
_WinAPI_CloseHandle($hOutFileMFT)
_WinAPI_CloseHandle($LogFileCsv)
_WinAPI_CloseHandle($LogFileIndxCsv)
_WinAPI_CloseHandle($LogFileDataRunsCsv)
AdlibUnRegister("_LogFileProgress")
GUICtrlSetData($ProgressStatus, "Processing LogFile transaction " & $CurrentRecord+1 & " of " & $MaxRecords)
GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
GUICtrlSetData($ProgressLogFile, 100 * ($CurrentRecord+1) / $MaxRecords)

_DisplayInfo("$LogFile processing finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & @CRLF)

#cs
;x64 dll not working properly?
If @AutoItX64 Then
	$Sqlite3DllString = @ScriptDir & "\sqlite3_x64.dll"

Else
	$Sqlite3DllString = @ScriptDir & "\sqlite3.dll"
EndIf
#ce
$Sqlite3DllString = @ScriptDir & "\sqlite3.dll"

;set encoding
If GUICtrlRead($CheckUnicode) = 1 Then
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "PRAGMA encoding = 'UTF-16le';CREATE TABLE bogus(one INTEGER,two TEXT);", $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not PRAGMA encoding = UTF-16le: " & $NtfsDbFile & " : " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
		Exit
	EndIf
	_SQLite_Startup($Sqlite3DllString)
	If @error Then
		MsgBox(0,"Error","sqlite3.dll was not loaded. Returned error val: " & @error)
		Exit
	EndIf
	$hDb = _SQLite_Open($NtfsDbFile) ;Open db
	If @error Then
		MsgBox(0,"Error","Opening database failed and returned error val: " & @extended)
		Exit
	EndIf
	_SQLite_QuerySingleRow(-1, "PRAGMA encoding;", $aRow2)
	If $aRow2[0] <> 'UTF-16le' Then
		MsgBox(0,"Error","Detecting encoding was not correct")
		Exit
	EndIf
	_SQLite_Close()
	_SQLite_Shutdown()
EndIf

; Create database with tables and import csv
$begin = TimerInit()
If $DoReconstructDataRuns Then
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE DataRuns (lf_Offset TEXT,lf_MFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_FileName TEXT,lf_LSN INTEGER,lf_RedoOperation TEXT,lf_UndoOperation TEXT,lf_OffsetInMft INTEGER,lf_AttributeOffset INTEGER,lf_SI_USN INTEGER,lf_DataName TEXT,lf_Flags TEXT,lf_NonResident TEXT,lf_CompressionUnitSize TEXT,lf_FileSize INTEGER,lf_InitializedStreamSize INTEGER,lf_OffsetToDataRuns INTEGER,lf_DataRuns TEXT);", $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not create table DataRuns in database: " & $NtfsDbFile & " : " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
		Exit
	EndIf
EndIf

$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE LogFile (lf_Offset TEXT,lf_MFTReference INTEGER,lf_RealMFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_LSN INTEGER,lf_LSNPrevious INTEGER,lf_RedoOperation TEXT,lf_UndoOperation TEXT,lf_OffsetInMft INTEGER,lf_FileName TEXT,lf_CurrentAttribute TEXT,lf_TextInformation TEXT,lf_UsnJrlFileName TEXT,lf_UsnJrlMFTReference INTEGER,lf_UsnJrlMFTParentReference INTEGER,lf_UsnJrlTimestamp TEXT,lf_UsnJrlReason TEXT,lf_UsnJrnlUsn INTEGER,lf_SI_CTime TEXT,lf_SI_ATime TEXT,lf_SI_MTime TEXT,lf_SI_RTime TEXT,lf_SI_FilePermission TEXT,lf_SI_MaxVersions INTEGER,lf_SI_VersionNumber INTEGER,lf_SI_ClassID INTEGER,lf_SI_SecurityID INTEGER,lf_SI_QuotaCharged INTEGER,lf_SI_USN INTEGER,lf_SI_PartialValue TEXT,lf_FN_CTime TEXT,lf_FN_ATime TEXT,lf_FN_MTime TEXT,lf_FN_RTime TEXT,lf_FN_AllocSize INTEGER,lf_FN_RealSize INTEGER,lf_FN_Flags TEXT,lf_FN_Namespace TEXT,lf_DT_StartVCN INTEGER,lf_DT_LastVCN INTEGER,lf_DT_ComprUnitSize INTEGER,lf_DT_AllocSize INTEGER,lf_DT_RealSize INTEGER,lf_DT_InitStreamSize INTEGER,lf_DT_DataRuns TEXT,lf_DT_Name TEXT,lf_FileNameModified INTEGER,lf_RedoChunkSize INTEGER,lf_UndoChunkSize INTEGER);", $sOutputFile)
If $SQLiteExe <> 0 Then
	MsgBox(0,"Error","Could not create table LogFile in database: " & $NtfsDbFile & " : " & @error)
	ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	Exit
EndIf

$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE IndexEntries (lf_Offset TEXT,lf_LSN INTEGER,lf_EntryNumber INTEGER,lf_MFTReference INTEGER,lf_MFTReferenceSeqNo INTEGER,lf_IndexFlags TEXT,lf_MFTParentReference INTEGER,lf_MFTParentReferenceSeqNo INTEGER,lf_CTime TEXT,lf_ATime TEXT,lf_MTime TEXT,lf_RTime TEXT,lf_AllocSize INTEGER,lf_RealSize INTEGER,lf_FileFlags TEXT,lf_FileName TEXT,lf_FileNameModified TEXT,lf_NameSpace TEXT,lf_SubNodeVCN TEXT);", $sOutputFile)
If $SQLiteExe <> 0 Then
	MsgBox(0,"Error","Could not create table IndexEntries in database: " & $NtfsDbFile & " : " & @error)
	ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	Exit
EndIf
if $DoReconstructDataRuns Then
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileDataRunsCsvfile) & "' DataRuns" & @CRLF, $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not import " & $LogFileDataRunsCsvfile & " into database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
		Exit
	EndIf
EndIf
$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileCsvFile) & "' LogFile" & @CRLF, $sOutputFile)
If $SQLiteExe <> 0 Then
	MsgBox(0,"Error","Could not import " & $LogFileCsvFile & " into database: " & @error)
	ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	Exit
EndIf
$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileIndxCsvfile) & "' IndexEntries" & @CRLF, $sOutputFile)
If $SQLiteExe <> 0 Then
	MsgBox(0,"Error","Could not import " & $LogFileIndxCsvfile & " into database: " & @error)
	ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
EndIf

_SQLite_Startup($Sqlite3DllString)
If @error Then
	MsgBox(0,"Error","sqlite3.dll was not loaded. Returned error val: " & @error)
	Exit
EndIf
$hDb = _SQLite_Open($NtfsDbFile) ;Open db
If @error Then
	MsgBox(0,"Error","Opening database failed and returned error val: " & @extended)
	Exit
EndIf

$command = _SQLite_Exec($hDb, "DELETE from LogFile where ROWID = 1;")
If @error Then
	MsgBox(0,"Error","DELETE from LogFile failed and returned error val: " & $command)
	Exit
EndIf
$command = _SQLite_Exec($hDb, "DELETE from IndexEntries where ROWID = 1;")
If @error Then
	MsgBox(0,"Error","DELETE from IndexEntries failed and returned error val: " & $command)
	Exit
EndIf

_SQLite_Close()
_SQLite_Shutdown()

If $TargetMftCsvFile Then
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE Mft (" _
		& "RecordOffset TEXT,Signature TEXT,IntegrityCheck TEXT,Style TEXT,HEADER_MFTREcordNumber INTEGER,HEADER_SequenceNo INTEGER,Header_HardLinkCount INTEGER,FN_ParentReferenceNo INTEGER,FN_ParentSequenceNo INTEGER,FN_FileName TEXT,FilePath TEXT,HEADER_Flags TEXT," _
		& "RecordActive TEXT,FileSizeBytes INTEGER,SI_FilePermission TEXT,FN_Flags TEXT,FN_NameType TEXT,ADS TEXT,SI_CTime TEXT,SI_ATime TEXT,SI_MTime TEXT,SI_RTime TEXT,MSecTest TEXT,FN_CTime TEXT,FN_ATime TEXT,FN_MTime TEXT,FN_RTime TEXT,CTimeTest TEXT," _
		& "FN_AllocSize INTEGER,FN_RealSize INTEGER,SI_USN INTEGER,DATA_Name TEXT,DATA_Flags TEXT,DATA_LengthOfAttribute TEXT,DATA_IndexedFlag TEXT,DATA_VCNs INTEGER,DATA_NonResidentFlag INTEGER,DATA_CompressionUnitSize INTEGER,HEADER_LSN INTEGER,HEADER_RecordRealSize INTEGER," _
		& "HEADER_RecordAllocSize INTEGER,HEADER_BaseRecord INTEGER,HEADER_BaseRecSeqNo INTEGER,HEADER_NextAttribID TEXT,DATA_AllocatedSize INTEGER,DATA_RealSize INTEGER,DATA_InitializedStreamSize INTEGER,SI_HEADER_Flags TEXT,SI_MaxVersions INTEGER,SI_VersionNumber INTEGER," _
		& "SI_ClassID INTEGER,SI_OwnerID INTEGER,SI_SecurityID INTEGER,FN_CTime_2 TEXT,FN_ATime_2 TEXT,FN_MTime_2 TEXT,FN_RTime_2 TEXT,FN_AllocSize_2 INTEGER,FN_RealSize_2 INTEGER,FN_Flags_2 TEXT,FN_NameLength_2 INTEGER,FN_NameType_2 TEXT,FN_FileName_2 TEXT," _
		& "GUID_ObjectID TEXT,GUID_BirthVolumeID TEXT,GUID_BirthObjectID TEXT,GUID_BirthDomainID TEXT,VOLUME_NAME_NAME TEXT,VOL_INFO_NTFS_VERSION TEXT,VOL_INFO_FLAGS TEXT,FN_CTime_3 TEXT,FN_ATime_3 TEXT,FN_MTime_3 TEXT,FN_RTime_3 TEXT,FN_AllocSize_3 INTEGER," _
		& "FN_RealSize_3 INTEGER,FN_Flags_3 TEXT,FN_NameLength_3 INTEGER,FN_NameType_3 TEXT,FN_FileName_3 TEXT,DATA_Name_2 TEXT,DATA_NonResidentFlag_2 INTEGER,DATA_Flags_2 TEXT,DATA_LengthOfAttribute_2 INTEGER,DATA_IndexedFlag_2 INTEGER,DATA_StartVCN_2 INTEGER," _
		& "DATA_LastVCN_2 INTEGER,DATA_VCNs_2 INTEGER,DATA_CompressionUnitSize_2 INTEGER,DATA_AllocatedSize_2 INTEGER,DATA_RealSize_2 INTEGER,DATA_InitializedStreamSize_2 INTEGER,DATA_Name_3 TEXT,DATA_NonResidentFlag_3 INTEGER,DATA_Flags_3 TEXT,DATA_LengthOfAttribute_3 INTEGER," _
		& "DATA_IndexedFlag_3 INTEGER,DATA_StartVCN_3 INTEGER,DATA_LastVCN_3 INTEGER,DATA_VCNs_3 INTEGER,DATA_CompressionUnitSize_3 INTEGER,DATA_AllocatedSize_3 INTEGER,DATA_RealSize_3 INTEGER,DATA_InitializedStreamSize_3 INTEGER,STANDARD_INFORMATION_ON INTEGER," _
		& "ATTRIBUTE_LIST_ON INTEGER,FILE_NAME_ON INTEGER,OBJECT_ID_ON INTEGER,SECURITY_DESCRIPTOR_ON INTEGER,VOLUME_NAME_ON INTEGER,VOLUME_INFORMATION_ON INTEGER,DATA_ON INTEGER,INDEX_ROOT_ON INTEGER,INDEX_ALLOCATION_ON INTEGER,BITMAP_ON INTEGER,REPARSE_POINT_ON INTEGER," _
		& "EA_INFORMATION_ON INTEGER,EA_ON INTEGER,PROPERTY_SET_ON INTEGER,LOGGED_UTILITY_STREAM_ON INTEGER" _
		& ");", $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not create table Mft in database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	EndIf
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($TargetMftCsvFile) & "' Mft" & @CRLF, $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not import " & $TargetMftCsvFile & " into database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	EndIf
;	_SQLite_Startup($Sqlite3DllString)
;	if $TargetMftCsvFile Then
;		$command = _SQLite_Exec($hDb, "DELETE from Mft where ROWID = 1;")
;		If @error Then
;			MsgBox(0,"Error","DELETE from Mft failed and returned error val: " & $command)
;			Exit
;		EndIf
;	EndIf
;	_SQLite_Close()
;	_SQLite_Shutdown()
	_SQLite_SQLiteExe2($NtfsDbFile, "DELETE from Mft where ROWID = 1;", $sOutputFile)
	_SQLite_SQLiteExe2($NtfsDbFile, "UPDATE Mft set header_lsn = -1 where header_lsn = '';", $sOutputFile)
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE MftTmp as select HEADER_MFTRecordNumber,HEADER_LSN,FN_FileName,FilePath from Mft;", $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not create table MftTmp in database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	EndIf
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE LogFileTmp as select * from LogFile left join MftTmp on LogFile.lf_LSN=MftTmp.HEADER_LSN;", $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not create table MftTmp in database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	EndIf
	_SQLite_SQLiteExe2($NtfsDbFile, "DROP TABLE LogFile;", $sOutputFile)
	_SQLite_SQLiteExe2($NtfsDbFile, "ALTER TABLE LogFileTmp rename to LogFile;", $sOutputFile)
EndIf
_DisplayInfo("Importing of csv's to db and update of tables took " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & @CRLF)

;----------------- UsnJrnl
If FileExists($UsnJrnlFile) Then
	$Progress = GUICtrlCreateLabel("Decoding $UsnJrnl info and writing to csv", 10, 280,540,20)
	GUICtrlSetFont($Progress, 12)
	$begin = TimerInit()
	Dim $tBuffer2, $hUsnJrnl, $RawPage="", $TestHeader, $UsnJrnlPage="", $Remainder="", $SQLiteExe, $Record_Size = 4096, $nBytes=""
	$tBuffer2 = DllStructCreate("byte[" & $Record_Size & "]")
	$hUsnJrnl = _WinAPI_CreateFile("\\.\" & $UsnJrnlFile,2,2,7)
	If $hUsnJrnl = 0 Then
		ConsoleWrite("Error: Creating handle on file" & @CRLF)
		Exit
	EndIf
	$UsnJrnlCsvFile = $ParserOutDir & "\UsnJrnl.csv"
	$UsnJrnlCsv = FileOpen($UsnJrnlCsvFile, $EncodingWhenOpen)
	If @error Then
		ConsoleWrite("Error creating: " & $UsnJrnlCsvFile & @CRLF)
		Exit
	EndIf
	$UsnJrnl_Csv_Header = "MFTReference"&$de&"MFTParentReference"&$de&"USN"&$de&"Timestamp"&$de&"Reason"&$de&"SourceInfo"&$de&"FileAttributes"&$de&"FileName"&$de&"FileNameModified"
	FileWriteLine($UsnJrnlCsv, $UsnJrnl_Csv_Header & @CRLF)
	$InputFileSize = _WinAPI_GetFileSizeEx($hUsnJrnl)
	ConsoleWrite("$MaxRecords " & $MaxRecords & @CRLF) ; 1712425
	AdlibRegister("_UsnJrnlProgress",500)
	$MaxRecords = Ceiling($InputFileSize/$Record_Size)
	For $i = 0 To $MaxRecords-1
		$CurrentRecord = $i
		_WinAPI_SetFilePointerEx($hUsnJrnl, $i*$Record_Size, $FILE_BEGIN)
		_WinAPI_ReadFile($hUsnJrnl, DllStructGetPtr($tBuffer2), $Record_Size, $nBytes)
		$RawPage = DllStructGetData($tBuffer2, 1)
		_UsnProcessPage(StringMid($RawPage,3))
	Next
	AdlibUnRegister("_UsnJrnlProgress")
    GUICtrlSetData($ProgressStatus, "Processing UsnJrnl record " & $CurrentRecord+1 & " of " & $MaxRecords)
    GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($ProgressUsnJrnl, 100 * ($CurrentRecord+1) / $MaxRecords)
	_WinAPI_CloseHandle($hUsnJrnl)
	_WinAPI_CloseHandle($UsnJrnlCsv)
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE UsnJrnl (UsnJrnlMFTReference INTEGER,UsnJrnlMFTParentReference INTEGER,UsnJrnlUSN INTEGER,UsnJrnlTimestamp TEXT,UsnJrnlReason TEXT,UsnJrnlSourceInfo TEXT,UsnJrnlFileAttributes TEXT,UsnJrnlFileName TEXT,UsnJrnlFileNameModified INTEGER);", $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not create table UsnJrnl in database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
		Exit
	EndIf
	$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($UsnJrnlCsvFile) & "' UsnJrnl" & @CRLF, $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not import " & $UsnJrnlCsvFile & " into database: " & @error)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
		Exit
	EndIf
	_SQLite_Startup($Sqlite3DllString)
	If @error Then
		MsgBox(0,"Error","sqlite3.dll was not loaded. Returned error val: " & @error)
		Exit
	EndIf
	$hDb = _SQLite_Open($NtfsDbFile) ;Open db
	If @error Then
		MsgBox(0,"Error","Opening database failed and returned error val: " & @extended)
		Exit
	EndIf
	$command = _SQLite_Exec($hDb, "DELETE from UsnJrnl where ROWID = 1;")
	If @error Then
		MsgBox(0,"Error","DELETE from UsnJrnl failed and returned error val: " & $command)
		Exit
	EndIf
;	_SQLite_Exec($hDb, "DELETE from LogFile where ROWID = 1;")
;	Join filename from UsnJrnl into LogFile
	ProgressOn("Stage 3: (joining data from UsnJrnl into LogFile)", "", "", -1, -1, 16)
	ProgressSet(0, 0 & " percent")
	$command = _SQLite_Exec($hDb, "create table LogFileTmp as select * from LogFile inner join UsnJrnl on LogFile.lf_SI_USN=UsnJrnl.UsnJrnlUSN where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
	If @error Then
		MsgBox(0,"Error","Create table LogFileTmp failed and returned error val: " & $command)
		Exit
	EndIf
	$command = _SQLite_Exec($hDb, "update LogFile set lf_UsnJrlFileName = (select UsnJrnlFileName from LogFileTmp where LogFileTmp.UsnJrnlUSN=LogFile.lf_SI_USN) where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
	If @error Then
		MsgBox(0,"Error","update LogFile set lf_UsnJrlFileName failed and returned error val: " & $command)
		Exit
	EndIf
	ProgressSet(20, 20 & " percent")
	$command = _SQLite_Exec($hDb, "update LogFile set lf_UsnJrlMFTReference = (select UsnJrnlMFTReference from LogFileTmp where LogFileTmp.UsnJrnlUSN=LogFile.lf_SI_USN) where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
	If @error Then
		MsgBox(0,"Error","update LogFile set lf_UsnJrlMFTReference failed and returned error val: " & $command)
		Exit
	EndIf
	ProgressSet(40, 40 & " percent")
	$command = _SQLite_Exec($hDb, "update LogFile set lf_UsnJrlMFTParentReference = (select UsnJrnlMFTParentReference from LogFileTmp where LogFileTmp.UsnJrnlUSN=LogFile.lf_SI_USN) where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
	If @error Then
		MsgBox(0,"Error","update LogFile set lf_UsnJrlMFTParentReference failed and returned error val: " & $command)
		Exit
	EndIf
	ProgressSet(60, 60 & " percent")
	$command = _SQLite_Exec($hDb, "update LogFile set lf_UsnJrlTimestamp = (select UsnJrnlTimestamp from LogFileTmp where LogFileTmp.UsnJrnlUSN=LogFile.lf_SI_USN) where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
	If @error Then
		MsgBox(0,"Error","update LogFile set lf_UsnJrlTimestamp failed and returned error val: " & $command)
		Exit
	EndIf
	ProgressSet(80, 80 & " percent")
	$command = _SQLite_Exec($hDb, "update LogFile set lf_UsnJrlReason = (select UsnJrnlReason from LogFileTmp where LogFileTmp.UsnJrnlUSN=LogFile.lf_SI_USN) where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
	If @error Then
		MsgBox(0,"Error","update LogFile set lf_UsnJrlReason failed and returned error val: " & $command)
		Exit
	EndIf
	If $DoReconstructDataRuns Then
;	$command = _SQLite_Exec($hDb, "create table LogFile2 as select * from LogFile order by LSN asc;")
		$command = _SQLite_Exec($hDb, "update DataRuns set lf_FileName = (select UsnJrnlFileName from LogFileTmp where LogFileTmp.UsnJrnlUSN=DataRuns.lf_SI_USN) where lf_SI_USN <> '' and lf_SI_USN <> '-' and lf_SI_USN <> 'PARTIAL VALUE';")
		If @error Then
			MsgBox(0,"Error","update DataRuns set FileName failed and returned error val: " & $command)
			Exit
		EndIf
	EndIf
	ProgressSet(100, "Done")
	_SQLite_Close()
	_SQLite_Shutdown()
	ProgressOff()
	_DisplayInfo("$UsnJrnl processing finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & @CRLF)
EndIf

If FileExists($UsnJrnlFile) Or $TargetMftCsvFile Then
	$SQLiteExe2 = _SQLite_SQLiteExe2($NtfsDbFile, ".headers on" & @CRLF & ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".output LogFileJoined.csv" & @CRLF & "select * from LogFile;" & @CRLF, $sOutputFile)
	If $SQLiteExe <> 0 Then
		MsgBox(0,"Error","Could not export LogFile table to csv: " & @error)
		ConsoleWrite("@error: " & @error & @CRLF)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
		Exit
	EndIf
	$moved = FileMove(@ScriptDir&"\LogFileJoined.csv",$ParserOutDir&"\LogFileJoined.csv",9)
EndIf

;remove bogus table
If GUICtrlRead($CheckUnicode) = 1 Then
	$SQLiteExe2 = _SQLite_SQLiteExe2($NtfsDbFile, "DROP TABLE bogus;", $sOutputFile)
	If $SQLiteExe2 <> 0 Then
		MsgBox(0,"Error","Could not DROP TABLE bogus: " & @error)
		ConsoleWrite("@error: " & @error & @CRLF)
		ConsoleWrite("$SQLiteExe: " & $SQLiteExe2 & @CRLF)
		Exit
	EndIf
EndIf

;--------- DataRuns
If Not $DoReconstructDataRuns Then
	_DisplayInfo("Done!" & @CRLF)
;	GUICtrlSetData($ProgressLogFile, 0)
;	GUICtrlSetData($ProgressUsnJrnl, 0)
;	GUICtrlSetData($ProgressReconstruct, 0)
	Return
EndIf
$Progress = GUICtrlCreateLabel("Reconstructing dataruns", 10, 280,540,20)
GUICtrlSetFont($Progress, 12)
$begin = TimerInit()
$sSQliteDll = _SQLite_Startup($Sqlite3DllString)
If @error Then
	MsgBox(0,"Error","sqlite3.dll was not loaded. Returned error val: " & @error)
	Exit
EndIf
ConsoleWrite("SQLite3.dll Loaded: " & $sSQliteDll & @CRLF)
ConsoleWrite("SQLite version: " & _SQLite_LibVersion() & @CRLF)
$hDb = _SQLite_Open($NtfsDbFile) ;Open db
If @error Then
	MsgBox(0,"Error","Opening database failed and returned error val: " & @extended)
	Exit
EndIf
$command = _SQLite_Exec($hDb, "UPDATE Dataruns set lf_OffsetToDataRuns = 0 where lf_OffsetToDataRuns = '';") ;Replace all empty values so we can filter the column later on
If @error Then
	MsgBox(0,"Error","Updating the DataRuns table failed and returned error val: " & $command)
	Exit
EndIf
$command = _SQLite_GetTable2d($hDb, "SELECT Count(*) FROM DataRuns;", $aRes, $iRows, $iColumns) ;Get number of rows
If @error Then
	MsgBox(0,"Error","Counting rows failed and returned error val: " & $command)
	Exit
EndIf
If IsArray($aRes) Then
	ConsoleWrite("Total rows to process for dataruns: " & $aRes[1][0] & @CRLF)
	$MaxRows=$aRes[1][0]
Else
	MsgBox(0,"Error","Could not resolve rows in DataRuns table.")
	Exit
EndIf
$RowsProcessed=0
$command = _SQLite_Query($hDb, "SELECT distinct(lf_MFTReference) from Dataruns;", $hQuery) ; Get distinct reference numbers
If @error Then
	MsgBox(0,"Error","SQL select query failed and returned error val: " & $command)
	Exit
EndIf
;ProgressOn("Stage 4: (reconstructing dataruns)", "", "", -1, -1, 16)
AdlibRegister("_DataRunReconstructProgress")
$Counter = 0
While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK
	$TargetRef = $aRow[0]
	If $TargetRef = 'lf_MFTReference' Then ContinueLoop
	ConsoleWrite("Current FileRef: " & $TargetRef & @CRLF)
	$command = _SQLite_GetTable2d($hDb, "SELECT * from Dataruns where lf_MFTReference = "&"'"&$TargetRef&"'"&" order by lf_LSN asc;", $DataRunArr, $iRows, $iColumns) ;Generate array from each ref and order it low-high by LSN
	If @error Then
		MsgBox(0,"Error","SQL select query failed and returned error val: " & $command)
		Exit
	EndIf
;	_ArrayDisplay($DataRunArr,"$DataRunArr")
	_ArrayDelete($DataRunArr,0) ;Remove header
;	_ArrayDisplay($DataRunArr,"$DataRunArr")
	For $i = 0 To UBound($DataRunArr)-1
		$RowsProcessed+=1
		$TestRef = $DataRunArr[$i][1]
		$RefAlreadyExist = _ArraySearch($NewDataRunArr,$TestRef,0,0,1,2,1,1)
		$RedoOperation = $DataRunArr[$i][5]
		If $RefAlreadyExist = -1 Or ($RedoOperation="CreateAttribute" Or $RedoOperation="InitializeFileRecordSegment") Then
			If $RedoOperation<>"CreateAttribute" And $RedoOperation<>"InitializeFileRecordSegment" And $DataRunArr[$i][16]="" Then $DataRunArr[$i][16] = 64
			;Write to new row
			$NewDataRunArr[$Counter][0] = $DataRunArr[$i][0] ; Offset first record
			$NewDataRunArr[$Counter][1] = $DataRunArr[$i][1] ; Ref
			$NewDataRunArr[$Counter][2] = $DataRunArr[$i][2] ; BaseRecRef
			$NewDataRunArr[$Counter][3] = $DataRunArr[$i][3] ; File Name
			$NewDataRunArr[$Counter][4] = $DataRunArr[$i][4] ; LSN
			$NewDataRunArr[$Counter][5] = $DataRunArr[$i][5] ; Redo Op
			$NewDataRunArr[$Counter][6] = $DataRunArr[$i][6] ; Undo Op
			$NewDataRunArr[$Counter][7] = $DataRunArr[$i][7] ; Offset In MFT
			$NewDataRunArr[$Counter][8] = $DataRunArr[$i][8] ; Attribute Offset
			$NewDataRunArr[$Counter][9] = $DataRunArr[$i][9] ; USN
			$NewDataRunArr[$Counter][10] = $DataRunArr[$i][10] ; DataName
			$NewDataRunArr[$Counter][11] = $DataRunArr[$i][11] ; Flags
			$NewDataRunArr[$Counter][12] = $DataRunArr[$i][12] ; Non-Resident
			$NewDataRunArr[$Counter][13] = $DataRunArr[$i][13] ; Compression unit size
			$NewDataRunArr[$Counter][14] = $DataRunArr[$i][14] ; File size
			$NewDataRunArr[$Counter][15] = $DataRunArr[$i][15] ; Initialized size
			$NewDataRunArr[$Counter][16] = $DataRunArr[$i][16] ; Offset to datarun
;			$NewDataRunArr[$Counter][16] = $MaxOffsetToDataruns ; Offset to datarun
			If $DataRunArr[$i][17] <> "" Then $NewDataRunArr[$Counter][17] = _UpdateDataRunInformation($NewDataRunArr[$Counter][5],$NewDataRunArr[$Counter][8],$NewDataRunArr[$Counter][16],$DataRunArr[$i][17],$NewDataRunArr[$Counter][17])
			$Counter+=1
			Redim $NewDataRunArr[2+$Counter][18]
			ContinueLoop
		EndIf
	; Update existing row
		If $DataRunArr[$i][2] <> "" Then $NewDataRunArr[$Counter-1][2] = $DataRunArr[$i][2]
		If $DataRunArr[$i][3] <> "" Then $NewDataRunArr[$Counter-1][3] = $DataRunArr[$i][3]
		If $DataRunArr[$i][4] <> "" Then $NewDataRunArr[$Counter-1][4] = $DataRunArr[$i][4]
		If $DataRunArr[$i][5] <> "" Then $NewDataRunArr[$Counter-1][5] = $DataRunArr[$i][5]
		If $DataRunArr[$i][6] <> "" Then $NewDataRunArr[$Counter-1][6] = $DataRunArr[$i][6]
		If $DataRunArr[$i][7] <> "0" Then $NewDataRunArr[$Counter-1][7] = $DataRunArr[$i][7]
		If $DataRunArr[$i][8] <> "0" Then $NewDataRunArr[$Counter-1][8] = $DataRunArr[$i][8]
;		If $DataRunArr[$i][9] <> "" Then $NewDataRunArr[$Counter-1][9] = $DataRunArr[$i][9]
		If $DataRunArr[$i][10] <> "" Then $NewDataRunArr[$Counter-1][10] = $DataRunArr[$i][10]
		If $DataRunArr[$i][11] <> "" Then $NewDataRunArr[$Counter-1][11] = $DataRunArr[$i][11]
		If $DataRunArr[$i][12] <> "" Then $NewDataRunArr[$Counter-1][12] = $DataRunArr[$i][12]
		If $DataRunArr[$i][13] <> "" Then $NewDataRunArr[$Counter-1][13] = $DataRunArr[$i][13]
		If $DataRunArr[$i][14] <> "" Then $NewDataRunArr[$Counter-1][14] = $DataRunArr[$i][14]
		If $DataRunArr[$i][15] <> "" Then $NewDataRunArr[$Counter-1][15] = $DataRunArr[$i][15]
		If $DataRunArr[$i][16] <> "" Then $NewDataRunArr[$Counter-1][16] = $DataRunArr[$i][16]
		If $DataRunArr[$i][17] <> "" Then $NewDataRunArr[$Counter-1][17] = _UpdateDataRunInformation($NewDataRunArr[$Counter-1][5],$NewDataRunArr[$Counter-1][8],$NewDataRunArr[$Counter-1][16],$DataRunArr[$i][17],$NewDataRunArr[$Counter-1][17])
	Next
	_ArrayDelete($NewDataRunArr,UBound($NewDataRunArr))
WEnd
;_ArrayDisplay($NewDataRunArr,"$NewDataRunArr")
if $NewDataRunArr[UBound($NewDataRunArr)-1][0] = '' Then _ArrayDelete($NewDataRunArr,UBound($NewDataRunArr))
if $NewDataRunArr[UBound($NewDataRunArr)-1][0] = '' Then _ArrayDelete($NewDataRunArr,UBound($NewDataRunArr))
;_ArrayDelete($NewDataRunArr,UBound($NewDataRunArr))
;_ArrayDelete($NewDataRunArr,UBound($NewDataRunArr))
;_ArrayDisplay($NewDataRunArr,"$NewDataRunArr")
;Write line by line of final dataruns information from array to csv
For $k = 0 To UBound($NewDataRunArr)-1
	FileWriteLine($LogFileDataRunsModCsv, $NewDataRunArr[$k][1]&$de&$NewDataRunArr[$k][2]&$de&$NewDataRunArr[$k][3]&$de&$NewDataRunArr[$k][4]&$de&$NewDataRunArr[$k][7]&$de&$NewDataRunArr[$k][10]&$de&$NewDataRunArr[$k][11]&$de&$NewDataRunArr[$k][12]&$de&$NewDataRunArr[$k][14]&$de&$NewDataRunArr[$k][15]&$de&$NewDataRunArr[$k][17] & @CRLF)
Next
FileFlush($LogFileDataRunsModCsv)
FileClose($LogFileDataRunsModCsv)
_DisplayInfo("Reconstruction of dataruns finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & @CRLF)
$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE DataRunsResolved (lf_MFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_FileName TEXT,lf_LSN INTEGER,lf_OffsetInMft INTEGER,lf_DataName TEXT,lf_Flags TEXT,lf_NonResident INTEGER,lf_FileSize INTEGER,lf_InitializedStreamSize INTEGER,lf_DataRuns TEXT);", $sOutputFile)
If $SQLiteExe <> 0 Then
	MsgBox(0,"Error","Could not create table DataRunsResolved in database: " & @error)
	ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
	Exit
EndIf
$SQLiteExe = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileDataRunsModCsvfile) & "' DataRunsResolved" & @CRLF, $sOutputFile)
If $SQLiteExe <> 0 Then
	MsgBox(0,"Error","Could not import " & $LogFileDataRunsModCsvfile & " into database: " & @error)
	ConsoleWrite("$SQLiteExe: " & $SQLiteExe & @CRLF)
EndIf
$command = _SQLite_Exec($hDb, "DELETE from DataRunsResolved where ROWID = 1;")
If @error Then
	MsgBox(0,"Error","DELETE from DataRunsResolved failed and returned error val: " & $command)
	Exit
EndIf
_SQLite_Close()
_SQLite_Shutdown()
AdlibUnRegister("_DataRunReconstructProgress")
GUICtrlSetData($ProgressStatus, "Reconstructing dataruns at row " & $RowsProcessed+1 & " of " & $MaxRows)
GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
GUICtrlSetData($ProgressReconstruct, 100 * ($RowsProcessed+1) / $MaxRows)
_DisplayInfo("Done!" & @CRLF)
$ReconstructDone=True
Return
EndFunc

Func _DecodeRCRD($RCRDRecord, $RCRDOffset, $OffsetAdjustment)
Local $DataPart = 0, $NextOffset = 131, $TotalSizeOfRCRD = StringLen($RCRDRecord)
Global $PredictedRefNumber = ""
Do
	$DataPart+=1
	$SizeOfNextClientData = StringMid($RCRDRecord,$NextOffset+48,8)
	$SizeOfNextClientData = Dec(_SwapEndian($SizeOfNextClientData),2)
	If $SizeOfNextClientData = 0 Then ExitLoop
	$SizeOfNextClientData = $SizeOfNextClientData*2
	$NextClientData = StringMid($RCRDRecord,$NextOffset,96+$SizeOfNextClientData) ; 48 bytes header + data
	If $NextOffset+96+$SizeOfNextClientData >= $TotalSizeOfRCRD Then Return $NextClientData ; We need to return the incomplete record, and attach it to the beginning of the next RCRD and continue processing
	$RecordOffset = $RCRDOffset+(($NextOffset-$OffsetAdjustment-3)/2)
	$RecordOffset = "0x"&Hex(Int($RecordOffset))
	If $VerboseOn Then
		ConsoleWrite(" - - - - - - - - - - - - - - - - - - - - - - - - - - " & @CRLF)
		ConsoleWrite("Record offset: " & $RecordOffset & @CRLF)
;		ConsoleWrite("Part: " & $DataPart & @CRLF)
;		ConsoleWrite(_HexEncode("0x"&$NextClientData) & @CRLF)
	EndIf
	_DecodeLSNRecord($NextClientData)
	$NextOffset+=96+$SizeOfNextClientData
Until $NextOffset >= $TotalSizeOfRCRD
Return ""
EndFunc

Func _DecodeLSNRecord($InputData)
Local $client_undo_next_lsn, $client_data_length, $client_index, $record_type, $flags, $redo_offset, $redo_length, $undo_offset, $target_attribute, $lcns_to_follow, $redo_operation_hex, $undo_operation_hex,$MftClusterIndex, $target_vcn
Local $target_lcn,$DecodeOk=False,$UsnOk=False,$TestAttributeType,$ResolvedAttributeOffset
Global $AttributeString
_ClearVar()
$this_lsn = StringMid($InputData,1,16)
$this_lsn = Dec(_SwapEndian($this_lsn),2)
$client_previous_lsn = StringMid($InputData,17,16)
$client_previous_lsn = Dec(_SwapEndian($client_previous_lsn),2)
$client_undo_next_lsn = StringMid($InputData,33,16)
$client_undo_next_lsn = Dec(_SwapEndian($client_undo_next_lsn),2)
$client_data_length = StringMid($InputData,49,8)
$client_data_length = _SwapEndian($client_data_length)
$client_index = StringMid($InputData,57,8)
$client_index = _SwapEndian($client_index)
$record_type = StringMid($InputData,65,8)
$record_type = _SwapEndian($record_type)
$transaction_id = StringMid($InputData,73,8)
$transaction_id = _SwapEndian($transaction_id)
$flags = StringMid($InputData,81,4)
$flags = _SwapEndian($flags)
;$alignment_or_reserved0 = StringMid($InputData,85,12)
$redo_operation = StringMid($InputData,97,4)
$redo_operation_hex = $redo_operation
$undo_operation = StringMid($InputData,101,4)
$undo_operation_hex = $undo_operation
$redo_operation = _SolveUndoRedoCodes(StringLeft($redo_operation,2))
$undo_operation = _SolveUndoRedoCodes(StringLeft($undo_operation,2))
$redo_offset = StringMid($InputData,105,4)
$redo_offset = Dec(_SwapEndian($redo_offset),2)
$redo_length = StringMid($InputData,109,4)
$redo_length = Dec(_SwapEndian($redo_length),2)
$undo_offset = StringMid($InputData,113,4)
$undo_offset = Dec(_SwapEndian($undo_offset),2)
$undo_length = StringMid($InputData,117,4)
$undo_length = Dec(_SwapEndian($undo_length),2)
$target_attribute = StringMid($InputData,121,4)
$target_attribute = _SwapEndian($target_attribute)
$lcns_to_follow = StringMid($InputData,125,4)
$lcns_to_follow = _SwapEndian($lcns_to_follow)
$record_offset_in_mft = StringMid($InputData,129,4)
$record_offset_in_mft = Dec(_SwapEndian($record_offset_in_mft),2)
$attribute_offset = StringMid($InputData,133,4)
$attribute_offset = Dec(_SwapEndian($attribute_offset),2)
$MftClusterIndex = StringMid($InputData,137,4)
$MftClusterIndex = _SwapEndian($MftClusterIndex)
;$alignment_or_reserved1 = StringMid($InputData,141,4)
$target_vcn = StringMid($InputData,145,8)
$target_vcn = _SwapEndian($target_vcn)
;$alignment_or_reserved2 = StringMid($InputData,153,8)
$target_lcn = StringMid($InputData,161,8)
$target_lcn = _SwapEndian($target_lcn)
;$alignment_or_reserved3 = StringMid($InputData,169,8)
$PredictedRefNumber = ((Dec($target_vcn,2)*$BytesPerCluster)/1024)+((Dec($MftClusterIndex,2)*512)/1024)
;ConsoleWrite("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
;Need to research more on how to calculate correct MFT ref
If ($redo_operation_hex = "0000" And $undo_operation_hex <> "0000") Or $redo_operation_hex = "0200" Or $redo_operation_hex = "0300" Or $redo_operation_hex = "0500" Or $redo_operation_hex = "0600" Or $redo_operation_hex = "0700" Or ($redo_operation_hex = "0800" And $PreviousRedoOp = "1c00") Or $redo_operation_hex = "0900" Or $redo_operation_hex = "0b00" Or $redo_operation_hex = "0c00" Or $redo_operation_hex = "0d00" Or $redo_operation_hex = "1100" Or $redo_operation_hex = "1300" Or $redo_operation_hex = "1c00" Then
	$KeptRefTmp = $PredictedRefNumber
	$KeptRef = $PredictedRefNumber
ElseIf $client_previous_lsn<>0 And ($redo_operation_hex = "0e00" Or $redo_operation_hex = "0f00" Or $redo_operation_hex = "1000" Or $redo_operation_hex = "1200" Or $redo_operation_hex = "1400" Or ($redo_operation_hex = "0800" And ($redo_operation_hex = "0800" Or $PreviousRedoOp = "0b00"))) Then
	$PredictedRefNumber = $KeptRef
;	$KeptRefTmp = $KeptRef
Else
	$PredictedRefNumber = -1 ;Not related to any particular MFT ref
EndIf
;if $redo_operation_hex="1b00" Then
;	MsgBox(0,"lsn: " & $this_lsn,"Ref: " & ((Dec($target_vcn,2)*$BytesPerCluster)/1024)+((Dec($MftClusterIndex,2)*512)/1024))
;	$PredictedRefNumber = ((Dec($target_vcn,2)*$BytesPerCluster)/1024)+((Dec($MftClusterIndex,2)*512)/1024)
;EndIf
#cs
If $redo_operation_hex="1500" or $redo_operation_hex="1600" Then
	$VerboseOn=1
Else
	$VerboseOn=0
EndIf
#ce
#cs
If $this_lsn=1050781 or $this_lsn=1050856 or $this_lsn=1057451 or $this_lsn=1057496  or $this_lsn=1057521 or $this_lsn=1057631 or $this_lsn=1057647 or $this_lsn=1058513 or $this_lsn=1059209 Then
;If $this_lsn=1059209 Then ;56375452416,56375452487,56375452507
	$VerboseOn=1
Else
	$VerboseOn=0
EndIf
#ce
If $VerboseOn Then
;If Dec($client_undo_next_lsn) <> $client_previous_lsn Then
;If $redo_operation_hex="1b00" Then
	ConsoleWrite("Calculated RefNumber: " & ((Dec($target_vcn,2)*$BytesPerCluster)/1024)+((Dec($MftClusterIndex,2)*512)/1024) & @CRLF)
	ConsoleWrite("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
	ConsoleWrite("$KeptRef: " & $KeptRef & @CRLF)
	ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
	ConsoleWrite("$client_previous_lsn: " & $client_previous_lsn & @CRLF)
;	ConsoleWrite("$client_undo_next_lsn: 0x" & $client_undo_next_lsn & @CRLF)
	ConsoleWrite("$client_undo_next_lsn: " & Dec($client_undo_next_lsn,2) & @CRLF)
	ConsoleWrite("$client_data_length: 0x" & $client_data_length & @CRLF)
	ConsoleWrite("$client_index: 0x" & $client_index & @CRLF)
	ConsoleWrite("$record_type: 0x" & $record_type & @CRLF)
	ConsoleWrite("$transaction_id: 0x" & $transaction_id & @CRLF)
	ConsoleWrite("$flags: 0x" & $flags & @CRLF)
	ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
	ConsoleWrite("$redo_operation_hex: 0x" & $redo_operation_hex & @CRLF)
	ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
	ConsoleWrite("$undo_operation_hex: 0x" & $undo_operation_hex & @CRLF)
	ConsoleWrite("$redo_offset: " & $redo_offset & @CRLF)
	ConsoleWrite("$redo_length: " & $redo_length & @CRLF)
	ConsoleWrite("$undo_offset: " & $undo_offset & @CRLF)
	ConsoleWrite("$undo_length: " & $undo_length & @CRLF)
	ConsoleWrite("$target_attribute: 0x" & $target_attribute & @CRLF)
	ConsoleWrite("$lcns_to_follow: 0x" & $lcns_to_follow & @CRLF)
	ConsoleWrite("$record_offset_in_mft: 0x" & Hex($record_offset_in_mft,8) & @CRLF)
	ConsoleWrite("$attribute_offset: 0x" & Hex($attribute_offset,8) & @CRLF)
	ConsoleWrite("$MftClusterIndex: 0x" & $MftClusterIndex & @CRLF)
	ConsoleWrite("$target_vcn: 0x" & $target_vcn & @CRLF)
	ConsoleWrite("$target_lcn: 0x" & $target_lcn & @CRLF)
	ConsoleWrite(@CRLF)
EndIf
;If $undo_operation_hex="0100" And (((Dec($target_vcn,2)*$BytesPerCluster)/1024)+((Dec($MftClusterIndex,2)*512)/1024) <> 0) Then MsgBox(0,"Info","Check CompensationlogRecord")
;ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
If $redo_length > 0 Then
	$redo_chunk = StringMid($InputData,97+($redo_offset*2),$redo_length*2)
	If $VerboseOn Then
		ConsoleWrite("Redo: " & $redo_operation & @CRLF)
		ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
	EndIf
	$RedoChunkSize = StringLen($redo_chunk)/2
	Select
		Case $redo_operation_hex="0200" ;InitializeFileRecordSegment
			_ParserCodeOldVersion($redo_chunk)
		Case $redo_operation_hex="0300" ;DeallocateFileRecordSegment
			_RemoveAllOffsetOfAttribute($PredictedRefNumber)
		Case $redo_operation_hex="0500" ; CreateAttribute
			$TestAttributeType = _Decode_AttributeType($redo_chunk)
			If $TestAttributeType <> '' Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $RedoChunkSize, $TestAttributeType)
			_Decode_CreateAttribute($redo_chunk,1)
;		Case $redo_operation_hex="0600" ; DeleteAttribute
;			$TestAttributeType = _Decode_AttributeType($undo_chunk)
;			If $TestAttributeType <> '' Then _RemoveSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $TestAttributeType)
		Case $redo_operation_hex="0700" ; UpdateResidentValue
			_Decode_UpdateResidentValue($redo_chunk)
			$ResolvedAttributeOffset = _CheckOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft)
			If Not @error Then
;				$AttributeString&= '->('&$ResolvedAttributeOffset&')'
				$AttributeString = $ResolvedAttributeOffset
			EndIf
		Case $redo_operation_hex="0800" ; UpdateNonResidentValue
			If StringLeft($redo_chunk,8) = "494e4458" Then ;INDX
				$TextInformation &= ";INDX"
				If $KeptRefTmp = 24 Then
					$AttributeString = "$INDEX_ALLOCATION($Quota?)"
					$PredictedRefNumber = $KeptRefTmp
					$KeptRef = $KeptRefTmp
				ElseIf $KeptRefTmp = 25 Then
					$AttributeString = "$INDEX_ALLOCATION($ObjId?)"
					$PredictedRefNumber = $KeptRefTmp
					$KeptRef = $KeptRefTmp
				ElseIf $KeptRefTmp = 26 Then
					$AttributeString = "$INDEX_ALLOCATION($Reparse?)"
					$PredictedRefNumber = $KeptRefTmp
					$KeptRef = $KeptRefTmp
				Else
					$DecodeOk=0
					$DecodeOk = _Decode_INDX($redo_chunk)
					If Not $DecodeOk Then
						ConsoleWrite("_Decode_INDX() failed for $this_lsn: " & $this_lsn & @CRLF)
						ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
					Else
						$TextInformation &= ";See LogFile_INDX.csv"
					EndIf
				EndIf
				If $PreviousRedoOp = "1c00" Then
					$AttributeString = $PreviousAttribute
					$PredictedRefNumber = $KeptRef
				EndIf
			Else
				$UsnOk=0
				$UsnOk = _UsnDecodeRecord2($redo_chunk)
				If Not $UsnOk Then
;					If $record_offset_in_mft + Int($redo_length) = 4096 Then
					If $PreviousRedoOp="0b00" Then ; SetNewAttributeSizes
;						MsgBox(0,"Check refs","$PredictedRefNumber: " & $PredictedRefNumber & ", $KeptRef: " & $KeptRef & ", $KeptRefTmp: " & $KeptRefTmp)
						$PredictedRefNumber = $KeptRef
						If Int($undo_length) = 0 And $undo_operation_hex = "0000" And Int($record_offset_in_mft) + Int($redo_length) = 4096 Then
							$TextInformation &= ";$UsnJrnl;Filling of zeros to page boundary"
							$AttributeString = "$DATA:$J"
						ElseIf Int($undo_length) > 0 And $undo_operation_hex="0800" Then
							$TextInformation &= ";$Secure"
							ConsoleWrite("_UsnDecodeRecord2() unresolved $Secure: " & $this_lsn & @CRLF)
							ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
						Else
							ConsoleWrite("_UsnDecodeRecord2() failed and probably not Filling of zeros to page boundary for $this_lsn: " & $this_lsn & @CRLF)
							ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
						EndIf
					Else
						ConsoleWrite("_UsnDecodeRecord2() failed and $PreviousRedoOp <> 0b00 for $this_lsn: " & $this_lsn & @CRLF)
						ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
					EndIf
;					ConsoleWrite("_UsnDecodeRecord2() failed for $this_lsn: " & $this_lsn & @CRLF)
;					ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
				Else
					$TextInformation &= ";$UsnJrnl"
				EndIf
			EndIf
		Case $redo_operation_hex="0900" ; UpdateMappingPairs
			_Decode_UpdateMappingPairs($redo_chunk)
			$AttributeString = "$DATA"
			$ResolvedAttributeOffset = _CheckOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft)
			If Not @error Then
;				$AttributeString&= '->('&$ResolvedAttributeOffset&')'
				$AttributeString = $ResolvedAttributeOffset
			EndIf
		Case $redo_operation_hex="0b00" ; SetNewAttributeSizes
			_Decode_SetNewAttributeSize($redo_chunk)
			If ($RealMftRef = $UsnJrnlRef) And ($UsnJrnlRef <> "") Then
				$AttributeString = "$DATA" ;$UsnJrnl
				$TextInformation &= ";$UsnJrnl"
			ElseIf $record_offset_in_mft > 56 Then
				$AttributeString = "??"
				$ResolvedAttributeOffset = _CheckOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft)
				If Not @error Then
;					$AttributeString&= '->('&$ResolvedAttributeOffset&')'
					$AttributeString = $ResolvedAttributeOffset
				EndIf
			EndIf
		Case $redo_operation_hex="0c00" Or $redo_operation_hex="0d00" Or $redo_operation_hex="0e00" Or $redo_operation_hex="0f00" ;AddindexEntryRoot,DeleteindexEntryRoot,AddIndexEntryAllocation,DeleteIndexEntryAllocation
;			if $redo_operation_hex="0f00" Then ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
			If $redo_length*2>168 Then
				$DecodeOk=0
				$DecodeOk = _Decode_IndexEntry($redo_chunk,$redo_operation_hex,1)
				If Not $DecodeOk Then
					If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
					ConsoleWrite("_Decode_IndexEntry() failed for $this_lsn: " & $this_lsn & @CRLF)
					ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
				Else
					If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($RealMftRef, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
				EndIf
			Else
;				if $PredictedRefNumber = 9 Then $AttributeString = "$INDEX_ALLOCATION"
				If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
				ConsoleWrite("Unresolved: " & $redo_operation & @CRLF)
				ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
				ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
			EndIf
			If $PreviousRedoOp = "1c00" Then $AttributeString = $PreviousAttribute
		Case $redo_operation_hex="1000" ; ResetAllocation
			$AttributeString = "$INDEX_ALLOCATION"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
			$AttributeString = "$INDEX_ALLOCATION"
		Case $redo_operation_hex="1100" ; ResetRoot
			$AttributeString = "$INDEX_ROOT"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1200" ; SetIndexEntryVcnAllocation
			_Decode_SetIndexEntryVcnAllocation($redo_chunk)
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1300" ; UpdateFileNameRoot
			_Decode_FileName($redo_chunk)
			If $PreviousRedoOp = "1c00" Then
				$AttributeString = $PreviousAttribute
			Else
				$AttributeString = "$INDEX_ROOT"
				$RealMftRef = "Parent"
			EndIf
		Case $redo_operation_hex="1400" ; UpdateFileNameAllocation
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
			If $KeptRefTmp > 0 And $client_previous_lsn = 0 Then
				$PredictedRefNumber = $KeptRefTmp
				$KeptRef = $KeptRefTmp
			EndIf
			_Decode_FileName($redo_chunk)
			If $PreviousRedoOp = "1c00" Then
				$AttributeString = $PreviousAttribute
			Else
				$AttributeString = "$INDEX_ALLOCATION"
				$RealMftRef = "Parent"
			EndIf
		Case $redo_operation_hex="1500" ;SetBitsInNonresidentBitMap
;			_Decode_SetBitsInNonresidentBitMap($redo_chunk,"")
		Case $redo_operation_hex="1600"  ;ClearBitsInNonresidentBitMap
;			_Decode_ClearBitsInNonresidentBitMap($redo_chunk,"")
		Case $redo_operation_hex="1c00" ; OpenNonresidentAttribute
			_Decode_OpenNonresidentAttribute($redo_chunk)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1D00"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1E00"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1F00"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="2000"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation = "UNKNOWN"
			$TextInformation &= ";RedoOperation="&$redo_operation_hex
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case Else
;			ConsoleWrite("Missed transaction!" & @CRLF)
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
	EndSelect
;	if $redo_operation_hex="0b00" And StringLen($redo_chunk) > 50 Then
;	if $redo_operation_hex="1200" Then
;		ConsoleWrite("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
;		ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;		ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;		ConsoleWrite("$target_attribute: 0x" & $target_attribute & @CRLF)
;		ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
;	EndIf
Else
	$RedoChunkSize = 0
EndIf
;If $redo_operation_hex="0c00" Then MsgBox(0,"Info","Check record")
;If $this_lsn=1067203  Then MsgBox(0,"Info","Check record")
;#cs
;ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
If $undo_length > 0 Then ; Not needed I guess
	$undo_chunk = StringMid($InputData,97+($undo_offset*2),$undo_length*2)
	If $VerboseOn Then
		ConsoleWrite("Undo: " & $undo_operation & @CRLF)
		ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)

	endif
	$UndoChunkSize = StringLen($undo_chunk)/2
;	If $this_lsn=100676915  Then ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
	Select
		Case $undo_operation_hex="0000" ; NoOp
			If Int($undo_offset)+Int($undo_length) > StringLen($InputData) Then
;				MsgBox(0,"Error","$undo_offset > StringLen($InputData) for LSN: " & $this_lsn)
			Else
				_Decode_AttributeName($undo_chunk)
			EndIf
		Case $undo_operation_hex="0200" ;InitializeFileRecordSegment
;			_ParserCodeOldVersion($undo_chunk)
		Case $undo_operation_hex="0500" ; CreateAttribute
			$TestAttributeType = _Decode_AttributeType($undo_chunk)
			If $TestAttributeType <> '' Then _RemoveSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $UndoChunkSize, $TestAttributeType)
			_Decode_CreateAttribute($undo_chunk,0)
		Case $undo_operation_hex="0700" ; UpdateResidentValue
;			_Decode_UpdateResidentValue($undo_chunk)
		Case $undo_operation_hex="0900"
;			_Decode_UpdateMappingPairs($undo_chunk)
		Case $undo_operation_hex="0800" ; UpdateNonResidentValue
;			If StringLeft($undo_chunk,8) = "494e4458" Then _Decode_INDX($undo_chunk)
		Case $undo_operation_hex="0b00"
;			_Decode_SetNewAttributeSize($undo_chunk)
		Case $undo_operation_hex="0c00" Or $undo_operation_hex="0e00"
			If $undo_length*2>168 Then
				_Decode_IndexEntry($undo_chunk,$undo_operation_hex,0)
			Else
				ConsoleWrite("Unresolved: " & $undo_operation & @CRLF)
				ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
				ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
			EndIf
		Case $undo_operation_hex="1000" ; ClearIndex
			If $undo_length*2>168 Then
				$DecodeOk=0
				$DecodeOk = _Decode_UndoWipeINDX($undo_chunk)
				If Not $DecodeOk Then
					ConsoleWrite("_Decode_UndoWipeINDX() failed for $this_lsn: " & $this_lsn & @CRLF)
					ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
				Else
					$TextInformation &= ";INDX"
				EndIf
			Else
;				if $PredictedRefNumber = 9 Then $AttributeString = "$INDEX_ALLOCATION"
				ConsoleWrite("Unresolved: " & $undo_operation & @CRLF)
				ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
				ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
				MsgBox(0,"Info","Check output of this transaction")
			EndIf
		Case $undo_operation_hex="1100"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1200" ; SetIndexEntryVcnAllocation
		Case $undo_operation_hex="1300" ; UpdateFileNameRoot
;			_Decode_FileName($undo_chunk)
		Case $undo_operation_hex="1400" ; UpdateFileNameAllocation
;			_Decode_FileName($undo_chunk)
		Case $undo_operation_hex="1500" ; SetBitsInNonresidentBitMap
;			_Decode_SetBitsInNonresidentBitMap($undo_chunk,";")
		Case $undo_operation_hex="1600" ; ClearBitsInNonresidentBitMap
;			_Decode_ClearBitsInNonresidentBitMap($undo_chunk,";")
		Case $undo_operation_hex="1D00"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1E00"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1F00"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation = "UNKNOWN"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case Else
;			ConsoleWrite("Missed transaction!" & @CRLF)
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
	EndSelect
Else
	$UndoChunkSize = 0
EndIf
If $VerboseOn Then
	_ArrayDisplay($AttrArray,"$AttrArray")
	MsgBox(0,"Info","Read output")
EndIf
If $SI_USN = $PreviousUsn And $SI_USN <> "" Then
;	MsgBox(0,"Usn:","$PreviousUsn: " & $PreviousUsn & ", $PreviousUsnFileName: " & $PreviousUsnFileName)
	$FN_Name = $PreviousUsnFileName
EndIf
If $client_previous_lsn=0 Then
	$PreviousRealRef=""
EndIf
If $undo_operation = "UNKNOWN" Then $TextInformation &= ";UndoOperation="&$undo_operation_hex
;If $undo_operation_hex="0f00" Then MsgBox(0,"Info","Check record")
;If $redo_operation_hex="0c00" Then MsgBox(0,"Info","Check record")
;#ce
$PreviousRedoOp = $redo_operation_hex
$PreviousAttribute = $AttributeString
If $UsnOk Then
	$PreviousUsn = $UsnJrnlUsn
	$PreviousUsnFileName = $UsnJrnlFileName
	$PreviousUsnReason = $UsnJrnlReason
EndIf
_SetNameOnSystemFiles()
_WriteLogFileCsv()
If $DoSplitCsv Then _WriteCSVExtra()
EndFunc

Func _DecodeRSTR($RSTRRecord)
Local $Startpos=3
$RSTRRecord = _DoFixup($RSTRRecord)
If $RSTRRecord = "" then Return ""  ;corrupt, failed fixup
$usa_ofs = StringMid($RSTRRecord,$Startpos+8,4)              ; 2 bytes
$usa_count = StringMid($RSTRRecord,$Startpos+12,4)           ; 2 bytes
$chkdsk_lsn = StringMid($RSTRRecord,$Startpos+16,16)         ; 8 bytes
$chkdsk_lsn = _SwapEndian($chkdsk_lsn)
$system_page_size = StringMid($RSTRRecord,$Startpos+32,8)    ; 4 bytes
$system_page_size = _SwapEndian($system_page_size)
$log_page_size = StringMid($RSTRRecord,$Startpos+40,8)       ; 4 bytes
$log_page_size = _SwapEndian($log_page_size)
$restart_area_offset = StringMid($RSTRRecord,$Startpos+48,4) ; 2 bytes
$minor_ver = StringMid($RSTRRecord,$Startpos+52,4)           ; 2 bytes
$major_ver = StringMid($RSTRRecord,$Startpos+56,4)           ; 2 bytes
If $VerboseOn Then
;	ConsoleWrite("$usa_ofs: " & $usa_ofs & @CRLF)
;	ConsoleWrite("$usa_count: " & $usa_count & @CRLF)
	ConsoleWrite("$chkdsk_lsn: " & Dec($chkdsk_lsn,2) & @CRLF)
	ConsoleWrite("$system_page_size: 0x" & $system_page_size & @CRLF)
	ConsoleWrite("$log_page_size: 0x" & $log_page_size & @CRLF)
;	ConsoleWrite("$restart_area_offset: " & $restart_area_offset & @CRLF)
	ConsoleWrite("$minor_ver: 0x" & _SwapEndian($minor_ver) & @CRLF)
	ConsoleWrite("$major_ver: 0x" & _SwapEndian($major_ver) & @CRLF)
EndIf
; End -> size = 30 bytes
;----------------------------------
$restart_area_offset = $Startpos+(Dec(_SwapEndian($restart_area_offset),2)*2)
; Log file restart area record
$current_lsn = StringMid($RSTRRecord,$restart_area_offset,16)
$current_lsn = _SwapEndian($current_lsn)
$log_clients = StringMid($RSTRRecord,$restart_area_offset+16,4)
$log_clients = _SwapEndian($log_clients)
$client_free_list = StringMid($RSTRRecord,$restart_area_offset+20,4)
$client_free_list = _SwapEndian($client_free_list)
$client_in_use_list = StringMid($RSTRRecord,$restart_area_offset+24,4)
$client_in_use_list = _SwapEndian($client_in_use_list)
$RESTART_AREA_FLAGS = StringMid($RSTRRecord,$restart_area_offset+28,4)
$RESTART_AREA_FLAGS = _SwapEndian($RESTART_AREA_FLAGS)
$seq_number_bits = StringMid($RSTRRecord,$restart_area_offset+32,8)
$seq_number_bits = _SwapEndian($seq_number_bits)
$restart_area_length = StringMid($RSTRRecord,$restart_area_offset+40,4)
$restart_area_length = _SwapEndian($restart_area_length)
$client_array_offset = StringMid($RSTRRecord,$restart_area_offset+44,4)
$client_array_offset = Dec(_SwapEndian($client_array_offset),2)*2
$file_size = StringMid($RSTRRecord,$restart_area_offset+48,16)
$file_size = _SwapEndian($file_size)
$last_lsn_data_length = StringMid($RSTRRecord,$restart_area_offset+64,8)
$last_lsn_data_length = _SwapEndian($last_lsn_data_length)
$log_record_header_length = StringMid($RSTRRecord,$restart_area_offset+72,4)
$log_record_header_length = _SwapEndian($log_record_header_length)
$log_page_data_offset = StringMid($RSTRRecord,$restart_area_offset+76,4)
$log_page_data_offset = _SwapEndian($log_page_data_offset)
$restart_log_open_count = StringMid($RSTRRecord,$restart_area_offset+80,8)
$restart_log_open_count = _SwapEndian($restart_log_open_count)
$reserved = StringMid($RSTRRecord,$restart_area_offset+88,8)
If Dec($file_size,2) <> $InputFileSize Then ConsoleWrite("Error: The size of the $LogFile as specified in RSTR is not the same as the filesize of input" & @CRLF)
If $VerboseOn Then
	ConsoleWrite("-------------------- RSTR: Log file restart area record" & @CRLF)
	ConsoleWrite("$restart_area_offset: " & $restart_area_offset & @CRLF)
	ConsoleWrite("$current_lsn: " & Dec($current_lsn,2) & @CRLF)
	ConsoleWrite("$log_clients: 0x" & $log_clients & @CRLF)
	ConsoleWrite("$client_free_list: 0x" & $client_free_list & @CRLF)
	ConsoleWrite("$client_in_use_list: 0x" & $client_in_use_list & @CRLF)
	ConsoleWrite("$RESTART_AREA_FLAGS: 0x" & $RESTART_AREA_FLAGS & @CRLF)
	ConsoleWrite("$seq_number_bits: 0x" & $seq_number_bits & @CRLF)
	ConsoleWrite("$restart_area_length: 0x" & $restart_area_length & @CRLF)
	ConsoleWrite("$client_array_offset: " & $client_array_offset & @CRLF)
	ConsoleWrite("$file_size: 0x" & $file_size & @CRLF)
	ConsoleWrite("$last_lsn_data_length: 0x" & $last_lsn_data_length & @CRLF)
	ConsoleWrite("$log_record_header_length: 0x" & $log_record_header_length & @CRLF)
	ConsoleWrite("$log_page_data_offset: 0x" & $log_page_data_offset & @CRLF)
	ConsoleWrite("$restart_log_open_count: 0x" & $restart_log_open_count & @CRLF)
;ConsoleWrite("$reserved: " & $reserved & @CRLF)
EndIf
; End RESTART_AREA -> size = 48 bytes
;---------------------------
; Log client record
$ClientRecordOffset = $restart_area_offset+$client_array_offset
$oldest_lsn = StringMid($RSTRRecord,$ClientRecordOffset,16)
$oldest_lsn = _SwapEndian($oldest_lsn)
$client_restart_lsn = StringMid($RSTRRecord,$ClientRecordOffset+16,16)
$client_restart_lsn = _SwapEndian($client_restart_lsn)
$prev_client = StringMid($RSTRRecord,$ClientRecordOffset+32,4)
$prev_client = _SwapEndian($prev_client)
$next_client = StringMid($RSTRRecord,$ClientRecordOffset+36,4)
$next_client = _SwapEndian($next_client)
$seq_number = StringMid($RSTRRecord,$ClientRecordOffset+40,4)
$seq_number = _SwapEndian($seq_number)
$reserved2 = StringMid($RSTRRecord,$ClientRecordOffset+44,12)
$client_name_length = StringMid($RSTRRecord,$ClientRecordOffset+56,8)
$client_name_length = _SwapEndian($client_name_length)
$client_name = StringMid($RSTRRecord,$ClientRecordOffset+64,16)   ; Actually 8 bytes (NTFS in unicode) + 120 bytes of 00's
If $VerboseOn Then
	ConsoleWrite("-------------------- RSTR: Log client record" & @CRLF)
	ConsoleWrite("$ClientRecordOffset: " & $ClientRecordOffset & @CRLF)
	ConsoleWrite("$oldest_lsn: " & Dec($oldest_lsn,2) & @CRLF)
	ConsoleWrite("$client_restart_lsn: " & Dec($client_restart_lsn,2) & @CRLF)
	ConsoleWrite("$prev_client: 0x" & $prev_client & @CRLF)
	ConsoleWrite("$next_client: 0x" & $next_client & @CRLF)
	ConsoleWrite("$seq_number: 0x" & $seq_number & @CRLF)
;	ConsoleWrite("$reserved2: " & $reserved2 & @CRLF)
	ConsoleWrite("$client_name_length (unicode): 0x" & $client_name_length & @CRLF)
	ConsoleWrite("$client_name: " & _UnicodeHexToStr($client_name) & @CRLF)
EndIf
; End -> size = 160 bytes, 32 bytes + name (128)
EndFunc

Func _DoFixup($record)
	$UpdSeqArrOffset = Dec(_SwapEndian(StringMid($record,11,4)))
	$UpdSeqArrSize = Dec(_SwapEndian(StringMid($record,15,4)))
	$UpdSeqArr = StringMid($record,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
	$UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
	$UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
	$UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
	$UpdSeqArrPart3 = StringMid($UpdSeqArr,13,4)
	$UpdSeqArrPart4 = StringMid($UpdSeqArr,17,4)
	$UpdSeqArrPart5 = StringMid($UpdSeqArr,21,4)
	$UpdSeqArrPart6 = StringMid($UpdSeqArr,25,4)
	$UpdSeqArrPart7 = StringMid($UpdSeqArr,29,4)
	$UpdSeqArrPart8 = StringMid($UpdSeqArr,33,4)
	$RecordEnd1 = StringMid($record,1023,4)
	$RecordEnd2 = StringMid($record,2047,4)
	$RecordEnd3 = StringMid($record,3071,4)
	$RecordEnd4 = StringMid($record,4095,4)
	$RecordEnd5 = StringMid($record,5119,4)
	$RecordEnd6 = StringMid($record,6143,4)
	$RecordEnd7 = StringMid($record,7167,4)
	$RecordEnd8 = StringMid($record,8191,4)
	If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2  OR $UpdSeqArrPart0 <> $RecordEnd3 OR $UpdSeqArrPart0 <> $RecordEnd4 OR $UpdSeqArrPart0 <> $RecordEnd5 OR $UpdSeqArrPart0 <> $RecordEnd6 OR $UpdSeqArrPart0 <> $RecordEnd7 OR $UpdSeqArrPart0 <> $RecordEnd8 Then
		ConsoleWrite("Error: Fixup failed at: 0x" & Hex($CurrentFileOffset) & @CRLF)
		Return ""
	EndIf
	$record = StringMid($record,1,1022) & $UpdSeqArrPart1 & StringMid($record,1027,1020) & $UpdSeqArrPart2 & StringMid($record,2051,1020) & $UpdSeqArrPart3 & StringMid($record,3075,1020) & $UpdSeqArrPart4 & StringMid($record,4099,1020) & $UpdSeqArrPart5 & StringMid($record,5123,1020) & $UpdSeqArrPart6 & StringMid($record,6147,1020) & $UpdSeqArrPart7 & StringMid($record,7171,1020) & $UpdSeqArrPart8
	Return $record
EndFunc

Func _SolveUndoRedoCodes($OpCode)
Local $InterpretedCode
Select
	Case $OpCode = "00"
		$InterpretedCode = "Noop"
	Case $OpCode = "01"
		$InterpretedCode = "CompensationlogRecord"
	Case $OpCode = "02"
		$InterpretedCode = "InitializeFileRecordSegment"
	Case $OpCode = "03"
		$InterpretedCode = "DeallocateFileRecordSegment"
	Case $OpCode = "04"
		$InterpretedCode = "WriteEndofFileRecordSegement"
	Case $OpCode = "05"
		$InterpretedCode = "CreateAttribute"
	Case $OpCode = "06"
		$InterpretedCode = "DeleteAttribute"
	Case $OpCode = "07"
		$InterpretedCode = "UpdateResidentValue"
	Case $OpCode = "08"
		$InterpretedCode = "UpdateNonResidentValue"
	Case $OpCode = "09"
		$InterpretedCode = "UpdateMappingPairs"
	Case $OpCode = "0a"
		$InterpretedCode = "DeleteDirtyClusters"
	Case $OpCode = "0b"
		$InterpretedCode = "SetNewAttributeSizes"
	Case $OpCode = "0c"
		$InterpretedCode = "AddindexEntryRoot"
	Case $OpCode = "0d"
		$InterpretedCode = "DeleteindexEntryRoot"
	Case $OpCode = "0e"
		$InterpretedCode = "AddIndexEntryAllocation"
	Case $OpCode = "0f"
		$InterpretedCode = "DeleteIndexEntryAllocation"
	Case $OpCode = "10"
		$InterpretedCode = "ResetAllocation"
	Case $OpCode = "11"
		$InterpretedCode = "ResetRoot"
	Case $OpCode = "12"
		$InterpretedCode = "SetIndexEntryVcnAllocation"
	Case $OpCode = "13"
		$InterpretedCode = "UpdateFileNameRoot"
	Case $OpCode = "14"
		$InterpretedCode = "UpdateFileNameAllocation"
	Case $OpCode = "15"
		$InterpretedCode = "SetBitsInNonresidentBitMap"
	Case $OpCode = "16"
		$InterpretedCode = "ClearBitsInNonresidentBitMap"
	Case $OpCode = "19"
		$InterpretedCode = "PrepareTransaction"
	Case $OpCode = "1a"
		$InterpretedCode = "CommitTransaction"
	Case $OpCode = "1b"
		$InterpretedCode = "ForgetTransaction"
	Case $OpCode = "1c"
		$InterpretedCode = "OpenNonresidentAttribute"
	Case $OpCode = "1d"
		$InterpretedCode = "UNKNOWN_1D"
	Case $OpCode = "1e"
		$InterpretedCode = "UNKNOWN_1E"
	Case $OpCode = "1f"
		$InterpretedCode = "DirtyPageTableDump"
	Case $OpCode = "20"
		$InterpretedCode = "TransactionTableDump"
	Case $OpCode = "21"
		$InterpretedCode = "UpdateRecordDataRoot"
	Case Else
		$InterpretedCode = "UNKNOWN"
;		MsgBox(0,"$OpCode",$OpCode)
EndSelect
Return $InterpretedCode
EndFunc

Func _SetRecordType($RecordType)
;CheckPointRecord = 0x02
;UpdateRecord = 0x01
;CommitRecord =
EndFunc

Func _SwapEndian($iHex)
	Return StringMid(Binary(Dec($iHex,2)),3, StringLen($iHex))
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf
    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")
    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)
    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf
    Return SetError(0, 0, DllStructGetData($tOut, 1))
EndFunc

Func _ParserCodeOldVersion($MFTEntry)
	Local $UpdSeqArrOffset, $HDR_LSN, $HDR_SequenceNo, $HDR_HardLinkCount, $HDR_Flags, $HDR_RecRealSize, $HDR_RecAllocSize, $HDR_BaseRecSeqNo, $HDR_NextAttribID, $HDR_MFTREcordNumber, $NextAttributeOffset, $AttributeType, $AttributeSize, $RecordActive
	Local $AttributeArray[17][2], $TestAttributeString
	$AttributeArray[0][0] = "Attribute name"
	$AttributeArray[0][1] = "Number"
	$AttributeArray[1][0] = "$STANDARD_INFORMATION"
	$AttributeArray[2][0] = "$ATTRIBUTE_LIST"
	$AttributeArray[3][0] = "$FILE_NAME"
	$AttributeArray[4][0] = "$OBJECT_ID"
	$AttributeArray[5][0] = "$SECURITY_DESCRIPTOR"
	$AttributeArray[6][0] = "$VOLUME_NAME"
	$AttributeArray[7][0] = "$VOLUME_INFORMATION"
	$AttributeArray[8][0] = "$DATA"
	$AttributeArray[9][0] = "$INDEX_ROOT"
	$AttributeArray[10][0] = "$INDEX_ALLOCATION"
	$AttributeArray[11][0] = "$BITMAP"
	$AttributeArray[12][0] = "$REPARSE_POINT"
	$AttributeArray[13][0] = "$EA_INFORMATION"
	$AttributeArray[14][0] = "$EA"
	$AttributeArray[15][0] = "$PROPERTY_SET"
	$AttributeArray[16][0] = "$LOGGED_UTILITY_STREAM"
	$UpdSeqArrOffset = StringMid($MFTEntry, 9, 4)
	$UpdSeqArrOffset = Dec(_SwapEndian($UpdSeqArrOffset),2)
	$HDR_LSN = StringMid($MFTEntry, 17, 16)
	$HDR_LSN = Dec(_SwapEndian($HDR_LSN),2)
	$HDR_SequenceNo = StringMid($MFTEntry, 33, 4)
	$HDR_SequenceNo = Dec(_SwapEndian($HDR_SequenceNo),2)
	$HDR_HardLinkCount = StringMid($MFTEntry,37,4)
	$HDR_HardLinkCount = Dec(_SwapEndian($HDR_HardLinkCount),2)
	$HDR_Flags = StringMid($MFTEntry, 45, 4);00=deleted file,01=file,02=deleted folder,03=folder
	Select
		Case $HDR_Flags = '0000'
			$HDR_Flags = 'FILE'
			$RecordActive = 'DELETED'
		Case $HDR_Flags = '0100'
			$HDR_Flags = 'FILE'
			$RecordActive = 'ALLOCATED'
		Case $HDR_Flags = '0200'
			$HDR_Flags = 'FOLDER'
			$RecordActive = 'DELETED'
		Case $HDR_Flags = '0300'
			$HDR_Flags = 'FOLDER'
			$RecordActive = 'ALLOCATED'
		Case $HDR_Flags = '0900'
			$HDR_Flags = 'FILE+INDEX_SECURITY'
			$RecordActive = 'ALLOCATED'
		Case $HDR_Flags = '0D00'
			$HDR_Flags = 'FILE+INDEX_OTHER'
			$RecordActive = 'ALLOCATED'
		Case Else
			$HDR_Flags = 'UNKNOWN'
			$RecordActive = 'UNKNOWN'
	EndSelect
	$HDR_RecRealSize = StringMid($MFTEntry, 49, 8)
	$HDR_RecRealSize = Dec(_SwapEndian($HDR_RecRealSize),2)
	$HDR_RecAllocSize = StringMid($MFTEntry, 57, 8)
	$HDR_RecAllocSize = Dec(_SwapEndian($HDR_RecAllocSize),2)
	$HDR_BaseRecord = StringMid($MFTEntry, 65, 12)
	$HDR_BaseRecord = Dec(_SwapEndian($HDR_BaseRecord),2)
	$HDR_BaseRecSeqNo = StringMid($MFTEntry, 77, 4)
	$HDR_BaseRecSeqNo = Dec(_SwapEndian($HDR_BaseRecSeqNo),2)
	$HDR_NextAttribID = StringMid($MFTEntry, 81, 4)
	$HDR_NextAttribID = "0x"&_SwapEndian($HDR_NextAttribID)
	If $UpdSeqArrOffset = 48 Then
		$HDR_MFTREcordNumber = StringMid($MFTEntry, 89, 8)
		$HDR_MFTREcordNumber = Dec(_SwapEndian($HDR_MFTREcordNumber),2)
		If $HDR_MFTREcordNumber <> $PredictedRefNumber Then MsgBox(0,"Error","Predicted Reference number do not match Reference found in $MFT. Are you sure your SectorsPerCluster configuration is correct?")
	Else
		$HDR_MFTREcordNumber = "NT style"
	EndIf
	If $VerboseOn Then
		ConsoleWrite("------------ MFT record decode --------------" & @CRLF)
		ConsoleWrite("$HDR_LSN: " & $HDR_LSN & @CRLF)
		ConsoleWrite("$HDR_SequenceNo: " & $HDR_SequenceNo & @CRLF)
		ConsoleWrite("$HDR_HardLinkCount: " & $HDR_HardLinkCount & @CRLF)
		ConsoleWrite("$HDR_Flags: " & $HDR_Flags & @CRLF)
		ConsoleWrite("$RecordActive: " & $RecordActive & @CRLF)
		ConsoleWrite("$HDR_RecRealSize: " & $HDR_RecRealSize & @CRLF)
		ConsoleWrite("$HDR_RecAllocSize: " & $HDR_RecAllocSize & @CRLF)
		ConsoleWrite("$HDR_BaseRecord: " & $HDR_BaseRecord & @CRLF)
		ConsoleWrite("$HDR_BaseRecSeqNo: " & $HDR_BaseRecSeqNo & @CRLF)
		ConsoleWrite("$HDR_NextAttribID: " & $HDR_NextAttribID & @CRLF)
		ConsoleWrite("$HDR_MFTREcordNumber: " & $HDR_MFTREcordNumber & @CRLF)
	EndIf
	$NextAttributeOffset = (Dec(StringMid($MFTEntry, 41, 2)) * 2)+1
;	ConsoleWrite("$NextAttributeOffset: " & $NextAttributeOffset & @CRLF)
	$AttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
;	ConsoleWrite("$AttributeType: " & $AttributeType & @CRLF)
	$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
	$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
;	ConsoleWrite("$AttributeSize: " & $AttributeSize & @CRLF)
	$AttributeKnown = 1
	While $AttributeKnown = 1
		$NextAttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
		$AttributeType = $NextAttributeType
		$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
		$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
		Select
			Case $AttributeType = $STANDARD_INFORMATION
				$AttributeKnown = 1
				$AttributeArray[1][1] += 1
				_Get_StandardInformation($MFTEntry, $NextAttributeOffset, $AttributeSize)
				$TestAttributeString &= '$STANDARD_INFORMATION?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $ATTRIBUTE_LIST
				$AttributeKnown = 1
				$AttributeArray[2][1] += 1
				$TestAttributeString &= '$ATTRIBUTE_LIST?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $FILE_NAME
				$AttributeKnown = 1
				$AttributeArray[3][1] += 1
				_Get_FileName($MFTEntry, $NextAttributeOffset, $AttributeSize, $AttributeArray[3][1])
				$TestAttributeString &= '$FILE_NAME?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $OBJECT_ID
				$AttributeKnown = 1
				$AttributeArray[4][1] += 1
				_Get_ObjectID($MFTEntry, $NextAttributeOffset, $AttributeSize)
				$TestAttributeString &= '$OBJECT_ID?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $SECURITY_DESCRIPTOR
				$AttributeKnown = 1
				$AttributeArray[5][1] += 1
				$TestAttributeString &= '$SECURITY_DESCRIPTOR?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $VOLUME_NAME
				$AttributeKnown = 1
				$AttributeArray[6][1] += 1
				_Get_VolumeName($MFTEntry, $NextAttributeOffset, $AttributeSize)
				$TestAttributeString &= '$VOLUME_NAME?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $VOLUME_INFORMATION
				$AttributeKnown = 1
				$AttributeArray[7][1] += 1
				_Get_VolumeInformation($MFTEntry, $NextAttributeOffset, $AttributeSize)
				$TestAttributeString &= '$VOLUME_INFORMATION?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $DATA
				$AttributeKnown = 1
				$AttributeArray[8][1] += 1
				_Get_Data($MFTEntry, $NextAttributeOffset, $AttributeSize, $AttributeArray[8][1])
				$TestAttributeString &= '$DATA?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $INDEX_ROOT
				$AttributeKnown = 1
				$AttributeArray[9][1] += 1
				$CoreIndexRoot = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreIndexRootChunk = $CoreIndexRoot[0]
				$CoreIndexRootName = $CoreIndexRoot[1]
				If $CoreIndexRootName = "$I30" Then _Get_IndexRoot($CoreIndexRootChunk,$AttributeArray[9][1],$CoreIndexRootName)
				$TestAttributeString &= '$INDEX_ROOT?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $INDEX_ALLOCATION
				$AttributeKnown = 1
				$AttributeArray[10][1] += 1
				$TestAttributeString &= '$INDEX_ALLOCATION?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $BITMAP
				$AttributeKnown = 1
				$AttributeArray[11][1] += 1
				$TestAttributeString &= '$BITMAP?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $REPARSE_POINT
				$AttributeKnown = 1
				$AttributeArray[12][1] += 1
				$CoreReparsePoint = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreReparsePointChunk = $CoreReparsePoint[0]
				$CoreReparsePointName = $CoreReparsePoint[1]
				_Get_ReparsePoint($CoreReparsePointChunk,$AttributeArray[12][1],$CoreReparsePointName)
				$TestAttributeString &= '$REPARSE_POINT?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $EA_INFORMATION
				$AttributeKnown = 1
				$AttributeArray[13][1] += 1
				$CoreEaInfo = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreEaInfoChunk = $CoreEaInfo[0]
				$CoreEaInfoName = $CoreEaInfo[1]
				_Get_EaInformation($CoreEaInfoChunk,$AttributeArray[13][1],$CoreEaInfoName)
				$TestAttributeString &= '$EA_INFORMATION?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $EA
				$AttributeKnown = 1
				$AttributeArray[14][1] += 1
				$CoreEa = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreEaChunk = $CoreEa[0]
				$CoreEaName = $CoreEa[1]
				_Get_Ea($CoreEaChunk,$AttributeArray[14][1],$CoreEaName)
				$TestAttributeString &= '$EA?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $PROPERTY_SET
				$AttributeKnown = 1
				$AttributeArray[15][1] += 1
				$TestAttributeString &= '$PROPERTY_SET?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $LOGGED_UTILITY_STREAM
				$AttributeKnown = 1
				$AttributeArray[16][1] += 1
				$CoreLoggedUtilityStream = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreLoggedUtilityStreamChunk = $CoreLoggedUtilityStream[0]
				$CoreLoggedUtilityStreamName = $CoreLoggedUtilityStream[1]
				_Get_LoggedUtilityStream($CoreLoggedUtilityStreamChunk,$AttributeArray[16][1],$CoreLoggedUtilityStreamName)
				$TestAttributeString &= '$LOGGED_UTILITY_STREAM?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
;				ConsoleWrite("No more attributes in this record." & @CRLF)

			Case $AttributeType <> $LOGGED_UTILITY_STREAM And $AttributeType <> $EA And $AttributeType <> $EA_INFORMATION And $AttributeType <> $REPARSE_POINT And $AttributeType <> $BITMAP And $AttributeType <> $INDEX_ALLOCATION And $AttributeType <> $INDEX_ROOT And $AttributeType <> $DATA And $AttributeType <> $VOLUME_INFORMATION And $AttributeType <> $VOLUME_NAME And $AttributeType <> $SECURITY_DESCRIPTOR And $AttributeType <> $OBJECT_ID And $AttributeType <> $FILE_NAME And $AttributeType <> $ATTRIBUTE_LIST And $AttributeType <> $STANDARD_INFORMATION And $AttributeType <> $PROPERTY_SET And $AttributeType <> $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
;				ConsoleWrite("Unknown attribute found in this record." & @CRLF)

		EndSelect

		$NextAttributeOffset = $NextAttributeOffset + ($AttributeSize * 2)
	WEnd
	For $CurrentAttribute = 1 To UBound($AttributeArray)-1
		If $AttributeArray[$CurrentAttribute][1] <> "" Then $AttributeString &= $AttributeArray[$CurrentAttribute][0]&"("&$AttributeArray[$CurrentAttribute][1]&")+"
	Next
	If $AttributeString <> "" Then $AttributeString = StringTrimRight($AttributeString,1)
	_WriteOut_MFTrecord($HDR_MFTREcordNumber, $MFTEntry)
	_UpdateSeveralOffsetOfAttribute($HDR_MFTREcordNumber, $TestAttributeString)
EndFunc

Func _Get_StandardInformation($MFTEntry, $SI_Offset, $SI_Size)
	Local $SI_HEADER_Flags, $SI_CTime_tmp, $SI_ATime_tmp, $SI_MTime_tmp, $SI_RTime_tmp
;	Local $SI_CTime_Core,$SI_CTime_Precision,$SI_ATime_Core,$SI_ATime_Precision,$SI_MTime_Core,$SI_MTime_Precision,$SI_RTime_Core,$SI_RTime_Precision
	$SI_HEADER_Flags = StringMid($MFTEntry, $SI_Offset + 24, 4)
	$SI_HEADER_Flags = _SwapEndian($SI_HEADER_Flags)
	$SI_HEADER_Flags = _AttribHeaderFlags("0x" & $SI_HEADER_Flags)
	;
	$SI_CTime = StringMid($MFTEntry, $SI_Offset + 48, 16)
	$SI_CTime = _SwapEndian($SI_CTime)
	$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
	$SI_CTime = _WinTime_UTCFileTimeFormat(Dec($SI_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_CTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_CTime_Core = StringMid($SI_CTime,1,StringLen($SI_CTime)-4)
		$SI_CTime_Precision = StringRight($SI_CTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
		$SI_CTime_Core = StringMid($SI_CTime,1,StringLen($SI_CTime)-9)
		$SI_CTime_Precision = StringRight($SI_CTime,8)
	Else
		$SI_CTime_Core = $SI_CTime
	EndIf
	;
	$SI_ATime = StringMid($MFTEntry, $SI_Offset + 64, 16)
	$SI_ATime = _SwapEndian($SI_ATime)
	$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
	$SI_ATime = _WinTime_UTCFileTimeFormat(Dec($SI_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_ATime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_ATime_Core = StringMid($SI_ATime,1,StringLen($SI_ATime)-4)
		$SI_ATime_Precision = StringRight($SI_ATime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
		$SI_ATime_Core = StringMid($SI_ATime,1,StringLen($SI_ATime)-9)
		$SI_ATime_Precision = StringRight($SI_ATime,8)
	Else
		$SI_ATime_Core = $SI_ATime
	EndIf
	;
	$SI_MTime = StringMid($MFTEntry, $SI_Offset + 80, 16)
	$SI_MTime = _SwapEndian($SI_MTime)
	$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
	$SI_MTime = _WinTime_UTCFileTimeFormat(Dec($SI_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_MTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_MTime_Core = StringMid($SI_MTime,1,StringLen($SI_MTime)-4)
		$SI_MTime_Precision = StringRight($SI_MTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
		$SI_MTime_Core = StringMid($SI_MTime,1,StringLen($SI_MTime)-9)
		$SI_MTime_Precision = StringRight($SI_MTime,8)
	Else
		$SI_MTime_Core = $SI_MTime
	EndIf
	;
	$SI_RTime = StringMid($MFTEntry, $SI_Offset + 96, 16)
	$SI_RTime = _SwapEndian($SI_RTime)
	$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
	$SI_RTime = _WinTime_UTCFileTimeFormat(Dec($SI_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_RTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_RTime_Core = StringMid($SI_RTime,1,StringLen($SI_RTime)-4)
		$SI_RTime_Precision = StringRight($SI_RTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
		$SI_RTime_Core = StringMid($SI_RTime,1,StringLen($SI_RTime)-9)
		$SI_RTime_Precision = StringRight($SI_RTime,8)
	Else
		$SI_RTime_Core = $SI_RTime
	EndIf
	;
	$SI_FilePermission = StringMid($MFTEntry, $SI_Offset + 112, 8)
	$SI_FilePermission = _SwapEndian($SI_FilePermission)
	$SI_FilePermission = _File_Attributes("0x" & $SI_FilePermission)
	$SI_MaxVersions = StringMid($MFTEntry, $SI_Offset + 120, 8)
	$SI_MaxVersions = Dec(_SwapEndian($SI_MaxVersions),2)
	$SI_VersionNumber = StringMid($MFTEntry, $SI_Offset + 128, 8)
	$SI_VersionNumber = Dec(_SwapEndian($SI_VersionNumber),2)
	$SI_ClassID = StringMid($MFTEntry, $SI_Offset + 136, 8)
	$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
	$SI_OwnerID = StringMid($MFTEntry, $SI_Offset + 144, 8)
	$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
	$SI_SecurityID = StringMid($MFTEntry, $SI_Offset + 152, 8)
	$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
	$SI_QuotaCharged = StringMid($MFTEntry, $SI_Offset + 160, 16)
	$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
	$SI_USN = StringMid($MFTEntry, $SI_Offset + 176, 16)
	$SI_USN = Dec(_SwapEndian($SI_USN),2)
	If $redo_operation="InitializeFileRecordSegment" Then $CurrentTimestamp = $SI_MTime ; $SI_RTime,$SI_MTime
;	If $undo_operation_hex="0200" Then $CurrentTimestamp = $SI_MTime ; $SI_RTime,$SI_MTime ;Not needed
	If $VerboseOn Then
		ConsoleWrite("### $STANDARD_INFORMATION ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$SI_HEADER_Flags: " & $SI_HEADER_Flags & @CRLF)
		ConsoleWrite("$SI_HEADER_Flags: " & $SI_HEADER_Flags & @CRLF)
		ConsoleWrite("$SI_CTime: " & $SI_CTime & @CRLF)
		ConsoleWrite("$SI_ATime: " & $SI_ATime & @CRLF)
		ConsoleWrite("$SI_MTime: " & $SI_MTime & @CRLF)
		ConsoleWrite("$SI_RTime: " & $SI_RTime & @CRLF)
		ConsoleWrite("$SI_FilePermission: " & $SI_FilePermission & @CRLF)
		ConsoleWrite("$SI_MaxVersions: " & $SI_MaxVersions & @CRLF)
		ConsoleWrite("$SI_VersionNumber: " & $SI_VersionNumber & @CRLF)
		ConsoleWrite("$SI_ClassID: " & $SI_ClassID & @CRLF)
		ConsoleWrite("$SI_OwnerID: " & $SI_OwnerID & @CRLF)
		ConsoleWrite("$SI_SecurityID: " & $SI_SecurityID & @CRLF)
		ConsoleWrite("$SI_QuotaCharged: " & $SI_QuotaCharged & @CRLF)
		ConsoleWrite("$SI_USN: " & $SI_USN & @CRLF)
	EndIf
EndFunc   ;==>_Get_StandardInformation

Func _AttribHeaderFlags($AHinput)
	Local $AHoutput = ""
	If BitAND($AHinput, 0x0001) Then $AHoutput &= 'COMPRESSED+'
	If BitAND($AHinput, 0x4000) Then $AHoutput &= 'ENCRYPTED+'
	If BitAND($AHinput, 0x8000) Then $AHoutput &= 'SPARSE+'
	$AHoutput = StringTrimRight($AHoutput, 1)
	Return $AHoutput
EndFunc   ;==>_AttribHeaderFlags

Func _FillZero($inp)
	Local $inplen, $out, $tmp = ""
	$inplen = StringLen($inp)
	For $i = 1 To 4 - $inplen
		$tmp &= "0"
	Next
	$out = $tmp & $inp
	Return $out
EndFunc   ;==>_FillZero

; start: by Ascend4nt -----------------------------
Func _WinTime_GetUTCToLocalFileTimeDelta()
	Local $iUTCFileTime=864000000000		; exactly 24 hours from the origin (although 12 hours would be more appropriate (max variance = 12))
	$iLocalFileTime=_WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If @error Then Return SetError(@error,@extended,-1)
	Return $iLocalFileTime-$iUTCFileTime	; /36000000000 = # hours delta (effectively giving the offset in hours from UTC/GMT)
EndFunc

Func _WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If $iUTCFileTime<0 Then Return SetError(1,0,-1)
	Local $aRet=DllCall($_COMMON_KERNEL32DLL,"bool","FileTimeToLocalFileTime","uint64*",$iUTCFileTime,"uint64*",0)
	If @error Then Return SetError(2,@error,-1)
	If Not $aRet[0] Then Return SetError(3,0,-1)
	Return $aRet[2]
EndFunc

Func _WinTime_UTCFileTimeFormat($iUTCFileTime,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
;~ 	If $iUTCFileTime<0 Then Return SetError(1,0,"")	; checked in below call

	; First convert file time (UTC-based file time) to 'local file time'
	Local $iLocalFileTime=_WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If @error Then Return SetError(@error,@extended,"")
	; Rare occassion: a filetime near the origin (January 1, 1601!!) is used,
	;	causing a negative result (for some timezones). Return as invalid param.
	If $iLocalFileTime<0 Then Return SetError(1,0,"")

	; Then convert file time to a system time array & format & return it
	Local $vReturn=_WinTime_LocalFileTimeFormat($iLocalFileTime,$iFormat,$iPrecision,$bAMPMConversion)
	Return SetError(@error,@extended,$vReturn)
EndFunc

Func _WinTime_LocalFileTimeFormat($iLocalFileTime,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
;~ 	If $iLocalFileTime<0 Then Return SetError(1,0,"")	; checked in below call

	; Convert file time to a system time array & return result
	Local $aSysTime=_WinTime_LocalFileTimeToSystemTime($iLocalFileTime)
	If @error Then Return SetError(@error,@extended,"")

	; Return only the SystemTime array?
	If $iFormat=0 Then Return $aSysTime

	Local $vReturn=_WinTime_FormatTime($aSysTime[0],$aSysTime[1],$aSysTime[2],$aSysTime[3], _
		$aSysTime[4],$aSysTime[5],$aSysTime[6],$aSysTime[7],$iFormat,$iPrecision,$bAMPMConversion)
	Return SetError(@error,@extended,$vReturn)
EndFunc

Func _WinTime_LocalFileTimeToSystemTime($iLocalFileTime)
	Local $aRet,$stSysTime,$aSysTime[8]=[-1,-1,-1,-1,-1,-1,-1,-1]

	; Negative values unacceptable
	If $iLocalFileTime<0 Then Return SetError(1,0,$aSysTime)

	; SYSTEMTIME structure [Year,Month,DayOfWeek,Day,Hour,Min,Sec,Milliseconds]
	$stSysTime=DllStructCreate("ushort[8]")

	$aRet=DllCall($_COMMON_KERNEL32DLL,"bool","FileTimeToSystemTime","uint64*",$iLocalFileTime,"ptr",DllStructGetPtr($stSysTime))
	If @error Then Return SetError(2,@error,$aSysTime)
	If Not $aRet[0] Then Return SetError(3,0,$aSysTime)
	Dim $aSysTime[8]=[DllStructGetData($stSysTime,1,1),DllStructGetData($stSysTime,1,2),DllStructGetData($stSysTime,1,4),DllStructGetData($stSysTime,1,5), _
		DllStructGetData($stSysTime,1,6),DllStructGetData($stSysTime,1,7),DllStructGetData($stSysTime,1,8),DllStructGetData($stSysTime,1,3)]
	Return $aSysTime
EndFunc

Func _WinTime_FormatTime($iYear,$iMonth,$iDay,$iHour,$iMin,$iSec,$iMilSec,$iDayOfWeek,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
	Local Static $_WT_aMonths[12]=["January","February","March","April","May","June","July","August","September","October","November","December"]
	Local Static $_WT_aDays[7]=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

	If Not $iFormat Or $iMonth<1 Or $iMonth>12 Or $iDayOfWeek>6 Then Return SetError(1,0,"")

	; Pad MM,DD,HH,MM,SS,MSMSMSMS as necessary
	Local $sMM=StringRight(0&$iMonth,2),$sDD=StringRight(0&$iDay,2),$sMin=StringRight(0&$iMin,2)
	; $sYY = $iYear	; (no padding)
	;	[technically Year can be 1-x chars - but this is generally used for 4-digit years. And SystemTime only goes up to 30827/30828]
	Local $sHH,$sSS,$sMS,$sAMPM

	; 'Extra precision 1': +SS (Seconds)
	If $iPrecision Then
		$sSS=StringRight(0&$iSec,2)
		; 'Extra precision 2': +MSMSMSMS (Milliseconds)
		If $iPrecision>1 Then
;			$sMS=StringRight('000'&$iMilSec,4)
			$sMS=StringRight('000'&$iMilSec,3);Fixed an erronous 0 in front of the milliseconds
		Else
			$sMS=""
		EndIf
	Else
		$sSS=""
		$sMS=""
	EndIf
	If $bAMPMConversion Then
		If $iHour>11 Then
			$sAMPM=" PM"
			; 12 PM will cause 12-12 to equal 0, so avoid the calculation:
			If $iHour=12 Then
				$sHH="12"
			Else
				$sHH=StringRight(0&($iHour-12),2)
			EndIf
		Else
			$sAMPM=" AM"
			If $iHour Then
				$sHH=StringRight(0&$iHour,2)
			Else
			; 00 military = 12 AM
				$sHH="12"
			EndIf
		EndIf
	Else
		$sAMPM=""
		$sHH=StringRight(0 & $iHour,2)
	EndIf

	Local $sDateTimeStr,$aReturnArray[3]

	; Return an array? [formatted string + "Month" + "DayOfWeek"]
	If BitAND($iFormat,0x10) Then
		$aReturnArray[1]=$_WT_aMonths[$iMonth-1]
		If $iDayOfWeek>=0 Then
			$aReturnArray[2]=$_WT_aDays[$iDayOfWeek]
		Else
			$aReturnArray[2]=""
		EndIf
		; Strip the 'array' bit off (array[1] will now indicate if an array is to be returned)
		$iFormat=BitAND($iFormat,0xF)
	Else
		; Signal to below that the array isn't to be returned
		$aReturnArray[1]=""
	EndIf

	; Prefix with "DayOfWeek "?
	If BitAND($iFormat,8) Then
		If $iDayOfWeek<0 Then Return SetError(1,0,"")	; invalid
		$sDateTimeStr=$_WT_aDays[$iDayOfWeek]&', '
		; Strip the 'DayOfWeek' bit off
		$iFormat=BitAND($iFormat,0x7)
	Else
		$sDateTimeStr=""
	EndIf

	If $iFormat<2 Then
		; Basic String format: YYYYMMDDHHMM[SS[MSMSMSMS[ AM/PM]]]
		$sDateTimeStr&=$iYear&$sMM&$sDD&$sHH&$sMin&$sSS&$sMS&$sAMPM
	Else
		; one of 4 formats which ends with " HH:MM[:SS[:MSMSMSMS[ AM/PM]]]"
		Switch $iFormat
			; /, : Format - MM/DD/YYYY
			Case 2
				$sDateTimeStr&=$sMM&'/'&$sDD&'/'
			; /, : alt. Format - DD/MM/YYYY
			Case 3
				$sDateTimeStr&=$sDD&'/'&$sMM&'/'
			; "Month DD, YYYY" format
			Case 4
				$sDateTimeStr&=$_WT_aMonths[$iMonth-1]&' '&$sDD&', '
			; "DD Month YYYY" format
			Case 5
				$sDateTimeStr&=$sDD&' '&$_WT_aMonths[$iMonth-1]&' '
			Case 6
				$sDateTimeStr&=$iYear&'-'&$sMM&'-'&$sDD
				$iYear=''
			Case Else
				Return SetError(1,0,"")
		EndSwitch
		$sDateTimeStr&=$iYear&' '&$sHH&':'&$sMin
		If $iPrecision Then
			$sDateTimeStr&=':'&$sSS
			If $iPrecision>1 Then $sDateTimeStr&=':'&$sMS
		EndIf
		$sDateTimeStr&=$sAMPM
	EndIf
	If $aReturnArray[1]<>"" Then
		$aReturnArray[0]=$sDateTimeStr
		Return $aReturnArray
	EndIf
	Return $sDateTimeStr
EndFunc
; end: by Ascend4nt ----------------------------

Func _Get_ObjectID($MFTEntry, $OBJECTID_Offset, $OBJECTID_Size)
	Local $GUID_ObjectID, $GUID_BirthVolumeID, $GUID_BirthObjectID, $GUID_BirthDomainID
	$GUID_ObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 48, 32)
	$GUID_ObjectID = StringMid($GUID_ObjectID, 1, 8) & "-" & StringMid($GUID_ObjectID, 9, 4) & "-" & StringMid($GUID_ObjectID, 13, 4) & "-" & StringMid($GUID_ObjectID, 17, 4) & "-" & StringMid($GUID_ObjectID, 21, 12)
	If $OBJECTID_Size - 24 = 32 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = "NOT PRESENT"
		$GUID_BirthDomainID = "NOT PRESENT"
		If $VerboseOn Then
			ConsoleWrite("### $OBJECT_ID ATTRIBUTE ###" & @CRLF)
			ConsoleWrite("$GUID_BirthVolumeID: " & $GUID_BirthVolumeID & @CRLF)
			ConsoleWrite("$GUID_BirthObjectID: " & $GUID_BirthObjectID & @CRLF)
			ConsoleWrite("$GUID_BirthDomainID: " & $GUID_BirthDomainID & @CRLF)
		EndIf
		$TextInformation &= ";GUID_BirthVolumeID="&$GUID_BirthVolumeID
		Return
	EndIf
	If $OBJECTID_Size - 24 = 48 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 112, 32)
		$GUID_BirthObjectID = StringMid($GUID_BirthObjectID, 1, 8) & "-" & StringMid($GUID_BirthObjectID, 9, 4) & "-" & StringMid($GUID_BirthObjectID, 13, 4) & "-" & StringMid($GUID_BirthObjectID, 17, 4) & "-" & StringMid($GUID_BirthObjectID, 21, 12)
		$GUID_BirthDomainID = "NOT PRESENT"
		If $VerboseOn Then
			ConsoleWrite("### $OBJECT_ID ATTRIBUTE ###" & @CRLF)
			ConsoleWrite("$GUID_BirthVolumeID: " & $GUID_BirthVolumeID & @CRLF)
			ConsoleWrite("$GUID_BirthObjectID: " & $GUID_BirthObjectID & @CRLF)
			ConsoleWrite("$GUID_BirthDomainID: " & $GUID_BirthDomainID & @CRLF)
		EndIf
		$TextInformation &= ";GUID_BirthVolumeID="&$GUID_BirthVolumeID&";GUID_BirthObjectID="&$GUID_BirthObjectID
		Return
	EndIf
	If $OBJECTID_Size - 24 = 64 Then
		$GUID_BirthVolumeID = StringMid($MFTEntry, $OBJECTID_Offset + 80, 32)
		$GUID_BirthVolumeID = StringMid($GUID_BirthVolumeID, 1, 8) & "-" & StringMid($GUID_BirthVolumeID, 9, 4) & "-" & StringMid($GUID_BirthVolumeID, 13, 4) & "-" & StringMid($GUID_BirthVolumeID, 17, 4) & "-" & StringMid($GUID_BirthVolumeID, 21, 12)
		$GUID_BirthObjectID = StringMid($MFTEntry, $OBJECTID_Offset + 112, 32)
		$GUID_BirthObjectID = StringMid($GUID_BirthObjectID, 1, 8) & "-" & StringMid($GUID_BirthObjectID, 9, 4) & "-" & StringMid($GUID_BirthObjectID, 13, 4) & "-" & StringMid($GUID_BirthObjectID, 17, 4) & "-" & StringMid($GUID_BirthObjectID, 21, 12)
		$GUID_BirthDomainID = StringMid($MFTEntry, $OBJECTID_Offset + 144, 32)
		$GUID_BirthDomainID = StringMid($GUID_BirthDomainID, 1, 8) & "-" & StringMid($GUID_BirthDomainID, 9, 4) & "-" & StringMid($GUID_BirthDomainID, 13, 4) & "-" & StringMid($GUID_BirthDomainID, 17, 4) & "-" & StringMid($GUID_BirthDomainID, 21, 12)
		If $VerboseOn Then
			ConsoleWrite("### $OBJECT_ID ATTRIBUTE ###" & @CRLF)
			ConsoleWrite("$GUID_BirthVolumeID: " & $GUID_BirthVolumeID & @CRLF)
			ConsoleWrite("$GUID_BirthObjectID: " & $GUID_BirthObjectID & @CRLF)
			ConsoleWrite("$GUID_BirthDomainID: " & $GUID_BirthDomainID & @CRLF)
		EndIf
		$TextInformation &= ";GUID_BirthVolumeID="&$GUID_BirthVolumeID&";GUID_BirthObjectID="&$GUID_BirthObjectID&";GUID_BirthDomainID="&$GUID_BirthDomainID
		Return
	EndIf
	$GUID_BirthVolumeID = "NOT PRESENT"
	$GUID_BirthObjectID = "NOT PRESENT"
	$GUID_BirthDomainID = "NOT PRESENT"
	If $VerboseOn Then
		ConsoleWrite("### $OBJECT_ID ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID: " & $GUID_BirthVolumeID & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID: " & $GUID_BirthObjectID & @CRLF)
		ConsoleWrite("$GUID_BirthDomainID: " & $GUID_BirthDomainID & @CRLF)
	EndIf
	$TextInformation &= ";ObjectID=EMPTY"
	Return
EndFunc   ;==>_Get_ObjectID

Func _Get_VolumeName($MFTEntry, $VOLUME_NAME_Offset, $VOLUME_NAME_Size)
	Local $VOLUME_NAME_NAME
	ConsoleWrite("### $VOLUME_NAME ATTRIBUTE ###" & @CRLF)
	If $VOLUME_NAME_Size - 24 > 0 Then
		$VOLUME_NAME_NAME = StringMid($MFTEntry, $VOLUME_NAME_Offset + 48, ($VOLUME_NAME_Size - 24) * 2)
		$VOLUME_NAME_NAME = _UnicodeHexToStr($VOLUME_NAME_NAME)
		$TextInformation &= ";VOLUME_NAME="&$VOLUME_NAME_NAME
		Return
	EndIf
	$VOLUME_NAME_NAME = "EMPTY"
	$TextInformation &= ";VOLUME_NAME="&$VOLUME_NAME_NAME
	ConsoleWrite("$VOLUME_NAME_NAME: " & $VOLUME_NAME_NAME & @CRLF)
	Return
EndFunc   ;==>_Get_VolumeName

Func _Get_VolumeInformation($MFTEntry, $VOLUME_INFO_Offset, $VOLUME_INFO_Size)
	Local $VOL_INFO_NTFS_VERSION, $VOL_INFO_FLAGS
	$VOL_INFO_NTFS_VERSION = Dec(StringMid($MFTEntry, $VOLUME_INFO_Offset + 64, 2)) & "," & Dec(StringMid($MFTEntry, $VOLUME_INFO_Offset + 66, 2))
	$VOL_INFO_FLAGS = StringMid($MFTEntry, $VOLUME_INFO_Offset + 68, 4)
	$VOL_INFO_FLAGS = _SwapEndian($VOL_INFO_FLAGS)
	$VOL_INFO_FLAGS = _VolInfoFlag("0x" & $VOL_INFO_FLAGS)
	If $VerboseOn Then
		ConsoleWrite("### $VOLUME_INOFRMATION ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$VOL_INFO_NTFS_VERSION: " & $VOL_INFO_NTFS_VERSION & @CRLF)
		ConsoleWrite("$VOL_INFO_FLAGS: " & $VOL_INFO_FLAGS & @CRLF)
	EndIf
	$TextInformation &= ";VOL_INFO_NTFS_VERSION="&$VOL_INFO_NTFS_VERSION&";VOL_INFO_FLAGS="&$VOL_INFO_FLAGS
	Return
EndFunc   ;==>_Get_VolumeInformation

Func _VolInfoFlag($VIFinput)
	Local $VIFoutput = ""
	If BitAND($VIFinput, 0x0001) Then $VIFoutput &= 'Dirty+'
	If BitAND($VIFinput, 0x0002) Then $VIFoutput &= 'Resize_LogFile+'
	If BitAND($VIFinput, 0x0004) Then $VIFoutput &= 'Upgrade_On_Mount+'
	If BitAND($VIFinput, 0x0008) Then $VIFoutput &= 'Mounted_On_NT4+'
	If BitAND($VIFinput, 0x0010) Then $VIFoutput &= 'Deleted_USN_Underway+'
	If BitAND($VIFinput, 0x0020) Then $VIFoutput &= 'Repair_ObjectIDs+'
	If BitAND($VIFinput, 0x8000) Then $VIFoutput &= 'Modified_By_CHKDSK+'
	$VIFoutput = StringTrimRight($VIFoutput, 1)
	Return $VIFoutput
EndFunc   ;==>_VolInfoFlag

Func _UnicodeHexToStr($FileName)
   $str = ""
   For $i = 1 To StringLen($FileName) Step 4
	  $str &= ChrW(Dec(_SwapEndian(StringMid($FileName, $i, 4))))
   Next
   Return $str
EndFunc

Func _Get_FileName($MFTEntry, $FN_Offset, $FN_Size, $FN_Number)
	Local $FN_ParentSeqNo, $FN_CTime_tmp, $FN_ATime_tmp, $FN_MTime_tmp, $FN_RTime_tmp, $FN_NameLen, $FN_NameSpace
;	Local $FN_CTime_Core,$FN_CTime_Precision,$FN_ATime_Core,$FN_ATime_Precision,$FN_MTime_Core,$FN_MTime_Precision,$FN_RTime_Core,$FN_RTime_Precision
	$FN_ParentRefNo = StringMid($MFTEntry, $FN_Offset + 48, 12)
	$FN_ParentRefNo = Dec(_SwapEndian($FN_ParentRefNo),2)
	$FN_ParentSeqNo = StringMid($MFTEntry, $FN_Offset + 60, 4)
	$FN_ParentSeqNo = Dec(_SwapEndian($FN_ParentSeqNo),2)
	;
	$FN_CTime = StringMid($MFTEntry, $FN_Offset + 64, 16)
	$FN_CTime = _SwapEndian($FN_CTime)
	$FN_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime)
	$FN_CTime = _WinTime_UTCFileTimeFormat(Dec($FN_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$FN_CTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$FN_CTime_Core = StringMid($FN_CTime,1,StringLen($FN_CTime)-4)
		$FN_CTime_Precision = StringRight($FN_CTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$FN_CTime = $FN_CTime & ":" & _FillZero(StringRight($FN_CTime_tmp, 4))
		$FN_CTime_Core = StringMid($FN_CTime,1,StringLen($FN_CTime)-9)
		$FN_CTime_Precision = StringRight($FN_CTime,8)
	Else
		$FN_CTime_Core = $FN_CTime
	EndIf
	;
	$FN_ATime = StringMid($MFTEntry, $FN_Offset + 80, 16)
	$FN_ATime = _SwapEndian($FN_ATime)
	$FN_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime)
	$FN_ATime = _WinTime_UTCFileTimeFormat(Dec($FN_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$FN_ATime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$FN_ATime_Core = StringMid($FN_ATime,1,StringLen($FN_ATime)-4)
		$FN_ATime_Precision = StringRight($FN_ATime,3)
	ElseIf $TimestampPrecision = 3 Then
		$FN_ATime = $FN_ATime & ":" & _FillZero(StringRight($FN_ATime_tmp, 4))
		$FN_ATime_Core = StringMid($FN_ATime,1,StringLen($FN_ATime)-9)
		$FN_ATime_Precision = StringRight($FN_ATime,8)
	Else
		$FN_ATime_Core = $FN_ATime
	EndIf
	;
	$FN_MTime = StringMid($MFTEntry, $FN_Offset + 96, 16)
	$FN_MTime = _SwapEndian($FN_MTime)
	$FN_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime)
	$FN_MTime = _WinTime_UTCFileTimeFormat(Dec($FN_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$FN_MTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$FN_MTime_Core = StringMid($FN_MTime,1,StringLen($FN_MTime)-4)
		$FN_MTime_Precision = StringRight($FN_MTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$FN_MTime = $FN_MTime & ":" & _FillZero(StringRight($FN_MTime_tmp, 4))
		$FN_MTime_Core = StringMid($FN_MTime,1,StringLen($FN_MTime)-9)
		$FN_MTime_Precision = StringRight($FN_MTime,8)
	Else
		$FN_MTime_Core = $FN_MTime
	EndIf
	;
	$FN_RTime = StringMid($MFTEntry, $FN_Offset + 112, 16)
	$FN_RTime = _SwapEndian($FN_RTime)
	$FN_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime)
	$FN_RTime = _WinTime_UTCFileTimeFormat(Dec($FN_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$FN_RTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$FN_RTime_Core = StringMid($FN_RTime,1,StringLen($FN_RTime)-4)
		$FN_RTime_Precision = StringRight($FN_RTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$FN_RTime = $FN_RTime & ":" & _FillZero(StringRight($FN_RTime_tmp, 4))
		$FN_RTime_Core = StringMid($FN_RTime,1,StringLen($FN_RTime)-9)
		$FN_RTime_Precision = StringRight($FN_RTime,8)
	Else
		$FN_RTime_Core = $FN_RTime
	EndIf
	;
	If $redo_operation="InitializeFileRecordSegment" Then $CurrentTimestamp = $FN_MTime ; $FN_RTime,$FN_MTime
	$FN_AllocSize = StringMid($MFTEntry, $FN_Offset + 128, 16)
	$FN_AllocSize = Dec(_SwapEndian($FN_AllocSize),2)
	$FN_RealSize = StringMid($MFTEntry, $FN_Offset + 144, 16)
	$FN_RealSize = Dec(_SwapEndian($FN_RealSize),2)
	$FN_Flags = StringMid($MFTEntry, $FN_Offset + 160, 8)
	$FN_Flags = _SwapEndian($FN_Flags)
	$FN_Flags = _File_Attributes("0x" & $FN_Flags)
	$FN_NameLen = StringMid($MFTEntry, $FN_Offset + 176, 2)
	$FN_NameLen = Dec($FN_NameLen)
	$FN_NameType = StringMid($MFTEntry, $FN_Offset + 178, 2)
	Select
		Case $FN_NameType = '00'
			$FN_NameType = 'POSIX'
		Case $FN_NameType = '01'
			$FN_NameType = 'WIN32'
		Case $FN_NameType = '02'
			$FN_NameType = 'DOS'
		Case $FN_NameType = '03'
			$FN_NameType = 'DOS+WIN32'
		Case $FN_NameType <> '00' And $FN_NameType <> '01' And $FN_NameType <> '02' And $FN_NameType <> '03'
			$FN_NameType = 'UNKNOWN'
	EndSelect
	$FN_NameSpace = $FN_NameLen - 1 ;Not really
	$FN_Name = StringMid($MFTEntry, $FN_Offset + 180, ($FN_NameLen + $FN_NameSpace) * 2)
	$FN_Name = _UnicodeHexToStr($FN_Name)
	$FN_Name = StringReplace($FN_Name,$de,$CharReplacement)
	$FileNameModified = @extended
	If $VerboseOn Then
		ConsoleWrite("### $FILE_NAME ATTRIBUTE " & $FN_Number & " ###" & @CRLF)
		ConsoleWrite("$FN_ParentRefNo: " & $FN_ParentRefNo & @CRLF)
		ConsoleWrite("$FN_ParentSeqNo: " & $FN_ParentSeqNo & @CRLF)
		ConsoleWrite("$FN_CTime: " & $FN_CTime & @CRLF)
		ConsoleWrite("$FN_ATime: " & $FN_ATime & @CRLF)
		ConsoleWrite("$FN_MTime: " & $FN_MTime & @CRLF)
		ConsoleWrite("$FN_RTime: " & $FN_RTime & @CRLF)
		ConsoleWrite("$FN_AllocSize: " & $FN_AllocSize & @CRLF)
		ConsoleWrite("$FN_RealSize: " & $FN_RealSize & @CRLF)
		ConsoleWrite("$FN_Flags: " & $FN_Flags & @CRLF)
		ConsoleWrite("$FN_NameLen: " & $FN_NameLen & @CRLF)
		ConsoleWrite("$FN_NameType: " & $FN_NameType & @CRLF)
		ConsoleWrite("$FN_Name: " & $FN_Name & @CRLF)
	EndIf
EndFunc

Func _Get_Data($MFTEntry, $DT_Offset, $DT_Size, $DT_Number)
	Local $DT_NameLength, $DT_NameRelativeOffset, $DT_VCNs, $DT_LengthOfAttribute, $DT_OffsetToAttribute, $DT_IndexedFlag
	$DT_NonResidentFlag = StringMid($MFTEntry, $DT_Offset + 16, 2)
	$DT_NameLength = Dec(StringMid($MFTEntry, $DT_Offset + 18, 2))
	$DT_NameRelativeOffset = StringMid($MFTEntry, $DT_Offset + 20, 4)
	$DT_NameRelativeOffset = Dec(_SwapEndian($DT_NameRelativeOffset),2)
	$DT_Flags = StringMid($MFTEntry, $DT_Offset + 24, 4)
	$DT_Flags = _SwapEndian($DT_Flags)
	$DT_Flags = _AttribHeaderFlags("0x" & $DT_Flags)
	If $VerboseOn Then
		ConsoleWrite("### $DATA ATTRIBUTE " & $DT_Number & " ###" & @CRLF)
		ConsoleWrite("$DT_Flags: " & $DT_Flags & @CRLF)
		ConsoleWrite("$DT_NonResidentFlag: " & $DT_NonResidentFlag & @CRLF)
		ConsoleWrite("$DT_NameLength: " & $DT_NameLength & @CRLF)
		ConsoleWrite("$DT_NameRelativeOffset: " & $DT_NameRelativeOffset & @CRLF)
		ConsoleWrite("$DT_Flags: " & $DT_Flags & @CRLF)
	EndIf
	If $DT_NameLength > 0 Then
		$DT_NameSpace = $DT_NameLength - 1
		$DT_Name = StringMid($MFTEntry, $DT_Offset + ($DT_NameRelativeOffset * 2), ($DT_NameLength + $DT_NameSpace) * 2)
		$DT_Name = _UnicodeHexToStr($DT_Name)
		$DT_Name = StringReplace($DT_Name,$de,$CharReplacement)
		$FileNameModified = @extended
		If $VerboseOn Then ConsoleWrite("$DT_Name: " & $DT_Name & @CRLF)
	EndIf
	If $DT_NonResidentFlag = '01' Then
		$DT_StartVCN = StringMid($MFTEntry, $DT_Offset + 32, 16)
		$DT_StartVCN = Dec(_SwapEndian($DT_StartVCN),2)
		$DT_LastVCN = StringMid($MFTEntry, $DT_Offset + 48, 16)
		$DT_LastVCN = Dec(_SwapEndian($DT_LastVCN),2)
		$DT_VCNs = $DT_LastVCN - $DT_StartVCN
		$DT_OffsetToDataRuns = StringMid($MFTEntry, $DT_Offset + 64, 4)
		$DT_OffsetToDataRuns = Dec(_SwapEndian($DT_OffsetToDataRuns),2)
		$DT_ComprUnitSize = StringMid($MFTEntry, $DT_Offset + 68, 4)
		$DT_ComprUnitSize = Dec(_SwapEndian($DT_ComprUnitSize),2)
		$DT_AllocSize = StringMid($MFTEntry, $DT_Offset + 80, 16)
		$DT_AllocSize = Dec(_SwapEndian($DT_AllocSize),2)
		$DT_RealSize = StringMid($MFTEntry, $DT_Offset + 96, 16)
		$DT_RealSize = Dec(_SwapEndian($DT_RealSize),2)
		$FileSizeBytes = $DT_RealSize
		$DT_InitStreamSize = StringMid($MFTEntry, $DT_Offset + 112, 16)
		$DT_InitStreamSize = Dec(_SwapEndian($DT_InitStreamSize),2)
		$DT_DataRuns = StringMid($MFTEntry,$DT_Offset+($DT_OffsetToDataRuns*2),(StringLen($MFTEntry)-$DT_OffsetToDataRuns)*2)
		If $VerboseOn Then
			ConsoleWrite("$DT_StartVCN: " & $DT_StartVCN & @CRLF)
			ConsoleWrite("$DT_LastVCN: " & $DT_LastVCN & @CRLF)
			ConsoleWrite("$DT_VCNs: " & $DT_VCNs & @CRLF)
			ConsoleWrite("$DT_OffsetToDataRuns: " & $DT_OffsetToDataRuns & @CRLF)
			ConsoleWrite("$DT_ComprUnitSize: " & $DT_ComprUnitSize & @CRLF)
			ConsoleWrite("$DT_AllocSize: " & $DT_AllocSize & @CRLF)
			ConsoleWrite("$DT_InitStreamSize: " & $DT_InitStreamSize & @CRLF)
			ConsoleWrite("$DT_DataRuns: " & $DT_DataRuns & @CRLF)
		EndIf
	ElseIf $DT_NonResidentFlag = '00' Then
		$DT_LengthOfAttribute = StringMid($MFTEntry, $DT_Offset + 32, 8)
		$DT_LengthOfAttribute = Dec(_SwapEndian($DT_LengthOfAttribute),2)
		$DT_AllocSize = $DT_LengthOfAttribute
		$DT_InitStreamSize = $DT_LengthOfAttribute
		$DT_RealSize = $DT_LengthOfAttribute
		$DT_OffsetToAttribute = StringMid($MFTEntry, $DT_Offset + 40, 4)
		$DT_OffsetToAttribute = Dec(_SwapEndian($DT_OffsetToAttribute),2)
		$DT_IndexedFlag = Dec(StringMid($MFTEntry, $DT_Offset + 44, 2))
		If $VerboseOn Then
			ConsoleWrite("$DT_LengthOfAttribute: " & $DT_LengthOfAttribute & @CRLF)
			ConsoleWrite("$DT_OffsetToAttribute: " & $DT_OffsetToAttribute & @CRLF)
			ConsoleWrite("$DT_IndexedFlag: " & $DT_IndexedFlag & @CRLF)
		EndIf
	EndIf
	_WriteLogFileDataRunsCsv()
EndFunc

Func _Decode_SetNewAttributeSize($input)
	Local $TestVar
	$DT_AllocSize = StringMid($input, 1, 16)
	$DT_AllocSize = Dec(_SwapEndian($DT_AllocSize),2)
	$DT_RealSize = StringMid($input, 17, 16)
	$DT_RealSize = Dec(_SwapEndian($DT_RealSize),2)
	$FileSizeBytes = $DT_RealSize
	$DT_InitStreamSize = StringMid($input, 33, 16)
	$DT_InitStreamSize = Dec(_SwapEndian($DT_InitStreamSize),2)
	If BinaryLen($input)=32 Then
		$DT_Flags = "COMPRESSED/SPARSE?"
;		$TestVar = StringMid($input, 49, 16)
;		$TestVar = Dec(_SwapEndian($TestVar),2)
;		If $TestVar <> 17891328 Then
;		If $TestVar <> "0000110100000000" Then
;			MsgBox(0,"Info","SetNewAttributeSize got an unexpected val")
;		EndIf
	EndIf
	If $VerboseOn Then
		ConsoleWrite("### SetNewAttributeSizes decoder ###" & @CRLF)
		ConsoleWrite("$DT_AllocSize = " & $DT_AllocSize & @crlf)
		ConsoleWrite("$DT_RealSize = " & $DT_RealSize & @crlf)
		ConsoleWrite("$DT_InitStreamSize = " & $DT_InitStreamSize & @crlf)
	EndIf
	_WriteLogFileDataRunsCsv()
EndFunc

Func _Decode_UpdateMappingPairs($input)
	;Tightly related to the setting of new attribute size. Actually these bytes are actual data runs and their relative location is determined by $attribute_offset. If we don't have any record history, this value is likely worthless.
	$DT_DataRuns = StringMid($input, 1)
	_WriteLogFileDataRunsCsv()
EndFunc

Func _Decode_INDX($Entry)
	If $VerboseOn Then ConsoleWrite("### INDX record decoder ###" & @CRLF)
	Local $IndxEntryNumberArr[1],$IndxMFTReferenceArr[1],$IndxMFTRefSeqNoArr[1],$IndxIndexFlagsArr[1],$IndxMFTReferenceOfParentArr[1],$IndxMFTParentRefSeqNoArr[1],$IndxCTimeArr[1],$IndxATimeArr[1],$IndxMTimeArr[1],$IndxRTimeArr[1],$IndxAllocSizeArr[1],$IndxRealSizeArr[1],$IndxFileFlagsArr[1],$IndxFileNameArr[1],$IndxSubNodeVCNArr[1],$IndxNameSpaceArr[1],$IndxFilenameModified[1]
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$EntryCounter=1,$Padding2,$EntryCounter=1,$DecodeOk=False
	Local $Indx_CTime_Core,$Indx_CTime_Precision,$Indx_ATime_Core,$Indx_ATime_Precision,$Indx_MTime_Core,$Indx_MTime_Precision,$Indx_RTime_Core,$Indx_RTime_Precision
	$NewLocalAttributeOffset = 1
	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+56,8)),2)
	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+48,8)),2)
	$NewLocalAttributeOffset = $NewLocalAttributeOffset+48+($IndxHeaderSize*2)
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
	$MFTReference = Dec($MFTReference)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,3,2))
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,3,2))
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,3,2))
	;
	$Indx_CTime = StringMid($Entry, $NewLocalAttributeOffset + 48, 16)
	$Indx_CTime = _SwapEndian($Indx_CTime)
	$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
	$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_CTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-4)
		$Indx_CTime_Precision = StringRight($Indx_CTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp, 4))
		$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-9)
		$Indx_CTime_Precision = StringRight($Indx_CTime,8)
	Else
		$Indx_CTime_Core = $Indx_CTime
	EndIf
	;
	$Indx_ATime = StringMid($Entry, $NewLocalAttributeOffset + 64, 16)
	$Indx_ATime = _SwapEndian($Indx_ATime)
	$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
	$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_ATime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-4)
		$Indx_ATime_Precision = StringRight($Indx_ATime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp, 4))
		$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-9)
		$Indx_ATime_Precision = StringRight($Indx_ATime,8)
	Else
		$Indx_ATime_Core = $Indx_ATime
	EndIf
	;
	$Indx_MTime = StringMid($Entry, $NewLocalAttributeOffset + 80, 16)
	$Indx_MTime = _SwapEndian($Indx_MTime)
	$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
	$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_MTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-4)
		$Indx_MTime_Precision = StringRight($Indx_MTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp, 4))
		$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-9)
		$Indx_MTime_Precision = StringRight($Indx_MTime,8)
	Else
		$Indx_MTime_Core = $Indx_MTime
	EndIf
	;
	$Indx_RTime = StringMid($Entry, $NewLocalAttributeOffset + 96, 16)
	$Indx_RTime = _SwapEndian($Indx_RTime)
	$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
	$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_RTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-4)
		$Indx_RTime_Precision = StringRight($Indx_RTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp, 4))
		$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-9)
		$Indx_RTime_Precision = StringRight($Indx_RTime,8)
	Else
		$Indx_RTime_Core = $Indx_RTime
	EndIf
	;
	$Indx_AllocSize = StringMid($Entry,$NewLocalAttributeOffset+112,16)
	$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,16)
	$Indx_File_Flags = StringMid($Indx_File_Flags,15,2) & StringMid($Indx_File_Flags,13,2) & StringMid($Indx_File_Flags,11,2) & StringMid($Indx_File_Flags,9,2)&StringMid($Indx_File_Flags,7,2) & StringMid($Indx_File_Flags,5,2) & StringMid($Indx_File_Flags,3,2) & StringMid($Indx_File_Flags,1,2)
	$Indx_File_Flags = StringMid($Indx_File_Flags,13,8)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_NameLength = StringMid($Entry,$NewLocalAttributeOffset+160,2)
	$Indx_NameLength = Dec($Indx_NameLength)
	$Indx_NameSpace = StringMid($Entry,$NewLocalAttributeOffset+162,2)
	Select
		Case $Indx_NameSpace = "00"	;POSIX
			$Indx_NameSpace = "POSIX"
		Case $Indx_NameSpace = "01"	;WIN32
			$Indx_NameSpace = "WIN32"
		Case $Indx_NameSpace = "02"	;DOS
			$Indx_NameSpace = "DOS"
		Case $Indx_NameSpace = "03"	;DOS+WIN32
			$Indx_NameSpace = "DOS+WIN32"
	EndSelect
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*2*2)
	$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
	$Indx_FileName = StringReplace($Indx_FileName,$de,$CharReplacement)
	$FileNameModified = @extended
	$tmp1 = 164+($Indx_NameLength*2*2)
	Do ; Calculate the length of the padding - 8 byte aligned
		$tmp2 = $tmp1/16
		If Not IsInt($tmp2) Then
			$tmp0 = 2
			$tmp1 += $tmp0
			$tmp3 += $tmp0
		EndIf
	Until IsInt($tmp2)
	$PaddingLength = $tmp3
;	$Padding2 = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2),$PaddingLength)
	If $IndexFlags <> "0000" Then
		$SubNodeVCN = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
		$SubNodeVCNLength = 16
	Else
		$SubNodeVCN = ""
		$SubNodeVCNLength = 0
	EndIf
	ReDim $IndxEntryNumberArr[1+$EntryCounter]
	ReDim $IndxMFTReferenceArr[1+$EntryCounter]
	ReDim $IndxMFTRefSeqNoArr[1+$EntryCounter]
	ReDim $IndxIndexFlagsArr[1+$EntryCounter]
	ReDim $IndxMFTReferenceOfParentArr[1+$EntryCounter]
	ReDim $IndxMFTParentRefSeqNoArr[1+$EntryCounter]
	ReDim $IndxCTimeArr[1+$EntryCounter]
	ReDim $IndxATimeArr[1+$EntryCounter]
	ReDim $IndxMTimeArr[1+$EntryCounter]
	ReDim $IndxRTimeArr[1+$EntryCounter]
	ReDim $IndxAllocSizeArr[1+$EntryCounter]
	ReDim $IndxRealSizeArr[1+$EntryCounter]
	ReDim $IndxFileFlagsArr[1+$EntryCounter]
	ReDim $IndxFileNameArr[1+$EntryCounter]
	ReDim $IndxNameSpaceArr[1+$EntryCounter]
	ReDim $IndxSubNodeVCNArr[1+$EntryCounter]
	ReDim $IndxFilenameModified[1+$EntryCounter]
	$IndxEntryNumberArr[$EntryCounter] = $EntryCounter
	$IndxMFTReferenceArr[$EntryCounter] = $MFTReference
	$IndxMFTRefSeqNoArr[$EntryCounter] = $MFTReferenceSeqNo
	$IndxIndexFlagsArr[$EntryCounter] = $IndexFlags
	$IndxMFTReferenceOfParentArr[$EntryCounter] = $MFTReferenceOfParent
	$IndxMFTParentRefSeqNoArr[$EntryCounter] = $MFTReferenceOfParentSeqNo
	$IndxCTimeArr[$EntryCounter] = $Indx_CTime
	$IndxATimeArr[$EntryCounter] = $Indx_ATime
	$IndxMTimeArr[$EntryCounter] = $Indx_MTime
	$IndxRTimeArr[$EntryCounter] = $Indx_RTime
	$IndxAllocSizeArr[$EntryCounter] = $Indx_AllocSize
	$IndxRealSizeArr[$EntryCounter] = $Indx_RealSize
	$IndxFileFlagsArr[$EntryCounter] = $Indx_File_Flags
	$IndxFileNameArr[$EntryCounter] = $Indx_FileName
	$IndxNameSpaceArr[$EntryCounter] = $Indx_NameSpace
	$IndxSubNodeVCNArr[$EntryCounter] = $SubNodeVCN
	$IndxFilenameModified[$EntryCounter] = $FileNameModified
;	FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
	If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
		$DecodeOk=True
		FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		$RealMftRef = $PredictedRefNumber
		$PredictedRefNumber = $MFTReferenceOfParent
		$KeptRef = $MFTReferenceOfParent
		$AttributeString = "$INDEX_ALLOCATION"
;		If $PreviousRedoOp = "1c00" Then
;			$AttributeString = $PreviousAttribute
;		Else
;			$AttributeString = "$INDEX_ALLOCATION"
;		EndIf
	EndIf
;	$RealMftRef = $PredictedRefNumber
; Work through the rest of the index entries
	$NextEntryOffset = $NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
	If $NextEntryOffset+64 >= StringLen($Entry) Then Return $DecodeOk
	Do
		$EntryCounter += 1
		$MFTReference = StringMid($Entry,$NextEntryOffset,12)
		$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
		$MFTReference = Dec($MFTReference)
		$MFTReferenceSeqNo = StringMid($Entry,$NextEntryOffset+12,4)
		$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
		$IndexEntryLength = StringMid($Entry,$NextEntryOffset+16,4)
		$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,3,2))
		$OffsetToFileName = StringMid($Entry,$NextEntryOffset+20,4)
		$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,3,2))
		$IndexFlags = StringMid($Entry,$NextEntryOffset+24,4)
		$Padding = StringMid($Entry,$NextEntryOffset+28,4)
		$MFTReferenceOfParent = StringMid($Entry,$NextEntryOffset+32,12)
		$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
		$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
		$MFTReferenceOfParentSeqNo = StringMid($Entry,$NextEntryOffset+44,4)
		$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,3,2))

		$Indx_CTime = StringMid($Entry, $NextEntryOffset + 48, 16)
		$Indx_CTime = _SwapEndian($Indx_CTime)
		$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
		$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_CTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-4)
			$Indx_CTime_Precision = StringRight($Indx_CTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp, 4))
			$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-9)
			$Indx_CTime_Precision = StringRight($Indx_CTime,8)
		Else
			$Indx_CTime_Core = $Indx_CTime
		EndIf
		;
		$Indx_ATime = StringMid($Entry, $NextEntryOffset + 64, 16)
		$Indx_ATime = _SwapEndian($Indx_ATime)
		$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
		$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_ATime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-4)
			$Indx_ATime_Precision = StringRight($Indx_ATime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp, 4))
			$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-9)
			$Indx_ATime_Precision = StringRight($Indx_ATime,8)
		Else
			$Indx_ATime_Core = $Indx_ATime
		EndIf
		;
		$Indx_MTime = StringMid($Entry, $NextEntryOffset + 80, 16)
		$Indx_MTime = _SwapEndian($Indx_MTime)
		$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
		$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_MTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-4)
			$Indx_MTime_Precision = StringRight($Indx_MTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp, 4))
			$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-9)
			$Indx_MTime_Precision = StringRight($Indx_MTime,8)
		Else
			$Indx_MTime_Core = $Indx_MTime
		EndIf
		;
		$Indx_RTime = StringMid($Entry, $NextEntryOffset + 96, 16)
		$Indx_RTime = _SwapEndian($Indx_RTime)
		$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
		$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_RTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-4)
			$Indx_RTime_Precision = StringRight($Indx_RTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp, 4))
			$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-9)
			$Indx_RTime_Precision = StringRight($Indx_RTime,8)
		Else
			$Indx_RTime_Core = $Indx_RTime
		EndIf
		;
		$Indx_AllocSize = StringMid($Entry,$NextEntryOffset+112,16)
		$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
		$Indx_RealSize = StringMid($Entry,$NextEntryOffset+128,16)
		$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
		$Indx_File_Flags = StringMid($Entry,$NextEntryOffset+144,16)
		$Indx_File_Flags = StringMid($Indx_File_Flags,15,2) & StringMid($Indx_File_Flags,13,2) & StringMid($Indx_File_Flags,11,2) & StringMid($Indx_File_Flags,9,2)&StringMid($Indx_File_Flags,7,2) & StringMid($Indx_File_Flags,5,2) & StringMid($Indx_File_Flags,3,2) & StringMid($Indx_File_Flags,1,2)
		$Indx_File_Flags = StringMid($Indx_File_Flags,13,8)
		$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
		$Indx_NameLength = StringMid($Entry,$NextEntryOffset+160,2)
		$Indx_NameLength = Dec($Indx_NameLength)
		$Indx_NameSpace = StringMid($Entry,$NextEntryOffset+162,2)
		Select
			Case $Indx_NameSpace = "00"	;POSIX
				$Indx_NameSpace = "POSIX"
			Case $Indx_NameSpace = "01"	;WIN32
				$Indx_NameSpace = "WIN32"
			Case $Indx_NameSpace = "02"	;DOS
				$Indx_NameSpace = "DOS"
			Case $Indx_NameSpace = "03"	;DOS+WIN32
				$Indx_NameSpace = "DOS+WIN32"
		EndSelect
		$Indx_FileName = StringMid($Entry,$NextEntryOffset+164,$Indx_NameLength*2*2)
		$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
		$Indx_FileName = StringReplace($Indx_FileName,$de,$CharReplacement)
		$FileNameModified = @extended
		$tmp0 = 0
		$tmp2 = 0
		$tmp3 = 0
		$tmp1 = 164+($Indx_NameLength*2*2)
		Do ; Calculate the length of the padding - 8 byte aligned
			$tmp2 = $tmp1/16
			If Not IsInt($tmp2) Then
				$tmp0 = 2
				$tmp1 += $tmp0
				$tmp3 += $tmp0
			EndIf
		Until IsInt($tmp2)
		$PaddingLength = $tmp3
;		$Padding = StringMid($Entry,$NextEntryOffset+164+($Indx_NameLength*2*2),$PaddingLength)
		If $IndexFlags <> "0000" Then
			$SubNodeVCN = StringMid($Entry,$NextEntryOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
			$SubNodeVCNLength = 16
		Else
			$SubNodeVCN = ""
			$SubNodeVCNLength = 0
		EndIf
		$NextEntryOffset = $NextEntryOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
		ReDim $IndxEntryNumberArr[1+$EntryCounter]
		ReDim $IndxMFTReferenceArr[1+$EntryCounter]
		Redim $IndxMFTRefSeqNoArr[1+$EntryCounter]
		ReDim $IndxIndexFlagsArr[1+$EntryCounter]
		ReDim $IndxMFTReferenceOfParentArr[1+$EntryCounter]
		ReDim $IndxMFTParentRefSeqNoArr[1+$EntryCounter]
		ReDim $IndxCTimeArr[1+$EntryCounter]
		ReDim $IndxATimeArr[1+$EntryCounter]
		ReDim $IndxMTimeArr[1+$EntryCounter]
		ReDim $IndxRTimeArr[1+$EntryCounter]
		ReDim $IndxAllocSizeArr[1+$EntryCounter]
		ReDim $IndxRealSizeArr[1+$EntryCounter]
		ReDim $IndxFileFlagsArr[1+$EntryCounter]
		ReDim $IndxFileNameArr[1+$EntryCounter]
		ReDim $IndxNameSpaceArr[1+$EntryCounter]
		ReDim $IndxSubNodeVCNArr[1+$EntryCounter]
		ReDim $IndxFilenameModified[1+$EntryCounter]
		$IndxEntryNumberArr[$EntryCounter] = $EntryCounter
		$IndxMFTReferenceArr[$EntryCounter] = $MFTReference
		$IndxMFTRefSeqNoArr[$EntryCounter] = $MFTReferenceSeqNo
		$IndxIndexFlagsArr[$EntryCounter] = $IndexFlags
		$IndxMFTReferenceOfParentArr[$EntryCounter] = $MFTReferenceOfParent
		$IndxMFTParentRefSeqNoArr[$EntryCounter] = $MFTReferenceOfParentSeqNo
		$IndxCTimeArr[$EntryCounter] = $Indx_CTime
		$IndxATimeArr[$EntryCounter] = $Indx_ATime
		$IndxMTimeArr[$EntryCounter] = $Indx_MTime
		$IndxRTimeArr[$EntryCounter] = $Indx_RTime
		$IndxAllocSizeArr[$EntryCounter] = $Indx_AllocSize
		$IndxRealSizeArr[$EntryCounter] = $Indx_RealSize
		$IndxFileFlagsArr[$EntryCounter] = $Indx_File_Flags
		$IndxFileNameArr[$EntryCounter] = $Indx_FileName
		$IndxNameSpaceArr[$EntryCounter] = $Indx_NameSpace
		$IndxSubNodeVCNArr[$EntryCounter] = $SubNodeVCN
		$IndxFilenameModified[$EntryCounter] = $FileNameModified
;		FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
			$DecodeOk=True
			FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
			$RealMftRef = $PredictedRefNumber
			$PredictedRefNumber = $MFTReferenceOfParent
			$KeptRef = $MFTReferenceOfParent
			$AttributeString = "$INDEX_ALLOCATION"
;			If $PreviousRedoOp = "1c00" Then
;				$AttributeString = $PreviousAttribute
;			Else
;				$AttributeString = "$INDEX_ALLOCATION"
;			EndIf
		EndIf
;		_ArrayDisplay($IndxMFTReferenceOfParentArr,"$IndxMFTReferenceOfParentArr")
	Until $NextEntryOffset+32 >= StringLen($Entry)
;	_ArrayDisplay($IndxMFTReferenceOfParentArr,"$IndxMFTReferenceOfParentArr")
	Return $DecodeOk
EndFunc

Func _Decode_IndexEntry($Entry,$AttrType,$IsRedo)
	If $VerboseOn Then ConsoleWrite("### IndexEntry decoder ###" & @CRLF)
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset;,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
;	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$EntryCounter=1,$Padding2,$EntryCounter=1,$DecodeOk=False
	Local $Indx_CTime_Core,$Indx_CTime_Precision,$Indx_ATime_Core,$Indx_ATime_Precision,$Indx_MTime_Core,$Indx_MTime_Precision,$Indx_RTime_Core,$Indx_RTime_Precision
	$NewLocalAttributeOffset = 1
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
	$MFTReference = Dec($MFTReference)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,3,2))
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,3,2))
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
;	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,3,2))
	;
	$Indx_CTime = StringMid($Entry, $NewLocalAttributeOffset + 48, 16)
	$Indx_CTime = _SwapEndian($Indx_CTime)
	$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
	$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_CTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-4)
		$Indx_CTime_Precision = StringRight($Indx_CTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp, 4))
		$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-9)
		$Indx_CTime_Precision = StringRight($Indx_CTime,8)
	Else
		$Indx_CTime_Core = $Indx_CTime
	EndIf
	;
	$Indx_ATime = StringMid($Entry, $NewLocalAttributeOffset + 64, 16)
	$Indx_ATime = _SwapEndian($Indx_ATime)
	$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
	$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_ATime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-4)
		$Indx_ATime_Precision = StringRight($Indx_ATime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp, 4))
		$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-9)
		$Indx_ATime_Precision = StringRight($Indx_ATime,8)
	Else
		$Indx_ATime_Core = $Indx_ATime
	EndIf
	;
	$Indx_MTime = StringMid($Entry, $NewLocalAttributeOffset + 80, 16)
	$Indx_MTime = _SwapEndian($Indx_MTime)
	$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
	$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_MTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-4)
		$Indx_MTime_Precision = StringRight($Indx_MTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp, 4))
		$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-9)
		$Indx_MTime_Precision = StringRight($Indx_MTime,8)
	Else
		$Indx_MTime_Core = $Indx_MTime
	EndIf
	;
	$Indx_RTime = StringMid($Entry, $NewLocalAttributeOffset + 96, 16)
	$Indx_RTime = _SwapEndian($Indx_RTime)
	$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
	$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_RTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-4)
		$Indx_RTime_Precision = StringRight($Indx_RTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp, 4))
		$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-9)
		$Indx_RTime_Precision = StringRight($Indx_RTime,8)
	Else
		$Indx_RTime_Core = $Indx_RTime
	EndIf
	;
	$Indx_AllocSize = StringMid($Entry,$NewLocalAttributeOffset+112,16)
	$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,16)
	$Indx_File_Flags = StringMid($Indx_File_Flags,15,2) & StringMid($Indx_File_Flags,13,2) & StringMid($Indx_File_Flags,11,2) & StringMid($Indx_File_Flags,9,2)&StringMid($Indx_File_Flags,7,2) & StringMid($Indx_File_Flags,5,2) & StringMid($Indx_File_Flags,3,2) & StringMid($Indx_File_Flags,1,2)
	$Indx_File_Flags = StringMid($Indx_File_Flags,13,8)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_NameLength = StringMid($Entry,$NewLocalAttributeOffset+160,2)
	$Indx_NameLength = Dec($Indx_NameLength)
	$Indx_NameSpace = StringMid($Entry,$NewLocalAttributeOffset+162,2)
	Select
		Case $Indx_NameSpace = "00"	;POSIX
			$Indx_NameSpace = "POSIX"
		Case $Indx_NameSpace = "01"	;WIN32
			$Indx_NameSpace = "WIN32"
		Case $Indx_NameSpace = "02"	;DOS
			$Indx_NameSpace = "DOS"
		Case $Indx_NameSpace = "03"	;DOS+WIN32
			$Indx_NameSpace = "DOS+WIN32"
	EndSelect
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*2*2)
	$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
	$Indx_FileName = StringReplace($Indx_FileName,$de,$CharReplacement)
	$FileNameModified = @extended
	$tmp1 = 164+($Indx_NameLength*2*2)
	Do ; Calculate the length of the padding - 8 byte aligned
		$tmp2 = $tmp1/16
		If Not IsInt($tmp2) Then
			$tmp0 = 2
			$tmp1 += $tmp0
			$tmp3 += $tmp0
		EndIf
	Until IsInt($tmp2)
	$PaddingLength = $tmp3
;	$Padding2 = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2),$PaddingLength)
	If $IndexFlags <> "0000" Then
		$SubNodeVCN = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
		$SubNodeVCNLength = 16
	Else
		$SubNodeVCN = ""
		$SubNodeVCNLength = 0
	EndIf
;FileWriteLine($LogFileCsv, $RecordOffset & $de & $PredictedRefNumber & $de & $RealMftRef & $de & $HDR_BaseRecord & $de & $this_lsn & $de & $client_previous_lsn & $de & $redo_operation & $de & $undo_operation & $de & $record_offset_in_mft & $de &
;$FN_Name & $de & $AttributeString & $de & $UsnJrnlFileName & $de & $FileNameModified & $de & $UsnJrnlFileReferenceNumber & $de & $UsnJrnlParentFileReferenceNumber & $de & $UsnJrnlTimestamp & $de & $UsnJrnlReason & $de & $SI_CTime & $de & $SI_ATime & $de &
;$SI_MTime & $de & $SI_RTime & $de & $SI_FilePermission & $de & $SI_MaxVersions & $de & $SI_VersionNumber & $de & $SI_ClassID & $de & $SI_SecurityID & $de & $SI_QuotaCharged & $de & $SI_USN & $de & $SI_PartialValue & $de & $FN_CTime & $de & $FN_ATime & $de &
;$FN_MTime & $de & $FN_RTime & $de & $FN_AllocSize & $de & $FN_RealSize & $de & $FN_Flags & $de & $DT_StartVCN & $de & $DT_LastVCN & $de & $DT_ComprUnitSize & $de & $DT_AllocSize & $de & $DT_RealSize & $de & $DT_InitStreamSize & $de & $DT_DataRuns & $de &
;$DT_Name & $de & $TextInformation & $de & $RedoChunkSize & $de & $UndoChunkSize & @crlf)
	If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0 And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
		if $IsRedo Then
			FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		EndIf
		$DecodeOk=True
		$RealMftRef = $MFTReferenceOfParent
		$PredictedRefNumber = $MFTReference
		$KeptRef = $MFTReference
		$FN_Name = $Indx_FileName
		$FN_NameType = $Indx_NameSpace
		$SI_CTime = $Indx_CTime
		$SI_ATime = $Indx_ATime
		$SI_MTime = $Indx_MTime
		$SI_RTime = $Indx_RTime
		$FN_AllocSize = $Indx_AllocSize
		$FN_RealSize = $Indx_RealSize
		$FN_Flags = $Indx_File_Flags
;		$TextInformation &= ";MFTReference="&$MFTReference&";FileName="&$Indx_FileName&";FileNameModified="&$FileNameModified
		if $AttrType = "0c00" Or $AttrType = "0d00" Then $AttributeString = "$INDEX_ROOT"
		if $AttrType = "0e00" Or $AttrType = "0f00" Then $AttributeString = "$INDEX_ALLOCATION"
	EndIf
	if $VerboseOn Then
;	if Not $DecodeOk Then
		ConsoleWrite("$MFTReference = " & $MFTReference & @crlf)
		ConsoleWrite("$MFTReferenceSeqNo = " & $MFTReferenceSeqNo & @crlf)
		ConsoleWrite("$IndexEntryLength = " & $IndexEntryLength & @crlf)
		ConsoleWrite("$OffsetToFileName = " & $OffsetToFileName & @crlf)
		ConsoleWrite("$IndexFlags = " & $IndexFlags & @crlf)
		ConsoleWrite("$MFTReferenceOfParent = " & $MFTReferenceOfParent & @crlf)
		ConsoleWrite("$Indx_CTime = " & $Indx_CTime & @crlf)
		ConsoleWrite("$Indx_ATime = " & $Indx_ATime & @crlf)
		ConsoleWrite("$Indx_MTime = " & $Indx_MTime & @crlf)
		ConsoleWrite("$Indx_RTime = " & $Indx_RTime & @crlf)
		ConsoleWrite("$Indx_AllocSize = " & $Indx_AllocSize & @crlf)
		ConsoleWrite("$Indx_RealSize = " & $Indx_RealSize & @crlf)
		ConsoleWrite("$Indx_File_Flags = " & $Indx_File_Flags & @crlf)
		ConsoleWrite("$Indx_NameLength = " & $Indx_NameLength & @crlf)
		ConsoleWrite("$Indx_NameSpace = " & $Indx_NameSpace & @crlf)
		ConsoleWrite("$Indx_FileName = " & $Indx_FileName & @crlf)
		ConsoleWrite("$SubNodeVCN = " & $SubNodeVCN & @crlf)
		ConsoleWrite(@crlf)
	EndIf
	Return $DecodeOk
EndFunc

Func _Get_IndexRoot($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$AttributeType,$CollationRule,$SizeOfIndexAllocationEntry,$ClustersPerIndexRoot,$IRPadding,$DecodeOk=False
	$AttributeType = StringMid($Entry,$LocalAttributeOffset,8)
;	$AttributeType = _SwapEndian($AttributeType)
	$CollationRule = StringMid($Entry,$LocalAttributeOffset+8,8)
	$CollationRule = _SwapEndian($CollationRule)
	$SizeOfIndexAllocationEntry = StringMid($Entry,$LocalAttributeOffset+16,8)
	$SizeOfIndexAllocationEntry = Dec(_SwapEndian($SizeOfIndexAllocationEntry),2)
	$ClustersPerIndexRoot = Dec(StringMid($Entry,$LocalAttributeOffset+24,2))
;	$IRPadding = StringMid($Entry,$LocalAttributeOffset+26,6)
	$OffsetToFirstEntry = StringMid($Entry,$LocalAttributeOffset+32,8)
	$OffsetToFirstEntry = Dec(_SwapEndian($OffsetToFirstEntry),2)
	$TotalSizeOfEntries = StringMid($Entry,$LocalAttributeOffset+40,8)
	$TotalSizeOfEntries = Dec(_SwapEndian($TotalSizeOfEntries),2)
	$AllocatedSizeOfEntries = StringMid($Entry,$LocalAttributeOffset+48,8)
	$AllocatedSizeOfEntries = Dec(_SwapEndian($AllocatedSizeOfEntries),2)
	$Flags = StringMid($Entry,$LocalAttributeOffset+56,2)
	If $Flags = "01" Then
		$Flags = "01 (Index Allocation needed)"
		$ResidentIndx = 0
	Else
		$Flags = "00 (Fits in Index Root)"
		$ResidentIndx = 1
	EndIf
;	$IRPadding2 = StringMid($Entry,$LocalAttributeOffset+58,6)
	if $VerboseOn Then
		ConsoleWrite("### $INDEX_ROOT ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$AttributeType = " & $AttributeType & @crlf)
		ConsoleWrite("$CollationRule = " & $CollationRule & @crlf)
		ConsoleWrite("$SizeOfIndexAllocationEntry = " & $SizeOfIndexAllocationEntry & @crlf)
		ConsoleWrite("$ClustersPerIndexRoot = " & $ClustersPerIndexRoot & @crlf)
;		ConsoleWrite("$IRPadding = " & $IRPadding & @crlf)
		ConsoleWrite("$OffsetToFirstEntry = " & $OffsetToFirstEntry & @crlf)
		ConsoleWrite("$TotalSizeOfEntries = " & $TotalSizeOfEntries & @crlf)
		ConsoleWrite("$AllocatedSizeOfEntries = " & $AllocatedSizeOfEntries & @crlf)
		ConsoleWrite("$Flags = " & $Flags & @crlf)
;		ConsoleWrite("$IRPadding2 = " & $IRPadding2 & @crlf)
	EndIf
	$IRArr[0][$Current_Attrib_Number] = "IndexRoot Number " & $Current_Attrib_Number
	$IRArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$IRArr[2][$Current_Attrib_Number] = $AttributeType
	$IRArr[3][$Current_Attrib_Number] = $CollationRule
	$IRArr[4][$Current_Attrib_Number] = $SizeOfIndexAllocationEntry
	$IRArr[5][$Current_Attrib_Number] = $ClustersPerIndexRoot
;	$IRArr[6][$Current_Attrib_Number] = $IRPadding
	$IRArr[7][$Current_Attrib_Number] = $OffsetToFirstEntry
	$IRArr[8][$Current_Attrib_Number] = $TotalSizeOfEntries
	$IRArr[9][$Current_Attrib_Number] = $AllocatedSizeOfEntries
	$IRArr[10][$Current_Attrib_Number] = $Flags
;	$IRArr[11][$Current_Attrib_Number] = $IRPadding2
;	_ArrayDisplay($IRArr,"$IRArr")
;	If $ResidentIndx And $AttributeType=$FILE_NAME And $CurrentAttributeName="$I30" Then
	If $ResidentIndx And $AttributeType=$FILE_NAME Then
		$TheResidentIndexEntry = StringMid($Entry,$LocalAttributeOffset+64)
		$DecodeOk = _Decode_INDX($TheResidentIndexEntry)
	EndIf
	Return $DecodeOk
EndFunc

Func _GetAttributeEntry($Entry)
	Local $CoreAttribute,$CoreAttributeTmp,$CoreAttributeArr[2]
	Local $ATTRIBUTE_HEADER_LengthOfAttribute,$ATTRIBUTE_HEADER_OffsetToAttribute,$ATTRIBUTE_HEADER_Length, $ATTRIBUTE_HEADER_NonResidentFlag, $ATTRIBUTE_HEADER_NameLength, $ATTRIBUTE_HEADER_NameRelativeOffset, $ATTRIBUTE_HEADER_Name
	$ATTRIBUTE_HEADER_Length = StringMid($Entry,9,8)
	$ATTRIBUTE_HEADER_Length = Dec(_SwapEndian($ATTRIBUTE_HEADER_Length),2)
	$ATTRIBUTE_HEADER_NonResidentFlag = StringMid($Entry,17,2)
	$ATTRIBUTE_HEADER_NameLength = Dec(StringMid($Entry,19,2))
	$ATTRIBUTE_HEADER_NameRelativeOffset = StringMid($Entry,21,4)
	$ATTRIBUTE_HEADER_NameRelativeOffset = Dec(_SwapEndian($ATTRIBUTE_HEADER_NameRelativeOffset))
	If $ATTRIBUTE_HEADER_NameLength > 0 Then
		$ATTRIBUTE_HEADER_Name = _UnicodeHexToStr(StringMid($Entry,$ATTRIBUTE_HEADER_NameRelativeOffset*2 + 1,$ATTRIBUTE_HEADER_NameLength*4))
	Else
		$ATTRIBUTE_HEADER_Name = ""
	EndIf
	If $ATTRIBUTE_HEADER_NonResidentFlag = '00' Then
		$ATTRIBUTE_HEADER_LengthOfAttribute = StringMid($Entry,33,8)
		$ATTRIBUTE_HEADER_LengthOfAttribute = Dec(_SwapEndian($ATTRIBUTE_HEADER_LengthOfAttribute),2)
		$ATTRIBUTE_HEADER_OffsetToAttribute = Dec(_SwapEndian(StringMid($Entry,41,4)))
		$CoreAttribute = StringMid($Entry,$ATTRIBUTE_HEADER_OffsetToAttribute*2+1,$ATTRIBUTE_HEADER_LengthOfAttribute*2)
	Else
		$CoreAttribute = ""
	EndIf
	$CoreAttributeArr[0] = $CoreAttribute
	$CoreAttributeArr[1] = $ATTRIBUTE_HEADER_Name
	If $ATTRIBUTE_HEADER_NameLength > 0 Then $TextInformation &= ";AttributeHeaderName="&$ATTRIBUTE_HEADER_Name
	Return $CoreAttributeArr
EndFunc

Func _Get_ReparsePoint($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$ReparseType,$ReparseDataLength,$ReparsePadding,$ReparseSubstititeNameOffset,$ReparseSubstituteNameLength,$ReparsePrintNameOffset,$ReparsePrintNameLength,$ReparseSubstititeName,$ReparsePrintName
	$ReparseType = StringMid($Entry,$LocalAttributeOffset,8)
	$ReparseType = "0x"& StringMid($ReparseType,7,2) & StringMid($ReparseType,5,2) & StringMid($ReparseType,3,2) & StringMid($ReparseType,1,2)
;http://msdn.microsoft.com/en-us/library/dd541667(v=prot.10).aspx
;http://msdn.microsoft.com/en-us/library/windows/desktop/aa365740(v=vs.85).aspx
	Select
		Case $ReparseType = '0xA000000C'
			$ReparseType = 'SYMLINK'
		Case $ReparseType = '0x8000000B'
			$ReparseType = 'FILTER_MANAGER'
		Case $ReparseType = '0x80000012'
			$ReparseType = 'DFSR'
		Case $ReparseType = '0x8000000A'
			$ReparseType = 'DFS'
		Case $ReparseType = '0x80000007'
			$ReparseType = 'SIS'
		Case $ReparseType = '0x80000005'
			$ReparseType = 'DRIVER_EXTENDER'
		Case $ReparseType = '0x80000006'
			$ReparseType = 'HSM2'
		Case $ReparseType = '0xC0000004'
			$ReparseType = 'HSM'
		Case $ReparseType = '0xA0000003'
			$ReparseType = 'MOUNT_POINT'
		Case $ReparseType = '0x80000009'
			$ReparseType = 'CSV'
		Case $ReparseType = '0x80000013'
			$ReparseType = 'DEDUP'
		Case $ReparseType = '0x80000014'
			$ReparseType = 'NFS'
		Case $ReparseType = '0x80000008'
			$ReparseType = 'WIM'
		Case Else
			$ReparseType = 'UNKNOWN'
	EndSelect
	$ReparseDataLength = StringMid($Entry,$LocalAttributeOffset+8,4)
	$ReparseDataLength = Dec(StringMid($ReparseDataLength,3,2) & StringMid($ReparseDataLength,1,2))
	$ReparsePadding = StringMid($Entry,$LocalAttributeOffset+12,4)
	$ReparseData = StringMid($Entry,$LocalAttributeOffset+16,$ReparseDataLength*2)
	$ReparseSubstititeNameOffset = StringMid($ReparseData,1,4)
	$ReparseSubstititeNameOffset = Dec(StringMid($ReparseSubstititeNameOffset,3,2) & StringMid($ReparseSubstititeNameOffset,1,2))
	$ReparseSubstituteNameLength = StringMid($ReparseData,5,4)
	$ReparseSubstituteNameLength = Dec(StringMid($ReparseSubstituteNameLength,3,2) & StringMid($ReparseSubstituteNameLength,1,2))
	$ReparsePrintNameOffset = StringMid($ReparseData,9,4)
	$ReparsePrintNameOffset = Dec(StringMid($ReparsePrintNameOffset,3,2) & StringMid($ReparsePrintNameOffset,1,2))
	$ReparsePrintNameLength = StringMid($ReparseData,13,4)
	$ReparsePrintNameLength = Dec(StringMid($ReparsePrintNameLength,3,2) & StringMid($ReparsePrintNameLength,1,2))
	$ReparseSubstititeName = StringMid($Entry,$LocalAttributeOffset+16+16,$ReparseSubstituteNameLength*2)
	$ReparseSubstititeName = _UnicodeHexToStr($ReparseSubstititeName)
	$ReparsePrintName = StringMid($Entry,($LocalAttributeOffset+32)+($ReparsePrintNameOffset*2),$ReparsePrintNameLength*2)
	$ReparsePrintName = _UnicodeHexToStr($ReparsePrintName)
	If $VerboseOn Then
		ConsoleWrite("### $REPARSE_POINT ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$ReparseType = " & $ReparseType & @crlf)
		ConsoleWrite("$ReparseDataLength = " & $ReparseDataLength & @crlf)
		ConsoleWrite("$ReparsePadding = " & $ReparsePadding & @crlf)
		ConsoleWrite("$ReparseSubstititeNameOffset = " & $ReparseSubstititeNameOffset & @crlf)
		ConsoleWrite("$ReparseSubstituteNameLength = " & $ReparseSubstituteNameLength & @crlf)
		ConsoleWrite("$ReparsePrintNameOffset = " & $ReparsePrintNameOffset & @crlf)
		ConsoleWrite("$ReparsePrintNameLength = " & $ReparsePrintNameLength & @crlf)
		ConsoleWrite("$ReparseSubstititeName = " & $ReparseSubstititeName & @crlf)
		ConsoleWrite("$ReparsePrintName = " & $ReparsePrintName & @crlf)
	EndIf
	$RPArr[0][$Current_Attrib_Number] = "RP Number " & $Current_Attrib_Number
	$RPArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$RPArr[2][$Current_Attrib_Number] = $ReparseType
	$RPArr[3][$Current_Attrib_Number] = $ReparseDataLength
	$RPArr[4][$Current_Attrib_Number] = $ReparsePadding
	$RPArr[5][$Current_Attrib_Number] = $ReparseSubstititeNameOffset
	$RPArr[6][$Current_Attrib_Number] = $ReparseSubstituteNameLength
	$RPArr[7][$Current_Attrib_Number] = $ReparsePrintNameOffset
	$RPArr[8][$Current_Attrib_Number] = $ReparsePrintNameLength
	$RPArr[9][$Current_Attrib_Number] = $ReparseSubstititeName
	$RPArr[10][$Current_Attrib_Number] = $ReparsePrintName
	$TextInformation &= ";ReparseType="&$ReparseType&";ReparseSubstititeName="&$ReparseSubstititeName&";ReparsePrintName="&$ReparsePrintName
EndFunc

Func _Get_EaInformation($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$TheEaInformation,$SizeOfPackedEas,$NumberOfEaWithFlagSet,$SizeOfUnpackedEas
	$TheEaInformation = StringMid($Entry,$LocalAttributeOffset)
	$SizeOfPackedEas = StringMid($Entry,$LocalAttributeOffset,4)
	$SizeOfPackedEas = Dec(StringMid($SizeOfPackedEas,3,2) & StringMid($SizeOfPackedEas,1,2))
	$NumberOfEaWithFlagSet = StringMid($Entry,$LocalAttributeOffset+4,4)
	$NumberOfEaWithFlagSet = Dec(StringMid($NumberOfEaWithFlagSet,3,2) & StringMid($NumberOfEaWithFlagSet,1,2))
	$SizeOfUnpackedEas = StringMid($Entry,$LocalAttributeOffset+8,8)
	Global $SizeOfUnpackedEas = Dec(StringMid($SizeOfUnpackedEas,7,2) & StringMid($SizeOfUnpackedEas,5,2) & StringMid($SizeOfUnpackedEas,3,2) & StringMid($SizeOfUnpackedEas,1,2))
	If $VerboseOn Then
		ConsoleWrite("### $EA_INFORMATION ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$TheEaInformation = " & $TheEaInformation & @crlf)
		ConsoleWrite("$SizeOfPackedEas = " & $SizeOfPackedEas & @crlf)
		ConsoleWrite("$NumberOfEaWithFlagSet = " & $NumberOfEaWithFlagSet & @crlf)
		ConsoleWrite("$SizeOfUnpackedEas = " & $SizeOfUnpackedEas & @crlf)
	EndIf
	$EAInfoArr[0][$Current_Attrib_Number] = "EA Info Number " & $Current_Attrib_Number
	$EAInfoArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$EAInfoArr[2][$Current_Attrib_Number] = $SizeOfPackedEas
	$EAInfoArr[3][$Current_Attrib_Number] = $NumberOfEaWithFlagSet
	$EAInfoArr[4][$Current_Attrib_Number] = $SizeOfUnpackedEas
	$TextInformation &= ";SizeOfPackedEas="&$SizeOfPackedEas&";NumberOfEaWithFlagSet="&$NumberOfEaWithFlagSet&";SizeOfUnpackedEas="&$SizeOfUnpackedEas
EndFunc

Func _Get_Ea($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$TheEa,$OffsetToNextEa,$EaFlags,$EaNameLength,$EaValueLength,$EaCounter=0
	$TheEa = StringMid($Entry,$LocalAttributeOffset,$SizeOfUnpackedEas*2)
	$OffsetToNextEa = StringMid($Entry,$LocalAttributeOffset,8)
	$OffsetToNextEa = Dec(StringMid($OffsetToNextEa,7,2) & StringMid($OffsetToNextEa,5,2) & StringMid($OffsetToNextEa,3,2) & StringMid($OffsetToNextEa,1,2))
	$EaFlags = StringMid($Entry,$LocalAttributeOffset+8,2)
	$EaNameLength = Dec(StringMid($Entry,$LocalAttributeOffset+10,2))
	$EaValueLength = StringMid($Entry,$LocalAttributeOffset+12,4)
	$EaValueLength = Dec(StringMid($EaValueLength,3,2) & StringMid($EaValueLength,1,2))
	$EaName = StringMid($Entry,$LocalAttributeOffset+16,$EaNameLength*2)
	$EaName = _HexToString($EaName)
	$EaValue = StringMid($Entry,$LocalAttributeOffset+16+($EaNameLength*2),$EaValueLength*2)
	If $VerboseOn Then
		ConsoleWrite("### $EA ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$TheEa = " & $TheEa & @crlf)
		ConsoleWrite(_HexEncode("0x"&$TheEa) & @crlf)
		ConsoleWrite("$OffsetToNextEa = " & $OffsetToNextEa & @crlf)
		ConsoleWrite("$EaFlags = " & $EaFlags & @crlf)
		ConsoleWrite("$EaNameLength = " & $EaNameLength & @crlf)
		ConsoleWrite("$EaValueLength = " & $EaValueLength & @crlf)
		ConsoleWrite("$EaName = " & $EaName & @crlf)
		ConsoleWrite("$EaValue = " & $EaValue & @crlf)
	EndIf
	$EAArr[0][$Current_Attrib_Number] = "EA Number " & $Current_Attrib_Number
	$EAArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$EAArr[2][$Current_Attrib_Number] = $OffsetToNextEa
	$EAArr[3][$Current_Attrib_Number] = $EaFlags
	$EAArr[4][$Current_Attrib_Number] = $EaNameLength
	$EAArr[5][$Current_Attrib_Number] = $EaValueLength
	$EAArr[6][$Current_Attrib_Number] = $EaName
	$EAArr[7][$Current_Attrib_Number] = $EaValue
	$TextInformation &= ";EaName="&$EaName&";EaValue="&$EaValue
	$NextEaOffset = $LocalAttributeOffset+22+($EaNameLength*2)+($EaValueLength*2)
	Do
		$EaCounter += 5
		$NextEaFlag = StringMid($Entry,$NextEaOffset+8,2)
		$NextEaNameLength = Dec(StringMid($Entry,$NextEaOffset+10,2))
		$NextEaValueLength = StringMid($Entry,$NextEaOffset+12,4)
		$NextEaValueLength = Dec(StringMid($NextEaValueLength,3,2) & StringMid($NextEaValueLength,1,2))
		$NextEaName = StringMid($Entry,$NextEaOffset+16,$NextEaNameLength*2)
		$NextEaName = _HexToString($NextEaName)
		$NextEaValue = StringMid($Entry,$NextEaOffset+16+($NextEaNameLength*2),$NextEaValueLength*2)
		If $VerboseOn Then
			ConsoleWrite("$NextEaFlag = " & $NextEaFlag & @crlf)
			ConsoleWrite("$NextEaNameLength = " & $NextEaNameLength & @crlf)
			ConsoleWrite("$NextEaValueLength = " & $NextEaValueLength & @crlf)
			ConsoleWrite("$NextEaName = " & $NextEaName & @crlf)
			ConsoleWrite("$NextEaName = " & $NextEaName & @crlf)
			ConsoleWrite("$NextEaValue = " & $NextEaValue & @crlf)
		EndIf
		$NextEaOffset = $NextEaOffset+22+2+($NextEaNameLength*2)+($NextEaValueLength*2)
		ReDim $EAArr[8+$EaCounter][$Current_Attrib_Number+1]
		Local $Counter1 = 7+($EaCounter-4)
		Local $Counter2 = 7+($EaCounter-3)
		Local $Counter3 = 7+($EaCounter-2)
		Local $Counter4 = 7+($EaCounter-1)
		Local $Counter5 = 7+($EaCounter-0)
		$EAArr[$Counter1][0] = "NextEaFlag"
		$EAArr[$Counter2][0] = "NextEaNameLength"
		$EAArr[$Counter3][0] = "NextEaValueLength"
		$EAArr[$Counter4][0] = "NextEaName"
		$EAArr[$Counter5][0] = "NextEaValue"
		$EAArr[$Counter1][$Current_Attrib_Number] = $NextEaFlag
		$EAArr[$Counter2][$Current_Attrib_Number] = $NextEaNameLength
		$EAArr[$Counter3][$Current_Attrib_Number] = $NextEaValueLength
		$EAArr[$Counter4][$Current_Attrib_Number] = $NextEaName
		$EAArr[$Counter5][$Current_Attrib_Number] = $NextEaValue
		$TextInformation &= ";EaName="&$EaName&";EaValue="&$EaValue
	Until $NextEaOffset >= $SizeOfUnpackedEas*2
;	_ArrayDisplay($EAArr,"$EAArr")
EndFunc

Func _Get_LoggedUtilityStream($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1
	$TheLoggedUtilityStream = StringMid($Entry,$LocalAttributeOffset)
	If $VerboseOn Then
		ConsoleWrite("### $LOGGED_UTILITY_STREAM ATTRIBUTE ###" & @CRLF)
		ConsoleWrite("$TheLoggedUtilityStream = " & $TheLoggedUtilityStream & @crlf)
	EndIf
	$LUSArr[0][$Current_Attrib_Number] = "LoggedUtilityStream Number " & $Current_Attrib_Number
	$LUSArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$LUSArr[2][$Current_Attrib_Number] = $TheLoggedUtilityStream
	$TextInformation &= ";LoggedUtilityStream="&$TheLoggedUtilityStream
EndFunc

Func _Decode_UpdateResidentValue($record)
	If $record_offset_in_mft = 56 Then ;$STANDARD_INFORMATION attribute 0x38
		If $VerboseOn Then ConsoleWrite("########### UpdateResidentValue in $STANDARD_INFORMATION ###########" & @CRLF)
		_Decode_StandardInformation($record)
		$AttributeString = "$STANDARD_INFORMATION"
	Else
		If $client_previous_lsn=0 And $undo_length=0 Then
;			If $PreviousUsnReason<>"" Then
;			If $SI_USN = $PreviousUsn Then $FN_Name = $PreviousUsnFileName
;			If $client_previous_lsn= Then $RealMftRef = $PreviousRealRef
;			EndIf
;			$AttributeString = $PreviousAttribute
			$FN_Name = $PreviousUsnFileName
		Else
;
		EndIf
		;In order to determine the correct attribute, we need to look into MFT and hope its layout or occupying file has not changed since this change occurred
	EndIf
EndFunc

Func _ResolveAttributeFromUsnReason($data)
	Select
		Case StringInStr($data,"DATA")
			$ret = "$DATA"
		Case StringInStr($data,"DATA")
			$ret = "$DATA"
		Case StringInStr($data,"DATA")
			$ret = "$DATA"
		Case Else
			$ret = "Unknown"
	EndSelect
	Return $ret
EndFunc

Func _Decode_CreateAttribute($record,$IsRedo)
	Local $RecordSize,$DecodeOk=False
	Global $CurrentAttribute
	$AttributeTypeCheck = StringMid($record,1,4)
	If $VerboseOn Then
		ConsoleWrite("########### CreateAttribute ###########" & @CRLF)
		ConsoleWrite("$AttributeTypeCheck: " & $AttributeTypeCheck & @CRLF)
	EndIf
	$RecordSize = StringLen($record)
	if $IsRedo Then
		Select
			Case $AttributeTypeCheck = "1000"
				_Get_StandardInformation($record, 1, $RecordSize)
				$AttributeString = "$STANDARD_INFORMATION"
			Case $AttributeTypeCheck = "2000"
				$AttributeString = "$ATTRIBUTE_LIST"
			Case $AttributeTypeCheck = "3000"
				_Get_FileName($record, 1, $RecordSize, 1)
				$AttributeString = "$FILE_NAME"
			Case $AttributeTypeCheck = "4000"
				_Get_ObjectID($record, 1, $RecordSize)
				$AttributeString = "$OBJECT_ID"
			Case $AttributeTypeCheck = "5000"
				$AttributeString = "$SECURITY_DESCRIPTOR"
			Case $AttributeTypeCheck = "6000"
				_Get_VolumeName($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_NAME"
			Case $AttributeTypeCheck = "7000"
				_Get_VolumeInformation($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_INFORMATION"
			Case $AttributeTypeCheck = "8000"
				_Get_Data($record, 1, $RecordSize, 1 )
				$AttributeString = "$DATA"
			Case $AttributeTypeCheck = "9000"
				$CoreIndexRoot = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreIndexRootChunk = $CoreIndexRoot[0]
				$CoreIndexRootName = $CoreIndexRoot[1]
				If $CoreIndexRootName = "$I30" Then $DecodeOk = _Get_IndexRoot($CoreIndexRootChunk,1,$CoreIndexRootName)
				$AttributeString = "$INDEX_ROOT"
			Case $AttributeTypeCheck = "A000"
				$CoreIndexAllocation = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreIndexAllocationChunk = $CoreIndexAllocation[0]
				$CoreIndexAllocationName = $CoreIndexAllocation[1]
				If $CoreIndexAllocationName = "$I30" Then $DecodeOk = _Decode_INDX($CoreIndexAllocationChunk)
				$AttributeString = "$INDEX_ALLOCATION"
			Case $AttributeTypeCheck = "B000"
;				ConsoleWrite("Bitmap:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$record) & @CRLF)
				$CoreBitmap = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreBitmapChunk = $CoreBitmap[0]
				$CoreBitmapName = $CoreBitmap[1]
				$AttributeString = "$BITMAP"
			Case $AttributeTypeCheck = "C000"
				$CoreReparsePoint = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreReparsePointChunk = $CoreReparsePoint[0]
				$CoreReparsePointName = $CoreReparsePoint[1]
				_Get_ReparsePoint($CoreReparsePointChunk,1,$CoreReparsePointName)
				$AttributeString = "$REPARSE_POINT"
			Case $AttributeTypeCheck = "D000"
				$CoreEaInformation = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreEaInformationChunk = $CoreEaInformation[0]
				$CoreEaInformationName = $CoreEaInformation[1]
				_Get_EaInformation($CoreEaInformationChunk,1,$CoreEaInformationName)
				$AttributeString = "$EA_INFORMATION"
			Case $AttributeTypeCheck = "E000"
				$CoreEa = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreEaChunk = $CoreEa[0]
				$CoreEaName = $CoreEa[1]
				_Get_Ea($CoreEaChunk,1,$CoreEaName)
				$AttributeString = "$EA"
			Case $AttributeTypeCheck = "F000"
				$AttributeString = "$PROPERTY_SET"
			Case $AttributeTypeCheck = "0001"
				$CoreLoggedUtilityStream = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreLoggedUtilityStreamChunk = $CoreLoggedUtilityStream[0]
				$CoreLoggedUtilityStreamName = $CoreLoggedUtilityStream[1]
				_Get_LoggedUtilityStream($CoreLoggedUtilityStreamChunk,1,$CoreLoggedUtilityStreamName)
				$AttributeString = "$LOGGED_UTILITY_STREAM"
		EndSelect
	Else
		Select
			Case $AttributeTypeCheck = "1000"
				$AttributeString = "$STANDARD_INFORMATION"
			Case $AttributeTypeCheck = "2000"
				$AttributeString = "$ATTRIBUTE_LIST"
			Case $AttributeTypeCheck = "3000"
				_Get_FileName($record, 1, $RecordSize, 1)
				$AttributeString = "$FILE_NAME"
			Case $AttributeTypeCheck = "4000"
				_Get_ObjectID($record, 1, $RecordSize)
				$AttributeString = "$OBJECT_ID"
			Case $AttributeTypeCheck = "5000"
				$AttributeString = "$SECURITY_DESCRIPTOR"
			Case $AttributeTypeCheck = "6000"
				_Get_VolumeName($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_NAME"
			Case $AttributeTypeCheck = "7000"
				_Get_VolumeInformation($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_INFORMATION"
			Case $AttributeTypeCheck = "8000"
				$AttributeString = "$DATA"
			Case $AttributeTypeCheck = "9000"
				$AttributeString = "$INDEX_ROOT"
			Case $AttributeTypeCheck = "A000"
				$AttributeString = "$INDEX_ALLOCATION"
			Case $AttributeTypeCheck = "B000"
;				ConsoleWrite("Bitmap:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$record) & @CRLF)
				$CoreBitmap = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreBitmapChunk = $CoreBitmap[0]
				$CoreBitmapName = $CoreBitmap[1]
				$AttributeString = "$BITMAP"
			Case $AttributeTypeCheck = "C000"
				$CoreReparsePoint = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreReparsePointChunk = $CoreReparsePoint[0]
				$CoreReparsePointName = $CoreReparsePoint[1]
				_Get_ReparsePoint($CoreReparsePointChunk,1,$CoreReparsePointName)
				$AttributeString = "$REPARSE_POINT"
			Case $AttributeTypeCheck = "D000"
				$CoreEaInformation = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreEaInformationChunk = $CoreEaInformation[0]
				$CoreEaInformationName = $CoreEaInformation[1]
				_Get_EaInformation($CoreEaInformationChunk,1,$CoreEaInformationName)
				$AttributeString = "$EA_INFORMATION"
			Case $AttributeTypeCheck = "E000"
				$CoreEa = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreEaChunk = $CoreEa[0]
				$CoreEaName = $CoreEa[1]
				_Get_Ea($CoreEaChunk,1,$CoreEaName)
				$AttributeString = "$EA"
			Case $AttributeTypeCheck = "F000"
				$AttributeString = "$PROPERTY_SET"
			Case $AttributeTypeCheck = "0001"
				$CoreLoggedUtilityStream = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreLoggedUtilityStreamChunk = $CoreLoggedUtilityStream[0]
				$CoreLoggedUtilityStreamName = $CoreLoggedUtilityStream[1]
				_Get_LoggedUtilityStream($CoreLoggedUtilityStreamChunk,1,$CoreLoggedUtilityStreamName)
				$AttributeString = "$LOGGED_UTILITY_STREAM"
		EndSelect
	EndIf
	Return $DecodeOk
EndFunc

Func _WriteOut_MFTrecord($MFTref, $content)
	Local $SectorSize = 1024, $nBytes = "", $Counter = 1, $rBuffer, $hFileOut, $OutFile, $Written, $Written2
	If Mod(StringLen($content)/2,1024) Then
		Do
			$content &= "00"
		Until Mod(StringLen($content)/2,1024)=0
	EndIf
;Writing 1 file for each found MFT record
#cs
	$OutFile = $ParserOutDir&"\"&$MFTref&"_MFTRecord.bin"
	While 1
		$Counter+=1
		If FileExists($OutFile) = 1 Then
			ConsoleWrite("Taken: " & $OutFile & @CRLF)
			$OutFile = $ParserOutDir&"\"&$MFTref&"_MFTRecord_"&$Counter&".bin"
			ContinueLoop
		Else
			ConsoleWrite("Free: " & $OutFile & @CRLF)
			ExitLoop
		EndIf
	WEnd
	DllStructSetData($rBuffer,1,"0x"&$content)
	$hFileOut = _WinAPI_CreateFile("\\.\" & $OutFile,3,6,7)
	If $hFileOut = 0 Then
		ConsoleWrite("Error: CreateFile returned: " & _WinAPI_GetLastErrorMessage() & @CRLF)
		Return
	EndIf
	$Written = _WinAPI_WriteFile($hFileOut, DllStructGetPtr($rBuffer), $SectorSize, $nBytes)
	If $Written = 0 Then
		ConsoleWrite("Error: WriteFile returned: " & _WinAPI_GetLastErrorMessage() & @CRLF)
		_WinAPI_CloseHandle($hFileOut)
		Return
	EndIf
	_WinAPI_CloseHandle($hFileOut)
#ce
; Writing each record into 1 dummy $MFT with all found records
	$rBuffer = DllStructCreate("byte ["&$SectorSize&"]")
	DllStructSetData($tBuffer,1,"0x"&$content)
	$Written2 = _WinAPI_WriteFile($hOutFileMFT, DllStructGetPtr($tBuffer), $SectorSize, $nBytes2)
	If $Written2 = 0 Then
		ConsoleWrite("Error: WriteFile returned: " & _WinAPI_GetLastErrorMessage() & @CRLF)
	EndIf
EndFunc

Func _UpdateDataRunInformation($TargetRedoOperation, $TargetAttributeOffset, $TargetOffsetToDatarun, $TargetDatarun, $PreviousDatarun)
	; This function is never called if current datarun is empty
	Local $Prepended, $DatarunTmp
	If $VerboseOn Then
		ConsoleWrite("--------------------_UpdateDataRunInformation()-------------------------" & @CRLF)
		ConsoleWrite("$TargetRedoOperation: " & $TargetRedoOperation & @CRLF)
		ConsoleWrite("$TargetAttributeOffset: " & $TargetAttributeOffset & @CRLF)
		ConsoleWrite("$TargetOffsetToDatarun: " & $TargetOffsetToDatarun & @CRLF)
		ConsoleWrite("$TargetDatarun: " & $TargetDatarun & @CRLF)
		ConsoleWrite("$PreviousDatarun: " & $PreviousDatarun & @CRLF)
	EndIf
	If StringLen($TargetDatarun) < 2 Then Return $PreviousDatarun
	If $TargetOffsetToDatarun = "" Then $TargetOffsetToDatarun = 0
	If ($TargetAttributeOffset = "" Or $TargetAttributeOffset = 0) And ($TargetRedoOperation="InitializeFileRecordSegment" Or $TargetRedoOperation="CreateAttribute") Then $TargetAttributeOffset = $TargetOffsetToDatarun
	If $TargetAttributeOffset < 72 And $TargetOffsetToDatarun = 0 Then $TargetOffsetToDatarun = 64
	If $TargetAttributeOffset >= 72 And $TargetOffsetToDatarun = 0 Then $TargetOffsetToDatarun = 72
	$ResolvedOffset = $TargetAttributeOffset-$TargetOffsetToDatarun
	If $VerboseOn Then ConsoleWrite("$ResolvedOffset: " & $ResolvedOffset & @CRLF)
	If $PreviousDatarun = "" Then ;First processing time for target ref
		If StringInStr($PreviousDatarun,"?")=0 And StringInStr($PreviousDatarun,"!")=0 And ($TargetRedoOperation="UpdateMappingPairs" Or $TargetRedoOperation="SetNewAttributeSizes") Then
			For $k = 1 To $ResolvedOffset
				$Prepended&="**"
			Next
			$DatarunTmp = "?"&$Prepended&$TargetDatarun
		ElseIf StringInStr($PreviousDatarun,"?")=0 And StringInStr($PreviousDatarun,"!")=0 And ($TargetRedoOperation="InitializeFileRecordSegment" Or $TargetRedoOperation="CreateAttribute") Then
			$DatarunTmp = "!"&$TargetDatarun
		EndIf
		If $VerboseOn Then ConsoleWrite("$DatarunTmp: " & $DatarunTmp & @CRLF)
		Return $DatarunTmp
	EndIf
	If $TargetDatarun = "" Then Return ;?
	;Second processing time for given ref. Will prepend ** equivalent to unknown first bytes. "?" is mmising first bytes and "|" is all bytes in run list known.
	If StringInStr($PreviousDatarun,"?")=0 And StringInStr($PreviousDatarun,"!")=0 And ($TargetRedoOperation="UpdateMappingPairs" Or $TargetRedoOperation="SetNewAttributeSizes") Then
		For $k = 1 To $ResolvedOffset
			$Prepended&="**"
		Next
		$DatarunTmp = "?"&$Prepended&$TargetDatarun
	ElseIf StringInStr($PreviousDatarun,"?")=0 And StringInStr($PreviousDatarun,"!")=0 And ($TargetRedoOperation="InitializeFileRecordSegment" Or $TargetRedoOperation="CreateAttribute") Then
		$DatarunTmp = "!"&$TargetDatarun
	Else
		$DatarunTmp = $PreviousDatarun
	EndIf
	$OffsetOfPrepended = StringInStr($DatarunTmp,"*",0,-1)
	If $ResolvedOffset=0 Then $DatarunTmp = StringReplace($DatarunTmp,"?","!")
	$FirstPart = StringMid($DatarunTmp,1,1+($ResolvedOffset*2))
	$ReassembledDatarun = $FirstPart&$TargetDatarun
	If $VerboseOn Then
		ConsoleWrite("$DatarunTmp: " & $DatarunTmp & @CRLF)
		ConsoleWrite("$OffsetOfPrepended: " & $OffsetOfPrepended & @CRLF)
		ConsoleWrite("$FirstPart: " & $FirstPart & @CRLF)
		ConsoleWrite("$ReassembledDatarun: " & $ReassembledDatarun & @CRLF)
	EndIf
	Return $ReassembledDatarun
EndFunc

;Had some problems with the original function and standard setup
Func _SQLite_SQLiteExe2($sDatabaseFile, $sInput, ByRef $sOutput, $sSQLiteExeFilename = -1, $fDebug = False)
	If $sSQLiteExeFilename = -1 Or (IsKeyword($sSQLiteExeFilename) And $sSQLiteExeFilename = Default) Then
		$sSQLiteExeFilename = @ScriptDir & "\SQLite3.exe"
		If Not FileExists($sSQLiteExeFilename) Then
			Local $aTemp = StringSplit(@AutoItExe, "\")
			$sSQLiteExeFilename = ""
			For $i = 1 To $aTemp[0] - 1
				$sSQLiteExeFilename &= $aTemp[$i] & "\"
			Next
			$sSQLiteExeFilename &= "Extras\SQLite\SQLite3.exe"
		EndIf
	EndIf
	If Not FileExists($sDatabaseFile) Then
		Local $hNewFile = FileOpen($sDatabaseFile, 2 + 8)
		If $hNewFile = -1 Then
			Return SetError(1, 0, $SQLITE_CANTOPEN) ; Can't Create new Database
		EndIf
		FileClose($hNewFile)
	EndIf
	Local $sInputFile = _TempFile(), $sOutputFile = _TempFile(), $iRval = $SQLITE_OK
	Local $hInputFile = FileOpen($sInputFile, 2)
	If $hInputFile > -1 Then
		$sInput = ".output stdout" & @CRLF & $sInput
		FileWrite($hInputFile, $sInput)
		FileClose($hInputFile)
		Local $sCmd = @ComSpec & " /c " & FileGetShortName($sSQLiteExeFilename) & '  "' _
				 & FileGetShortName($sDatabaseFile) _
				 & '" > "' & FileGetShortName($sOutputFile) _
				 & '" < "' & FileGetShortName($sInputFile) & '"'
		Local $nErrorLevel = RunWait($sCmd, @ScriptDir, @SW_HIDE)
		If $fDebug = True Then
			Local $nErrorTemp = @error
			__SQLite_Print('@@ Debug(_SQLite_SQLiteExe) : $sCmd = ' & $sCmd & @CRLF & '>ErrorLevel: ' & $nErrorLevel & @CRLF)
			SetError($nErrorTemp)
		EndIf
		If @error = 1 Or $nErrorLevel = 1 Then
			$iRval = $SQLITE_MISUSE ; SQLite.exe not found
		Else
			$sOutput = FileRead($sOutputFile, FileGetSize($sOutputFile))
			If StringInStr($sOutput, "SQL error:", 1) > 0 Or StringInStr($sOutput, "Incomplete SQL:", 1) > 0 Then $iRval = $SQLITE_ERROR ; SQL error / Incomplete SQL
		EndIf
	Else
		$iRval = $SQLITE_CANTOPEN ; Can't open Input File
	EndIf
	If FileExists($sInputFile) Then FileDelete($sInputFile)
	Switch $iRval
		Case $SQLITE_MISUSE
			SetError(2)
		Case $SQLITE_ERROR
			SetError(3)
		Case $SQLITE_CANTOPEN
			SetError(4)
	EndSwitch
	Return $iRval
EndFunc

Func _Decode_StandardInformation($Attribute)
	Local $SI_HEADER_Flags, $SI_Offset = 1-48, $Add="", $f=0, $SI_Size, $SI_CTime_tmp, $SI_ATime_tmp, $SI_MTime_tmp, $SI_RTime_tmp
	If $attribute_offset < 24 Then $Attribute = StringTrimLeft($Attribute,24-$attribute_offset) ;For now just strip the attribute header.
	$SI_Size = StringLen($Attribute)
	Select
		Case $attribute_offset <= 48
			If $attribute_offset = 32 Then $Attribute = "0000000000000000"&$Attribute
			If $attribute_offset = 40 Then $Attribute = "00000000000000000000000000000000"&$Attribute
			If $attribute_offset = 48 Then $Attribute = "000000000000000000000000000000000000000000000000"&$Attribute
			$SI_CTime = StringMid($Attribute, $SI_Offset + 48, 16)
;			$SI_CTime = _SwapEndian($SI_CTime)
;			$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
;			$SI_CTime = _WinTime_UTCFileTimeFormat(Dec($SI_CTime,2) - $tDelta, $DateTimeFormat, 2)
;			If @error Then
;				$SI_CTime = "-"
;			Else
;				$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
;			EndIf
			;
			$SI_CTime = _SwapEndian($SI_CTime)
			$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
			$SI_CTime = _WinTime_UTCFileTimeFormat(Dec($SI_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$SI_CTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$SI_CTime_Core = StringMid($SI_CTime,1,StringLen($SI_CTime)-4)
				$SI_CTime_Precision = StringRight($SI_CTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
				$SI_CTime_Core = StringMid($SI_CTime,1,StringLen($SI_CTime)-9)
				$SI_CTime_Precision = StringRight($SI_CTime,8)
			Else
				$SI_CTime_Core = $SI_CTime
			EndIf
			;
			$SI_ATime = StringMid($Attribute, $SI_Offset + 64, 16)
;			$SI_ATime = _SwapEndian($SI_ATime)
;			$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
;			$SI_ATime = _WinTime_UTCFileTimeFormat(Dec($SI_ATime,2) - $tDelta, $DateTimeFormat, 2)
;			If @error Then
;				$SI_ATime = "-"
;			Else
;				$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
;			EndIf
			;
			$SI_ATime = _SwapEndian($SI_ATime)
			$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
			$SI_ATime = _WinTime_UTCFileTimeFormat(Dec($SI_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$SI_ATime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$SI_ATime_Core = StringMid($SI_ATime,1,StringLen($SI_ATime)-4)
				$SI_ATime_Precision = StringRight($SI_ATime,3)
			ElseIf $TimestampPrecision = 3 Then
				$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
				$SI_ATime_Core = StringMid($SI_ATime,1,StringLen($SI_ATime)-9)
				$SI_ATime_Precision = StringRight($SI_ATime,8)
			Else
				$SI_ATime_Core = $SI_ATime
			EndIf
			;
			$SI_MTime = StringMid($Attribute, $SI_Offset + 80, 16)
;			$SI_MTime = _SwapEndian($SI_MTime)
;			$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
;			$SI_MTime = _WinTime_UTCFileTimeFormat(Dec($SI_MTime,2) - $tDelta, $DateTimeFormat, 2)
;			If @error Then
;				$SI_MTime = "-"
;			Else
;				$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
;			EndIf
			;
			$SI_MTime = _SwapEndian($SI_MTime)
			$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
			$SI_MTime = _WinTime_UTCFileTimeFormat(Dec($SI_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$SI_MTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$SI_MTime_Core = StringMid($SI_MTime,1,StringLen($SI_MTime)-4)
				$SI_MTime_Precision = StringRight($SI_MTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
				$SI_MTime_Core = StringMid($SI_MTime,1,StringLen($SI_MTime)-9)
				$SI_MTime_Precision = StringRight($SI_MTime,8)
			Else
				$SI_MTime_Core = $SI_MTime
			EndIf
			;
			$SI_RTime = StringMid($Attribute, $SI_Offset + 96, 16)
;			$SI_RTime = _SwapEndian($SI_RTime)
;			$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
;			$SI_RTime = _WinTime_UTCFileTimeFormat(Dec($SI_RTime,2) - $tDelta, $DateTimeFormat, 2)
;			If @error Then
;				$SI_RTime = "-"
;			Else
;				$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
;			EndIf
			;
			$SI_RTime = _SwapEndian($SI_RTime)
			$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
			$SI_RTime = _WinTime_UTCFileTimeFormat(Dec($SI_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$SI_RTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$SI_RTime_Core = StringMid($SI_RTime,1,StringLen($SI_RTime)-4)
				$SI_RTime_Precision = StringRight($SI_RTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
				$SI_RTime_Core = StringMid($SI_RTime,1,StringLen($SI_RTime)-9)
				$SI_RTime_Precision = StringRight($SI_RTime,8)
			Else
				$SI_RTime_Core = $SI_RTime
			EndIf
			;
			; 16 * 4 = 64
			If $SI_Size >= 72 Then
				$SI_FilePermission = StringMid($Attribute, $SI_Offset + 112, 8)
				$SI_FilePermission = _SwapEndian($SI_FilePermission)
				$SI_FilePermission = _File_Attributes("0x" & $SI_FilePermission)
			Else
				$SI_FilePermission = "-"
			EndIf
			If $SI_Size >= 80 Then
				$SI_MaxVersions = StringMid($Attribute, $SI_Offset + 120, 8)
				$SI_MaxVersions = Dec(_SwapEndian($SI_MaxVersions),2)
			Else
				$SI_MaxVersions = "-"
			EndIf
			If $SI_Size >= 88 Then
				$SI_VersionNumber = StringMid($Attribute, $SI_Offset + 128, 8)
				$SI_VersionNumber = Dec(_SwapEndian($SI_VersionNumber),2)
			Else
				$SI_VersionNumber = "-"
			EndIf
			If $SI_Size >= 96 Then
				$SI_ClassID = StringMid($Attribute, $SI_Offset + 136, 8)
				$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
			Else
				$SI_ClassID = "-"
			EndIf
			If $SI_Size >= 104 Then
				$SI_OwnerID = StringMid($Attribute, $SI_Offset + 144, 8)
				$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
			Else
				$SI_OwnerID = "-"
			EndIf
			If $SI_Size >= 112 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "-"
			EndIf
			If $SI_Size >= 128 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 144 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 56 And $attribute_offset < 60
			$SI_Offset = 1-112
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			If $attribute_offset = 56 Then
				$SI_FilePermission = StringMid($Attribute, $SI_Offset + 112, 8)
				$SI_FilePermission = _SwapEndian($SI_FilePermission)
				$SI_FilePermission = _File_Attributes("0x" & $SI_FilePermission)
			Else
				$SI_FilePermission = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 112, 8 - ($attribute_offset-56)*2)
			EndIf
;Adjust the rest of the attribute
			For $f = 1 To $attribute_offset-56
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size >= 16 Then
				$SI_MaxVersions = StringMid($Attribute, $SI_Offset + 120, 8)
				$SI_MaxVersions = Dec(_SwapEndian($SI_MaxVersions),2)
			Else
				$SI_MaxVersions = "-"
			EndIf
			If $SI_Size >= 24 Then
				$SI_VersionNumber = StringMid($Attribute, $SI_Offset + 128, 8)
				$SI_VersionNumber = Dec(_SwapEndian($SI_VersionNumber),2)
			Else
				$SI_VersionNumber = "-"
			EndIf
			If $SI_Size >= 32 Then
				$SI_ClassID = StringMid($Attribute, $SI_Offset + 136, 8)
				$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
			Else
				$SI_ClassID = "-"
			EndIf
			If $SI_Size >= 40 Then
				$SI_OwnerID = StringMid($Attribute, $SI_Offset + 144, 8)
				$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
			Else
				$SI_OwnerID = "-"
			EndIf
			If $SI_Size >= 48 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "-"
			EndIf
			If $SI_Size >= 64 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 80 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 60 And $attribute_offset < 64
			$SI_Offset = 1-120
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			If $attribute_offset = 60 Then
				$SI_MaxVersions = StringMid($Attribute, $SI_Offset + 120, 8)
				$SI_MaxVersions = Dec(_SwapEndian($SI_MaxVersions),2)
			Else
				$SI_MaxVersions = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 120, 8 - ($attribute_offset-60)*2)
			EndIf
			For $f = 1 To $attribute_offset-60
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size >= 16 Then
				$SI_VersionNumber = StringMid($Attribute, $SI_Offset + 128, 8)
				$SI_VersionNumber = Dec(_SwapEndian($SI_VersionNumber),2)
			Else
				$SI_VersionNumber = "-"
			EndIf
			If $SI_Size >= 24 Then
				$SI_ClassID = StringMid($Attribute, $SI_Offset + 136, 8)
				$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
			Else
				$SI_ClassID = "-"
			EndIf
			If $SI_Size >= 32 Then
				$SI_OwnerID = StringMid($Attribute, $SI_Offset + 144, 8)
				$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
			Else
				$SI_OwnerID = "-"
			EndIf
			If $SI_Size >= 40 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "-"
			EndIf
			If $SI_Size >= 56 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 80 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 64 And $attribute_offset < 68
			$SI_Offset = 1-128
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			$SI_MaxVersions = "-"
			If $attribute_offset = 64 Then
				$SI_VersionNumber = StringMid($Attribute, $SI_Offset + 128, 8)
				$SI_VersionNumber = Dec(_SwapEndian($SI_VersionNumber),2)
			Else
				$SI_VersionNumber = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 128, 8 - ($attribute_offset-64)*2)
			EndIf
			For $f = 1 To $attribute_offset-64
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size >= 16 Then
				$SI_ClassID = StringMid($Attribute, $SI_Offset + 136, 8)
				$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
			Else
				$SI_ClassID = "-"
			EndIf
			If $SI_Size >= 24 Then
				$SI_OwnerID = StringMid($Attribute, $SI_Offset + 144, 8)
				$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
			Else
				$SI_OwnerID = "-"
			EndIf
			If $SI_Size >= 32 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "-"
			EndIf
			If $SI_Size >= 48 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 64 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 68 And $attribute_offset < 72
			$SI_Offset = 1-136
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			$SI_MaxVersions = "-"
			$SI_VersionNumber = "-"
			If $attribute_offset = 68 Then
				$SI_ClassID = StringMid($Attribute, $SI_Offset + 136, 8)
				$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
			Else
				$SI_ClassID = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 136, 8 - ($attribute_offset-68)*2)
			EndIf
			For $f = 1 To $attribute_offset-68
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size >= 16 Then
				$SI_OwnerID = StringMid($Attribute, $SI_Offset + 144, 8)
				$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
			Else
				$SI_OwnerID = "-"
			EndIf
			If $SI_Size >= 24 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "-"
			EndIf
			If $SI_Size >= 40 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 56 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 72 And $attribute_offset < 76
			$SI_Offset = 1-144
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			$SI_MaxVersions = "-"
			$SI_VersionNumber = "-"
			$SI_ClassID = "-"
			If $attribute_offset = 72 Then
				$SI_OwnerID = StringMid($Attribute, $SI_Offset + 144, 8)
				$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
			Else
				$SI_OwnerID = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 144, 8 - ($attribute_offset-72)*2)
			EndIf
			For $f = 1 To $attribute_offset-72
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size >= 16 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "-"
			EndIf
			If $SI_Size >= 32 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 48 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 76 And $attribute_offset < 80
			$SI_Offset = 1-152
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			$SI_MaxVersions = "-"
			$SI_VersionNumber = "-"
			$SI_ClassID = "-"
			$SI_OwnerID = "-"
			If $attribute_offset = 76 Then
				$SI_SecurityID = StringMid($Attribute, $SI_Offset + 152, 8)
				$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
			Else
				$SI_SecurityID = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 152, 8 - ($attribute_offset-76)*2)
			EndIf
			For $f = 1 To $attribute_offset-76
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size >= 24 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "-"
			EndIf
			If $SI_Size >= 40 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 80 And $attribute_offset < 88
			$SI_Offset = 1-160
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			$SI_MaxVersions = "-"
			$SI_VersionNumber = "-"
			$SI_ClassID = "-"
			$SI_OwnerID = "-"
			$SI_SecurityID = "-"
			If $attribute_offset = 80 Then
				$SI_QuotaCharged = StringMid($Attribute, $SI_Offset + 160, 16)
				$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
			Else
				$SI_QuotaCharged = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 160, 16 - ($attribute_offset-80)*2)
			EndIf
			For $f = 1 To $attribute_offset-80
				$Add &= "00"
			Next
			$Attribute = $Add&$Attribute
			$SI_Size = StringLen($Attribute)
			If $SI_Size = 16 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "-"
			EndIf
		Case $attribute_offset >= 88 And $attribute_offset < 95
			$SI_Offset = 1-176
			$SI_CTime = "-"
			$SI_ATime = "-"
			$SI_MTime = "-"
			$SI_RTime = "-"
			$SI_FilePermission = "-"
			$SI_MaxVersions = "-"
			$SI_VersionNumber = "-"
			$SI_ClassID = "-"
			$SI_OwnerID = "-"
			$SI_SecurityID = "-"
			$SI_QuotaCharged = "-"
			If $attribute_offset = 88 Then
				$SI_USN = StringMid($Attribute, $SI_Offset + 176, 16)
				$SI_USN = Dec(_SwapEndian($SI_USN),2)
			Else
				$SI_USN = "PARTIAL VALUE"
				$SI_PartialValue = StringMid($Attribute, $SI_Offset + 176, 16 - ($attribute_offset-88)*2)
			EndIf
		EndSelect
	If $SI_USN <> "-" Then _WriteLogFileDataRunsCsv()
	If $VerboseOn Then
		ConsoleWrite("$SI_HEADER_Flags: " & $SI_HEADER_Flags & @CRLF)
		ConsoleWrite("$SI_CTime: " & $SI_CTime & @CRLF)
		ConsoleWrite("$SI_ATime: " & $SI_ATime & @CRLF)
		ConsoleWrite("$SI_MTime: " & $SI_MTime & @CRLF)
		ConsoleWrite("$SI_RTime: " & $SI_RTime & @CRLF)
		ConsoleWrite("$SI_FilePermission: " & $SI_FilePermission & @CRLF)
		ConsoleWrite("$SI_MaxVersions: " & $SI_MaxVersions & @CRLF)
		ConsoleWrite("$SI_VersionNumber: " & $SI_VersionNumber & @CRLF)
		ConsoleWrite("$SI_ClassID: " & $SI_ClassID & @CRLF)
		ConsoleWrite("$SI_OwnerID: " & $SI_OwnerID & @CRLF)
		ConsoleWrite("$SI_SecurityID: " & $SI_SecurityID & @CRLF)
		ConsoleWrite("$SI_QuotaCharged: " & $SI_QuotaCharged & @CRLF)
		ConsoleWrite("$SI_USN: " & $SI_USN & @CRLF)
		ConsoleWrite("$SI_PartialValue: " & $SI_PartialValue & @CRLF)
	EndIf
EndFunc

Func _Decode_FileName($attribute)
	Local $SI_CTime_tmp, $SI_ATime_tmp, $SI_MTime_tmp, $SI_RTime_tmp
	$SI_CTime = StringMid($attribute, 1, 16)
	$SI_CTime = _SwapEndian($SI_CTime)
	$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
	;
	$SI_CTime = _WinTime_UTCFileTimeFormat(Dec($SI_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_CTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_CTime_Core = StringMid($SI_CTime,1,StringLen($SI_CTime)-4)
		$SI_CTime_Precision = StringRight($SI_CTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
		$SI_CTime_Core = StringMid($SI_CTime,1,StringLen($SI_CTime)-9)
		$SI_CTime_Precision = StringRight($SI_CTime,8)
	Else
		$SI_CTime_Core = $SI_CTime
	EndIf
	;
	$SI_ATime = StringMid($attribute, 17, 16)
	$SI_ATime = _SwapEndian($SI_ATime)
	$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
	;
	$SI_ATime = _WinTime_UTCFileTimeFormat(Dec($SI_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_ATime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_ATime_Core = StringMid($SI_ATime,1,StringLen($SI_ATime)-4)
		$SI_ATime_Precision = StringRight($SI_ATime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
		$SI_ATime_Core = StringMid($SI_ATime,1,StringLen($SI_ATime)-9)
		$SI_ATime_Precision = StringRight($SI_ATime,8)
	Else
		$SI_ATime_Core = $SI_ATime
	EndIf
	;
	$SI_MTime = StringMid($attribute, 33, 16)
	$SI_MTime = _SwapEndian($SI_MTime)
	$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
	;
	$SI_MTime = _WinTime_UTCFileTimeFormat(Dec($SI_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_MTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_MTime_Core = StringMid($SI_MTime,1,StringLen($SI_MTime)-4)
		$SI_MTime_Precision = StringRight($SI_MTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
		$SI_MTime_Core = StringMid($SI_MTime,1,StringLen($SI_MTime)-9)
		$SI_MTime_Precision = StringRight($SI_MTime,8)
	Else
		$SI_MTime_Core = $SI_MTime
	EndIf
	;
	$SI_RTime = StringMid($attribute, 49, 16)
	$SI_RTime = _SwapEndian($SI_RTime)
	$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
	;
	$SI_RTime = _WinTime_UTCFileTimeFormat(Dec($SI_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$SI_RTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$SI_RTime_Core = StringMid($SI_RTime,1,StringLen($SI_RTime)-4)
		$SI_RTime_Precision = StringRight($SI_RTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
		$SI_RTime_Core = StringMid($SI_RTime,1,StringLen($SI_RTime)-9)
		$SI_RTime_Precision = StringRight($SI_RTime,8)
	Else
		$SI_RTime_Core = $SI_RTime
	EndIf
	;
	$FN_AllocSize = StringMid($attribute, 65, 16)
	$FN_AllocSize = Dec(_SwapEndian($FN_AllocSize),2)
	$FN_RealSize = StringMid($attribute, 81, 16)
	$FN_RealSize = Dec(_SwapEndian($FN_RealSize),2)
	$FN_Flags = StringMid($attribute, 97, 8)
	$FN_Flags = _SwapEndian($FN_Flags)
	$FN_Flags = _File_Attributes("0x" & $FN_Flags)
	If $VerboseOn Then
		ConsoleWrite("########### Decoding $FILE_NAME ATTTRIBUTE ###########" & @CRLF)
		ConsoleWrite("$SI_CTime: " & $SI_CTime & @CRLF)
		ConsoleWrite("$SI_ATime: " & $SI_ATime & @CRLF)
		ConsoleWrite("$SI_MTime: " & $SI_MTime & @CRLF)
		ConsoleWrite("$SI_RTime: " & $SI_RTime & @CRLF)
		ConsoleWrite("$FN_AllocSize: " & $FN_AllocSize & @CRLF)
		ConsoleWrite("$FN_RealSize: " & $FN_RealSize & @CRLF)
		ConsoleWrite("$FN_Flags: " & $FN_Flags & @CRLF)
	EndIf
EndFunc

Func _DecodeSourceInfoFlag($input)
	Select
		Case $input = 0x00000001
			$ret = "USN_SOURCE_DATA_MANAGEMENT"
		Case $input = 0x00000002
			$ret = "USN_SOURCE_AUXILIARY_DATA"
		Case $input = 0x00000004
			$ret = "USN_SOURCE_REPLICATION_MANAGEMENT"
		Case Else
			$ret = "EMPTY"
	EndSelect
	Return $ret
EndFunc

Func _DecodeTimestamp($StampDecode)
	$StampDecode = _SwapEndian($StampDecode)
	$StampDecode_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $StampDecode)
	$StampDecode = _WinTime_UTCFileTimeFormat(Dec($StampDecode,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$StampDecode = "-"
	ElseIf $TimestampPrecision = 3 Then
		$StampDecode = $StampDecode & ":" & _FillZero(StringRight($StampDecode_tmp, 4))
	EndIf
	Return $StampDecode
EndFunc

Func _DecodeReasonCodes($USNReasonInput)
	Local $USNReasonOutput = ""
	If BitAND($USNReasonInput, 0x00008000) Then $USNReasonOutput &= 'BASIC_INFO_CHANGE+'
	If BitAND($USNReasonInput, 0x80000000) Then $USNReasonOutput &= 'CLOSE+'
	If BitAND($USNReasonInput, 0x00020000) Then $USNReasonOutput &= 'COMPRESSION_CHANGE+'
	If BitAND($USNReasonInput, 0x00000002) Then $USNReasonOutput &= 'DATA_EXTEND+'
	If BitAND($USNReasonInput, 0x00000001) Then $USNReasonOutput &= 'DATA_OVERWRITE+'
	If BitAND($USNReasonInput, 0x00000004) Then $USNReasonOutput &= 'DATA_TRUNCATION+'
	If BitAND($USNReasonInput, 0x00000400) Then $USNReasonOutput &= 'EA_CHANGE+'
	If BitAND($USNReasonInput, 0x00040000) Then $USNReasonOutput &= 'ENCRYPTION_CHANGE+'
	If BitAND($USNReasonInput, 0x00000100) Then $USNReasonOutput &= 'FILE_CREATE+'
	If BitAND($USNReasonInput, 0x00000200) Then $USNReasonOutput &= 'FILE_DELETE+'
	If BitAND($USNReasonInput, 0x00010000) Then $USNReasonOutput &= 'HARD_LINK_CHANGE+'
	If BitAND($USNReasonInput, 0x00004000) Then $USNReasonOutput &= 'INDEXABLE_CHANGE+'
	If BitAND($USNReasonInput, 0x00000020) Then $USNReasonOutput &= 'NAMED_DATA_EXTEND+'
	If BitAND($USNReasonInput, 0x00000010) Then $USNReasonOutput &= 'NAMED_DATA_OVERWRITE+'
	If BitAND($USNReasonInput, 0x00000040) Then $USNReasonOutput &= 'NAMED_DATA_TRUNCATION+'
	If BitAND($USNReasonInput, 0x00080000) Then $USNReasonOutput &= 'OBJECT_ID_CHANGE+'
	If BitAND($USNReasonInput, 0x00002000) Then $USNReasonOutput &= 'RENAME_NEW_NAME+'
	If BitAND($USNReasonInput, 0x00001000) Then $USNReasonOutput &= 'RENAME_OLD_NAME+'
	If BitAND($USNReasonInput, 0x00100000) Then $USNReasonOutput &= 'REPARSE_POINT_CHANGE+'
	If BitAND($USNReasonInput, 0x00000800) Then $USNReasonOutput &= 'SECURITY_CHANGE+'
	If BitAND($USNReasonInput, 0x00200000) Then $USNReasonOutput &= 'STREAM_CHANGE+'
	If BitAND($USNReasonInput, 0x00800000) Then $USNReasonOutput &= 'INTEGRITY_CHANGE+'
	$USNReasonOutput = StringTrimRight($USNReasonOutput, 1)
	Return $USNReasonOutput
EndFunc

Func _File_Attributes($FAInput)
	Local $FAOutput = ""
	If BitAND($FAInput, 0x0001) Then $FAOutput &= 'read_only+'
	If BitAND($FAInput, 0x0002) Then $FAOutput &= 'hidden+'
	If BitAND($FAInput, 0x0004) Then $FAOutput &= 'system+'
	If BitAND($FAInput, 0x0010) Then $FAOutput &= 'directory+'
	If BitAND($FAInput, 0x0020) Then $FAOutput &= 'archive+'
	If BitAND($FAInput, 0x0040) Then $FAOutput &= 'device+'
	If BitAND($FAInput, 0x0080) Then $FAOutput &= 'normal+'
	If BitAND($FAInput, 0x0100) Then $FAOutput &= 'temporary+'
	If BitAND($FAInput, 0x0200) Then $FAOutput &= 'sparse_file+'
	If BitAND($FAInput, 0x0400) Then $FAOutput &= 'reparse_point+'
	If BitAND($FAInput, 0x0800) Then $FAOutput &= 'compressed+'
	If BitAND($FAInput, 0x1000) Then $FAOutput &= 'offline+'
	If BitAND($FAInput, 0x2000) Then $FAOutput &= 'not_indexed+'
	If BitAND($FAInput, 0x4000) Then $FAOutput &= 'encrypted+'
	If BitAND($FAInput, 0x8000) Then $FAOutput &= 'integrity_stream+'
	If BitAND($FAInput, 0x10000) Then $FAOutput &= 'virtual+'
	If BitAND($FAInput, 0x20000) Then $FAOutput &= 'no_scrub_data+'
	If BitAND($FAInput, 0x10000000) Then $FAOutput &= 'directory+'
	If BitAND($FAInput, 0x20000000) Then $FAOutput &= 'index_view+'
	$FAOutput = StringTrimRight($FAOutput, 1)
	Return $FAOutput
EndFunc

Func _UsnProcessPage($TargetPage)
	Local $LocalUsnPart = 0, $NextOffset = 1, $TotalSizeOfPage = StringLen($TargetPage)
	Do
		$LocalUsnPart+=1
		$SizeOfNextUsnRecord = StringMid($TargetPage,$NextOffset,8)
		$SizeOfNextUsnRecord = Dec(_SwapEndian($SizeOfNextUsnRecord),2)
		If $SizeOfNextUsnRecord = 0 Then ExitLoop
		$SizeOfNextUsnRecord = $SizeOfNextUsnRecord*2
		$NextUsnRecord = StringMid($TargetPage,$NextOffset,$SizeOfNextUsnRecord)
		$FileNameLength = StringMid($TargetPage,$NextOffset+112,4)
		$FileNameLength = Dec(_SwapEndian($FileNameLength),2)
;		$TestOffset = $FileNameOffset+$FileNameLength
		$TestOffset = 60+$FileNameLength
		If $NextOffset+$SizeOfNextUsnRecord >= $TotalSizeOfPage Then Return
;		ConsoleWrite(" - - - - - - - - - - - - - - - - - - - - - - - - - - " & @CRLF)
;		ConsoleWrite("Part: " & $LocalUsnPart & @CRLF)
;		ConsoleWrite(_HexEncode("0x"&$NextUsnRecord) & @CRLF)
		_UsnDecodeRecord($NextUsnRecord)
		$NextOffset+=$SizeOfNextUsnRecord
	Until $NextOffset >= $TotalSizeOfPage
	Return
EndFunc

Func _UsnDecodeRecord($Record)
	$UsnJrnlRecordLength = StringMid($Record,1,8)
	$UsnJrnlRecordLength = Dec(_SwapEndian($UsnJrnlRecordLength),2)
;	$UsnJrnlMajorVersion = StringMid($Record,9,4)
;	$UsnJrnlMinorVersion = StringMid($Record,13,4)
	$UsnJrnlFileReferenceNumber = StringMid($Record,17,12)
	$UsnJrnlFileReferenceNumber = Dec(_SwapEndian($UsnJrnlFileReferenceNumber),2)
	$UsnJrnlParentFileReferenceNumber = StringMid($Record,33,12)
	$UsnJrnlParentFileReferenceNumber = Dec(_SwapEndian($UsnJrnlParentFileReferenceNumber),2)
	$UsnJrnlUsn = StringMid($Record,49,16)
	$UsnJrnlUsn = Dec(_SwapEndian($UsnJrnlUsn),2)
	$UsnJrnlTimestamp = StringMid($Record,65,16)
	$UsnJrnlTimestamp = _DecodeTimestamp($UsnJrnlTimestamp)
	$UsnJrnlReason = StringMid($Record,81,8)
	$UsnJrnlReason = _DecodeReasonCodes("0x"&_SwapEndian($UsnJrnlReason))
	$UsnJrnlSourceInfo = StringMid($Record,89,8)
;	$UsnJrnlSourceInfo = _DecodeSourceInfoFlag("0x"&_SwapEndian($UsnJrnlSourceInfo))
	$UsnJrnlSourceInfo = "0x"&_SwapEndian($UsnJrnlSourceInfo)
;	$UsnJrnlSecurityId = StringMid($Record,97,8)
	$UsnJrnlFileAttributes = StringMid($Record,105,8)
	$UsnJrnlFileAttributes = _File_Attributes("0x"&_SwapEndian($UsnJrnlFileAttributes))
	$UsnJrnlFileNameLength = StringMid($Record,113,4)
	$UsnJrnlFileNameLength = Dec(_SwapEndian($UsnJrnlFileNameLength),2)
	$UsnJrnlFileNameOffset = StringMid($Record,117,4)
	$UsnJrnlFileNameOffset = Dec(_SwapEndian($UsnJrnlFileNameOffset),2)
	$UsnJrnlFileName = StringMid($Record,121,$UsnJrnlFileNameLength*2)
	$UsnJrnlFileName = _UnicodeHexToStr($UsnJrnlFileName)
	$UsnJrnlFileName = StringReplace($UsnJrnlFileName,$de,$CharReplacement)
	$FileNameModified = @extended
	If $VerboseOn Then
		ConsoleWrite("$UsnJrnlFileReferenceNumber: " & $UsnJrnlFileReferenceNumber & @CRLF)
		ConsoleWrite("$UsnJrnlParentFileReferenceNumber: " & $UsnJrnlParentFileReferenceNumber & @CRLF)
		ConsoleWrite("$UsnJrnlUsn: " & $UsnJrnlUsn & @CRLF)
		ConsoleWrite("$UsnJrnlTimestamp: " & $UsnJrnlTimestamp & @CRLF)
		ConsoleWrite("$UsnJrnlReason: " & $UsnJrnlReason & @CRLF)
		ConsoleWrite("$UsnJrnlSourceInfo: " & $UsnJrnlSourceInfo & @CRLF)
		ConsoleWrite("$UsnJrnlFileAttributes: " & $UsnJrnlFileAttributes & @CRLF)
		ConsoleWrite("$UsnJrnlFileName: " & $UsnJrnlFileName & @CRLF)
	EndIf
	FileWriteLine($UsnJrnlCsv, $UsnJrnlFileReferenceNumber&$de&$UsnJrnlParentFileReferenceNumber&$de&$UsnJrnlUsn&$de&$UsnJrnlTimestamp&$de&$UsnJrnlReason&$de&$UsnJrnlSourceInfo&$de&$UsnJrnlFileAttributes&$de&$UsnJrnlFileName&$de&$FileNameModified&@crlf)
EndFunc

Func _ClearVar()
;	$RecordOffset=""
	$PredictedRefNumber=""
	$this_lsn=""
	$client_previous_lsn=""
	$redo_operation=""
	$undo_operation=""
	$record_offset_in_mft=""
	$attribute_offset=""
	$DT_Flags=""
	$DT_NonResidentFlag=""
	$DT_ComprUnitSize=""
	$DT_AllocSize=""
	$DT_RealSize=""
;	$FileSizeBytes=""
	$DT_InitStreamSize=""
	$DT_DataRuns=""
	$DT_StartVCN=""
	$DT_LastVCN=""
	$DT_AllocSize=""
	$DT_Name=""
	$FN_Name=""
	$DT_OffsetToDataRuns=""
	$SI_CTime=""
	$SI_ATime=""
	$SI_MTime=""
	$SI_RTime=""
	$SI_RTime=""
	$SI_FilePermission=""
	$SI_MaxVersions=""
	$SI_VersionNumber=""
	$SI_ClassID=""
	$SI_SecurityID=""
	$SI_QuotaCharged=""
	$SI_USN=""
	$SI_PartialValue=""
	$FN_CTime=""
	$FN_ATime=""
	$FN_MTime=""
	$FN_RTime=""
	$FN_AllocSize=""
	$FN_RealSize=""
	$FN_Flags=""
	$FN_Name=""
	$FN_NameType=""
	$UsnJrnlFileName=""
	$FileNameModified=""
	$UsnJrnlFileReferenceNumber=""
	$UsnJrnlParentFileReferenceNumber=""
	$UsnJrnlTimestamp=""
	$UsnJrnlReason=""
	$UsnJrnlUsn=""
	$AttributeString=""
	$HDR_BaseRecord=""
	$TextInformation=""
	$RedoChunkSize=""
	$UndoChunkSize=""
	$CurrentTimestamp=""
	$RealMftRef=""
	If $DoSplitCsv Then
		$SI_CTime_Core = ""
		$SI_ATime_Core = ""
		$SI_MTime_Core = ""
		$SI_RTime_Core = ""
		$SI_CTime_Precision = ""
		$SI_ATime_Precision = ""
		$SI_MTime_Precision = ""
		$SI_RTime_Precision = ""
		$FN_CTime_Core = ""
		$FN_ATime_Core = ""
		$FN_MTime_Core = ""
		$FN_RTime_Core = ""
		$FN_CTime_Precision = ""
		$FN_ATime_Precision = ""
		$FN_MTime_Precision = ""
		$FN_RTime_Precision = ""
	EndIf
EndFunc

Func _PrepareOutput()
	$TimestampStart = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC
	$ParserOutDir = @ScriptDir&"\NtfsOutput_"&$TimestampStart
	If DirCreate($ParserOutDir) = 0 Then
		ConsoleWrite("Error creating: " & $ParserOutDir & @CRLF)
		Exit
	EndIf
	ConsoleWrite("Output directory: " & $ParserOutDir & @CRLF)
	$debuglogfile = FileOpen($ParserOutDir & "\debug.log",$EncodingWhenOpen)
	If @error Then
		MsgBox(0,"Error","Could not create debug.log")
		Exit
	EndIf
	$LogFileCsvFile = $ParserOutDir & "\LogFile.csv"
	$LogFileCsv = FileOpen($LogFileCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileCsvFile)
	$LogFileIndxCsvfile = $ParserOutDir & "\LogFile_INDX.csv"
	$LogFileIndxCsv = FileOpen($LogFileIndxCsvfile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileIndxCsvfile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileIndxCsvfile)
	$LogFileUndoWipeIndxCsvfile = $ParserOutDir & "\LogFile_UndoWipe_INDX.csv"
	$LogFileUndoWipeIndxCsv = FileOpen($LogFileUndoWipeIndxCsvfile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileUndoWipeIndxCsvfile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileUndoWipeIndxCsvfile)
	$LogFileUsnJrnlCsvFile = $ParserOutDir & "\LogFile_lfUsnJrnl.csv"
	$LogFileUsnJrnlCsv = FileOpen($LogFileUsnJrnlCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileUsnJrnlCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileUsnJrnlCsvFile)
	If $DoReconstructDataRuns Then
		$LogFileDataRunsCsvfile = $ParserOutDir & "\LogFile_DataRuns.csv"
		$LogFileDataRunsCsv = FileOpen($LogFileDataRunsCsvfile, $EncodingWhenOpen)
		If @error Then
			_DebugOut("Error creating: " & $LogFileDataRunsCsvfile)
			Exit
		EndIf
		_DebugOut("Created output file: " & $LogFileDataRunsCsvfile)
		$LogFileDataRunsModCsvfile = $ParserOutDir & "\LogFile_DataRunsResolved.csv"
		$LogFileDataRunsModCsv = FileOpen($LogFileDataRunsModCsvfile, $EncodingWhenOpen)
		If @error Then
			_DebugOut("Error creating: " & $LogFileDataRunsCsvfile)
			Exit
		EndIf
		_DebugOut("Created output file: " & $LogFileDataRunsModCsvfile)
	EndIf
	$NtfsDbFile = $ParserOutDir & "\ntfs.db"
	_DebugOut("Output DB file: " & $NtfsDbFile)
	$tBuffer = DllStructCreate("byte [1024]")
	$OutFileMFT = $ParserOutDir&"\MFTrecords.bin"
	$hOutFileMFT = _WinAPI_CreateFile("\\.\" & $OutFileMFT,3,6,7)
	If $hOutFileMFT = 0 Then
		_DebugOut("Error: CreateFile returned: " & _WinAPI_GetLastErrorMessage())
		Return
	EndIf
	_DebugOut("Created output file: " & $OutFileMFT)
	If $DoSplitCsv Then
		$csvextra = $ParserOutDir&"\LogFileExtra.csv"
		_DebugOut("Created output file: " & $csvextra)
	EndIf
EndFunc

Func _WriteCSVExtraHeader()
	Local $csv_extra_header
	$csv_extra_header = "lf_LSN"&$de&"SI_CTime_Core"&$de&"SI_CTime_Precision"&$de&"SI_ATime_Core"&$de&"SI_ATime_Precision"&$de&"SI_MTime_Core"&$de&"SI_MTime_Precision"&$de&"SI_RTime_Core"&$de&"SI_RTime_Precision"&$de
	$csv_extra_header &= "FN_CTime_Core"&$de&"FN_CTime_Precision"&$de&"FN_ATime_Core"&$de&"FN_ATime_Precision"&$de&"FN_MTime_Core"&$de&"FN_MTime_Precision"&$de&"FN_RTime_Core"&$de&"FN_RTime_Precision"
	FileWriteLine($csvextra, $csv_extra_header & @CRLF)
EndFunc

Func _WriteCSVHeader()
	$LogFile_Csv_Header = "lf_Offset"&$de&"lf_MFTReference"&$de&"lf_RealMFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_LSN"&$de&"lf_LSNPrevious"&$de&"lf_RedoOperation"&$de&"lf_UndoOperation"&$de&"lf_OffsetInMft"&$de&"lf_FileName"&$de&"lf_CurrentAttribute"&$de&"lf_TextInformation"&$de&"lf_UsnJrnlFileName"&$de&"lf_UsnJrnlMFTReference"&$de&"lf_UsnJrnlMFTParentReference"&$de&"lf_UsnJrnlTimestamp"&$de&"lf_UsnJrnlReason"&$de&"lf_UsnJrnlUsn"&$de&"lf_SI_CTime"&$de&"lf_SI_ATime"&$de&"lf_SI_MTime"&$de&"lf_SI_RTime"&$de&"lf_SI_FilePermission"&$de&"lf_SI_MaxVersions"&$de&"lf_SI_VersionNumber"&$de&"lf_SI_ClassID"&$de&"lf_SI_SecurityID"&$de&"lf_SI_QuotaCharged"&$de&"lf_SI_USN"&$de&"lf_SI_PartialValue"&$de&"lf_FN_CTime"&$de&"lf_FN_ATime"&$de&"lf_FN_MTime"&$de&"lf_FN_RTime"&$de&"lf_FN_AllocSize"&$de&"lf_FN_RealSize"&$de&"lf_FN_Flags"&$de&"lf_FN_Namespace"&$de&"lf_DT_StartVCN"&$de&"lf_DT_LastVCN"&$de&"lf_DT_ComprUnitSize"&$de&"lf_DT_AllocSize"&$de&"lf_DT_RealSize"&$de&"lf_DT_InitStreamSize"&$de&"lf_DT_DataRuns"&$de&"lf_DT_Name"&$de&"lf_FileNameModified"&$de&"lf_RedoChunkSize"&$de&"lf_UndoChunkSize"
	FileWriteLine($LogFileCsv, $LogFile_Csv_Header & @CRLF)
	$LogFile_Indx_Csv_Header = "lf_Offset"&$de&"lf_LSN"&$de&"lf_EntryNumber"&$de&"lf_MFTReference"&$de&"lf_MFTReferenceSeqNo"&$de&"lf_IndexFlags"&$de&"lf_MFTParentReference"&$de&"lf_MFTParentReferenceSeqNo"&$de&"lf_CTime"&$de&"lf_ATime"&$de&"lf_MTime"&$de&"lf_RTime"&$de&"lf_AllocSize"&$de&"lf_RealSize"&$de&"lf_FileFlags"&$de&"lf_FileName"&$de&"lf_FileNameModified"&$de&"lf_NameSpace"&$de&"lf_SubNodeVCN"
	FileWriteLine($LogFileIndxCsv, $LogFile_Indx_Csv_Header & @CRLF)
	$LogFile_UndoWipe_Indx_Csv_Header = "lf_uw_Offset"&$de&"lf_uw_LSN"&$de&"lf_uw_EntryNumber"&$de&"lf_uw_MFTReference"&$de&"lf_uw_MFTReferenceSeqNo"&$de&"lf_uw_IndexFlags"&$de&"lf_uw_MFTParentReference"&$de&"lf_uw_MFTParentReferenceSeqNo"&$de&"lf_uw_CTime"&$de&"lf_uw_ATime"&$de&"lf_uw_MTime"&$de&"lf_uw_RTime"&$de&"lf_uw_AllocSize"&$de&"lf_uw_RealSize"&$de&"lf_uw_FileFlags"&$de&"lf_uw_FileName"&$de&"lf_uw_FileNameModified"&$de&"lf_uw_NameSpace"&$de&"lf_uw_SubNodeVCN"
	FileWriteLine($LogFileUndoWipeIndxCsv, $LogFile_UndoWipe_Indx_Csv_Header & @CRLF)
	$LogFile_DataRuns_Csv_Header = "lf_Offset"&$de&"lf_MFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_FileName"&$de&"lf_LSN"&$de&"lf_RedoOperation"&$de&"lf_UndoOperation"&$de&"lf_OffsetInMft"&$de&"lf_AttributeOffset"&$de&"lf_SI_USN"&$de&"lf_DataName"&$de&"lf_Flags"&$de&"lf_NonResident"&$de&"lf_CompressionUnitSize"&$de&"lf_FileSize"&$de&"lf_InitializedStreamSize"&$de&"lf_OffsetToDataRuns"&$de&"lf_DataRuns"
	FileWriteLine($LogFileDataRunsCsv, $LogFile_DataRuns_Csv_Header & @CRLF)
	$LogFile_DataRunsResolved_Csv_Header = "lf_MFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_FileName"&$de&"lf_LSN"&$de&"lf_OffsetInMft"&$de&"lf_DataName"&$de&"lf_Flags"&$de&"lf_NonResident"&$de&"lf_FileSize"&$de&"lf_InitializedStreamSize"&$de&"lf_DataRuns"
	FileWriteLine($LogFileDataRunsModCsv, $LogFile_DataRunsResolved_Csv_Header & @CRLF)
;	$LogFile_UsnJrnl_Csv_Header = "MFTReference"&$de&"MFTParentReference"&$de&"USN"&$de&"Timestamp"&$de&"Reason"&$de&"SourceInfo"&$de&"FileAttributes"&$de&"FileName"&$de&"FileNameModified"
	$LogFile_UsnJrnl_Csv_Header = "FileName"&$de&"USN"&$de&"Timestamp"&$de&"Reason"&$de&"MFTReference"&$de&"MFTReferenceSeqNo"&$de&"MFTParentReference"&$de&"ParentReferenceSeqNo"&$de&"FileAttributes"
	FileWriteLine($LogFileUsnJrnlCsv, $LogFile_UsnJrnl_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVExtra()
	FileWriteLine($csvextra, $this_lsn & $de & $SI_CTime_Core & $de & $SI_CTime_Precision & $de & $SI_ATime_Core & $de & $SI_ATime_Precision & $de & $SI_MTime_Core & $de & $SI_MTime_Precision & $de & $SI_RTime_Core & $de & $SI_RTime_Precision & $de & _
	$FN_CTime_Core & $de & $FN_CTime_Precision & $de & $FN_ATime_Core & $de & $FN_ATime_Precision & $de & $FN_MTime_Core & $de & $FN_MTime_Precision & $de & $FN_RTime_Core & $de & $FN_RTime_Precision & @CRLF)
EndFunc

Func _WriteLogFileCsv()
	FileWriteLine($LogFileCsv, $RecordOffset & $de & $PredictedRefNumber & $de & $RealMftRef & $de & $HDR_BaseRecord & $de & $this_lsn & $de & $client_previous_lsn & $de & $redo_operation & $de & $undo_operation & $de & $record_offset_in_mft & $de & $FN_Name & $de & $AttributeString & $de & $TextInformation & $de & $UsnJrnlFileName & $de & $UsnJrnlFileReferenceNumber & $de & $UsnJrnlParentFileReferenceNumber & $de & $UsnJrnlTimestamp & $de & $UsnJrnlReason & $de & $UsnJrnlUsn & $de & $SI_CTime & $de & $SI_ATime & $de & $SI_MTime & $de & $SI_RTime & $de & $SI_FilePermission & $de & $SI_MaxVersions & $de & $SI_VersionNumber & $de & $SI_ClassID & $de & $SI_SecurityID & $de & $SI_QuotaCharged & $de & $SI_USN & $de & $SI_PartialValue & $de & $FN_CTime & $de & $FN_ATime & $de & $FN_MTime & $de & $FN_RTime & $de & $FN_AllocSize & $de & $FN_RealSize & $de & $FN_Flags & $de & $FN_NameType & $de & $DT_StartVCN & $de & $DT_LastVCN & $de & $DT_ComprUnitSize & $de & $DT_AllocSize & $de & $DT_RealSize & $de & $DT_InitStreamSize & $de & $DT_DataRuns & $de & $DT_Name & $de & $FileNameModified & $de & $RedoChunkSize & $de & $UndoChunkSize & @crlf)
EndFunc

Func _WriteLogFileDataRunsCsv()
	FileWriteLine($LogFileDataRunsCsv, $RecordOffset & $de & $PredictedRefNumber & $de & $HDR_BaseRecord & $de & $FN_Name & $de & $this_lsn & $de & $redo_operation & $de & $undo_operation & $de & $record_offset_in_mft & $de & $attribute_offset & $de & $SI_USN & $de & $DT_Name & $de & $DT_Flags & $de & $DT_NonResidentFlag & $de & $DT_ComprUnitSize & $de & $DT_RealSize & $de & $DT_InitStreamSize & $de & $DT_OffsetToDataRuns & $de & $DT_DataRuns & @crlf)
EndFunc

Func _Decode_OpenNonresidentAttribute($datachunk)
	Local $Unknown1, $aMFTReference, $aMFTReferenceSeqNo, $aPreviousLsn, $aAttributeHex, $Unknown2
;	ConsoleWrite("OpenNonresidentAttribute: " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$datachunk) & @CRLF)
	If StringLen($datachunk) = 88 Then
		$Unknown1 = _SwapEndian(StringMid($datachunk,9,8))
		$PredictedRefNumber = Dec(_SwapEndian(StringMid($datachunk,17,12)))
		$KeptRef = $PredictedRefNumber
		$aMFTReferenceSeqNo = Dec(_SwapEndian(StringMid($datachunk,29,4)))
		$aPreviousLsn = Dec(_SwapEndian(StringMid($datachunk,33,16)))
		if $client_previous_lsn <> $aPreviousLsn Then
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$client_previous_lsn: " & $client_previous_lsn & @CRLF)
;			ConsoleWrite("$aPreviousLsn: " & $aPreviousLsn & @CRLF)
			$TextInformation &= ";PreviousLsn="&$aPreviousLsn
		EndIf
		$aAttributeHex = StringMid($datachunk,57,4)
		$AttributeString = _ResolveAttributeType($aAttributeHex)
	ElseIf StringLen($datachunk) = 80 Then
		$Unknown1 = _SwapEndian(StringMid($datachunk,9,8))
		$aAttributeHex = StringMid($datachunk,17,4)
		$AttributeString = _ResolveAttributeType($aAttributeHex)
		$PredictedRefNumber = Dec(_SwapEndian(StringMid($datachunk,33,12)))
		$KeptRef = $PredictedRefNumber
		$aMFTReferenceSeqNo = Dec(_SwapEndian(StringMid($datachunk,45,4)))
		$aPreviousLsn = Dec(_SwapEndian(StringMid($datachunk,49,16)))
		$Unknown2 = _SwapEndian(StringMid($datachunk,65,16))
		if $client_previous_lsn <> $aPreviousLsn Then
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$client_previous_lsn: " & $client_previous_lsn & @CRLF)
;			ConsoleWrite("$aPreviousLsn: " & $aPreviousLsn & @CRLF)
			$TextInformation &= ";PreviousLsn="&$aPreviousLsn
		EndIf

	Else
		ConsoleWrite("Unresolved OpenNonresidentAttribute for LSN: " & $this_lsn & @CRLF)
		ConsoleWrite(_HexEncode("0x"&$datachunk) & @CRLF)
	EndIf
	If $VerboseOn Then
		ConsoleWrite("$Unknown1: " & $Unknown1 & @CRLF)
		ConsoleWrite("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
		ConsoleWrite("$aMFTReferenceSeqNo: " & $aMFTReferenceSeqNo & @CRLF)
		ConsoleWrite("$aPreviousLsn: " & $aPreviousLsn & @CRLF)
		ConsoleWrite("$aAttributeHex: " & $aAttributeHex & @CRLF)
		ConsoleWrite("$AttributeString: " & $AttributeString & @CRLF)
		ConsoleWrite("$Unknown2: " & $Unknown2 & @CRLF)
	EndIf
EndFunc

Func _ResolveAttributeType($input)
	Select
		Case $input = "1000"
			Return "$STANDARD_INFORMATION"
		Case $input = "2000"
			Return "$ATTRIBUTE_LIST"
		Case $input = "3000"
			Return "$FILE_NAME"
		Case $input = "4000"
			Return "$OBJECT_ID"
		Case $input = "5000"
			Return "$SECURITY_DESCRIPTOR"
		Case $input = "6000"
			Return "$VOLUME_NAME"
		Case $input = "7000"
			Return "$VOLUME_INFORMATION"
		Case $input = "8000"
			Return "$DATA"
		Case $input = "9000"
			Return "$INDEX_ROOT"
		Case $input = "a000"
			Return "$INDEX_ALLOCATION"
		Case $input = "b000"
			Return "$BITMAP"
		Case $input = "c000"
			Return "$REPARSE_POINT"
		Case $input = "d000"
			Return "$EA_INFORMATION"
		Case $input = "e000"
			Return "$EA"
		Case $input = "0001"
			Return "$LOGGED_UTILITY_STREAM"
		Case Else
			Return "UNKNOWN"
	EndSelect
EndFunc

Func _Decode_SetBitsInNonresidentBitMap($data,$prepend)
	Local $Unknown1, $Unknown2
	$Unknown1 = _SwapEndian(StringMid($data,1,8))
	$Unknown2 = _SwapEndian(StringMid($data,9,8))
	$TextInformation &= $prepend&"SetBits="&$Unknown1&"->"&$Unknown2
EndFunc

Func _Decode_ClearBitsInNonresidentBitMap($data,$prepend)
	Local $Unknown1, $Unknown2
	$Unknown1 = _SwapEndian(StringMid($data,1,8))
	$Unknown2 = _SwapEndian(StringMid($data,9,8))
	$TextInformation &= $prepend&"ClearBits="&$Unknown1&"->"&$Unknown2
EndFunc

Func _Decode_SetIndexEntryVcnAllocation($data)
	Local $Unknown1, $Unknown2
	$Unknown1 = Dec(_SwapEndian(StringMid($data,1,8)))
	$Unknown2 = Dec(_SwapEndian(StringMid($data,9,8)))
	$TextInformation &= ";IndexEntryVcnAllocation="&$Unknown1
	$AttributeString = "$INDEX_ALLOCATION"
EndFunc

Func _InjectTimeZoneInfo()
$Regions = "UTC: -12.00|" & _
	"UTC: -11.00|" & _
	"UTC: -10.00|" & _
	"UTC: -9.30|" & _
	"UTC: -9.00|" & _
	"UTC: -8.00|" & _
	"UTC: -7.00|" & _
	"UTC: -6.00|" & _
	"UTC: -5.00|" & _
	"UTC: -4.30|" & _
	"UTC: -4.00|" & _
	"UTC: -3.30|" & _
	"UTC: -3.00|" & _
	"UTC: -2.00|" & _
	"UTC: -1.00|" & _
	"UTC: 0.00|" & _
	"UTC: 1.00|" & _
	"UTC: 2.00|" & _
	"UTC: 3.00|" & _
	"UTC: 3.30|" & _
	"UTC: 4.00|" & _
	"UTC: 4.30|" & _
	"UTC: 5.00|" & _
	"UTC: 5.30|" & _
	"UTC: 5.45|" & _
	"UTC: 6.00|" & _
	"UTC: 6.30|" & _
	"UTC: 7.00|" & _
	"UTC: 8.00|" & _
	"UTC: 8.45|" & _
	"UTC: 9.00|" & _
	"UTC: 9.30|" & _
	"UTC: 10.00|" & _
	"UTC: 10.30|" & _
	"UTC: 11.00|" & _
	"UTC: 11.30|" & _
	"UTC: 12.00|" & _
	"UTC: 12.45|" & _
	"UTC: 13.00|" & _
	"UTC: 14.00|"
GUICtrlSetData($Combo2,$Regions,"UTC: 0.00")
EndFunc

Func _GetUTCRegion()
	$UTCRegion = GUICtrlRead($Combo2)
	If $UTCRegion = "" Then Return SetError(1,0,0)
	$part1 = StringMid($UTCRegion,StringInStr($UTCRegion," ")+1)
	Global $UTCconfig = $part1
	If StringRight($part1,2) = "15" Then $part1 = StringReplace($part1,".15",".25")
	If StringRight($part1,2) = "30" Then $part1 = StringReplace($part1,".30",".50")
	If StringRight($part1,2) = "45" Then $part1 = StringReplace($part1,".45",".75")
	$DeltaTest = $part1*36000000000
	Return $DeltaTest
EndFunc

Func _TranslateSeparator()
	; Or do it the other way around to allow setting other trickier separators, like specifying it in hex
	GUICtrlSetData($SaparatorInput,StringLeft(GUICtrlRead($SaparatorInput),1))
	GUICtrlSetData($SaparatorInput2,"0x"&Hex(Asc(GUICtrlRead($SaparatorInput)),2))
EndFunc

Func _InjectTimestampFormat()
Local $Formats = "1|" & _
	"2|" & _
	"3|" & _
	"4|" & _
	"5|" & _
	"6|"
	GUICtrlSetData($ComboTimestampFormat,$Formats,"6")
EndFunc

Func _InjectTimestampPrecision()
Local $Precision = "None|" & _
	"MilliSec|" & _
	"NanoSec|"
	GUICtrlSetData($ComboTimestampPrecision,$Precision,"NanoSec")
EndFunc

Func _TranslateTimestamp()
	Local $lPrecision,$lTimestamp,$lTimestampTmp
	$DateTimeFormat = StringLeft(GUICtrlRead($ComboTimestampFormat),1)
	$lPrecision = GUICtrlRead($ComboTimestampPrecision)
	Select
		Case $lPrecision = "None"
			$TimestampPrecision = 1
		Case $lPrecision = "MilliSec"
			$TimestampPrecision = 2
		Case $lPrecision = "NanoSec"
			$TimestampPrecision = 3
	EndSelect
	$lTimestampTmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ExampleTimestampVal)
	$lTimestamp = _WinTime_UTCFileTimeFormat(Dec($ExampleTimestampVal,2), $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$lTimestamp = "-"
	ElseIf $TimestampPrecision = 3 Then
		$lTimestamp = $lTimestamp & ":" & _FillZero(StringRight($lTimestampTmp, 4))
	EndIf
	GUICtrlSetData($InputExampleTimestamp,$lTimestamp)
EndFunc

Func _DisplayInfo($DebugInfo)
	GUICtrlSetData($myctredit, $DebugInfo, 1)
EndFunc

Func _SelectLogFile()
	$InputLogFile = FileOpenDialog("Select $LogFile",@ScriptDir,"All (*.*)")
	If @error Then Return
;	_DisplayInfo("Selected $LogFile: " & $InputLogFile & @CRLF)
	GUICtrlSetData($LogFileField,$InputLogFile)
EndFunc

Func _SelectUsnJrnl()
	$UsnJrnlFile = FileOpenDialog("Select $UsnJrnl",@ScriptDir,"All (*.*)")
	If @error Then
		_DisplayInfo("Error getting $UsnJrnl: " & $UsnJrnlFile & @CRLF)
		GUICtrlSetData($UsnJrnlField,"Error getting $UsnJrnl")
	Else
;		_DisplayInfo("Selected $UsnJrnl: " & $UsnJrnlFile & @CRLF)
		GUICtrlSetData($UsnJrnlField,$UsnJrnlFile)
	EndIf
EndFunc

Func _SelectMftCsv()
	$TargetMftCsvFile = FileOpenDialog("Select MFT csv file",@ScriptDir,"All (*.*)")
	If @error then Return
;	_DisplayInfo("Selected MFT csv file: " & $TargetMftCsvFile & @CRLF)
	GUICtrlSetData($MFTField,$TargetMftCsvFile)
EndFunc

Func _LogFileProgress()
    GUICtrlSetData($ProgressStatus, "Processing LogFile transaction " & $CurrentRecord & " of " & $MaxRecords)
    GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($ProgressLogFile, 100 * $CurrentRecord / $MaxRecords)
EndFunc

Func _UsnJrnlProgress()
    GUICtrlSetData($ProgressStatus, "Processing UsnJrnl record " & $CurrentRecord & " of " & $MaxRecords)
    GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($ProgressUsnJrnl, 100 * $CurrentRecord / $MaxRecords)
EndFunc

Func _DataRunReconstructProgress()
    GUICtrlSetData($ProgressStatus, "Reconstructing dataruns at row " & $RowsProcessed & " of " & $MaxRows)
    GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($ProgressReconstruct, 100 * $RowsProcessed / $MaxRows)
EndFunc

Func _DebugOut($text, $var="")
   If $var Then $var = _HexEncode($var) & @CRLF
   $text &= @CRLF & $var
   ConsoleWrite($text)
   If $debuglogfile Then FileWrite($debuglogfile, $text)
EndFunc

Func _Decode_UndoWipeINDX($Entry)
	If $VerboseOn Then ConsoleWrite("### Undo wipe of INDX record decoder ###" & @CRLF)
	Local $IndxEntryNumberArr[1],$IndxMFTReferenceArr[1],$IndxMFTRefSeqNoArr[1],$IndxIndexFlagsArr[1],$IndxMFTReferenceOfParentArr[1],$IndxMFTParentRefSeqNoArr[1],$IndxCTimeArr[1],$IndxATimeArr[1],$IndxMTimeArr[1],$IndxRTimeArr[1],$IndxAllocSizeArr[1],$IndxRealSizeArr[1],$IndxFileFlagsArr[1],$IndxFileNameArr[1],$IndxSubNodeVCNArr[1],$IndxNameSpaceArr[1],$IndxFilenameModified[1]
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$EntryCounter=1,$Padding2,$EntryCounter=1,$DecodeOk=False
	Local $Indx_CTime_Core,$Indx_CTime_Precision,$Indx_ATime_Core,$Indx_ATime_Precision,$Indx_MTime_Core,$Indx_MTime_Precision,$Indx_RTime_Core,$Indx_RTime_Precision
	$NewLocalAttributeOffset = 1
;	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+56,8)),2)
;	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+48,8)),2)
;	$NewLocalAttributeOffset = $NewLocalAttributeOffset+48+($IndxHeaderSize*2)
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
	$MFTReference = Dec($MFTReference)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,3,2))
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,3,2))
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,3,2))
	;
	$Indx_CTime = StringMid($Entry, $NewLocalAttributeOffset + 48, 16)
	$Indx_CTime = _SwapEndian($Indx_CTime)
	$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
	$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_CTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-4)
		$Indx_CTime_Precision = StringRight($Indx_CTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp, 4))
		$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-9)
		$Indx_CTime_Precision = StringRight($Indx_CTime,8)
	Else
		$Indx_CTime_Core = $Indx_CTime
	EndIf
	;
	$Indx_ATime = StringMid($Entry, $NewLocalAttributeOffset + 64, 16)
	$Indx_ATime = _SwapEndian($Indx_ATime)
	$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
	$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_ATime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-4)
		$Indx_ATime_Precision = StringRight($Indx_ATime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp, 4))
		$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-9)
		$Indx_ATime_Precision = StringRight($Indx_ATime,8)
	Else
		$Indx_ATime_Core = $Indx_ATime
	EndIf
	;
	$Indx_MTime = StringMid($Entry, $NewLocalAttributeOffset + 80, 16)
	$Indx_MTime = _SwapEndian($Indx_MTime)
	$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
	$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_MTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-4)
		$Indx_MTime_Precision = StringRight($Indx_MTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp, 4))
		$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-9)
		$Indx_MTime_Precision = StringRight($Indx_MTime,8)
	Else
		$Indx_MTime_Core = $Indx_MTime
	EndIf
	;
	$Indx_RTime = StringMid($Entry, $NewLocalAttributeOffset + 96, 16)
	$Indx_RTime = _SwapEndian($Indx_RTime)
	$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
	$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$Indx_RTime = "-"
	ElseIf $TimestampPrecision = 2 Then
		$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-4)
		$Indx_RTime_Precision = StringRight($Indx_RTime,3)
	ElseIf $TimestampPrecision = 3 Then
		$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp, 4))
		$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-9)
		$Indx_RTime_Precision = StringRight($Indx_RTime,8)
	Else
		$Indx_RTime_Core = $Indx_RTime
	EndIf
	;
	$Indx_AllocSize = StringMid($Entry,$NewLocalAttributeOffset+112,16)
	$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,16)
	$Indx_File_Flags = StringMid($Indx_File_Flags,15,2) & StringMid($Indx_File_Flags,13,2) & StringMid($Indx_File_Flags,11,2) & StringMid($Indx_File_Flags,9,2)&StringMid($Indx_File_Flags,7,2) & StringMid($Indx_File_Flags,5,2) & StringMid($Indx_File_Flags,3,2) & StringMid($Indx_File_Flags,1,2)
	$Indx_File_Flags = StringMid($Indx_File_Flags,13,8)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_NameLength = StringMid($Entry,$NewLocalAttributeOffset+160,2)
	$Indx_NameLength = Dec($Indx_NameLength)
	$Indx_NameSpace = StringMid($Entry,$NewLocalAttributeOffset+162,2)
	Select
		Case $Indx_NameSpace = "00"	;POSIX
			$Indx_NameSpace = "POSIX"
		Case $Indx_NameSpace = "01"	;WIN32
			$Indx_NameSpace = "WIN32"
		Case $Indx_NameSpace = "02"	;DOS
			$Indx_NameSpace = "DOS"
		Case $Indx_NameSpace = "03"	;DOS+WIN32
			$Indx_NameSpace = "DOS+WIN32"
	EndSelect
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*2*2)
	$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
	$Indx_FileName = StringReplace($Indx_FileName,$de,$CharReplacement)
	$FileNameModified = @extended
	$tmp1 = 164+($Indx_NameLength*2*2)
	Do ; Calculate the length of the padding - 8 byte aligned
		$tmp2 = $tmp1/16
		If Not IsInt($tmp2) Then
			$tmp0 = 2
			$tmp1 += $tmp0
			$tmp3 += $tmp0
		EndIf
	Until IsInt($tmp2)
	$PaddingLength = $tmp3
;	$Padding2 = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2),$PaddingLength)
	If $IndexFlags <> "0000" Then
		$SubNodeVCN = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
		$SubNodeVCNLength = 16
	Else
		$SubNodeVCN = ""
		$SubNodeVCNLength = 0
	EndIf
	ReDim $IndxEntryNumberArr[1+$EntryCounter]
	ReDim $IndxMFTReferenceArr[1+$EntryCounter]
	ReDim $IndxMFTRefSeqNoArr[1+$EntryCounter]
	ReDim $IndxIndexFlagsArr[1+$EntryCounter]
	ReDim $IndxMFTReferenceOfParentArr[1+$EntryCounter]
	ReDim $IndxMFTParentRefSeqNoArr[1+$EntryCounter]
	ReDim $IndxCTimeArr[1+$EntryCounter]
	ReDim $IndxATimeArr[1+$EntryCounter]
	ReDim $IndxMTimeArr[1+$EntryCounter]
	ReDim $IndxRTimeArr[1+$EntryCounter]
	ReDim $IndxAllocSizeArr[1+$EntryCounter]
	ReDim $IndxRealSizeArr[1+$EntryCounter]
	ReDim $IndxFileFlagsArr[1+$EntryCounter]
	ReDim $IndxFileNameArr[1+$EntryCounter]
	ReDim $IndxNameSpaceArr[1+$EntryCounter]
	ReDim $IndxSubNodeVCNArr[1+$EntryCounter]
	ReDim $IndxFilenameModified[1+$EntryCounter]
	$IndxEntryNumberArr[$EntryCounter] = $EntryCounter
	$IndxMFTReferenceArr[$EntryCounter] = $MFTReference
	$IndxMFTRefSeqNoArr[$EntryCounter] = $MFTReferenceSeqNo
	$IndxIndexFlagsArr[$EntryCounter] = $IndexFlags
	$IndxMFTReferenceOfParentArr[$EntryCounter] = $MFTReferenceOfParent
	$IndxMFTParentRefSeqNoArr[$EntryCounter] = $MFTReferenceOfParentSeqNo
	$IndxCTimeArr[$EntryCounter] = $Indx_CTime
	$IndxATimeArr[$EntryCounter] = $Indx_ATime
	$IndxMTimeArr[$EntryCounter] = $Indx_MTime
	$IndxRTimeArr[$EntryCounter] = $Indx_RTime
	$IndxAllocSizeArr[$EntryCounter] = $Indx_AllocSize
	$IndxRealSizeArr[$EntryCounter] = $Indx_RealSize
	$IndxFileFlagsArr[$EntryCounter] = $Indx_File_Flags
	$IndxFileNameArr[$EntryCounter] = $Indx_FileName
	$IndxNameSpaceArr[$EntryCounter] = $Indx_NameSpace
	$IndxSubNodeVCNArr[$EntryCounter] = $SubNodeVCN
	$IndxFilenameModified[$EntryCounter] = $FileNameModified
;	FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
	If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
		$DecodeOk=True
		FileWriteLine($LogFileUndoWipeIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		$PredictedRefNumber = $MFTReferenceOfParent
		$KeptRef = $MFTReferenceOfParent
		$AttributeString = "$INDEX_ALLOCATION"
	EndIf
; Work through the rest of the index entries
	$NextEntryOffset = $NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
	If $NextEntryOffset+64 >= StringLen($Entry) Then Return $DecodeOk
	Do
		$EntryCounter += 1
		$MFTReference = StringMid($Entry,$NextEntryOffset,12)
		$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
		$MFTReference = Dec($MFTReference)
		$MFTReferenceSeqNo = StringMid($Entry,$NextEntryOffset+12,4)
		$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
		$IndexEntryLength = StringMid($Entry,$NextEntryOffset+16,4)
		$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,3,2))
		$OffsetToFileName = StringMid($Entry,$NextEntryOffset+20,4)
		$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,3,2))
		$IndexFlags = StringMid($Entry,$NextEntryOffset+24,4)
		$Padding = StringMid($Entry,$NextEntryOffset+28,4)
		$MFTReferenceOfParent = StringMid($Entry,$NextEntryOffset+32,12)
		$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
		$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
		$MFTReferenceOfParentSeqNo = StringMid($Entry,$NextEntryOffset+44,4)
		$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,3,2))

		$Indx_CTime = StringMid($Entry, $NextEntryOffset + 48, 16)
		$Indx_CTime = _SwapEndian($Indx_CTime)
		$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
		$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_CTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-4)
			$Indx_CTime_Precision = StringRight($Indx_CTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp, 4))
			$Indx_CTime_Core = StringMid($Indx_CTime,1,StringLen($Indx_CTime)-9)
			$Indx_CTime_Precision = StringRight($Indx_CTime,8)
		Else
			$Indx_CTime_Core = $Indx_CTime
		EndIf
		;
		$Indx_ATime = StringMid($Entry, $NextEntryOffset + 64, 16)
		$Indx_ATime = _SwapEndian($Indx_ATime)
		$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
		$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_ATime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-4)
			$Indx_ATime_Precision = StringRight($Indx_ATime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp, 4))
			$Indx_ATime_Core = StringMid($Indx_ATime,1,StringLen($Indx_ATime)-9)
			$Indx_ATime_Precision = StringRight($Indx_ATime,8)
		Else
			$Indx_ATime_Core = $Indx_ATime
		EndIf
		;
		$Indx_MTime = StringMid($Entry, $NextEntryOffset + 80, 16)
		$Indx_MTime = _SwapEndian($Indx_MTime)
		$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
		$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_MTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-4)
			$Indx_MTime_Precision = StringRight($Indx_MTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp, 4))
			$Indx_MTime_Core = StringMid($Indx_MTime,1,StringLen($Indx_MTime)-9)
			$Indx_MTime_Precision = StringRight($Indx_MTime,8)
		Else
			$Indx_MTime_Core = $Indx_MTime
		EndIf
		;
		$Indx_RTime = StringMid($Entry, $NextEntryOffset + 96, 16)
		$Indx_RTime = _SwapEndian($Indx_RTime)
		$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
		$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$Indx_RTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-4)
			$Indx_RTime_Precision = StringRight($Indx_RTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp, 4))
			$Indx_RTime_Core = StringMid($Indx_RTime,1,StringLen($Indx_RTime)-9)
			$Indx_RTime_Precision = StringRight($Indx_RTime,8)
		Else
			$Indx_RTime_Core = $Indx_RTime
		EndIf
		;
		$Indx_AllocSize = StringMid($Entry,$NextEntryOffset+112,16)
		$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
		$Indx_RealSize = StringMid($Entry,$NextEntryOffset+128,16)
		$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
		$Indx_File_Flags = StringMid($Entry,$NextEntryOffset+144,16)
		$Indx_File_Flags = StringMid($Indx_File_Flags,15,2) & StringMid($Indx_File_Flags,13,2) & StringMid($Indx_File_Flags,11,2) & StringMid($Indx_File_Flags,9,2)&StringMid($Indx_File_Flags,7,2) & StringMid($Indx_File_Flags,5,2) & StringMid($Indx_File_Flags,3,2) & StringMid($Indx_File_Flags,1,2)
		$Indx_File_Flags = StringMid($Indx_File_Flags,13,8)
		$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
		$Indx_NameLength = StringMid($Entry,$NextEntryOffset+160,2)
		$Indx_NameLength = Dec($Indx_NameLength)
		$Indx_NameSpace = StringMid($Entry,$NextEntryOffset+162,2)
		Select
			Case $Indx_NameSpace = "00"	;POSIX
				$Indx_NameSpace = "POSIX"
			Case $Indx_NameSpace = "01"	;WIN32
				$Indx_NameSpace = "WIN32"
			Case $Indx_NameSpace = "02"	;DOS
				$Indx_NameSpace = "DOS"
			Case $Indx_NameSpace = "03"	;DOS+WIN32
				$Indx_NameSpace = "DOS+WIN32"
		EndSelect
		$Indx_FileName = StringMid($Entry,$NextEntryOffset+164,$Indx_NameLength*2*2)
		$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
		$Indx_FileName = StringReplace($Indx_FileName,$de,$CharReplacement)
		$FileNameModified = @extended
		$tmp0 = 0
		$tmp2 = 0
		$tmp3 = 0
		$tmp1 = 164+($Indx_NameLength*2*2)
		Do ; Calculate the length of the padding - 8 byte aligned
			$tmp2 = $tmp1/16
			If Not IsInt($tmp2) Then
				$tmp0 = 2
				$tmp1 += $tmp0
				$tmp3 += $tmp0
			EndIf
		Until IsInt($tmp2)
		$PaddingLength = $tmp3
;		$Padding = StringMid($Entry,$NextEntryOffset+164+($Indx_NameLength*2*2),$PaddingLength)
		If $IndexFlags <> "0000" Then
			$SubNodeVCN = StringMid($Entry,$NextEntryOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
			$SubNodeVCNLength = 16
		Else
			$SubNodeVCN = ""
			$SubNodeVCNLength = 0
		EndIf
		$NextEntryOffset = $NextEntryOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
		ReDim $IndxEntryNumberArr[1+$EntryCounter]
		ReDim $IndxMFTReferenceArr[1+$EntryCounter]
		Redim $IndxMFTRefSeqNoArr[1+$EntryCounter]
		ReDim $IndxIndexFlagsArr[1+$EntryCounter]
		ReDim $IndxMFTReferenceOfParentArr[1+$EntryCounter]
		ReDim $IndxMFTParentRefSeqNoArr[1+$EntryCounter]
		ReDim $IndxCTimeArr[1+$EntryCounter]
		ReDim $IndxATimeArr[1+$EntryCounter]
		ReDim $IndxMTimeArr[1+$EntryCounter]
		ReDim $IndxRTimeArr[1+$EntryCounter]
		ReDim $IndxAllocSizeArr[1+$EntryCounter]
		ReDim $IndxRealSizeArr[1+$EntryCounter]
		ReDim $IndxFileFlagsArr[1+$EntryCounter]
		ReDim $IndxFileNameArr[1+$EntryCounter]
		ReDim $IndxNameSpaceArr[1+$EntryCounter]
		ReDim $IndxSubNodeVCNArr[1+$EntryCounter]
		ReDim $IndxFilenameModified[1+$EntryCounter]
		$IndxEntryNumberArr[$EntryCounter] = $EntryCounter
		$IndxMFTReferenceArr[$EntryCounter] = $MFTReference
		$IndxMFTRefSeqNoArr[$EntryCounter] = $MFTReferenceSeqNo
		$IndxIndexFlagsArr[$EntryCounter] = $IndexFlags
		$IndxMFTReferenceOfParentArr[$EntryCounter] = $MFTReferenceOfParent
		$IndxMFTParentRefSeqNoArr[$EntryCounter] = $MFTReferenceOfParentSeqNo
		$IndxCTimeArr[$EntryCounter] = $Indx_CTime
		$IndxATimeArr[$EntryCounter] = $Indx_ATime
		$IndxMTimeArr[$EntryCounter] = $Indx_MTime
		$IndxRTimeArr[$EntryCounter] = $Indx_RTime
		$IndxAllocSizeArr[$EntryCounter] = $Indx_AllocSize
		$IndxRealSizeArr[$EntryCounter] = $Indx_RealSize
		$IndxFileFlagsArr[$EntryCounter] = $Indx_File_Flags
		$IndxFileNameArr[$EntryCounter] = $Indx_FileName
		$IndxNameSpaceArr[$EntryCounter] = $Indx_NameSpace
		$IndxSubNodeVCNArr[$EntryCounter] = $SubNodeVCN
		$IndxFilenameModified[$EntryCounter] = $FileNameModified
;		FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
			$DecodeOk=True
			FileWriteLine($LogFileUndoWipeIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
			$PredictedRefNumber = $MFTReferenceOfParent
			$KeptRef = $MFTReferenceOfParent
			$AttributeString = "$INDEX_ALLOCATION"
		EndIf
;		_ArrayDisplay($IndxMFTReferenceOfParentArr,"$IndxMFTReferenceOfParentArr")
	Until $NextEntryOffset+32 >= StringLen($Entry)
;	_ArrayDisplay($IndxMFTReferenceOfParentArr,"$IndxMFTReferenceOfParentArr")
	Return $DecodeOk
EndFunc

Func _UsnDecodeRecord2($Record)
	Local $UsnJrnlRecordLength,$UsnJrnlMajorVersion,$UsnJrnlMFTReferenceSeqNo,$UsnJrnlParentReferenceSeqNo
	Local $UsnJrnlSourceInfo,$UsnJrnlSecurityId,$UsnJrnlFileAttributes,$UsnJrnlFileNameLength,$UsnJrnlFileNameOffset,$DecodeOk=False
	$UsnJrnlRecordLength = StringMid($Record,1,8)
	$UsnJrnlRecordLength = Dec(_SwapEndian($UsnJrnlRecordLength),2)
;	$UsnJrnlMajorVersion = StringMid($Record,9,4)
;	$UsnJrnlMinorVersion = StringMid($Record,13,4)
	$UsnJrnlFileReferenceNumber = StringMid($Record,17,12)
	$UsnJrnlFileReferenceNumber = Dec(_SwapEndian($UsnJrnlFileReferenceNumber),2)
	$UsnJrnlMFTReferenceSeqNo = StringMid($Record,29,4)
	$UsnJrnlMFTReferenceSeqNo = Dec(_SwapEndian($UsnJrnlMFTReferenceSeqNo),2)
	$UsnJrnlParentFileReferenceNumber = StringMid($Record,33,12)
	$UsnJrnlParentFileReferenceNumber = Dec(_SwapEndian($UsnJrnlParentFileReferenceNumber),2)
	$UsnJrnlParentReferenceSeqNo = StringMid($Record,45,4)
	$UsnJrnlParentReferenceSeqNo = Dec(_SwapEndian($UsnJrnlParentReferenceSeqNo),2)
	$UsnJrnlUsn = StringMid($Record,49,16)
	$UsnJrnlUsn = Dec(_SwapEndian($UsnJrnlUsn),2)
	$UsnJrnlTimestamp = StringMid($Record,65,16)
	$UsnJrnlTimestamp = _DecodeTimestamp($UsnJrnlTimestamp)
	$UsnJrnlReason = StringMid($Record,81,8)
	$UsnJrnlReason = _DecodeReasonCodes("0x"&_SwapEndian($UsnJrnlReason))
;	$UsnJrnlSourceInfo = StringMid($Record,89,8)
;	$UsnJrnlSourceInfo = _DecodeSourceInfoFlag("0x"&_SwapEndian($UsnJrnlSourceInfo))
;	$UsnJrnlSourceInfo = "0x"&_SwapEndian($UsnJrnlSourceInfo)
;	$UsnJrnlSecurityId = StringMid($Record,97,8)
	$UsnJrnlFileAttributes = StringMid($Record,105,8)
	$UsnJrnlFileAttributes = _File_Attributes("0x"&_SwapEndian($UsnJrnlFileAttributes))
	$UsnJrnlFileNameLength = StringMid($Record,113,4)
	$UsnJrnlFileNameLength = Dec(_SwapEndian($UsnJrnlFileNameLength),2)
	$UsnJrnlFileNameOffset = StringMid($Record,117,4)
	$UsnJrnlFileNameOffset = Dec(_SwapEndian($UsnJrnlFileNameOffset),2)
	$UsnJrnlFileName = StringMid($Record,121,$UsnJrnlFileNameLength*2)
	$UsnJrnlFileName = _UnicodeHexToStr($UsnJrnlFileName)
	If $VerboseOn Then
		ConsoleWrite("$UsnJrnlFileReferenceNumber: " & $UsnJrnlFileReferenceNumber & @CRLF)
		ConsoleWrite("$UsnJrnlMFTReferenceSeqNo: " & $UsnJrnlMFTReferenceSeqNo & @CRLF)
		ConsoleWrite("$UsnJrnlParentFileReferenceNumber: " & $UsnJrnlParentFileReferenceNumber & @CRLF)
		ConsoleWrite("$UsnJrnlParentReferenceSeqNo: " & $UsnJrnlParentReferenceSeqNo & @CRLF)
		ConsoleWrite("$UsnJrnlUsn: " & $UsnJrnlUsn & @CRLF)
		ConsoleWrite("$UsnJrnlTimestamp: " & $UsnJrnlTimestamp & @CRLF)
		ConsoleWrite("$UsnJrnlReason: " & $UsnJrnlReason & @CRLF)
;		ConsoleWrite("$UsnJrnlSourceInfo: " & $UsnJrnlSourceInfo & @CRLF)
;		ConsoleWrite("$UsnJrnlSecurityId: " & $UsnJrnlSecurityId & @CRLF)
		ConsoleWrite("$UsnJrnlFileAttributes: " & $UsnJrnlFileAttributes & @CRLF)
		ConsoleWrite("$UsnJrnlFileName: " & $UsnJrnlFileName & @CRLF)
	EndIf
	If Int($UsnJrnlFileReferenceNumber) > 0 And Int($UsnJrnlMFTReferenceSeqNo) > 0 And Int($UsnJrnlParentFileReferenceNumber) > 4 And $UsnJrnlFileNameLength > 0  And $UsnJrnlTimestamp<>"-" And StringInStr($UsnJrnlTimestamp,"1601")=0 Then
		$DecodeOk=True
		FileWriteLine($LogFileUsnJrnlCsv, $UsnJrnlFileName&$de&$UsnJrnlUsn&$de&$UsnJrnlTimestamp&$de&$UsnJrnlReason&$de&$UsnJrnlFileReferenceNumber&$de&$UsnJrnlMFTReferenceSeqNo&$de&$UsnJrnlParentFileReferenceNumber&$de&$UsnJrnlParentReferenceSeqNo&$de&$UsnJrnlFileAttributes&@crlf)
		$RealMftRef = $PredictedRefNumber
		$UsnJrnlRef = $PredictedRefNumber
		$PredictedRefNumber = $UsnJrnlFileReferenceNumber
		$KeptRef = $UsnJrnlFileReferenceNumber
		$FN_Name = $UsnJrnlFileName
		$AttributeString = "$DATA:$J"
	Else
		$UsnJrnlFileReferenceNumber=""
		$UsnJrnlParentFileReferenceNumber=""
		$UsnJrnlTimestamp=""
		$UsnJrnlReason=""
		$UsnJrnlFileName=""
	EndIf
	Return $DecodeOk
EndFunc

Func _Decode_AttributeName($data)
	$AttributeString &= ":"&_UnicodeHexToStr($data)
EndFunc

Func _SetNameOnSystemFiles()
	Select
		Case $PredictedRefNumber = 0
			$FN_Name = "$MFT"
		Case $PredictedRefNumber = 1
			$FN_Name = "$MFTMirr"
		Case $PredictedRefNumber = 2
			$FN_Name = "$LogFile"
		Case $PredictedRefNumber = 3
			$FN_Name = "$Volume"
		Case $PredictedRefNumber = 4
			$FN_Name = "$AttrDef"
		Case $PredictedRefNumber = 5
			$FN_Name = "."
		Case $PredictedRefNumber = 6
			$FN_Name = "$Bitmap"
		Case $PredictedRefNumber = 7
			$FN_Name = "$Boot"
		Case $PredictedRefNumber = 8
			$FN_Name = "$BadClus"
		Case $PredictedRefNumber = 9
			$FN_Name = "$Secure"
		Case $PredictedRefNumber = 10
			$FN_Name = "$UpCase"
		Case $PredictedRefNumber = 11
			$FN_Name = "$Extend"
	EndSelect
EndFunc

Func _RemoveSingleOffsetOfAttribute($TestRef, $TestOffsetAttr, $TestSize, $TestString)
	Local $RefIndex,$Replaced,$AttrArraySplit,$check=0,$ConcatString
	If $VerboseOn Then
		ConsoleWrite("_RemoveSingleOffsetOfAttribute()" & @CRLF)
		ConsoleWrite("$TestOffsetAttr: " & $TestOffsetAttr & @CRLF)
		ConsoleWrite("$TestSize: " & $TestSize & @CRLF)
		ConsoleWrite("$TestString: " & $TestString & @CRLF)
	EndIf
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
;		ConsoleWrite("Ref already exist in array" & @CRLF)
		$AttrArraySplit = StringSplit($AttrArray[$RefIndex][1], ',')
		For $i = 1 To $AttrArraySplit[0]-1
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			$TestOffset2 = StringInStr($AttrArraySplit[$i], '?')
			$FoundAttr = StringMid($AttrArraySplit[$i], 1, $TestOffset2-1)
			$FoundOffset = StringMid($AttrArraySplit[$i], $TestOffset2+1)
			If $VerboseOn Then
				ConsoleWrite("$AttrArraySplit[$i]: " & $AttrArraySplit[$i] & @CRLF)
				ConsoleWrite("$TestOffset2: " & $TestOffset2 & @CRLF)
				ConsoleWrite("$FoundAttr: " & $FoundAttr & @CRLF)
				ConsoleWrite("$FoundOffset: " & $FoundOffset & @CRLF)
			EndIf
			$TestOffset = StringInStr($AttrArraySplit[$i], $TestOffsetAttr)
			If $TestOffset Then
				ConsoleWrite("Found offset: " & $TestOffset & @CRLF)
				$check=1
			EndIf
;			If Not $check Then ContinueLoop
			If Not StringIsDigit($FoundOffset) Then MsgBox(0,"Not number:",$FoundOffset)
			If Int($TestOffsetAttr) > Int($FoundOffset) Then ContinueLoop
			If $TestOffset Then
				$AttrArraySplit[$i] = ''
			Else
				If $AttrArraySplit[$i] = '' Then ContinueLoop
				If Int($TestOffsetAttr) < Int($FoundOffset) Then
					$AttrArraySplit[$i] = $FoundAttr&'?'&Int($FoundOffset)-Int($TestSize)
					ConsoleWrite("Modified entry: " & $FoundAttr&'?'&Int($FoundOffset)-Int($TestSize) & @CRLF)
					If Int($FoundOffset)-Int($TestSize) < 0 Then MsgBox(0,"Error _RemoveSingleOffsetOfAttribute()",$this_lsn)
				EndIf
			EndIf
		Next
		For $i = 1 To $AttrArraySplit[0]-1
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			$ConcatString &= $AttrArraySplit[$i]&','
		Next
		$AttrArray[$RefIndex][1] = $ConcatString
	Else
		ConsoleWrite("Error: Ref not found" & @CRLF)
	EndIf
EndFunc

Func _RemoveAllOffsetOfAttribute($TestRef)
	Local $RefIndex
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
		ConsoleWrite("Ref already exist in array" & @CRLF)
		$AttrArray[$RefIndex][1] = ''
	Else
		ConsoleWrite("Error: Ref not found" & @CRLF)
	EndIf
EndFunc

Func _UpdateSingleOffsetOfAttribute($TestRef, $TestOffsetAttr, $TestSize, $TestString)
	Local $RefIndex,$Replaced,$AttrArraySplit,$check=0,$ConcatString
	If $VerboseOn Then
		ConsoleWrite("_RemoveSingleOffsetOfAttribute()" & @CRLF)
		ConsoleWrite("$TestOffsetAttr: " & $TestOffsetAttr & @CRLF)
		ConsoleWrite("$TestSize: " & $TestSize & @CRLF)
		ConsoleWrite("$TestString: " & $TestString & @CRLF)
	EndIf
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
;		ConsoleWrite("Ref already exist in array" & @CRLF)
		$AttrArraySplit = StringSplit($AttrArray[$RefIndex][1], ',')
		$HighestOffset = 0
		For $i = 1 To $AttrArraySplit[0]-1
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			$TestOffset2 = StringInStr($AttrArraySplit[$i], '?')
			$FoundAttr = StringMid($AttrArraySplit[$i], 1, $TestOffset2-1)
			$FoundOffset = StringMid($AttrArraySplit[$i], $TestOffset2+1)
			If Int($FoundOffset) > $HighestOffset Then $HighestOffset=Int($FoundOffset)
			If $VerboseOn Then
				ConsoleWrite("$AttrArraySplit[$i]: " & $AttrArraySplit[$i] & @CRLF)
				ConsoleWrite("$TestOffset2: " & $TestOffset2 & @CRLF)
				ConsoleWrite("$FoundAttr: " & $FoundAttr & @CRLF)
				ConsoleWrite("$FoundOffset: " & $FoundOffset & @CRLF)
			EndIf
			$TestOffset = StringInStr($AttrArraySplit[$i], $TestOffsetAttr)
			If $TestOffset Then
				ConsoleWrite("Found offset: " & $TestOffset & @CRLF)
			EndIf
			If Not StringIsDigit($FoundOffset) Then MsgBox(0,"Not number:",$FoundOffset)
			If Int($TestOffsetAttr) > Int($FoundOffset) Then ContinueLoop
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			If Int($TestOffsetAttr) = Int($FoundOffset) Then
				$AttrArraySplit[$i] = $TestString&'?'&$TestOffsetAttr
				$check=1
			ElseIf Int($TestOffsetAttr) < Int($FoundOffset) Then
				$AttrArraySplit[$i] = $FoundAttr&'?'&Int($FoundOffset)+Int($TestSize)
				ConsoleWrite("Modified entry: " & $FoundAttr&'?'&Int($FoundOffset)+Int($TestSize) & @CRLF)
				If Int($FoundOffset)-Int($TestSize) < 0 Then MsgBox(0,"Error _RemoveSingleOffsetOfAttribute()",$this_lsn)
				$check=1
			EndIf
		Next
		If Int($TestOffsetAttr) > $HighestOffset Then
			$NewLimit = $AttrArraySplit[0]
			ReDim $AttrArraySplit[$NewLimit+1]
			$AttrArraySplit[$NewLimit] = $TestString&'?'&$TestOffsetAttr
		EndIf
		For $i = 1 To Ubound($AttrArraySplit)-1
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			$ConcatString &= $AttrArraySplit[$i]&','
		Next
		$AttrArray[$RefIndex][1] = $ConcatString
	Else
;		ConsoleWrite("Adding new row for new ref" & @CRLF)
		$GlobalCounter += 1
		ReDim $AttrArray[$GlobalCounter][2]
		$AttrArray[$GlobalCounter-1][0] = $TestRef
		$AttrArray[$GlobalCounter-1][1] = $TestString&'?'&$TestOffsetAttr&','
	EndIf
EndFunc

Func _UpdateSeveralOffsetOfAttribute($TestRef, $TestString)
	Local $RefIndex
	If $VerboseOn Then
		ConsoleWrite("_UpdateSeveralOffsetOfAttribute()" & @CRLF)
		ConsoleWrite("$TestString: " & $TestString & @CRLF)
	EndIf
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
;		ConsoleWrite("Ref already exist in array" & @CRLF)
		$AttrArray[$RefIndex][0] = $TestRef
		$AttrArray[$RefIndex][1] = $TestString&','
	Else
;		ConsoleWrite("Adding new row for new ref" & @CRLF)
		$GlobalCounter += 1
		ReDim $AttrArray[$GlobalCounter][2]
		$AttrArray[$GlobalCounter - 1][0] = $TestRef
		$AttrArray[$GlobalCounter - 1][1] = $TestString&','
	EndIf
EndFunc

Func _CheckOffsetOfAttribute($TestRef, $TestString)
	Local $RefIndex,$FoundAttr,$AttrArraySplit,$TestOffset
	If $VerboseOn Then
		ConsoleWrite("_CheckOffsetOfAttribute()" & @CRLF)
		ConsoleWrite("$TestString: " & $TestString & @CRLF)
		_ArrayDisplay($AttrArraySplit,"$AttrArraySplit")
	EndIf
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
		$AttrArraySplit = StringSplit($AttrArray[$RefIndex][1], ',')
		If $VerboseOn Then
			_ArrayDisplay($AttrArraySplit,"$AttrArraySplit")
		EndIf
		For $i = 1 To $AttrArraySplit[0]
			$TestOffset = StringInStr($AttrArraySplit[$i], $TestString)
			If $VerboseOn Then
				ConsoleWrite("$AttrArraySplit[$i]: " & $AttrArraySplit[$i] & @CRLF)
				ConsoleWrite("$TestOffset: " & $TestOffset & @CRLF)
			EndIf
			If $TestOffset Then
				If Not StringIsDigit(StringMid($AttrArraySplit[$i],$TestOffset-1,1)) Then
					If StringMid($AttrArraySplit[$i],$TestOffset-1,1) <> '?' Then MsgBox(0,"Error in _CheckOffsetOfAttribute()",$AttrArraySplit[$i] & " -> " & StringMid($AttrArraySplit[$i],$TestOffset-1,1))
					$FoundAttr = StringMid($AttrArraySplit[$i], 1, $TestOffset-2)
					ConsoleWrite("$FoundAttr: " & $FoundAttr & @CRLF)
					Return $FoundAttr
				EndIf
			EndIf
		Next
		ConsoleWrite("Error: Attribute offset not found" & @CRLF)
		Return SetError(1,0,$FoundAttr)
	Else
		ConsoleWrite("Error: Ref not found" & @CRLF)
		Return SetError(1,0,$FoundAttr)
	EndIf
EndFunc

Func _Decode_AttributeType($record)
;	Local $RecordSize,$DecodeOk=False
	Global $CurrentAttribute
	$AttributeTypeCheck = StringMid($record,1,4)
	If $VerboseOn Then
		ConsoleWrite("########### _Decode_AttributeType() ###########" & @CRLF)
		ConsoleWrite("$AttributeTypeCheck: " & $AttributeTypeCheck & @CRLF)
	EndIf
;	$RecordSize = StringLen($record)
	Select
		Case $AttributeTypeCheck = "1000"
			$AttributeString = "$STANDARD_INFORMATION"
		Case $AttributeTypeCheck = "2000"
			$AttributeString = "$ATTRIBUTE_LIST"
		Case $AttributeTypeCheck = "3000"
			$AttributeString = "$FILE_NAME"
		Case $AttributeTypeCheck = "4000"
			$AttributeString = "$OBJECT_ID"
		Case $AttributeTypeCheck = "5000"
			$AttributeString = "$SECURITY_DESCRIPTOR"
		Case $AttributeTypeCheck = "6000"
			$AttributeString = "$VOLUME_NAME"
		Case $AttributeTypeCheck = "7000"
			$AttributeString = "$VOLUME_INFORMATION"
		Case $AttributeTypeCheck = "8000"
			$AttributeString = "$DATA"
		Case $AttributeTypeCheck = "9000"
			$AttributeString = "$INDEX_ROOT"
		Case $AttributeTypeCheck = "A000"
			$AttributeString = "$INDEX_ALLOCATION"
		Case $AttributeTypeCheck = "B000"
			$AttributeString = "$BITMAP"
		Case $AttributeTypeCheck = "C000"
			$AttributeString = "$REPARSE_POINT"
		Case $AttributeTypeCheck = "D000"
			$AttributeString = "$EA_INFORMATION"
		Case $AttributeTypeCheck = "E000"
			$AttributeString = "$EA"
		Case $AttributeTypeCheck = "F000"
			$AttributeString = "$PROPERTY_SET"
		Case $AttributeTypeCheck = "0001"
			$AttributeString = "$LOGGED_UTILITY_STREAM"
	EndSelect
	Return $AttributeString
EndFunc
