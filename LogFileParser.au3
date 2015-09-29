#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Comment=$LogFile parser utility for NTFS
#AutoIt3Wrapper_Res_Description=$LogFile parser utility for NTFS
#AutoIt3Wrapper_Res_Fileversion=2.0.0.21
#AutoIt3Wrapper_Res_LegalCopyright=Joakim Schicht
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GuiEdit.au3>
#Include <WinAPIEx.au3>
#include <Array.au3>
#Include <String.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <File.au3>
#include <Math.au3>
#include "SecureConstants.au3"

Global $VerboseOn = 0, $CharReplacement=":", $de="|", $PrecisionSeparator=".", $DoSplitCsv=False, $csvextra, $InputLogFile,$TargetMftCsvFile, $UsnJrnlFile, $SectorsPerCluster, $DoReconstructDataRuns=False, $debuglogfile, $csvextra, $CurrentTimestamp, $EncodingWhenOpen=2, $ReconstructDone=False
Global $begin, $ElapsedTime, $CurrentRecord, $i, $PreviousUsn,$PreviousUsnFileName, $PreviousRedoOp, $PreviousAttribute, $PreviousUsnReason, $undo_length, $RealMftRef, $PreviousRealRef, $FromRcrdSlack, $IncompleteTransaction
Global $ProgressLogFile, $ProgressReconstruct, $CurrentProgress=-1, $ProgressStatus, $ProgressUsnJrnl, $ProgressSize
Global $CurrentFileOffset, $InputFileSize, $MaxRecords, $Record_Size=4096, $SectorSize=512, $Remainder = "", $_COMMON_KERNEL32DLL=DllOpen("kernel32.dll"), $PredictedRefNumber, $LogFileCsv, $LogFileIndxCsv, $LogFileDataRunsCsv, $LogFileDataRunsCsvFile, $LogFileDataRunsModCsv, $NtfsDbFile, $LogFileCsvFile, $LogFileIndxCsvfile, $LogFileDataRunsModCsvfile, $LogFileUndoWipeIndxCsv, $LogFileUndoWipeIndxCsvfile,$LogFileUsnJrnlCsv,$LogFileUsnJrnlCsvFile
Global $RecordOffset, $PredictedRefNumber, $this_lsn, $client_previous_lsn, $redo_operation, $undo_operation, $record_offset_in_mft, $attribute_offset, $hOutFileMFT, $tBuffer, $nBytes2, $HDR_BaseRecord, $FilePath, $HDR_SequenceNo
Global $nBytes, $rFile, $DataRunArr[2][18], $NewDataRunArr[1][18], $RowsProcessed, $MaxRows, $hQuery, $aRow, $aRow2, $iRows, $iColumns, $aRes, $sOutputFile
Global $RSTRsig = "52535452", $RCRDsig = "52435244", $BAADsig = "44414142", $CHKDsig = "444b4843", $Emptysig = "ffffffff"
Global $SI_CTime, $SI_ATime, $SI_MTime, $SI_RTime, $SI_FilePermission, $SI_MaxVersions, $SI_VersionNumber, $SI_ClassID, $SI_SecurityID, $SI_QuotaCharged, $SI_USN, $SI_PartialValue
Global $SI_CTime_Core,$SI_ATime_Core,$SI_MTime_Core,$SI_RTime_Core,$SI_CTime_Precision,$SI_ATime_Precision,$SI_MTime_Precision,$SI_RTime_Precision
Global $FN_CTime, $FN_ATime, $FN_MTime, $FN_RTime, $FN_AllocSize, $FN_RealSize, $FN_Flags, $FN_Name, $FN_NameType
Global $FN_CTime_Core,$FN_ATime_Core,$FN_MTime_Core,$FN_RTime_Core,$FN_CTime_Precision,$FN_ATime_Precision,$FN_MTime_Precision,$FN_RTime_Precision
Global $UsnJrnlFileReferenceNumber, $UsnJrnlParentFileReferenceNumber, $UsnJrnlTimestamp, $UsnJrnlReason, $UsnJrnlFileName, $FileNameModified, $UsnJrnlUsn, $UsnJrnlRef
Global $UsnJrnlCsv, $UsnJrnlCsvFile, $AttributeString, $KeptRef=-1, $TextInformation, $RedoChunkSize, $UndoChunkSize, $KeptRefTmp, $redo_length
Global $DT_NonResidentFlag, $DT_Flags, $DT_ComprUnitSize, $DT_RealSize, $DT_DataRuns, $DT_InitStreamSize, $DT_OffsetToDataRuns, $DT_StartVCN, $DT_LastVCN, $DT_AllocSize, $DT_Name
Global $FN_CTime_Core,$FN_CTime_Precision,$FN_ATime_Core,$FN_ATime_Precision,$FN_MTime_Core,$FN_MTime_Precision,$FN_RTime_Core,$FN_RTime_Precision
Global $SI_CTime_Core,$SI_CTime_Precision,$SI_ATime_Core,$SI_ATime_Precision,$SI_MTime_Core,$SI_MTime_Precision,$SI_RTime_Core,$SI_RTime_Precision
Global $LogFileFileNamesCsv,$LogFileFileNamesCsvFile,$LogFileTxfDataCsv,$LogFileTxfDataCsvFile
Global $SDHArray[1][1],$SIIArray[1][1],$de2=":",$LogFileSecureSDSCsv,$LogFileSecureSDHCsv,$LogFileSecureSIICsv,$LogFileSecureSDSCsvFile,$LogFileSecureSDHCsvFile,$LogFileSecureSIICsvFile
Global $TargetSDSOffsetHex,$SecurityDescriptorHash,$SecurityId,$ControlText,$SidOwner,$SidGroup
Global $SAclRevision,$SAceCount,$SAceTypeText,$SAceFlagsText,$SAceMask,$SAceObjectType,$SAceInheritedObjectType,$SAceSIDString,$SAceObjectFlagsText
Global $DAclRevision,$DAceCount,$DAceTypeText,$DAceFlagsText,$DAceMask,$DAceObjectType,$DAceInheritedObjectType,$DAceSIDString,$DAceObjectFlagsText
Global $OpenAttributesArray[1][14],$AttributeNamesDumpArray[1][4],$DirtyPageTableDumpArray[1][10],$lsn_openattributestable=0,$FileOutputTesterArray[21],$FileNamesArray[1][3],$SlackOpenAttributesArray[1][14],$SlackAttributeNamesDumpArray[1][4]
Global $LogFileOpenAttributeTableCsv,$LogFileOpenAttributeTableCsvFile,$LogFileDirtyPageTableCsv,$LogFileDirtyPageTableCsvFile,$LogFileBitsInNonresidentBitMapCsv,$LogFileBitsInNonresidentBitMapCsvFile,$LogFileTransactionTableCsv,$LogFileTransactionTableCsvFile
Global $LogFileReparseRCsv,$LogFileQuotaQCsv,$LogFileQuotaOCsv,$LogFileObjIdOCsv,$LogFileReparseRCsvFile,$LogFileQuotaQCsvFile,$LogFileQuotaOCsvFile,$LogFileObjIdOCsvFile,$LogFileRCRDCsv,$LogFileRCRDCsvFile
Global $client_index,$record_type,$transaction_id,$lf_flags,$target_attribute,$lcns_to_follow,$record_offset_in_mft,$attribute_offset,$MftClusterIndex,$target_vcn,$target_lcn,$InOpenAttributeTable=-1,$LsnValidationLevel
Global $LogFileTransactionHeaderCsv,$LogFileTransactionHeaderCsvFile,$LogFileSlackOpenAttributeTableCsv,$LogFileSlackOpenAttributeTableCsvFile,$LogFileSlackAttributeNamesDumpCsv,$LogFileSlackAttributeNamesDumpCsvFile,$LogFileAttributeListCsv,$LogFileAttributeListCsvFile
Global $GlobalDataKeepCounter=0,$GlobalRecordSpreadCounter=0,$GlobalRecordSpreadReset=0,$GlobalRecordSpreadReset2=0,$DoRebuildBrokenHeader=False,$MinSizeBrokenTransaction = 80, $IsNt5x=0, $DoExtractResidentUpdates=0
Global $RUN_VCN[1], $RUN_Clusters[1], $MFT_RUN_Clusters[1], $MFT_RUN_VCN[1], $DataQ[1], $AttrQ[1], $BytesPerCluster
Global $IsCompressed = False, $IsSparse = False
Global $outputpath=@ScriptDir, $hDisk, $sBuffer, $DataRun, $DATA_InitSize, $DATA_RealSize, $ImageOffset = 0, $ADS_Name
Global $TargetImageFile, $Entries, $IsImage=False, $IsPhysicalDrive=False, $ComboPhysicalDrives, $Combo, $MFT_Record_Size
Global $EaNonResidentArray[1][9]
Global $SQLite3Exe = @ScriptDir & "\sqlite3.exe"

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

If Not FileExists($SQLite3Exe) Then
	MsgBox(0,"Error","sqlite3.exe not found in current directory")
	Exit
EndIf

$Form = GUICreate("NTFS $LogFile Parser 2.0.0.21", 540, 520, -1, -1)

$Menu_help = GUICtrlCreateMenu("&Help")
;$Menu_Documentation = GUICtrlCreateMenuItem("&Documentation", $Menu_Help)
$Menu_Donate = GUICtrlCreateMenuItem("&Donate", $Menu_Help)
$Menu_GetHelp = GUICtrlCreateMenuItem("&Help", $Menu_Help)

$LabelLogFile = GUICtrlCreateLabel("$LogFile:",20,10,80,20)
$LogFileField = GUICtrlCreateInput("mandatory (unless fragment)",70,10,350,20)
GUICtrlSetState($LogFileField, $GUI_DISABLE)
$ButtonLogFile = GUICtrlCreateButton("Select $LogFile", 430, 10, 100, 20)

;$LabelUsnJrnl = GUICtrlCreateLabel("$UsnJrnl:",20,35,80,20)
;$UsnJrnlField = GUICtrlCreateInput("No longer needed",70,35,350,20)
;GUICtrlSetState($UsnJrnlField, $GUI_DISABLE)
;$ButtonUsnJrnl = GUICtrlCreateButton("Select $UsnJrnl", 430, 35, 100, 20)
;GUICtrlSetState($ButtonUsnJrnl, $GUI_DISABLE)
$LabelFragment = GUICtrlCreateLabel("Fragment:",20,35,80,20)
$FragmentField = GUICtrlCreateInput("Broken transaction fragment (optional, not yet activated)",70,35,350,20)
GUICtrlSetState($FragmentField, $GUI_DISABLE)
$ButtonFragment = GUICtrlCreateButton("Select fragment", 430, 35, 100, 20)

$LabelMFT = GUICtrlCreateLabel("MFT:",20,60,80,20)
$MFTField = GUICtrlCreateInput("Output of latest mft2csv (optional)",70,60,350,20)
GUICtrlSetState($MFTField, $GUI_DISABLE)
$ButtonMFT = GUICtrlCreateButton("Get MFT csv", 430, 60, 100, 20)

$LabelTimestampFormat = GUICtrlCreateLabel("Timestamp format:",20,85,90,20)
$ComboTimestampFormat = GUICtrlCreateCombo("", 110, 85, 30, 25)
$LabelTimestampPrecision = GUICtrlCreateLabel("Precision:",150,85,50,20)
$ComboTimestampPrecision = GUICtrlCreateCombo("", 200, 85, 70, 25)
$CheckCsvSplit = GUICtrlCreateCheckbox("split csv", 280, 85, 60, 20)
GUICtrlSetState($CheckCsvSplit, $GUI_UNCHECKED)
$LabelPrecisionSeparator = GUICtrlCreateLabel("Precision separator:",350,85,100,20)
$PrecisionSeparatorInput = GUICtrlCreateInput($PrecisionSeparator,450,85,20,20)

$InputExampleTimestamp = GUICtrlCreateInput("",340,110,190,20)
GUICtrlSetState($InputExampleTimestamp, $GUI_DISABLE)

$Label1 = GUICtrlCreateLabel("Set decoded timestamps to specific region:",20,110,230,20)
$Combo2 = GUICtrlCreateCombo("", 230, 110, 85, 25)

$LabelSeparator = GUICtrlCreateLabel("Set separator:",20,135,70,20)
$SaparatorInput = GUICtrlCreateInput($de,90,135,20,20)
$SaparatorInput2 = GUICtrlCreateInput($de,120,135,30,20)
GUICtrlSetState($SaparatorInput2, $GUI_DISABLE)

$CheckUnicode = GUICtrlCreateCheckbox("Unicode", 160, 135, 60, 20)
GUICtrlSetState($CheckUnicode, $GUI_UNCHECKED)

$CheckReconstruct = GUICtrlCreateCheckbox("Reconstruct data runs", 220, 135, 120, 20)
GUICtrlSetState($CheckReconstruct, $GUI_UNCHECKED)

$CheckBrokenHeaderRebuild = GUICtrlCreateCheckbox("Rebuild headers (in slack)", 350, 135, 140, 20)
GUICtrlSetState($CheckBrokenHeaderRebuild, $GUI_UNCHECKED)

$Label2 = GUICtrlCreateLabel("Sectors per cluster:",20,170,100,20)
$InputSectorPerCluster = GUICtrlCreateInput("8",120,170,30,20)

$Label3 = GUICtrlCreateLabel("MFT record size:",170,170,80,20)
$InputMFTRecordSize = GUICtrlCreateInput("1024",260,170,40,20)

$Label4 = GUICtrlCreateLabel("LSN error level:",310,170,80,20)
$InputErrorLevel = GUICtrlCreateInput("0.1",400,170,40,20)
$InputErrorLevelTranslated = GUICtrlCreateInput("",450,170,80,20)
GUICtrlSetState($InputErrorLevelTranslated, $GUI_DISABLE)

$CheckNt5x = GUICtrlCreateCheckbox("Source is from Nt5x (XP,2003)", 20, 205, 160, 20)
GUICtrlSetState($CheckNt5x, $GUI_UNCHECKED)
$CheckExtractResident = GUICtrlCreateCheckbox("Extract non + resident updates of min size:",190, 205, 215, 20)
GUICtrlSetState($CheckExtractResident, $GUI_UNCHECKED)
$MinSizeResidentExtraction = GUICtrlCreateInput("2",410,205,30,20)

$ButtonStart = GUICtrlCreateButton("Start", 450, 195, 80, 30)

$myctredit = GUICtrlCreateEdit("", 0, 230, 540, 85, BitOr($ES_AUTOVSCROLL,$WS_VSCROLL))
_GUICtrlEdit_SetLimitText($myctredit, 128000)

_InjectTimeZoneInfo()
_InjectTimestampFormat()
_InjectTimestampPrecision()
$PrecisionSeparator = GUICtrlRead($PrecisionSeparatorInput)
_TranslateTimestamp()
_TranslateErrorLevel()

GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Sleep(50)
	_TranslateSeparator()
	$PrecisionSeparator = GUICtrlRead($PrecisionSeparatorInput)
	_TranslateTimestamp()
	_TranslateErrorLevel()
	Switch $nMsg
;		Case $Menu_Documentation
;			ShellExecute("https://github.com/jschicht/LogFileParser")
		Case $Menu_Donate
			ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=joakim%2eschicht%40gmail%2ecom&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest")
		Case $Menu_GetHelp
			ShellExecute("mailto:joakim%2eschicht%40gmail%2ecom")
		Case $ButtonLogFile
			_SelectLogFile()
		Case $ButtonMFT
			_SelectMftCsv()
;		Case $ButtonUsnJrnl
;			_SelectUsnJrnl()
		Case $ButtonFragment
			_SelectFragment()
		Case $ButtonStart
			_Main()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func _Main()
Local $last_lsn,$page_flags,$page_count,$page_position,$next_record_offset,$page_unknown,$last_end_lsn
Local $next_last_lsn,$next_page_flags,$next_page_count,$next_page_position,$next_next_record_offset,$next_page_unknown,$next_last_end_lsn
Global $DataRunArr[2][18], $NewDataRunArr[1][18]
Global $GlobalCounter = 1,$AttrArray[$GlobalCounter][2], $DoReconstructDataRuns=False, $DoRebuildBrokenHeader=False
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

$MFT_Record_Size = GUICtrlRead($InputMFTRecordSize)
if StringIsDigit($MFT_Record_Size)=0 Or ($MFT_Record_Size <> 1024 And $MFT_Record_Size <> 4096) Then
	_DisplayInfo("Error: MFT record size should be an integer of either 1024 or 4096" & @CRLF)
	Return
EndIf

If GUICtrlRead($CheckUnicode) = 1 Then
	$EncodingWhenOpen = 2+32
EndIf

If GUICtrlRead($CheckNt5x) = 1 Then
	$IsNt5x = True
Else
	$IsNt5x = False
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

If GUICtrlRead($CheckExtractResident) = 1 Then
	$MinSizeResidentExtraction = GUICtrlRead($MinSizeResidentExtraction)
	If $MinSizeResidentExtraction > 0 Then
		$DoExtractResidentUpdates=1
	EndIf
EndIf

If GUICtrlRead($CheckBrokenHeaderRebuild) = 1 Then
	$DoRebuildBrokenHeader = True
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

If $LsnValidationLevel = 0 Then
	_DisplayInfo("Error: LsnValidationLevel: " & $LsnValidationLevel & @CRLF)
	Return
EndIf

_PrepareOutput()
If $DoExtractResidentUpdates Then
	DirCreate($ParserOutDir&"\ResidentExtract")
	DirCreate($ParserOutDir&"\NonResidentExtract")
EndIf
;Put output filenames into an array
$FileOutputTesterArray[0] = $LogFileCsvFile
$FileOutputTesterArray[1] = $LogFileIndxCsvFile
$FileOutputTesterArray[2] = $LogFileDataRunsCsvFile
$FileOutputTesterArray[3] = $LogFileSecureSDSCsvFile
$FileOutputTesterArray[4] = $LogFileSecureSDHCsvFile
$FileOutputTesterArray[5] = $LogFileSecureSIICsvFile
$FileOutputTesterArray[6] = $LogFileOpenAttributeTableCsvFile
$FileOutputTesterArray[7] = $LogFileDirtyPageTableCsvFile
$FileOutputTesterArray[8] = $LogFileBitsInNonresidentBitMapCsvFile
$FileOutputTesterArray[9] = $LogFileUsnJrnlCsvFile
$FileOutputTesterArray[10] = $LogFileReparseRCsvFile
$FileOutputTesterArray[11] = $LogFileQuotaQCsvFile
$FileOutputTesterArray[12] = $LogFileQuotaOCsvFile
$FileOutputTesterArray[13] = $LogFileObjIdOCsvFile
$FileOutputTesterArray[14] = $LogFileTransactionTableCsvFile
$FileOutputTesterArray[15] = $LogFileRCRDCsvFile
$FileOutputTesterArray[16] = $LogFileSlackOpenAttributeTableCsvFile
$FileOutputTesterArray[17] = $LogFileSlackAttributeNamesDumpCsvFile
$FileOutputTesterArray[18] = $LogFileAttributeListCsvFile
$FileOutputTesterArray[19] = $LogFileFileNamesCsvFile
$FileOutputTesterArray[20] = $LogFileTxfDataCsvFile


_WriteCSVHeader()
If $DoSplitCsv Then _WriteCSVExtraHeader()

;Secure headers
_WriteCSVHeaderSecureSDS()
_WriteCSVHeaderSecureSDH()
_WriteCSVHeaderSecureSII()

;Various csv headers
_WriteCSVHeaderOpenAttributeTable()
_WriteCSVHeaderDirtyPageTable()
_WriteCSVHeaderBitsInNonresidentBitMap()
_WriteCSVHeaderReparseR()
_WriteCSVHeaderQuotaQ()
_WriteCSVHeaderQuotaO()
_WriteCSVHeaderObjIdO()
_WriteCSVHeaderTransactionTable()
_WriteCSVHeaderRCRD()
_WriteCSVHeaderTransactionHeader()
_WriteCSVHeaderSlackOpenAttributeTable()
_WriteCSVHeaderSlackAttributeNamesDump()
_WriteCSVHeaderAttributeList()
_WriteCSVHeaderFileNames()
_WriteCSVHeaderTxfData()

$FileNamesArray[0][0] = "Ref"
$FileNamesArray[0][1] = "FileName"
$FileNamesArray[0][2] = "LSN"

$EaNonResidentArray[0][0] = "MFTRef"
$EaNonResidentArray[0][1] = "EntrySize"
$EaNonResidentArray[0][2] = "EntryName"
$EaNonResidentArray[0][3] = "Written"
$EaNonResidentArray[0][4] = "LSN"
$EaNonResidentArray[0][5] = "target_attribute"
$EaNonResidentArray[0][6] = "MftClusterIndex"
$EaNonResidentArray[0][7] = "target_vcn"
$EaNonResidentArray[0][8] = "OutputFileName"

_DebugOut("Using $LogFile: " & $InputLogFile)
If GUICtrlRead($CheckUnicode) = 1 Then
	_DebugOut("Unicode: 1")
Else
	_DebugOut("Unicode: 0")
EndIf

If StringLen(GUICtrlRead($PrecisionSeparatorInput)) <> 1 Then
	_DisplayInfo("Error: Precision separator not set properly" & @crlf)
	_DebugOut("Error: Precision separator not set properly: " & GUICtrlRead($PrecisionSeparatorInput))
	Return
Else
	$PrecisionSeparator = GUICtrlRead($PrecisionSeparatorInput)
	_DebugOut("Using precision separator: " & $PrecisionSeparator)
EndIf

_DebugOut("LSN Validation level: " & $LsnValidationLevel & " (" & $LsnValidationLevel*100 & " %)")
_DebugOut("Timestamps presented in UTC: " & $UTCconfig)
_DebugOut("Sectors per cluster: " & $SectorsPerCluster)
_DebugOut("DataRun reconstruct configuration: " & $DoReconstructDataRuns)
_DebugOut("Rebuild broken header for transactions found in slack: " & $DoRebuildBrokenHeader)
_DebugOut("Nt5x: " & $IsNt5x)
_DebugOut("DoExtractResidentUpdates: " & $DoExtractResidentUpdates)

$tBuffer = DllStructCreate("byte[" & $Record_Size & "]")
$tBuffer2 = DllStructCreate("byte[" & $SectorSize & "]")
$hFile = _WinAPI_CreateFile("\\.\" & $InputLogFile,2,2,7)
If $hFile = 0 Then
	_DebugOut("Error: Creating handle on $LogFile: " & _WinAPI_GetLastErrorMessage())
	Exit
EndIf


If FileExists($UsnJrnlFile) Then _DebugOut("Using $UsnJrnl: " & $UsnJrnlFile)
If $TargetMftCsvFile Then _DebugOut("Using MFT csv: " & $TargetMftCsvFile)
_DebugOut("Using DateTime format: " & $DateTimeFormat)
_DebugOut("Using timestamp precision: " & $TimestampPrecision)
_DebugOut("------------------- END CONFIGURATION -----------------------")

;$Progress = GUICtrlCreateLabel("Decoding $LogFile data and writing to csv", 10, 280,540,20)
$Progress = GUICtrlCreateLabel("Decoding $LogFile data and writing to csv", 10, 320,540,20)
GUICtrlSetFont($Progress, 12)
$ProgressStatus = GUICtrlCreateLabel("", 10, 350, 520, 20)
$ElapsedTime = GUICtrlCreateLabel("", 10, 365, 520, 20)
$ProgressLogFile = GUICtrlCreateProgress(10, 390, 520, 30)
$ProgressUsnJrnl = GUICtrlCreateProgress(10,  425, 520, 30)
$ProgressReconstruct = GUICtrlCreateProgress(10, 460, 520, 30)
$begin = TimerInit()
AdlibRegister("_LogFileProgress", 500)
$InputFileSize = _WinAPI_GetFileSizeEx($hFile)
$MaxRecords = Ceiling($InputFileSize/$Record_Size)
$RCRDRecord=""
$ConcatenatedRCRD=""
$DataUnprocessed = ""
$PreviousRcrdLsn = 0
$PreviousRcrdPosition = 0
$NextRecordChunk=""
;ConsoleWrite("$MaxRecords: " & $MaxRecords & @CRLF)

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
		$last_lsn = Dec(_SwapEndian($last_lsn),2)
		$page_flags = "0x" & _SwapEndian(StringMid($RCRDRecord,35,8))
		$page_count = Dec(_SwapEndian(StringMid($RCRDRecord,43,4)),2)
		$page_position = Dec(_SwapEndian(StringMid($RCRDRecord,47,4)),2)
		$next_record_offset = "0x" & _SwapEndian(StringMid($RCRDRecord,51,4))
		$page_unknown = "0x" & _SwapEndian(StringMid($RCRDRecord,55,12))
		$last_end_lsn = StringMid($RCRDRecord,67,16)
		$last_end_lsn = Dec(_SwapEndian($last_end_lsn),2)
;		ConsoleWrite("$i: " & $i & @CRLF)

		;Start - Get values from next record
		If $i < $MaxRecords-1 Then
			_WinAPI_SetFilePointerEx($hFile, ($i+1)*$Record_Size, $FILE_BEGIN)
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer2), $SectorSize, $nBytes)
			$NextRecordChunk = DllStructGetData($tBuffer2, 1)
			If StringMid($NextRecordChunk,3,8) = $RCRDsig Then
				$next_last_lsn = StringMid($NextRecordChunk,19,16)
				$next_last_lsn = Dec(_SwapEndian($next_last_lsn),2)
				$next_page_flags = "0x" & _SwapEndian(StringMid($NextRecordChunk,35,8))
				$next_page_count = Dec(_SwapEndian(StringMid($NextRecordChunk,43,4)),2)
				$next_page_position = Dec(_SwapEndian(StringMid($NextRecordChunk,47,4)),2)
				$next_next_record_offset = "0x" & _SwapEndian(StringMid($NextRecordChunk,51,4))
				$next_page_unknown = "0x" & _SwapEndian(StringMid($NextRecordChunk,55,12))
				$next_last_end_lsn = StringMid($NextRecordChunk,67,16)
				$next_last_end_lsn = Dec(_SwapEndian($next_last_end_lsn),2)
			Else
				;
			EndIf
		EndIf
		;End - Get values from next record

		$RulesString=""
		;Rules that determine if data flow will continue into next record
		$rule1 = ($last_lsn = $last_end_lsn)
		If $rule1 Then $RulesString&="rule1;"
		$rule2 = ($last_lsn > $next_last_lsn)
		If $rule2 Then $RulesString&="rule2;"
		$rule3 = ($last_end_lsn > $next_last_end_lsn And $next_last_end_lsn <> 0)
		If $rule3 Then $RulesString&="rule3;"
;		$rule4 = ($last_lsn = $next_last_lsn And $last_end_lsn <> 0 And $next_last_end_lsn <> 0 And $last_end_lsn > $next_last_end_lsn)
;		If $rule4 Then $RulesString&="rule4;"
		$rule5 = ($page_count - $page_position = 0) And ($next_page_position > 1)
		If $rule5 Then $RulesString&="rule5;"
		$rule6 = ($page_count - $page_position <> 0) And ($next_page_position - $page_position <> 1)
		If $rule6 Then $RulesString&="rule6;"
		$rule7 = ($page_count - $page_position <> 0) And ($next_page_position - $page_position = 0) And ($page_count <> $next_page_count)
		If $rule7 Then $RulesString&="rule7;"
;		If ($last_lsn = $last_end_lsn) Or ($last_lsn > $next_last_lsn) Or ($last_end_lsn > $next_last_end_lsn And $next_last_end_lsn <> 0) Or (($page_count - $page_position = 0) And ($next_page_position > 1)) Or (($page_count - $page_position <> 0) And ($next_page_position - $page_position <> 1)) Or (($page_count - $page_position <> 0) And ($next_page_position - $page_position = 0) And ($page_count <> $next_page_count)) Then
		If $rule1 Or $rule2 Or $rule3 Or $rule5 Or $rule6 Or $rule7 Then
			$NoMoreData=1
		Else
			$NoMoreData=0
		EndIf

		If $i = $MaxRecords-1 Then $NoMoreData=1

		$RCRDHeader = StringMid($RCRDRecord,1,130)
		$RCRDRecord = $RCRDHeader&$Remainder&StringMid($RCRDRecord,131)
		$DataUnprocessed = _DecodeRCRD($RCRDRecord, $CurrentFileOffset, StringLen($Remainder), $NoMoreData)

		If $NoMoreData Then
			$Remainder = ""
			$GlobalDataKeepCounter=0
;			If Not ($last_lsn = $last_end_lsn) Then _DumpOutput("------------- Skipping returned data -----------------Offset: 0x" & Hex($CurrentFileOffset,8) & @CRLF)
;			_DumpOutput("------------- Skipping returned data -----------------Offset: 0x" & Hex($CurrentFileOffset,8) & @CRLF)
;			ConsoleWrite("Offset: 0x" & Hex($CurrentFileOffset,8) & @CRLF)
		Else
			$Remainder = $DataUnprocessed
			$GlobalDataKeepCounter+=1
		EndIf

		$GlobalRecordSpreadReset2 = $GlobalRecordSpreadReset

		If $last_lsn = $next_last_lsn And $GlobalDataKeepCounter Then
			$GlobalRecordSpreadCounter += 1
			$GlobalRecordSpreadReset = 0
		Else
			If $GlobalRecordSpreadCounter Then
				$GlobalRecordSpreadReset = $GlobalRecordSpreadCounter
				$GlobalRecordSpreadCounter = 0
			Else
				$GlobalRecordSpreadReset = 0
				$GlobalRecordSpreadCounter = 0
			EndIf
		EndIf

		FileWriteLine($LogFileRCRDCsv, "0x"&Hex($CurrentFileOffset,8)&$de&$last_lsn&$de&$page_flags&$de&$page_count&$de&$page_position&$de&$next_record_offset&$de&$page_unknown&$de&$last_end_lsn&$de&$GlobalDataKeepCounter&$de&$RulesString&$de&$GlobalRecordSpreadCounter&$de&$GlobalRecordSpreadReset2&@crlf)
		$PreviousRcrdLsn = $last_lsn
		$PreviousRcrdPosition = $page_position
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
_WinAPI_CloseHandle($LogFileSecureSDSCsv)
_WinAPI_CloseHandle($LogFileSecureSDHCsv)
_WinAPI_CloseHandle($LogFileSecureSIICsv)
_WinAPI_CloseHandle($LogFileOpenAttributeTableCsv)
_WinAPI_CloseHandle($LogFileDirtyPageTableCsv)
_WinAPI_CloseHandle($LogFileBitsInNonresidentBitMapCsv)
_WinAPI_CloseHandle($UsnJrnlCsv)
_WinAPI_CloseHandle($LogFileReparseRCsv)
_WinAPI_CloseHandle($LogFileQuotaQCsv)
_WinAPI_CloseHandle($LogFileQuotaOCsv)
_WinAPI_CloseHandle($LogFileObjIdOCsv)
_WinAPI_CloseHandle($LogFileTransactionTableCsv)
_WinAPI_CloseHandle($LogFileSlackOpenAttributeTableCsv)
_WinAPI_CloseHandle($LogFileSlackAttributeNamesDumpCsv)
_WinAPI_CloseHandle($LogFileAttributeListCsv)
_WinAPI_CloseHandle($LogFileFileNamesCsv)

AdlibUnRegister("_LogFileProgress")
GUICtrlSetData($ProgressStatus, "Processing LogFile transaction " & $CurrentRecord+1 & " of " & $MaxRecords)
GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
GUICtrlSetData($ProgressLogFile, 100 * ($CurrentRecord+1) / $MaxRecords)

_DisplayInfo("$LogFile processing finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & "." & @CRLF)
_DumpOutput("------------------ END PROCESSING -------------------" & @CRLF)
_DumpOutput("$LogFile processing finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & "." & @CRLF)

For $FileNumber = 0 To UBound($FileOutputTesterArray)-1
	If FileExists($FileOutputTesterArray[$FileNumber]) Then
;		ConsoleWrite("Checking output: " & $FileOutputTesterArray[$FileNumber] & @CRLF)
		If (_FileCountLines($FileOutputTesterArray[$FileNumber]) < 2) Then
			FileMove($FileOutputTesterArray[$FileNumber],$FileOutputTesterArray[$FileNumber]&".empty",1)
			_DumpOutput("Empty output: " & $FileOutputTesterArray[$FileNumber] & " is postfixed with .empty" & @CRLF)
		EndIf
	EndIf
Next
;_ArrayDisplay($FileNamesArray,"$FileNamesArray")
;#cs
;x64 dll not working properly?
If @AutoItX64 Then
	$Sqlite3DllString = @ScriptDir & "\sqlite3_x64.dll"

Else
	$Sqlite3DllString = @ScriptDir & "\sqlite3.dll"
EndIf
;#ce
;$Sqlite3DllString = @ScriptDir & "\sqlite3.dll"

;set encoding
If GUICtrlRead($CheckUnicode) = 1 Then
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "PRAGMA encoding = 'UTF-16le';CREATE TABLE bogus(one INTEGER,two TEXT);", $sOutputFile, $SQLite3Exe)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not PRAGMA encoding = UTF-16le: " & $NtfsDbFile & " : " & @error)
		_DumpOutput("Error Could not PRAGMA encoding = UTF-16le, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
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
_DisplayInfo("Importing csv's to db and updating tables." & @CRLF)
_DumpOutput("Importing csv's to db and updating tables." & @CRLF)
$begin = TimerInit()
If $DoReconstructDataRuns Then
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE DataRuns (lf_Offset TEXT,lf_MFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_FileName TEXT,lf_LSN INTEGER,lf_RedoOperation TEXT,lf_UndoOperation TEXT,lf_OffsetInMft INTEGER,lf_AttributeOffset INTEGER,lf_SI_USN INTEGER,lf_DataName TEXT,lf_Flags TEXT,lf_NonResident TEXT,lf_CompressionUnitSize TEXT,lf_FileSize INTEGER,lf_InitializedStreamSize INTEGER,lf_OffsetToDataRuns INTEGER,lf_DataRuns TEXT);", $sOutputFile, $SQLite3Exe)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not create table DataRuns in database: " & $NtfsDbFile & " : " & @error)
		_DumpOutput("Error Could not create table DataRuns, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
		Exit
	EndIf
EndIf

;$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE LogFile (lf_Offset TEXT,lf_MFTReference INTEGER,lf_RealMFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_LSN INTEGER,lf_LSNPrevious INTEGER,lf_RedoOperation TEXT,lf_UndoOperation TEXT,lf_OffsetInMft INTEGER,lf_FileName TEXT,lf_CurrentAttribute TEXT,lf_TextInformation TEXT,lf_UsnJrlFileName TEXT,lf_UsnJrlMFTReference INTEGER,lf_UsnJrlMFTParentReference INTEGER,lf_UsnJrlTimestamp TEXT,lf_UsnJrlReason TEXT,lf_UsnJrnlUsn INTEGER,lf_SI_CTime TEXT,lf_SI_ATime TEXT,lf_SI_MTime TEXT,lf_SI_RTime TEXT,lf_SI_FilePermission TEXT,lf_SI_MaxVersions INTEGER,lf_SI_VersionNumber INTEGER,lf_SI_ClassID INTEGER,lf_SI_SecurityID INTEGER,lf_SI_QuotaCharged INTEGER,lf_SI_USN INTEGER,lf_SI_PartialValue TEXT,lf_FN_CTime TEXT,lf_FN_ATime TEXT,lf_FN_MTime TEXT,lf_FN_RTime TEXT,lf_FN_AllocSize INTEGER,lf_FN_RealSize INTEGER,lf_FN_Flags TEXT,lf_FN_Namespace TEXT,lf_DT_StartVCN INTEGER,lf_DT_LastVCN INTEGER,lf_DT_ComprUnitSize INTEGER,lf_DT_AllocSize INTEGER,lf_DT_RealSize INTEGER,lf_DT_InitStreamSize INTEGER,lf_DT_DataRuns TEXT,lf_DT_Name TEXT,lf_FileNameModified INTEGER,lf_RedoChunkSize INTEGER,lf_UndoChunkSize INTEGER);", $sOutputFile)
$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE LogFile (lf_Offset TEXT,lf_MFTReference INTEGER,lf_RealMFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_LSN INTEGER,lf_LSNPrevious INTEGER,lf_RedoOperation TEXT,lf_UndoOperation TEXT,lf_OffsetInMft INTEGER,lf_FileName TEXT,lf_CurrentAttribute TEXT,lf_TextInformation TEXT,lf_UsnJrlFileName TEXT,lf_UsnJrlMFTReference INTEGER,lf_UsnJrlMFTParentReference INTEGER,lf_UsnJrlTimestamp TEXT,lf_UsnJrlReason TEXT,lf_UsnJrnlUsn INTEGER,lf_SI_CTime TEXT,lf_SI_ATime TEXT,lf_SI_MTime TEXT,lf_SI_RTime TEXT,lf_SI_FilePermission TEXT,lf_SI_MaxVersions INTEGER,lf_SI_VersionNumber INTEGER,lf_SI_ClassID INTEGER,lf_SI_SecurityID INTEGER,lf_SI_QuotaCharged INTEGER,lf_SI_USN INTEGER,lf_SI_PartialValue TEXT,lf_FN_CTime TEXT,lf_FN_ATime TEXT,lf_FN_MTime TEXT,lf_FN_RTime TEXT,lf_FN_AllocSize INTEGER,lf_FN_RealSize INTEGER,lf_FN_Flags TEXT,lf_FN_Namespace TEXT,lf_DT_StartVCN INTEGER,lf_DT_LastVCN INTEGER,lf_DT_ComprUnitSize INTEGER,lf_DT_AllocSize INTEGER,lf_DT_RealSize INTEGER,lf_DT_InitStreamSize INTEGER,lf_DT_DataRuns TEXT,lf_DT_Name TEXT,lf_FileNameModified INTEGER,lf_RedoChunkSize INTEGER,lf_UndoChunkSize INTEGER,lf_record_type INTEGER,lf_transaction_id INTEGER,lf_flags INTEGER,lf_target_attribute INTEGER,lf_lcns_to_follow INTEGER,lf_attribute_offset INTEGER,lf_MftClusterIndex INTEGER,lf_target_vcn INTEGER,lf_target_lcn INTEGER,InOpenAttributeTable INTEGER,FromRcrdSlack INTEGER,IncompleteTransaction INTEGER);", $sOutputFile, $SQLite3Exe)
If $SQLiteExecution <> 0 Then
	MsgBox(0,"Error","Could not create table LogFile in database: " & $NtfsDbFile & " : " & @error)
	_DumpOutput("Error Could not create table LogFile, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	Exit
EndIf

$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE IndexEntries (lf_Offset TEXT,lf_LSN INTEGER,lf_EntryNumber INTEGER,lf_MFTReference INTEGER,lf_MFTReferenceSeqNo INTEGER,lf_IndexFlags TEXT,lf_MFTParentReference INTEGER,lf_MFTParentReferenceSeqNo INTEGER,lf_CTime TEXT,lf_ATime TEXT,lf_MTime TEXT,lf_RTime TEXT,lf_AllocSize INTEGER,lf_RealSize INTEGER,lf_FileFlags TEXT,lf_ReparseTag TEXT,lf_FileName TEXT,lf_FileNameModified TEXT,lf_NameSpace TEXT,lf_SubNodeVCN TEXT);", $sOutputFile, $SQLite3Exe)
If $SQLiteExecution <> 0 Then
	MsgBox(0,"Error","Could not create table IndexEntries in database: " & $NtfsDbFile & " : " & @error)
	_DumpOutput("Error Could not create table IndexEntries, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	Exit
EndIf

;Import csv for dataruns
If FileExists($LogFileDataRunsCsvfile) Then
	if $DoReconstructDataRuns Then
		$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileDataRunsCsvfile) & "' DataRuns" & @CRLF, $sOutputFile)
		If $SQLiteExecution <> 0 Then
			MsgBox(0,"Error","Could not import " & $LogFileDataRunsCsvfile & " into database: " & @error)
			_DumpOutput("Error importing csv to DataRuns, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
			Exit
		EndIf
	EndIf
EndIf

;Import main csv of logfile output
If FileExists($LogFileCsvFile) Then
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileCsvFile) & "' LogFile" & @CRLF, $sOutputFile)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not import " & $LogFileCsvFile & " into database: " & @error)
		_DumpOutput("Error importing csv to LogFile, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
		Exit
	EndIf
EndIf

;Import csv of INDX decodes
If FileExists($LogFileIndxCsvfile) Then
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileIndxCsvfile) & "' IndexEntries" & @CRLF, $sOutputFile)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not import " & $LogFileIndxCsvfile & " into database: " & @error)
		_DumpOutput("Error importing csv to IndexEntries, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	EndIf
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
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE Mft (" _
		& "RecordOffset TEXT,Signature TEXT,IntegrityCheck TEXT,Style TEXT,HEADER_MFTREcordNumber INTEGER,HEADER_SequenceNo INTEGER,Header_HardLinkCount INTEGER,FN_ParentReferenceNo INTEGER,FN_ParentSequenceNo INTEGER,FN_FileName TEXT,FilePath TEXT,HEADER_Flags TEXT," _
		& "RecordActive TEXT,FileSizeBytes INTEGER,SI_FilePermission TEXT,FN_Flags TEXT,FN_NameType TEXT,ADS TEXT,SI_CTime TEXT,SI_ATime TEXT,SI_MTime TEXT,SI_RTime TEXT,MSecTest TEXT,FN_CTime TEXT,FN_ATime TEXT,FN_MTime TEXT,FN_RTime TEXT,CTimeTest TEXT," _
		& "FN_AllocSize INTEGER,FN_RealSize INTEGER,FN_EaSize INTEGER,SI_USN INTEGER,DATA_Name TEXT,DATA_Flags TEXT,DATA_LengthOfAttribute TEXT,DATA_IndexedFlag TEXT,DATA_VCNs INTEGER,DATA_NonResidentFlag INTEGER,DATA_CompressionUnitSize INTEGER,HEADER_LSN INTEGER,HEADER_RecordRealSize INTEGER," _
		& "HEADER_RecordAllocSize INTEGER,HEADER_BaseRecord INTEGER,HEADER_BaseRecSeqNo INTEGER,HEADER_NextAttribID TEXT,DATA_AllocatedSize INTEGER,DATA_RealSize INTEGER,DATA_InitializedStreamSize INTEGER,SI_HEADER_Flags TEXT,SI_MaxVersions INTEGER,SI_VersionNumber INTEGER," _
		& "SI_ClassID INTEGER,SI_OwnerID INTEGER,SI_SecurityID INTEGER,SI_Quota INTEGER,FN_CTime_2 TEXT,FN_ATime_2 TEXT,FN_MTime_2 TEXT,FN_RTime_2 TEXT,FN_AllocSize_2 INTEGER,FN_RealSize_2 INTEGER,FN_EaSize_2 INTEGER,FN_Flags_2 TEXT,FN_NameLength_2 INTEGER,FN_NameType_2 TEXT,FN_FileName_2 TEXT," _
		& "GUID_ObjectID TEXT,GUID_BirthVolumeID TEXT,GUID_BirthObjectID TEXT,GUID_BirthDomainID TEXT,VOLUME_NAME_NAME TEXT,VOL_INFO_NTFS_VERSION TEXT,VOL_INFO_FLAGS TEXT,FN_CTime_3 TEXT,FN_ATime_3 TEXT,FN_MTime_3 TEXT,FN_RTime_3 TEXT,FN_AllocSize_3 INTEGER," _
		& "FN_RealSize_3 INTEGER,FN_EaSize_3 INTEGER,FN_Flags_3 TEXT,FN_NameLength_3 INTEGER,FN_NameType_3 TEXT,FN_FileName_3 TEXT,DATA_Name_2 TEXT,DATA_NonResidentFlag_2 INTEGER,DATA_Flags_2 TEXT,DATA_LengthOfAttribute_2 INTEGER,DATA_IndexedFlag_2 INTEGER,DATA_StartVCN_2 INTEGER," _
		& "DATA_LastVCN_2 INTEGER,DATA_VCNs_2 INTEGER,DATA_CompressionUnitSize_2 INTEGER,DATA_AllocatedSize_2 INTEGER,DATA_RealSize_2 INTEGER,DATA_InitializedStreamSize_2 INTEGER,DATA_Name_3 TEXT,DATA_NonResidentFlag_3 INTEGER,DATA_Flags_3 TEXT,DATA_LengthOfAttribute_3 INTEGER," _
		& "DATA_IndexedFlag_3 INTEGER,DATA_StartVCN_3 INTEGER,DATA_LastVCN_3 INTEGER,DATA_VCNs_3 INTEGER,DATA_CompressionUnitSize_3 INTEGER,DATA_AllocatedSize_3 INTEGER,DATA_RealSize_3 INTEGER,DATA_InitializedStreamSize_3 INTEGER,STANDARD_INFORMATION_ON INTEGER," _
		& "ATTRIBUTE_LIST_ON INTEGER,FILE_NAME_ON INTEGER,OBJECT_ID_ON INTEGER,SECURITY_DESCRIPTOR_ON INTEGER,VOLUME_NAME_ON INTEGER,VOLUME_INFORMATION_ON INTEGER,DATA_ON INTEGER,INDEX_ROOT_ON INTEGER,INDEX_ALLOCATION_ON INTEGER,BITMAP_ON INTEGER,REPARSE_POINT_ON INTEGER," _
		& "EA_INFORMATION_ON INTEGER,EA_ON INTEGER,PROPERTY_SET_ON INTEGER,LOGGED_UTILITY_STREAM_ON INTEGER" _
		& ");", $sOutputFile, $SQLite3Exe)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not create table Mft in database: " & @error)
		_DumpOutput("Error Could not create table Mft, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	EndIf
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($TargetMftCsvFile) & "' Mft" & @CRLF, $sOutputFile)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not import " & $TargetMftCsvFile & " into database: " & @error)
		_DumpOutput("Error importing csv to Mft, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
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
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE MftTmp as select HEADER_MFTRecordNumber,HEADER_LSN,FN_FileName,FilePath from Mft;", $sOutputFile, $SQLite3Exe)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not create table MftTmp in database: " & @error)
		_DumpOutput("Error Could not create table MftTmp, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	EndIf
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE LogFileTmp as select * from LogFile left join MftTmp on LogFile.lf_LSN=MftTmp.HEADER_LSN;", $sOutputFile, $SQLite3Exe)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not create table LogFileTmp in database: " & @error)
		_DumpOutput("Error Could not create table LogFileTmp, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	EndIf
	_SQLite_SQLiteExe2($NtfsDbFile, "DROP TABLE LogFile;", $sOutputFile)
	_SQLite_SQLiteExe2($NtfsDbFile, "ALTER TABLE LogFileTmp rename to LogFile;", $sOutputFile)
EndIf
_DisplayInfo("Csv import and table updates took " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & "." & @CRLF)
_DumpOutput("Csv import and table updates took " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & "." & @CRLF)

;----------------- UsnJrnl
If FileExists($UsnJrnlFile) Then
	$Progress = GUICtrlCreateLabel("Decoding $UsnJrnl info and writing to csv", 10, 280,540,20)
	GUICtrlSetFont($Progress, 12)
	$begin = TimerInit()
	Dim $tBuffer2, $hUsnJrnl, $RawPage="", $TestHeader, $UsnJrnlPage="", $Remainder="", $SQLiteExecution, $Record_Size = 4096, $nBytes=""
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
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE UsnJrnl (UsnJrnlMFTReference INTEGER,UsnJrnlMFTParentReference INTEGER,UsnJrnlUSN INTEGER,UsnJrnlTimestamp TEXT,UsnJrnlReason TEXT,UsnJrnlSourceInfo TEXT,UsnJrnlFileAttributes TEXT,UsnJrnlFileName TEXT,UsnJrnlFileNameModified INTEGER);", $sOutputFile, $SQLite3Exe)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not create table UsnJrnl in database: " & @error)
		_DumpOutput("Error Could not create table UsnJrnl, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
		Exit
	EndIf
	$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($UsnJrnlCsvFile) & "' UsnJrnl" & @CRLF, $sOutputFile)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not import " & $UsnJrnlCsvFile & " into database: " & @error)
		_DumpOutput("Error importing csv to UsnJrnl, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
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
	$SQLiteExecution2 = _SQLite_SQLiteExe2($NtfsDbFile, ".headers on" & @CRLF & ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".output LogFileJoined.csv" & @CRLF & "select * from LogFile;" & @CRLF, $sOutputFile)
	If $SQLiteExecution <> 0 Then
		MsgBox(0,"Error","Could not export LogFile table to csv: " & @error)
		_DumpOutput("@error: " & @error & @CRLF)
		_DumpOutput("Error exporting from LogFile table to LogFileJoined.csv, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
		Exit
	EndIf
	$moved = FileMove(@ScriptDir&"\LogFileJoined.csv",$ParserOutDir&"\LogFileJoined.csv",9)
EndIf

;remove bogus table
If GUICtrlRead($CheckUnicode) = 1 Then
	$SQLiteExecution2 = _SQLite_SQLiteExe2($NtfsDbFile, "DROP TABLE bogus;", $sOutputFile)
	If $SQLiteExecution2 <> 0 Then
		MsgBox(0,"Error","Could not DROP TABLE bogus: " & @error)
		_DumpOutput("@error: " & @error & @CRLF)
		_DumpOutput("Error Could not DROP TABLE bogus, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
;		Exit
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
$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, "CREATE TABLE DataRunsResolved (lf_MFTReference INTEGER,lf_MFTBaseRecRef INTEGER,lf_FileName TEXT,lf_LSN INTEGER,lf_OffsetInMft INTEGER,lf_DataName TEXT,lf_Flags TEXT,lf_NonResident INTEGER,lf_FileSize INTEGER,lf_InitializedStreamSize INTEGER,lf_DataRuns TEXT);", $sOutputFile, $SQLite3Exe)
If $SQLiteExecution <> 0 Then
	MsgBox(0,"Error","Could not create table DataRunsResolved in database: " & @error)
	_DumpOutput("Error Could not create table DataRunsResolved, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
	Exit
EndIf
$SQLiteExecution = _SQLite_SQLiteExe2($NtfsDbFile, ".mode csv" & @CRLF & ".separator " & $de & @CRLF & ".import '" & FileGetShortName($LogFileDataRunsModCsvfile) & "' DataRunsResolved" & @CRLF, $sOutputFile)
If $SQLiteExecution <> 0 Then
	MsgBox(0,"Error","Could not import " & $LogFileDataRunsModCsvfile & " into database: " & @error)
	_DumpOutput("Error importing csv to DataRunsResolved, $SQLiteExecution: " & $SQLiteExecution & @CRLF)
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
#cs
RCRD
0x40: 64 byte header
0x30: record 48 byte header + data
#ce
Func _DecodeRCRD($RCRDRecord, $RCRDOffset, $OffsetAdjustment, $DoNotReturnData)
Local $DataPart = 0, $NextOffset = 131, $TotalSizeOfRCRD = StringLen($RCRDRecord), $LsnSignatureLength=10, $CharsToMove=0, $ZeroSample="0000000000000000", $LsnSignatureFound=0, $last_lsn_tmp_refup, $last_lsn_tmp_refdown, $RebuiltLsn
Global $PredictedRefNumber = "", $FromRcrdSlack=0, $SlackPerRCRDCounter=0

;_DumpOutput("<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>" & @CRLF)
;_DumpOutput("$RCRDOffset: 0x" & Hex($RCRDOffset,8) & @CRLF)
;ConsoleWrite(_HexEncode(StringMid($RCRDRecord,1,130)) & @CRLF)
;ConsoleWrite("$TotalSizeOfRCRD: 0x" & Hex(Int(($TotalSizeOfRCRD-3)/2),8) & @CRLF)
;ConsoleWrite(_HexEncode("0x"&StringMid($RCRDRecord,131)) & @CRLF)
;ConsoleWrite(_HexEncode(StringMid($RCRDRecord,1)) & @CRLF)

$last_lsn_tmp = StringMid($RCRDRecord,19,16)
$last_lsn_tmp = Dec(_SwapEndian($last_lsn_tmp),2)

$last_end_lsn_tmp = StringMid($RCRDRecord,67,16)
$last_end_lsn_tmp = Dec(_SwapEndian($last_end_lsn_tmp),2)

$max_last_lsn = _Max($last_lsn_tmp,$last_end_lsn_tmp)

$last_lsn_tmp_refup = Round($max_last_lsn*(1+$LsnValidationLevel))
$last_lsn_tmp_refdown = Round($max_last_lsn*(1-$LsnValidationLevel))

$this_lsn_tmp = StringMid($RCRDRecord,$NextOffset,16)
$this_lsn_tmp = Dec(_SwapEndian($this_lsn_tmp),2)

$next_record_offset = Dec(_SwapEndian(StringMid($RCRDRecord,51,4)),2)

$client_previous_lsn_tmp = StringMid($RCRDRecord,$NextOffset+16,16)
$client_previous_lsn_tmp = Dec(_SwapEndian($client_previous_lsn_tmp),2)
$client_undo_next_lsn_tmp = StringMid($RCRDRecord,$NextOffset+32,16)
$client_undo_next_lsn_tmp = Dec(_SwapEndian($client_undo_next_lsn_tmp),2)
;If ($this_lsn_tmp > $last_lsn_tmp) Or ($this_lsn_tmp < $last_lsn_tmp - 1000) Then
;	_DumpOutput("Error: RCRD seems corrupt at offset: 0x" & Hex($RCRDOffset,8) & @CRLF)
;	_DumpOutput("Bytes reassembled: " & $OffsetAdjustment & @CRLF)
;	_DumpOutput("$last_lsn_tmp: " & $last_lsn_tmp & @CRLF)
;	_DumpOutput("$this_lsn_tmp: " & $this_lsn_tmp & @CRLF)
;	_DumpOutput(_HexEncode(StringMid($RCRDRecord,1)) & @CRLF)
;	Return
;EndIf
;$TestChunk2 = StringMid($last_lsn_tmp_mod,16-$LsnSignatureLength)
;ConsoleWrite("$TestChunk2: " & $TestChunk2 & @CRLF)
If ($this_lsn_tmp > $max_last_lsn) Or ($client_previous_lsn_tmp > $max_last_lsn) Or ($client_undo_next_lsn_tmp > $max_last_lsn) Or ($this_lsn_tmp < $last_lsn_tmp_refdown) Or ($client_previous_lsn_tmp < $last_lsn_tmp_refdown And $client_previous_lsn_tmp <> 0) Or ($client_undo_next_lsn_tmp < $last_lsn_tmp_refdown And $client_undo_next_lsn_tmp <> 0) Then
	_DumpOutput("Scanning for LSN signature from RCRD offset: 0x" & Hex($RCRDOffset,8) & @CRLF)
;	_DumpOutput("$DoNotReturnData: " & $DoNotReturnData & @CRLF)
;	_DumpOutput("$OffsetAdjustment: " & $OffsetAdjustment & @CRLF)
;	_DumpOutput("$last_lsn_tmp: " & $last_lsn_tmp & @CRLF);
;	_DumpOutput("$last_end_lsn_tmp: " & $last_end_lsn_tmp & @CRLF)
;	_DumpOutput("$max_last_lsn: " & $max_last_lsn & @CRLF)
;	_DumpOutput("$last_lsn_tmp_refup: " & $last_lsn_tmp_refup & @CRLF)
;	_DumpOutput("$last_lsn_tmp_refdown: " & $last_lsn_tmp_refdown & @CRLF)
;	_DumpOutput("$NextOffset: " & $NextOffset & @CRLF)
;	_DumpOutput("$CharsToMove: " & $CharsToMove & @CRLF)
	While 1
		If $CharsToMove+$NextOffset > $TotalSizeOfRCRD Then ExitLoop
;		_DumpOutput("0x"&Hex(Int(($NextOffset+$CharsToMove-3)/2),8) & @CRLF)
		$TestChunk1 = StringMid($RCRDRecord,$NextOffset+$CharsToMove,16)
		$TestChunk1 = Dec(_SwapEndian($TestChunk1),2)
;		_DumpOutput("$TestChunk1: " & $TestChunk1 & @CRLF)

		If ($TestChunk1 > $last_lsn_tmp_refdown) And ($TestChunk1 < $last_lsn_tmp_refup) Then
			$TestChunk2 = StringMid($RCRDRecord,$NextOffset+$CharsToMove+16,16)
			$TestChunk2 = Dec(_SwapEndian($TestChunk2),2)
;			_DumpOutput("$TestChunk2: " & $TestChunk2 & @CRLF)
			$TestChunk3 = StringMid($RCRDRecord,$NextOffset+$CharsToMove+16+16,16)
			$TestChunk3 = Dec(_SwapEndian($TestChunk3),2)
;			_DumpOutput("$TestChunk3: " & $TestChunk3 & @CRLF)
			If (($TestChunk2 > $last_lsn_tmp_refdown) And ($TestChunk2 < $last_lsn_tmp_refup)) Or ($TestChunk2 = 0) Then
				If (($TestChunk3 > $last_lsn_tmp_refdown) And ($TestChunk3 < $last_lsn_tmp_refup)) Or ($TestChunk3 = 0) Then
	;				ConsoleWrite("Match1!!!" & @CRLF)
					$LsnSignatureFound=1
					ExitLoop
				Else
	;				ConsoleWrite("False positive" & @CRLF)
					$CharsToMove+=16
					ContinueLoop
				EndIf
			Else
	;			ConsoleWrite("False positive" & @CRLF)
				$CharsToMove+=16
				ContinueLoop
			EndIf
;			ConsoleWrite("Match2!!!" & @CRLF)
;			ExitLoop
		EndIf
		$CharsToMove+=16
		If $CharsToMove+$NextOffset > $TotalSizeOfRCRD Then ExitLoop
	WEnd
	If Not $LsnSignatureFound Then
		_DumpOutput("LSN signature not found:" & @CRLF)
		_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,$NextOffset)) & @CRLF)
		Return ""
	Else
		If $CharsToMove > 0 Then
			If $DoNotReturnData > 0 And $OffsetAdjustment > 0 Then ;This check should not be necessary?????????????????????????
				$RecordOffset = "0x" & Hex(Int($RCRDOffset-$OffsetAdjustment/2),8)
;				_DumpOutput("Unknown slack space found at record offset 0x" & Hex(Int($RCRDOffset-$OffsetAdjustment+($NextOffset-3)/2),8) & " - 0x" & Hex(Int($RCRDOffset-$OffsetAdjustment+($NextOffset+$CharsToMove-3)/2),8) & @CRLF)
				_DumpOutput("Unknown slack space found at record offset 0x" & Hex(Int($RCRDOffset-$OffsetAdjustment/2),8) & " - 0x" & Hex(Int($RCRDOffset-$OffsetAdjustment+$CharsToMove/2),8) & @CRLF)
			Else
				$RecordOffset = "0x" & Hex(Int($RCRDOffset+($NextOffset-3)/2),8)
				_DumpOutput("Unknown slack space found at record offset 0x" & Hex(Int($RCRDOffset+($NextOffset-3)/2),8) & " - 0x" & Hex(Int($RCRDOffset+($NextOffset+$CharsToMove-3)/2),8) & @CRLF)
			EndIf
			_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,$NextOffset,$CharsToMove)) & @CRLF)
			If $DoRebuildBrokenHeader And $CharsToMove >= $MinSizeBrokenTransaction Then
				_DumpOutput("Attempting a repair of possible broken header 1.." & @CRLF)
				$ClientData = _CheckAndRepairTransactionHeader(StringMid($RCRDRecord,$NextOffset,$CharsToMove))
				If Not @Error Then
					$RebuiltLsn = StringMid($ClientData,1,16)
					$RebuiltLsn = Dec(_SwapEndian($RebuiltLsn),2)
					$IncompleteTransaction=1
					_DecodeLSNRecord($ClientData,$RebuiltLsn)
				EndIf
			EndIf
		EndIf
		_DumpOutput("Found LSN signature match at record offset 0x"&Hex(Int($RCRDOffset+($NextOffset+$CharsToMove-3)/2),8) & @CRLF)
		$NextOffset += $CharsToMove
	EndIf
	$FromRcrdSlack=1
else
	$FromRcrdSlack=0
EndIf

$SizeOfClientData = StringMid($RCRDRecord,$NextOffset+48,8)
$SizeOfClientData = Dec(_SwapEndian($SizeOfClientData),2)
;_DumpOutput("RCRD Offset: 0x" & Hex($RCRDOffset,8) & @CRLF)
;_DumpOutput("$SizeOfClientData: 0x" & Hex(Int($SizeOfClientData),8) & @CRLF)
If Not $DoNotReturnData Then
	If 96+($SizeOfClientData*2) > $TotalSizeOfRCRD-$NextOffset Then
;		_DumpOutput("Data returned 0 (" & $GlobalDataKeepCounter & ")" & @CRLF)
;		_DumpOutput("Returned data:" & @CRLF)
;		_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,$NextOffset)) & @CRLF)
		Return StringMid($RCRDRecord,$NextOffset)
	EndIf
EndIf

Do
	If $DataPart And $GlobalRecordSpreadReset Then
		$RecordOffset = $RCRDOffset+(($NextOffset-$OffsetAdjustment-3+(128*$GlobalRecordSpreadReset))/2)
;		$RecordOffset = $RCRDOffset+(($NextOffset-$OffsetAdjustment-3)/2)
		$RecordOffset = "0x"&Hex(Int($RecordOffset))
	ElseIf $DataPart Then
		$RecordOffset = $RCRDOffset+(($NextOffset-$OffsetAdjustment-3)/2)
		$RecordOffset = "0x"&Hex(Int($RecordOffset))
	Else
		$RecordOffset = $RCRDOffset+(($NextOffset-$OffsetAdjustment-3-(128*$GlobalDataKeepCounter))/2)
		$RecordOffset = "0x"&Hex(Int($RecordOffset))
	EndIf

	If $NextOffset-$OffsetAdjustment >= $next_record_offset*2 Then
;		_DumpOutput("RCRD Offset: 0x" & Hex($RCRDOffset,8) & @CRLF)
		If Not $DoNotReturnData Then
;			_DumpOutput("Data returned 1 (" & $GlobalDataKeepCounter & ")" & @CRLF)
;			_DumpOutput("Return data (split record) at end of RCRD at 0x" & Hex(Int($next_record_offset),4) & @CRLF)
;			_DumpOutput("Bytes returned: 0x" & Hex(Int((($TotalSizeOfRCRD-3-$OffsetAdjustment)/2)-$next_record_offset),8) & @CRLF)
;			_DumpOutput("$NextOffset: " & $NextOffset & @CRLF)
;			_DumpOutput("$OffsetAdjustment: " & $OffsetAdjustment & @CRLF)
;			_DumpOutput("$NextOffset-$OffsetAdjustment: " & $NextOffset-$OffsetAdjustment & @CRLF)
;			_DumpOutput("$next_record_offset: " & $next_record_offset*2 & @CRLF)
;			_DumpOutput("$next_record_offset: 0x" & Hex(Int($next_record_offset),4) & @CRLF)
	;		_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,3+($next_record_offset*2))) & @CRLF)
;			_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,$NextOffset)) & @CRLF)
			Return StringMid($RCRDRecord,$NextOffset)
		Else
			_DumpOutput("Analyzing slack space starting at " & $RecordOffset & @CRLF)
			_TestSlackSpace(StringMid($RCRDRecord,$NextOffset),$max_last_lsn,$RecordOffset)
			Return ""
		EndIf
	EndIf
	$SizeOfClientData = StringMid($RCRDRecord,$NextOffset+48,8)
	$SizeOfClientData = Dec(_SwapEndian($SizeOfClientData),2)
	$SizeOfClientData = $SizeOfClientData*2

	If $SizeOfClientData = 0 Then
		_DumpOutput("Error: $SizeOfClientData was 0 at " & $RecordOffset & @CRLF)
		_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,$NextOffset)) & @CRLF)
;		_TestSlackSpace(StringMid($RCRDRecord,$NextOffset),$last_lsn_tmp,$RecordOffset)
		ExitLoop
	EndIf
#cs
	If $RCRDOffset > 0x1A28000 Then
		_DumpOutput("------------------------------------" & @CRLF)
		_DumpOutput("RCRD Offset: 0x" & Hex($RCRDOffset,8) & @CRLF)
		_DumpOutput("$SizeOfClientData: 0x" & Hex(Int($SizeOfClientData/2),8) & @CRLF)
		_DumpOutput("$SizeOfClientData: " & $SizeOfClientData & @CRLF)
		_DumpOutput("$NextOffset: " & $NextOffset & @CRLF)
		_DumpOutput("$OffsetAdjustment: " & $OffsetAdjustment & @CRLF)
		_DumpOutput("$TotalSizeOfRCRD: " & $TotalSizeOfRCRD & @CRLF)
	EndIf
#ce
	$ClientData = StringMid($RCRDRecord,$NextOffset,96+$SizeOfClientData) ; 48 bytes header + data
	If $NextOffset-1-$OffsetAdjustment+96+$SizeOfClientData > $TotalSizeOfRCRD Then ; We need to return the incomplete record, and attach it to the beginning of the next RCRD and continue processing
		If Not $DoNotReturnData Then
;			_DumpOutput("Data returned 2 (" & $GlobalDataKeepCounter & ")" & @CRLF)
;			Return $ClientData
			Return StringMid($RCRDRecord,$NextOffset)
		Else
			_DumpOutput("Error should not really be here: " & $RecordOffset & @CRLF)
			_DumpOutput("$NextOffset: " & $NextOffset & @CRLF)
			_DumpOutput("$OffsetAdjustment: " & $OffsetAdjustment & @CRLF)
			_DumpOutput("$SizeOfClientData: " & $SizeOfClientData & @CRLF)
			_DumpOutput("Part 1: " & $NextOffset-$OffsetAdjustment+96+$SizeOfClientData & @CRLF)
			_DumpOutput("Part 2: " & $TotalSizeOfRCRD & @CRLF)
			_TestSlackSpace($ClientData,$max_last_lsn,$RecordOffset)
			Return ""
		EndIf
	EndIf
;	_DumpOutput("Transaction: " & @CRLF)
;	_DumpOutput(_HexEncode("0x"&$ClientData) & @CRLF)
	_DecodeLSNRecord($ClientData,$max_last_lsn)
	$NextOffset += 96+$SizeOfClientData
	$DataPart += 1
Until $NextOffset >= $TotalSizeOfRCRD
If Not $DoNotReturnData Then
	_DumpOutput("Error: Something must be wrong" & @CRLF)
	_DumpOutput(_HexEncode("0x"&StringMid($RCRDRecord,$NextOffset)) & @CRLF)
EndIf
Return ""
EndFunc

Func _TestSlackSpace($InputData,$last_lsn_tmp,$Offset)
	;$InputData = SlackSpace data in RCRD
	;$last_lsn_tmp = From header of RCRD
	Local $CharsToMove=0, $LsnSignatureFound=0, $TotalSizeOfRCRD=StringLen($InputData), $NextOffset = 1, $last_lsn_tmp_refup, $last_lsn_tmp_refdown
	$FromRcrdSlack += 1
	$SlackPerRCRDCounter += 1

	$last_lsn_tmp_refup = $last_lsn_tmp*(1+$LsnValidationLevel)
	$last_lsn_tmp_refdown = $last_lsn_tmp*(1-$LsnValidationLevel)

	If $TotalSizeOfRCRD < $MinSizeBrokenTransaction Then
		_DumpOutput("SlackSpace: The size of input data was too small for a valid record header:" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
		Return
	Else
;		_DumpOutput("SlackSpace: Size of input data: 0x" & Hex(Int($TotalSizeOfRCRD/2),8) & @CRLF)
	EndIf
;	_DumpOutput("$last_lsn_tmp: 0x" & _SwapEndian(Hex($last_lsn_tmp,16)) & @CRLF)
;	_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	$this_lsn_tmp = StringMid($InputData,1,16)
	$this_lsn_tmp = Dec(_SwapEndian($this_lsn_tmp),2)
	$client_previous_lsn_tmp = StringMid($InputData,$NextOffset+16,16)
	$client_previous_lsn_tmp = Dec(_SwapEndian($client_previous_lsn_tmp),2)
	$client_undo_next_lsn_tmp = StringMid($InputData,$NextOffset+32,16)
	$client_undo_next_lsn_tmp = Dec(_SwapEndian($client_undo_next_lsn_tmp),2)
	If ($this_lsn_tmp > $last_lsn_tmp) Or ($client_previous_lsn_tmp > $last_lsn_tmp) Or ($client_undo_next_lsn_tmp > $last_lsn_tmp) Or ($this_lsn_tmp < $last_lsn_tmp_refdown) Or ($client_previous_lsn_tmp < $last_lsn_tmp_refdown And $client_previous_lsn_tmp <> 0) Or ($client_undo_next_lsn_tmp < $last_lsn_tmp_refdown And $client_undo_next_lsn_tmp <> 0) Then
		_DumpOutput("SlackSpace: Scanning for LSN signature" & @CRLF)
		While 1
			If $CharsToMove+$NextOffset > $TotalSizeOfRCRD Then ExitLoop
			$TestChunk1 = StringMid($InputData,$NextOffset+$CharsToMove,16)
			$TestChunk1 = Dec(_SwapEndian($TestChunk1),2)
	;		ConsoleWrite("0x"&Hex(Int(($NextOffset+$CharsToMove-3)/2),8) & " $TestChunk1: " & $TestChunk1 & @CRLF)
			If ($TestChunk1 > $last_lsn_tmp_refdown) And ($TestChunk1 < $last_lsn_tmp_refup) Then
;			If $last_lsn_tmp_mod = $TestChunk Then
				$TestChunk2 = StringMid($InputData,$NextOffset+$CharsToMove+16,16)
				$TestChunk2 = Dec(_SwapEndian($TestChunk2),2)
	;			ConsoleWrite("$TestChunk2: " & $TestChunk2 & @CRLF)
				$TestChunk3 = StringMid($InputData,$NextOffset+$CharsToMove+16+16,16)
				$TestChunk3 = Dec(_SwapEndian($TestChunk3),2)
	;			ConsoleWrite("$TestChunk3: " & $TestChunk3 & @CRLF)
				If (($TestChunk2 > $last_lsn_tmp_refdown) And ($TestChunk2 < $last_lsn_tmp_refup)) Or ($TestChunk2 = 0) Then
					If (($TestChunk3 > $last_lsn_tmp_refdown) And ($TestChunk3 < $last_lsn_tmp_refup)) Or ($TestChunk3 = 0) Then
		;				ConsoleWrite("Match1!!!" & @CRLF)
						$LsnSignatureFound=1
						ExitLoop
					Else
		;				ConsoleWrite("False positive" & @CRLF)
						$CharsToMove+=16
						ContinueLoop
					EndIf
				Else
		;			ConsoleWrite("False positive" & @CRLF)
					$CharsToMove+=16
					ContinueLoop
				EndIf
	;			ConsoleWrite("Match2!!!" & @CRLF)
	;			ExitLoop
			EndIf
			$CharsToMove+=16
			If $CharsToMove+$NextOffset > $TotalSizeOfRCRD Then ExitLoop
		WEnd
		If Not $LsnSignatureFound Then
			_DumpOutput("SlackSpace: LSN signature not found." & @CRLF)
			_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
			If $DoRebuildBrokenHeader And $CharsToMove >= $MinSizeBrokenTransaction Then
				$RecordOffset = "0x" & Hex(Int($Offset),8)
				_DumpOutput("Attempting a repair of possible broken header 2.." & @CRLF)
				$ClientData = _CheckAndRepairTransactionHeader(StringMid($InputData,$NextOffset,$CharsToMove))
				If Not @Error Then
					$RebuiltLsn = StringMid($ClientData,1,16)
					$RebuiltLsn = Dec(_SwapEndian($RebuiltLsn),2)
					$IncompleteTransaction=1
					_DecodeLSNRecord($ClientData,$RebuiltLsn)
				EndIf
			EndIf
			Return
		Else
			If $CharsToMove > 0 Then
				_DumpOutput("Unknown slack space found at record offset 0x" & Hex(Int($Offset+($NextOffset)/2),8) & " - 0x" & Hex(Int($Offset+($NextOffset+$CharsToMove)/2),8) & @CRLF)
				_DumpOutput(_HexEncode("0x"&StringMid($InputData,$NextOffset,$CharsToMove)) & @CRLF)
				If $DoRebuildBrokenHeader And $CharsToMove >= $MinSizeBrokenTransaction Then
					$RecordOffset = "0x" & Hex(Int($Offset+($NextOffset)/2),8)
					_DumpOutput("Attempting a repair of possible broken header 3.." & @CRLF)
					$ClientData = _CheckAndRepairTransactionHeader(StringMid($InputData,$NextOffset,$CharsToMove))
					If Not @Error Then
						$RebuiltLsn = StringMid($ClientData,1,16)
						$RebuiltLsn = Dec(_SwapEndian($RebuiltLsn),2)
						$IncompleteTransaction=1
						_DecodeLSNRecord($ClientData,$RebuiltLsn)
					EndIf
				EndIf
			EndIf
;			_DumpOutput(_HexEncode("0x"&StringMid($InputData,$NextOffset,$CharsToMove)) & @CRLF)
			_DumpOutput("SlackSpace: Found LSN signature match at record offset 0x"&Hex(Int($Offset+($NextOffset+$CharsToMove)/2),8) & @CRLF)
			$NextOffset += $CharsToMove
		EndIf
	EndIf

	Do
		If $NextOffset >= $TotalSizeOfRCRD Then
			Return
		EndIf
		$RecordOffset = Int(Dec(StringRight($Offset,8),2) + ($NextOffset/2))
		$RecordOffset = "0x"&Hex($RecordOffset)

		$this_lsn_tmp = StringMid($InputData,$NextOffset,16)
		$this_lsn_tmp = Dec(_SwapEndian($this_lsn_tmp),2)
		$client_previous_lsn_tmp = StringMid($InputData,$NextOffset+16,16)
		$client_previous_lsn_tmp = Dec(_SwapEndian($client_previous_lsn_tmp),2)
		$client_undo_next_lsn_tmp = StringMid($InputData,$NextOffset+32,16)
		$client_undo_next_lsn_tmp = Dec(_SwapEndian($client_undo_next_lsn_tmp),2)
		;We need some sanity checking on the next bytes
		If ($this_lsn_tmp > $last_lsn_tmp) Or ($client_previous_lsn_tmp > $last_lsn_tmp) Or ($client_undo_next_lsn_tmp > $last_lsn_tmp) Or ($this_lsn_tmp < $last_lsn_tmp_refdown) Or ($client_previous_lsn_tmp < $last_lsn_tmp_refdown And $client_previous_lsn_tmp <> 0) Or ($client_undo_next_lsn_tmp < $last_lsn_tmp_refdown And $client_undo_next_lsn_tmp <> 0) Then
			_DumpOutput("SlackSpace: Invalid record header at 0x" & Hex(Int($Offset+($NextOffset/2))) & @CRLF)
			_DumpOutput("SlackSpace: Rescanning for LSN signature." & @CRLF)
			If $SlackPerRCRDCounter < 1800 Then
				_TestSlackSpace(StringMid($InputData,$NextOffset),$last_lsn_tmp,$Offset+($NextOffset/2))
				Return
			Else
				Return
			EndIf
		EndIf

		$SizeOfClientData = StringMid($InputData,$NextOffset+48,8)
		$SizeOfClientData = Dec(_SwapEndian($SizeOfClientData),2)
		$SizeOfClientData = $SizeOfClientData*2
		If $SizeOfClientData = 0 Then
;			MsgBox(0,"Info","$SizeOfClientData = 0 at " & $RecordOffset)
			_DumpOutput("SlackSpace: Error $SizeOfClientData = 0 at 0x" & Hex(Int($Offset+($NextOffset/2))) & @CRLF)
;			_TestSlackSpace(StringMid($InputData,$NextOffset),$last_lsn_tmp,$Offset+($NextOffset/2))
			ExitLoop
		EndIf

		$ClientData = StringMid($InputData,$NextOffset,96+$SizeOfClientData)
		If $NextOffset-1+96+$SizeOfClientData > $TotalSizeOfRCRD Then ; Or maybe we should attempt parsing incomplete records as this is record slack space..
			_DumpOutput("SlackSpace: Warning incomplete record at 0x" & Hex(Int($Offset+($NextOffset/2))) & @CRLF)
;			_DumpOutput("SlackSpace: $NextOffset: " & $NextOffset & @CRLF)
;			_DumpOutput("SlackSpace: $SizeOfClientData: " & $SizeOfClientData & @CRLF)
;			_DumpOutput("SlackSpace: Part 1: " & $NextOffset+96+$SizeOfClientData & @CRLF)
;			_DumpOutput("SlackSpace: Part 2: " & $TotalSizeOfRCRD & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$ClientData) & @CRLF)
			_DecodeLSNRecord($ClientData,$this_lsn_tmp)
			Return
		EndIf

		_DumpOutput("SlackSpace: Parsing identified record at " & $RecordOffset & @CRLF)
;		_DumpOutput("$RecordOffset: " & $RecordOffset & @CRLF)
;		_DumpOutput(_HexEncode("0x"&$ClientData) & @CRLF)
		_DecodeLSNRecord($ClientData,$this_lsn_tmp)
		$NextOffset+=96+$SizeOfClientData
	Until $NextOffset >= $TotalSizeOfRCRD
EndFunc

Func _DecodeLSNRecord($InputData,$last_lsn_tmp)
;Local $target_lcn, $client_undo_next_lsn, $client_data_length, $client_index, $record_type, $flags, $redo_offset, $undo_offset, $target_attribute, $lcns_to_follow, $redo_operation_hex, $undo_operation_hex,$MftClusterIndex, $target_vcn
Local $client_undo_next_lsn, $client_data_length, $redo_offset, $undo_offset, $redo_operation_hex, $undo_operation_hex
Local $DecodeOk=False,$UsnOk=False,$TestAttributeType,$ResolvedAttributeOffset,$FoundInTable=0,$FoundInTableDummy=0,$AttrNameTmp,$last_lsn_tmp_refup,$last_lsn_tmp_refdown,$FoundInTableSlack=0
Global $AttributeString

;_ClearVar()

$this_lsn = StringMid($InputData,1,16)
$this_lsn = Dec(_SwapEndian($this_lsn),2)

$last_lsn_tmp_refup = $last_lsn_tmp*(1+$LsnValidationLevel)
$last_lsn_tmp_refdown = $last_lsn_tmp*(1-$LsnValidationLevel)
;<Test for valid lsn>
If ($this_lsn > $last_lsn_tmp) Or ($this_lsn < $last_lsn_tmp_refdown) Then
	_DumpOutput("Error: RCRD seems corrupt at offset: " & $RecordOffset & @CRLF)
	_DumpOutput("$last_lsn_tmp: " & $last_lsn_tmp & @CRLF)
	_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
	_DumpOutput(_HexEncode("0x"&StringMid($InputData,1)) & @CRLF)
	_ClearVar()
	Return
EndIf
;</Test for valid lsn>

$client_previous_lsn = StringMid($InputData,17,16)
$client_previous_lsn = Dec(_SwapEndian($client_previous_lsn),2)
$client_undo_next_lsn = StringMid($InputData,33,16)
$client_undo_next_lsn = Dec(_SwapEndian($client_undo_next_lsn),2)
$client_data_length = StringMid($InputData,49,8)
$client_data_length = Dec(_SwapEndian($client_data_length),2)
$client_index = StringMid($InputData,57,8)
$client_index = "0x"&_SwapEndian($client_index)
$record_type = StringMid($InputData,65,8)
$record_type = "0x"&_SwapEndian($record_type)
$transaction_id = StringMid($InputData,73,8)
$transaction_id = "0x"&_SwapEndian($transaction_id)
$lf_flags = StringMid($InputData,81,4)
$lf_flags = "0x"&_SwapEndian($lf_flags)
;$alignment_or_reserved0 = StringMid($InputData,85,12)
$redo_operation_hex = StringMid($InputData,97,4)
$redo_operation = Dec(_SwapEndian($redo_operation_hex),2)
$redo_operation = _SolveUndoRedoCodes($redo_operation)
$undo_operation_hex = StringMid($InputData,101,4)
$undo_operation = Dec(_SwapEndian($undo_operation_hex),2)
$undo_operation = _SolveUndoRedoCodes($undo_operation)
$redo_offset = StringMid($InputData,105,4)
$redo_offset = Dec(_SwapEndian($redo_offset),2)
$redo_length = StringMid($InputData,109,4)
$redo_length = Dec(_SwapEndian($redo_length),2)
$undo_offset = StringMid($InputData,113,4)
$undo_offset = Dec(_SwapEndian($undo_offset),2)
$undo_length = StringMid($InputData,117,4)
$undo_length = Dec(_SwapEndian($undo_length),2)
$target_attribute = StringMid($InputData,121,4)
$target_attribute = "0x"&_SwapEndian($target_attribute)

;Align tmp sizes to 8 bytes
$redo_length_tmp = $redo_length
If Mod($redo_length_tmp,8) Then
	While 1
		$redo_length_tmp+=1
		If Mod($redo_length_tmp,8) = 0 Then ExitLoop
	WEnd
EndIf

$undo_length_tmp = $undo_length
If Mod($undo_length_tmp,8) Then
	While 1
		$undo_length_tmp+=1
		If Mod($undo_length_tmp,8) = 0 Then ExitLoop
	WEnd
EndIf
;Validation check of header values
Local $ValidationTest1 = $redo_operation = "SetNewAttributeSizes" And $client_data_length < $undo_offset+$undo_length_tmp
Local $ValidationTest2 = $client_data_length <> $undo_offset+$undo_length_tmp And $redo_operation <> "CompensationlogRecord" And $redo_operation <> "SetNewAttributeSizes" And $redo_operation <> "ForgetTransaction" And ($redo_operation <> "Noop" And $undo_operation <> "Noop")
Local $ValidationTest3 = $client_data_length <> $redo_offset+$redo_length_tmp And $redo_operation <> "CompensationlogRecord" And $redo_operation <> "SetNewAttributeSizes" And $redo_operation <> "ForgetTransaction" And ($redo_operation <> "Noop" And $undo_operation <> "Noop")
Local $ValidationTest4 = $redo_operation = "UNKNOWN"
Local $ValidationTest5 = $undo_operation = "UNKNOWN"
;Local $ValidationTest6 = $client_data_length <> $redo_offset+$redo_length_tmp And $client_data_length <> $undo_offset+$undo_length_tmp And $redo_operation <> "CompensationlogRecord" And $redo_operation <> "SetNewAttributeSizes"
If $ValidationTest1 Or ($ValidationTest2 And $ValidationTest3) Or $ValidationTest4 Or $ValidationTest5 Then
;If (($client_data_length <> $undo_offset+$undo_length_tmp And $redo_operation <> "CompensationlogRecord") And ($client_data_length <> $redo_offset+$redo_length_tmp And $redo_operation <> "CompensationlogRecord")) Or $redo_operation = "UNKNOWN"  Or $undo_operation = "UNKNOWN" Then
	_DumpOutput("Error: Validation of header values failed at offset: " & $RecordOffset & @CRLF)
	_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
	_DumpOutput("$client_data_length: 0x" & Hex($client_data_length) & @CRLF)
	_DumpOutput("$redo_offset: 0x" & Hex($redo_offset,4) & @CRLF)
	_DumpOutput("$redo_length_tmp: 0x" & Hex($redo_length_tmp,4) & @CRLF)
	_DumpOutput("$undo_offset: 0x" & Hex($undo_offset,4) & @CRLF)
	_DumpOutput("$undo_length_tmp: 0x" & Hex($undo_length_tmp,4) & @CRLF)
	_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
	_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
	_DumpOutput(_HexEncode("0x"&StringMid($InputData,1)) & @CRLF)
	_ClearVar()
	Return
EndIf

;Test for incomplete records grabbed from slack space
If ((48 + $client_data_length) > (StringLen($InputData)/2)) Then
	_DumpOutput("Error: Incomplete record recovered at offset: " & $RecordOffset & @CRLF)
	_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
;	_DumpOutput("Part 1: " & 48 + $client_data_length & " 0x" & Hex(Int(48 + $client_data_length)) & @CRLF)
;	_DumpOutput("Part 2: " & StringLen($InputData)/2 & " 0x" & Hex(Int(StringLen($InputData)/2)) & @CRLF)
	_DumpOutput(_HexEncode("0x"&StringMid($InputData,1)) & @CRLF)
;	MsgBox(0,"Info","Check output")
	$TextInformation &= ";Incomplete record recovered"
	$IncompleteTransaction = 1
EndIf
If Not $FromRcrdSlack Then
	If $this_lsn > $lsn_openattributestable Then
		If Not ($target_attribute = 0x0000 Or $target_attribute = 0x0017 Or $target_attribute = 0x0018) Then
			If Ubound($OpenAttributesArray) > 1 Then
				$FoundInTable = _ArraySearch($OpenAttributesArray,$target_attribute,0,0,0,2,1,0)
		;		ConsoleWrite("$FoundInTable: " & $FoundInTable & @CRLF)
				If Not $FoundInTable > 0 Then
					$InOpenAttributeTable=0
					_DumpOutput("Could not find $target_attribute in $OpenAttributesArray: " & $target_attribute & " for $this_lsn: " & $this_lsn & @CRLF)
					_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
		;			$FoundInTable = _ArraySearch($OpenAttributesArray2,$target_attribute,0,0,0,2,1,0)
		;			ConsoleWrite("Attempt 2 $FoundInTable: " & $FoundInTable & @CRLF)
				Else
					$InOpenAttributeTable=$lsn_openattributestable
				EndIf
			Else
				$InOpenAttributeTable=0
		;		MsgBox(0,"Error","$target_attribute was not found because array is empty")
			EndIf
		EndIf
	EndIf
Else
;	If $this_lsn > $lsn_openattributestable Then
		If Not ($target_attribute = 0x0000 Or $target_attribute = 0x0017 Or $target_attribute = 0x0018) Then
			If Ubound($SlackOpenAttributesArray) > 1 Then
				$FoundInTableSlack = _ArraySearch($SlackOpenAttributesArray,$target_attribute,0,0,0,2,1,0)
				If Not $FoundInTableSlack > 0 Then
					$InOpenAttributeTable=0
					_DumpOutput("Could not find $target_attribute in $SlackOpenAttributesArray: " & $target_attribute & " for $this_lsn: " & $this_lsn & @CRLF)
					_ArrayDisplay($SlackOpenAttributesArray,"$SlackOpenAttributesArray")
				Else
					$InOpenAttributeTable=0 ;$lsn_openattributestable
				EndIf
			Else
				$InOpenAttributeTable=0
			EndIf
		EndIf
;	EndIf
EndIf

;If $this_lsn=102077767547 or $this_lsn=102093572805 Then
;	ConsoleWrite("$target_attribute was not found in array: " & $target_attribute & @CRLF)
;	_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
;EndIf
$lcns_to_follow = StringMid($InputData,125,4)
$lcns_to_follow = "0x"&_SwapEndian($lcns_to_follow)
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
$target_lcn = "0x"&_SwapEndian($target_lcn)
;$alignment_or_reserved3 = StringMid($InputData,169,8)
$PredictedRefNumber = ((Dec($target_vcn,2)*$BytesPerCluster)/$MFT_Record_Size)+((Dec($MftClusterIndex,2)*512)/$MFT_Record_Size)
;ConsoleWrite("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
;Need to research more on how to calculate correct MFT ref
If ($redo_operation_hex = "0000" And $undo_operation_hex <> "0000") Or $redo_operation_hex = "0200" Or $redo_operation_hex = "0300" Or $redo_operation_hex = "0400" Or $redo_operation_hex = "0500" Or $redo_operation_hex = "0600" Or $redo_operation_hex = "0700" Or ($redo_operation_hex = "0800" And $PreviousRedoOp = "1c00") Or $redo_operation_hex = "0900" Or $redo_operation_hex = "0b00" Or $redo_operation_hex = "0c00" Or $redo_operation_hex = "0d00" Or $redo_operation_hex = "1100" Or $redo_operation_hex = "1300" Or $redo_operation_hex = "1c00" Then
	If Not $FromRcrdSlack Then
		$KeptRefTmp = $PredictedRefNumber
		$KeptRef = $PredictedRefNumber
	EndIf
	ElseIf $client_previous_lsn<>0 And ($redo_operation_hex = "0e00" Or $redo_operation_hex = "0f00" Or $redo_operation_hex = "1000" Or $redo_operation_hex = "1200" Or $redo_operation_hex = "1400" Or ($redo_operation_hex = "0800" And ($redo_operation_hex = "0800" Or $PreviousRedoOp = "0b00"))) Then
	If Not $FromRcrdSlack Then
		$PredictedRefNumber = $KeptRef
;		$KeptRefTmp = $KeptRef
	Else
		$PredictedRefNumber = -1 ;Not possible from slack
	EndIf
Else
	$PredictedRefNumber = -1 ;Not related to any particular MFT ref
EndIf

$target_vcn = "0x"&$target_vcn
$MftClusterIndex = "0x"&$MftClusterIndex


If Not $FromRcrdSlack Then
	FileWriteLine($LogFileTransactionHeaderCsv, $RecordOffset & $de & $this_lsn & $de & $client_previous_lsn & $de & $client_undo_next_lsn & $de & $client_index & $de & $record_type & $de & $transaction_id & $de & $lf_flags & $de & $redo_operation & $de & $undo_operation & $de & $redo_offset & $de & $redo_length_tmp & $de & $undo_offset & $de & $undo_length_tmp & $de & $client_data_length & $de & $target_attribute & $de & $lcns_to_follow & $de & $record_offset_in_mft & $de & $attribute_offset & $de & $MftClusterIndex & $de & $target_vcn & $de & $target_lcn & @crlf)
EndIf

If Not $FromRcrdSlack Then
	If $FoundInTable > 0 Then
	;	ConsoleWrite("ubound($OpenAttributesArray): " & ubound($OpenAttributesArray) & @CRLF)
		$AttributeStringTmp = _ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTable][5],3,4))
		If $AttributeStringTmp <> "UNKNOWN" And $OpenAttributesArray[$FoundInTable][9] <> 0 Then ;Why do these sometimes point to offsets in OpenAttributeTable containing invalid data?
			If $IsNt5x=0 Or $OpenAttributesArray[$FoundInTable][7]>0 Then ;target_attribute is handled differently on nt5.x than nt6.x
				$AttributeString = $AttributeStringTmp
				If $OpenAttributesArray[$FoundInTable][12] <> "" Then
					$AttributeString &= ":"&$OpenAttributesArray[$FoundInTable][12]
				EndIf
		;		$PredictedRefNumber = $OpenAttributesArray[$FoundInTable][7]
				$RealMftRef = $OpenAttributesArray[$FoundInTable][7]
				If $redo_operation_hex = "0800" Then $PredictedRefNumber = $RealMftRef
				If $PredictedRefNumber = -1 Then $PredictedRefNumber = $RealMftRef
			EndIf
		Else
			$InOpenAttributeTable = "-" & $InOpenAttributeTable ;Will indicate an offset match in OpenAttributeTable that contains invalid data.
		EndIf
	EndIf
	If $PredictedRefNumber = 0 Then
;		If $target_attribute = 0x0018 And Ubound($OpenAttributesArray) > 1 Then
		If Ubound($OpenAttributesArray) > 1 Then
			$FoundInTable = _ArraySearch($OpenAttributesArray,$target_attribute,0,0,0,2,1,0)
	;		ConsoleWrite("$FoundInTable: " & $FoundInTable & @CRLF)
			If $FoundInTable > 0 Then
				$AttributeStringTmp = _ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTable][5],3,4))
				If $AttributeStringTmp <> "UNKNOWN" And $AttributeStringTmp <> "$DATA" Then
					$AttributeString = $AttributeStringTmp
				EndIf
				If $OpenAttributesArray[$FoundInTable][12] <> "" And $AttributeString <> "" Then
					$AttributeString &= ":"&$OpenAttributesArray[$FoundInTable][12]
				EndIf
			Else
				_DumpOutput("Error: $target_attribute was not found in array: " & $target_attribute & " at lsn " & $this_lsn & @CRLF)
;				_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
			EndIf
		EndIf
	EndIf
Else
	If $FoundInTableSlack > 0 Then
	;	ConsoleWrite("ubound($OpenAttributesArray): " & ubound($OpenAttributesArray) & @CRLF)
		$AttributeStringTmp = _ResolveAttributeType(StringMid($SlackOpenAttributesArray[$FoundInTableSlack][5],3,4))
		If $AttributeStringTmp <> "UNKNOWN" And $SlackOpenAttributesArray[$FoundInTableSlack][9] <> 0 Then ;Why do these sometimes point to offsets in OpenAttributeTable containing invalid data?
			$AttributeString = $AttributeStringTmp
			If $SlackOpenAttributesArray[$FoundInTableSlack][12] <> "" Then
				$AttributeString &= ":"&$SlackOpenAttributesArray[$FoundInTableSlack][12]
			EndIf
	;		$PredictedRefNumber = $OpenAttributesArray[$FoundInTable][7]
;			$RealMftRef = $SlackOpenAttributesArray[$FoundInTableSlack][7]
;			If $redo_operation_hex = "0800" Then $PredictedRefNumber = $RealMftRef
;			If $PredictedRefNumber = -1 Then $PredictedRefNumber = $RealMftRef
		Else
;			$InOpenAttributeTable = "-" & $InOpenAttributeTable ;Will indicate an offset match in OpenAttributeTable that contains invalid data.
		EndIf
	EndIf
EndIf
;if $redo_operation_hex="1b00" Then
;	MsgBox(0,"lsn: " & $this_lsn,"Ref: " & ((Dec($target_vcn,2)*$BytesPerCluster)/$MFT_Record_Size)+((Dec($MftClusterIndex,2)*512)/$MFT_Record_Size))
;	$PredictedRefNumber = ((Dec($target_vcn,2)*$BytesPerCluster)/$MFT_Record_Size)+((Dec($MftClusterIndex,2)*512)/$MFT_Record_Size)
;EndIf
#cs
If $redo_operation_hex="1500" or $redo_operation_hex="1600" Then
	$VerboseOn=1
Else
	$VerboseOn=0
EndIf
#ce

;If $this_lsn=105054169 Or $this_lsn=105054288  Or $this_lsn=5693203315 Or $this_lsn=105061642  Or $this_lsn=100666594 Or $this_lsn= 100666924 Then
;	$VerboseOn=1
;Else
;	$VerboseOn=0
;EndIf
;If $this_lsn=278686421041 Or $this_lsn=278686421187 Then
;	$VerboseOn=1
;Else
;	$VerboseOn=0
;EndIf

If $VerboseOn Then
;If Dec($client_undo_next_lsn) <> $client_previous_lsn Then
;If $redo_operation_hex="1b00" Then
	_DumpOutput("Calculated RefNumber: " & ((Dec($target_vcn,2)*$BytesPerCluster)/$MFT_Record_Size)+((Dec($MftClusterIndex,2)*512)/$MFT_Record_Size) & @CRLF)
	_DumpOutput("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
	_DumpOutput("$KeptRef: " & $KeptRef & @CRLF)
	_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
	_DumpOutput("$client_previous_lsn: " & $client_previous_lsn & @CRLF)
	_DumpOutput("$client_undo_next_lsn: " & $client_undo_next_lsn & @CRLF)
	_DumpOutput("$client_data_length: 0x" & Hex($client_data_length,8) & @CRLF)
	_DumpOutput("$client_index: " & $client_index & @CRLF)
	_DumpOutput("$record_type: " & $record_type & @CRLF)
	_DumpOutput("$transaction_id: " & $transaction_id & @CRLF)
	_DumpOutput("$lf_flags: " & $lf_flags & @CRLF)
	_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
	_DumpOutput("$redo_operation_hex: 0x" & $redo_operation_hex & @CRLF)
	_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
	_DumpOutput("$undo_operation_hex: 0x" & $undo_operation_hex & @CRLF)
	_DumpOutput("$redo_offset: " & $redo_offset & @CRLF)
	_DumpOutput("$redo_length: " & $redo_length & @CRLF)
	_DumpOutput("$undo_offset: " & $undo_offset & @CRLF)
	_DumpOutput("$undo_length: " & $undo_length & @CRLF)
	_DumpOutput("$target_attribute: " & $target_attribute & @CRLF)
	_DumpOutput("$lcns_to_follow: " & $lcns_to_follow & @CRLF)
	_DumpOutput("$record_offset_in_mft: 0x" & Hex($record_offset_in_mft,8) & @CRLF)
	_DumpOutput("$attribute_offset: 0x" & Hex($attribute_offset,8) & @CRLF)
	_DumpOutput("$MftClusterIndex: " & $MftClusterIndex & @CRLF)
	_DumpOutput("$target_vcn: " & $target_vcn & @CRLF)
	_DumpOutput("$target_lcn: " & $target_lcn & @CRLF)
	_DumpOutput("$AttributeString: " & $AttributeString & @CRLF)
	_DumpOutput("$FoundInTable: " & $FoundInTable & @CRLF)
	_DumpOutput(@CRLF)
;	MsgBox(0,"Verbose","Check output")
EndIf
;If $undo_operation_hex="0100" And (((Dec($target_vcn,2)*$BytesPerCluster)/$MFT_Record_Size)+((Dec($MftClusterIndex,2)*512)/$MFT_Record_Size) <> 0) Then MsgBox(0,"Info","Check CompensationlogRecord")
;ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
If $redo_length > 0 Then
	$redo_chunk = StringMid($InputData,97+($redo_offset*2),$redo_length*2)
	If $VerboseOn Then
		_DumpOutput("Redo: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
	EndIf
	$RedoChunkSize = StringLen($redo_chunk)/2
	Select
		Case $redo_operation_hex="0200" ;InitializeFileRecordSegment
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
;			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			If $redo_length <= 60 Then
				$TextInformation &= ";Initializing empty record"
			Else
				_ParserCodeOldVersion($redo_chunk)
				If Not $FromRcrdSlack Then
					_UpdateFileNameArray($PredictedRefNumber,$HDR_SequenceNo,$FN_Name,$this_lsn)
				EndIf
			EndIf
		Case $redo_operation_hex="0300" ;DeallocateFileRecordSegment
			_RemoveAllOffsetOfAttribute($PredictedRefNumber)
		Case $redo_operation_hex="0400" ;WriteEndOfFileRecordSegment
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			$TextInformation &= ";Search debug.log for " & $this_lsn
		Case $redo_operation_hex="0500" ; CreateAttribute
			$TestAttributeType = _Decode_AttributeType($redo_chunk)
			If $TestAttributeType <> '' Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $RedoChunkSize, $TestAttributeType)
			_Decode_CreateAttribute($redo_chunk,1)
		Case $redo_operation_hex="0600" ; DeleteAttribute
;			$TestAttributeType = _Decode_AttributeType($undo_chunk)
;			If $TestAttributeType <> '' Then _RemoveSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $TestAttributeType)
		Case $redo_operation_hex="0700" ; UpdateResidentValue
			$ResolvedAttributeOffset = _CheckOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft)
			If Not @error Then
;				$AttributeString&= '->('&$ResolvedAttributeOffset&')'
				$AttributeString = $ResolvedAttributeOffset
			EndIf
			_Decode_UpdateResidentValue($redo_chunk,1)
		Case $redo_operation_hex="0800" ; UpdateNonResidentValue
			If StringLeft($redo_chunk,8) = "494e4458" Then ;INDX
				$TextInformation &= ";INDX"

				If Not $FromRcrdSlack Then
					If $KeptRefTmp = 9 Or $PredictedRefNumber = 9 Or $RealMftRef = 9 Then
						If $KeptRefTmp = 9 Then
							If $FoundInTable < 1 Then $AttributeString = "$INDEX_ALLOCATION(??)"
							$PredictedRefNumber = $KeptRefTmp
							$KeptRef = $KeptRefTmp
						EndIf
						If ($AttributeString = "$INDEX_ALLOCATION:$SDH" Or $AttributeString = "UNKNOWN:$SDH") Then
							$Indx = _GetIndxWoFixup($redo_chunk)
							_DecodeIndxEntriesSDH($Indx,1)
							$TextInformation &= ";See LogFile_SecureSDH.csv"
						ElseIf ($AttributeString = "$INDEX_ALLOCATION:$SII" Or $AttributeString = "UNKNOWN:$SII") Then
							$Indx = _GetIndxWoFixup($redo_chunk)
							_DecodeIndxEntriesSII($Indx,1)
							$TextInformation &= ";See LogFile_SecureSII.csv"
						ElseIf StringMid($redo_chunk,217,8) = "49004900" Then
							$Indx = _GetIndxWoFixup($redo_chunk)
							_DecodeIndxEntriesSII($Indx,1)
							$AttributeString = "$INDEX_ALLOCATION:$SII"
							$TextInformation &= ";See LogFile_SecureSII.csv"
						Else
							_DumpOutput("Error: $Secure contained unidentified INDX at lsn: " & $this_lsn & @CRLF)
							_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
						EndIf
					EndIf
					If $KeptRefTmp = 24 Or $PredictedRefNumber = 24 Or $RealMftRef = 24 Then
						If $KeptRefTmp = 24 Then
							If $FoundInTable < 1 Then $AttributeString = "$INDEX_ALLOCATION($Quota?)"
							$PredictedRefNumber = $KeptRefTmp
							$KeptRef = $KeptRefTmp
						EndIf
						If ($AttributeString = "$INDEX_ALLOCATION:$O" Or $AttributeString = "$INDEX_ROOT:$O" Or $AttributeString = "UNKNOWN:$O") Then
							_Decode_Quota_O($redo_chunk,1)
							$TextInformation &= ";See LogFile_QuotaO.csv"
						EndIf
						If ($AttributeString = "$INDEX_ALLOCATION:$Q" Or $AttributeString = "$INDEX_ROOT:$Q" Or $AttributeString = "UNKNOWN:$Q") Then
							_Decode_Quota_Q($redo_chunk,1)
							$TextInformation &= ";See LogFile_QuotaO.csv"
						EndIf
					EndIf
					If $KeptRefTmp = 25 Or $PredictedRefNumber = 25 Or $RealMftRef = 25 Then
						If $KeptRefTmp = 25 Then
							If $FoundInTable < 1 Then $AttributeString = "$INDEX_ALLOCATION($ObjId?)"
							$PredictedRefNumber = $KeptRefTmp
							$KeptRef = $KeptRefTmp
						EndIf
						If ($AttributeString = "$INDEX_ALLOCATION:$O" Or $AttributeString = "$INDEX_ROOT:$O" Or $AttributeString = "UNKNOWN:$O") Then
							_Decode_ObjId_O($redo_chunk,1)
							$TextInformation &= ";See LogFile_ObjIdO.csv"
						EndIf
					EndIf
					If $KeptRefTmp = 26 Or $PredictedRefNumber = 26 Or $RealMftRef = 26 Then
						If $KeptRefTmp = 26 Then
							If $FoundInTable < 1 Then $AttributeString = "$INDEX_ALLOCATION($Reparse?)"
							$PredictedRefNumber = $KeptRefTmp
							$KeptRef = $KeptRefTmp
						EndIf
						If ($AttributeString = "$INDEX_ALLOCATION:$R" Or $AttributeString = "$INDEX_ROOT:$R" Or $AttributeString = "UNKNOWN:$R") Then
							_Decode_Reparse_R($redo_chunk,1)
							$TextInformation &= ";See LogFile_ReparseR.csv"
						EndIf
					EndIf
				Else

					$DecodeOk=0
					$DecodeOk = _Decode_INDX($redo_chunk)
					If Not $DecodeOk Then ;Possibly $Secure:$SDH or $Secure:$SII
;						ConsoleWrite("_Decode_INDX() failed for $this_lsn: " & $this_lsn & @CRLF)
;						ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
						$Indx = _GetIndxWoFixup($redo_chunk)
						If StringMid($Indx,89,8) = "49004900" Then ;SDH signature
							_DecodeIndxEntriesSDH($Indx,1)
							$TextInformation &= ";See LogFile_SecureSDH.csv"
						Else
							_DecodeIndxEntriesSII($Indx,1)
							$TextInformation &= ";See LogFile_SecureSII.csv"
						EndIf
					Else
						$TextInformation &= ";See LogFile_INDX_I30.csv"
					EndIf
				EndIf
				If $PreviousRedoOp = "1c00" And Not $FromRcrdSlack Then
					If $FoundInTable < 1 Then $AttributeString = $PreviousAttribute
					$PredictedRefNumber = $KeptRef
				EndIf

			Else
				If $FoundInTable > 0 Or $FoundInTableSlack > 0 Then
					Select
						Case $AttributeString = "$ATTRIBUTE_LIST"
							_DecodeAttrList($redo_chunk,1)
							$TextInformation &= ";See LogFile_AttributeList.csv"
						Case $AttributeString = "$Data:$SDS"
							_MainSecure($redo_chunk,1)
							$TextInformation &= ";$Secure:$SDS;See LogFile_SecurityDescriptors.csv"
						Case $AttributeString = "$INDEX_ALLOCATION:$SII"
							$Indx = _GetIndxWoFixup($redo_chunk)
							_DecodeIndxEntriesSII($Indx,1)
							$TextInformation &= ";See LogFile_SecureSII.csv"
						Case $AttributeString = "$INDEX_ALLOCATION:$SDH"
							$Indx = _GetIndxWoFixup($redo_chunk)
							_DecodeIndxEntriesSDH($Indx,1)
							$TextInformation &= ";See LogFile_SecureSDH.csv"
						Case $AttributeString = "$EA"
;							_DumpOutput("Verbose: Nonresident $EA caught at lsn " & $this_lsn & @CRLF)
;							_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
							$Test = _Get_Ea_NonResident($redo_chunk)
							If @error Then
								_DumpOutput("Error: _Get_Ea_NonResident returned: " & $Test & @CRLF)
							EndIf
;							_ArrayDisplay($EaNonResidentArray,"$EaNonResidentArray")
						Case ($PredictedRefNumber = 24 Or $RealMftRef = 24) And ($AttributeString = "$INDEX_ALLOCATION:$O" Or $AttributeString = "$INDEX_ROOT:$O" Or $AttributeString = "UNKNOWN:$O")
							_Decode_Quota_O($redo_chunk,1)
							$TextInformation &= ";See LogFile_QuotaO.csv"
						Case ($PredictedRefNumber = 24 Or $RealMftRef = 24) And ($AttributeString = "$INDEX_ALLOCATION:$Q" Or $AttributeString = "$INDEX_ROOT:$Q" Or $AttributeString = "UNKNOWN:$Q")
							_Decode_Quota_Q($redo_chunk,1)
							$TextInformation &= ";See LogFile_QuotaQ.csv"
						Case ($PredictedRefNumber = 25 Or $RealMftRef = 25) And ($AttributeString = "$INDEX_ALLOCATION:$O" Or $AttributeString = "$INDEX_ROOT:$O" Or $AttributeString = "UNKNOWN:$O")
							_Decode_ObjId_O($redo_chunk,1)
							$TextInformation &= ";See LogFile_ObjIdO.csv"
						Case ($PredictedRefNumber = 26 Or $RealMftRef = 26) And ($AttributeString = "$INDEX_ALLOCATION:$R" Or $AttributeString = "$INDEX_ROOT:$R" Or $AttributeString = "UNKNOWN:$R")
							_Decode_Reparse_R($redo_chunk,1)
							$TextInformation &= ";See LogFile_ReparseR.csv"
						Case $AttributeString = "$DATA:$J"
							$UsnOk=0
							$UsnOk = _UsnDecodeRecord2($redo_chunk)
							If $UsnOk Then
								If Not $FromRcrdSlack Then
									_UpdateFileNameArray($PredictedRefNumber,$HDR_SequenceNo,$FN_Name,$this_lsn)
								EndIf
								$TextInformation &= ";$UsnJrnl"
							Else
								_DumpOutput("_UsnDecodeRecord2() failed and probably not Filling of zeros to page boundary for $this_lsn: " & $this_lsn & @CRLF)
								_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
							EndIf
						Case $AttributeString = "$LOGGED_UTILITY_STREAM:$TXF_DATA" ;may only be resident..
							_DumpOutput("Verbose: Not yet implemented for $LOGGED_UTILITY_STREAM:$TXF_DATA." & @CRLF)
							_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
							_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
							_DumpOutput(_HexEncode("0x"&$redo_chunk) & @crlf)
							$TextInformation &= ";Search debug.log for " & $this_lsn
;							MsgBox(0,"Error","This indicates an unexpected situation at LSN: " & $this_lsn)
						Case $AttributeString = "$LOGGED_UTILITY_STREAM:$EFS"
							_DumpOutput("Verbose: Not yet implemented for $LOGGED_UTILITY_STREAM:$EFS." & @CRLF)
							_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
							_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
							_DumpOutput(_HexEncode("0x"&$redo_chunk) & @crlf)
							$TextInformation &= ";Search debug.log for " & $this_lsn
;							MsgBox(0,"Error","This indicates an unexpected situation at LSN: " & $this_lsn)
					EndSelect
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
							ElseIf Int($undo_length) >= 32 And $undo_operation_hex="0800" Then
								_MainSecure($redo_chunk,1)
								$TextInformation &= ";$Secure:$SDS;See LogFile_SecurityDescriptors.csv"
							ElseIf Int($undo_length) > 0 And $undo_operation_hex="0800" Then
								$TextInformation &= ";$Secure"
								_DumpOutput("Error in UpdateNonResidentValue: unresolved $Secure: " & $this_lsn & @CRLF)
								_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
							Else
								_DumpOutput("_UsnDecodeRecord2() failed and probably not Filling of zeros to page boundary for $this_lsn: " & $this_lsn & @CRLF)
								_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
							EndIf
						Else ;Likely $Secure:$SDS
	;						ConsoleWrite("_UsnDecodeRecord2() failed and $PreviousRedoOp <> 0b00 for $this_lsn: " & $this_lsn & @CRLF)
	;						ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
							_MainSecure($redo_chunk,1)
							$TextInformation &= ";$Secure:$SDS;See LogFile_SecurityDescriptors.csv"
						EndIf
					Else
						If Not $FromRcrdSlack Then
							_UpdateFileNameArray($PredictedRefNumber,$HDR_SequenceNo,$FN_Name,$this_lsn)
						EndIf
						$TextInformation &= ";$UsnJrnl"
					EndIf
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
		Case $redo_operation_hex="0a00" ;DeleteDirtyClusters
			_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
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
			Else
;				_DumpOutput("Error at LSN: " & $this_lsn & @CRLF)
;				_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
;				_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			EndIf
		Case $redo_operation_hex="0c00" Or $redo_operation_hex="0d00" Or $redo_operation_hex="0e00" Or $redo_operation_hex="0f00" ;AddindexEntryRoot,DeleteindexEntryRoot,AddIndexEntryAllocation,DeleteIndexEntryAllocation
			If ($redo_operation_hex="0c00" Or $redo_operation_hex="0d00") And $AttributeString="" Then $AttributeString = "$INDEX_ROOT"
			If ($redo_operation_hex="0e00" Or $redo_operation_hex="0f00") And $AttributeString="" Then $AttributeString = "$INDEX_ALLOCATION"

			If StringInStr($AttributeString,"$I30") Then
				$DecodeOk=0
				$DecodeOk = _Decode_IndexEntry($redo_chunk,$redo_operation_hex,1)
				If Not $DecodeOk Then
					If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
					_DumpOutput("_Decode_IndexEntry() failed for $this_lsn: " & $this_lsn & @CRLF)
					_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
				Else
					If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($RealMftRef, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
				EndIf
			Else
				Select
					Case $PredictedRefNumber = 9 Or $RealMftRef = 9 ;$Secure
						If $redo_length = 40 Then ;$SII
							_DecodeIndxEntriesSII($redo_chunk,1)
							$TextInformation &= ";$Secure:$SII;See LogFile_SecureSII.csv"
							$AttributeString &= ":$SII"
						ElseIf $redo_length = 48 Then  ;$SDH
							_DecodeIndxEntriesSDH($redo_chunk,1)
							$TextInformation &= ";$Secure:$SDH;See LogFile_SecureSDH.csv"
							$AttributeString &= ":$SDH"
						EndIf

					Case $PredictedRefNumber = 24 Or $RealMftRef = 24 ;$Quota
						If $redo_length > 68 Then
							_Decode_Quota_Q($redo_chunk,1)
							$TextInformation &= ";See LogFile_QuotaQ.csv"
						Else
							_Decode_Quota_O($redo_chunk,1)
							$TextInformation &= ";See LogFile_QuotaO.csv"
						EndIf

					Case $PredictedRefNumber = 25 Or $RealMftRef = 25 ;$ObjId
	;					If $redo_length = 88 Then ;also 96..
							_Decode_ObjId_O($redo_chunk,1)
							$TextInformation &= ";See LogFile_ObjIdO.csv"
	;					EndIf

					Case $PredictedRefNumber = 26 Or $RealMftRef = 26 ;$Reparse
						_Decode_Reparse_R($redo_chunk,1)
						$TextInformation &= ";See LogFile_ReparseR.csv"

					Case Else
						$DecodeOk=0
						$DecodeOk = _Decode_IndexEntry($redo_chunk,$redo_operation_hex,1)
						If Not $DecodeOk Then
							If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
							_DumpOutput("_Decode_IndexEntry() failed for $this_lsn: " & $this_lsn & @CRLF)
							_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
						Else
							If $redo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($RealMftRef, $record_offset_in_mft, $RedoChunkSize, '$INDEX_ROOT')
						EndIf
				EndSelect
			EndIf
		Case $redo_operation_hex="1000" ; WriteEndOfIndexBuffer -> always 0 (on nt6x?) but check undo
			If $AttributeString="" Then $AttributeString = "$INDEX_ALLOCATION"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1100" ; SetIndexEntryVcnRoot
			_Decode_SetIndexEntryVcn($redo_chunk)
			$AttributeString = "$INDEX_ROOT"
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1200" ; SetIndexEntryVcnAllocation
			_Decode_SetIndexEntryVcn($redo_chunk)
			$AttributeString = "$INDEX_ALLOCATION"
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
			If Not $FromRcrdSlack Then
				If $KeptRefTmp > 0 And $client_previous_lsn = 0 Then
					$PredictedRefNumber = $KeptRefTmp
					$KeptRef = $KeptRefTmp
				EndIf
			EndIf
			_Decode_FileName($redo_chunk)
			If $PreviousRedoOp = "1c00" Then
				$AttributeString = $PreviousAttribute
			Else
				$AttributeString = "$INDEX_ALLOCATION"
				$RealMftRef = "Parent"
			EndIf
		Case $redo_operation_hex="1500" ;SetBitsInNonresidentBitMap
			_Decode_BitsInNonresidentBitMap2($redo_chunk)
		Case $redo_operation_hex="1600"  ;ClearBitsInNonresidentBitMap
;			_Decode_BitsInNonresidentBitMap2($redo_chunk)
		Case $redo_operation_hex="1700" ;HotFix
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1800" ;EndTopLevelAction
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1900" ;PrepareTransaction
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1c00" ; OpenNonresidentAttribute
			If Not $FromRcrdSlack Then
				$FoundInTableDummy = _Decode_OpenNonresidentAttribute($redo_chunk)
				If $undo_length = 0 Then ;We inject an empty name in array since the undo part did not contain any name (should never happen though)..
					If $FoundInTableDummy > 0 Then
						$OpenAttributesArray[$FoundInTableDummy][12] = ""
						FileWriteLine($LogFileOpenAttributeTableCsv, $RecordOffset&$de&$this_lsn&$de&$OpenAttributesArray[$FoundInTableDummy][0]&$de&$OpenAttributesArray[$FoundInTableDummy][12]&$de&$OpenAttributesArray[$FoundInTableDummy][1]&$de&$OpenAttributesArray[$FoundInTableDummy][2]&$de&$OpenAttributesArray[$FoundInTableDummy][3]&$de&$OpenAttributesArray[$FoundInTableDummy][4]&$de&$OpenAttributesArray[$FoundInTableDummy][5]&$de&_ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTableDummy][5],3,4))&$de&$OpenAttributesArray[$FoundInTableDummy][6]&$de&$OpenAttributesArray[$FoundInTableDummy][7]&$de&$OpenAttributesArray[$FoundInTableDummy][8]&$de&$OpenAttributesArray[$FoundInTableDummy][9]&$de&$OpenAttributesArray[$FoundInTableDummy][10]&$de&$OpenAttributesArray[$FoundInTableDummy][11]&$de&$OpenAttributesArray[$FoundInTableDummy][13]&@crlf)
					EndIf
				EndIf
			EndIf
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case $redo_operation_hex="1D00" ;OpenAttributeTableDump
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
;			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			If Not $FromRcrdSlack Then
				$OpenAttributesArray = 0
				Global $OpenAttributesArray[1][14]
				If $IsNt5x Then
					_Decode_OpenAttributeTableDumpNt5x($redo_chunk,1)
				Else
					_Decode_OpenAttributeTableDumpNt6x($redo_chunk,1)
				EndIf
				$TextInformation &= ";See LogFile_OpenAttributeTable.csv"
			Else
				$SlackOpenAttributesArray = 0
				Global $SlackOpenAttributesArray[1][14]
				If $IsNt5x Then
					_Decode_SlackOpenAttributeTableDumpNt5x($redo_chunk,1)
				Else
					_Decode_SlackOpenAttributeTableDumpNt6x($redo_chunk,1)
				EndIf
				$TextInformation &= ";See LogFile_SlackOpenAttributeTable.csv"
			EndIf
		Case $redo_operation_hex="1E00" ;AttributeNamesDump
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
			If Not $FromRcrdSlack Then
				_Decode_AttributeNamesDump($redo_chunk)
			Else
				_Decode_SlackAttributeNamesDump($redo_chunk)
			EndIf
		Case $redo_operation_hex="1F00" ;DirtyPageTableDump
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$redo_operation: " & $redo_operation & @CRLF)
;			ConsoleWrite("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$redo_chunk) & @CRLF)
			_Decode_DirtyPageTableDump($redo_chunk)
			$TextInformation &= ";See LogFile_DirtyPageTable.csv"
		Case $redo_operation_hex="2000" ;TransactionTableDump
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
;			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			_Decode_TransactionTableDump($redo_chunk)
			$TextInformation &= ";See LogFile_TransactionTable.csv"
		Case $redo_operation_hex="2100" ;UpdateRecordDataRoot
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
;			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			_Decode_Quota_Q_SingleEntry($redo_chunk,1)
			$TextInformation &= ";See LogFile_QuotaQ.csv"
		Case $redo_operation_hex="2200" ;UpdateRecordDataAllocation
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
;			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
			_Decode_Quota_Q_SingleEntry($redo_chunk,1)
			$TextInformation &= ";See LogFile_QuotaQ.csv"
		Case $redo_operation = "UNKNOWN"
			$TextInformation &= ";RedoOperation="&$redo_operation_hex
			_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
		Case Else
			_DumpOutput("Missed transaction!" & @CRLF)
			_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
			_DumpOutput("$redo_operation_hex: " & $redo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$redo_chunk) & @CRLF)
	EndSelect
Else
	$RedoChunkSize = 0
EndIf

If $undo_length > 0 Then ; Not needed I guess
	$undo_chunk = StringMid($InputData,97+($undo_offset*2),$undo_length*2)
	If $VerboseOn Then
		_DumpOutput("Undo: " & $undo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
	endif
	$UndoChunkSize = StringLen($undo_chunk)/2
	Select
		Case $undo_operation_hex="0000" ; NoOp
			If Not $FromRcrdSlack Then
				If Int($undo_offset)+Int($undo_length) > StringLen($InputData) Then
	;				MsgBox(0,"Error","$undo_offset > StringLen($InputData) for LSN: " & $this_lsn)
				Else
					$AttrNameTmp = _Decode_AttributeName($undo_chunk)
					If $FoundInTableDummy > 0 Then
	;					MsgBox(0,"Info","Writing entry")
						$OpenAttributesArray[$FoundInTableDummy][12] = $AttrNameTmp
						FileWriteLine($LogFileOpenAttributeTableCsv, $RecordOffset&$de&$this_lsn&$de&$OpenAttributesArray[$FoundInTableDummy][0]&$de&$OpenAttributesArray[$FoundInTableDummy][12]&$de&$OpenAttributesArray[$FoundInTableDummy][1]&$de&$OpenAttributesArray[$FoundInTableDummy][2]&$de&$OpenAttributesArray[$FoundInTableDummy][3]&$de&$OpenAttributesArray[$FoundInTableDummy][4]&$de&$OpenAttributesArray[$FoundInTableDummy][5]&$de&_ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTableDummy][5],3,4))&$de&$OpenAttributesArray[$FoundInTableDummy][6]&$de&$OpenAttributesArray[$FoundInTableDummy][7]&$de&$OpenAttributesArray[$FoundInTableDummy][8]&$de&$OpenAttributesArray[$FoundInTableDummy][9]&$de&$OpenAttributesArray[$FoundInTableDummy][10]&$de&$OpenAttributesArray[$FoundInTableDummy][11]&$de&$OpenAttributesArray[$FoundInTableDummy][13]&@crlf)
	;					FileWriteLine($LogFileOpenAttributeTableCsv, $RecordOffset&$de&$this_lsn&$de&$OpenAttributesArray[$FoundInTableDummy][0]&$de&$OpenAttributesArray[$FoundInTableDummy][12]&$de&$OpenAttributesArray[$FoundInTableDummy][1]&$de&$OpenAttributesArray[$FoundInTableDummy][2]&$de&$OpenAttributesArray[$FoundInTableDummy][3]&$de&$OpenAttributesArray[$FoundInTableDummy][4]&$de&$OpenAttributesArray[$FoundInTableDummy][5]&$de&_ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTableDummy][5],3,4))&$de&$OpenAttributesArray[$FoundInTableDummy][6]&$de&$OpenAttributesArray[$FoundInTableDummy][7]&$de&$OpenAttributesArray[$FoundInTableDummy][8]&$de&$OpenAttributesArray[$FoundInTableDummy][9]&$de&$OpenAttributesArray[$FoundInTableDummy][10]&$de&"0xDEADBEEF"&@crlf)
						If $VerboseOn Then
							_DumpOutput("_Decode_AttributeName() returned: " & $AttrNameTmp & @CRLF)
							_DumpOutput("Updating $OpenAttributesArray at row: " & $FoundInTableDummy & @CRLF)
							_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
						EndIf
					EndIf
				EndIf
			EndIf
		Case $undo_operation_hex="0100" ;CompensationlogRecord
		Case $undo_operation_hex="0200" ;InitializeFileRecordSegment
;			_ParserCodeOldVersion($undo_chunk)
		Case $undo_operation_hex="0400" ; WriteEndOfFileRecordSegment
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
;			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="0500" ; CreateAttribute
			$TestAttributeType = _Decode_AttributeType($undo_chunk)
			If $TestAttributeType <> '' Then _RemoveSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $UndoChunkSize, $TestAttributeType)
			_Decode_CreateAttribute($undo_chunk,0)
		Case $undo_operation_hex="0700" ; UpdateResidentValue
			_Decode_UpdateResidentValue($undo_chunk,0)
		Case $undo_operation_hex="0900"
;			_Decode_UpdateMappingPairs($undo_chunk)
		Case $undo_operation_hex="0800" ; UpdateNonResidentValue
;			If StringLeft($undo_chunk,8) = "494e4458" Then _Decode_INDX($undo_chunk)
		Case $undo_operation_hex="0b00"
;			_Decode_SetNewAttributeSize($undo_chunk)
		Case $undo_operation_hex="0c00" Or $undo_operation_hex="0e00"
			#cs
			If $undo_length*2>168 Then
				$DecodeOk = _Decode_IndexEntry($undo_chunk,$undo_operation_hex,0)
				If Not $DecodeOk Then
					_DumpOutput("_Decode_IndexEntry() failed at undo for $this_lsn: " & $this_lsn & @CRLF)
					_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
				EndIf
			Else
				_DumpOutput(@CRLF & "Unresolved: " & $undo_operation & @CRLF)
				_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
				_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
			EndIf
			#ce
			Select
				Case $PredictedRefNumber = 9 Or $RealMftRef = 9 ;$Secure
					If $undo_length = 40 Then ;$SII
						_DecodeIndxEntriesSII($undo_chunk,0)
						$TextInformation &= ";$Secure:$SII;See LogFile_SecureSII.csv"
						$AttributeString &= ":$SII"
					ElseIf $undo_length = 48 Then  ;$SDH
						_DecodeIndxEntriesSDH($undo_chunk,0)
						$TextInformation &= ";$Secure:$SDH;See LogFile_SecureSDH.csv"
						$AttributeString &= ":$SDH"
					EndIf

				Case $PredictedRefNumber = 24 Or $RealMftRef = 24 ;$Quota
					If $undo_length > 68 Then
						_Decode_Quota_Q($undo_chunk,0)
						$TextInformation &= ";See LogFile_QuotaQ.csv"
					Else
						_Decode_Quota_O($undo_chunk,0)
						$TextInformation &= ";See LogFile_QuotaO.csv"
					EndIf

				Case $PredictedRefNumber = 25 Or $RealMftRef = 25 ;$ObjId
					If $undo_length = 88 Then
						_Decode_ObjId_O($undo_chunk,0)
						$TextInformation &= ";See LogFile_ObjIdO.csv"
					EndIf

				Case Else
					If $undo_length*2>168 Then
						$DecodeOk=0
						$DecodeOk = _Decode_IndexEntry($undo_chunk,$undo_operation_hex,0)
						If Not $DecodeOk Then
	;						If $undo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($PredictedRefNumber, $record_offset_in_mft, $UndoChunkSize, '$INDEX_ROOT')
							_DumpOutput("_Decode_IndexEntry() failed at undo for $this_lsn: " & $this_lsn & @CRLF)
							_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
						Else
;							If $undo_operation_hex="0c00" Then _UpdateSingleOffsetOfAttribute($RealMftRef, $record_offset_in_mft, $UndoChunkSize, '$INDEX_ROOT')
						EndIf
					Else
						_DumpOutput(@CRLF & "Error: Unresolved: " & $undo_operation & @CRLF)
						_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
						_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
					EndIf
			EndSelect
		Case $undo_operation_hex="1000" ; WriteEndOfIndexBuffer
			Select
				Case $AttributeString = "$ATTRIBUTE_LIST"
					_DecodeAttrList($undo_chunk,0)
					$TextInformation &= ";See LogFile_AttributeList.csv"
				Case $AttributeString = "$Data:$SDS"
					_MainSecure($undo_chunk,0)
					$TextInformation &= ";$Secure:$SDS;See LogFile_SecurityDescriptors.csv"
				Case $AttributeString = "$INDEX_ALLOCATION:$SII"
					$Indx = _GetIndxWoFixup($undo_chunk)
					_DecodeIndxEntriesSII($Indx,0)
					$TextInformation &= ";See LogFile_SecureSII.csv"
				Case $AttributeString = "$INDEX_ALLOCATION:$SDH"
					$Indx = _GetIndxWoFixup($undo_chunk)
					_DecodeIndxEntriesSDH($Indx,0)
					$TextInformation &= ";See LogFile_SecureSDH.csv"
				Case ($PredictedRefNumber = 24 Or $RealMftRef = 24) And ($AttributeString = "$INDEX_ALLOCATION:$O" Or $AttributeString = "$INDEX_ROOT:$O" Or $AttributeString = "UNKNOWN:$O")
					_Decode_Quota_O($undo_chunk,0)
					$TextInformation &= ";See LogFile_QuotaO.csv"
				Case ($PredictedRefNumber = 24 Or $RealMftRef = 24) And ($AttributeString = "$INDEX_ALLOCATION:$Q" Or $AttributeString = "$INDEX_ROOT:$Q" Or $AttributeString = "UNKNOWN:$Q")
					_Decode_Quota_Q($undo_chunk,0)
					$TextInformation &= ";See LogFile_QuotaQ.csv"
				Case ($PredictedRefNumber = 25 Or $RealMftRef = 25) And ($AttributeString = "$INDEX_ALLOCATION:$O" Or $AttributeString = "$INDEX_ROOT:$O" Or $AttributeString = "UNKNOWN:$O")
					_Decode_ObjId_O($undo_chunk,0)
					$TextInformation &= ";See LogFile_ObjIdO.csv"
				Case ($PredictedRefNumber = 26 Or $RealMftRef = 26) And ($AttributeString = "$INDEX_ALLOCATION:$R" Or $AttributeString = "$INDEX_ROOT:$R" Or $AttributeString = "UNKNOWN:$R")
					_Decode_Reparse_R($undo_chunk,0)
					$TextInformation &= ";See LogFile_ReparseR.csv"
				Case Not ($PredictedRefNumber = 9 Or $PredictedRefNumber = 24 Or $PredictedRefNumber = 25 Or $PredictedRefNumber = 26 Or $RealMftRef = 9 Or $RealMftRef = 24 Or $RealMftRef = 25 Or $RealMftRef = 26) And $AttributeString = "$INDEX_ALLOCATION:$I30"
					$DecodeOk=0
					$DecodeOk = _Decode_UndoWipeINDX($undo_chunk)
					If Not $DecodeOk Then
						_DumpOutput(@CRLF & "_Decode_UndoWipeINDX() failed for $this_lsn: " & $this_lsn & @CRLF)
						_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
					EndIf
				Case Else
					_DumpOutput("Unresolved: " & $undo_operation & @CRLF)
					_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
					_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
			EndSelect
;--------------------------------------------
#cs
			If Not ($PredictedRefNumber = 9 Or $PredictedRefNumber = 24 Or $PredictedRefNumber = 25 Or $PredictedRefNumber = 26 Or $RealMftRef = 9 Or $RealMftRef = 24 Or $RealMftRef = 25 Or $RealMftRef = 26) Then
;			If ($PredictedRefNumber <> 9 And $PredictedRefNumber <> 24 And $PredictedRefNumber <> 25 And $PredictedRefNumber <> 26) Or ($RealMftRef <> 9 And $RealMftRef <> 24 And $RealMftRef <> 25 And $RealMftRef <> 26) Then
;			If $undo_length*2>168 Then
				$DecodeOk=0
				$DecodeOk = _Decode_UndoWipeINDX($undo_chunk)
				If Not $DecodeOk Then
					_DumpOutput(@CRLF & "_Decode_UndoWipeINDX() failed for $this_lsn: " & $this_lsn & @CRLF)
					_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
;				Else
;					$TextInformation &= ";INDX"
				EndIf
			Else
				_DumpOutput("Unresolved: " & $undo_operation & @CRLF)
				_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
				_DumpOutput("Though it is probably ok to not bother with undo of indexes that are not of type $I30." & @CRLF)
				_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
;				MsgBox(0,"Info","Check output of transaction with lsn: " & $this_lsn)
			EndIf

#ce
		Case $undo_operation_hex="1100" ; SetIndexEntryVcnRoot
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1200" ; SetIndexEntryVcnAllocation
		Case $undo_operation_hex="1300" ; UpdateFileNameRoot
;			_Decode_FileName($undo_chunk)
		Case $undo_operation_hex="1400" ; UpdateFileNameAllocation
;			_Decode_FileName($undo_chunk)
		Case $undo_operation_hex="1500" ; SetBitsInNonresidentBitMap
			_Decode_BitsInNonresidentBitMap($redo_chunk,$redo_operation,$undo_chunk,$undo_operation)
			$TextInformation &= ";See LogFile_BitsInNonresidentBitMap.csv"
		Case $undo_operation_hex="1600" ; ClearBitsInNonresidentBitMap
			_Decode_BitsInNonresidentBitMap($redo_chunk,$redo_operation,$undo_chunk,$undo_operation)
			$TextInformation &= ";See LogFile_BitsInNonresidentBitMap.csv"
		Case $undo_operation_hex="1700" ;HotFix
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1800" ;EndTopLevelAction
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1900" ;PrepareTransaction
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1D00" ;OpenAttributeTableDump
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1E00" ;AttributeNamesDump
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="1F00" ;DirtyPageTableDump
;			ConsoleWrite("$this_lsn: " & $this_lsn & @CRLF)
;			ConsoleWrite("$undo_operation: " & $undo_operation & @CRLF)
;			ConsoleWrite("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			ConsoleWrite(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="2000" ;TransactionTableDump
			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case $undo_operation_hex="2100" ;UpdateRecordDataRoot
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
;			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
			_Decode_Quota_Q_SingleEntry($undo_chunk,0)
		Case $undo_operation_hex="2200" ;UpdateRecordDataAllocation
;			_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
;			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
;			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
;			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
			_Decode_Quota_Q_SingleEntry($undo_chunk,0)
		Case $undo_operation = "UNKNOWN"
			_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$undo_operation: " & $undo_operation & @CRLF)
			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
		Case Else
			_DumpOutput("Missed transaction!" & @CRLF)
			_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
			_DumpOutput("$undo_operation_hex: " & $undo_operation_hex & @CRLF)
			_DumpOutput(_HexEncode("0x"&$undo_chunk) & @CRLF)
	EndSelect
Else
	$UndoChunkSize = 0
EndIf

If Not $FromRcrdSlack Then
	If $SI_USN = $PreviousUsn And $SI_USN <> "" Then
	;	MsgBox(0,"Usn:","$PreviousUsn: " & $PreviousUsn & ", $PreviousUsnFileName: " & $PreviousUsnFileName)
		$FN_Name = $PreviousUsnFileName
	EndIf
	If $client_previous_lsn=0 Then
		$PreviousRealRef=""
	EndIf
	If $undo_operation = "UNKNOWN" Then $TextInformation &= ";UndoOperation="&$undo_operation_hex

	$PreviousRedoOp = $redo_operation_hex
	$PreviousAttribute = $AttributeString
	If $UsnOk Then
		$PreviousUsn = $UsnJrnlUsn
		$PreviousUsnFileName = $UsnJrnlFileName
		$PreviousUsnReason = $UsnJrnlReason
	EndIf
	If $FoundInTable > 0 Then
	;	ConsoleWrite("ubound($OpenAttributesArray): " & ubound($OpenAttributesArray) & @CRLF)
		$AttributeStringTmp = _ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTable][5],3,4))
		If $AttributeStringTmp <> "UNKNOWN" And $OpenAttributesArray[$FoundInTable][9] <> 0 Then ;Why do these sometimes point to offsets in OpenAttributeTable containing invalid data?
			If $IsNt5x=0 Or $OpenAttributesArray[$FoundInTable][7]>0 Then ;target_attribute is handled differently on nt5.x than nt6.x
				$AttributeString = $AttributeStringTmp
				If $OpenAttributesArray[$FoundInTable][12] <> "" Then
					$AttributeString &= ":"&$OpenAttributesArray[$FoundInTable][12]
				EndIf

	;			$PredictedRefNumber = $OpenAttributesArray[$FoundInTable][7]
				$RealMftRef = $OpenAttributesArray[$FoundInTable][7]
				$PredictedRefNumber = $RealMftRef
				If $PredictedRefNumber = -1 Then $PredictedRefNumber = $RealMftRef
			EndIf
		Else
			$InOpenAttributeTable = "-" & $InOpenAttributeTable ;Will indicate an offset match in OpenAttributeTable that contains invalid data.
		EndIf
	EndIf
	If $PredictedRefNumber = 0 Then
;		If $target_attribute = 0x0018 And Ubound($OpenAttributesArray) > 1 Then
		If Ubound($OpenAttributesArray) > 1 Then
			$FoundInTable = _ArraySearch($OpenAttributesArray,$target_attribute,0,0,0,2,1,0)
	;		ConsoleWrite("$FoundInTable: " & $FoundInTable & @CRLF)
			If $FoundInTable > 0 Then
				$AttributeStringTmp = _ResolveAttributeType(StringMid($OpenAttributesArray[$FoundInTable][5],3,4))
				If $AttributeStringTmp <> "$DATA" And $AttributeStringTmp <> "UNKNOWN" Then
					$AttributeString = $AttributeStringTmp
				EndIf
				If $OpenAttributesArray[$FoundInTable][12] <> "" And $AttributeString <> "" Then
					$AttributeString &= ":"&$OpenAttributesArray[$FoundInTable][12]
				EndIf
			Else
				_DumpOutput("Error: $target_attribute was not found in array: " & $target_attribute & " at lsn " & $this_lsn & @CRLF)
;				_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
			EndIf
;		Else
;			$PredictedRefNumber = $RealMftRef
		EndIf
	EndIf
EndIf

If $PredictedRefNumber > 0 And $FN_Name="" Then
	$FN_Name = _GetFileNameFromArray($PredictedRefNumber,$this_lsn)
EndIf

If $FN_Name="" Then _SetNameOnSystemFiles()

_WriteLogFileCsv()
If $DoSplitCsv Then _WriteCSVExtra()

If $VerboseOn Then
	_DumpOutput("End of function, check the output." & @CRLF)
	MsgBox(0,"VerboseOn","Check output of lsn: " & $this_lsn)
	_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
EndIf

_ClearVar()
EndFunc

Func _DecodeRSTR($RSTRRecord)
Local $Startpos=3
$RSTRRecord = _DoFixup($RSTRRecord)
If $RSTRRecord = "" then Return ""  ;corrupt, failed fixup
_DumpOutput("------------- RSTR -------------" & @CRLF)
;_DumpOutput(_HexEncode($RSTRRecord) & @CRLF)
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
;_DumpOutput("$usa_ofs: " & $usa_ofs & @CRLF)
;_DumpOutput("$usa_count: " & $usa_count & @CRLF)
_DumpOutput("$chkdsk_lsn: " & Dec($chkdsk_lsn,2) & @CRLF)
_DumpOutput("$system_page_size: 0x" & $system_page_size & @CRLF)
_DumpOutput("$log_page_size: 0x" & $log_page_size & @CRLF)
;_DumpOutput("$restart_area_offset: " & $restart_area_offset & @CRLF)
_DumpOutput("$minor_ver: 0x" & _SwapEndian($minor_ver) & @CRLF)
_DumpOutput("$major_ver: 0x" & _SwapEndian($major_ver) & @CRLF)
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

_DumpOutput("--- RSTR: Log file restart area record:" & @CRLF)
If Dec($file_size,2) <> $InputFileSize Then _DumpOutput("Error: The size of the $LogFile as specified in RSTR is not the same as the filesize of input" & @CRLF)
_DumpOutput("$restart_area_offset: " & $restart_area_offset & @CRLF)
_DumpOutput("$current_lsn: " & Dec($current_lsn,2) & @CRLF)
_DumpOutput("$log_clients: 0x" & $log_clients & @CRLF)
_DumpOutput("$client_free_list: 0x" & $client_free_list & @CRLF)
_DumpOutput("$client_in_use_list: 0x" & $client_in_use_list & @CRLF)
_DumpOutput("$RESTART_AREA_FLAGS: 0x" & $RESTART_AREA_FLAGS & @CRLF)
_DumpOutput("$seq_number_bits: 0x" & $seq_number_bits & @CRLF)
_DumpOutput("$restart_area_length: 0x" & $restart_area_length & @CRLF)
_DumpOutput("$client_array_offset: " & $client_array_offset & @CRLF)
_DumpOutput("$file_size: 0x" & $file_size & @CRLF)
_DumpOutput("$last_lsn_data_length: 0x" & $last_lsn_data_length & @CRLF)
_DumpOutput("$log_record_header_length: 0x" & $log_record_header_length & @CRLF)
_DumpOutput("$log_page_data_offset: 0x" & $log_page_data_offset & @CRLF)
_DumpOutput("$restart_log_open_count: 0x" & $restart_log_open_count & @CRLF)
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
$client_name_length = Dec(_SwapEndian($client_name_length),2)
$client_name = StringMid($RSTRRecord,$ClientRecordOffset+64,$client_name_length*2)   ; Normally 8 bytes (NTFS in unicode) + 120 bytes of 00's
_DumpOutput("--- RSTR: Log client record:" & @CRLF)
_DumpOutput("$ClientRecordOffset: " & $ClientRecordOffset & @CRLF)
_DumpOutput("$oldest_lsn: " & Dec($oldest_lsn,2) & @CRLF)
_DumpOutput("$client_restart_lsn: " & Dec($client_restart_lsn,2) & @CRLF)
_DumpOutput("$prev_client: 0x" & $prev_client & @CRLF)
_DumpOutput("$next_client: 0x" & $next_client & @CRLF)
_DumpOutput("$seq_number: 0x" & $seq_number & @CRLF)
;_DumpOutput("$reserved2: " & $reserved2 & @CRLF)
_DumpOutput("$client_name_length (unicode): " & $client_name_length & @CRLF)
_DumpOutput("$client_name: " & BinaryToString("0x"&$client_name,2) & @CRLF)
; End -> size = 160 bytes, 32 bytes + name (128)
_DumpOutput("------------- END RSTR -------------" & @CRLF)
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
	Case $OpCode = 0 ;"00"
		$InterpretedCode = "Noop"
	Case $OpCode = 1 ;"01"
		$InterpretedCode = "CompensationlogRecord"
	Case $OpCode = 2 ;"02"
		$InterpretedCode = "InitializeFileRecordSegment"
	Case $OpCode = 3 ;"03"
		$InterpretedCode = "DeallocateFileRecordSegment"
	Case $OpCode = 4 ;"04"
		$InterpretedCode = "WriteEndofFileRecordSegement"
	Case $OpCode = 5 ;"05"
		$InterpretedCode = "CreateAttribute"
	Case $OpCode = 6 ;"06"
		$InterpretedCode = "DeleteAttribute"
	Case $OpCode = 7 ;"07"
		$InterpretedCode = "UpdateResidentValue"
	Case $OpCode = 8 ;"08"
		$InterpretedCode = "UpdateNonResidentValue"
	Case $OpCode = 9 ;"09"
		$InterpretedCode = "UpdateMappingPairs"
	Case $OpCode = 10 ;"0a"
		$InterpretedCode = "DeleteDirtyClusters"
	Case $OpCode = 11 ;"0b"
		$InterpretedCode = "SetNewAttributeSizes"
	Case $OpCode = 12 ;"0c"
		$InterpretedCode = "AddindexEntryRoot"
	Case $OpCode = 13 ;"0d"
		$InterpretedCode = "DeleteindexEntryRoot"
	Case $OpCode = 14 ;"0e"
		$InterpretedCode = "AddIndexEntryAllocation"
	Case $OpCode = 15 ;"0f"
		$InterpretedCode = "DeleteIndexEntryAllocation"
	Case $OpCode = 16 ;"10"
		$InterpretedCode = "WriteEndOfIndexBuffer"
	Case $OpCode = 17 ;"11"
		$InterpretedCode = "SetIndexEntryVcnRoot"
	Case $OpCode = 18 ;"12"
		$InterpretedCode = "SetIndexEntryVcnAllocation"
	Case $OpCode = 19 ;"13"
		$InterpretedCode = "UpdateFileNameRoot"
	Case $OpCode = 20 ;"14"
		$InterpretedCode = "UpdateFileNameAllocation"
	Case $OpCode = 21 ;"15"
		$InterpretedCode = "SetBitsInNonresidentBitMap"
	Case $OpCode = 22 ;"16"
		$InterpretedCode = "ClearBitsInNonresidentBitMap"
	Case $OpCode = 23 ;"17"
		$InterpretedCode = "HotFix"
	Case $OpCode = 24 ;"18"
		$InterpretedCode = "EndTopLevelAction"
	Case $OpCode = 25 ;"19"
		$InterpretedCode = "PrepareTransaction"
	Case $OpCode = 26 ;"1a"
		$InterpretedCode = "CommitTransaction"
	Case $OpCode = 27 ;"1b"
		$InterpretedCode = "ForgetTransaction"
	Case $OpCode = 28 ;"1c"
		$InterpretedCode = "OpenNonresidentAttribute"
	Case $OpCode = 29 ;"1d"
		$InterpretedCode = "OpenAttributeTableDump"
	Case $OpCode = 30 ;"1e"
		$InterpretedCode = "AttributeNamesDump"
	Case $OpCode = 31 ;"1f"
		$InterpretedCode = "DirtyPageTableDump"
	Case $OpCode = 32 ;"20"
		$InterpretedCode = "TransactionTableDump"
	Case $OpCode = 33 ;"21"
		$InterpretedCode = "UpdateRecordDataRoot"
	Case $OpCode = 34 ;"22"
		$InterpretedCode = "UpdateRecordDataAllocation"
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
	Local $UpdSeqArrOffset, $HDR_LSN, $HDR_HardLinkCount, $HDR_Flags, $HDR_RecRealSize, $HDR_RecAllocSize, $HDR_BaseRecSeqNo, $HDR_NextAttribID, $HDR_MFTREcordNumber, $NextAttributeOffset, $AttributeType, $AttributeSize, $RecordActive
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
	EndIf
	If $UpdSeqArrOffset = 48 Then
		$HDR_MFTREcordNumber = StringMid($MFTEntry, 89, 8)
		$HDR_MFTREcordNumber = Dec(_SwapEndian($HDR_MFTREcordNumber),2)
		If $HDR_MFTREcordNumber <> $PredictedRefNumber And $redo_length > 24 And $undo_operation <> "CompensationlogRecord" Then
			If MsgBox(4,"Error with LSN " & $this_lsn,"Predicted Reference number: " & $PredictedRefNumber & " do not match Reference found in $MFT: " & $HDR_MFTREcordNumber & ". Are you sure your SectorsPerCluster (" & $SectorsPerCluster & ") or MFT Record size configuration (" & $MFT_Record_Size & ") is correct?") = 7 Then Exit
		EndIf
	Else
		$HDR_MFTREcordNumber = "NT style"
	EndIf
	If $VerboseOn Then
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
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
;				ConsoleWrite("$SECURITY_DESCRIPTOR:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$CoreAttrChunk) & @CRLF)
				If $CoreAttrChunk <> "" Then
					_DecodeSecurityDescriptorAttribute($CoreAttrChunk)
					;Write information to csv
					_WriteCsvSecureSDS(1)
					;Make sure all global variables for csv are cleared
					_ClearVarSecureSDS()
				EndIf
;				$TextInformation &= ";See LogFile_SecurityDescriptors.csv"
;				$AttributeString = "$SECURITY_DESCRIPTOR"
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
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				_Get_Data($MFTEntry, $NextAttributeOffset, $AttributeSize, $AttributeArray[8][1])
				$TestAttributeString &= '$DATA?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $INDEX_ROOT
				$AttributeKnown = 1
				$AttributeArray[9][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
					If $CoreAttrName = "$I30" Then _Get_IndexRoot($CoreAttrChunk,$CoreAttrName)
				EndIf
				$TestAttributeString &= '$INDEX_ROOT?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $INDEX_ALLOCATION
				$AttributeKnown = 1
				$AttributeArray[10][1] += 1
				$TestAttributeString &= '$INDEX_ALLOCATION?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $BITMAP
				$AttributeKnown = 1
				$AttributeArray[11][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$TestAttributeString &= '$BITMAP?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $REPARSE_POINT
				$AttributeKnown = 1
				$AttributeArray[12][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
					_Get_ReparsePoint($CoreAttrChunk,$CoreAttrName)
				EndIf
				$TestAttributeString &= '$REPARSE_POINT?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $EA_INFORMATION
				$AttributeKnown = 1
				$AttributeArray[13][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
					_Get_EaInformation($CoreAttrChunk)
				EndIf
				$TestAttributeString &= '$EA_INFORMATION?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $EA
				$AttributeKnown = 1
				$AttributeArray[14][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
					_Get_Ea($CoreAttrChunk)
				EndIf
				$TestAttributeString &= '$EA?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $PROPERTY_SET
				$AttributeKnown = 1
				$AttributeArray[15][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$TestAttributeString &= '$PROPERTY_SET?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $LOGGED_UTILITY_STREAM
				$AttributeKnown = 1
				$AttributeArray[16][1] += 1
				$CoreAttr = _GetAttributeEntry(StringMid($MFTEntry,$NextAttributeOffset,$AttributeSize*2))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
					_Get_LoggedUtilityStream($CoreAttrChunk,$CoreAttrName)
				EndIf
				$TestAttributeString &= '$LOGGED_UTILITY_STREAM?'&($NextAttributeOffset-1)/2&','
			Case $AttributeType = $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
;				ConsoleWrite("No more attributes in this record." & @CRLF)

			Case Else
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
;			If $iPrecision>1 Then $sDateTimeStr&=':'&$sMS
			If $iPrecision>1 Then $sDateTimeStr&=$PrecisionSeparator&$sMS
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

Func _Get_ObjectID($MFTEntry,$OBJECTID_Offset,$OBJECTID_Size)
	Local $GUID_ObjectID, $GUID_BirthVolumeID, $GUID_BirthObjectID, $GUID_BirthDomainID
	$GUID_ObjectID = StringMid($MFTEntry,$OBJECTID_Offset+48,32)
	$GUID_ObjectID = _HexToGuidStr($GUID_ObjectID,1)
	Select
		Case $OBJECTID_Size - 24 = 16
			$GUID_BirthVolumeID = "NOT PRESENT"
			$GUID_BirthObjectID = "NOT PRESENT"
			$GUID_BirthDomainID = "NOT PRESENT"
		Case $OBJECTID_Size - 24 = 32
			$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
			$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)
			$GUID_BirthObjectID = "NOT PRESENT"
			$GUID_BirthDomainID = "NOT PRESENT"
		Case $OBJECTID_Size - 24 = 48
			$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
			$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)
			$GUID_BirthObjectID = StringMid($MFTEntry,$OBJECTID_Offset+112,32)
			$GUID_BirthObjectID = _HexToGuidStr($GUID_BirthObjectID,1)
			$GUID_BirthDomainID = "NOT PRESENT"
		Case $OBJECTID_Size - 24 = 64
			$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
			$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)
			$GUID_BirthObjectID = StringMid($MFTEntry,$OBJECTID_Offset+112,32)
			$GUID_BirthObjectID = _HexToGuidStr($GUID_BirthObjectID,1)
			$GUID_BirthDomainID = StringMid($MFTEntry,$OBJECTID_Offset+144,32)
			$GUID_BirthDomainID = _HexToGuidStr($GUID_BirthDomainID,1)
		Case Else
			_DumpOutput("Error: The $OBJECT_ID size was unexpected." & @crlf)
	EndSelect
	$TextInformation &= ";GUID_BirthVolumeID="&$GUID_BirthVolumeID&";GUID_BirthObjectID="&$GUID_BirthObjectID&";GUID_BirthDomainID="&$GUID_BirthDomainID
	If $VerboseOn Then
		_DumpOutput("### $OBJECT_ID ATTRIBUTE ###" & @CRLF)
		_DumpOutput("$GUID_BirthVolumeID: " & $GUID_BirthVolumeID & @CRLF)
		_DumpOutput("$GUID_BirthObjectID: " & $GUID_BirthObjectID & @CRLF)
		_DumpOutput("$GUID_BirthDomainID: " & $GUID_BirthDomainID & @CRLF)
	EndIf
EndFunc

Func _Get_VolumeName($MFTEntry, $VOLUME_NAME_Offset, $VOLUME_NAME_Size)
	Local $VOLUME_NAME_NAME
	ConsoleWrite("### $VOLUME_NAME ATTRIBUTE ###" & @CRLF)
	If $VOLUME_NAME_Size - 24 > 0 Then
		$VOLUME_NAME_NAME = StringMid($MFTEntry, $VOLUME_NAME_Offset + 48, ($VOLUME_NAME_Size - 24) * 2)
;		MsgBox(0,"$VOLUME_NAME_NAME",$VOLUME_NAME_NAME)
		$VOLUME_NAME_NAME = BinaryToString("0x"&$VOLUME_NAME_NAME,2)
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
	$FN_Name = StringMid($MFTEntry, $FN_Offset + 180, $FN_NameLen*4)
	$FN_Name = BinaryToString("0x"&$FN_Name,2)
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
		_DumpOutput("### $DATA ATTRIBUTE " & $DT_Number & " ###" & @CRLF)
		_DumpOutput("$DT_Flags: " & $DT_Flags & @CRLF)
		_DumpOutput("$DT_NonResidentFlag: " & $DT_NonResidentFlag & @CRLF)
		_DumpOutput("$DT_NameLength: " & $DT_NameLength & @CRLF)
		_DumpOutput("$DT_NameRelativeOffset: " & $DT_NameRelativeOffset & @CRLF)
		_DumpOutput("$DT_Flags: " & $DT_Flags & @CRLF)
	EndIf
	If $DT_NameLength > 0 Then
		$DT_NameSpace = $DT_NameLength - 1
		$DT_Name = StringMid($MFTEntry, $DT_Offset + ($DT_NameRelativeOffset * 2), $DT_NameLength*4)
		$DT_Name = BinaryToString("0x"&$DT_Name,2)
		$DT_Name = StringReplace($DT_Name,$de,$CharReplacement)
		$FileNameModified = @extended
		If $VerboseOn Then _DumpOutput("$DT_Name: " & $DT_Name & @CRLF)
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
			_DumpOutput("$DT_StartVCN: " & $DT_StartVCN & @CRLF)
			_DumpOutput("$DT_LastVCN: " & $DT_LastVCN & @CRLF)
			_DumpOutput("$DT_VCNs: " & $DT_VCNs & @CRLF)
			_DumpOutput("$DT_OffsetToDataRuns: " & $DT_OffsetToDataRuns & @CRLF)
			_DumpOutput("$DT_ComprUnitSize: " & $DT_ComprUnitSize & @CRLF)
			_DumpOutput("$DT_AllocSize: " & $DT_AllocSize & @CRLF)
			_DumpOutput("$DT_InitStreamSize: " & $DT_InitStreamSize & @CRLF)
			_DumpOutput("$DT_DataRuns: " & $DT_DataRuns & @CRLF)
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
			_DumpOutput("$DT_LengthOfAttribute: " & $DT_LengthOfAttribute & @CRLF)
			_DumpOutput("$DT_OffsetToAttribute: " & $DT_OffsetToAttribute & @CRLF)
			_DumpOutput("$DT_IndexedFlag: " & $DT_IndexedFlag & @CRLF)
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
		_DumpOutput("_Decode_SetNewAttributeSize():" & @CRLF)
		_DumpOutput("$DT_AllocSize = " & $DT_AllocSize & @crlf)
		_DumpOutput("$DT_RealSize = " & $DT_RealSize & @crlf)
		_DumpOutput("$DT_InitStreamSize = " & $DT_InitStreamSize & @crlf)
	EndIf
	_WriteLogFileDataRunsCsv()
EndFunc

Func _Decode_UpdateMappingPairs($input)
	;Tightly related to the setting of new attribute size. Actually these bytes are actual data runs and their relative location is determined by $attribute_offset. If we don't have any record history, this value is likely worthless.
	$DT_DataRuns = StringMid($input, 1)
	_WriteLogFileDataRunsCsv()
EndFunc

Func _Decode_INDX($Entry)
	If $VerboseOn Then _DumpOutput("_Decode_INDX():" & @CRLF)
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$EntryCounter=1,$Padding2,$EntryCounter=1,$DecodeOk=False
	Local $Indx_CTime_Core,$Indx_CTime_Precision,$Indx_ATime_Core,$Indx_ATime_Precision,$Indx_MTime_Core,$Indx_MTime_Precision,$Indx_RTime_Core,$Indx_RTime_Precision
	$NewLocalAttributeOffset = 1
	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+56,8)),2)
	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+48,8)),2)
	$NewLocalAttributeOffset = $NewLocalAttributeOffset+48+($IndxHeaderSize*2)
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = _SwapEndian($MFTReference)
	$MFTReference = Dec($MFTReference,2)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(_SwapEndian($MFTReferenceSeqNo),2)
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(_SwapEndian($IndexEntryLength),2)
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(_SwapEndian($OffsetToFileName),2)
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = _SwapEndian($MFTReferenceOfParent)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent,2)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(_SwapEndian($MFTReferenceOfParentSeqNo),2)
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
	$Indx_AllocSize = Dec(_SwapEndian($Indx_AllocSize),2)
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(_SwapEndian($Indx_RealSize),2)
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,8)
	$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_ReparseTag = StringMid($Entry,$NewLocalAttributeOffset+152,8)
	$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
	$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
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
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*4)
	$Indx_FileName = BinaryToString("0x"&$Indx_FileName,2)
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

;	FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
	If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
		$DecodeOk=True
		FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_ReparseTag & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		$RealMftRef = $PredictedRefNumber
		$PredictedRefNumber = $MFTReferenceOfParent
		$KeptRef = $MFTReferenceOfParent
		$AttributeString = "$INDEX_ALLOCATION"
		If Not $FromRcrdSlack Then
			If $Indx_NameSpace <> "DOS" Then _UpdateFileNameArray($MFTReference,$MFTReferenceSeqNo,$Indx_FileName,$this_lsn)
		EndIf
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
		$MFTReference = _SwapEndian($MFTReference)
		$MFTReference = Dec($MFTReference,2)
		$MFTReferenceSeqNo = StringMid($Entry,$NextEntryOffset+12,4)
		$MFTReferenceSeqNo = Dec(_SwapEndian($MFTReferenceSeqNo),2)
		$IndexEntryLength = StringMid($Entry,$NextEntryOffset+16,4)
		$IndexEntryLength = Dec(_SwapEndian($IndexEntryLength),2)
		$OffsetToFileName = StringMid($Entry,$NextEntryOffset+20,4)
		$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,3,2))
		$IndexFlags = StringMid($Entry,$NextEntryOffset+24,4)
		$Padding = StringMid($Entry,$NextEntryOffset+28,4)
		$MFTReferenceOfParent = StringMid($Entry,$NextEntryOffset+32,12)
		$MFTReferenceOfParent = _SwapEndian($MFTReferenceOfParent)
		$MFTReferenceOfParent = Dec($MFTReferenceOfParent,2)
		$MFTReferenceOfParentSeqNo = StringMid($Entry,$NextEntryOffset+44,4)
		$MFTReferenceOfParentSeqNo = Dec(_SwapEndian($MFTReferenceOfParentSeqNo),2)

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
		$Indx_AllocSize = Dec(_SwapEndian($Indx_AllocSize),2)
		$Indx_RealSize = StringMid($Entry,$NextEntryOffset+128,16)
		$Indx_RealSize = Dec(_SwapEndian($Indx_RealSize),2)
		$Indx_File_Flags = StringMid($Entry,$NextEntryOffset+144,8)
		$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
		$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
		$Indx_ReparseTag = StringMid($Entry,$NextEntryOffset+152,8)
		$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
		$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
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
		$Indx_FileName = StringMid($Entry,$NextEntryOffset+164,$Indx_NameLength*4)
		$Indx_FileName = BinaryToString("0x"&$Indx_FileName,2)
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

;		FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
			$DecodeOk=True
			FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_ReparseTag & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
			$RealMftRef = $PredictedRefNumber
			$PredictedRefNumber = $MFTReferenceOfParent
			$KeptRef = $MFTReferenceOfParent
			$AttributeString = "$INDEX_ALLOCATION"
			If Not $FromRcrdSlack Then
				If $Indx_NameSpace <> "DOS" Then _UpdateFileNameArray($MFTReference,$MFTReferenceSeqNo,$Indx_FileName,$this_lsn)
			EndIf
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
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset;,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
;	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$EntryCounter=1,$Padding2,$EntryCounter=1,$DecodeOk=False
	Local $Indx_CTime_Core,$Indx_CTime_Precision,$Indx_ATime_Core,$Indx_ATime_Precision,$Indx_MTime_Core,$Indx_MTime_Precision,$Indx_RTime_Core,$Indx_RTime_Precision
	$NewLocalAttributeOffset = 1
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = _SwapEndian($MFTReference)
	$MFTReference = Dec($MFTReference,2)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(_SwapEndian($MFTReferenceSeqNo),2)
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(_SwapEndian($IndexEntryLength),2)
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(_SwapEndian($OffsetToFileName),2)
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
;	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = _SwapEndian($MFTReferenceOfParent)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent,2)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(_SwapEndian($MFTReferenceOfParentSeqNo),2)
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
	$Indx_AllocSize = Dec(_SwapEndian($Indx_AllocSize),2)
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(_SwapEndian($Indx_RealSize),2)
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,8)
	$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_ReparseTag = StringMid($Entry,$NewLocalAttributeOffset+152,8)
	$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
	$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
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
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*4)
	$Indx_FileName = BinaryToString("0x"&$Indx_FileName,2)
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
			FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_ReparseTag & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
			If Not $FromRcrdSlack Then
				If $Indx_NameSpace <> "DOS" Then _UpdateFileNameArray($MFTReference,$MFTReferenceSeqNo,$Indx_FileName,$this_lsn)
			EndIf
		Else
			FileWriteLine($LogFileUndoWipeIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_ReparseTag & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
			If Not $FromRcrdSlack Then
				If $Indx_NameSpace <> "DOS" Then _UpdateFileNameArray($MFTReference,$MFTReferenceSeqNo,$Indx_FileName,$this_lsn)
			EndIf
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
		_DumpOutput("_Decode_IndexEntry():" & @CRLF)
		_DumpOutput("$MFTReference = " & $MFTReference & @crlf)
		_DumpOutput("$MFTReferenceSeqNo = " & $MFTReferenceSeqNo & @crlf)
		_DumpOutput("$IndexEntryLength = " & $IndexEntryLength & @crlf)
		_DumpOutput("$OffsetToFileName = " & $OffsetToFileName & @crlf)
		_DumpOutput("$IndexFlags = " & $IndexFlags & @crlf)
		_DumpOutput("$MFTReferenceOfParent = " & $MFTReferenceOfParent & @crlf)
		_DumpOutput("$Indx_CTime = " & $Indx_CTime & @crlf)
		_DumpOutput("$Indx_ATime = " & $Indx_ATime & @crlf)
		_DumpOutput("$Indx_MTime = " & $Indx_MTime & @crlf)
		_DumpOutput("$Indx_RTime = " & $Indx_RTime & @crlf)
		_DumpOutput("$Indx_AllocSize = " & $Indx_AllocSize & @crlf)
		_DumpOutput("$Indx_RealSize = " & $Indx_RealSize & @crlf)
		_DumpOutput("$Indx_File_Flags = " & $Indx_File_Flags & @crlf)
		_DumpOutput("$Indx_NameLength = " & $Indx_NameLength & @crlf)
		_DumpOutput("$Indx_NameSpace = " & $Indx_NameSpace & @crlf)
		_DumpOutput("$Indx_FileName = " & $Indx_FileName & @crlf)
		_DumpOutput("$SubNodeVCN = " & $SubNodeVCN & @crlf)
		_DumpOutput(@crlf)
	EndIf
	Return $DecodeOk
EndFunc

Func _Get_IndexRoot($Entry,$CurrentAttributeName)
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
		_DumpOutput("_Get_IndexRoot():" & @CRLF)
		_DumpOutput("$AttributeType = " & $AttributeType & @crlf)
		_DumpOutput("$CollationRule = " & $CollationRule & @crlf)
		_DumpOutput("$SizeOfIndexAllocationEntry = " & $SizeOfIndexAllocationEntry & @crlf)
		_DumpOutput("$ClustersPerIndexRoot = " & $ClustersPerIndexRoot & @crlf)
;		_DumpOutput("$IRPadding = " & $IRPadding & @crlf)
		_DumpOutput("$OffsetToFirstEntry = " & $OffsetToFirstEntry & @crlf)
		_DumpOutput("$TotalSizeOfEntries = " & $TotalSizeOfEntries & @crlf)
		_DumpOutput("$AllocatedSizeOfEntries = " & $AllocatedSizeOfEntries & @crlf)
		_DumpOutput("$Flags = " & $Flags & @crlf)
;		_DumpOutput("$IRPadding2 = " & $IRPadding2 & @crlf)
	EndIf

;	If $ResidentIndx And $AttributeType=$FILE_NAME And $CurrentAttributeName="$I30" Then
	If $ResidentIndx And $AttributeType=$FILE_NAME Then
		$TheResidentIndexEntry = StringMid($Entry,$LocalAttributeOffset+64)
		$DecodeOk = _Decode_INDX($TheResidentIndexEntry)
	EndIf
	Return $DecodeOk
EndFunc

Func _GetAttributeEntry($Entry)
	Local $CoreAttribute,$CoreAttributeTmp,$CoreAttributeArr[3]
	Local $ATTRIBUTE_HEADER_LengthOfAttribute,$ATTRIBUTE_HEADER_OffsetToAttribute,$ATTRIBUTE_HEADER_Length, $ATTRIBUTE_HEADER_NonResidentFlag, $ATTRIBUTE_HEADER_NameLength, $ATTRIBUTE_HEADER_NameRelativeOffset, $ATTRIBUTE_HEADER_Name
	$ATTRIBUTE_HEADER_Length = StringMid($Entry,9,8)
	$ATTRIBUTE_HEADER_Length = Dec(_SwapEndian($ATTRIBUTE_HEADER_Length),2)
	$ATTRIBUTE_HEADER_NonResidentFlag = Dec(StringMid($Entry,17,2))
	$ATTRIBUTE_HEADER_NameLength = Dec(StringMid($Entry,19,2))
	$ATTRIBUTE_HEADER_NameRelativeOffset = StringMid($Entry,21,4)
	$ATTRIBUTE_HEADER_NameRelativeOffset = Dec(_SwapEndian($ATTRIBUTE_HEADER_NameRelativeOffset))
	If $ATTRIBUTE_HEADER_NameLength > 0 Then
		$ATTRIBUTE_HEADER_Name = BinaryToString("0x"&StringMid($Entry,$ATTRIBUTE_HEADER_NameRelativeOffset*2 + 1,$ATTRIBUTE_HEADER_NameLength*4),2)
	Else
		$ATTRIBUTE_HEADER_Name = ""
	EndIf
	If $ATTRIBUTE_HEADER_NonResidentFlag = 0 Then
		$ATTRIBUTE_HEADER_LengthOfAttribute = StringMid($Entry,33,8)
		$ATTRIBUTE_HEADER_LengthOfAttribute = Dec(_SwapEndian($ATTRIBUTE_HEADER_LengthOfAttribute),2)
		$ATTRIBUTE_HEADER_OffsetToAttribute = Dec(_SwapEndian(StringMid($Entry,41,4)))
		$CoreAttribute = StringMid($Entry,$ATTRIBUTE_HEADER_OffsetToAttribute*2+1,$ATTRIBUTE_HEADER_LengthOfAttribute*2)
	Else
		$CoreAttribute = ""
	EndIf
	$CoreAttributeArr[0] = $CoreAttribute
	$CoreAttributeArr[1] = $ATTRIBUTE_HEADER_Name
	$CoreAttributeArr[2] = $ATTRIBUTE_HEADER_NonResidentFlag
	If $ATTRIBUTE_HEADER_NameLength > 0 Then $TextInformation &= ";AttributeHeaderName="&$ATTRIBUTE_HEADER_Name
	Return $CoreAttributeArr
EndFunc

Func _Get_ReparsePoint($Entry,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$GuidPresent=0,$ReparseType,$ReparseDataLength,$ReparsePadding,$ReparseGuid,$ReparseSubstititeNameOffset,$ReparseSubstituteNameLength,$ReparsePrintNameOffset,$ReparsePrintNameLength,$ReparseSubstititeName,$ReparsePrintName
	$ReparseType = StringMid($Entry,$LocalAttributeOffset,8)
	$ReparseType = _SwapEndian($ReparseType)
	If Dec(StringMid($ReparseType,1,2)) < 128 Then ;Non-Microsoft - GUID exist
		$GuidPresent = 1
	EndIf
	$ReparseType = "0x" & $ReparseType
	$ReparseType = _GetReparseType($ReparseType)
	$ReparseDataLength = StringMid($Entry,$LocalAttributeOffset+8,4)
	$ReparseDataLength = Dec(_SwapEndian($ReparseDataLength),2)
;	$ReparsePadding = StringMid($Entry,$LocalAttributeOffset+12,4)
	If $GuidPresent Then
		$ReparseGuid = StringMid($Entry,$LocalAttributeOffset+16,32)
		$ReparseGuid = _HexToGuidStr($ReparseGuid,1)
		$ReparseData = StringMid($Entry,$LocalAttributeOffset+48,$ReparseDataLength*2)
	Else
		$ReparseData = StringMid($Entry,$LocalAttributeOffset+16,$ReparseDataLength*2)
	EndIf
;	$ReparseData = StringMid($Entry,$LocalAttributeOffset+16,$ReparseDataLength*2)
	$ReparseSubstititeNameOffset = StringMid($ReparseData,1,4)
	$ReparseSubstititeNameOffset = Dec(_SwapEndian($ReparseSubstititeNameOffset),2)
	$ReparseSubstituteNameLength = StringMid($ReparseData,5,4)
	$ReparseSubstituteNameLength = Dec(_SwapEndian($ReparseSubstituteNameLength),2)
	$ReparsePrintNameOffset = StringMid($ReparseData,9,4)
	$ReparsePrintNameOffset = Dec(_SwapEndian($ReparsePrintNameOffset),2)
	$ReparsePrintNameLength = StringMid($ReparseData,13,4)
	$ReparsePrintNameLength = Dec(_SwapEndian($ReparsePrintNameLength),2)
	;-----if $ReparseSubstititeNameOffset<>0 then the order is reversed and parsed from end of $ReparseData ????????
	If StringMid($ReparseData,1,4) <> "0000" Then
		$ReparseSubstititeName = StringMid($Entry,StringLen($Entry)+1-($ReparseSubstituteNameLength*2),$ReparseSubstituteNameLength*2)
;		_DumpOutput("$ReparseSubstititeName = " & $ReparseSubstititeName & @crlf)
		$ReparseSubstititeName = BinaryToString("0x"&$ReparseSubstititeName,2)
		$ReparsePrintName = StringMid($Entry,StringLen($Entry)+1-($ReparseSubstituteNameLength*2)-($ReparsePrintNameLength*2),$ReparsePrintNameLength*2)
;		_DumpOutput("$ReparsePrintName = " & $ReparsePrintName & @crlf)
		$ReparsePrintName = BinaryToString("0x"&$ReparsePrintName,2)
	Else
		$ReparseSubstititeName = StringMid($Entry,$LocalAttributeOffset+16+16,$ReparseSubstituteNameLength*2)
;		_DumpOutput("$ReparseSubstititeName = " & $ReparseSubstititeName & @crlf)
		$ReparseSubstititeName = BinaryToString("0x"&$ReparseSubstititeName,2)
		$ReparsePrintName = StringMid($Entry,($LocalAttributeOffset+32)+($ReparsePrintNameOffset*2),$ReparsePrintNameLength*2)
;		_DumpOutput("$ReparsePrintName = " & $ReparsePrintName & @crlf)
		$ReparsePrintName = BinaryToString("0x"&$ReparsePrintName,2)
	EndIf
	If $VerboseOn Then
		_DumpOutput("_Get_ReparsePoint():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$Entry) & @CRLF)
		_DumpOutput("$ReparseType = " & $ReparseType & @crlf)
		_DumpOutput("$ReparseDataLength = " & $ReparseDataLength & @crlf)
;		_DumpOutput("$ReparsePadding = " & $ReparsePadding & @crlf)
		_DumpOutput("$ReparseGuid = " & $ReparseGuid & @crlf)
		_DumpOutput("$ReparseSubstititeNameOffset = " & $ReparseSubstititeNameOffset & @crlf)
		_DumpOutput("$ReparseSubstituteNameLength = " & $ReparseSubstituteNameLength & @crlf)
		_DumpOutput("$ReparsePrintNameOffset = " & $ReparsePrintNameOffset & @crlf)
		_DumpOutput("$ReparsePrintNameLength = " & $ReparsePrintNameLength & @crlf)
		_DumpOutput("$ReparseSubstititeName = " & $ReparseSubstititeName & @crlf)
		_DumpOutput("$ReparsePrintName = " & $ReparsePrintName & @crlf)
	EndIf
	If $GuidPresent Then
		$TextInformation &= ";ReparseTag="&$ReparseType&";ReparseGuid="&$ReparseGuid&";ReparseSubstititeName="&$ReparseSubstititeName&";ReparsePrintName="&$ReparsePrintName
	Else
		$TextInformation &= ";ReparseTag="&$ReparseType&";ReparseSubstititeName="&$ReparseSubstititeName&";ReparsePrintName="&$ReparsePrintName
	EndIf
EndFunc

Func _Get_EaInformation($Entry)
	Local $LocalAttributeOffset = 1,$TheEaInformation,$SizeOfPackedEas,$NumberOfEaWithFlagSet,$SizeOfUnpackedEas
	$TheEaInformation = StringMid($Entry,$LocalAttributeOffset)
	$SizeOfPackedEas = StringMid($Entry,$LocalAttributeOffset,4)
	$SizeOfPackedEas = Dec(_SwapEndian($SizeOfPackedEas),2)
	$NumberOfEaWithFlagSet = StringMid($Entry,$LocalAttributeOffset+4,4)
	$NumberOfEaWithFlagSet = Dec(_SwapEndian($NumberOfEaWithFlagSet),2)
	$SizeOfUnpackedEas = StringMid($Entry,$LocalAttributeOffset+8,8)
	$SizeOfUnpackedEas = Dec(_SwapEndian($SizeOfUnpackedEas),2)
	If $VerboseOn Then
		_DumpOutput("_Get_EaInformation():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$TheEaInformation) & @crlf)
;		_DumpOutput("$TheEaInformation = " & $TheEaInformation & @crlf)
		_DumpOutput("$SizeOfPackedEas = " & $SizeOfPackedEas & @crlf)
		_DumpOutput("$NumberOfEaWithFlagSet = " & $NumberOfEaWithFlagSet & @crlf)
		_DumpOutput("$SizeOfUnpackedEas = " & $SizeOfUnpackedEas & @crlf)
	EndIf
	$TextInformation &= ";SizeOfPackedEas="&$SizeOfPackedEas&";NumberOfEaWithFlagSet="&$NumberOfEaWithFlagSet&";SizeOfUnpackedEas="&$SizeOfUnpackedEas
EndFunc

Func _Get_Ea($Entry)
	Local $LocalAttributeOffset = 1,$OffsetToNextEa,$EaFlags,$EaNameLength,$EaValueLength,$EaCounter=1
	$StringLengthInput = StringLen($Entry)

	_DumpOutput("$EA detected" & @CRLF)
	_DumpOutput("$this_lsn: " & $this_lsn & @crlf)
	_DumpOutput(_HexEncode("0x"&$Entry) & @crlf)
	$OffsetToNextEa = StringMid($Entry,$LocalAttributeOffset,8)
	$OffsetToNextEa = Dec(_SwapEndian($OffsetToNextEa),2)
	$EaFlags = StringMid($Entry,$LocalAttributeOffset+8,2)
	$EaNameLength = Dec(StringMid($Entry,$LocalAttributeOffset+10,2))
	$EaValueLength = StringMid($Entry,$LocalAttributeOffset+12,4)
	$EaValueLength = Dec(_SwapEndian($EaValueLength),2)
	$EaName = StringMid($Entry,$LocalAttributeOffset+16,$EaNameLength*2)
	$EaName = _HexToString($EaName)
	$EaValue = StringMid($Entry,$LocalAttributeOffset+16+($EaNameLength*2)+2,$EaValueLength*2)
	#cs
	If $VerboseOn Then
		_DumpOutput("_Get_Ea():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$Entry) & @crlf)
		_DumpOutput("$OffsetToNextEa = " & $OffsetToNextEa & @crlf)
		_DumpOutput("$EaFlags = " & $EaFlags & @crlf)
		_DumpOutput("$EaNameLength = " & $EaNameLength & @crlf)
		_DumpOutput("$EaValueLength = " & $EaValueLength & @crlf)
		_DumpOutput("$EaName = " & $EaName & @crlf)
		_DumpOutput("$EaValue:" & @crlf)
		_DumpOutput(_HexEncode("0x"&$EaValue) & @crlf)
	EndIf
	#ce
	_DumpOutput("EaName("&$EaCounter&"): " & $EaName & @crlf)
	_DumpOutput(_HexEncode("0x"&$EaValue) & @crlf)
	$TextInformation &= ";EaName("&$EaCounter&")="&$EaName

	If $DoExtractResidentUpdates Then
		_ExtractResidentUpdatesEa($EaValue,$EaName)
	EndIf

	If $OffsetToNextEa*2 >= $StringLengthInput Then
		Return
	EndIf

	Do
		$LocalAttributeOffset += $OffsetToNextEa*2
		If $LocalAttributeOffset >= $StringLengthInput Then ExitLoop
		$EaCounter+=1
		$OffsetToNextEa = StringMid($Entry,$LocalAttributeOffset,8)
		$OffsetToNextEa = Dec(_SwapEndian($OffsetToNextEa),2)
		$EaFlags = Dec(StringMid($Entry,$LocalAttributeOffset+8,2))
		$EaNameLength = Dec(StringMid($Entry,$LocalAttributeOffset+10,2))
		$EaValueLength = StringMid($Entry,$LocalAttributeOffset+12,4)
		$EaValueLength = Dec(StringMid($EaValueLength,3,2) & StringMid($EaValueLength,1,2))
		$EaName = StringMid($Entry,$LocalAttributeOffset+16,$EaNameLength*2)
		$EaName = _HexToString($EaName)
		$EaValue = StringMid($Entry,$LocalAttributeOffset+16+($EaNameLength*2),$EaValueLength*2)
		#cs
		If $VerboseOn Then
			_DumpOutput("$EaFlags = " & $EaFlags & @crlf)
			_DumpOutput("$EaNameLength = " & $EaNameLength & @crlf)
			_DumpOutput("$EaValueLength = " & $EaValueLength & @crlf)
			_DumpOutput("$EaName = " & $EaName & @crlf)
			_DumpOutput("$EaValue: " & @crlf)
			_DumpOutput(_HexEncode("0x"&$EaValue) & @crlf)
		EndIf
		#ce
		_DumpOutput("EaName("&$EaCounter&"): " & $EaName & @crlf)
		_DumpOutput(_HexEncode("0x"&$EaValue) & @crlf)
		$TextInformation &= ";EaName("&$EaCounter&")="&$EaName
		If $DoExtractResidentUpdates Then
			_ExtractResidentUpdatesEa($EaValue,$EaName)
		EndIf
	Until $LocalAttributeOffset >= $StringLengthInput
	$TextInformation &= ";Search debug.log for " & $this_lsn
EndFunc

Func _Get_LoggedUtilityStream($Entry,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1
	$TheLoggedUtilityStream = StringMid($Entry,$LocalAttributeOffset)
	If $VerboseOn Then
		_DumpOutput("_Get_LoggedUtilityStream():" & @CRLF)
		_DumpOutput("$TheLoggedUtilityStream = " & $TheLoggedUtilityStream & @crlf)
	EndIf
	$TextInformation &= ";LoggedUtilityStream="&$TheLoggedUtilityStream
	If $CurrentAttributeName = "$TXF_DATA" Then
		_Decode_TXF_DATA($TheLoggedUtilityStream,1)
	EndIf
EndFunc

Func _Decode_UpdateResidentValue($record,$IsRedo)
	If $VerboseOn Then _DumpOutput("_Decode_UpdateResidentValue():" & @CRLF)
	If $IsRedo Then
		Select
			Case $record_offset_in_mft = 56 Or $AttributeString = "$STANDARD_INFORMATION"
				_Decode_StandardInformation($record)
				$AttributeString = "$STANDARD_INFORMATION"

			Case $AttributeString = "$LOGGED_UTILITY_STREAM" And $undo_length > 0
				_Decode_TXF_DATA($record,$IsRedo)

			Case $AttributeString = "$EA" And $undo_length > 0
				_Get_Ea($record)

			Case $AttributeString = "$BITMAP" And $undo_length > 0

;			Case $DoExtractResidentUpdates And $MinSizeResidentExtraction > 0 And $redo_length >= $MinSizeResidentExtraction And $undo_length > 0 And $redo_length=$undo_length
			Case $DoExtractResidentUpdates And $redo_length >= $MinSizeResidentExtraction And $undo_length > 0 ;Assume $DATA
				_ExtractResidentUpdates($record,$IsRedo)
			Case $client_previous_lsn=0 And $undo_length=0
				$TextInformation &= ";Initializing with zeros"
			Case $PredictedRefNumber = 31 ;Updates to $Tops:$DATA
				_DumpOutput("Verbose: Updates to $Tops:$DATA" & @CRLF)
				_DumpOutput("$this_lsn: " & $this_lsn & @crlf)
				_DumpOutput(_HexEncode("0x"&$record) & @crlf)
			Case Else
				_DumpOutput("Error in _Decode_UpdateResidentValue():" & @CRLF)
				_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
				_DumpOutput(_HexEncode("0x"&$record) & @crlf)
;				MsgBox(0,"Error","This indicates an unexpected situation at LSN: " & $this_lsn)

		EndSelect
	Else
		Select
			Case $record_offset_in_mft = 56 Or $AttributeString = "$STANDARD_INFORMATION"

			Case $AttributeString = "$LOGGED_UTILITY_STREAM"

			Case $AttributeString = "$BITMAP"

;			Case $record_offset_in_mft <> 56 And $DoExtractResidentUpdates And $MinSizeResidentExtraction > 0 And $redo_length >= $MinSizeResidentExtraction And $undo_length > 0 And $redo_length=$undo_length ;Assume $DATA
			Case $record_offset_in_mft <> 56 And $DoExtractResidentUpdates And $redo_length >= $MinSizeResidentExtraction
				_ExtractResidentUpdates($record,$IsRedo)

		EndSelect
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
	Local $RecordSize,$DecodeOk=False,$CoreAttr,$CoreAttrName,$CoreAttrChunk, $LocalStreamName
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
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				_DecodeAttrList($record,$IsRedo)
				$AttributeString = "$ATTRIBUTE_LIST"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag&";See LogFile_AttributeList.csv"
			Case $AttributeTypeCheck = "3000"
				_Get_FileName($record, 1, $RecordSize, 1)
				$AttributeString = "$FILE_NAME"
			Case $AttributeTypeCheck = "4000"
				_Get_ObjectID($record, 1, $RecordSize)
				$AttributeString = "$OBJECT_ID"
			Case $AttributeTypeCheck = "5000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
;				ConsoleWrite("$SECURITY_DESCRIPTOR:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$CoreAttrChunk) & @CRLF)
				If $CoreAttrChunk <> "" Then
					_DecodeSecurityDescriptorAttribute($CoreAttrChunk)
					;Write information to csv
					_WriteCsvSecureSDS($IsRedo)
					;Make sure all global variables for csv are cleared
					_ClearVarSecureSDS()
				EndIf
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag&";See LogFile_SecurityDescriptors.csv"
				$AttributeString = "$SECURITY_DESCRIPTOR"
			Case $AttributeTypeCheck = "6000"
				_Get_VolumeName($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_NAME"
			Case $AttributeTypeCheck = "7000"
				_Get_VolumeInformation($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_INFORMATION"
			Case $AttributeTypeCheck = "8000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				_Get_Data($record, 1, $RecordSize, 1 )
				If $DT_Name <> "" Then
					$AttributeString = "$DATA:"&$DT_Name
				Else
					$AttributeString = "$DATA"
				EndIf
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "9000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				If $CoreAttrName = "$I30" Then $DecodeOk = _Get_IndexRoot($CoreAttrChunk,$CoreAttrName)
				$AttributeString = "$INDEX_ROOT"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "A000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				If $CoreAttrChunk <> "" Then ;Will never occur?
					If $CoreAttrName = "$I30" Then $DecodeOk = _Decode_INDX($CoreAttrChunk)
				EndIf
				$AttributeString = "$INDEX_ALLOCATION"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "B000"
;				ConsoleWrite("Bitmap:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$record) & @CRLF)
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				$AttributeString = "$BITMAP"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "C000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				If $CoreAttrChunk <> "" Then
					_Get_ReparsePoint($CoreAttrChunk,$CoreAttrName)
				EndIf
				$AttributeString = "$REPARSE_POINT"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "D000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				If $CoreAttrChunk <> "" Then
					_Get_EaInformation($CoreAttrChunk)
				EndIf
				$AttributeString = "$EA_INFORMATION"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "E000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				If $CoreAttrChunk <> "" Then
					_Get_Ea($CoreAttrChunk)
				EndIf
				$AttributeString = "$EA"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "F000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				$AttributeString = "$PROPERTY_SET"
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
			Case $AttributeTypeCheck = "0001"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$CoreAttrNonResidentFlag = $CoreAttr[2]
				If $CoreAttrChunk <> "" Then
					_Get_LoggedUtilityStream($CoreAttrChunk,$CoreAttrName)
				EndIf
				If $CoreAttrName <> "" Then
					$AttributeString = "$LOGGED_UTILITY_STREAM:" & $CoreAttrName
				Else
					$AttributeString = "$LOGGED_UTILITY_STREAM"
				EndIf
				$TextInformation &= ";NonResidentFlag="&$CoreAttrNonResidentFlag
		EndSelect
	Else
		Select
			Case $AttributeTypeCheck = "1000"
				$AttributeString = "$STANDARD_INFORMATION"
			Case $AttributeTypeCheck = "2000"
				$AttributeString = "$ATTRIBUTE_LIST"
				_DecodeAttrList($record,$IsRedo)
				$AttributeString = "$ATTRIBUTE_LIST"
				$TextInformation &= ";See LogFile_AttributeList.csv"
			Case $AttributeTypeCheck = "3000"
				_Get_FileName($record, 1, $RecordSize, 1)
				$AttributeString = "$FILE_NAME"
			Case $AttributeTypeCheck = "4000"
				_Get_ObjectID($record, 1, $RecordSize)
				$AttributeString = "$OBJECT_ID"
			Case $AttributeTypeCheck = "5000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
;				ConsoleWrite("$SECURITY_DESCRIPTOR:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$CoreAttrChunk) & @CRLF)
				If $CoreAttrChunk <> "" Then
					_DecodeSecurityDescriptorAttribute($CoreAttrChunk)
					;Write information to csv
					_WriteCsvSecureSDS($IsRedo)
					;Make sure all global variables for csv are cleared
					_ClearVarSecureSDS()
				EndIf
				$TextInformation &= ";See LogFile_SecurityDescriptors.csv"
				$AttributeString = "$SECURITY_DESCRIPTOR"
			Case $AttributeTypeCheck = "6000"
				_Get_VolumeName($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_NAME"
			Case $AttributeTypeCheck = "7000"
				_Get_VolumeInformation($record, 1, $RecordSize)
				$AttributeString = "$VOLUME_INFORMATION"
			Case $AttributeTypeCheck = "8000"
				$AttributeString = "$DATA"
				$LocalStreamName = _Get_DataName($record)
				If $LocalStreamName <> "" Then
					$AttributeString = "$DATA:"&$LocalStreamName
				Else
					$AttributeString = "$DATA"
				EndIf
			Case $AttributeTypeCheck = "9000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$AttributeString = "$INDEX_ROOT"
			Case $AttributeTypeCheck = "A000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$AttributeString = "$INDEX_ALLOCATION"
			Case $AttributeTypeCheck = "B000"
;				ConsoleWrite("Bitmap:" & @CRLF)
;				ConsoleWrite(_HexEncode("0x"&$record) & @CRLF)
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				$AttributeString = "$BITMAP"
			Case $AttributeTypeCheck = "C000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
;					_Get_ReparsePoint($CoreAttrChunk,1,$CoreAttrName)
				EndIf
				$AttributeString = "$REPARSE_POINT"
			Case $AttributeTypeCheck = "D000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
;					_Get_EaInformation($CoreAttrChunk,1,$CoreAttrName)
				EndIf
				$AttributeString = "$EA_INFORMATION"
			Case $AttributeTypeCheck = "E000"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
;					_Get_Ea($CoreAttrChunk,1,$CoreAttrName)
				EndIf
				$AttributeString = "$EA"
			Case $AttributeTypeCheck = "F000"
				$AttributeString = "$PROPERTY_SET"
			Case $AttributeTypeCheck = "0001"
				$CoreAttr = _GetAttributeEntry(StringMid($record,1,$RecordSize))
				$CoreAttrChunk = $CoreAttr[0]
				$CoreAttrName = $CoreAttr[1]
				If $CoreAttrChunk <> "" Then
;					_Get_LoggedUtilityStream($CoreAttrChunk,1,$CoreAttrName)
				EndIf
				If $CoreAttrName <> "" Then
					$AttributeString = "$LOGGED_UTILITY_STREAM:" & $CoreAttrName
				Else
					$AttributeString = "$LOGGED_UTILITY_STREAM"
				EndIf
		EndSelect
	EndIf
	If $CoreAttrName <> "" And StringInStr($AttributeString,":")=0 Then
		$AttributeString &= ":"&$CoreAttrName
	EndIf
	Return $DecodeOk
EndFunc

Func _WriteOut_MFTrecord($MFTref, $content)
	Local $nBytes = "", $Counter = 1, $rBuffer, $hFileOut, $OutFile, $Written, $Written2
	If Mod(StringLen($content)/2,$MFT_Record_Size) Then
		Do
			$content &= "00"
		Until Mod(StringLen($content)/2,$MFT_Record_Size)=0
	EndIf

; Writing each record into 1 dummy $MFT with all found records
	$rBuffer = DllStructCreate("byte ["&$MFT_Record_Size&"]")
	DllStructSetData($rBuffer,1,"0x"&$content)
	$Written2 = _WinAPI_WriteFile($hOutFileMFT, DllStructGetPtr($rBuffer), DllStructGetSize($rBuffer), $nBytes2)
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
	If BitAND($USNReasonInput, 0x00000100) Then $USNReasonOutput &= 'FILE_CREATE+'
	;The file or directory is created for the first time.
	If BitAND($USNReasonInput, 0x00001000) Then $USNReasonOutput &= 'RENAME_OLD_NAME+'
	;The file or directory is renamed, and the file name in the USN_RECORD_V2 structure is the previous name.
	If BitAND($USNReasonInput, 0x00002000) Then $USNReasonOutput &= 'RENAME_NEW_NAME+'
	;A file or directory is renamed, and the file name in the USN_RECORD_V2 structure is the new name.
	If BitAND($USNReasonInput, 0x00008000) Then $USNReasonOutput &= 'BASIC_INFO_CHANGE+'
	;A user has either changed one or more file or directory attributes (for example, the read-only, hidden, system, archive, or sparse attribute), or one or more time stamps.
	If BitAND($USNReasonInput, 0x00000400) Then $USNReasonOutput &= 'EA_CHANGE+'
	;The user made a change to the extended attributes of a file or directory.
	;These NTFS file system attributes are not accessible to Windows-based applications.
	If BitAND($USNReasonInput, 0x00000800) Then $USNReasonOutput &= 'SECURITY_CHANGE+'
	;A change is made in the access rights to a file or directory.
	If BitAND($USNReasonInput, 0x00004000) Then $USNReasonOutput &= 'INDEXABLE_CHANGE+'
	;A user changes the FILE_ATTRIBUTE_NOT_CONTENT_INDEXED attribute.
	;That is, the user changes the file or directory from one where content can be indexed to one where content cannot be indexed, or vice versa. Content indexing permits rapid searching of data by building a database of selected content.
	If BitAND($USNReasonInput, 0x00010000) Then $USNReasonOutput &= 'HARD_LINK_CHANGE+'
	;An NTFS file system hard link is added to or removed from the file or directory.
	;An NTFS file system hard link, similar to a POSIX hard link, is one of several directory entries that see the same file or directory.
	If BitAND($USNReasonInput, 0x00020000) Then $USNReasonOutput &= 'COMPRESSION_CHANGE+'
	;The compression state of the file or directory is changed from or to compressed.
	If BitAND($USNReasonInput, 0x00040000) Then $USNReasonOutput &= 'ENCRYPTION_CHANGE+'
	;The file or directory is encrypted or decrypted.
	If BitAND($USNReasonInput, 0x00080000) Then $USNReasonOutput &= 'OBJECT_ID_CHANGE+'
	;The object identifier of a file or directory is changed.
	If BitAND($USNReasonInput, 0x00100000) Then $USNReasonOutput &= 'REPARSE_POINT_CHANGE+'
	;The reparse point that is contained in a file or directory is changed, or a reparse point is added to or deleted from a file or directory.
	If BitAND($USNReasonInput, 0x00800000) Then $USNReasonOutput &= 'INTEGRITY_CHANGE+'
	If BitAND($USNReasonInput, 0x00000004) Then $USNReasonOutput &= 'DATA_TRUNCATION+'
	;The file or directory is truncated.
	If BitAND($USNReasonInput, 0x00000002) Then $USNReasonOutput &= 'DATA_EXTEND+'
	;The file or directory is extended (added to).
	If BitAND($USNReasonInput, 0x00000001) Then $USNReasonOutput &= 'DATA_OVERWRITE+'
	;The data in the file or directory is overwritten.
	If BitAND($USNReasonInput, 0x00200000) Then $USNReasonOutput &= 'STREAM_CHANGE+'
	;A named stream is added to or removed from a file, or a named stream is renamed.
	If BitAND($USNReasonInput, 0x00400000) Then $USNReasonOutput &= 'TRANSACTED_CHANGE+'
	;Transactional NTFS (TxF) change.
	If BitAND($USNReasonInput, 0x00000040) Then $USNReasonOutput &= 'NAMED_DATA_TRUNCATION+'
	;The one or more named data streams for a file is truncated.
	If BitAND($USNReasonInput, 0x00000020) Then $USNReasonOutput &= 'NAMED_DATA_EXTEND+'
	;The one or more named data streams for a file are extended (added to).
	If BitAND($USNReasonInput, 0x00000010) Then $USNReasonOutput &= 'NAMED_DATA_OVERWRITE+'
	;The data in one or more named data streams for a file is overwritten.
	If BitAND($USNReasonInput, 0x00000200) Then $USNReasonOutput &= 'FILE_DELETE+'
	;The file or directory is deleted.
	If BitAND($USNReasonInput, 0x80000000) Then $USNReasonOutput &= 'CLOSE+'
	;The file or directory is closed.
	$USNReasonOutput = StringTrimRight($USNReasonOutput, 1)
	Return $USNReasonOutput
EndFunc

Func _File_Attributes($FAInput)
	Local $FAOutput = ""
	If BitAND($FAInput, 0x0001) Then $FAOutput &= 'read_only+'
	If BitAND($FAInput, 0x0002) Then $FAOutput &= 'hidden+'
	If BitAND($FAInput, 0x0004) Then $FAOutput &= 'system+'
	If BitAND($FAInput, 0x0010) Then $FAOutput &= 'directory1+'
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
	If BitAND($FAInput, 0x40000) Then $FAOutput &= 'ea+'
	If BitAND($FAInput, 0x10000000) Then $FAOutput &= 'directory2+'
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
	$UsnJrnlFileName = BinaryToString("0x"&$UsnJrnlFileName,2)
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
	$record_type=""
	$transaction_id=""
	$lf_flags=""
	$target_attribute=""
	$lcns_to_follow=""
	$MftClusterIndex=""
	$target_vcn=""
	$target_lcn=""
	$InOpenAttributeTable=-1
	$IncompleteTransaction=0
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
	$HDR_SequenceNo=""
	$TextInformation=""
	$RedoChunkSize=""
	$UndoChunkSize=""
	$CurrentTimestamp=""
	$RealMftRef=""
	$undo_length=""
	$redo_length=""
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
	$LogFileIndxCsvfile = $ParserOutDir & "\LogFile_INDX_I30.csv"
	$LogFileIndxCsv = FileOpen($LogFileIndxCsvfile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileIndxCsvfile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileIndxCsvfile)
	$LogFileUndoWipeIndxCsvfile = $ParserOutDir & "\LogFile_UndoWipe_INDX_I30.csv"
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

	$LogFileSecureSDSCsvFile = $ParserOutDir & "\LogFile_SecurityDescriptors.csv"
	$LogFileSecureSDSCsv = FileOpen($LogFileSecureSDSCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileSecureSDSCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileSecureSDSCsvFile)

	$LogFileSecureSDHCsvFile = $ParserOutDir & "\LogFile_SecureSDH.csv"
	$LogFileSecureSDHCsv = FileOpen($LogFileSecureSDHCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileSecureSDHCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileSecureSDHCsvFile)

	$LogFileSecureSIICsvFile = $ParserOutDir & "\LogFile_SecureSII.csv"
	$LogFileSecureSIICsv = FileOpen($LogFileSecureSIICsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileSecureSIICsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileSecureSIICsvFile)

	$LogFileOpenAttributeTableCsvFile = $ParserOutDir & "\LogFile_OpenAttributeTable.csv"
	$LogFileOpenAttributeTableCsv = FileOpen($LogFileOpenAttributeTableCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileOpenAttributeTableCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileOpenAttributeTableCsvFile)

	$LogFileDirtyPageTableCsvFile = $ParserOutDir & "\LogFile_DirtyPageTable.csv"
	$LogFileDirtyPageTableCsv = FileOpen($LogFileDirtyPageTableCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileDirtyPageTableCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileDirtyPageTableCsvFile)

	$LogFileBitsInNonresidentBitMapCsvFile = $ParserOutDir & "\LogFile_BitsInNonresidentBitMap.csv"
	$LogFileBitsInNonresidentBitMapCsv = FileOpen($LogFileBitsInNonresidentBitMapCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileBitsInNonresidentBitMapCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileBitsInNonresidentBitMapCsvFile)

	$LogFileObjIdOCsvFile = $ParserOutDir & "\LogFile_ObjIdO.csv"
	$LogFileObjIdOCsv = FileOpen($LogFileObjIdOCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileObjIdOCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileObjIdOCsvFile)

	$LogFileQuotaOCsvFile = $ParserOutDir & "\LogFile_QuotaO.csv"
	$LogFileQuotaOCsv = FileOpen($LogFileQuotaOCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileQuotaOCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileQuotaOCsvFile)

	$LogFileQuotaQCsvFile = $ParserOutDir & "\LogFile_QuotaQ.csv"
	$LogFileQuotaQCsv = FileOpen($LogFileQuotaQCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileQuotaQCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileQuotaQCsvFile)

	$LogFileReparseRCsvFile = $ParserOutDir & "\LogFile_ReparseR.csv"
	$LogFileReparseRCsv = FileOpen($LogFileReparseRCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileReparseRCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileReparseRCsvFile)

	$LogFileTransactionTableCsvFile = $ParserOutDir & "\LogFile_TransactionTable.csv"
	$LogFileTransactionTableCsv = FileOpen($LogFileTransactionTableCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileTransactionTableCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileTransactionTableCsvFile)

	$LogFileRCRDCsvFile = $ParserOutDir & "\LogFile_RCRD.csv"
	$LogFileRCRDCsv = FileOpen($LogFileRCRDCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileRCRDCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileRCRDCsvFile)

	$LogFileTransactionHeaderCsvFile = $ParserOutDir & "\LogFile_AllTransactionHeaders.csv"
	$LogFileTransactionHeaderCsv = FileOpen($LogFileTransactionHeaderCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileTransactionHeaderCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileTransactionHeaderCsvFile)

	$LogFileSlackOpenAttributeTableCsvFile = $ParserOutDir & "\LogFile_SlackOpenAttributeTable.csv"
	$LogFileSlackOpenAttributeTableCsv = FileOpen($LogFileSlackOpenAttributeTableCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileSlackOpenAttributeTableCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileSlackOpenAttributeTableCsvFile)

	$LogFileSlackAttributeNamesDumpCsvFile = $ParserOutDir & "\LogFile_SlackAttributeNamesDump.csv"
	$LogFileSlackAttributeNamesDumpCsv = FileOpen($LogFileSlackAttributeNamesDumpCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileSlackAttributeNamesDumpCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileSlackAttributeNamesDumpCsvFile)

	$LogFileAttributeListCsvFile = $ParserOutDir & "\LogFile_AttributeList.csv"
	$LogFileAttributeListCsv = FileOpen($LogFileAttributeListCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileAttributeListCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileAttributeListCsvFile)

	$LogFileFileNamesCsvFile = $ParserOutDir & "\LogFile_FileNames.csv"
	$LogFileFilenamesCsv = FileOpen($LogFileFileNamesCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileFileNamesCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileFileNamesCsvFile)

	$LogFileTxfDataCsvFile = $ParserOutDir & "\LogFile_TxfData.csv"
	$LogFileTxfDataCsv = FileOpen($LogFileTxfDataCsvFile, $EncodingWhenOpen)
	If @error Then
		_DebugOut("Error creating: " & $LogFileTxfDataCsvFile)
		Exit
	EndIf
	_DebugOut("Created output file: " & $LogFileTxfDataCsvFile)
EndFunc

Func _WriteCSVExtraHeader()
	Local $csv_extra_header
	$csv_extra_header = "lf_LSN"&$de&"SI_CTime_Core"&$de&"SI_CTime_Precision"&$de&"SI_ATime_Core"&$de&"SI_ATime_Precision"&$de&"SI_MTime_Core"&$de&"SI_MTime_Precision"&$de&"SI_RTime_Core"&$de&"SI_RTime_Precision"&$de
	$csv_extra_header &= "FN_CTime_Core"&$de&"FN_CTime_Precision"&$de&"FN_ATime_Core"&$de&"FN_ATime_Precision"&$de&"FN_MTime_Core"&$de&"FN_MTime_Precision"&$de&"FN_RTime_Core"&$de&"FN_RTime_Precision"
	FileWriteLine($csvextra, $csv_extra_header & @CRLF)
EndFunc

Func _WriteCSVHeader()
;	$LogFile_Csv_Header = "lf_Offset"&$de&"lf_MFTReference"&$de&"lf_RealMFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_LSN"&$de&"lf_LSNPrevious"&$de&"lf_RedoOperation"&$de&"lf_UndoOperation"&$de&"lf_OffsetInMft"&$de&"lf_FileName"&$de&"lf_CurrentAttribute"&$de&"lf_TextInformation"&$de&"lf_UsnJrnlFileName"&$de&"lf_UsnJrnlMFTReference"&$de&"lf_UsnJrnlMFTParentReference"&$de&"lf_UsnJrnlTimestamp"&$de&"lf_UsnJrnlReason"&$de&"lf_UsnJrnlUsn"&$de&"lf_SI_CTime"&$de&"lf_SI_ATime"&$de&"lf_SI_MTime"&$de&"lf_SI_RTime"&$de&"lf_SI_FilePermission"&$de&"lf_SI_MaxVersions"&$de&"lf_SI_VersionNumber"&$de&"lf_SI_ClassID"&$de&"lf_SI_SecurityID"&$de&"lf_SI_QuotaCharged"&$de&"lf_SI_USN"&$de&"lf_SI_PartialValue"&$de&"lf_FN_CTime"&$de&"lf_FN_ATime"&$de&"lf_FN_MTime"&$de&"lf_FN_RTime"&$de&"lf_FN_AllocSize"&$de&"lf_FN_RealSize"&$de&"lf_FN_Flags"&$de&"lf_FN_Namespace"&$de&"lf_DT_StartVCN"&$de&"lf_DT_LastVCN"&$de&"lf_DT_ComprUnitSize"&$de&"lf_DT_AllocSize"&$de&"lf_DT_RealSize"&$de&"lf_DT_InitStreamSize"&$de&"lf_DT_DataRuns"&$de&"lf_DT_Name"&$de&"lf_FileNameModified"&$de&"lf_RedoChunkSize"&$de&"lf_UndoChunkSize"
	$LogFile_Csv_Header = "lf_Offset"&$de&"lf_MFTReference"&$de&"lf_RealMFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_LSN"&$de&"lf_LSNPrevious"&$de&"lf_RedoOperation"&$de&"lf_UndoOperation"&$de&"lf_OffsetInMft"&$de&"lf_FileName"&$de&"lf_CurrentAttribute"&$de&"lf_TextInformation"&$de&"lf_UsnJrnlFileName"&$de&"lf_UsnJrnlMFTReference"&$de&"lf_UsnJrnlMFTParentReference"&$de&"lf_UsnJrnlTimestamp"&$de&"lf_UsnJrnlReason"&$de&"lf_UsnJrnlUsn"&$de&"lf_SI_CTime"&$de&"lf_SI_ATime"&$de&"lf_SI_MTime"&$de&"lf_SI_RTime"&$de&"lf_SI_FilePermission"&$de&"lf_SI_MaxVersions"&$de&"lf_SI_VersionNumber"&$de&"lf_SI_ClassID"&$de&"lf_SI_SecurityID"&$de&"lf_SI_QuotaCharged"&$de&"lf_SI_USN"&$de&"lf_SI_PartialValue"&$de&"lf_FN_CTime"&$de&"lf_FN_ATime"&$de&"lf_FN_MTime"&$de&"lf_FN_RTime"&$de&"lf_FN_AllocSize"&$de&"lf_FN_RealSize"&$de&"lf_FN_Flags"&$de&"lf_FN_Namespace"&$de&"lf_DT_StartVCN"&$de&"lf_DT_LastVCN"&$de&"lf_DT_ComprUnitSize"&$de&"lf_DT_AllocSize"&$de&"lf_DT_RealSize"&$de&"lf_DT_InitStreamSize"&$de&"lf_DT_DataRuns"&$de&"lf_DT_Name"&$de&"lf_FileNameModified"&$de&"lf_RedoChunkSize"&$de&"lf_UndoChunkSize"&$de&"lf_client_index"&$de&"lf_record_type"&$de&"lf_transaction_id"&$de&"lf_flags"&$de&"lf_target_attribute"&$de&"lf_lcns_to_follow"&$de&"lf_attribute_offset"&$de&"lf_MftClusterIndex"&$de&"lf_target_vcn"&$de&"lf_target_lcn"&$de&"InOpenAttributeTable"&$de&"FromRcrdSlack"&$de&"IncompleteTransaction"
	FileWriteLine($LogFileCsv, $LogFile_Csv_Header & @CRLF)
	$LogFile_Indx_Csv_Header = "lf_Offset"&$de&"lf_LSN"&$de&"lf_EntryNumber"&$de&"lf_MFTReference"&$de&"lf_MFTReferenceSeqNo"&$de&"lf_IndexFlags"&$de&"lf_MFTParentReference"&$de&"lf_MFTParentReferenceSeqNo"&$de&"lf_CTime"&$de&"lf_ATime"&$de&"lf_MTime"&$de&"lf_RTime"&$de&"lf_AllocSize"&$de&"lf_RealSize"&$de&"lf_FileFlags"&$de&"lf_ReparseTag"&$de&"lf_FileName"&$de&"lf_FileNameModified"&$de&"lf_NameSpace"&$de&"lf_SubNodeVCN"
	FileWriteLine($LogFileIndxCsv, $LogFile_Indx_Csv_Header & @CRLF)
	$LogFile_UndoWipe_Indx_Csv_Header = "lf_uw_Offset"&$de&"lf_uw_LSN"&$de&"lf_uw_EntryNumber"&$de&"lf_uw_MFTReference"&$de&"lf_uw_MFTReferenceSeqNo"&$de&"lf_uw_IndexFlags"&$de&"lf_uw_MFTParentReference"&$de&"lf_uw_MFTParentReferenceSeqNo"&$de&"lf_uw_CTime"&$de&"lf_uw_ATime"&$de&"lf_uw_MTime"&$de&"lf_uw_RTime"&$de&"lf_uw_AllocSize"&$de&"lf_uw_RealSize"&$de&"lf_uw_FileFlags"&$de&"lf_uw_ReparseTag"&$de&"lf_uw_FileName"&$de&"lf_uw_FileNameModified"&$de&"lf_uw_NameSpace"&$de&"lf_uw_SubNodeVCN"
	FileWriteLine($LogFileUndoWipeIndxCsv, $LogFile_UndoWipe_Indx_Csv_Header & @CRLF)
	$LogFile_DataRuns_Csv_Header = "lf_Offset"&$de&"lf_MFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_FileName"&$de&"lf_LSN"&$de&"lf_RedoOperation"&$de&"lf_UndoOperation"&$de&"lf_OffsetInMft"&$de&"lf_AttributeOffset"&$de&"lf_SI_USN"&$de&"lf_DataName"&$de&"lf_Flags"&$de&"lf_NonResident"&$de&"lf_CompressionUnitSize"&$de&"lf_FileSize"&$de&"lf_InitializedStreamSize"&$de&"lf_OffsetToDataRuns"&$de&"lf_DataRuns"
	FileWriteLine($LogFileDataRunsCsv, $LogFile_DataRuns_Csv_Header & @CRLF)
	$LogFile_DataRunsResolved_Csv_Header = "lf_MFTReference"&$de&"lf_MFTBaseRecRef"&$de&"lf_FileName"&$de&"lf_LSN"&$de&"lf_OffsetInMft"&$de&"lf_DataName"&$de&"lf_Flags"&$de&"lf_NonResident"&$de&"lf_FileSize"&$de&"lf_InitializedStreamSize"&$de&"lf_DataRuns"
	FileWriteLine($LogFileDataRunsModCsv, $LogFile_DataRunsResolved_Csv_Header & @CRLF)
;	$LogFile_UsnJrnl_Csv_Header = "MFTReference"&$de&"MFTParentReference"&$de&"USN"&$de&"Timestamp"&$de&"Reason"&$de&"SourceInfo"&$de&"FileAttributes"&$de&"FileName"&$de&"FileNameModified"
	$LogFile_UsnJrnl_Csv_Header = "FileName"&$de&"USN"&$de&"Timestamp"&$de&"Reason"&$de&"MFTReference"&$de&"MFTReferenceSeqNo"&$de&"MFTParentReference"&$de&"ParentReferenceSeqNo"&$de&"FileAttributes"&$de&"MajorVersion"&$de&"MinorVersion"&$de&"SourceInfo"&$de&"SecurityId"
	FileWriteLine($LogFileUsnJrnlCsv, $LogFile_UsnJrnl_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVExtra()
	FileWriteLine($csvextra, $this_lsn & $de & $SI_CTime_Core & $de & $SI_CTime_Precision & $de & $SI_ATime_Core & $de & $SI_ATime_Precision & $de & $SI_MTime_Core & $de & $SI_MTime_Precision & $de & $SI_RTime_Core & $de & $SI_RTime_Precision & $de & _
	$FN_CTime_Core & $de & $FN_CTime_Precision & $de & $FN_ATime_Core & $de & $FN_ATime_Precision & $de & $FN_MTime_Core & $de & $FN_MTime_Precision & $de & $FN_RTime_Core & $de & $FN_RTime_Precision & @CRLF)
EndFunc

Func _WriteLogFileCsv()
;	FileWriteLine($LogFileCsv, $RecordOffset & $de & $PredictedRefNumber & $de & $RealMftRef & $de & $HDR_BaseRecord & $de & $this_lsn & $de & $client_previous_lsn & $de & $redo_operation & $de & $undo_operation & $de & $record_offset_in_mft & $de & $FN_Name & $de & $AttributeString & $de & $TextInformation & $de & $UsnJrnlFileName & $de & $UsnJrnlFileReferenceNumber & $de & $UsnJrnlParentFileReferenceNumber & $de & $UsnJrnlTimestamp & $de & $UsnJrnlReason & $de & $UsnJrnlUsn & $de & $SI_CTime & $de & $SI_ATime & $de & $SI_MTime & $de & $SI_RTime & $de & $SI_FilePermission & $de & $SI_MaxVersions & $de & $SI_VersionNumber & $de & $SI_ClassID & $de & $SI_SecurityID & $de & $SI_QuotaCharged & $de & $SI_USN & $de & $SI_PartialValue & $de & $FN_CTime & $de & $FN_ATime & $de & $FN_MTime & $de & $FN_RTime & $de & $FN_AllocSize & $de & $FN_RealSize & $de & $FN_Flags & $de & $FN_NameType & $de & $DT_StartVCN & $de & $DT_LastVCN & $de & $DT_ComprUnitSize & $de & $DT_AllocSize & $de & $DT_RealSize & $de & $DT_InitStreamSize & $de & $DT_DataRuns & $de & $DT_Name & $de & $FileNameModified & $de & $RedoChunkSize & $de & $UndoChunkSize & @crlf)
	FileWriteLine($LogFileCsv, $RecordOffset & $de & $PredictedRefNumber & $de & $RealMftRef & $de & $HDR_BaseRecord & $de & $this_lsn & $de & $client_previous_lsn & $de & $redo_operation & $de & $undo_operation & $de & $record_offset_in_mft & $de & $FN_Name & $de & $AttributeString & $de & $TextInformation & $de & $UsnJrnlFileName & $de & $UsnJrnlFileReferenceNumber & $de & $UsnJrnlParentFileReferenceNumber & $de & $UsnJrnlTimestamp & $de & $UsnJrnlReason & $de & $UsnJrnlUsn & $de & $SI_CTime & $de & $SI_ATime & $de & $SI_MTime & $de & $SI_RTime & $de & $SI_FilePermission & $de & $SI_MaxVersions & $de & $SI_VersionNumber & $de & $SI_ClassID & $de & $SI_SecurityID & $de & $SI_QuotaCharged & $de & $SI_USN & $de & $SI_PartialValue & $de & $FN_CTime & $de & $FN_ATime & $de & $FN_MTime & $de & $FN_RTime & $de & $FN_AllocSize & $de & $FN_RealSize & $de & $FN_Flags & $de & $FN_NameType & $de & $DT_StartVCN & $de & $DT_LastVCN & $de & $DT_ComprUnitSize & $de & $DT_AllocSize & $de & $DT_RealSize & $de & $DT_InitStreamSize & $de & $DT_DataRuns & $de & $DT_Name & $de & $FileNameModified & $de & $RedoChunkSize & $de & $UndoChunkSize & $de & $client_index & $de &$record_type & $de & $transaction_id & $de & $lf_flags & $de & $target_attribute & $de & $lcns_to_follow & $de & $attribute_offset & $de & $MftClusterIndex & $de & $target_vcn & $de & $target_lcn & $de & $InOpenAttributeTable & $de & $FromRcrdSlack & $de & $IncompleteTransaction & @crlf)
EndFunc

Func _WriteLogFileDataRunsCsv()
	If $PredictedRefNumber > 0 And $FN_Name="" Then
		$FN_Name = _GetFileNameFromArray($PredictedRefNumber,$this_lsn)
	EndIf
	FileWriteLine($LogFileDataRunsCsv, $RecordOffset & $de & $PredictedRefNumber & $de & $HDR_BaseRecord & $de & $FN_Name & $de & $this_lsn & $de & $redo_operation & $de & $undo_operation & $de & $record_offset_in_mft & $de & $attribute_offset & $de & $SI_USN & $de & $DT_Name & $de & $DT_Flags & $de & $DT_NonResidentFlag & $de & $DT_ComprUnitSize & $de & $DT_RealSize & $de & $DT_InitStreamSize & $de & $DT_OffsetToDataRuns & $de & $DT_DataRuns & @crlf)
EndFunc

Func _Decode_OpenNonresidentAttribute($datachunk)
	Local $Unknown1, $aMFTReference, $aMFTReferenceSeqNo, $LsnOfOpenRecord, $aAttributeHex, $Unknown2, $AllocatedOrNextFree, $DirtyPagesSeen, $AttributeNamePresent, $UnknownPointer, $EndSignature, $RetVal=0
	If $VerboseOn Then
		_DumpOutput("_Decode_OpenNonresidentAttribute(): " & @CRLF)
		_DumpOutput("LSN: " & $this_lsn & @CRLF)
		_DumpOutput(_HexEncode("0x"&$datachunk) & @CRLF)
	EndIf

	Select
		Case StringLen($datachunk) = 80 ;OPEN_ATTRIBUTE_ENTRY Nt6.x
			If $IsNt5x Then $TextInformation &= ";Mixed OS detected"
			$AllocatedOrNextFree = _SwapEndian(StringMid($datachunk,1,8))
			$DirtyPagesSeen = StringMid($datachunk, 9, 2)
			$AttributeNamePresent = StringMid($datachunk, 11, 2)
			$unknown1 = StringMid($datachunk, 13, 4)

			$aAttributeHex = StringMid($datachunk,17,8)
			$AttributeString = _ResolveAttributeType(StringLeft($aAttributeHex,4))

			$unknown2 = StringMid($datachunk, 25, 8)

			$PredictedRefNumber = Dec(_SwapEndian(StringMid($datachunk,33,12)))
			$KeptRef = $PredictedRefNumber
			$aMFTReferenceSeqNo = Dec(_SwapEndian(StringMid($datachunk,45,4)))
			$LsnOfOpenRecord = Dec(_SwapEndian(StringMid($datachunk,49,16))) ;LsnOfOpenRecord
			$TextInformation &= ";LsnOfOpenRecord="&$LsnOfOpenRecord

			$UnknownPointer = _SwapEndian(StringMid($datachunk, 65, 8))
			$EndSignature = StringMid($datachunk,73,8)
			If $VerboseOn Then
				_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
				_DumpOutput("$DirtyPagesSeen: " & $DirtyPagesSeen & @CRLF)
				_DumpOutput("$AttributeNamePresent: " & $AttributeNamePresent & @CRLF)
				_DumpOutput("$aAttributeHex: " & $aAttributeHex & @CRLF)
				_DumpOutput("$AttributeString: " & $AttributeString & @CRLF)
				_DumpOutput("$Unknown2: " & $Unknown2 & @CRLF)
				_DumpOutput("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
				_DumpOutput("$aMFTReferenceSeqNo: " & $aMFTReferenceSeqNo & @CRLF)
				_DumpOutput("$LsnOfOpenRecord: " & $LsnOfOpenRecord & @CRLF)
				_DumpOutput("$UnknownPointer: " & $UnknownPointer & @CRLF)
				_DumpOutput("$EndSignature: " & $EndSignature & @CRLF)
			EndIf

			$FoundInTable = _ArraySearch($OpenAttributesArray,$target_attribute,0,0,0,2,1,0)
			If $FoundInTable > 0 Then
				If $OpenAttributesArray[$FoundInTable][1] <> 0xffffffff Then
	;				_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
	;				$OpenAttributesArray[$FoundInTable][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
					$OpenAttributesArray[$FoundInTable][1] = "0xFFFFFFFF"
					$OpenAttributesArray[$FoundInTable][2] = "0x" & $DirtyPagesSeen
					$OpenAttributesArray[$FoundInTable][3] = "0x" & $AttributeNamePresent
					$OpenAttributesArray[$FoundInTable][4] = "0x" & $unknown1
					$OpenAttributesArray[$FoundInTable][5] = "0x" & $aAttributeHex
					$OpenAttributesArray[$FoundInTable][6] = "0x" & $unknown2
					$OpenAttributesArray[$FoundInTable][7] = $PredictedRefNumber
					$OpenAttributesArray[$FoundInTable][8] = $aMFTReferenceSeqNo
					$OpenAttributesArray[$FoundInTable][9] = $LsnOfOpenRecord
					$OpenAttributesArray[$FoundInTable][10] = "0x" & $UnknownPointer
					$OpenAttributesArray[$FoundInTable][11] = "0x" & $EndSignature
	;				$OpenAttributesArray[$FoundInTable][12] = "Attribute name in undo chunk"
					$OpenAttributesArray[$FoundInTable][13] = 1
					$RetVal = $FoundInTable
					$TextInformation &= ";Updated OpenAttributesArray"
				Else
					_DumpOutput("Error in OpenNonresidentAttribute for LSN: " & $this_lsn & @CRLF)
					_DumpOutput("AllocatedOrNextFree was 0xffffffff" & @CRLF)
				EndIf
			Else
				#cs
				_DumpOutput("Error in OpenNonresidentAttribute for LSN: " & $this_lsn & @CRLF)
				_DumpOutput("Could not update array with new entry" & @CRLF)
				_DumpOutput(_HexEncode("0x"&$datachunk) & @CRLF)
				_DumpOutput("$target_attribute: " & $target_attribute & @CRLF)
				_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
				_DumpOutput("$DirtyPagesSeen: " & $DirtyPagesSeen & @CRLF)
				_DumpOutput("$AttributeNamePresent: " & $AttributeNamePresent & @CRLF)
				_DumpOutput("$aAttributeHex: " & $aAttributeHex & @CRLF)
				_DumpOutput("$AttributeString: " & $AttributeString & @CRLF)
				_DumpOutput("$Unknown2: " & $Unknown2 & @CRLF)
				_DumpOutput("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
				_DumpOutput("$aMFTReferenceSeqNo: " & $aMFTReferenceSeqNo & @CRLF)
				_DumpOutput("$LsnOfOpenRecord: " & $LsnOfOpenRecord & @CRLF)
				_DumpOutput("$UnknownPointer: " & $UnknownPointer & @CRLF)
				_DumpOutput("$EndSignature: " & $EndSignature & @CRLF)
				_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
				#ce
				$ArrayEnd = UBound($OpenAttributesArray)
				ReDim $OpenAttributesArray[$ArrayEnd+1][14]
				$OpenAttributesArray[$ArrayEnd][0] = $target_attribute
				$OpenAttributesArray[$ArrayEnd][1] = "0x" & $AllocatedOrNextFree
				$OpenAttributesArray[$ArrayEnd][2] = "0x" & $DirtyPagesSeen
				$OpenAttributesArray[$ArrayEnd][3] = "0x" & $AttributeNamePresent
				$OpenAttributesArray[$ArrayEnd][4] = "0x" & $unknown1
				$OpenAttributesArray[$ArrayEnd][5] = "0x" & $aAttributeHex
				$OpenAttributesArray[$ArrayEnd][6] = "0x" & $unknown2
				$OpenAttributesArray[$ArrayEnd][7] = $PredictedRefNumber
				$OpenAttributesArray[$ArrayEnd][8] = $aMFTReferenceSeqNo
				$OpenAttributesArray[$ArrayEnd][9] = $LsnOfOpenRecord
				$OpenAttributesArray[$ArrayEnd][10] = "0x" & $UnknownPointer
				$OpenAttributesArray[$ArrayEnd][11] = "0x" & $EndSignature
				$OpenAttributesArray[$ArrayEnd][13] = 1
				$RetVal = $ArrayEnd
				$TextInformation &= ";Updated OpenAttributesArray"
			EndIf
		Case StringLen($datachunk) = 88 ;OPEN_ATTRIBUTE_ENTRY Nt5.x
			If Not $IsNt5x Then $TextInformation &= ";Mixed OS detected"
			$AllocatedOrNextFree = _SwapEndian(StringMid($datachunk,1,8))
			$UnknownPointer = _SwapEndian(StringMid($datachunk, 9, 8))
			$PredictedRefNumber = Dec(_SwapEndian(StringMid($datachunk,17,12)))
			$KeptRef = $PredictedRefNumber
			$aMFTReferenceSeqNo = Dec(_SwapEndian(StringMid($datachunk,29,4)))
			$LsnOfOpenRecord = Dec(_SwapEndian(StringMid($datachunk,33,16))) ;LsnOfOpenRecord
			$unknown2 = StringMid($datachunk, 49, 8)
			$aAttributeHex = StringMid($datachunk,57,8)
			$AttributeString = _ResolveAttributeType(StringLeft($aAttributeHex,4))
			$unknown3 = StringMid($datachunk, 65, 8)
			$EndSignature = StringMid($datachunk,73,8)
			$DirtyPagesSeen = StringMid($datachunk, 81, 2)
			$AttributeNamePresent = StringMid($datachunk, 83, 2)
			$unknown1 = StringMid($datachunk, 85, 4)
			$TextInformation &= ";LsnOfOpenRecord="&$LsnOfOpenRecord

			If $VerboseOn Then
				_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
				_DumpOutput("$DirtyPagesSeen: " & $DirtyPagesSeen & @CRLF)
				_DumpOutput("$AttributeNamePresent: " & $AttributeNamePresent & @CRLF)
				_DumpOutput("$aAttributeHex: " & $aAttributeHex & @CRLF)
				_DumpOutput("$AttributeString: " & $AttributeString & @CRLF)
				_DumpOutput("$Unknown2: " & $Unknown2 & @CRLF)
				_DumpOutput("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
				_DumpOutput("$aMFTReferenceSeqNo: " & $aMFTReferenceSeqNo & @CRLF)
				_DumpOutput("$LsnOfOpenRecord: " & $LsnOfOpenRecord & @CRLF)
				_DumpOutput("$UnknownPointer: " & $UnknownPointer & @CRLF)
				_DumpOutput("$EndSignature: " & $EndSignature & @CRLF)
			EndIf

			$FoundInTable = _ArraySearch($OpenAttributesArray,$target_attribute,0,0,0,2,1,0)
			If $FoundInTable > 0 Then
				If $OpenAttributesArray[$FoundInTable][1] <> 0xffffffff Then
	;				_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
	;				$OpenAttributesArray[$FoundInTable][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
					$OpenAttributesArray[$FoundInTable][1] = "0xFFFFFFFF"
					$OpenAttributesArray[$FoundInTable][2] = "0x" & $DirtyPagesSeen
					$OpenAttributesArray[$FoundInTable][3] = "0x" & $AttributeNamePresent
					$OpenAttributesArray[$FoundInTable][4] = "0x" & $unknown1
					$OpenAttributesArray[$FoundInTable][5] = "0x" & $aAttributeHex
					$OpenAttributesArray[$FoundInTable][6] = "0x" & $unknown2
					$OpenAttributesArray[$FoundInTable][7] = $PredictedRefNumber
					$OpenAttributesArray[$FoundInTable][8] = $aMFTReferenceSeqNo
					$OpenAttributesArray[$FoundInTable][9] = $LsnOfOpenRecord
					$OpenAttributesArray[$FoundInTable][10] = "0x" & $UnknownPointer
					$OpenAttributesArray[$FoundInTable][11] = "0x" & $EndSignature
	;				$OpenAttributesArray[$FoundInTable][12] = "Attribute name in undo chunk"
					$OpenAttributesArray[$FoundInTable][13] = 0
					$RetVal = $FoundInTable
					$TextInformation &= ";Updated OpenAttributesArray"
;					_DumpOutput($TextInformation & " (existing entry)" & @CRLF)
				Else
					_DumpOutput("Error in OpenNonresidentAttribute for LSN: " & $this_lsn & @CRLF)
					_DumpOutput("AllocatedOrNextFree was 0xffffffff" & @CRLF)
				EndIf
			Else
				#cs
				_DumpOutput("Error in OpenNonresidentAttribute for LSN: " & $this_lsn & @CRLF)
				_DumpOutput("Could not update array with new entry" & @CRLF)
				_DumpOutput(_HexEncode("0x"&$datachunk) & @CRLF)
				_DumpOutput("$target_attribute: " & $target_attribute & @CRLF)
				_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
				_DumpOutput("$DirtyPagesSeen: " & $DirtyPagesSeen & @CRLF)
				_DumpOutput("$AttributeNamePresent: " & $AttributeNamePresent & @CRLF)
				_DumpOutput("$aAttributeHex: " & $aAttributeHex & @CRLF)
				_DumpOutput("$AttributeString: " & $AttributeString & @CRLF)
				_DumpOutput("$Unknown2: " & $Unknown2 & @CRLF)
				_DumpOutput("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
				_DumpOutput("$aMFTReferenceSeqNo: " & $aMFTReferenceSeqNo & @CRLF)
				_DumpOutput("$LsnOfOpenRecord: " & $LsnOfOpenRecord & @CRLF)
				_DumpOutput("$UnknownPointer: " & $UnknownPointer & @CRLF)
				_DumpOutput("$EndSignature: " & $EndSignature & @CRLF)
				_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
				#ce
				$ArrayEnd = UBound($OpenAttributesArray)
				ReDim $OpenAttributesArray[$ArrayEnd+1][14]
				$OpenAttributesArray[$ArrayEnd][0] = $target_attribute
				$OpenAttributesArray[$ArrayEnd][1] = "0x" & $AllocatedOrNextFree
				$OpenAttributesArray[$ArrayEnd][2] = "0x" & $DirtyPagesSeen
				$OpenAttributesArray[$ArrayEnd][3] = "0x" & $AttributeNamePresent
				$OpenAttributesArray[$ArrayEnd][4] = "0x" & $unknown1
				$OpenAttributesArray[$ArrayEnd][5] = "0x" & $aAttributeHex
				$OpenAttributesArray[$ArrayEnd][6] = "0x" & $unknown2
				$OpenAttributesArray[$ArrayEnd][7] = $PredictedRefNumber
				$OpenAttributesArray[$ArrayEnd][8] = $aMFTReferenceSeqNo
				$OpenAttributesArray[$ArrayEnd][9] = $LsnOfOpenRecord
				$OpenAttributesArray[$ArrayEnd][10] = "0x" & $UnknownPointer
				$OpenAttributesArray[$ArrayEnd][11] = "0x" & $EndSignature
				$OpenAttributesArray[$ArrayEnd][13] = 0
				$RetVal = $ArrayEnd
				$TextInformation &= ";Updated OpenAttributesArray"
;_DumpOutput($TextInformation & " (new entry)" & @CRLF)
			EndIf
		Case Else
			_DumpOutput("Error: Unresolved OpenNonresidentAttribute for LSN: " & $this_lsn & @CRLF)
			_DumpOutput(_HexEncode("0x"&$datachunk) & @CRLF)
	EndSelect

	If $VerboseOn Then
		_DumpOutput("_Decode_OpenNonresidentAttribute(): " & @CRLF)
		_DumpOutput("$Unknown1: " & $Unknown1 & @CRLF)
		_DumpOutput("$PredictedRefNumber: " & $PredictedRefNumber & @CRLF)
		_DumpOutput("$aMFTReferenceSeqNo: " & $aMFTReferenceSeqNo & @CRLF)
		_DumpOutput("$LsnOfOpenRecord: " & $LsnOfOpenRecord & @CRLF)
		_DumpOutput("$aAttributeHex: " & $aAttributeHex & @CRLF)
		_DumpOutput("$AttributeString: " & $AttributeString & @CRLF)
		_DumpOutput("$Unknown2: " & $Unknown2 & @CRLF)
	EndIf
	Return $RetVal
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

Func _Decode_SetIndexEntryVcn($data)
	Local $VCN
	$VCN = "0x"&_SwapEndian(StringMid($data,1,16))
;	$VCN = Dec(_SwapEndian(StringMid($data,1,16)),2)
	$TextInformation &= ";VCN="&$VCN
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

Func _TranslateErrorLevel()
	$ErrorLevel = GUICtrlRead($InputErrorLevel)
	$LsnValidationLevel = Number($ErrorLevel)
	$TextString = $LsnValidationLevel*100 & " % (up/down)"
	GUICtrlSetData($InputErrorLevelTranslated,$TextString)
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
#cs
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
#ce
Func _SelectMftCsv()
	$TargetMftCsvFile = FileOpenDialog("Select MFT csv file",@ScriptDir,"All (*.*)")
	If @error then Return
;	_DisplayInfo("Selected MFT csv file: " & $TargetMftCsvFile & @CRLF)
	GUICtrlSetData($MFTField,$TargetMftCsvFile)
EndFunc

Func _LogFileProgress()
    GUICtrlSetData($ProgressStatus, "Processing LogFile RCRD record " & $CurrentRecord & " of " & $MaxRecords)
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
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$EntryCounter=1,$Padding2,$EntryCounter=1,$DecodeOk=False
	Local $Indx_CTime_Core,$Indx_CTime_Precision,$Indx_ATime_Core,$Indx_ATime_Precision,$Indx_MTime_Core,$Indx_MTime_Precision,$Indx_RTime_Core,$Indx_RTime_Precision
	$NewLocalAttributeOffset = 1
;	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+56,8)),2)
;	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$NewLocalAttributeOffset+48,8)),2)
;	$NewLocalAttributeOffset = $NewLocalAttributeOffset+48+($IndxHeaderSize*2)
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = _SwapEndian($MFTReference)
	$MFTReference = Dec($MFTReference,2)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(_SwapEndian($MFTReferenceSeqNo),2)
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(_SwapEndian($IndexEntryLength),2)
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(_SwapEndian($OffsetToFileName),2)
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = _SwapEndian($MFTReferenceOfParent)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent,2)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(_SwapEndian($MFTReferenceOfParentSeqNo),2)
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
	$Indx_AllocSize = Dec(_SwapEndian($Indx_AllocSize),2)
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(_SwapEndian($Indx_RealSize),2)
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,8)
	$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_ReparseTag = StringMid($Entry,$NewLocalAttributeOffset+152,8)
	$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
	$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
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
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*4)
	$Indx_FileName = BinaryToString("0x"&$Indx_FileName,2)
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

;	FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
	If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
		$DecodeOk=True
		FileWriteLine($LogFileUndoWipeIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_ReparseTag & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		$PredictedRefNumber = $MFTReferenceOfParent
		$KeptRef = $MFTReferenceOfParent
		$AttributeString = "$INDEX_ALLOCATION"
		If Not $FromRcrdSlack Then
			If $Indx_NameSpace <> "DOS" Then _UpdateFileNameArray($MFTReference,$MFTReferenceSeqNo,$Indx_FileName,$this_lsn)
		EndIf
	EndIf
; Work through the rest of the index entries
	$NextEntryOffset = $NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
	If $NextEntryOffset+64 >= StringLen($Entry) Then Return $DecodeOk
	Do
		$EntryCounter += 1
		$MFTReference = StringMid($Entry,$NextEntryOffset,12)
		$MFTReference = _SwapEndian($MFTReference)
		$MFTReference = Dec($MFTReference,2)
		$MFTReferenceSeqNo = StringMid($Entry,$NextEntryOffset+12,4)
		$MFTReferenceSeqNo = Dec(_SwapEndian($MFTReferenceSeqNo),2)
		$IndexEntryLength = StringMid($Entry,$NextEntryOffset+16,4)
		$IndexEntryLength = Dec(_SwapEndian($IndexEntryLength),2)
		$OffsetToFileName = StringMid($Entry,$NextEntryOffset+20,4)
		$OffsetToFileName = Dec(_SwapEndian($OffsetToFileName),2)
		$IndexFlags = StringMid($Entry,$NextEntryOffset+24,4)
		$Padding = StringMid($Entry,$NextEntryOffset+28,4)
		$MFTReferenceOfParent = StringMid($Entry,$NextEntryOffset+32,12)
		$MFTReferenceOfParent = _SwapEndian($MFTReferenceOfParent)
		$MFTReferenceOfParent = Dec($MFTReferenceOfParent,2)
		$MFTReferenceOfParentSeqNo = StringMid($Entry,$NextEntryOffset+44,4)
		$MFTReferenceOfParentSeqNo = Dec(_SwapEndian($MFTReferenceOfParentSeqNo),2)

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
		$Indx_AllocSize = Dec(_SwapEndian($Indx_AllocSize),2)
		$Indx_RealSize = StringMid($Entry,$NextEntryOffset+128,16)
		$Indx_RealSize = Dec(_SwapEndian($Indx_RealSize),2)
		$Indx_File_Flags = StringMid($Entry,$NextEntryOffset+144,8)
		$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
		$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
		$Indx_ReparseTag = StringMid($Entry,$NextEntryOffset+152,8)
		$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
		$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
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
		$Indx_FileName = StringMid($Entry,$NextEntryOffset+164,$Indx_NameLength*4)
		$Indx_FileName = BinaryToString("0x"&$Indx_FileName,2)
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

;		FileWriteLine($LogFileIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
		If $MFTReference > 0 And $MFTReferenceSeqNo > 0 And $MFTReferenceOfParent > 4 And $Indx_NameLength > 0  And $Indx_CTime<>"-" And $Indx_ATime<>"-" And $Indx_MTime<>"-" And $Indx_RTime<>"-" Then
			$DecodeOk=True
			FileWriteLine($LogFileUndoWipeIndxCsv, $RecordOffset & $de & $this_lsn & $de & $EntryCounter & $de & $MFTReference & $de & $MFTReferenceSeqNo & $de & $IndexFlags & $de & $MFTReferenceOfParent & $de & $MFTReferenceOfParentSeqNo & $de & $Indx_CTime & $de & $Indx_ATime & $de & $Indx_MTime & $de & $Indx_RTime & $de & $Indx_AllocSize & $de & $Indx_RealSize & $de & $Indx_File_Flags & $de & $Indx_ReparseTag & $de & $Indx_FileName & $de & $FileNameModified & $de & $Indx_NameSpace & $de & $SubNodeVCN & @crlf)
			$PredictedRefNumber = $MFTReferenceOfParent
			$KeptRef = $MFTReferenceOfParent
			$AttributeString = "$INDEX_ALLOCATION"
			If Not $FromRcrdSlack Then
				If $Indx_NameSpace <> "DOS" Then _UpdateFileNameArray($MFTReference,$MFTReferenceSeqNo,$Indx_FileName,$this_lsn)
			EndIf
		EndIf
;		_ArrayDisplay($IndxMFTReferenceOfParentArr,"$IndxMFTReferenceOfParentArr")
	Until $NextEntryOffset+32 >= StringLen($Entry)
;	_ArrayDisplay($IndxMFTReferenceOfParentArr,"$IndxMFTReferenceOfParentArr")
	Return $DecodeOk
EndFunc

Func _UsnDecodeRecord2($Record)
	Local $UsnJrnlRecordLength,$UsnJrnlMajorVersion,$UsnJrnlMFTReferenceSeqNo,$UsnJrnlParentReferenceSeqNo
	Local $UsnJrnlSourceInfo,$UsnJrnlSecurityId,$UsnJrnlFileAttributes,$UsnJrnlFileNameLength,$UsnJrnlFileNameOffset,$DecodeOk=False
;	$UsnJrnlRecordLength = StringMid($Record,1,8)
;	$UsnJrnlRecordLength = Dec(_SwapEndian($UsnJrnlRecordLength),2)
	$UsnJrnlMajorVersion = StringMid($Record,9,4)
	$UsnJrnlMajorVersion = Dec(_SwapEndian($UsnJrnlMajorVersion),2)
	$UsnJrnlMinorVersion = StringMid($Record,13,4)
	$UsnJrnlMinorVersion = Dec(_SwapEndian($UsnJrnlMinorVersion),2)
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
	$UsnJrnlSourceInfo = StringMid($Record,89,8)
;	$UsnJrnlSourceInfo = _DecodeSourceInfoFlag("0x"&_SwapEndian($UsnJrnlSourceInfo))
	$UsnJrnlSourceInfo = "0x"&_SwapEndian($UsnJrnlSourceInfo)
	$UsnJrnlSecurityId = StringMid($Record,97,8)
	$UsnJrnlSecurityId = Dec(_SwapEndian($UsnJrnlSecurityId),2)
	$UsnJrnlFileAttributes = StringMid($Record,105,8)
	$UsnJrnlFileAttributes = _File_Attributes("0x"&_SwapEndian($UsnJrnlFileAttributes))
	$UsnJrnlFileNameLength = StringMid($Record,113,4)
	$UsnJrnlFileNameLength = Dec(_SwapEndian($UsnJrnlFileNameLength),2)
;	$UsnJrnlFileNameOffset = StringMid($Record,117,4)
;	$UsnJrnlFileNameOffset = Dec(_SwapEndian($UsnJrnlFileNameOffset),2)
	$UsnJrnlFileName = StringMid($Record,121,$UsnJrnlFileNameLength*2)
	$UsnJrnlFileName = BinaryToString("0x"&$UsnJrnlFileName,2)
	If $VerboseOn Then
		_DumpOutput("_UsnDecodeRecord2(): " & @CRLF)
		_DumpOutput("$UsnJrnlFileReferenceNumber: " & $UsnJrnlFileReferenceNumber & @CRLF)
		_DumpOutput("$UsnJrnlMFTReferenceSeqNo: " & $UsnJrnlMFTReferenceSeqNo & @CRLF)
		_DumpOutput("$UsnJrnlParentFileReferenceNumber: " & $UsnJrnlParentFileReferenceNumber & @CRLF)
		_DumpOutput("$UsnJrnlParentReferenceSeqNo: " & $UsnJrnlParentReferenceSeqNo & @CRLF)
		_DumpOutput("$UsnJrnlUsn: " & $UsnJrnlUsn & @CRLF)
		_DumpOutput("$UsnJrnlTimestamp: " & $UsnJrnlTimestamp & @CRLF)
		_DumpOutput("$UsnJrnlReason: " & $UsnJrnlReason & @CRLF)
;		_DumpOutput("$UsnJrnlSourceInfo: " & $UsnJrnlSourceInfo & @CRLF)
;		_DumpOutput("$UsnJrnlSecurityId: " & $UsnJrnlSecurityId & @CRLF)
		_DumpOutput("$UsnJrnlFileAttributes: " & $UsnJrnlFileAttributes & @CRLF)
		_DumpOutput("$UsnJrnlFileName: " & $UsnJrnlFileName & @CRLF)
	EndIf
;	If Int($UsnJrnlFileReferenceNumber) > 0 And Int($UsnJrnlMFTReferenceSeqNo) > 0 And Int($UsnJrnlParentFileReferenceNumber) > 4 And $UsnJrnlFileNameLength > 0  And $UsnJrnlTimestamp<>"-" And StringInStr($UsnJrnlTimestamp,"1601")=0 Then
	If Int($UsnJrnlFileReferenceNumber) > 0 And Int($UsnJrnlMFTReferenceSeqNo) > 0 And Int($UsnJrnlParentFileReferenceNumber) > 4 And $UsnJrnlFileNameLength > 0  And $UsnJrnlTimestamp<>"-" Then
		$DecodeOk=True
		FileWriteLine($LogFileUsnJrnlCsv, $UsnJrnlFileName&$de&$UsnJrnlUsn&$de&$UsnJrnlTimestamp&$de&$UsnJrnlReason&$de&$UsnJrnlFileReferenceNumber&$de&$UsnJrnlMFTReferenceSeqNo&$de&$UsnJrnlParentFileReferenceNumber&$de&$UsnJrnlParentReferenceSeqNo&$de&$UsnJrnlFileAttributes&$de&$UsnJrnlMajorVersion&$de&$UsnJrnlMinorVersion&$de&$UsnJrnlSourceInfo&$de&$UsnJrnlSecurityId&@crlf)
		$RealMftRef = $PredictedRefNumber
		$UsnJrnlRef = $PredictedRefNumber
		$PredictedRefNumber = $UsnJrnlFileReferenceNumber
		$KeptRef = $UsnJrnlFileReferenceNumber
		$FN_Name = $UsnJrnlFileName
		$HDR_SequenceNo = $UsnJrnlMFTReferenceSeqNo
		$AttributeString = "$DATA:$J"
	Else
		#cs
		_DumpOutput("Error in _UsnDecodeRecord2(): " & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$UsnJrnlFileReferenceNumber: " & $UsnJrnlFileReferenceNumber & @CRLF)
		_DumpOutput("$UsnJrnlMFTReferenceSeqNo: " & $UsnJrnlMFTReferenceSeqNo & @CRLF)
		_DumpOutput("$UsnJrnlParentFileReferenceNumber: " & $UsnJrnlParentFileReferenceNumber & @CRLF)
		_DumpOutput("$UsnJrnlParentReferenceSeqNo: " & $UsnJrnlParentReferenceSeqNo & @CRLF)
		_DumpOutput("$UsnJrnlUsn: " & $UsnJrnlUsn & @CRLF)
		_DumpOutput("$UsnJrnlTimestamp: " & $UsnJrnlTimestamp & @CRLF)
		_DumpOutput("$UsnJrnlReason: " & $UsnJrnlReason & @CRLF)
		_DumpOutput("$UsnJrnlFileAttributes: " & $UsnJrnlFileAttributes & @CRLF)
		_DumpOutput("$UsnJrnlFileName: " & $UsnJrnlFileName & @CRLF)
		#ce
		$UsnJrnlFileReferenceNumber=""
		$UsnJrnlParentFileReferenceNumber=""
		$UsnJrnlUsn=""
		$UsnJrnlTimestamp=""
		$UsnJrnlReason=""
		$UsnJrnlFileName=""
	EndIf
	Return $DecodeOk
EndFunc

Func _Decode_AttributeName($data)
	Local $TmpName
	$TmpName = BinaryToString("0x"&$data,2)
	$AttributeString &= ":"&$TmpName
	Return $TmpName
EndFunc

Func _SetNameOnSystemFiles()
	Local $LocalRef = $PredictedRefNumber
	If $PredictedRefNumber = 0 And $RealMftRef <> 0 Then $LocalRef = $RealMftRef
	Select
		Case $LocalRef = 0
			$FN_Name = "$MFT"
		Case $LocalRef = 1
			$FN_Name = "$MFTMirr"
		Case $LocalRef = 2
			$FN_Name = "$LogFile"
		Case $LocalRef = 3
			$FN_Name = "$Volume"
		Case $LocalRef = 4
			$FN_Name = "$AttrDef"
		Case $LocalRef = 5
			$FN_Name = "."
		Case $LocalRef = 6
			$FN_Name = "$Bitmap"
		Case $LocalRef = 7
			$FN_Name = "$Boot"
		Case $LocalRef = 8
			$FN_Name = "$BadClus"
		Case $LocalRef = 9
			$FN_Name = "$Secure"
		Case $LocalRef = 10
			$FN_Name = "$UpCase"
		Case $LocalRef = 11
			$FN_Name = "$Extend"
		Case $LocalRef = 24
			$FN_Name = "$Quota"
		Case $LocalRef = 25
			$FN_Name = "$ObjId"
		Case $LocalRef = 26
			$FN_Name = "$Reparse"
		Case $LocalRef = 27
			If Not $IsNt5x Then $FN_Name = "$RmMetadata"
		Case $LocalRef = 28
			If Not $IsNt5x Then $FN_Name = "$Repair"
		Case $LocalRef = 29
			If Not $IsNt5x Then $FN_Name = "TxfLog"
		Case $LocalRef = 30
			If Not $IsNt5x Then $FN_Name = "$Txf"
		Case $LocalRef = 31
			If Not $IsNt5x Then $FN_Name = "$Tops"
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
;				ConsoleWrite("Found offset: " & $TestOffset & @CRLF)
				$check=1
			EndIf
;			If Not $check Then ContinueLoop
			If Not StringIsDigit($FoundOffset) Then _DumpOutput("Not number: " & $FoundOffset & " at lsn " & $this_lsn)
			If Int($TestOffsetAttr) > Int($FoundOffset) Then ContinueLoop
			If $TestOffset Then
				$AttrArraySplit[$i] = ''
			Else
				If $AttrArraySplit[$i] = '' Then ContinueLoop
				If Int($TestOffsetAttr) < Int($FoundOffset) Then
					$AttrArraySplit[$i] = $FoundAttr&'?'&Int($FoundOffset)-Int($TestSize)
					ConsoleWrite("Modified entry: " & $FoundAttr&'?'&Int($FoundOffset)-Int($TestSize) & @CRLF)
					If Int($FoundOffset)-Int($TestSize) < 0 Then _DebugOut("Error in _RemoveSingleOffsetOfAttribute() with " & $this_lsn)
				EndIf
			EndIf
		Next
		For $i = 1 To $AttrArraySplit[0]-1
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			$ConcatString &= $AttrArraySplit[$i]&','
		Next
		$AttrArray[$RefIndex][1] = $ConcatString
	Else
;		ConsoleWrite("Error: Ref not found" & @CRLF)
	EndIf
EndFunc

Func _RemoveAllOffsetOfAttribute($TestRef)
	Local $RefIndex
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
		ConsoleWrite("Ref already exist in array" & @CRLF)
		$AttrArray[$RefIndex][1] = ''
	Else
;		ConsoleWrite("Error: Ref not found" & @CRLF)
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
;				ConsoleWrite("Found offset: " & $TestOffset & @CRLF)
			EndIf
			If Not StringIsDigit($FoundOffset) Then _DumpOutput("Not number: " & $FoundOffset & " at lsn " & $this_lsn)
			If Int($TestOffsetAttr) > Int($FoundOffset) Then ContinueLoop
			If $AttrArraySplit[$i] = '' Then ContinueLoop
			If Int($TestOffsetAttr) = Int($FoundOffset) Then
				$AttrArraySplit[$i] = $TestString&'?'&$TestOffsetAttr
				$check=1
			ElseIf Int($TestOffsetAttr) < Int($FoundOffset) Then
				$AttrArraySplit[$i] = $FoundAttr&'?'&Int($FoundOffset)+Int($TestSize)
				ConsoleWrite("Modified entry: " & $FoundAttr&'?'&Int($FoundOffset)+Int($TestSize) & @CRLF)
				If Int($FoundOffset)-Int($TestSize) < 0 Then _DebugOut("Error in _UpdateSingleOffsetOfAttribute() with " & $this_lsn)
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
;		_ArrayDisplay($AttrArraySplit,"$AttrArraySplit")
	EndIf
	$RefIndex = _ArraySearch($AttrArray, $TestRef)
	If $RefIndex <> -1 Or Not @error Then
		$AttrArraySplit = StringSplit($AttrArray[$RefIndex][1], ',')
		If $VerboseOn Then
;			_ArrayDisplay($AttrArraySplit,"$AttrArraySplit")
		EndIf
		For $i = 1 To $AttrArraySplit[0]
			$TestOffset = StringInStr($AttrArraySplit[$i], $TestString)
			If $VerboseOn Then
				ConsoleWrite("$AttrArraySplit[$i]: " & $AttrArraySplit[$i] & @CRLF)
				ConsoleWrite("$TestOffset: " & $TestOffset & @CRLF)
			EndIf
			If $TestOffset Then
				If Not StringIsDigit(StringMid($AttrArraySplit[$i],$TestOffset-1,1)) Then
					If StringMid($AttrArraySplit[$i],$TestOffset-1,1) <> '?' Then _DebugOut("Error in _CheckOffsetOfAttribute()",$AttrArraySplit[$i] & " -> " & StringMid($AttrArraySplit[$i] & " at offset " & $TestOffset-1,1))
					$FoundAttr = StringMid($AttrArraySplit[$i], 1, $TestOffset-2)
;					ConsoleWrite("$FoundAttr: " & $FoundAttr & @CRLF)
					Return $FoundAttr
				EndIf
			EndIf
		Next
;		ConsoleWrite("Error: Attribute offset not found" & @CRLF)
		Return SetError(1,0,$FoundAttr)
	Else
;		ConsoleWrite("Error: Ref not found" & @CRLF)
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

;--------------Security------------------
Func _IsSmallAceStruct($input)
	Select
		Case $input=$ACCESS_ALLOWED_ACE_TYPE Or $input=$ACCESS_DENIED_ACE_TYPE Or $input=$SYSTEM_AUDIT_ACE_TYPE
			Return 1
		Case $input=$ACCESS_ALLOWED_CALLBACK_ACE_TYPE Or $input=$ACCESS_DENIED_CALLBACK_ACE_TYPE Or $input=$SYSTEM_AUDIT_CALLBACK_ACE_TYPE
			Return 1
		Case $input=$SYSTEM_MANDATORY_LABEL_ACE_TYPE Or $input=$SYSTEM_RESOURCE_ATTRIBUTE_ACE_TYPE Or $input=$SYSTEM_SCOPED_POLICY_ID_ACE_TYPE Or $input=$SYSTEM_PROCESS_TRUST_LABEL_ACE_TYPE
			Return 1
		Case $input=$ACCESS_ALLOWED_OBJECT_ACE_TYPE Or $input=$ACCESS_DENIED_OBJECT_ACE_TYPE Or $input=$SYSTEM_AUDIT_OBJECT_ACE_TYPE
			Return 0
		Case $input=$ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE Or $input=$ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE Or $input=$SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE
			Return 0
	EndSelect
EndFunc

Func _DecodeAceFlags($input)
	Local $output = ""
	If $input = 0x00 Then Return 'ZERO'
	If BitAND($input, $CONTAINER_INHERIT_ACE) Then $output &= 'CONTAINER_INHERIT_ACE+'
	If BitAND($input, $FAILED_ACCESS_ACE_FLAG) Then $output &= 'FAILED_ACCESS_ACE_FLAG+'
	If BitAND($input, $INHERIT_ONLY_ACE) Then $output &= 'INHERIT_ONLY_ACE+'
	If BitAND($input, $INHERITED_ACE) Then $output &= 'INHERITED_ACE+'
	If BitAND($input, $NO_PROPAGATE_INHERIT_ACE) Then $output &= 'NO_PROPAGATE_INHERIT_ACE+'
	If BitAND($input, $OBJECT_INHERIT_ACE) Then $output &= 'OBJECT_INHERIT_ACE+'
	If BitAND($input, $SUCCESSFUL_ACCESS_ACE_FLAG) Then $output &= 'SUCCESSFUL_ACCESS_ACE_FLAG+'
	$output = StringTrimRight($output, 1)
	Return $output
EndFunc

Func _DecodeAceType($input)
	Local $output = ""
	If $input = $ACCESS_ALLOWED_ACE_TYPE Then Return 'ACCESS_ALLOWED_ACE_TYPE'
	If $input = $ACCESS_DENIED_ACE_TYPE Then Return 'ACCESS_DENIED_ACE_TYPE'
	If $input = $SYSTEM_AUDIT_ACE_TYPE Then Return 'SYSTEM_AUDIT_ACE_TYPE'
	If $input = $SYSTEM_ALARM_ACE_TYPE Then Return 'SYSTEM_ALARM_ACE_TYPE'
	If $input = $ACCESS_ALLOWED_COMPOUND_ACE_TYPE Then Return 'ACCESS_ALLOWED_COMPOUND_ACE_TYPE'
	If $input = $ACCESS_ALLOWED_OBJECT_ACE_TYPE Then Return 'ACCESS_ALLOWED_OBJECT_ACE_TYPE'
	If $input = $ACCESS_DENIED_OBJECT_ACE_TYPE Then Return 'ACCESS_DENIED_OBJECT_ACE_TYPE'
	If $input = $SYSTEM_AUDIT_OBJECT_ACE_TYPE Then Return 'SYSTEM_AUDIT_OBJECT_ACE_TYPE'
	If $input = $SYSTEM_ALARM_OBJECT_ACE_TYPE Then Return 'SYSTEM_ALARM_OBJECT_ACE_TYPE'
	If $input = $ACCESS_ALLOWED_CALLBACK_ACE_TYPE Then Return 'ACCESS_ALLOWED_CALLBACK_ACE_TYPE'
	If $input = $ACCESS_DENIED_CALLBACK_ACE_TYPE Then Return 'ACCESS_DENIED_CALLBACK_ACE_TYPE'
	If $input = $ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE Then Return 'ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE'
	If $input = $ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE Then Return 'ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE'
	If $input = $SYSTEM_AUDIT_CALLBACK_ACE_TYPE Then Return 'SYSTEM_AUDIT_CALLBACK_ACE_TYPE'
	If $input = $SYSTEM_ALARM_CALLBACK_ACE_TYPE Then Return 'SYSTEM_ALARM_CALLBACK_ACE_TYPE'
	If $input = $SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE Then Return 'SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE'
	If $input = $SYSTEM_ALARM_CALLBACK_OBJECT_ACE_TYPE Then Return 'SYSTEM_ALARM_CALLBACK_OBJECT_ACE_TYPE'
	If $input = $SYSTEM_MANDATORY_LABEL_ACE_TYPE Then Return 'SYSTEM_MANDATORY_LABEL_ACE_TYPE'
	If $input = $SYSTEM_RESOURCE_ATTRIBUTE_ACE_TYPE Then Return 'SYSTEM_RESOURCE_ATTRIBUTE_ACE_TYPE'
	If $input = $SYSTEM_SCOPED_POLICY_ID_ACE_TYPE Then Return 'SYSTEM_SCOPED_POLICY_ID_ACE_TYPE'
	If $input = $SYSTEM_PROCESS_TRUST_LABEL_ACE_TYPE Then Return 'SYSTEM_PROCESS_TRUST_LABEL_ACE_TYPE'
;	$output = StringTrimRight($output, 1)
	Return "UNKNOWN"
EndFunc

Func _SecurityDescriptorControl($input)
	Local $output = ""
	If BitAND($input, $SE_OWNER_DEFAULTED) Then $output &= 'SE_OWNER_DEFAULTED+'
	If BitAND($input, $SE_GROUP_DEFAULTED) Then $output &= 'SE_GROUP_DEFAULTED+'
	If BitAND($input, $SE_DACL_PRESENT) Then $output &= 'SE_DACL_PRESENT+'
	If BitAND($input, $SE_DACL_DEFAULTED) Then $output &= 'SE_DACL_DEFAULTED+'
	If BitAND($input, $SE_SACL_PRESENT) Then $output &= 'SE_SACL_PRESENT+'
	If BitAND($input, $SE_SACL_DEFAULTED) Then $output &= 'SE_SACL_DEFAULTED+'
	If BitAND($input, $SE_DACL_UNTRUSTED) Then $output &= 'SE_DACL_UNTRUSTED+'
	If BitAND($input, $SE_SERVER_SECURITY) Then $output &= 'SE_SERVER_SECURITY+'
	If BitAND($input, $SE_DACL_AUTO_INHERIT_REQ) Then $output &= 'SE_DACL_AUTO_INHERIT_REQ+'
	If BitAND($input, $SE_SACL_AUTO_INHERIT_REQ) Then $output &= 'SE_SACL_AUTO_INHERIT_REQ+'
	If BitAND($input, $SE_DACL_AUTO_INHERITED) Then $output &= 'SE_DACL_AUTO_INHERITED+'
	If BitAND($input, $SE_SACL_AUTO_INHERITED) Then $output &= 'SE_SACL_AUTO_INHERITED+'
	If BitAND($input, $SE_DACL_PROTECTED) Then $output &= 'SE_DACL_PROTECTED+'
	If BitAND($input, $SE_SACL_PROTECTED) Then $output &= 'SE_SACL_PROTECTED+'
	If BitAND($input, $SE_RM_CONTROL_VALID) Then $output &= 'SE_RM_CONTROL_VALID+'
	If BitAND($input, $SE_SELF_RELATIVE) Then $output &= 'SE_SELF_RELATIVE+'
	$output = StringTrimRight($output, 1)
	Return $output
EndFunc

Func _DecodeAceObjectFlag($input)
	Local $output = ""
	If $input = $ACE_NO_VALID_OBJECT_TYPE_PRESENT Then Return 'ACE_NO_VALID_OBJECT_TYPE_PRESENT'
	If $input = $ACE_OBJECT_TYPE_PRESENT Then Return 'ACE_OBJECT_TYPE_PRESENT'
	If $input = $ACE_INHERITED_OBJECT_TYPE_PRESENT Then Return 'ACE_INHERITED_OBJECT_TYPE_PRESENT'
	Return "UNKNOWN"
;	If BitAND($input, $ACE_OBJECT_TYPE_PRESENT) Then $output &= 'ACE_OBJECT_TYPE_PRESENT+'
;	If BitAND($input, $ACE_INHERITED_OBJECT_TYPE_PRESENT) Then $output &= 'ACE_INHERITED_OBJECT_TYPE_PRESENT+'
;	$output = StringTrimRight($output, 1)
;	Return $output
EndFunc

Func _DecodeSecurityDescriptorAttribute($InputData)
	;http://0cch.net/ntfsdoc/attributes/security_descriptor.html
	Local $StartOffset = 1
	Global $SecurityDescriptorHash,$SecurityId,$ControlText,$SidOwner,$SidGroup
;	ConsoleWrite("_DecodeSDSChunk() " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$InputData))

;	Start SelfrelativeSecurityDescriptor
	$Revision = StringMid($InputData, $StartOffset, 2)

	$Revision = Dec($Revision)
	If $Revision <> 1 Then
;		ConsoleWrite("Error: Revision invalid: " & $Revision & @CRLF)
;		Return
	EndIf
	$Sbz1 = StringMid($InputData, $StartOffset + 2, 2)

	$SECURITY_DESCRIPTOR_CONTROL = StringMid($InputData, $StartOffset + 4, 4)
	$SECURITY_DESCRIPTOR_CONTROL = _SwapEndian($SECURITY_DESCRIPTOR_CONTROL)

	$ControlText = _SecurityDescriptorControl("0x"&$SECURITY_DESCRIPTOR_CONTROL)

	If Not BitAND("0x"&$SECURITY_DESCRIPTOR_CONTROL, $SE_SELF_RELATIVE) Then
		ConsoleWrite("Error: Descriptor not self relative. Nothing to do" & @CRLF)
		Return
	EndIf
	$PSidOwner = StringMid($InputData, $StartOffset + 8, 8)
	$PSidOwner = _SwapEndian($PSidOwner)

	$PSidOwner = Dec($PSidOwner)
	$PSidGroup = StringMid($InputData, $StartOffset + 16, 8)
	$PSidGroup = _SwapEndian($PSidGroup)

	$PSidGroup = Dec($PSidGroup)
	$PSacl = StringMid($InputData, $StartOffset + 24, 8)
	$PSacl = _SwapEndian($PSacl)

	$PSacl = Dec($PSacl)
	$PDacl = StringMid($InputData, $StartOffset + 32, 8)
	$PDacl = _SwapEndian($PDacl)

	$PDacl = Dec($PDacl)
	If $PSidOwner > 0 Then
		$SidOwner = _DecodeSID(StringMid($InputData,$StartOffset+$PSidOwner*2))
	EndIf
	If $PSidGroup > 0 Then
		$SidGroup = _DecodeSID(StringMid($InputData,$StartOffset+$PSidGroup*2))
	EndIf
	If $PSacl > 0 Then
		_DecodeAcl_S(StringMid($InputData,$StartOffset+$PSacl*2))
	EndIf
	If $PDacl > 0 Then
		_DecodeAcl_D(StringMid($InputData,$StartOffset+$PDacl*2))
	EndIf
	#cs
	ConsoleWrite("$SecurityDescriptorHash: " & $SecurityDescriptorHash & @CRLF)
	ConsoleWrite("$SecurityId: " & $SecurityId & @CRLF)
	ConsoleWrite("$EntryOffset: " & $EntryOffset & @CRLF)
	ConsoleWrite("$EntrySize: " & $EntrySize & @CRLF)
	ConsoleWrite("$Revision: " & $Revision & @CRLF)
	ConsoleWrite("$Sbz1: " & $Sbz1 & @CRLF)
	ConsoleWrite("$SECURITY_DESCRIPTOR_CONTROL: " & $SECURITY_DESCRIPTOR_CONTROL & @CRLF)
	ConsoleWrite("$ControlText: " & $ControlText & @CRLF)
	ConsoleWrite("$PSidOwner: " & $PSidOwner & @CRLF)
	ConsoleWrite("$PSidGroup: " & $PSidGroup & @CRLF)
	ConsoleWrite("$PSacl: " & $PSacl & @CRLF)
	ConsoleWrite("$PDacl: " & $PDacl & @CRLF)
	#ce
EndFunc

Func _DecodeSDSChunk($InputData, $Hash)
	;https://msdn.microsoft.com/en-us/library/cc230366.aspx
	Local $StartOffset = 1
	Global $SecurityDescriptorHash,$SecurityId,$ControlText,$SidOwner,$SidGroup
;	ConsoleWrite("_DecodeSDSChunk() " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$InputData))
	$SecurityDescriptorHash = StringMid($InputData, $StartOffset, 8)
;	$SecurityDescriptorHash = _SwapEndian($SecurityDescriptorHash)
	If $SecurityDescriptorHash <> $Hash Then
		ConsoleWrite("Error: Hash mismatch" & @CRLF)
		Return
	EndIf
	$SecurityDescriptorHash = "0x" & $SecurityDescriptorHash

	$SecurityId = StringMid($InputData, $StartOffset + 8, 8)
	$SecurityId = _SwapEndian($SecurityId)
	$SecurityId = Dec($SecurityId,2)

	$EntryOffset = StringMid($InputData, $StartOffset + 16, 16)
	$EntryOffset = _SwapEndian($EntryOffset)

	$EntrySize = StringMid($InputData, $StartOffset + 32, 8)
	$EntrySize = _SwapEndian($EntrySize)

;	Start SelfrelativeSecurityDescriptor
	$Revision = StringMid($InputData, $StartOffset + 40, 2)

	$Revision = Dec($Revision)
	If $Revision <> 1 Then
;		ConsoleWrite("Error: Revision invalid: " & $Revision & @CRLF)
;		Return
	EndIf
	$Sbz1 = StringMid($InputData, $StartOffset + 42, 2)

	$SECURITY_DESCRIPTOR_CONTROL = StringMid($InputData, $StartOffset + 44, 4)
	$SECURITY_DESCRIPTOR_CONTROL = _SwapEndian($SECURITY_DESCRIPTOR_CONTROL)

	$ControlText = _SecurityDescriptorControl("0x"&$SECURITY_DESCRIPTOR_CONTROL)

	If Not BitAND("0x"&$SECURITY_DESCRIPTOR_CONTROL, $SE_SELF_RELATIVE) Then
		ConsoleWrite("Error: Descriptor not self relative. Nothing to do" & @CRLF)
		Return
	EndIf
	$PSidOwner = StringMid($InputData, $StartOffset + 48, 8)
	$PSidOwner = _SwapEndian($PSidOwner)

	$PSidOwner = Dec($PSidOwner)
	$PSidGroup = StringMid($InputData, $StartOffset + 56, 8)
	$PSidGroup = _SwapEndian($PSidGroup)

	$PSidGroup = Dec($PSidGroup)
	$PSacl = StringMid($InputData, $StartOffset + 64, 8)
	$PSacl = _SwapEndian($PSacl)

	$PSacl = Dec($PSacl)
	$PDacl = StringMid($InputData, $StartOffset + 72, 8)
	$PDacl = _SwapEndian($PDacl)

	$PDacl = Dec($PDacl)
	If $PSidOwner > 0 Then
		$SidOwner = _DecodeSID(StringMid($InputData,$StartOffset+40+$PSidOwner*2))
	EndIf
	If $PSidGroup > 0 Then
		$SidGroup = _DecodeSID(StringMid($InputData,$StartOffset+40+$PSidGroup*2))
	EndIf
	If $PSacl > 0 Then
		_DecodeAcl_S(StringMid($InputData,$StartOffset+40+$PSacl*2))
	EndIf
	If $PDacl > 0 Then
		_DecodeAcl_D(StringMid($InputData,$StartOffset+40+$PDacl*2))
	EndIf
	If $VerboseOn Then
		_DumpOutput("_DecodeSDSChunk(): " & @CRLF)
		_DumpOutput("$SecurityDescriptorHash: " & $SecurityDescriptorHash & @CRLF)
		_DumpOutput("$SecurityId: " & $SecurityId & @CRLF)
		_DumpOutput("$EntryOffset: " & $EntryOffset & @CRLF)
		_DumpOutput("$EntrySize: " & $EntrySize & @CRLF)
		_DumpOutput("$Revision: " & $Revision & @CRLF)
		_DumpOutput("$Sbz1: " & $Sbz1 & @CRLF)
		_DumpOutput("$SECURITY_DESCRIPTOR_CONTROL: " & $SECURITY_DESCRIPTOR_CONTROL & @CRLF)
		_DumpOutput("$ControlText: " & $ControlText & @CRLF)
		_DumpOutput("$PSidOwner: " & $PSidOwner & @CRLF)
		_DumpOutput("$PSidGroup: " & $PSidGroup & @CRLF)
		_DumpOutput("$PSacl: " & $PSacl & @CRLF)
		_DumpOutput("$PDacl: " & $PDacl & @CRLF)
	EndIf
EndFunc

Func _DecodeAcl_S($InputData)
	;https://msdn.microsoft.com/en-us/library/cc230297.aspx
	Local $StartOffset = 1, $AceDataCounter = 0
	Global $SAclRevision,$SAceCount,$SAceTypeText,$SAceFlagsText,$SAceMask,$SAceObjectFlagsText,$SAceObjectType,$SAceInheritedObjectType,$SAceSIDString
;	ConsoleWrite("_DecodeAcl_S() " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$InputData))
	; ACL header 8 bytes
	$SAclRevision = StringMid($InputData, $StartOffset, 2)

	If $SAclRevision <> "02" And $SAclRevision <> "04" Then
		ConsoleWrite("Error: Invalid SAclRevision: " & $SAclRevision & @CRLF)
	EndIf
	$Sbz1 = StringMid($InputData, $StartOffset + 2, 2)

	$AclSize = StringMid($InputData, $StartOffset + 4, 4)
	$AclSize = _SwapEndian($AclSize)

	$AclSize = Dec($AclSize)
	$SAceCount = StringMid($InputData, $StartOffset + 8, 4)
	$SAceCount = _SwapEndian($SAceCount)

	$SAceCount = Dec($SAceCount)
	$Sbz2 = StringMid($InputData, $StartOffset + 12, 4)
	#cs
	ConsoleWrite("$SAclRevision: " & $SAclRevision & @CRLF)
	ConsoleWrite("$Sbz1: " & $Sbz1 & @CRLF)
	ConsoleWrite("$AclSize: " & $AclSize & @CRLF)
	ConsoleWrite("$SAceCount: " & $SAceCount & @CRLF)
	ConsoleWrite("$Sbz2: " & $Sbz2 & @CRLF)
	#ce
	If $SAceCount < 1 Then Return
	For $j = 1 To $SAceCount

		;ACE_HEADER 4 bytes
		;https://msdn.microsoft.com/en-us/library/cc230296.aspx
		$AceType = StringMid($InputData, $StartOffset + $AceDataCounter + 16, 2)

		$AceTypeText = _DecodeAceType(Number("0x"&$AceType))
		If $AceTypeText = "" Then
			ConsoleWrite("Error: AceType invalid" & @CRLF)
;			ContinueLoop
		EndIf
		If $AceTypeText = "UNKNOWN" Then ConsoleWrite("Unknown ace flags: " & $AceType & @CRLF)

		$AceFlags = StringMid($InputData, $StartOffset + $AceDataCounter + 18, 2)

		$AceFlagsText = _DecodeAceFlags(Number("0x"&$AceFlags))

		If $j > 1 Then
			$SAceTypeText &= $de2 & $AceTypeText
			$SAceFlagsText &= $de2 & $AceFlagsText
		Else
			$SAceTypeText = $AceTypeText
			$SAceFlagsText = $AceFlagsText
		EndIf
		$AceSize = StringMid($InputData, $StartOffset + $AceDataCounter + 20, 4)
		$AceSize = _SwapEndian($AceSize)

		$AceSize = Dec($AceSize)
		;Remaining bytes of ACE depends on AceType
		$Mask=""
		$Flags=""
		$ObjectType=""
		$InheritedObjectType=""
		$SIDString=""
		If _IsSmallAceStruct("0x"&$AceType) Then
;			ConsoleWrite("Small struct " & @CRLF)
			;"dword Mask;dword SidStart"
			;https://msdn.microsoft.com/en-us/library/windows/desktop/aa374902(v=vs.85).aspx
			$Mask = StringMid($InputData, $StartOffset + $AceDataCounter + 24, 8)
			$Mask = "0x"&_SwapEndian($Mask)

			$SIDString = _DecodeSID(StringMid($InputData,$StartOffset + $AceDataCounter + 32, $AceSize*2))
			If $j > 1 Then
				$SAceMask &= $de2 & $Mask
				$SAceSIDString &= $de2 & $SIDString
			Else
				$SAceMask = $Mask
				$SAceSIDString = $SIDString
			EndIf
		Else
;			ConsoleWrite("Big struct " & @CRLF)
			;"dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"
			$Mask = StringMid($InputData, $StartOffset + $AceDataCounter + 24, 8)
			$Mask = "0x"&_SwapEndian($Mask)

			$ObjectFlags = StringMid($InputData, $StartOffset + $AceDataCounter + 32, 8)
			$ObjectFlags = _SwapEndian($ObjectFlags)
			$ObjectFlagsText = _DecodeAceObjectFlag($ObjectFlags)

			$ObjectType = StringMid($InputData, $StartOffset + $AceDataCounter + 40, 32)
			$ObjectType = _HexToGuidStr($ObjectType,1)
			$InheritedObjectType = StringMid($InputData, $StartOffset + $AceDataCounter + 72, 32)
			$InheritedObjectType = _HexToGuidStr($InheritedObjectType,1)

			$SIDString = _DecodeSID(StringMid($InputData,$StartOffset + $AceDataCounter + 104, $AceSize*2))
			If $j > 1 Then
				$SAceMask &= $de2 & $Mask
				$SAceObjectFlagsText &= $de2 & $ObjectFlagsText
				$SAceObjectType &= $de2 & $ObjectType
				$SAceInheritedObjectType &= $de2 & $InheritedObjectType
				$SAceSIDString &= $de2 & $SIDString
			Else
				$SAceMask = $Mask
				$SAceObjectFlagsText = $ObjectFlagsText
				$SAceObjectType = $ObjectType
				$SAceInheritedObjectType = $InheritedObjectType
				$SAceSIDString = $SIDString
			EndIf
		EndIf
		#cs
		ConsoleWrite(@CRLF & "Ace number: " & $j & @CRLF)
		ConsoleWrite("$AceType: " & $AceType & @CRLF)
		ConsoleWrite("$AceTypeText: " & $AceTypeText & @CRLF)
		ConsoleWrite("$AceFlags: " & $AceFlags & @CRLF)
		ConsoleWrite("$AceFlagsText: " & $AceFlagsText & @CRLF)
		ConsoleWrite("$AceSize: " & $AceSize & @CRLF)
		ConsoleWrite("$Mask: " & $Mask & @CRLF)
		ConsoleWrite("$Flags: " & $Flags & @CRLF)
		ConsoleWrite("$ObjectType: " & $ObjectType & @CRLF)
		ConsoleWrite("$InheritedObjectType: " & $InheritedObjectType & @CRLF)
		ConsoleWrite("$SIDString: " & $SIDString & @CRLF)
		#ce
		$AceDataCounter += $AceSize*2
	Next
EndFunc

Func _DecodeAcl_D($InputData)
	;https://msdn.microsoft.com/en-us/library/cc230297.aspx
	Local $StartOffset = 1, $AceDataCounter = 0
	Global $DAclRevision,$DAceCount,$DAceTypeText,$DAceFlagsText,$DAceMask,$DAceObjectFlagsText,$DAceObjectType,$DAceInheritedObjectType,$DAceSIDString
;	ConsoleWrite("_DecodeAcl_D() " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$InputData))
	; ACL header 8 bytes
	$DAclRevision = StringMid($InputData, $StartOffset, 2)

	If $DAclRevision <> "02" And $DAclRevision <> "04" Then
		ConsoleWrite("Error: Invalid DAclRevision: " & $DAclRevision & @CRLF)
	EndIf
	$Sbz1 = StringMid($InputData, $StartOffset + 2, 2)

	$AclSize = StringMid($InputData, $StartOffset + 4, 4)
	$AclSize = _SwapEndian($AclSize)

	$AclSize = Dec($AclSize)
	$DAceCount = StringMid($InputData, $StartOffset + 8, 4)
	$DAceCount = _SwapEndian($DAceCount)

	$DAceCount = Dec($DAceCount)
	$Sbz2 = StringMid($InputData, $StartOffset + 12, 4)
	#cs
	ConsoleWrite("$DAclRevision: " & $DAclRevision & @CRLF)
	ConsoleWrite("$Sbz1: " & $Sbz1 & @CRLF)
	ConsoleWrite("$AclSize: " & $AclSize & @CRLF)
	ConsoleWrite("$DAceCount: " & $DAceCount & @CRLF)
	ConsoleWrite("$Sbz2: " & $Sbz2 & @CRLF)
	#ce
	If $DAceCount < 1 Then Return
	For $j = 1 To $DAceCount

		;ACE_HEADER 4 bytes
		;https://msdn.microsoft.com/en-us/library/cc230296.aspx
		$AceType = StringMid($InputData, $StartOffset + $AceDataCounter + 16, 2)

		$AceTypeText = _DecodeAceType(Number("0x"&$AceType))
		If $AceTypeText = "" Then
			ConsoleWrite("Error: AceType invalid" & @CRLF)
;			ContinueLoop
		EndIf

		$AceFlags = StringMid($InputData, $StartOffset + $AceDataCounter + 18, 2)

		$AceFlagsText = _DecodeAceFlags(Number("0x"&$AceFlags))

		If $j > 1 Then
			$DAceTypeText &= $de2 & $AceTypeText
			$DAceFlagsText &= $de2 & $AceFlagsText
		Else
			$DAceTypeText = $AceTypeText
			$DAceFlagsText = $AceFlagsText
		EndIf
		$AceSize = StringMid($InputData, $StartOffset + $AceDataCounter + 20, 4)
		$AceSize = _SwapEndian($AceSize)

		$AceSize = Dec($AceSize)
		;Remaining bytes of ACE depends on AceType
		$Mask=""
		$Flags=""
		$ObjectType=""
		$InheritedObjectType=""
		$SIDString=""
		If _IsSmallAceStruct("0x"&$AceType) Then
;			ConsoleWrite("Small struct " & @CRLF)
			;"dword Mask;dword SidStart"
			;https://msdn.microsoft.com/en-us/library/windows/desktop/aa374902(v=vs.85).aspx
			$Mask = StringMid($InputData, $StartOffset + $AceDataCounter + 24, 8)
			$Mask = "0x"&_SwapEndian($Mask)

			$SIDString = _DecodeSID(StringMid($InputData,$StartOffset + $AceDataCounter + 32, $AceSize*2))

			If $j > 1 Then
				$DAceMask &= $de2 & $Mask
				$DAceSIDString &= $de2 & $SIDString
			Else
				$DAceMask = $Mask
				$DAceSIDString = $SIDString
			EndIf
		Else
;			ConsoleWrite("Big struct " & @CRLF)
			;"dword Mask;dword Flags;GUID ObjectType;GUID InheritedObjectType;dword SidStart"
			$Mask = StringMid($InputData, $StartOffset + $AceDataCounter + 24, 8)
			$Mask = "0x"&_SwapEndian($Mask)

			$ObjectFlags = StringMid($InputData, $StartOffset + $AceDataCounter + 32, 8)
			$ObjectFlags = _SwapEndian($ObjectFlags)
			$ObjectFlagsText = _DecodeAceObjectFlag($ObjectFlags)

			$ObjectType = StringMid($InputData, $StartOffset + $AceDataCounter + 40, 32)
			$ObjectType = _HexToGuidStr($ObjectType,1)
			$InheritedObjectType = StringMid($InputData, $StartOffset + $AceDataCounter + 72, 32)
			$InheritedObjectType = _HexToGuidStr($InheritedObjectType,1)

			$SIDString = _DecodeSID(StringMid($InputData,$StartOffset + $AceDataCounter + 104, $AceSize*2))

			If $j > 1 Then
				$DAceMask &= $de2 & $Mask
				$DAceObjectFlagsText &= $de2 & $ObjectFlagsText
				$DAceObjectType &= $de2 & $ObjectType
				$DAceInheritedObjectType &= $de2 & $InheritedObjectType
				$DAceSIDString &= $de2 & $SIDString
			Else
				$DAceMask = $Mask
				$DAceObjectFlagsText = $ObjectFlagsText
				$DAceObjectType = $ObjectType
				$DAceInheritedObjectType = $InheritedObjectType
				$DAceSIDString = $SIDString
			EndIf
		EndIf
		#cs
		ConsoleWrite(@CRLF & "Ace number: " & $j & @CRLF)
		ConsoleWrite("$AceType: " & $AceType & @CRLF)
		ConsoleWrite("$AceTypeText: " & $AceTypeText & @CRLF)
		ConsoleWrite("$AceFlags: " & $AceFlags & @CRLF)
		ConsoleWrite("$AceFlagsText: " & $AceFlagsText & @CRLF)
		ConsoleWrite("$AceSize: " & $AceSize & @CRLF)
		ConsoleWrite("$Mask: " & $Mask & @CRLF)
		ConsoleWrite("$Flags: " & $Flags & @CRLF)
		ConsoleWrite("$ObjectType: " & $ObjectType & @CRLF)
		ConsoleWrite("$InheritedObjectType: " & $InheritedObjectType & @CRLF)
		ConsoleWrite("$SIDString: " & $SIDString & @CRLF)
		#ce
		$AceDataCounter += $AceSize*2
	Next
EndFunc

Func _DecodeSID($InputData)
	;https://msdn.microsoft.com/en-us/library/cc230371.aspx
	Local $StartOffset = 1, $SIDString = "S"
;	ConsoleWrite("_DecodeSID() " & @CRLF)
	$Revision = StringMid($InputData, $StartOffset, 2)
	$Revision = Dec($Revision)
	If $Revision <> 1 Then
		ConsoleWrite("Error: Revision invalid: " & $Revision & @CRLF)
		Return SetError(1,0,0)
	EndIf
	$SIDString &= "-" & $Revision
	$SubAuthorityCount = StringMid($InputData, $StartOffset + 2, 2)
	$SubAuthorityCount = Dec($SubAuthorityCount)
	If $SubAuthorityCount > 15 Then
		ConsoleWrite("Error: SubAuthorityCount invalid: " & $SubAuthorityCount & @CRLF)
		Return SetError(1,0,0)
	EndIf
	;SID_IDENTIFIER_AUTHORITY
	$IdentifierAuthority = StringMid($InputData, $StartOffset + 4, 12)
;	ConsoleWrite("$IdentifierAuthority: " & $IdentifierAuthority & @CRLF)
	$IdentifierAuthorityString = _DecodeSidIdentifierAuthorityString($IdentifierAuthority)

	$IdentifierAuthority = _DecodeSidIdentifierAuthority($IdentifierAuthority)

	$SIDString &= "-" & $IdentifierAuthority
	;SubAuthority (variable)
	If $SubAuthorityCount < 1 Or $SubAuthorityCount > 15 Then
		ConsoleWrite("Error: $SubAuthorityCount seems invalid: " & $SubAuthorityCount & @CRLF)
		Return SetError(1,0,0)
	EndIf
	For $j = 1 To $SubAuthorityCount
		$SubAuthority = StringMid($InputData, $StartOffset + (($j-1)*8) + 16, 8)
;		ConsoleWrite("$SubAuthority: " & $SubAuthority & @CRLF)
		$SIDString &= "-" & Dec(_SwapEndian($SubAuthority),2)
	Next
	#cs
	ConsoleWrite("$Revision: " & $Revision & @CRLF)
	ConsoleWrite("$SubAuthorityCount: " & $SubAuthorityCount & @CRLF)
	ConsoleWrite("$IdentifierAuthorityString: " & $IdentifierAuthorityString & @CRLF)
	ConsoleWrite("$IdentifierAuthority: " & $IdentifierAuthority & @CRLF)
	ConsoleWrite("$SIDString: " & $SIDString & @CRLF)
	#ce
	Return $SIDString
EndFunc

Func _DecodeSidIdentifierAuthority($InputData)
;	ConsoleWrite("_DecodeSidIdentifierAuthority() " & @CRLF)
	Select
		Case $InputData = "000000000000"
			Return Dec($InputData)
;			Return "0"
		Case $InputData = "000000000001"
			Return Dec($InputData)
;			Return "1"
		Case $InputData = "000000000002"
			Return Dec($InputData)
;			Return "2"
		Case $InputData = "000000000003"
			Return Dec($InputData)
;			Return "3"
		Case $InputData = "000000000004"
			Return Dec($InputData)
;			Return "4"
		Case $InputData = "000000000005"
			Return Dec($InputData)
;			Return "5"
		Case $InputData = "00000000000F"
			Return Dec($InputData)
;			Return "F"
		Case $InputData = "000000000010"
			Return Dec($InputData)
;			Return "10"
		Case $InputData = "000000000011"
			Return Dec($InputData)
;			Return "11"
		Case $InputData = "000000000012"
			Return Dec($InputData)
;			Return "12"
		Case $InputData = "000000000013"
			Return Dec($InputData)
;			Return "13"
		Case Else
			Return "UNKNOWN"
	EndSelect
EndFunc

Func _DecodeSidIdentifierAuthorityString($InputData)
;	ConsoleWrite("_DecodeSidIdentifierAuthorityString() " & @CRLF)
	Select
		Case $InputData = "000000000000"
			Return "NULL_SID_AUTHORITY"
		Case $InputData = "000000000001"
			Return "WORLD_SID_AUTHORITY"
		Case $InputData = "000000000002"
			Return "LOCAL_SID_AUTHORITY"
		Case $InputData = "000000000003"
			Return "CREATOR_SID_AUTHORITY"
		Case $InputData = "000000000004"
			Return "NON_UNIQUE_AUTHORITY"
		Case $InputData = "000000000005"
			Return "SECURITY_NT_AUTHORITY"
		Case $InputData = "00000000000F"
			Return "SECURITY_APP_PACKAGE_AUTHORITY"
		Case $InputData = "000000000010"
			Return "SECURITY_MANDATORY_LABEL_AUTHORITY"
		Case $InputData = "000000000011"
			Return "SECURITY_SCOPED_POLICY_ID_AUTHORITY"
		Case $InputData = "000000000012"
			Return "SECURITY_AUTHENTICATION_AUTHORITY"
		Case $InputData = "000000000013"
			Return "SECURITY_PROCESS_TRUST_AUTHORITY"
		Case Else
			Return "UNKNOWN"
	EndSelect
EndFunc

Func _DecodeIndxEntriesSDH($InputData,$IsRedo)
	Local $StartOffset = 1, $Counter = 0
	Local $InputDataSize = BinaryLen("0x"&$InputData)
	ReDim $SDHArray[100+1+$InputDataSize/48][6]
	$SDHArray[0][0] = "OffsetInSDS"
	$SDHArray[0][1] = "SizeInSDS"
	$SDHArray[0][2] = "SecurityDescriptorHashKey"
	$SDHArray[0][3] = "SecurityIdKey"
	$SDHArray[0][4] = "SecurityDescriptorHashData"
	$SDHArray[0][5] = "SecurityIdData"

;	_ArrayDisplay($SDHArray,"$SDHArray")
;	ConsoleWrite("_DecodeIndxEntriesSDH() " & @CRLF)
;	ConsoleWrite("Input size: " & $InputDataSize & @CRLF)
;	ConsoleWrite("$InputData: " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$InputData))

	#cs
	$MaxDescriptors=UBound($SDHArray)-101
	$begin = TimerInit()
	AdlibRegister("_SDHProgress", 500)
	#ce
	While 1
		If $StartOffset >= $InputDataSize*2 Then ExitLoop
		$Counter+=1
		$CurrentDescriptor=$Counter

		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = _SwapEndian($DataOffset)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = _SwapEndian($DataSize)

		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = _SwapEndian($IndexEntrySize)

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = _SwapEndian($IndexKeySize)

		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes
		;Start of SDH index entry
	;	$StartOffset = $StartOffset+24
		$SecurityDescriptorHashKey = "0x" & StringMid($InputData, $StartOffset + 32, 8)
;		$SecurityDescriptorHashKey = _SwapEndian($SecurityDescriptorHashKey)

		$SecurityIdKey = StringMid($InputData, $StartOffset + 40, 8)
		$SecurityIdKey = _SwapEndian($SecurityIdKey)
		$SecurityIdKey = Dec($SecurityIdKey,2)

		$SecurityDescriptorHashData = "0x" & StringMid($InputData, $StartOffset + 48, 8)
;		$SecurityDescriptorHashData = _SwapEndian($SecurityDescriptorHashData)

		$SecurityIdData = StringMid($InputData, $StartOffset + 56, 8)
		$SecurityIdData = _SwapEndian($SecurityIdData)
		$SecurityIdData = Dec($SecurityIdData,2)

		$OffsetInSDS = StringMid($InputData, $StartOffset + 64, 16)
		$OffsetInSDS = "0x" & _SwapEndian($OffsetInSDS)

		$SizeInSDS = StringMid($InputData, $StartOffset + 80, 8)
		$SizeInSDS = "0x" & _SwapEndian($SizeInSDS)

		$EndPadding = StringMid($InputData, $StartOffset + 88, 8)
		If $EndPadding <> "49004900" Then
			ConsoleWrite("Wrong end padding (49004900): " & $EndPadding & @CRLF)
			Return 0
		EndIf

		FileWriteLine($LogFileSecureSDHCsv, $RecordOffset&$de&$this_lsn&$de&$Flags&$de&$SecurityDescriptorHashKey&$de&$SecurityIdKey&$de&$SecurityDescriptorHashData&$de&$SecurityIdData&$de&$OffsetInSDS&$de&$SizeInSDS&$de&$IsRedo&@crlf)
		$SDHArray[$Counter][0] = $OffsetInSDS
		$SDHArray[$Counter][1] = $SizeInSDS
		$SDHArray[$Counter][2] = $SecurityDescriptorHashKey
		$SDHArray[$Counter][3] = $SecurityIdKey
		$SDHArray[$Counter][4] = $SecurityDescriptorHashData
		$SDHArray[$Counter][5] = $SecurityIdData
		#cs
		ConsoleWrite(@CRLF)
		ConsoleWrite("$DataOffset: " & $DataOffset & @CRLF)
		ConsoleWrite("$DataSize: " & $DataSize & @CRLF)
		ConsoleWrite("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
		ConsoleWrite("$IndexKeySize: " & $IndexKeySize & @CRLF)
		ConsoleWrite("$Flags: " & $Flags & @CRLF)
		ConsoleWrite("$SecurityDescriptorHashKey: " & $SecurityDescriptorHashKey & @CRLF)
		ConsoleWrite("$SecurityIdKey: " & $SecurityIdKey & @CRLF)
		ConsoleWrite("$SecurityDescriptorHashData: " & $SecurityDescriptorHashData & @CRLF)
		ConsoleWrite("$SecurityIdData: " & $SecurityIdData & @CRLF)
		ConsoleWrite("$OffsetInSDS: " & $OffsetInSDS & @CRLF)
		ConsoleWrite("$SizeInSDS: " & $SizeInSDS & @CRLF)
		#ce
		$StartOffset += 96
	WEnd
	#cs
	$MaxDescriptors = $CurrentDescriptor
	AdlibUnRegister("_SDHProgress")
	GUICtrlSetData($ProgressStatus, "[$SDH] Processing security descriptor index entry " & $CurrentDescriptor & " of " & $MaxDescriptors)
	GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($ProgressSDH, 100 * $CurrentDescriptor / $MaxDescriptors)
	_DisplayInfo("$SDH processing finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & @CRLF)
	#ce
	ReDim $SDHArray[$Counter+1][6]
EndFunc

Func _DecodeIndxEntriesSII($InputData,$IsRedo)
	Local $StartOffset = 1, $Counter = 0
	Local $InputDataSize = BinaryLen("0x"&$InputData)
	ReDim $SIIArray[100+1+$InputDataSize/40][5]
	$SIIArray[0][0] = "OffsetInSDS"
	$SIIArray[0][1] = "SizeInSDS"
	$SIIArray[0][2] = "SecurityIdKey"
	$SIIArray[0][3] = "SecurityDescriptorHashData"
	$SIIArray[0][4] = "SecurityIdData"
;	ConsoleWrite("_DecodeIndxEntriesSII() " & @CRLF)
;	ConsoleWrite("Input size: " & BinaryLen("0x"&$InputData) & @CRLF)
;	ConsoleWrite("$InputData: " & @CRLF)
;	ConsoleWrite(_HexEncode("0x"&$InputData))

	#cs
	$MaxDescriptors=UBound($SIIArray)-101
	$begin = TimerInit()
	AdlibRegister("_SIIProgress", 500)
	#ce
	While 1
		If $StartOffset >= BinaryLen("0x"&$InputData)*2 Then ExitLoop
		$Counter+=1
		$CurrentDescriptor=$Counter

		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = _SwapEndian($DataOffset)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = _SwapEndian($DataSize)

		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = _SwapEndian($IndexEntrySize)

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = _SwapEndian($IndexKeySize)

		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes
		$SecurityIdKey = StringMid($InputData, $StartOffset + 32, 8)
		$SecurityIdKey = _SwapEndian($SecurityIdKey)
		$SecurityIdKey = Dec($SecurityIdKey,2)

		$SecurityDescriptorHashData = "0x" & StringMid($InputData, $StartOffset + 40, 8)
;		$SecurityDescriptorHashData = _SwapEndian($SecurityDescriptorHashData)

		$SecurityIdData = StringMid($InputData, $StartOffset + 48, 8)
		$SecurityIdData = _SwapEndian($SecurityIdData)
		$SecurityIdData = Dec($SecurityIdData,2)

		$OffsetInSDS = StringMid($InputData, $StartOffset + 56, 16)
		$OffsetInSDS = "0x" & _SwapEndian($OffsetInSDS)

		$SizeInSDS = StringMid($InputData, $StartOffset + 72, 8)
		$SizeInSDS = "0x" & _SwapEndian($SizeInSDS)

		FileWriteLine($LogFileSecureSIICsv, $RecordOffset&$de&$this_lsn&$de&$Flags&$de&$SecurityIdKey&$de&$SecurityDescriptorHashData&$de&$SecurityIdData&$de&$OffsetInSDS&$de&$SizeInSDS&$de&$IsRedo&@crlf)
		$SIIArray[$Counter][0] = $OffsetInSDS
		$SIIArray[$Counter][1] = $SizeInSDS
		$SIIArray[$Counter][2] = $SecurityIdKey
		$SIIArray[$Counter][3] = $SecurityDescriptorHashData
		$SIIArray[$Counter][4] = $SecurityIdData
		#cs
		ConsoleWrite(@CRLF)
		ConsoleWrite("$DataOffset: " & $DataOffset & @CRLF)
		ConsoleWrite("$DataSize: " & $DataSize & @CRLF)
		ConsoleWrite("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
		ConsoleWrite("$IndexKeySize: " & $IndexKeySize & @CRLF)
		ConsoleWrite("$Flags: " & $Flags & @CRLF)
		ConsoleWrite("$SecurityIdKey: " & $SecurityIdKey & @CRLF)
		ConsoleWrite("$SecurityDescriptorHashData: " & $SecurityDescriptorHashData & @CRLF)
		ConsoleWrite("$SecurityIdData: " & $SecurityIdData & @CRLF)
		ConsoleWrite("$OffsetInSDS: " & $OffsetInSDS & @CRLF)
		ConsoleWrite("$SizeInSDS: " & $SizeInSDS & @CRLF)
		#ce
		$StartOffset += 80
	WEnd
	#cs
	$MaxDescriptors = $CurrentDescriptor
	AdlibUnRegister("_SIIProgress")
	GUICtrlSetData($ProgressStatus, "[$SII] Processing security descriptor index entry " & $CurrentDescriptor & " of " & $MaxDescriptors)
	GUICtrlSetData($ElapsedTime, "Elapsed time = " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)))
	GUICtrlSetData($ProgressSII, 100 * $CurrentDescriptor / $MaxDescriptors)
	_DisplayInfo("$SII processing finished in " & _WinAPI_StrFromTimeInterval(TimerDiff($begin)) & @CRLF)
	#ce
	ReDim $SIIArray[$Counter+1][5]
EndFunc

Func _GetIndx($Entry)
;	ConsoleWrite("Starting function _Get_IndexAllocation()" & @crlf)
	Local $NextPosition = 3,$IndxHdrMagic,$IndxEntries,$TotalIndxEntries
;	ConsoleWrite("StringLen of chunk = " & StringLen($Entry) & @crlf)
;	ConsoleWrite("Expected records = " & StringLen($Entry)/8192 & @crlf)
;	$NextPosition = 1
	Do
		$IndxHdrMagic = StringMid($Entry,$NextPosition,8)
;		ConsoleWrite("$IndxHdrMagic = " & $IndxHdrMagic & @crlf)
		$IndxHdrMagic = _HexToString($IndxHdrMagic)
;		ConsoleWrite("$IndxHdrMagic = " & $IndxHdrMagic & @crlf)
		If $IndxHdrMagic <> "INDX" Then
;			ConsoleWrite("$IndxHdrMagic: " & $IndxHdrMagic & @crlf)
			ConsoleWrite("Error: Record is not of type INDX, and this was not expected.." & @crlf)
			$NextPosition += 8192
			ContinueLoop
		EndIf
		$IndxEntries = _StripIndxRecord(StringMid($Entry,$NextPosition,8192))
		$TotalIndxEntries &= $IndxEntries
		$NextPosition += 8192
	Until $NextPosition >= StringLen($Entry)+32
;	ConsoleWrite("INDX record:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($Entry,1)) & @crlf)
;	ConsoleWrite("Total chunk of stripped INDX entries:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($TotalIndxEntries,1)) & @crlf)
;	_DecodeIndxEntriesSDH($TotalIndxEntries)
	Return $TotalIndxEntries
EndFunc

Func _GetIndxWoFixup($Entry)
;	ConsoleWrite("Starting function _Get_IndexAllocation()" & @crlf)
	Local $NextPosition = 1,$IndxHdrMagic,$IndxEntries,$TotalIndxEntries
;	ConsoleWrite("StringLen of chunk = " & StringLen($Entry) & @crlf)
;	ConsoleWrite("Expected records = " & StringLen($Entry)/8192 & @crlf)
;	$NextPosition = 1
	Do
		$IndxHdrMagic = StringMid($Entry,$NextPosition,8)
;		ConsoleWrite("$IndxHdrMagic = " & $IndxHdrMagic & @crlf)
		$IndxHdrMagic = _HexToString($IndxHdrMagic)
;		ConsoleWrite("$IndxHdrMagic = " & $IndxHdrMagic & @crlf)
		If $IndxHdrMagic <> "INDX" Then
;			ConsoleWrite("$IndxHdrMagic: " & $IndxHdrMagic & @crlf)
			ConsoleWrite("Error: Record is not of type INDX, and this was not expected.." & @crlf)
			$NextPosition += 8192
			ContinueLoop
		EndIf
		$IndxEntries = _StripIndxRecordWoFixup(StringMid($Entry,$NextPosition,8192))
		$TotalIndxEntries &= $IndxEntries
		$NextPosition += 8192
	Until $NextPosition >= StringLen($Entry)+32
;	ConsoleWrite("INDX record:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($Entry,1)) & @crlf)
;	ConsoleWrite("Total chunk of stripped INDX entries:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($TotalIndxEntries,1)) & @crlf)
;	_DecodeIndxEntriesSDH($TotalIndxEntries)
	Return $TotalIndxEntries
EndFunc

Func _StripIndxRecordWoFixup($Entry)
;	ConsoleWrite("Starting function _StripIndxRecord()" & @crlf)
	Local $LocalAttributeOffset = 1,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxHdrUpdSeqArrPart4,$IndxHdrUpdSeqArrPart5,$IndxHdrUpdSeqArrPart6,$IndxHdrUpdSeqArrPart7,$IndxHdrUpdSeqArrPart8
	Local $IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4,$IndxRecordEnd5,$IndxRecordEnd6,$IndxRecordEnd7,$IndxRecordEnd8,$IndxRecordSize,$IndxHeaderSize,$IsNotLeafNode
;	ConsoleWrite("Unfixed INDX record:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"&$Entry) & @crlf)
;	ConsoleWrite(_HexEncode("0x" & StringMid($Entry,1,4096)) & @crlf)
	#cs
	$IndxHdrUpdateSeqArrOffset = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+8,4)))
;	ConsoleWrite("$IndxHdrUpdateSeqArrOffset = " & $IndxHdrUpdateSeqArrOffset & @crlf)
	$IndxHdrUpdateSeqArrSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+12,4)))
;	ConsoleWrite("$IndxHdrUpdateSeqArrSize = " & $IndxHdrUpdateSeqArrSize & @crlf)
	$IndxHdrUpdSeqArr = StringMid($Entry,1+($IndxHdrUpdateSeqArrOffset*2),$IndxHdrUpdateSeqArrSize*2*2)
;	ConsoleWrite("$IndxHdrUpdSeqArr = " & $IndxHdrUpdSeqArr & @crlf)
	$IndxHdrUpdSeqArrPart0 = StringMid($IndxHdrUpdSeqArr,1,4)
	$IndxHdrUpdSeqArrPart1 = StringMid($IndxHdrUpdSeqArr,5,4)
	$IndxHdrUpdSeqArrPart2 = StringMid($IndxHdrUpdSeqArr,9,4)
	$IndxHdrUpdSeqArrPart3 = StringMid($IndxHdrUpdSeqArr,13,4)
	$IndxHdrUpdSeqArrPart4 = StringMid($IndxHdrUpdSeqArr,17,4)
	$IndxHdrUpdSeqArrPart5 = StringMid($IndxHdrUpdSeqArr,21,4)
	$IndxHdrUpdSeqArrPart6 = StringMid($IndxHdrUpdSeqArr,25,4)
	$IndxHdrUpdSeqArrPart7 = StringMid($IndxHdrUpdSeqArr,29,4)
	$IndxHdrUpdSeqArrPart8 = StringMid($IndxHdrUpdSeqArr,33,4)
	$IndxRecordEnd1 = StringMid($Entry,1021,4)
	$IndxRecordEnd2 = StringMid($Entry,2045,4)
	$IndxRecordEnd3 = StringMid($Entry,3069,4)
	$IndxRecordEnd4 = StringMid($Entry,4093,4)
	$IndxRecordEnd5 = StringMid($Entry,5117,4)
	$IndxRecordEnd6 = StringMid($Entry,6141,4)
	$IndxRecordEnd7 = StringMid($Entry,7165,4)
	$IndxRecordEnd8 = StringMid($Entry,8189,4)
	If $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd1 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd2 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd3 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd4 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd5 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd6 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd7 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd8 Then
		ConsoleWrite("Error the INDX record is corrupt" & @CRLF)
		Return ; Not really correct because I think in theory chunks of 1024 bytes can be invalid and not just everything or nothing for the given INDX record.
	Else
		$Entry = StringMid($Entry,1,1020) & $IndxHdrUpdSeqArrPart1 & StringMid($Entry,1025,1020) & $IndxHdrUpdSeqArrPart2 & StringMid($Entry,2049,1020) & $IndxHdrUpdSeqArrPart3 & StringMid($Entry,3073,1020) & $IndxHdrUpdSeqArrPart4 & StringMid($Entry,4097,1020) & $IndxHdrUpdSeqArrPart5 & StringMid($Entry,5121,1020) & $IndxHdrUpdSeqArrPart6 & StringMid($Entry,6145,1020) & $IndxHdrUpdSeqArrPart7 & StringMid($Entry,7169,1020)
	EndIf
	#ce
	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+56,8)),2)
;	ConsoleWrite("$IndxRecordSize = " & $IndxRecordSize & @crlf)
	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+48,8)),2)
;	ConsoleWrite("$IndxHeaderSize = " & $IndxHeaderSize & @crlf)
	$IsNotLeafNode = StringMid($Entry,$LocalAttributeOffset+72,2) ;1 if not leaf node
	$Entry = StringMid($Entry,$LocalAttributeOffset+48+($IndxHeaderSize*2),($IndxRecordSize-$IndxHeaderSize-16)*2)
	If $IsNotLeafNode = "01" Then  ; This flag leads to the entry being 8 bytes of 00's longer than the others. Can be stripped I think.
		$Entry = StringTrimRight($Entry,16)
;		ConsoleWrite("Is not leaf node..." & @crlf)
	EndIf
	Return $Entry
EndFunc

Func _StripIndxRecord($Entry)
;	ConsoleWrite("Starting function _StripIndxRecord()" & @crlf)
	Local $LocalAttributeOffset = 1,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxHdrUpdSeqArrPart4,$IndxHdrUpdSeqArrPart5,$IndxHdrUpdSeqArrPart6,$IndxHdrUpdSeqArrPart7,$IndxHdrUpdSeqArrPart8
	Local $IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4,$IndxRecordEnd5,$IndxRecordEnd6,$IndxRecordEnd7,$IndxRecordEnd8,$IndxRecordSize,$IndxHeaderSize,$IsNotLeafNode
;	ConsoleWrite("Unfixed INDX record:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"&$Entry) & @crlf)
;	ConsoleWrite(_HexEncode("0x" & StringMid($Entry,1,4096)) & @crlf)
	$IndxHdrUpdateSeqArrOffset = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+8,4)))
;	ConsoleWrite("$IndxHdrUpdateSeqArrOffset = " & $IndxHdrUpdateSeqArrOffset & @crlf)
	$IndxHdrUpdateSeqArrSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+12,4)))
;	ConsoleWrite("$IndxHdrUpdateSeqArrSize = " & $IndxHdrUpdateSeqArrSize & @crlf)
	$IndxHdrUpdSeqArr = StringMid($Entry,1+($IndxHdrUpdateSeqArrOffset*2),$IndxHdrUpdateSeqArrSize*2*2)
;	ConsoleWrite("$IndxHdrUpdSeqArr = " & $IndxHdrUpdSeqArr & @crlf)
	$IndxHdrUpdSeqArrPart0 = StringMid($IndxHdrUpdSeqArr,1,4)
	$IndxHdrUpdSeqArrPart1 = StringMid($IndxHdrUpdSeqArr,5,4)
	$IndxHdrUpdSeqArrPart2 = StringMid($IndxHdrUpdSeqArr,9,4)
	$IndxHdrUpdSeqArrPart3 = StringMid($IndxHdrUpdSeqArr,13,4)
	$IndxHdrUpdSeqArrPart4 = StringMid($IndxHdrUpdSeqArr,17,4)
	$IndxHdrUpdSeqArrPart5 = StringMid($IndxHdrUpdSeqArr,21,4)
	$IndxHdrUpdSeqArrPart6 = StringMid($IndxHdrUpdSeqArr,25,4)
	$IndxHdrUpdSeqArrPart7 = StringMid($IndxHdrUpdSeqArr,29,4)
	$IndxHdrUpdSeqArrPart8 = StringMid($IndxHdrUpdSeqArr,33,4)
	$IndxRecordEnd1 = StringMid($Entry,1021,4)
	$IndxRecordEnd2 = StringMid($Entry,2045,4)
	$IndxRecordEnd3 = StringMid($Entry,3069,4)
	$IndxRecordEnd4 = StringMid($Entry,4093,4)
	$IndxRecordEnd5 = StringMid($Entry,5117,4)
	$IndxRecordEnd6 = StringMid($Entry,6141,4)
	$IndxRecordEnd7 = StringMid($Entry,7165,4)
	$IndxRecordEnd8 = StringMid($Entry,8189,4)
	If $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd1 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd2 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd3 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd4 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd5 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd6 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd7 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd8 Then
		ConsoleWrite("Error the INDX record is corrupt" & @CRLF)
		Return ; Not really correct because I think in theory chunks of 1024 bytes can be invalid and not just everything or nothing for the given INDX record.
	Else
		$Entry = StringMid($Entry,1,1020) & $IndxHdrUpdSeqArrPart1 & StringMid($Entry,1025,1020) & $IndxHdrUpdSeqArrPart2 & StringMid($Entry,2049,1020) & $IndxHdrUpdSeqArrPart3 & StringMid($Entry,3073,1020) & $IndxHdrUpdSeqArrPart4 & StringMid($Entry,4097,1020) & $IndxHdrUpdSeqArrPart5 & StringMid($Entry,5121,1020) & $IndxHdrUpdSeqArrPart6 & StringMid($Entry,6145,1020) & $IndxHdrUpdSeqArrPart7 & StringMid($Entry,7169,1020)
	EndIf
	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+56,8)),2)
;	ConsoleWrite("$IndxRecordSize = " & $IndxRecordSize & @crlf)
	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+48,8)),2)
;	ConsoleWrite("$IndxHeaderSize = " & $IndxHeaderSize & @crlf)
	$IsNotLeafNode = StringMid($Entry,$LocalAttributeOffset+72,2) ;1 if not leaf node
	$Entry = StringMid($Entry,$LocalAttributeOffset+48+($IndxHeaderSize*2),($IndxRecordSize-$IndxHeaderSize-16)*2)
	If $IsNotLeafNode = "01" Then  ; This flag leads to the entry being 8 bytes of 00's longer than the others. Can be stripped I think.
		$Entry = StringTrimRight($Entry,16)
;		ConsoleWrite("Is not leaf node..." & @crlf)
	EndIf
	Return $Entry
EndFunc

Func _HexToGuidStr($input,$mode)
	;{4b-2b-2b-2b-6b}
	Local $OutStr
	If Not StringLen($input) = 32 Then Return $input
	If $mode Then $OutStr = "{"
	$OutStr &= _SwapEndian(StringMid($input,1,8)) & "-"
	$OutStr &= _SwapEndian(StringMid($input,9,4)) & "-"
	$OutStr &= _SwapEndian(StringMid($input,13,4)) & "-"
	$OutStr &= StringMid($input,17,4) & "-"
	$OutStr &= StringMid($input,21,12)
	If $mode Then $OutStr &= "}"
	Return $OutStr
EndFunc

Func _MainSecure($RawContentSDS,$IsRedo)
	$SizeSDS = StringLen($RawContentSDS)/2
	$StartOffset = 1
	$BytesProcessed = 0
	$CurrentDescriptor = 0
	If $VerboseOn Then
		_DumpOutput("_MainSecure(): " & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$SizeSDS: " & $SizeSDS & @CRLF)
		_DumpOutput(_HexEncode("0x"&$RawContentSDS) & @CRLF)
	EndIf
	While 1
		$CurrentDescriptor += 1
		If $BytesProcessed >= $SizeSDS Then
;			_DumpOutput("End of $SDS reached 1" & @CRLF)
;			_DumpOutput("$BytesProcessed: " & $BytesProcessed & @CRLF)
			ExitLoop
		EndIf
		$TargetSDSOffset = StringMid($RawContentSDS,$StartOffset + 16, 16)
;		$TargetSDSOffset = Dec(_SwapEndian($TargetSDSOffset),2)
		$TargetSDSOffset = $BytesProcessed

		$TargetSDSSize = StringMid($RawContentSDS,$StartOffset + 32, 8)
		$TargetSDSSize = Dec(_SwapEndian($TargetSDSSize),2)

		If $TargetSDSOffset >= $SizeSDS Then
;			_DumpOutput("End of $SDS reached 2" & @CRLF)
;			_DumpOutput("$TargetSDSOffset: " & $TargetSDSOffset & @CRLF)
			ExitLoop
		EndIf

		$TargetSDSOffsetHex = "0x"&Hex(Int(($StartOffset-3)/2),8)

		If $TargetSDSOffset = 0 And $TargetSDSSize = 0 Then
			If Mod(($StartOffset-$StartOffset)/2,262144) Then ; Align 0x40000
				Do
					$StartOffset+=2
				Until Mod(($StartOffset-$StartOffset)/2,262144)=0
				ContinueLoop ;Move to next block
			Else
				ExitLoop ;We are at end
			EndIf
		EndIf

		If Mod($TargetSDSSize,16) Then ; Align SDS size to 16 bytes
			Do
				$TargetSDSSize+=1
			Until Mod($TargetSDSSize,16)=0
		EndIf
		$TargetSDSHash = StringMid($RawContentSDS,$StartOffset, 8)
		$TargetSDSChunk = StringMid($RawContentSDS,$StartOffset+($TargetSDSOffset*2), $TargetSDSSize*2)
		If $VerboseOn Then
			_DumpOutput("$StartOffset: " & $StartOffset & @CRLF)
			_DumpOutput("$TargetSDSSize: " & $TargetSDSSize & @CRLF)
			_DumpOutput("$TargetSDSOffset: " & $TargetSDSOffset & @CRLF)
			_DumpOutput("$SizeSDS: " & $SizeSDS & @CRLF)
		EndIf
		_DecodeSDSChunk($TargetSDSChunk, $TargetSDSHash)
		;Write information to csv
		_WriteCsvSecureSDS($IsRedo)
		;Make sure all global variables for csv are cleared
		_ClearVarSecureSDS()
		$BytesProcessed+=$TargetSDSSize
		$StartOffset+=$TargetSDSSize*2
	WEnd
EndFunc

Func _ClearVarSecureSDS()
	$TargetSDSOffsetHex = ""
	$SecurityDescriptorHash = ""
	$SecurityId = ""
	$ControlText = ""
	$SidOwner = ""
	$SidGroup = ""
	$SAclRevision = ""
	$SAceCount = ""
	$SAceTypeText = ""
	$SAceFlagsText = ""
	$SAceMask = ""
	$SAceObjectType = ""
	$SAceInheritedObjectType = ""
	$SAceSIDString = ""
	$SAceObjectFlagsText = ""
	$DAclRevision = ""
	$DAceCount = ""
	$DAceTypeText = ""
	$DAceFlagsText = ""
	$DAceMask = ""
	$DAceObjectType = ""
	$DAceInheritedObjectType = ""
	$DAceSIDString = ""
	$DAceObjectFlagsText = ""
EndFunc

Func _WriteCsvSecureSDS($IsRedo)
	FileWriteLine($LogFileSecureSDSCsv, $RecordOffset&$de&$this_lsn&$de&$SecurityDescriptorHash&$de&$SecurityId&$de&$ControlText&$de&$SidOwner&$de&$SidGroup&$de&$SAclRevision&$de&$SAceCount&$de&$SAceTypeText&$de&$SAceFlagsText&$de&$SAceMask&$de&$SAceObjectFlagsText&$de&$SAceObjectType&$de&$SAceInheritedObjectType&$de&$SAceSIDString&$de&$DAclRevision&$de&$DAceCount&$de&$DAceTypeText&$de&$DAceFlagsText&$de&$DAceMask&$de&$DAceObjectFlagsText&$de&$DAceObjectType&$de&$DAceInheritedObjectType&$de&$DAceSIDString&$de&$IsRedo&@crlf)
EndFunc

Func _WriteCSVHeaderSecureSDS()
	$SecureSDS_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"SecurityDescriptorHash"&$de&"SecurityId"&$de&"Control"&$de&"SidOwner"&$de&"SidGroup"&$de&"SAclRevision"&$de&"SAceCount"&$de&"SAceType"&$de&"SAceFlags"&$de&"SAceMask"&$de&"SAceObjectFlags"&$de&"SAceObjectType"&$de&"SAceInheritedObjectType"&$de&"SAceSIDofTrustee"&$de&"DAclRevision"&$de&"DAceCount"&$de&"DAceType"&$de&"DAceFlags"&$de&"DAceMask"&$de&"DAceObjectFlags"&$de&"DAceObjectType"&$de&"DAceInheritedObjectType"&$de&"DAceSIDofTrustee"&$de&"IsRedo"
	FileWriteLine($LogFileSecureSDSCsv, $SecureSDS_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderSecureSDH()
	$SecureSDH_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"sdh_flags"&$de&"sdh_SecurityDescriptorHashKey"&$de&"sdh_SecurityIdKey"&$de&"sdh_SecurityDescriptorHashData"&$de&"sdh_SecurityIdData"&$de&"sdh_OffsetInSDS"&$de&"sdh_SizeInSDS"&$de&"IsRedo"
	FileWriteLine($LogFileSecureSDHCsv, $SecureSDH_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderSecureSII()
	$SecureSII_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"sdh_flags"&$de&"sdh_SecurityIdKey"&$de&"sdh_SecurityDescriptorHashData"&$de&"sdh_SecurityIdData"&$de&"sdh_OffsetInSDS"&$de&"sdh_SizeInSDS"&$de&"IsRedo"
	FileWriteLine($LogFileSecureSIICsv, $SecureSII_Csv_Header & @CRLF)
EndFunc

;-----------/Security------------------

Func _Decode_ObjId_O($InputData,$IsRedo)
	Local $Counter=1
	;88 bytes
	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	If $VerboseOn Then
		_DumpOutput("_Decode_ObjId_O():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	EndIf

	Do
		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = Dec(_SwapEndian($DataOffset),2)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = Dec(_SwapEndian($DataSize),2)

		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = Dec(_SwapEndian($IndexEntrySize),2)
		If $IndexEntrySize = 0 Then ExitLoop

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = Dec(_SwapEndian($IndexKeySize),2)

		;1=Entry has subnodes, 2=Last entry
		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes
		$GUIDObjectId = StringMid($InputData, $StartOffset + 32, 32)
		$GUIDObjectId = _HexToGuidStr($GUIDObjectId,0)

		$MftRef = StringMid($InputData, $StartOffset + 64, 12)
		$MftRef = Dec(_SwapEndian($MftRef),2)

		$MftSeqNo = StringMid($InputData, $StartOffset + 76, 4)
		$MftSeqNo = Dec(_SwapEndian($MftSeqNo),2)

		$GUIDBirthVolumeId = StringMid($InputData, $StartOffset + 80, 32)
		$GUIDBirthVolumeId = _HexToGuidStr($GUIDBirthVolumeId,0)

		$GUIDBirthObjectId = StringMid($InputData, $StartOffset + 112, 32)
		$GUIDBirthObjectId = _HexToGuidStr($GUIDBirthObjectId,0)

		$GUIDDomainId = StringMid($InputData, $StartOffset + 144, 32)
		$GUIDDomainId = _HexToGuidStr($GUIDDomainId,0)

		If $VerboseOn Then
			_DumpOutput(@CRLF)
			_DumpOutput(_HexEncode("0x"&StringMid($InputData, $StartOffset, $IndexEntrySize*2)) & @CRLF)
			_DumpOutput("$Counter: " & $Counter & @CRLF)
			_DumpOutput("$DataOffset: " & $DataOffset & @CRLF)
			_DumpOutput("$DataSize: " & $DataSize & @CRLF)
			_DumpOutput("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
			_DumpOutput("$IndexKeySize: " & $IndexKeySize & @CRLF)
			_DumpOutput("$Flags: " & $Flags & @CRLF)
			_DumpOutput("$GUIDObjectId: " & $GUIDObjectId & @CRLF)
			_DumpOutput("$MftRef: " & $MftRef & @CRLF)
			_DumpOutput("$MftSeqNo: " & $MftSeqNo & @CRLF)
			_DumpOutput("$GUIDBirthVolumeId: " & $GUIDBirthVolumeId & @CRLF)
			_DumpOutput("$GUIDBirthObjectId: " & $GUIDBirthObjectId & @CRLF)
			_DumpOutput("$GUIDDomainId: " & $GUIDDomainId & @CRLF)
		EndIf

		$TextInformation &= ";MftRef="&$MftRef&";MftSeqNo="&$MftSeqNo
		FileWriteLine($LogFileObjIdOCsv, $RecordOffset&$de&$this_lsn&$de&$IndexEntrySize&$de&$IndexKeySize&$de&$Flags&$de&$GUIDObjectId&$de&$MftRef&$de&$MftSeqNo&$de&$GUIDBirthVolumeId&$de&$GUIDBirthObjectId&$de&$GUIDDomainId&$de&$IsRedo&@crlf)
		$StartOffset += $IndexEntrySize*2
		$Counter+=1
	Until $StartOffset >= $InputDataSize
EndFunc

Func _Decode_Quota_O($InputData,$IsRedo)
	Local $Counter=1
	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	If $VerboseOn Then
		_DumpOutput("_Decode_Quota_O():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	EndIf

	Do
		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = Dec(_SwapEndian($DataOffset),2)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = Dec(_SwapEndian($DataSize),2)

		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = Dec(_SwapEndian($IndexEntrySize),2)
		If $IndexEntrySize = 0 Then ExitLoop

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = Dec(_SwapEndian($IndexKeySize),2)

		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes
		$SID = StringMid($InputData, $StartOffset + 32, $IndexKeySize*2)
		$SID = _DecodeSID($SID)

		$OwnerId = StringMid($InputData, $StartOffset + 32 + ($IndexKeySize*2), 8)
		$OwnerId = Dec(_SwapEndian($OwnerId),2)

		If $VerboseOn Then
			_DumpOutput(@CRLF)
			_DumpOutput(_HexEncode("0x"&StringMid($InputData, $StartOffset, $IndexEntrySize*2)) & @CRLF)
			_DumpOutput("$Counter: " & $Counter & @CRLF)
			_DumpOutput("$DataOffset: " & $DataOffset & @CRLF)
			_DumpOutput("$DataSize: " & $DataSize & @CRLF)
			_DumpOutput("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
			_DumpOutput("$IndexKeySize: " & $IndexKeySize & @CRLF)
			_DumpOutput("$Flags: " & $Flags & @CRLF)
			_DumpOutput("$SID: " & $SID & @CRLF)
			_DumpOutput("$OwnerId: " & $OwnerId & @CRLF)
		EndIf

	;	$Padding8 = StringMid($InputData, $StartOffset + 32 + ($IndexKeySize*2), 16)
		FileWriteLine($LogFileQuotaOCsv, $RecordOffset&$de&$this_lsn&$de&$IndexEntrySize&$de&$IndexKeySize&$de&$Flags&$de&$SID&$de&$OwnerId&$de&$IsRedo&@crlf)
		$Counter+=1
		$StartOffset += $IndexEntrySize*2
	Until $StartOffset >= $InputDataSize
EndFunc

Func _Decode_Quota_Q($InputData,$IsRedo)
	Local $Counter=1
	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	If $VerboseOn Then
		_DumpOutput("_Decode_Quota_Q():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	EndIf

	Do
		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = Dec(_SwapEndian($DataOffset),2)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = Dec(_SwapEndian($DataSize),2)

		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = Dec(_SwapEndian($IndexEntrySize),2)
		If $IndexEntrySize = 0 Then ExitLoop

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = Dec(_SwapEndian($IndexKeySize),2)

		;1=Entry has subnodes, 2=Last entry
		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes
		$OwnerId = StringMid($InputData, $StartOffset + 32, 8)
		$OwnerId = Dec(_SwapEndian($OwnerId),2)

		$Version = StringMid($InputData, $StartOffset + 40, 8)
		$Version = "0x" & _SwapEndian($Version)

		$Flags2 = StringMid($InputData, $StartOffset + 48, 8)
		$Flags2 = _SwapEndian($Flags2)
		$Flags2Text = _Decode_QuotaFlags("0x"&$Flags2)

		$BytesUsed = StringMid($InputData, $StartOffset + 56, 16)
		$BytesUsed = Dec(_SwapEndian($BytesUsed),2)

		$ChangeTime = StringMid($InputData, $StartOffset + 72, 16)
		$ChangeTime = _SwapEndian($ChangeTime)
		$ChangeTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ChangeTime)
		$ChangeTime = _WinTime_UTCFileTimeFormat(Dec($ChangeTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
		If @error Then
			$ChangeTime = "-"
		ElseIf $TimestampPrecision = 2 Then
			$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-4)
			$ChangeTime_Precision = StringRight($ChangeTime,3)
		ElseIf $TimestampPrecision = 3 Then
			$ChangeTime = $ChangeTime & ":" & _FillZero(StringRight($ChangeTime_tmp, 4))
			$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-9)
			$ChangeTime_Precision = StringRight($ChangeTime,8)
		Else
			$ChangeTime_Core = $ChangeTime
		EndIf
		$TextInformation &= ";ChangeTime=" & $ChangeTime

		$WarningLimit = StringMid($InputData, $StartOffset + 88, 16)
		$WarningLimit = "0x" & _SwapEndian($WarningLimit)

		$HardLimit = StringMid($InputData, $StartOffset + 104, 16)
		$HardLimit = "0x" & _SwapEndian($HardLimit)

		$ExceededTime = StringMid($InputData, $StartOffset + 120, 16)

		If $ExceededTime <> "0000000000000000" Then
			$ExceededTime = _SwapEndian($ExceededTime)
			$ExceededTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ExceededTime)
			$ExceededTime = _WinTime_UTCFileTimeFormat(Dec($ExceededTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$ExceededTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$ExceededTime_Core = StringMid($ExceededTime,1,StringLen($ExceededTime)-4)
				$ExceededTime_Precision = StringRight($ExceededTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$ExceededTime = $ExceededTime & ":" & _FillZero(StringRight($ExceededTime_tmp, 4))
				$ExceededTime_Core = StringMid($ExceededTime,1,StringLen($ExceededTime)-9)
				$ExceededTime_Precision = StringRight($ExceededTime,8)
			Else
				$ExceededTime_Core = $ExceededTime
			EndIf
		Else
			$ExceededTime = 0
		EndIf

		$SID = StringMid($InputData, $StartOffset + 136)
		$SID = _DecodeSID($SID)

		If $VerboseOn Then
			_DumpOutput(@CRLF)
			_DumpOutput(_HexEncode("0x"&StringMid($InputData, $StartOffset, $IndexEntrySize*2)) & @CRLF)
			_DumpOutput("$Counter: " & $Counter & @CRLF)
			_DumpOutput("$DataOffset: " & $DataOffset & @CRLF)
			_DumpOutput("$DataSize: " & $DataSize & @CRLF)
			_DumpOutput("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
			_DumpOutput("$IndexKeySize: " & $IndexKeySize & @CRLF)
			_DumpOutput("$Flags: " & $Flags & @CRLF)
			_DumpOutput("$OwnerId: " & $OwnerId & @CRLF)
			_DumpOutput("$Version: " & $Version & @CRLF)
			_DumpOutput("$Flags2Text: " & $Flags2Text & @CRLF)
			_DumpOutput("$BytesUsed: " & $BytesUsed & @CRLF)
			_DumpOutput("$ChangeTime: " & $ChangeTime & @CRLF)
			_DumpOutput("$WarningLimit: " & $WarningLimit & @CRLF)
			_DumpOutput("$HardLimit: " & $HardLimit & @CRLF)
			_DumpOutput("$ExceededTime: " & $ExceededTime & @CRLF)
			_DumpOutput("$SID: " & $SID & @CRLF)
		EndIf

		;$Padding8 = StringMid($InputData, $StartOffset + 32 + ($IndexKeySize*2), 16)
		FileWriteLine($LogFileQuotaQCsv, $RecordOffset&$de&$this_lsn&$de&$IndexEntrySize&$de&$IndexKeySize&$de&$Flags&$de&$OwnerId&$de&$Version&$de&$Flags2Text&$de&$BytesUsed&$de&$ChangeTime&$de&$WarningLimit&$de&$HardLimit&$de&$ExceededTime&$de&$SID&$de&$IsRedo&@crlf)
		$Counter+=1
		$StartOffset += $IndexEntrySize*2
	Until $StartOffset >= $InputDataSize
EndFunc

Func _Decode_QuotaFlags($InputData)
	Local $Output=""
	If BitAND($InputData, 0x0001) Then $Output &= "Default Limits+"
	If BitAND($InputData, 0x0002) Then $Output &= "Limit Reached+"
	If BitAND($InputData, 0x0004) Then $Output &= "Id Deleted+"
	If BitAND($InputData, 0x0010) Then $Output &= "Tracking Enabled+"
	If BitAND($InputData, 0x0020) Then $Output &= "Enforcement Enabled+"
	If BitAND($InputData, 0x0040) Then $Output &= "Tracking Requested+"
	If BitAND($InputData, 0x0080) Then $Output &= "Log Threshold+"
	If BitAND($InputData, 0x0100) Then $Output &= "Log Limit+"
	If BitAND($InputData, 0x0200) Then $Output &= "Out Of Date+"
	If BitAND($InputData, 0x0400) Then $Output &= "Corrupt+"
	If BitAND($InputData, 0x0800) Then $Output &= "Pending Deletes+"
	$Output = StringTrimRight($Output, 1)
	Return $Output
EndFunc

Func _Decode_Reparse_R($InputData,$IsRedo)
	Local $Counter=1
	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	If $VerboseOn Then
		_DumpOutput("_Decode_Reparse_R():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	EndIf

	Do
		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = Dec(_SwapEndian($DataOffset),2)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = Dec(_SwapEndian($DataSize),2)

;		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = Dec(_SwapEndian($IndexEntrySize),2)
		If $IndexEntrySize = 0 Then ExitLoop

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = Dec(_SwapEndian($IndexKeySize),2)

		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes
		$KeyReparseTag = StringMid($InputData, $StartOffset + 32, 8)
		$KeyReparseTag = "0x" & _SwapEndian($KeyReparseTag)
		$KeyReparseTag = _GetReparseType($KeyReparseTag)

		$KeyMftRefOfReparsePoint = StringMid($InputData, $StartOffset + 40, 12)
		$KeyMftRefOfReparsePoint = Dec(_SwapEndian($KeyMftRefOfReparsePoint),2)

		$KeyMftRefSeqNoOfReparsePoint = StringMid($InputData, $StartOffset + 52, 4)
		$KeyMftRefSeqNoOfReparsePoint = Dec(_SwapEndian($KeyMftRefSeqNoOfReparsePoint),2)

		If $VerboseOn Then
			_DumpOutput(@CRLF)
			_DumpOutput(_HexEncode("0x"&StringMid($InputData, $StartOffset, $IndexEntrySize*2)) & @CRLF)
			_DumpOutput("$Counter: " & $Counter & @CRLF)
			_DumpOutput("$DataOffset: " & $DataOffset & @CRLF)
			_DumpOutput("$DataSize: " & $DataSize & @CRLF)
			_DumpOutput("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
			_DumpOutput("$IndexKeySize: " & $IndexKeySize & @CRLF)
			_DumpOutput("$Flags: " & $Flags & @CRLF)
			_DumpOutput("$KeyReparseTag: " & $KeyReparseTag & @CRLF)
			_DumpOutput("$KeyMftRefOfReparsePoint: " & $KeyMftRefOfReparsePoint & @CRLF)
			_DumpOutput("$KeyMftRefSeqNoOfReparsePoint: " & $KeyMftRefSeqNoOfReparsePoint & @CRLF)
		EndIf

	;	$Padding4 = StringMid($InputData, $StartOffset + 56, 8)
		FileWriteLine($LogFileReparseRCsv, $RecordOffset&$de&$this_lsn&$de&$IndexEntrySize&$de&$IndexKeySize&$de&$Flags&$de&$KeyReparseTag&$de&$KeyMftRefOfReparsePoint&$de&$KeyMftRefSeqNoOfReparsePoint&$de&$IsRedo&@crlf)
		$Counter+=1
		$StartOffset += $IndexEntrySize*2
	Until $StartOffset >= $InputDataSize
EndFunc

Func _Decode_OpenAttributeTableDumpNt6x($InputData,$IsFirst)
	Local $StartOffset = 1,$EntryCounter=1, $LocalIsNt6x=0
	;Header
	$TableEntrySize = StringMid($InputData, $StartOffset, 4)
	$TableEntrySize = Dec(_SwapEndian($TableEntrySize),2)

	$MaxEntries = StringMid($InputData, $StartOffset + 4, 4)
	$MaxEntries = Dec(_SwapEndian($MaxEntries),2)

	$NumberOfEntries = StringMid($InputData, $StartOffset + 8, 8)
	$NumberOfEntries = Dec(_SwapEndian($NumberOfEntries),2)
	If ($MaxEntries = 0 Or $NumberOfEntries = 0) Then _DumpOutput("VerboseInfo: Entries was 0 in _Decode_OpenAttributeTableDumpNt6x() at lsn " & $this_lsn & @CRLF)


	$EntrySignature = StringMid($InputData, $StartOffset + 24, 8)

	$OffsetLastRealEntry = StringMid($InputData, $StartOffset + 32, 8)
	$OffsetLastRealEntry = Dec(_SwapEndian($OffsetLastRealEntry),2)

;	$OffsetLastReservedEntry = StringMid($InputData, $StartOffset + 40, 8)
;	$OffsetLastReservedEntry = Dec(_SwapEndian($OffsetLastReservedEntry),2)
	$OffsetLastReservedEntry = $MaxEntries*$TableEntrySize

;	$NumberOfEntries = Round($OffsetLastReservedEntry/40)
	$NumberOfEntries = $MaxEntries

	If $VerboseOn Then
		_DumpOutput("_Decode_OpenAttributeTableDumpNt6x: " & @CRLF)
		_DumpOutput("$TableEntrySize: " & $TableEntrySize & @CRLF)
		_DumpOutput("$MaxEntries: " & $MaxEntries & @CRLF)
		_DumpOutput("$EntrySignature: " & $EntrySignature & @CRLF)
		_DumpOutput("$OffsetLastRealEntry: " & $OffsetLastRealEntry & @CRLF)
		_DumpOutput("$OffsetLastReservedEntry: " & $OffsetLastReservedEntry & @CRLF)
		_DumpOutput("$NumberOfEntries: " & $NumberOfEntries & @CRLF)
	EndIf

	$OpenAttributesArray[0][0] = "TableOffset"
	$OpenAttributesArray[0][1] = "AllocatedOrNextFree"
	$OpenAttributesArray[0][2] = "DirtyPagesSeen"
	$OpenAttributesArray[0][3] = "AttributeNamePresent"
	$OpenAttributesArray[0][4] = "unknown1"
	$OpenAttributesArray[0][5] = "AttributeCode"
	$OpenAttributesArray[0][6] = "unknown2"
	$OpenAttributesArray[0][7] = "MftRef"
	$OpenAttributesArray[0][8] = "MftRefSeqNo"
	$OpenAttributesArray[0][9] = "Lsn"
	$OpenAttributesArray[0][10] = "UnknownPointer"
	$OpenAttributesArray[0][11] = "EndSignature"
	$OpenAttributesArray[0][12] = "AttributeName"
	$OpenAttributesArray[0][13] = "IsNt6.x"

	$OffsetFirstEntry = 48

	$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8)
;	$TargetAttributeCode0 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 8)
	$TargetAttributeCode1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 4)
	$TargetAttributeCode2 = _ResolveAttributeType($TargetAttributeCode1)
	If $IsFirst=1 And $TargetAttributeCode2 = "UNKNOWN" And ($AllocatedOrNextFree = "00000000" Or $AllocatedOrNextFree = "FFFFFFFF") Then ;Wrong function
		_DumpOutput("Error in _Decode_OpenAttributeTableDumpNt6x()" & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
;		_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
;		_DumpOutput("$TargetAttributeCode0: " & $TargetAttributeCode0 & @CRLF)
;		_DumpOutput("$TargetAttributeCode1: " & $TargetAttributeCode1 & @CRLF)
;		_DumpOutput("$TargetAttributeCode2: " & $TargetAttributeCode2 & @CRLF)
		_DumpOutput("Calling _Decode_OpenAttributeTableDumpNt5x()" & @CRLF)
		If Not $IsNt5x Then $TextInformation &= ";Mixed OS detected"
		_Decode_OpenAttributeTableDumpNt5x($InputData,0)
		Return
	EndIf
	$LocalIsNt6x=1

	ReDim $OpenAttributesArray[1+$NumberOfEntries][14]
	Do
		$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8) ;AllocatedOrNextFree

		$DirtyPagesSeen = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 8, 2)

		$AttributeNamePresent = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 10, 2)

		$unknown1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 12, 4)

		$TargetAttributeCode = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 8)
;		$TargetAttributeCode = _SwapEndian($TargetAttributeCode)

		$unknown2 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 24, 8)

		$TargetMftRef = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 32, 12)
		$TargetMftRef = Dec(_SwapEndian($TargetMftRef),2)

		$TargetMftRefSeqNo = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 44, 4)
		$TargetMftRefSeqNo = Dec(_SwapEndian($TargetMftRefSeqNo),2)

		$TargetLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 48, 16)
		$TargetLsn = Dec(_SwapEndian($TargetLsn),2)
;		$unknown3 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 8)

		$UnknownPointer = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 64, 8)
		$UnknownPointer = _SwapEndian($UnknownPointer)
		$TargetEndSignature = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 72, 8)

		$OpenAttributesArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
		$OpenAttributesArray[$EntryCounter][1] = "0x" & $AllocatedOrNextFree
		$OpenAttributesArray[$EntryCounter][2] = "0x" & $DirtyPagesSeen
		$OpenAttributesArray[$EntryCounter][3] = "0x" & $AttributeNamePresent
		$OpenAttributesArray[$EntryCounter][4] = "0x" & $unknown1
		$OpenAttributesArray[$EntryCounter][5] = "0x" & $TargetAttributeCode
		$OpenAttributesArray[$EntryCounter][6] = "0x" & $unknown2
		$OpenAttributesArray[$EntryCounter][7] = $TargetMftRef
		$OpenAttributesArray[$EntryCounter][8] = $TargetMftRefSeqNo
		$OpenAttributesArray[$EntryCounter][9] = $TargetLsn
		$OpenAttributesArray[$EntryCounter][10] = "0x" & $UnknownPointer
		$OpenAttributesArray[$EntryCounter][11] = "0x" & $TargetEndSignature
		$OpenAttributesArray[$EntryCounter][13] = $LocalIsNt6x

		If $VerboseOn Then
			_DumpOutput(@CRLF)
			_DumpOutput("$EntryCounter: " & $EntryCounter & @CRLF)
			_DumpOutput(_HexEncode("0x"&StringMid($InputData,$StartOffset+$OffsetFirstEntry,$TableEntrySize*2)) & @CRLF)
			_DumpOutput("Offset: " & $OpenAttributesArray[$EntryCounter][0] & @CRLF)
			_DumpOutput("AllocatedOrNextFree: " & $OpenAttributesArray[$EntryCounter][1] & @CRLF)
			_DumpOutput("DirtyPagesSeen: " & $OpenAttributesArray[$EntryCounter][2] & @CRLF)
			_DumpOutput("AttributeNamePresent: " & $OpenAttributesArray[$EntryCounter][3] & @CRLF)
			_DumpOutput("unknown1: " & $OpenAttributesArray[$EntryCounter][4] & @CRLF)
			_DumpOutput("TargetAttributeCode: " & $OpenAttributesArray[$EntryCounter][5] & @CRLF)
			_DumpOutput("unknown2: " & $OpenAttributesArray[$EntryCounter][6] & @CRLF)
			_DumpOutput("TargetMftRef: " & $OpenAttributesArray[$EntryCounter][7] & @CRLF)
			_DumpOutput("TargetMftRefSeqNo: " & $OpenAttributesArray[$EntryCounter][8] & @CRLF)
			_DumpOutput("TargetLsn: " & $OpenAttributesArray[$EntryCounter][9] & @CRLF)
			_DumpOutput("UnknownPointer: " & $OpenAttributesArray[$EntryCounter][10] & @CRLF)
			_DumpOutput("TargetEndSignature: " & $OpenAttributesArray[$EntryCounter][11] & @CRLF)
		EndIf

		$StartOffset += $TableEntrySize*2
		$EntryCounter += 1
;	Until $StartOffset >= $OffsetLastRealEntry*2
;	Until $StartOffset-$OffsetFirstEntry >= $OffsetLastReservedEntry*2
	Until $StartOffset >= $OffsetLastReservedEntry*2
	ReDim $OpenAttributesArray[$EntryCounter][14]

	$lsn_openattributestable = $this_lsn
	If $VerboseOn Then
		_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
	EndIf
EndFunc

Func _Decode_OpenAttributeTableDumpNt5x($InputData,$IsFirst)
	Local $StartOffset = 1,$EntryCounter=1, $LocalIsNt6x=0
	;Header
	$TableEntrySize = StringMid($InputData, $StartOffset, 4)
	$TableEntrySize = Dec(_SwapEndian($TableEntrySize),2)

	$MaxEntries = StringMid($InputData, $StartOffset + 4, 4)
	$MaxEntries = Dec(_SwapEndian($MaxEntries),2)

	$NumberOfEntries = StringMid($InputData, $StartOffset + 8, 8)
	$NumberOfEntries = Dec(_SwapEndian($NumberOfEntries),2)
	If ($MaxEntries = 0 Or $NumberOfEntries = 0) Then _DumpOutput("VerboseInfo: Entries was 0 in _Decode_OpenAttributeTableDumpNt5x() at lsn " & $this_lsn & @CRLF)


	$EntrySignature = StringMid($InputData, $StartOffset + 24, 8)

	$OffsetLastRealEntry = StringMid($InputData, $StartOffset + 32, 8)
	$OffsetLastRealEntry = Dec(_SwapEndian($OffsetLastRealEntry),2)

;	$OffsetLastReservedEntry = StringMid($InputData, $StartOffset + 40, 8)
;	$OffsetLastReservedEntry = Dec(_SwapEndian($OffsetLastReservedEntry),2)
	$OffsetLastReservedEntry = $MaxEntries*$TableEntrySize

;	$NumberOfEntries = Round($OffsetLastReservedEntry/40)
	$NumberOfEntries = $MaxEntries

	If $VerboseOn Then
		_DumpOutput("_Decode_OpenAttributeTableDumpNt5x: " & @CRLF)
		_DumpOutput("$TableEntrySize: " & $TableEntrySize & @CRLF)
		_DumpOutput("$MaxEntries: " & $MaxEntries & @CRLF)
		_DumpOutput("$EntrySignature: " & $EntrySignature & @CRLF)
		_DumpOutput("$OffsetLastRealEntry: " & $OffsetLastRealEntry & @CRLF)
		_DumpOutput("$OffsetLastReservedEntry: " & $OffsetLastReservedEntry & @CRLF)
		_DumpOutput("$NumberOfEntries: " & $NumberOfEntries & @CRLF)
	EndIf

	$OpenAttributesArray[0][0] = "TableOffset"
	$OpenAttributesArray[0][1] = "AllocatedOrNextFree"
	$OpenAttributesArray[0][2] = "DirtyPagesSeen"
	$OpenAttributesArray[0][3] = "AttributeNamePresent"
	$OpenAttributesArray[0][4] = "unknown1"
	$OpenAttributesArray[0][5] = "AttributeCode"
	$OpenAttributesArray[0][6] = "unknown2"
	$OpenAttributesArray[0][7] = "MftRef"
	$OpenAttributesArray[0][8] = "MftRefSeqNo"
	$OpenAttributesArray[0][9] = "Lsn"
	$OpenAttributesArray[0][10] = "UnknownPointer"
	$OpenAttributesArray[0][11] = "EndSignature"
	$OpenAttributesArray[0][12] = "AttributeName"
	$OpenAttributesArray[0][13] = "IsNt6.x"

	$OffsetFirstEntry = 48

	$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8)
;	$TargetAttributeCode0 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 8)
	$TargetAttributeCode1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 4)
	$TargetAttributeCode2 = _ResolveAttributeType($TargetAttributeCode1)
	If $IsFirst=1 And $TargetAttributeCode2 = "UNKNOWN" And ($AllocatedOrNextFree = "00000000" Or $AllocatedOrNextFree = "FFFFFFFF") Then ;Wrong function
		_DumpOutput("Error in _Decode_OpenAttributeTableDumpNt5x()" & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
;		_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
;		_DumpOutput("$TargetAttributeCode0: " & $TargetAttributeCode0 & @CRLF)
;		_DumpOutput("$TargetAttributeCode1: " & $TargetAttributeCode1 & @CRLF)
;		_DumpOutput("$TargetAttributeCode2: " & $TargetAttributeCode2 & @CRLF)
		_DumpOutput("Calling _Decode_OpenAttributeTableDumpNt6x()" & @CRLF)
		If $IsNt5x Then $TextInformation &= ";Mixed OS detected"
		_Decode_OpenAttributeTableDumpNt6x($InputData,0)
		Return
	EndIf
	$LocalIsNt6x=0

	ReDim $OpenAttributesArray[1+$NumberOfEntries][14]
	Do
		$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8) ;AllocatedOrNextFree

		$UnknownPointer = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 8, 8) ;An offset to NamesDump?
		$UnknownPointer = _SwapEndian($UnknownPointer)

		$TargetMftRef = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 12)
		$TargetMftRef = Dec(_SwapEndian($TargetMftRef),2)

		$TargetMftRefSeqNo = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 28, 4)
		$TargetMftRefSeqNo = Dec(_SwapEndian($TargetMftRefSeqNo),2)

		$TargetLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 32, 16)
		$TargetLsn = Dec(_SwapEndian($TargetLsn),2)

		$unknown2 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 48, 8)

		$TargetAttributeCode = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 8)

		;$unknown3 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 64, 8)

		$TargetEndSignature = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 72, 8)

		$DirtyPagesSeen = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 80, 2)

		$AttributeNamePresent = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 82, 2)

		$unknown1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 84, 4)

		$OpenAttributesArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
		$OpenAttributesArray[$EntryCounter][1] = "0x" & $AllocatedOrNextFree
		$OpenAttributesArray[$EntryCounter][2] = "0x" & $DirtyPagesSeen
		$OpenAttributesArray[$EntryCounter][3] = "0x" & $AttributeNamePresent
		$OpenAttributesArray[$EntryCounter][4] = "0x" & $unknown1
		$OpenAttributesArray[$EntryCounter][5] = "0x" & $TargetAttributeCode
		$OpenAttributesArray[$EntryCounter][6] = "0x" & $unknown2
		$OpenAttributesArray[$EntryCounter][7] = $TargetMftRef
		$OpenAttributesArray[$EntryCounter][8] = $TargetMftRefSeqNo
		$OpenAttributesArray[$EntryCounter][9] = $TargetLsn
		$OpenAttributesArray[$EntryCounter][10] = "0x" & $UnknownPointer
		$OpenAttributesArray[$EntryCounter][11] = "0x" & $TargetEndSignature
		$OpenAttributesArray[$EntryCounter][13] = $LocalIsNt6x

		If $VerboseOn Then
			_DumpOutput(@CRLF)
			_DumpOutput("$EntryCounter: " & $EntryCounter & @CRLF)
			_DumpOutput(_HexEncode("0x"&StringMid($InputData,$StartOffset+$OffsetFirstEntry,$TableEntrySize*2)) & @CRLF)
			_DumpOutput("Offset: " & $OpenAttributesArray[$EntryCounter][0] & @CRLF)
			_DumpOutput("AllocatedOrNextFree: " & $OpenAttributesArray[$EntryCounter][1] & @CRLF)
			_DumpOutput("DirtyPagesSeen: " & $OpenAttributesArray[$EntryCounter][2] & @CRLF)
			_DumpOutput("AttributeNamePresent: " & $OpenAttributesArray[$EntryCounter][3] & @CRLF)
			_DumpOutput("unknown1: " & $OpenAttributesArray[$EntryCounter][4] & @CRLF)
			_DumpOutput("TargetAttributeCode: " & $OpenAttributesArray[$EntryCounter][5] & @CRLF)
			_DumpOutput("unknown2: " & $OpenAttributesArray[$EntryCounter][6] & @CRLF)
			_DumpOutput("TargetMftRef: " & $OpenAttributesArray[$EntryCounter][7] & @CRLF)
			_DumpOutput("TargetMftRefSeqNo: " & $OpenAttributesArray[$EntryCounter][8] & @CRLF)
			_DumpOutput("TargetLsn: " & $OpenAttributesArray[$EntryCounter][9] & @CRLF)
			_DumpOutput("UnknownPointer: " & $OpenAttributesArray[$EntryCounter][10] & @CRLF)
			_DumpOutput("TargetEndSignature: " & $OpenAttributesArray[$EntryCounter][11] & @CRLF)
		EndIf

		$StartOffset += $TableEntrySize*2
		$EntryCounter += 1
;	Until $StartOffset >= $OffsetLastRealEntry*2
;	Until $StartOffset-$OffsetFirstEntry >= $OffsetLastReservedEntry*2
	Until $StartOffset >= $OffsetLastReservedEntry*2
	ReDim $OpenAttributesArray[$EntryCounter][14]

	$lsn_openattributestable = $this_lsn
	If $VerboseOn Then
		_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
	EndIf
EndFunc

Func _Decode_AttributeNamesDump($InputData)
	Local $StartOffset = 1,$EntryCounter=1, $EntrySize=0
	$InputDataSize = StringLen($InputData)
	$AttributeNamesDumpArray[0][0] = "DumpOffset"
	$AttributeNamesDumpArray[0][1] = "OffsetInTable"
	$AttributeNamesDumpArray[0][2] = "NameLength"
	$AttributeNamesDumpArray[0][3] = "AttributeStreamName"


	Do
		If $StartOffset+8 >= $InputDataSize Then ExitLoop
		ReDim $AttributeNamesDumpArray[1+$EntryCounter][4]

		$OffsetInTable = StringMid($InputData, $StartOffset, 4)
;		ConsoleWrite("$OffsetInTable: " & $OffsetInTable & @CRLF)
		$OffsetInTable = _SwapEndian($OffsetInTable)

		$NameLength = StringMid($InputData, $StartOffset + 4, 4)
;		ConsoleWrite("$NameLength: " & $NameLength & @CRLF)
		$NameLength = Dec(_SwapEndian($NameLength),2)

		$AttributeStreamName = StringMid($InputData, $StartOffset + 8, $NameLength*2)
;		ConsoleWrite("$AttributeStreamName: " & $AttributeStreamName & @CRLF)
		$AttributeStreamName = BinaryToString("0x"&$AttributeStreamName,2)

		$AttributeNamesDumpArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset- 1)/2),8)
		$AttributeNamesDumpArray[$EntryCounter][1] = "0x" & $OffsetInTable
		$AttributeNamesDumpArray[$EntryCounter][2] = $NameLength
		$AttributeNamesDumpArray[$EntryCounter][3] = $AttributeStreamName

		If $VerboseOn Then
			_DumpOutput(@CRLF & "$EntryCounter: " & $EntryCounter & @CRLF)
			_DumpOutput("$StartOffset: 0x" & Hex(Int(($StartOffset- 1)/2),8) & @CRLF)
			_DumpOutput("$OffsetInTable: 0x" & $OffsetInTable & @CRLF)
			_DumpOutput("$NameLength: " & $NameLength & @CRLF)
			_DumpOutput("$AttributeStreamName: " & $AttributeStreamName & @CRLF)
		EndIf

		If Ubound($OpenAttributesArray) > 1 Then
;			ConsoleWrite("Ubound($OpenAttributesArray): " & Ubound($OpenAttributesArray) & @CRLF)
			$FoundInTable = _ArraySearch($OpenAttributesArray,$AttributeNamesDumpArray[$EntryCounter][1],0,0,0,2,1,0)
;			ConsoleWrite("$FoundInTable: " & $FoundInTable & @CRLF)
			If $FoundInTable > 0 Then $OpenAttributesArray[$FoundInTable][12] = $AttributeStreamName
		EndIf

		$EntrySize = 12 + ($NameLength*2)
		$StartOffset += $EntrySize
		$EntryCounter += 1
	Until $StartOffset+8 >= $InputDataSize
	ReDim $AttributeNamesDumpArray[$EntryCounter][4]


	For $i = 1 To UBound($OpenAttributesArray)-1
		FileWriteLine($LogFileOpenAttributeTableCsv, $RecordOffset&$de&$lsn_openattributestable&$de&$OpenAttributesArray[$i][0]&$de&$OpenAttributesArray[$i][12]&$de&$OpenAttributesArray[$i][1]&$de&$OpenAttributesArray[$i][2]&$de&$OpenAttributesArray[$i][3]&$de&$OpenAttributesArray[$i][4]&$de&$OpenAttributesArray[$i][5]&$de&_ResolveAttributeType(StringMid($OpenAttributesArray[$i][5],3,4))&$de&$OpenAttributesArray[$i][6]&$de&$OpenAttributesArray[$i][7]&$de&$OpenAttributesArray[$i][8]&$de&$OpenAttributesArray[$i][9]&$de&$OpenAttributesArray[$i][10]&$de&$OpenAttributesArray[$i][11]&$de&$OpenAttributesArray[$i][13]&@crlf)
	Next
	If $VerboseOn Then
		_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_ArrayDisplay($AttributeNamesDumpArray,"$AttributeNamesDumpArray")
;		ConsoleWrite("_Decode_AttributeNamesDump() end : " & @CRLF)
;		_ArrayDisplay($OpenAttributesArray,"$OpenAttributesArray")
	EndIf
EndFunc

Func _Decode_DirtyPageTableDump($InputData)
	Local $StartOffset = 1,$EntryCounter=1
	;Header
	$TableEntrySize = StringMid($InputData, $StartOffset, 4)
	$TableEntrySize = Dec(_SwapEndian($TableEntrySize),2)

	$unknown0 = StringMid($InputData, $StartOffset + 4, 4)

	$NumberOfEntries = StringMid($InputData, $StartOffset + 8, 8)
	$NumberOfEntries = Dec(_SwapEndian($NumberOfEntries),2)
;	ConsoleWrite("$NumberOfEntries: " & $NumberOfEntries & @CRLF)

	$EntrySignature = StringMid($InputData, $StartOffset + 24, 8)

	$OffsetLastRealEntry = StringMid($InputData, $StartOffset + 32, 8)
	$OffsetLastRealEntry = Dec(_SwapEndian($OffsetLastRealEntry),2)

	$OffsetLastReservedEntry = StringMid($InputData, $StartOffset + 40, 8)
	$OffsetLastReservedEntry = Dec(_SwapEndian($OffsetLastReservedEntry),2)

	$NumberOfEntries = Round($OffsetLastReservedEntry/40)

	$DirtyPageTableDumpArray[0][0] = "TableOffset"
	$DirtyPageTableDumpArray[0][1] = "AllocatedOrNextFree"
	$DirtyPageTableDumpArray[0][2] = "IndexOfDirtyPageEntryToOpenAttribute"
	$DirtyPageTableDumpArray[0][3] = "LengthOfTransfer"
	$DirtyPageTableDumpArray[0][4] = "LcnsToFollow"
	$DirtyPageTableDumpArray[0][5] = "Reserved"
	$DirtyPageTableDumpArray[0][6] = "Vcn"
	$DirtyPageTableDumpArray[0][7] = "OldestLsn"
	$DirtyPageTableDumpArray[0][8] = "LcnsForPage"
	$DirtyPageTableDumpArray[0][9] = "EndSignature"

	$OffsetFirstEntry = 48
	ReDim $DirtyPageTableDumpArray[1+$NumberOfEntries][10]
	Do
		If $StartOffset >= $OffsetLastRealEntry*2 Then ExitLoop
		$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8) ;AllocatedOrNextFree
		If $AllocatedOrNextFree <> $EntrySignature Then ExitLoop ;RESTART_ENTRY_ALLOCATED

		$IndexOfDirtyPageEntryToOpenAttribute = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 8, 8)
		$IndexOfDirtyPageEntryToOpenAttribute = _SwapEndian($IndexOfDirtyPageEntryToOpenAttribute)

		$LengthOfTransfer = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 8)
		$LengthOfTransfer = _SwapEndian($LengthOfTransfer)

		$LcnsToFollow = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 24, 8)
		$LcnsToFollow = _SwapEndian($LcnsToFollow)

		$Reserved = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 32, 8)

		$Vcn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 40, 8)
		$Vcn = Dec(_SwapEndian($Vcn),2)

		$OldestLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 48, 16)
		$OldestLsn = Dec(_SwapEndian($OldestLsn),2)

		$LcnsForPage = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 64, 8)
		$LcnsForPage = Dec(_SwapEndian($LcnsForPage),2)

		$TargetEndSignature = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 72, 8)

		$DirtyPageTableDumpArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
		$DirtyPageTableDumpArray[$EntryCounter][1] = "0x" & $AllocatedOrNextFree
		$DirtyPageTableDumpArray[$EntryCounter][2] = "0x" & $IndexOfDirtyPageEntryToOpenAttribute
		$DirtyPageTableDumpArray[$EntryCounter][3] = "0x" & $LengthOfTransfer
		$DirtyPageTableDumpArray[$EntryCounter][4] = "0x" & $LcnsToFollow
		$DirtyPageTableDumpArray[$EntryCounter][5] = "0x" & $Reserved
		$DirtyPageTableDumpArray[$EntryCounter][6] = $Vcn
		$DirtyPageTableDumpArray[$EntryCounter][7] = $OldestLsn
		$DirtyPageTableDumpArray[$EntryCounter][8] = $LcnsForPage
		$DirtyPageTableDumpArray[$EntryCounter][9] = "0x" & $TargetEndSignature

		$StartOffset += $TableEntrySize*2
		$EntryCounter += 1
;	Until $StartOffset-$OffsetFirstEntry >= $OffsetLastRealEntry*2
	Until $StartOffset >= $OffsetLastRealEntry*2
	ReDim $DirtyPageTableDumpArray[$EntryCounter][10]
;	_ArrayDisplay($DirtyPageTableDumpArray,"$DirtyPageTableDumpArray")
	For $i = 1 To UBound($DirtyPageTableDumpArray)-1
		FileWriteLine($LogFileDirtyPageTableCsv, $RecordOffset&$de&$this_lsn&$de&$DirtyPageTableDumpArray[$i][0]&$de&$DirtyPageTableDumpArray[$i][1]&$de&$DirtyPageTableDumpArray[$i][2]&$de&$DirtyPageTableDumpArray[$i][3]&$de&$DirtyPageTableDumpArray[$i][4]&$de&$DirtyPageTableDumpArray[$i][5]&$de&$DirtyPageTableDumpArray[$i][6]&$de&$DirtyPageTableDumpArray[$i][7]&$de&$DirtyPageTableDumpArray[$i][8]&$de&$DirtyPageTableDumpArray[$i][9]&@crlf)
	Next
EndFunc

Func _WriteCSVHeaderOpenAttributeTable()
	$OpenAttributeTable_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"TableOffset"&$de&"AttributeName"&$de&"AllocatedOrNextFree"&$de&"DirtyPagesSeen"&$de&"AttributeNamePresent"&$de&"unknown1"&$de&"AttributeCode"&$de&"AttributeType"&$de&"unknown2"&$de&"MftRef"&$de&"MftRefSeqNo"&$de&"Lsn"&$de&"UnknownPointer"&$de&"EndSignature"&$de&"IsNt6.x"
	FileWriteLine($LogFileOpenAttributeTableCsv, $OpenAttributeTable_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderDirtyPageTable()
	$DirtyPageTable_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"TableOffset"&$de&"AllocatedOrNextFree"&$de&"IndexOfDirtyPageEntryToOpenAttribute"&$de&"LengthOfTransfer"&$de&"LcnsToFollow"&$de&"Reserved"&$de&"Vcn"&$de&"OldestLsn"&$de&"LcnsForPage"&$de&"EndSignature"
	FileWriteLine($LogFileDirtyPageTableCsv, $DirtyPageTable_Csv_Header & @CRLF)
EndFunc
;#cs
Func _Decode_BitsInNonresidentBitMap2($data)
	Local $BitMapOffset, $NumberOfBits
	$BitMapOffset = "0x"&_SwapEndian(StringMid($data,1,8))
	$NumberOfBits = "0x"&_SwapEndian(StringMid($data,9,8))
	$TextInformation = ";BitMapOffset="&$BitMapOffset&";NumberOfBits="&$NumberOfBits
EndFunc
;#ce
Func _Decode_BitsInNonresidentBitMap($RedoData,$RedoOperation,$UndoData,$UndoOperation)
	Local $StartOffset = 1
	Local $Redo_BitMapOffset,$Redo_NumberOfBits,$Undo_BitMapOffset,$Undo_NumberOfBits
	$Redo_BitMapOffset = StringMid($RedoData, $StartOffset, 8)
	$Redo_BitMapOffset = "0x" & _SwapEndian($Redo_BitMapOffset)
	$Redo_NumberOfBits = StringMid($RedoData, $StartOffset + 8, 8)
	$Redo_NumberOfBits = "0x" & _SwapEndian($Redo_NumberOfBits)
	$Undo_BitMapOffset = StringMid($UndoData, $StartOffset, 8)
	$Undo_BitMapOffset = "0x" & _SwapEndian($Undo_BitMapOffset)
	$Undo_NumberOfBits = StringMid($UndoData, $StartOffset + 8, 8)
	$Undo_NumberOfBits = "0x" & _SwapEndian($Undo_NumberOfBits)
	If ($Redo_BitMapOffset <> $Undo_BitMapOffset) Or ($Redo_NumberOfBits <> $Undo_NumberOfBits) Then MsgBox(0,"Info","Bits mismatch in redo vs undo: " & $this_lsn)
	FileWriteLine($LogFileBitsInNonresidentBitMapCsv, $RecordOffset&$de&$this_lsn&$de&$RedoOperation&$de&$Redo_BitMapOffset&$de&$Redo_NumberOfBits&$de&$UndoOperation&$de&$Undo_BitMapOffset&$de&$Undo_NumberOfBits&@crlf)
EndFunc

Func _WriteCSVHeaderBitsInNonresidentBitMap()
	$BitsInNonresidentBitMap_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"RedoOperation"&$de&"Redo_BitMapOffset"&$de&"Redo_NumberOfBits"&$de&"UndoOperation"&$de&"Undo_BitMapOffset"&$de&"Undo_NumberOfBits"
	FileWriteLine($LogFileBitsInNonresidentBitMapCsv, $BitsInNonresidentBitMap_Csv_Header & @CRLF)
EndFunc

Func _DumpOutput($text)
   ConsoleWrite($text)
   If $debuglogfile Then FileWrite($debuglogfile, $text)
EndFunc

Func _WriteCSVHeaderObjIdO()
	$ObjIdO_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"IndexEntrySize"&$de&"IndexKeySize"&$de&"Flags"&$de&"GUIDObjectId"&$de&"MftRef"&$de&"MftSeqNo"&$de&"GUIDBirthVolumeId"&$de&"GUIDBirthObjectId"&$de&"GUIDDomainId"&$de&"IsRedo"
	FileWriteLine($LogFileObjIdOCsv, $ObjIdO_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderQuotaO()
	$QuotaO_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"IndexEntrySize"&$de&"IndexKeySize"&$de&"Flags"&$de&"SID"&$de&"OwnerId"&$de&"IsRedo"
	FileWriteLine($LogFileQuotaOCsv, $QuotaO_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderQuotaQ()
	$QuotaQ_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"IndexEntrySize"&$de&"IndexKeySize"&$de&"Flags"&$de&"OwnerId"&$de&"Version"&$de&"Flags2"&$de&"BytesUsed"&$de&"ChangeTime"&$de&"WarningLimit(bytes)"&$de&"HardLimit(bytes)"&$de&"ExceededTime"&$de&"SID"&$de&"IsRedo"
	FileWriteLine($LogFileQuotaQCsv, $QuotaQ_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderReparseR()
	$ReparseR_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"IndexEntrySize"&$de&"IndexKeySize"&$de&"Flags"&$de&"KeyReparseTag"&$de&"KeyMftRefOfReparsePoint"&$de&"KeyMftRefSeqNoOfReparsePoint"&$de&"IsRedo"
	FileWriteLine($LogFileReparseRCsv, $ReparseR_Csv_Header & @CRLF)
EndFunc

Func _Decode_TransactionTableDump($InputData)
	Local $StartOffset = 1,$EntryCounter=1
	;Header
	$TableEntrySize = StringMid($InputData, $StartOffset, 4)
	$TableEntrySize = Dec(_SwapEndian($TableEntrySize),2)

	$MaxEntries = StringMid($InputData, $StartOffset + 4, 4)
	$MaxEntries = Dec(_SwapEndian($MaxEntries),2)

	$NumberOfEntries = StringMid($InputData, $StartOffset + 8, 8)
	$NumberOfEntries = Dec(_SwapEndian($NumberOfEntries),2)
	If ($MaxEntries = 0 Or $NumberOfEntries = 0) Then _DumpOutput("VerboseInfo: Entries was 0 in _Decode_TransactionTableDump() at lsn " & $this_lsn & @CRLF)

	$EntrySignature = StringMid($InputData, $StartOffset + 24, 8)

	$OffsetLastRealEntry = StringMid($InputData, $StartOffset + 32, 8)
	$OffsetLastRealEntry = Dec(_SwapEndian($OffsetLastRealEntry),2)

;	$OffsetLastReservedEntry = StringMid($InputData, $StartOffset + 40, 8)
;	$OffsetLastReservedEntry = Dec(_SwapEndian($OffsetLastReservedEntry),2)
	$OffsetLastReservedEntry = $MaxEntries*$TableEntrySize

;	$NumberOfEntries = Round($OffsetLastReservedEntry/40)
	$NumberOfEntries = $MaxEntries

	If $VerboseOn Then
		_DumpOutput("_Decode_TransactionTableDump: " & @CRLF)
		_DumpOutput("$TableEntrySize: " & $TableEntrySize & @CRLF)
		_DumpOutput("$MaxEntries: " & $MaxEntries & @CRLF)
		_DumpOutput("$EntrySignature: " & $EntrySignature & @CRLF)
		_DumpOutput("$OffsetLastRealEntry: " & $OffsetLastRealEntry & @CRLF)
		_DumpOutput("$OffsetLastReservedEntry: " & $OffsetLastReservedEntry & @CRLF)
		_DumpOutput("$NumberOfEntries: " & $NumberOfEntries & @CRLF)
	EndIf

	$OffsetFirstEntry = 48
	Do
		$AllocatedOrNextFree = "0x" & StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8) ;AllocatedOrNextFree

		$TransactionState = "0x" & StringMid($InputData, $StartOffset + $OffsetFirstEntry + 8, 2)

		$Reserved = "0x" & StringMid($InputData, $StartOffset + $OffsetFirstEntry + 10, 6)

		$FirstLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 16)
		$FirstLsn = Dec(_SwapEndian($FirstLsn),2)

		$PreviousLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 32, 16)
		$PreviousLsn = Dec(_SwapEndian($PreviousLsn),2)

		$UndoNextLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 48, 16)
		$UndoNextLsn = Dec(_SwapEndian($UndoNextLsn),2)

		$UndoRecords = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 64, 8)
		$UndoRecords = Dec(_SwapEndian($UndoRecords),2)

		$UndoBytes = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 72, 8)
		$UndoBytes = Dec(_SwapEndian($UndoBytes),2)

		$EntryOffset = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)

		FileWriteLine($LogFileTransactionTableCsv, $this_lsn&$de&$EntryOffset&$de&$AllocatedOrNextFree&$de&$TransactionState&$de&$Reserved&$de&$FirstLsn&$de&$PreviousLsn&$de&$UndoNextLsn&$de&$UndoRecords&$de&$UndoBytes&@crlf)

		$StartOffset += $TableEntrySize*2
		$EntryCounter += 1
	Until $StartOffset >= $OffsetLastReservedEntry*2
EndFunc

Func _WriteCSVHeaderTransactionTable()
	$TransactionTable_Csv_Header = "lf_LSN"&$de&"TableOffset"&$de&"AllocatedOrNextFree"&$de&"TransactionState"&$de&"Reserved"&$de&"FirstLsn"&$de&"PreviousLsn"&$de&"UndoNextLsn"&$de&"UndoRecords"&$de&"UndoBytes"
	FileWriteLine($LogFileTransactionTableCsv, $TransactionTable_Csv_Header & @CRLF)
EndFunc

#cs
Global $FileNamesArray[1][3]
$FileNamesArray[0][0] = "Ref"
$FileNamesArray[0][1] = "FileName"
$FileNamesArray[0][2] = "LSN"
#ce

Func _GetFileNameFromArray($InputRef,$InputLsn)
	$InputRef=Int($InputRef)
	Local $FoundInTable = _ArraySearch($FileNamesArray,$InputRef,0,0,0,2,1,0)
	If $VerboseOn Then
		_DumpOutput("_GetFileNameFromArray(): " & @CRLF)
		_DumpOutput("$InputRef: " & $InputRef & @CRLF)
		_DumpOutput("$InputLsn: " & $InputLsn & @CRLF)
		_DumpOutput("$FoundInTable: " & $FoundInTable & @CRLF)
		_DumpOutput("@error: " & @error & @CRLF)
		_ArrayDisplay($FileNamesArray,"$FileNamesArray")
	EndIf
	If $FoundInTable > 0 Then
		If $InputLsn > $FileNamesArray[$FoundInTable][2] Then
			Return $FileNamesArray[$FoundInTable][1]
		EndIf
	EndIf
	Return ""
EndFunc

Func _UpdateFileNameArray($InputRef,$InputRefSeqNo,$InputName,$InputLsn)
	$InputRef=Int($InputRef)
	$InputName=String($InputName)
;	Local $FoundInTable = _ArraySearch($FileNamesArray,$InputRef,0,0,0,0,0,0)
	Local $FoundInTable = _ArraySearch($FileNamesArray,$InputRef,0,0,0,2,1,0)
	If $VerboseOn Then
		_DumpOutput("_UpdateFileNameArray(): " & @CRLF)
		_DumpOutput("$InputRef: " & $InputRef & @CRLF)
		_DumpOutput("$InputRefSeqNo: " & $InputRefSeqNo & @CRLF)
		_DumpOutput("$InputName: " & $InputName & @CRLF)
		_DumpOutput("$InputLsn: " & $InputLsn & @CRLF)
		_DumpOutput("$FoundInTable: " & $FoundInTable & @CRLF)
		_DumpOutput("@error: " & @error & @CRLF)
;		_ArrayDisplay($FileNamesArray,"$FileNamesArray")
	EndIf
	If $FoundInTable < 1 Then
		;Add new entry
		$ArrayEnd = UBound($FileNamesArray)
		ReDim $FileNamesArray[$ArrayEnd+1][3]
		$FileNamesArray[$ArrayEnd][0] = $InputRef
		$FileNamesArray[$ArrayEnd][1] = $InputName
		$FileNamesArray[$ArrayEnd][2] = $InputLsn
		FileWriteLine($LogFileFileNamesCsv, $RecordOffset & $de & $InputLsn & $de & $InputRef & $de & $InputRefSeqNo & $de & $InputName & @crlf)
	Else
		;Update existing entry
		If $FileNamesArray[$FoundInTable][1] <> $InputName Then
			$FileNamesArray[$FoundInTable][0] = $InputRef
			$FileNamesArray[$FoundInTable][1] = $InputName
			$FileNamesArray[$FoundInTable][2] = $InputLsn
			FileWriteLine($LogFileFileNamesCsv, $RecordOffset & $de & $InputLsn & $de & $InputRef & $de & $InputRefSeqNo & $de & $InputName & @crlf)
		EndIf
	EndIf
	Return $FoundInTable
EndFunc

Func _WriteCSVHeaderRCRD()
	$RCRD_Csv_Header = "Offset"&$de&"last_lsn"&$de&"page_flags"&$de&"page_count"&$de&"page_position"&$de&"next_record_offset"&$de&"page_unknown"&$de&"last_end_lsn"&$de&"KeepData"&$de&"RulesString"&$de&"GlobalRecordSpreadCounter"&$de&"GlobalRecordSpreadReset2"
	FileWriteLine($LogFileRCRDCsv, $RCRD_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderTransactionHeader()
	$TransactionHeader_Csv_Header = "RecordOffset"&$de&"this_lsn"&$de&"client_previous_lsn"&$de&"client_undo_next_lsn"&$de&"client_index"&$de&"record_type"&$de&"transaction_id"&$de&"lf_flags"&$de&"redo_operation"&$de&"undo_operation"&$de&"redo_offset"&$de&"redo_length"&$de&"undo_offset"&$de&"undo_length"&$de&"client_data_length"&$de&"target_attribute"&$de&"lcns_to_follow"&$de&"record_offset_in_mft"&$de&"attribute_offset"&$de&"MftClusterIndex"&$de&"target_vcn"&$de&"target_lcn"
	FileWriteLine($LogFileTransactionHeaderCsv, $TransactionHeader_Csv_Header & @CRLF)
EndFunc

Func _WriteCSVHeaderSlackOpenAttributeTable()
	$SlackOpenAttributeTable_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"TableOffset"&$de&"AttributeName"&$de&"AllocatedOrNextFree"&$de&"DirtyPagesSeen"&$de&"AttributeNamePresent"&$de&"unknown1"&$de&"AttributeCode"&$de&"AttributeType"&$de&"unknown2"&$de&"MftRef"&$de&"MftRefSeqNo"&$de&"Lsn"&$de&"UnknownPointer"&$de&"EndSignature"&$de&"IsNt6.x"
	FileWriteLine($LogFileSlackOpenAttributeTableCsv, $SlackOpenAttributeTable_Csv_Header & @CRLF)
EndFunc

Func _Decode_SlackOpenAttributeTableDumpNt6x($InputData,$IsFirst)
	Local $StartOffset = 1,$EntryCounter=1, $InputDataSize = StringLen($InputData), $LocalIsNt6x=0
	;Header
	$TableEntrySize = StringMid($InputData, $StartOffset, 4)
	$TableEntrySize = Dec(_SwapEndian($TableEntrySize),2)

	$MaxEntries = StringMid($InputData, $StartOffset + 4, 4)
	$MaxEntries = Dec(_SwapEndian($MaxEntries),2)

	$NumberOfEntries = StringMid($InputData, $StartOffset + 8, 8)
	$NumberOfEntries = Dec(_SwapEndian($NumberOfEntries),2)
	If ($MaxEntries = 0 Or $NumberOfEntries = 0) Then _DumpOutput("VerboseInfo: Entries was 0 in _Decode_SlackOpenAttributeTableDumpNt6x() at lsn " & $this_lsn & @CRLF)


	$EntrySignature = StringMid($InputData, $StartOffset + 24, 8)

	$OffsetLastRealEntry = StringMid($InputData, $StartOffset + 32, 8)
	$OffsetLastRealEntry = Dec(_SwapEndian($OffsetLastRealEntry),2)

;	$OffsetLastReservedEntry = StringMid($InputData, $StartOffset + 40, 8)
;	$OffsetLastReservedEntry = Dec(_SwapEndian($OffsetLastReservedEntry),2)
	$OffsetLastReservedEntry = $MaxEntries*$TableEntrySize

;	$NumberOfEntries = Round($OffsetLastReservedEntry/40)
	$NumberOfEntries = $MaxEntries

	If $VerboseOn Then
		_DumpOutput("_Decode_SlackOpenAttributeTableDumpNt6x: " & @CRLF)
		_DumpOutput("$TableEntrySize: " & $TableEntrySize & @CRLF)
		_DumpOutput("$MaxEntries: " & $MaxEntries & @CRLF)
		_DumpOutput("$EntrySignature: " & $EntrySignature & @CRLF)
		_DumpOutput("$OffsetLastRealEntry: " & $OffsetLastRealEntry & @CRLF)
		_DumpOutput("$OffsetLastReservedEntry: " & $OffsetLastReservedEntry & @CRLF)
		_DumpOutput("$NumberOfEntries: " & $NumberOfEntries & @CRLF)
	EndIf

	$SlackOpenAttributesArray[0][0] = "TableOffset"
	$SlackOpenAttributesArray[0][1] = "AllocatedOrNextFree"
	$SlackOpenAttributesArray[0][2] = "DirtyPagesSeen"
	$SlackOpenAttributesArray[0][3] = "AttributeNamePresent"
	$SlackOpenAttributesArray[0][4] = "unknown1"
	$SlackOpenAttributesArray[0][5] = "AttributeCode"
	$SlackOpenAttributesArray[0][6] = "unknown2"
	$SlackOpenAttributesArray[0][7] = "MftRef"
	$SlackOpenAttributesArray[0][8] = "MftRefSeqNo"
	$SlackOpenAttributesArray[0][9] = "Lsn"
	$SlackOpenAttributesArray[0][10] = "UnknownPointer"
	$SlackOpenAttributesArray[0][11] = "EndSignature"
	$SlackOpenAttributesArray[0][12] = "AttributeName"
	$SlackOpenAttributesArray[0][13] = "IsNt6.x"

	$OffsetFirstEntry = 48

	$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8)
;	$TargetAttributeCode0 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 8)
	$TargetAttributeCode1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 4)
	$TargetAttributeCode2 = _ResolveAttributeType($TargetAttributeCode1)
	If $IsFirst=1 And $TargetAttributeCode2 = "UNKNOWN" And ($AllocatedOrNextFree = "00000000" Or $AllocatedOrNextFree = "FFFFFFFF") Then ;Wrong function
		_DumpOutput("Error in _Decode_SlackOpenAttributeTableDumpNt6x()" & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
;		_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
;		_DumpOutput("$TargetAttributeCode0: " & $TargetAttributeCode0 & @CRLF)
;		_DumpOutput("$TargetAttributeCode1: " & $TargetAttributeCode1 & @CRLF)
;		_DumpOutput("$TargetAttributeCode2: " & $TargetAttributeCode2 & @CRLF)
		_DumpOutput("Calling _Decode_SlackOpenAttributeTableDumpNt5x()" & @CRLF)
		If Not $IsNt5x Then $TextInformation &= ";Mixed OS detected"
		_Decode_SlackOpenAttributeTableDumpNt5x($InputData,0)
		Return
	EndIf
	$LocalIsNt6x=1

	ReDim $SlackOpenAttributesArray[1+$NumberOfEntries][14]
	Do
		If $StartOffset >= $InputDataSize Then ExitLoop
		$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8) ;AllocatedOrNextFree

		$DirtyPagesSeen = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 8, 2)

		$AttributeNamePresent = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 10, 2)

		$unknown1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 12, 4)

		$TargetAttributeCode = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 8)
;		$TargetAttributeCode = _SwapEndian($TargetAttributeCode)

		$unknown2 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 24, 8)

		$TargetMftRef = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 32, 12)
		$TargetMftRef = Dec(_SwapEndian($TargetMftRef),2)

		$TargetMftRefSeqNo = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 44, 4)
		$TargetMftRefSeqNo = Dec(_SwapEndian($TargetMftRefSeqNo),2)

		$TargetLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 48, 16)
		$TargetLsn = Dec(_SwapEndian($TargetLsn),2)
;		$unknown3 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 8)

		$UnknownPointer = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 64, 8)
		$UnknownPointer = _SwapEndian($UnknownPointer)
		$TargetEndSignature = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 72, 8)

		$SlackOpenAttributesArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
		$SlackOpenAttributesArray[$EntryCounter][1] = "0x" & $AllocatedOrNextFree
		$SlackOpenAttributesArray[$EntryCounter][2] = "0x" & $DirtyPagesSeen
		$SlackOpenAttributesArray[$EntryCounter][3] = "0x" & $AttributeNamePresent
		$SlackOpenAttributesArray[$EntryCounter][4] = "0x" & $unknown1
		$SlackOpenAttributesArray[$EntryCounter][5] = "0x" & $TargetAttributeCode
		$SlackOpenAttributesArray[$EntryCounter][6] = "0x" & $unknown2
		$SlackOpenAttributesArray[$EntryCounter][7] = $TargetMftRef
		$SlackOpenAttributesArray[$EntryCounter][8] = $TargetMftRefSeqNo
		$SlackOpenAttributesArray[$EntryCounter][9] = $TargetLsn
		$SlackOpenAttributesArray[$EntryCounter][10] = "0x" & $UnknownPointer
		$SlackOpenAttributesArray[$EntryCounter][11] = "0x" & $TargetEndSignature
		$SlackOpenAttributesArray[$EntryCounter][13] = $LocalIsNt6x

		$StartOffset += $TableEntrySize*2
;		If $StartOffset >= $InputDataSize Then ExitLoop
		$EntryCounter += 1

;	Until $StartOffset >= $OffsetLastRealEntry*2
;	Until $StartOffset-$OffsetFirstEntry >= $OffsetLastReservedEntry*2
	Until $StartOffset >= $OffsetLastReservedEntry*2
	ReDim $SlackOpenAttributesArray[$EntryCounter][14]

	For $i = 1 To UBound($SlackOpenAttributesArray)-1
		FileWriteLine($LogFileSlackOpenAttributeTableCsv, $RecordOffset&$de&$this_lsn&$de&$SlackOpenAttributesArray[$i][0]&$de&$SlackOpenAttributesArray[$i][12]&$de&$SlackOpenAttributesArray[$i][1]&$de&$SlackOpenAttributesArray[$i][2]&$de&$SlackOpenAttributesArray[$i][3]&$de&$SlackOpenAttributesArray[$i][4]&$de&$SlackOpenAttributesArray[$i][5]&$de&_ResolveAttributeType(StringMid($SlackOpenAttributesArray[$i][5],3,4))&$de&$SlackOpenAttributesArray[$i][6]&$de&$SlackOpenAttributesArray[$i][7]&$de&$SlackOpenAttributesArray[$i][8]&$de&$SlackOpenAttributesArray[$i][9]&$de&$SlackOpenAttributesArray[$i][10]&$de&$SlackOpenAttributesArray[$i][11]&$de&$SlackOpenAttributesArray[$i][13]&@crlf)
	Next

;	$lsn_openattributestable = $this_lsn
	If $VerboseOn Then
		_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_ArrayDisplay($SlackOpenAttributesArray,"$SlackOpenAttributesArray")
	EndIf
EndFunc

Func _Decode_SlackOpenAttributeTableDumpNt5x($InputData,$IsFirst)
	Local $StartOffset = 1,$EntryCounter=1, $InputDataSize = StringLen($InputData), $LocalIsNt6x=0
	;Header
	$TableEntrySize = StringMid($InputData, $StartOffset, 4)
	$TableEntrySize = Dec(_SwapEndian($TableEntrySize),2)

	$MaxEntries = StringMid($InputData, $StartOffset + 4, 4)
	$MaxEntries = Dec(_SwapEndian($MaxEntries),2)

	$NumberOfEntries = StringMid($InputData, $StartOffset + 8, 8)
	$NumberOfEntries = Dec(_SwapEndian($NumberOfEntries),2)
	If ($MaxEntries = 0 Or $NumberOfEntries = 0) Then _DumpOutput("VerboseInfo: Entries was 0 in _Decode_SlackOpenAttributeTableDumpNt5x() at lsn " & $this_lsn & @CRLF)


	$EntrySignature = StringMid($InputData, $StartOffset + 24, 8)

	$OffsetLastRealEntry = StringMid($InputData, $StartOffset + 32, 8)
	$OffsetLastRealEntry = Dec(_SwapEndian($OffsetLastRealEntry),2)

;	$OffsetLastReservedEntry = StringMid($InputData, $StartOffset + 40, 8)
;	$OffsetLastReservedEntry = Dec(_SwapEndian($OffsetLastReservedEntry),2)
	$OffsetLastReservedEntry = $MaxEntries*$TableEntrySize

;	$NumberOfEntries = Round($OffsetLastReservedEntry/40)
	$NumberOfEntries = $MaxEntries

	If $VerboseOn Then
		_DumpOutput("_Decode_SlackOpenAttributeTableDumpNt5x: " & @CRLF)
		_DumpOutput("$TableEntrySize: " & $TableEntrySize & @CRLF)
		_DumpOutput("$MaxEntries: " & $MaxEntries & @CRLF)
		_DumpOutput("$EntrySignature: " & $EntrySignature & @CRLF)
		_DumpOutput("$OffsetLastRealEntry: " & $OffsetLastRealEntry & @CRLF)
		_DumpOutput("$OffsetLastReservedEntry: " & $OffsetLastReservedEntry & @CRLF)
		_DumpOutput("$NumberOfEntries: " & $NumberOfEntries & @CRLF)
	EndIf

	$SlackOpenAttributesArray[0][0] = "TableOffset"
	$SlackOpenAttributesArray[0][1] = "AllocatedOrNextFree"
	$SlackOpenAttributesArray[0][2] = "DirtyPagesSeen"
	$SlackOpenAttributesArray[0][3] = "AttributeNamePresent"
	$SlackOpenAttributesArray[0][4] = "unknown1"
	$SlackOpenAttributesArray[0][5] = "AttributeCode"
	$SlackOpenAttributesArray[0][6] = "unknown2"
	$SlackOpenAttributesArray[0][7] = "MftRef"
	$SlackOpenAttributesArray[0][8] = "MftRefSeqNo"
	$SlackOpenAttributesArray[0][9] = "Lsn"
	$SlackOpenAttributesArray[0][10] = "UnknownPointer"
	$SlackOpenAttributesArray[0][11] = "EndSignature"
	$SlackOpenAttributesArray[0][12] = "AttributeName"
	$SlackOpenAttributesArray[0][13] = "IsNt6.x"

	$OffsetFirstEntry = 48

	$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8)
;	$TargetAttributeCode0 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 8)
	$TargetAttributeCode1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 4)
	$TargetAttributeCode2 = _ResolveAttributeType($TargetAttributeCode1)
	If $IsFirst=1 And $TargetAttributeCode2 = "UNKNOWN" And ($AllocatedOrNextFree = "00000000" Or $AllocatedOrNextFree = "FFFFFFFF") Then ;Wrong function
		_DumpOutput("Error in _Decode_SlackOpenAttributeTableDumpNt5x()" & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
;		_DumpOutput("$AllocatedOrNextFree: " & $AllocatedOrNextFree & @CRLF)
;		_DumpOutput("$TargetAttributeCode0: " & $TargetAttributeCode0 & @CRLF)
;		_DumpOutput("$TargetAttributeCode1: " & $TargetAttributeCode1 & @CRLF)
;		_DumpOutput("$TargetAttributeCode2: " & $TargetAttributeCode2 & @CRLF)
		_DumpOutput("Calling _Decode_SlackOpenAttributeTableDumpNt6x()" & @CRLF)
		If $IsNt5x Then $TextInformation &= ";Mixed OS detected"
		_Decode_SlackOpenAttributeTableDumpNt6x($InputData,0)
		Return
	EndIf
	$LocalIsNt6x=0

	ReDim $SlackOpenAttributesArray[1+$NumberOfEntries][14]
	Do
		If $StartOffset >= $InputDataSize Then ExitLoop
		$AllocatedOrNextFree = StringMid($InputData, $StartOffset + $OffsetFirstEntry, 8) ;AllocatedOrNextFree

		$UnknownPointer = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 8, 8) ;An offset to NamesDump?
		$UnknownPointer = _SwapEndian($UnknownPointer)

		$TargetMftRef = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 16, 12)
		$TargetMftRef = Dec(_SwapEndian($TargetMftRef),2)

		$TargetMftRefSeqNo = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 28, 4)
		$TargetMftRefSeqNo = Dec(_SwapEndian($TargetMftRefSeqNo),2)

		$TargetLsn = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 32, 16)
		$TargetLsn = Dec(_SwapEndian($TargetLsn),2)

		$unknown2 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 48, 8)

		$TargetAttributeCode = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 56, 8)

		;$unknown3 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 64, 8)

		$TargetEndSignature = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 72, 8)

		$DirtyPagesSeen = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 80, 2)

		$AttributeNamePresent = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 82, 2)

		$unknown1 = StringMid($InputData, $StartOffset + $OffsetFirstEntry + 84, 4)

		$SlackOpenAttributesArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset + $OffsetFirstEntry - 1)/2),4)
		$SlackOpenAttributesArray[$EntryCounter][1] = "0x" & $AllocatedOrNextFree
		$SlackOpenAttributesArray[$EntryCounter][2] = "0x" & $DirtyPagesSeen
		$SlackOpenAttributesArray[$EntryCounter][3] = "0x" & $AttributeNamePresent
		$SlackOpenAttributesArray[$EntryCounter][4] = "0x" & $unknown1
		$SlackOpenAttributesArray[$EntryCounter][5] = "0x" & $TargetAttributeCode
		$SlackOpenAttributesArray[$EntryCounter][6] = "0x" & $unknown2
		$SlackOpenAttributesArray[$EntryCounter][7] = $TargetMftRef
		$SlackOpenAttributesArray[$EntryCounter][8] = $TargetMftRefSeqNo
		$SlackOpenAttributesArray[$EntryCounter][9] = $TargetLsn
		$SlackOpenAttributesArray[$EntryCounter][10] = "0x" & $UnknownPointer
		$SlackOpenAttributesArray[$EntryCounter][11] = "0x" & $TargetEndSignature
		$SlackOpenAttributesArray[$EntryCounter][13] = $LocalIsNt6x

		$StartOffset += $TableEntrySize*2
;		If $StartOffset >= $InputDataSize Then ExitLoop
		$EntryCounter += 1

;	Until $StartOffset >= $OffsetLastRealEntry*2
;	Until $StartOffset-$OffsetFirstEntry >= $OffsetLastReservedEntry*2
	Until $StartOffset >= $OffsetLastReservedEntry*2
	ReDim $SlackOpenAttributesArray[$EntryCounter][14]

	For $i = 1 To UBound($SlackOpenAttributesArray)-1
		FileWriteLine($LogFileSlackOpenAttributeTableCsv, $RecordOffset&$de&$this_lsn&$de&$SlackOpenAttributesArray[$i][0]&$de&$SlackOpenAttributesArray[$i][12]&$de&$SlackOpenAttributesArray[$i][1]&$de&$SlackOpenAttributesArray[$i][2]&$de&$SlackOpenAttributesArray[$i][3]&$de&$SlackOpenAttributesArray[$i][4]&$de&$SlackOpenAttributesArray[$i][5]&$de&_ResolveAttributeType(StringMid($SlackOpenAttributesArray[$i][5],3,4))&$de&$SlackOpenAttributesArray[$i][6]&$de&$SlackOpenAttributesArray[$i][7]&$de&$SlackOpenAttributesArray[$i][8]&$de&$SlackOpenAttributesArray[$i][9]&$de&$SlackOpenAttributesArray[$i][10]&$de&$SlackOpenAttributesArray[$i][11]&$de&$SlackOpenAttributesArray[$i][13]&@crlf)
	Next

;	$lsn_openattributestable = $this_lsn
	If $VerboseOn Then
		_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_ArrayDisplay($SlackOpenAttributesArray,"$SlackOpenAttributesArray")
	EndIf
EndFunc

Func _Decode_SlackAttributeNamesDump($InputData)
	Local $StartOffset = 1,$EntryCounter=1, $EntrySize=0
	$InputDataSize = StringLen($InputData)
	$SlackAttributeNamesDumpArray[0][0] = "DumpOffset"
	$SlackAttributeNamesDumpArray[0][1] = "OffsetInTable"
	$SlackAttributeNamesDumpArray[0][2] = "NameLength"
	$SlackAttributeNamesDumpArray[0][3] = "AttributeStreamName"

	Do
		If $StartOffset+8 >= $InputDataSize Then ExitLoop
		ReDim $SlackAttributeNamesDumpArray[1+$EntryCounter][4]

		$OffsetInTable = StringMid($InputData, $StartOffset, 4)
;		ConsoleWrite("$OffsetInTable: " & $OffsetInTable & @CRLF)
		$OffsetInTable = _SwapEndian($OffsetInTable)

		$NameLength = StringMid($InputData, $StartOffset + 4, 4)
;		ConsoleWrite("$NameLength: " & $NameLength & @CRLF)
		$NameLength = Dec(_SwapEndian($NameLength),2)

		$AttributeStreamName = StringMid($InputData, $StartOffset + 8, $NameLength*2)
;		ConsoleWrite("$AttributeStreamName: " & $AttributeStreamName & @CRLF)
		$AttributeStreamName = BinaryToString("0x"&$AttributeStreamName,2)

		$SlackAttributeNamesDumpArray[$EntryCounter][0] = "0x" & Hex(Int(($StartOffset- 1)/2),8)
		$SlackAttributeNamesDumpArray[$EntryCounter][1] = "0x" & $OffsetInTable
		$SlackAttributeNamesDumpArray[$EntryCounter][2] = $NameLength
		$SlackAttributeNamesDumpArray[$EntryCounter][3] = $AttributeStreamName

;		If Ubound($SlackOpenAttributesArray) > 1 Then
;			ConsoleWrite("Ubound($SlackOpenAttributesArray): " & Ubound($SlackOpenAttributesArray) & @CRLF)
;			$FoundInTable = _ArraySearch($SlackOpenAttributesArray,$SlackAttributeNamesDumpArray[$EntryCounter][1],0,0,0,2,1,0)
;			ConsoleWrite("$FoundInTable: " & $FoundInTable & @CRLF)
;			If $FoundInTable > 0 Then $SlackOpenAttributesArray[$FoundInTable][12] = $AttributeStreamName
;		EndIf

		$EntrySize = 12 + ($NameLength*2)
		$StartOffset += $EntrySize
;		If $StartOffset+8 >= $InputDataSize Then ExitLoop
		$EntryCounter += 1
	Until $StartOffset+8 >= $InputDataSize
	ReDim $SlackAttributeNamesDumpArray[$EntryCounter][4]

	For $i = 1 To UBound($SlackAttributeNamesDumpArray)-1
		FileWriteLine($LogFileSlackAttributeNamesDumpCsv, $RecordOffset&$de&$this_lsn&$de&$SlackAttributeNamesDumpArray[$i][0]&$de&$SlackAttributeNamesDumpArray[$i][1]&$de&$SlackAttributeNamesDumpArray[$i][2]&$de&$SlackAttributeNamesDumpArray[$i][3]&@crlf)
	Next
	If $VerboseOn Then
		_DumpOutput(@CRLF & "$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$redo_operation: " & $redo_operation & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_ArrayDisplay($SlackAttributeNamesDumpArray,"$SlackAttributeNamesDumpArray")
;		_ArrayDisplay($SlackOpenAttributesArray,"$SlackOpenAttributesArray")
	EndIf
EndFunc

Func _WriteCSVHeaderSlackAttributeNamesDump()
	$SlackAttributeNamesDump_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"DumpOffset"&$de&"OffsetInTable"&$de&"NameLength"&$de&"AttributeStreamName"
	FileWriteLine($LogFileSlackAttributeNamesDumpCsv, $SlackAttributeNamesDump_Csv_Header & @CRLF)
EndFunc

Func _CheckAndRepairTransactionHeader($InputData)
	Local $StartOffset=1, $InputDataSize = StringLen($InputData)/2, $SanityCheckSuccess=0, $DummyPrepend = "0000000000000000", $LocalCounter=0, $FragmentFakeLsnA = "3146616b654c736e", $FragmentFakeLsnB = "3246616b654c736e", $ReturnData
	Local $FragmentFakeLsn1, $FragmentFakeLsn2, $FragmentFakeLsn3, $FragmentTestLsn1, $FragmentTestLsn2, $FragmentTestLsn3, $FragmentRedoLength_tmp,$FragmentUndoLength_tmp

	Do
;		_DumpOutput("$LocalCounter: " & $LocalCounter & @CRLF)
;		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
;		_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
		$FragmentLsn1 = StringMid($InputData, $StartOffset, 16)
		$FragmentLsn1 = Dec(_SwapEndian($FragmentLsn1),2)
		$FragmentLsn2 = StringMid($InputData, $StartOffset + 16, 16)
		$FragmentLsn2 = Dec(_SwapEndian($FragmentLsn2),2)
		$FragmentLsn3 = StringMid($InputData, $StartOffset + 32, 16)
		$FragmentLsn3 = Dec(_SwapEndian($FragmentLsn3),2)
		$FragmentClientDataLength = StringMid($InputData, $StartOffset + 48, 8)
		$FragmentClientDataLength = Dec(_SwapEndian($FragmentClientDataLength),2)
		$FragmentClientIndex = StringMid($InputData, $StartOffset + 56, 8)
		$FragmentClientIndex = Dec(_SwapEndian($FragmentClientIndex),2)
		$FragmentRecordType = StringMid($InputData, $StartOffset + 64, 8)
		$FragmentRecordType = Dec(_SwapEndian($FragmentRecordType),2)
		$FragmentTransactionId = StringMid($InputData, $StartOffset + 72, 8)
		$FragmentTransactionId = Dec(_SwapEndian($FragmentTransactionId),2)
		$FragmentFlags = StringMid($InputData, $StartOffset + 80, 4)
		$FragmentFlags = Dec(_SwapEndian($FragmentFlags),2)
		;Allignment 6 bytes
		$FragmentRedoOp = StringMid($InputData, $StartOffset + 96, 4)
		$FragmentRedoOp = Dec(_SwapEndian($FragmentRedoOp),2)
		$FragmentUndoOp = StringMid($InputData, $StartOffset + 100, 4)
		$FragmentUndoOp = Dec(_SwapEndian($FragmentUndoOp),2)
		$FragmentRedoOffset = StringMid($InputData, $StartOffset + 104, 4)
		$FragmentRedoOffset = Dec(_SwapEndian($FragmentRedoOffset),2)
		$FragmentRedoLength = StringMid($InputData, $StartOffset + 108, 4)
		$FragmentRedoLength = Dec(_SwapEndian($FragmentRedoLength),2)
		$FragmentUndoOffset = StringMid($InputData, $StartOffset + 112, 4)
		$FragmentUndoOffset = Dec(_SwapEndian($FragmentUndoOffset),2)
		$FragmentUndoLength = StringMid($InputData, $StartOffset + 116, 4)
		$FragmentUndoLength = Dec(_SwapEndian($FragmentUndoLength),2)
		$FragmentTargetAttribute = StringMid($InputData, $StartOffset + 120, 4)
		$FragmentTargetAttribute = Dec(_SwapEndian($FragmentTargetAttribute),2)
		$FragmentLcnsToFollow = StringMid($InputData, $StartOffset + 124, 4)
		$FragmentLcnsToFollow = Dec(_SwapEndian($FragmentLcnsToFollow),2)
		$FragmentRecordOffsetInMft = StringMid($InputData, $StartOffset + 128, 4)
		$FragmentRecordOffsetInMft = Dec(_SwapEndian($FragmentRecordOffsetInMft),2)
		$FragmentAttributeOffset = StringMid($InputData, $StartOffset + 132, 4)
		$FragmentAttributeOffset = Dec(_SwapEndian($FragmentAttributeOffset),2)
		$FragmentMftClusterIndex = StringMid($InputData, $StartOffset + 136, 4)
		$FragmentMftClusterIndex = Dec(_SwapEndian($FragmentMftClusterIndex),2)
		$FragmentTargetVcn = StringMid($InputData, $StartOffset + 140, 8)
		$FragmentTargetVcn = Dec(_SwapEndian($FragmentTargetVcn),2)
		$FragmentTargetLcn = StringMid($InputData, $StartOffset + 148, 8)
		$FragmentTargetLcn = Dec(_SwapEndian($FragmentTargetLcn),2)
		;Do the tests

		Select
			Case _SanityCheck_LSN($FragmentLsn1)=0 And $LocalCounter < 1
				If $LocalCounter > 0 Then
;					_DumpOutput("Skipping _SanityCheck_LSN($FragmentLsn1)" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_LSN($FragmentLsn1)" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_LSN($FragmentLsn2)=0 And $LocalCounter < 2
				If $LocalCounter > 1 Then
;					_DumpOutput("Skipping _SanityCheck_LSN($FragmentLsn2)" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_LSN($FragmentLsn2)" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_LSN($FragmentLsn3)=0 And $LocalCounter < 3
				If $LocalCounter > 2 Then
;					_DumpOutput("Skipping _SanityCheck_LSN($FragmentLsn3)" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_LSN($FragmentLsn3)" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityTest2($FragmentLsn1,$FragmentLsn2,$FragmentLsn3)=0 And $LocalCounter < 1
				If $LocalCounter > 0 Then
;					_DumpOutput("Skipping _SanityTest2()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityTest2()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityTest3($FragmentLsn2,$FragmentLsn3)=0 And $LocalCounter < 2
				If $LocalCounter > 1 Then
;					_DumpOutput("Skipping _SanityTest3()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityTest3()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_ClientDataLength($FragmentClientDataLength)=0 And $LocalCounter < 4
				If $LocalCounter > 3 Then
;					_DumpOutput("Skipping _SanityCheck_ClientDataLength()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_ClientDataLength()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_ClientIndex($FragmentClientIndex)=0 And $LocalCounter < 4
				If $LocalCounter > 3 Then
;					_DumpOutput("Skipping _SanityCheck_ClientIndex()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_ClientIndex()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_RecordType($FragmentRecordType)=0 And $LocalCounter < 5
				If $LocalCounter > 4 Then
;					_DumpOutput("Skipping _SanityCheck_RecordType()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_RecordType()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_TransactionId($FragmentTransactionId)=0 And $LocalCounter < 5
				If $LocalCounter > 4 Then
;					_DumpOutput("Skipping _SanityCheck_TransactionId()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_TransactionId()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_Flags($FragmentFlags)=0 And $LocalCounter < 6
				If $LocalCounter > 5 Then
;					_DumpOutput("Skipping _SanityCheck_Flags()" & @CRLF)
				Else
;					_DumpOutput("Error in _SanityCheck_Flags()" & @CRLF)
					$InputData = $DummyPrepend & $InputData
					$LocalCounter += 1
					ContinueLoop
				EndIf
			Case _SanityCheck_UndoRedoOpCode($FragmentRedoOp)=0
;				_DumpOutput("Error in _SanityCheck_UndoRedoOpCode($FragmentRedoOp)" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_UndoRedoOpCode($FragmentUndoOp)=0
;				_DumpOutput("Error in _SanityCheck_UndoRedoOpCode($FragmentUndoOp)" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_RedoOffset($FragmentRedoOffset)=0
;				_DumpOutput("Error in _SanityCheck_RedoOffset()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_UndoOffset($FragmentUndoOffset)=0
;				_DumpOutput("Error in _SanityCheck_UndoOffset()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_TargetAttribute($FragmentTargetAttribute)=0
;				_DumpOutput("Error in _SanityCheck_TargetAttribute()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_LcnsToFollow($FragmentLcnsToFollow)=0
;				_DumpOutput("Error in _SanityCheck_LcnsToFollow()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_RecordOffsetInMft($FragmentRecordOffsetInMft)=0
;				_DumpOutput("Error in _SanityCheck_RecordOffsetInMft()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityCheck_AttributeOffset($FragmentAttributeOffset)=0
;				_DumpOutput("Error in _SanityCheck_AttributeOffset()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop
			Case _SanityTest1($FragmentRedoOp,$FragmentUndoOp)=0
;				_DumpOutput("Error in _SanityTest1()" & @CRLF)
				$InputData = $DummyPrepend & $InputData
				$LocalCounter += 1
				ContinueLoop

			Case Else
				$SanityCheckSuccess=1
;				_DumpOutput("Case Else" & @CRLF)
;				_DumpOutput("_SanityCheckTransactionHeader: Validation success at prepending bytes: " & $LocalCounter*8 & @CRLF)
;				_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
				ExitLoop
;				$StartOffset += 96 + ($FragmentClientDataLength*2)
		EndSelect

		$SanityCheckSuccess=1
;		_DumpOutput("_SanityCheckTransactionHeader: Validation success at prepending bytes: " & $LocalCounter*8 & @CRLF)
;		_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
		ExitLoop
	Until $LocalCounter > 6
;	_DumpOutput("_SanityCheckTransactionHeader: Validation success at $StartOffset = " & $StartOffset & @CRLF)
;	_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
	If Not $SanityCheckSuccess Then
		_DumpOutput("Repair of header failed" & @CRLF)
		Return SetError(1,0,0)
	EndIf
	_DumpOutput("_CheckAndRepairTransactionHeader(): Validation success when prepending bytes: 0x" & Hex(Int($LocalCounter*8),4) & @CRLF)
;	_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)


	If $LocalCounter > 3 Then
	;Align tmp sizes to 8 bytes
		$FragmentRedoLength_tmp = $FragmentRedoLength
		If Mod($FragmentRedoLength_tmp,8) Then
			While 1
				$FragmentRedoLength_tmp+=1
				If Mod($FragmentRedoLength_tmp,8) = 0 Then ExitLoop
			WEnd
		EndIf

		$FragmentUndoLength_tmp = $FragmentUndoLength
		If Mod($FragmentUndoLength_tmp,8) Then
			While 1
				$FragmentUndoLength_tmp+=1
				If Mod($FragmentUndoLength_tmp,8) = 0 Then ExitLoop
			WEnd
		EndIf
	EndIf

;	_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	;Attempt rebuilding a header
	Select
		Case $LocalCounter = 1
;			_DumpOutput("Case $LocalCounter = 1" & @CRLF)
			$FragmentTestLsn2 = StringMid($InputData,$StartOffset + 16,16)
			$FragmentTestLsn2 = Dec(_SwapEndian($FragmentTestLsn2),2)
			If $FragmentTestLsn2 > 0 Then
				$FragmentFakeLsn1 = $FragmentTestLsn2 + 760 ;Just add something
				$FragmentFakeLsn1 = _SwapEndian(Hex($FragmentFakeLsn1,16))
			Else
				$FragmentFakeLsn1 = $FragmentFakeLsnA
			EndIf
			$ReturnData = $FragmentFakeLsn1 & StringMid($InputData,$StartOffset + 16)
			$TextInformation &= ";Header rebuilt with fake (LSN1)"
			_DumpOutput("Header rebuilt with fake (LSN1)" & @CRLF)
		Case $LocalCounter = 2
;			_DumpOutput("Case $LocalCounter = 2" & @CRLF)
			$FragmentTestLsn3 = StringMid($InputData,$StartOffset + 32,16)
			$FragmentTestLsn3 = Dec(_SwapEndian($FragmentTestLsn3),2)
			If $FragmentTestLsn3 > 0 Then
				$FragmentFakeLsn1 = $FragmentTestLsn3 + 760 ;Just add something
				$FragmentFakeLsn1 = _SwapEndian(Hex($FragmentFakeLsn1,16))
				$FragmentFakeLsn2 = _SwapEndian(Hex($FragmentTestLsn3,16))
			Else
				$FragmentFakeLsn1 = $FragmentFakeLsnB
				$FragmentFakeLsn2 = $DummyPrepend ;$FragmentFakeLsnA
			EndIf
			$ReturnData = $FragmentFakeLsn1 & $FragmentFakeLsn2 & StringMid($InputData,$StartOffset + 32)
			$TextInformation &= ";Header rebuilt with fake (LSN1,LSN2)"
			_DumpOutput("Header rebuilt with fake (LSN1,LSN2)" & @CRLF)
		Case $LocalCounter = 3
;			_DumpOutput("Case $LocalCounter = 3" & @CRLF)
			$FragmentFakeLsn1 = $FragmentFakeLsnB
			$FragmentFakeLsn2 = $FragmentFakeLsnA
			$FragmentFakeLsn3 = $FragmentFakeLsnA
			$ReturnData = $FragmentFakeLsn1 & $FragmentFakeLsn2 & $FragmentFakeLsn3 & StringMid($InputData,$StartOffset + 48)
			$TextInformation &= ";Header rebuilt with fake (LSN1,LSN2,LSN3)"
			_DumpOutput("Header rebuilt with fake (LSN1,LSN2,LSN3)" & @CRLF)
		Case $LocalCounter = 4
;			_DumpOutput("Case $LocalCounter = 4" & @CRLF)
			$FragmentFakeLsn1 = $FragmentFakeLsnB
			$FragmentFakeLsn2 = $FragmentFakeLsnA
			$FragmentFakeLsn3 = $FragmentFakeLsnA
;			If _SolveUndoRedoCodes($FragmentRedoOp) <> "CompensationlogRecord" Then
				$FragmentFakeClientDataLength = _Max(Int($FragmentRedoOffset+$FragmentRedoLength_tmp),Int($FragmentUndoOffset+$FragmentUndoLength_tmp))
				$FragmentFakeClientDataLength = _SwapEndian(Hex(Int($FragmentFakeClientDataLength),8))
;			Else ;Actually this is not needed
;				$FragmentFakeClientDataLength = (StringLen($InputData)-96)/2
;				$FragmentFakeClientDataLength = _SwapEndian(Hex(Int($FragmentFakeClientDataLength),8))
;			EndIf
			$FragmentFakeClientIndex = "00000000"
			$ReturnData = $FragmentFakeLsn1 & $FragmentFakeLsn2 & $FragmentFakeLsn3 & $FragmentFakeClientDataLength & $FragmentFakeClientIndex & StringMid($InputData,$StartOffset + 64)
			$TextInformation &= ";Header rebuilt with fake (LSN1,LSN2,LSN3,ClientDataLength,ClientIndex)"
			_DumpOutput("Header rebuilt with fake (LSN1,LSN2,LSN3,ClientDataLength,ClientIndex)" & @CRLF)
		Case $LocalCounter = 5
;			_DumpOutput("Case $LocalCounter = 5" & @CRLF)
			$FragmentFakeLsn1 = $FragmentFakeLsnB
			$FragmentFakeLsn2 = $FragmentFakeLsnA
			$FragmentFakeLsn3 = $FragmentFakeLsnA
;			If _SolveUndoRedoCodes($FragmentRedoOp) <> "CompensationlogRecord" Then
				$FragmentFakeClientDataLength = _Max(Int($FragmentRedoOffset+$FragmentRedoLength_tmp),Int($FragmentUndoOffset+$FragmentUndoLength_tmp))
				$FragmentFakeClientDataLength = _SwapEndian(Hex(Int($FragmentFakeClientDataLength),8))
;			Else ;Actually this is not needed
;				$FragmentFakeClientDataLength = (StringLen($InputData)-96)/2
;				$FragmentFakeClientDataLength = _SwapEndian(Hex(Int($FragmentFakeClientDataLength),8))
;			EndIf
			$FragmentFakeClientIndex = "00000000"
			$FragmentFakeRecordType = "01000000"
			$FragmentFakeTransactionId = "18000000"
			$ReturnData = $FragmentFakeLsn1 & $FragmentFakeLsn2 & $FragmentFakeLsn3 & $FragmentFakeClientDataLength & $FragmentFakeClientIndex & $FragmentFakeRecordType & $FragmentFakeTransactionId & StringMid($InputData,$StartOffset + 80)
			$TextInformation &= ";Header rebuilt with fake (LSN1,LSN2,LSN3,ClientDataLength,ClientIndex,RecordType,TransactionId)"
			_DumpOutput("Header rebuilt with fake (LSN1,LSN2,LSN3,ClientDataLength,ClientIndex,RecordType,TransactionId)" & @CRLF)
		Case $LocalCounter = 6
;			_DumpOutput("Case $LocalCounter = 6" & @CRLF)
			$FragmentFakeLsn1 = $FragmentFakeLsnB
			$FragmentFakeLsn2 = $FragmentFakeLsnA
			$FragmentFakeLsn3 = $FragmentFakeLsnA
;			If _SolveUndoRedoCodes($FragmentRedoOp) <> "CompensationlogRecord" Then
				$FragmentFakeClientDataLength = _Max(Int($FragmentRedoOffset+$FragmentRedoLength_tmp),Int($FragmentUndoOffset+$FragmentUndoLength_tmp))
				$FragmentFakeClientDataLength = _SwapEndian(Hex(Int($FragmentFakeClientDataLength),8))
;			Else ;Actually this is not needed
;				$FragmentFakeClientDataLength = (StringLen($InputData)-96)/2
;				$FragmentFakeClientDataLength = _SwapEndian(Hex(Int($FragmentFakeClientDataLength),8))
;			EndIf
			$FragmentFakeClientIndex = "00000000"
			$FragmentFakeRecordType = "01000000"
			$FragmentFakeTransactionId = "18000000"
			$FragmentFakeFlags = "0000"
			$FragmentFakePadding6 = "000000000000"
			$ReturnData = $FragmentFakeLsn1 & $FragmentFakeLsn2 & $FragmentFakeLsn3 & $FragmentFakeClientDataLength & $FragmentFakeClientIndex & $FragmentFakeRecordType & $FragmentFakeTransactionId & $FragmentFakeFlags & $FragmentFakePadding6 & StringMid($InputData,$StartOffset + 96)
			$TextInformation &= ";Header rebuilt with fake (LSN1,LSN2,LSN3,ClientDataLength,ClientIndex,RecordType,TransactionId,Flags)"
			_DumpOutput("Header rebuilt with fake (LSN1,LSN2,LSN3,ClientDataLength,ClientIndex,RecordType,TransactionId,Flags)" & @CRLF)
		Case Else
			$ReturnData = $InputData
	EndSelect

	_DumpOutput("Repaired transaction:" & @CRLF)
	If $LocalCounter < 4 Then
		_DumpOutput(_HexEncode("0x"&StringMid($ReturnData,$StartOffset,96 + ($FragmentClientDataLength*2))) & @CRLF)
		Return StringMid($ReturnData,$StartOffset,96 + ($FragmentClientDataLength*2))
	Else
		_DumpOutput(_HexEncode("0x"&$ReturnData) & @CRLF)
		Return $ReturnData
	EndIf
EndFunc

Func _SanityTest1($RedoOp,$UndoOp)
	$Undo = _SolveUndoRedoCodes($UndoOp)
	$Redo = _SolveUndoRedoCodes($RedoOp)
	If $Undo = "Noop" And Not ($Redo = "DirtyPageTableDump" Or $Redo = "CompensationlogRecord" Or $Redo = "UpdateNonResidentValue" Or $Redo = "InitializeFileRecordSegment" Or $Redo = "OpenAttributeTableDump" Or $Redo = "AttributeNamesDump" Or $Redo = "OpenNonresidentAttribute" Or $Redo = "TransactionTableDump") Then
		_DumpOutput("_SanityTest1: 1" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "ForgetTransaction" And $Undo <> "CompensationlogRecord") Or ($Undo = "CompensationlogRecord" And $Redo <> "ForgetTransaction") Then
		_DumpOutput("_SanityTest1: 2" & @CRLF)
		Return 0
	EndIf
	If $Undo = "DeallocateFileRecordSegment" And $Redo <> "Noop" Then
		_DumpOutput("_SanityTest1: 3" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "AddIndexEntryAllocation" And $Undo <> "DeleteIndexEntryAllocation") Or ($Undo = "DeleteIndexEntryAllocation" And $Redo <> "AddIndexEntryAllocation") Then
		_DumpOutput("_SanityTest1: 4" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "AddindexEntryRoot" And $Undo <> "DeleteindexEntryRoot") Or ($Undo = "DeleteindexEntryRoot" And $Redo <> "AddindexEntryRoot") Then
		_DumpOutput("_SanityTest1: 5" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "CreateAttribute" And $Undo <> "DeleteAttribute") Or ($Undo = "DeleteAttribute" And $Redo <> "CreateAttribute") Then
		_DumpOutput("_SanityTest1: 6" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "SetBitsInNonresidentBitMap" And $Undo <> "ClearBitsInNonresidentBitMap") Or ($Undo = "SetBitsInNonresidentBitMap" And $Redo <> "ClearBitsInNonresidentBitMap") Then
		_DumpOutput("_SanityTest1: 7" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "SetIndexEntryVcnAllocation" And $Undo <> "SetIndexEntryVcnAllocation") Or ($Undo = "SetIndexEntryVcnAllocation" And $Redo <> "SetIndexEntryVcnAllocation") Then
		_DumpOutput("_SanityTest1: 8" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "SetIndexEntryVcnRoot" And $Undo <> "SetIndexEntryVcnRoot") Or ($Undo = "SetIndexEntryVcnRoot" And $Redo <> "SetIndexEntryVcnRoot") Then
		_DumpOutput("_SanityTest1: 9" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "UpdateMappingPairs" And $Undo <> "UpdateMappingPairs") Or ($Undo = "UpdateMappingPairs" And $Redo <> "UpdateMappingPairs") Then
		_DumpOutput("_SanityTest1: 10" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "WriteEndOfIndexBuffer" And $Undo <> "WriteEndOfIndexBuffer") Or ($Undo = "WriteEndOfIndexBuffer" And $Redo <> "WriteEndOfIndexBuffer") Then
		_DumpOutput("_SanityTest1: 11" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "UpdateResidentValue" And $Undo <> "UpdateResidentValue") Or ($Undo = "UpdateResidentValue" And $Redo <> "UpdateResidentValue") Then
		_DumpOutput("_SanityTest1: 12" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "UpdateFileNameRoot" And $Undo <> "UpdateFileNameRoot") Or ($Undo = "UpdateFileNameRoot" And $Redo <> "UpdateFileNameRoot") Then
		_DumpOutput("_SanityTest1: 13" & @CRLF)
		Return 0
	EndIf
	If ($Redo = "UpdateFileNameAllocation" And $Undo <> "UpdateFileNameAllocation") Or ($Undo = "UpdateFileNameAllocation" And $Redo <> "UpdateFileNameAllocation") Then
		_DumpOutput("_SanityTest1: 14" & @CRLF)
		Return 0
	EndIf
	Return 1
EndFunc

Func _SanityTest2($LSN1,$LSN2,$LSN3)
	If $LSN2 > $LSN1 Or $LSN3 > $LSN1 Or ($LSN2 = 0 And $LSN3 <> 0) Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func _SanityTest3($LSN2,$LSN3)
	If $LSN2 = 0 And $LSN3 <> 0 Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func _SanityCheck_LSN($InputData)
	If $InputData = 0 Or $InputData > 0xFFFF Then ;And $InputData < 0xFFFFFFFFFFFFFFFF Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_ClientDataLength($InputData)
	If $InputData > 0x28 and $InputData < 0xFFFF Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_ClientIndex($InputData)
	If $InputData <> 0x0 And $InputData <> 0x1 Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func _SanityCheck_RecordType($InputData)
	If $InputData <> 0x1 And $InputData <> 0x2 Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func _SanityCheck_TransactionId($InputData)
	If Not Mod($InputData,8) Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_Flags($InputData)
	If $InputData <> 0x0 And $InputData <> 0x1 Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func _SanityCheck_UndoRedoOpCode($InputData)
	If _SolveUndoRedoCodes($InputData) <> "UNKNOWN" Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_RedoOffset($InputData)
	If Not Mod($InputData,8) And $InputData < 0xFFFF Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_UndoOffset($InputData)
	If $InputData > 0x0 And $InputData < 0xFFFF Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_TargetAttribute($InputData)
	If $InputData = 0x1 Or $InputData = 0x17 Or $InputData = 0x18 Or Not Mod($InputData+0x10,0x28) Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_LcnsToFollow($InputData)
	If $InputData <> 0x0 And $InputData <> 0x1 Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func _SanityCheck_RecordOffsetInMft($InputData)
	If $InputData < 0xFFFF Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_AttributeOffset($InputData)
	If $InputData < 0xFFFF Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func _SanityCheck_MftClusterIndex($InputData)
	;Not posible to validate
	Return 1
EndFunc

Func _SanityCheck_TargetVcn($InputData)
	;Not posible to validate
	Return 1
EndFunc

Func _SanityCheck_TargetLcn($InputData)
	;Not posible to validate
	Return 1
EndFunc

Func _CheckAndRepairTransactionHeader2($InputData)
	Local $StartOffset=1, $InputDataSize = StringLen($InputData)/2, $SanityCheckSuccess=0

	Do
		_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
		$FragmentLsn1 = StringMid($InputData, $StartOffset, 16)
;		_DumpOutput("$FragmentLsn1: " & $FragmentLsn1 & @CRLF)
		$FragmentLsn1 = Dec(_SwapEndian($FragmentLsn1),2)
		$FragmentLsn2 = StringMid($InputData, $StartOffset + 16, 16)
		$FragmentLsn2 = Dec(_SwapEndian($FragmentLsn2),2)
		$FragmentLsn3 = StringMid($InputData, $StartOffset + 32, 16)
		$FragmentLsn3 = Dec(_SwapEndian($FragmentLsn3),2)
		$FragmentClientDataLength = StringMid($InputData, $StartOffset + 48, 8)
		$FragmentClientDataLength = Dec(_SwapEndian($FragmentClientDataLength),2)
		$FragmentClientIndex = StringMid($InputData, $StartOffset + 56, 8)
		$FragmentClientIndex = Dec(_SwapEndian($FragmentClientIndex),2)
;		_DumpOutput("$FragmentClientIndex:" & $FragmentClientIndex & @CRLF)
		$FragmentRecordType = StringMid($InputData, $StartOffset + 64, 8)
		$FragmentRecordType = Dec(_SwapEndian($FragmentRecordType),2)
		$FragmentTransactionId = StringMid($InputData, $StartOffset + 72, 8)
		$FragmentTransactionId = Dec(_SwapEndian($FragmentTransactionId),2)
		$FragmentFlags = StringMid($InputData, $StartOffset + 80, 4)
		$FragmentFlags = Dec(_SwapEndian($FragmentFlags),2)
		;Allignment 6 bytes
		$FragmentRedoOp = StringMid($InputData, $StartOffset + 96, 4)
		$FragmentRedoOp = Dec(_SwapEndian($FragmentRedoOp),2)
		$FragmentUndoOp = StringMid($InputData, $StartOffset + 100, 4)
		$FragmentUndoOp = Dec(_SwapEndian($FragmentUndoOp),2)
		$FragmentRedoOffset = StringMid($InputData, $StartOffset + 104, 4)
		$FragmentRedoOffset = Dec(_SwapEndian($FragmentRedoOffset),2)
		$FragmentRedoLength = StringMid($InputData, $StartOffset + 108, 4)
		$FragmentRedoLength = Dec(_SwapEndian($FragmentRedoLength),2)
		$FragmentUndoOffset = StringMid($InputData, $StartOffset + 112, 4)
		$FragmentUndoOffset = Dec(_SwapEndian($FragmentUndoOffset),2)
		$FragmentUndoLength = StringMid($InputData, $StartOffset + 116, 4)
		$FragmentUndoLength = Dec(_SwapEndian($FragmentUndoLength),2)
		$FragmentTargetAttribute = StringMid($InputData, $StartOffset + 120, 4)
;		_DumpOutput("$FragmentTargetAttribute:" & $FragmentTargetAttribute & @CRLF)
		$FragmentTargetAttribute = Dec(_SwapEndian($FragmentTargetAttribute),2)
		$FragmentLcnsToFollow = StringMid($InputData, $StartOffset + 124, 4)
		$FragmentLcnsToFollow = Dec(_SwapEndian($FragmentLcnsToFollow),2)
		$FragmentRecordOffsetInMft = StringMid($InputData, $StartOffset + 128, 4)
		$FragmentRecordOffsetInMft = Dec(_SwapEndian($FragmentRecordOffsetInMft),2)
		$FragmentAttributeOffset = StringMid($InputData, $StartOffset + 132, 4)
		$FragmentAttributeOffset = Dec(_SwapEndian($FragmentAttributeOffset),2)
		$FragmentMftClusterIndex = StringMid($InputData, $StartOffset + 136, 4)
		$FragmentMftClusterIndex = Dec(_SwapEndian($FragmentMftClusterIndex),2)
		$FragmentTargetVcn = StringMid($InputData, $StartOffset + 140, 8)
		$FragmentTargetVcn = Dec(_SwapEndian($FragmentTargetVcn),2)
		$FragmentTargetLcn = StringMid($InputData, $StartOffset + 148, 8)
		$FragmentTargetLcn = Dec(_SwapEndian($FragmentTargetLcn),2)
		;Do the tests
		Select
			Case _SanityCheck_LSN($FragmentLsn1)=0
				_DumpOutput("Error in _SanityCheck_LSN($FragmentLsn1)" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_LSN($FragmentLsn2)=0
				_DumpOutput("Error in _SanityCheck_LSN($FragmentLsn2)" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_LSN($FragmentLsn3)=0
				_DumpOutput("Error in _SanityCheck_LSN($FragmentLsn3)" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_ClientDataLength($FragmentClientDataLength)=0
				_DumpOutput("Error in _SanityCheck_ClientDataLength()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_ClientIndex($FragmentClientIndex)=0
				_DumpOutput("Error in _SanityCheck_ClientIndex()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_RecordType($FragmentRecordType)=0
				_DumpOutput("Error in _SanityCheck_RecordType()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_TransactionId($FragmentTransactionId)=0
				_DumpOutput("Error in _SanityCheck_TransactionId()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_Flags($FragmentFlags)=0
				_DumpOutput("Error in _SanityCheck_Flags()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_UndoRedoOpCode($FragmentRedoOp)=0
				_DumpOutput("Error in _SanityCheck_UndoRedoOpCode($FragmentRedoOp)" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_UndoRedoOpCode($FragmentUndoOp)=0
				_DumpOutput("Error in _SanityCheck_UndoRedoOpCode($FragmentUndoOp)" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_RedoOffset($FragmentRedoOffset)=0
				_DumpOutput("Error in _SanityCheck_RedoOffset()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_UndoOffset($FragmentUndoOffset)=0
				_DumpOutput("Error in _SanityCheck_UndoOffset()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_TargetAttribute($FragmentTargetAttribute)=0
				_DumpOutput("Error in _SanityCheck_TargetAttribute()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_LcnsToFollow($FragmentLcnsToFollow)=0
				_DumpOutput("Error in _SanityCheck_LcnsToFollow()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_RecordOffsetInMft($FragmentRecordOffsetInMft)=0
				_DumpOutput("Error in _SanityCheck_RecordOffsetInMft()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityCheck_AttributeOffset($FragmentAttributeOffset)=0
				_DumpOutput("Error in _SanityCheck_AttributeOffset()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityTest1($FragmentRedoOp,$FragmentUndoOp)=0
				_DumpOutput("Error in _SanityTest1()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case _SanityTest2($FragmentLsn1,$FragmentLsn2,$FragmentLsn3)=0
				_DumpOutput("Error in _SanityTest2()" & @CRLF)
				$StartOffset += 16
				ContinueLoop
			Case Else
				$SanityCheckSuccess=1
				_DumpOutput("_SanityCheckTransactionHeader: Validation success at $StartOffset = " & $StartOffset & @CRLF)
				_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
				ExitLoop
;				$StartOffset += 96 + ($FragmentClientDataLength*2)
		EndSelect


		$StartOffset += 16 ;Since transactions are always aligned to 8 bytes
	Until $StartOffset >= $InputDataSize
	_DumpOutput("_SanityCheckTransactionHeader: Validation success at $StartOffset = " & $StartOffset & @CRLF)
	_DumpOutput("$StartOffset = 0x" & Hex(Int(($StartOffset-1)/2)) & @CRLF)
	If Not $SanityCheckSuccess Then Return SetError(1,0,0)
	Return StringMid($InputData,$StartOffset,96 + ($FragmentClientDataLength*2))
EndFunc

Func _SelectFragment()
	_DisplayInfo("Not yet fully implemented" & @CRLF)
	Return
	;Not sure if this will ever be activated. Needs further codechange.
	$FragmentFile = FileOpenDialog("Select Fragment",@ScriptDir,"All (*.*)")
	If @error Then
		_DisplayInfo("Error getting Fragment: " & $FragmentFile & @CRLF)
		GUICtrlSetData($FragmentField,"Error getting Fragment")
		Return
	Else
;		_DisplayInfo("Selected Fragment: " & $FragmentFile & @CRLF)
		GUICtrlSetData($FragmentField,$FragmentFile)
	EndIf
	$hFragment = FileOpen($FragmentFile,16)
	$FragmentData = FileRead($hFragment)
	_CheckFragment(StringMid($FragmentData,3))
EndFunc

Func _CheckFragment($InputData)

	_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	$result = _CheckAndRepairTransactionHeader($InputData)
	If @error Then
		_DumpOutput("Error in sanity check of data" & @CRLF)
	Else
		_DumpOutput("Success verifying data:" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$result) & @CRLF)
	EndIf
EndFunc

Func _Decode_Attribute_List($InputData)

EndFunc

;Func _DecodeAttrList($TargetFile, $AttrList)
Func _DecodeAttrList($AttrList,$IsRedo)
	Local $offset, $LocalAttribID, $LocalName, $ALRecordLength, $ALNameLength, $ALNameOffset
	$offset=0
	$list=$AttrList
	$str=";BaseRef="
	While StringLen($list) > $offset*2
		$type=StringMid($List, ($offset*2)+1, 4)
		$type = _ResolveAttributeType($type)
		$ALRecordLength = Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
		$ALNameLength = Dec(_SwapEndian(StringMid($List, $offset*2 + 13, 2)))
		$ALNameOffset = Dec(_SwapEndian(StringMid($List, $offset*2 + 15, 2)))
		$TestVCN = Dec(_SwapEndian(StringMid($List, $offset*2 + 17, 16)))
		$ref=Dec(_SwapEndian(StringMid($List, $offset*2 + 33, 8)))
		$LocalAttribID = "0x" & StringMid($List, $offset*2 + 49, 2) & StringMid($List, $offset*2 + 51, 2)
		If $ALNameLength > 0 Then
			$LocalName = StringMid($List, $offset*2 + 53, $ALNameLength*2*2)
			$LocalName = BinaryToString("0x"&$LocalName,2)
		Else
			$LocalName = ""
		EndIf
		If Not StringInStr($str, $ref) Then $str &= $ref & "-"
		If $ALRecordLength=0 Or $type="UNKNOWN" Then ExitLoop
		$EntryOffset = "0x"&Hex(Int($offset),8)
		FileWriteLine($LogFileAttributeListCsv, $this_lsn&$de&$EntryOffset&$de&$IsRedo&$de&$type&$de&"0x"&Hex($TestVCN,8)&$de&$ref&$de&$LocalName&$de&$LocalAttribID&@crlf)
		$offset += Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
	WEnd
EndFunc

Func _WriteCSVHeaderAttributeList()
	$AttributeList_Csv_Header = "lf_LSN"&$de&"ListOffset"&$de&"IsRedoOp"&$de&"AttributeType"&$de&"VCN"&$de&"BaseMFTRef"&$de&"Name"&$de&"AttributeId"
	FileWriteLine($LogFileAttributeListCsv, $AttributeList_Csv_Header & @CRLF)
EndFunc

Func _Decode_Quota_Q_SingleEntry($InputData,$IsRedo)
	Local $Counter=1
	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	If $VerboseOn Then
		_DumpOutput("_Decode_Quota_Q_SingleEntry():" & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	EndIf

	$DataOffset = "-"
	$DataSize = "-"
	$IndexEntrySize = "-"
	$IndexKeySize = "-"
	$Flags = "-"
	$OwnerId = "-"

	$Version = StringMid($InputData, $StartOffset, 8)
	$Version = "0x" & _SwapEndian($Version)

	$Flags2 = StringMid($InputData, $StartOffset + 8, 8)
	$Flags2 = _SwapEndian($Flags2)
	$Flags2Text = _Decode_QuotaFlags("0x"&$Flags2)

	$BytesUsed = StringMid($InputData, $StartOffset + 16, 16)
	$BytesUsed = Dec(_SwapEndian($BytesUsed),2)

	Select
		Case $InputDataSize = 96
			$ChangeTime = StringMid($InputData, $StartOffset + 32, 16)
			$ChangeTime = _SwapEndian($ChangeTime)
			$ChangeTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ChangeTime)
			$ChangeTime = _WinTime_UTCFileTimeFormat(Dec($ChangeTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$ChangeTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-4)
				$ChangeTime_Precision = StringRight($ChangeTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$ChangeTime = $ChangeTime & ":" & _FillZero(StringRight($ChangeTime_tmp, 4))
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-9)
				$ChangeTime_Precision = StringRight($ChangeTime,8)
			Else
				$ChangeTime_Core = $ChangeTime
			EndIf
			If $IsRedo Then $TextInformation &= ";ChangeTime=" & $ChangeTime

			$WarningLimit = StringMid($InputData, $StartOffset + 48, 16)
			$WarningLimit = "0x" & _SwapEndian($WarningLimit)

			$HardLimit = StringMid($InputData, $StartOffset + 64, 16)
			$HardLimit = "0x" & _SwapEndian($HardLimit)


			$ExceededTime = StringMid($InputData, $StartOffset + 80, 16)

			If $ExceededTime <> "0000000000000000" Then
				$ExceededTime = _SwapEndian($ExceededTime)
				$ExceededTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ExceededTime)
				$ExceededTime = _WinTime_UTCFileTimeFormat(Dec($ExceededTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
				If @error Then
					$ExceededTime = "-"
				ElseIf $TimestampPrecision = 2 Then
					$ExceededTime_Core = StringMid($ExceededTime,1,StringLen($ExceededTime)-4)
					$ExceededTime_Precision = StringRight($ExceededTime,3)
				ElseIf $TimestampPrecision = 3 Then
					$ExceededTime = $ExceededTime & ":" & _FillZero(StringRight($ExceededTime_tmp, 4))
					$ExceededTime_Core = StringMid($ExceededTime,1,StringLen($ExceededTime)-9)
					$ExceededTime_Precision = StringRight($ExceededTime,8)
				Else
					$ExceededTime_Core = $ExceededTime
				EndIf
			Else
				$ExceededTime = 0
			EndIf
		Case $InputDataSize = 80
			$ChangeTime = StringMid($InputData, $StartOffset + 32, 16)
			$ChangeTime = _SwapEndian($ChangeTime)
			$ChangeTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ChangeTime)
			$ChangeTime = _WinTime_UTCFileTimeFormat(Dec($ChangeTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$ChangeTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-4)
				$ChangeTime_Precision = StringRight($ChangeTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$ChangeTime = $ChangeTime & ":" & _FillZero(StringRight($ChangeTime_tmp, 4))
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-9)
				$ChangeTime_Precision = StringRight($ChangeTime,8)
			Else
				$ChangeTime_Core = $ChangeTime
			EndIf
			If $IsRedo Then $TextInformation &= ";ChangeTime=" & $ChangeTime

			$WarningLimit = StringMid($InputData, $StartOffset + 48, 16)
			$WarningLimit = "0x" & _SwapEndian($WarningLimit)

			$HardLimit = StringMid($InputData, $StartOffset + 64, 16)
			$HardLimit = "0x" & _SwapEndian($HardLimit)

			$ExceededTime = "-"
		Case $InputDataSize = 64
			$ChangeTime = StringMid($InputData, $StartOffset + 32, 16)
			$ChangeTime = _SwapEndian($ChangeTime)
			$ChangeTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ChangeTime)
			$ChangeTime = _WinTime_UTCFileTimeFormat(Dec($ChangeTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$ChangeTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-4)
				$ChangeTime_Precision = StringRight($ChangeTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$ChangeTime = $ChangeTime & ":" & _FillZero(StringRight($ChangeTime_tmp, 4))
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-9)
				$ChangeTime_Precision = StringRight($ChangeTime,8)
			Else
				$ChangeTime_Core = $ChangeTime
			EndIf
			If $IsRedo Then $TextInformation &= ";ChangeTime=" & $ChangeTime

			$WarningLimit = StringMid($InputData, $StartOffset + 48, 16)
			$WarningLimit = "0x" & _SwapEndian($WarningLimit)

			$HardLimit = "-"
			$ExceededTime = "-"
		Case $InputDataSize = 48
			$ChangeTime = StringMid($InputData, $StartOffset + 32, 16)
			$ChangeTime = _SwapEndian($ChangeTime)
			$ChangeTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $ChangeTime)
			$ChangeTime = _WinTime_UTCFileTimeFormat(Dec($ChangeTime,2) - $tDelta, $DateTimeFormat, $TimestampPrecision)
			If @error Then
				$ChangeTime = "-"
			ElseIf $TimestampPrecision = 2 Then
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-4)
				$ChangeTime_Precision = StringRight($ChangeTime,3)
			ElseIf $TimestampPrecision = 3 Then
				$ChangeTime = $ChangeTime & ":" & _FillZero(StringRight($ChangeTime_tmp, 4))
				$ChangeTime_Core = StringMid($ChangeTime,1,StringLen($ChangeTime)-9)
				$ChangeTime_Precision = StringRight($ChangeTime,8)
			Else
				$ChangeTime_Core = $ChangeTime
			EndIf
			If $IsRedo Then $TextInformation &= ";ChangeTime=" & $ChangeTime

			$WarningLimit = "-"
			$HardLimit = "-"
			$ExceededTime = "-"
		Case Else
			$ChangeTime = "-"
			$WarningLimit = "-"
			$HardLimit = "-"
			$ExceededTime = "-"
	EndSelect

	$SID = "-"

	If $VerboseOn Then
		_DumpOutput(@CRLF)
		_DumpOutput("$DataOffset: " & $DataOffset & @CRLF)
		_DumpOutput("$DataSize: " & $DataSize & @CRLF)
		_DumpOutput("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
		_DumpOutput("$IndexKeySize: " & $IndexKeySize & @CRLF)
		_DumpOutput("$Flags: " & $Flags & @CRLF)
		_DumpOutput("$OwnerId: " & $OwnerId & @CRLF)
		_DumpOutput("$Version: " & $Version & @CRLF)
		_DumpOutput("$Flags2Text: " & $Flags2Text & @CRLF)
		_DumpOutput("$BytesUsed: " & $BytesUsed & @CRLF)
		_DumpOutput("$ChangeTime: " & $ChangeTime & @CRLF)
		_DumpOutput("$WarningLimit: " & $WarningLimit & @CRLF)
		_DumpOutput("$HardLimit: " & $HardLimit & @CRLF)
		_DumpOutput("$ExceededTime: " & $ExceededTime & @CRLF)
		_DumpOutput("$SID: " & $SID & @CRLF)
	EndIf

	FileWriteLine($LogFileQuotaQCsv, $RecordOffset&$de&$this_lsn&$de&$IndexEntrySize&$de&$IndexKeySize&$de&$Flags&$de&$OwnerId&$de&$Version&$de&$Flags2Text&$de&$BytesUsed&$de&$ChangeTime&$de&$WarningLimit&$de&$HardLimit&$de&$ExceededTime&$de&$SID&$de&$IsRedo&@crlf)
EndFunc

Func _GetReparseType($ReparseType)
	;http://msdn.microsoft.com/en-us/library/dd541667(v=prot.10).aspx
	;http://msdn.microsoft.com/en-us/library/windows/desktop/aa365740(v=vs.85).aspx
	Select
		Case $ReparseType = '0x00000000'
			Return 'ZERO'
		Case $ReparseType = '0x80000005'
			Return 'DRIVER_EXTENDER'
		Case $ReparseType = '0x80000006'
			Return 'HSM2'
		Case $ReparseType = '0x80000007'
			Return 'SIS'
		Case $ReparseType = '0x80000008'
			Return 'WIM'
		Case $ReparseType = '0x80000009'
			Return 'CSV'
		Case $ReparseType = '0x8000000A'
			Return 'DFS'
		Case $ReparseType = '0x8000000B'
			Return 'FILTER_MANAGER'
		Case $ReparseType = '0x80000012'
			Return 'DFSR'
		Case $ReparseType = '0x80000013'
			Return 'DEDUP'
		Case $ReparseType = '0x80000014'
			Return 'NFS'
		Case $ReparseType = '0xA0000003'
			Return 'MOUNT_POINT'
		Case $ReparseType = '0xA000000C'
			Return 'SYMLINK'
		Case $ReparseType = '0xC0000004'
			Return 'HSM'
		Case $ReparseType = '0x80000015'
			Return 'FILE_PLACEHOLDER'
		Case $ReparseType = '0x80000017'
			Return 'WOF'
		Case Else
			Return 'UNKNOWN(' & $ReparseType & ')'
	EndSelect
EndFunc

Func _ExtractResidentUpdates($InputData,$IsRedo)
	If $IsRedo Then
		$OutResident = $ParserOutDir&"\ResidentExtract\MFT("&$PredictedRefNumber&")_0x"&Hex(Int($record_offset_in_mft),4)&"_0x"&Hex(Int($attribute_offset),4)&"_LSN("&$this_lsn&")redo.bin"
	Else
		$OutResident = $ParserOutDir&"\ResidentExtract\MFT("&$PredictedRefNumber&")_0x"&Hex(Int($record_offset_in_mft),4)&"_0x"&Hex(Int($attribute_offset),4)&"_LSN("&$this_lsn&")undo.bin"
	EndIf
	$hFileOutResident = FileOpen($OutResident,18)
	If $VerboseOn Then
		_DumpOutput("_ExtractResidentUpdates(): " & @CRLF)
		_DumpOutput("$OutResident: " & $OutResident & @CRLF)
		_DumpOutput("$hFileOutResident: " & $hFileOutResident & @CRLF)
	EndIf
	FileWrite($hFileOutResident,"0x"&$InputData)
	FileClose($hFileOutResident)
EndFunc

Func _Get_DataName($MFTEntry)
	Local $DT_NameLength, $DT_NameRelativeOffset, $DT_NameSpace, $DT_Name, $DT_Offset=1
	$DT_NameLength = Dec(StringMid($MFTEntry, $DT_Offset + 18, 2))
	$DT_NameRelativeOffset = StringMid($MFTEntry, $DT_Offset + 20, 4)
	$DT_NameRelativeOffset = Dec(_SwapEndian($DT_NameRelativeOffset),2)
	If $DT_NameLength > 0 Then
		$DT_NameSpace = $DT_NameLength - 1
		$DT_Name = StringMid($MFTEntry, $DT_Offset + ($DT_NameRelativeOffset * 2), $DT_NameLength*4)
		$DT_Name = BinaryToString("0x"&$DT_Name,2)
		$DT_Name = StringReplace($DT_Name,$de,$CharReplacement)
	EndIf
	If $VerboseOn Then
		_DumpOutput("_Get_DataName():" & @CRLF)
		_DumpOutput("$DT_NameLength: " & $DT_NameLength & @CRLF)
		_DumpOutput("$DT_NameRelativeOffset: " & $DT_NameRelativeOffset & @CRLF)
		_DumpOutput("$DT_Name: " & $DT_Name & @CRLF)
	EndIf
	Return $DT_Name
EndFunc

Func _WriteCSVHeaderFileNames()
	$FileNames_Csv_Header = "Offset"&$de&"lf_LSN"&$de&"MftRef"&$de&"MftRefSeqNo"&$de&"FileName"
	FileWriteLine($LogFileFileNamesCsv, $FileNames_Csv_Header & @CRLF)
EndFunc

Func _Decode_TXF_DATA($InputData,$IsRedo)
	Local $Counter=1, $replacechars = ""

	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	If $VerboseOn Then
		_DumpOutput("_Decode_TXF_DATA():" & @CRLF)
		_DumpOutput("$this_lsn: " & $this_lsn & @CRLF)
		_DumpOutput("$InputDataSize: " & $InputDataSize/2 & @CRLF)
		_DumpOutput(_HexEncode("0x"&$InputData) & @CRLF)
	EndIf
	$TextInformation &= ";See LogFile_TxfData.csv"

	If Mod($InputDataSize,16) Then
		While 1
			$InputData = "0" & $InputData
			$Counter += 1
			$replacechars &= "-"
			If Mod(StringLen($InputData),16) = 0 Then ExitLoop
		WEnd
	EndIf

;	If $Counter > 1 Then $TextInformation &= ";Partial update"
	If $InputDataSize < 112 Then $TextInformation &= ";Partial update"

	Select
		Case $InputDataSize < 113 And $InputDataSize > 96

			$MftRef_RM_Root = StringMid($InputData, $StartOffset, 12)
			$MftRef_RM_Root = Dec(_SwapEndian($MftRef_RM_Root),2)
			$MftRefSeqNo_RM_Root = StringMid($InputData, $StartOffset + 12, 4)
			$MftRefSeqNo_RM_Root = Dec(_SwapEndian($MftRefSeqNo_RM_Root),2)

			$UsnIndex = StringMid($InputData, $StartOffset + 16, 16)
			$UsnIndex = "0x"&_SwapEndian($UsnIndex)

			;Increments with 1. The last TxfFileId is referenced in $Tops standard $DATA stream at offset 0x28
			$TxfFileId = StringMid($InputData, $StartOffset + 32, 16)
			$TxfFileId = "0x"&_SwapEndian($TxfFileId)

			;Offset into $TxfLogContainer00000000000000000001
			$LsnUserData = StringMid($InputData, $StartOffset + 48, 16)
			$LsnUserData = "0x"&_SwapEndian($LsnUserData)

			;Offset into $TxfLogContainer00000000000000000001
			$LsnNtfsMetadata = StringMid($InputData, $StartOffset + 64, 16)
			$LsnNtfsMetadata = "0x"&_SwapEndian($LsnNtfsMetadata)

			$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
			$LsnDirectoryIndex = "0x"&_SwapEndian($LsnDirectoryIndex)

			$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
			$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)

		Case $InputDataSize < 97 And $InputDataSize > 80
			$StartOffset = -15

			$MftRef_RM_Root = "-"
			$MftRefSeqNo_RM_Root = "-"

			$UsnIndex = StringMid($InputData, $StartOffset + 16, 16)
			$UsnIndex = _SwapEndian($UsnIndex)
			$UsnIndex = StringMid($UsnIndex,1,StringLen($UsnIndex)-($Counter-1)) & $replacechars
			$UsnIndex = "0x" & $UsnIndex

			$TxfFileId = StringMid($InputData, $StartOffset + 32, 16)
			$TxfFileId = "0x"&_SwapEndian($TxfFileId)

			$LsnUserData = StringMid($InputData, $StartOffset + 48, 16)
			$LsnUserData = "0x"&_SwapEndian($LsnUserData)

			$LsnNtfsMetadata = StringMid($InputData, $StartOffset + 64, 16)
			$LsnNtfsMetadata = "0x"&_SwapEndian($LsnNtfsMetadata)

			$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
			$LsnDirectoryIndex = "0x"&_SwapEndian($LsnDirectoryIndex)

			$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
			$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)

		Case $InputDataSize < 81 And $InputDataSize > 64
			$StartOffset = -31

			$MftRef_RM_Root = "-"
			$MftRefSeqNo_RM_Root = "-"
			$UsnIndex = "-"

			$TxfFileId = StringMid($InputData, $StartOffset + 32, 16)
			$TxfFileId = _SwapEndian($TxfFileId)
			$TxfFileId = StringMid($TxfFileId,1,StringLen($TxfFileId)-($Counter-1)) & $replacechars
			$TxfFileId = "0x" & $TxfFileId

			$LsnUserData = StringMid($InputData, $StartOffset + 48, 16)
			$LsnUserData = "0x"&_SwapEndian($LsnUserData)

			$LsnNtfsMetadata = StringMid($InputData, $StartOffset + 64, 16)
			$LsnNtfsMetadata = "0x"&_SwapEndian($LsnNtfsMetadata)

			$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
			$LsnDirectoryIndex = "0x"&_SwapEndian($LsnDirectoryIndex)

			$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
			$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)

		Case $InputDataSize < 65 And $InputDataSize > 48
			$StartOffset = -47

			$MftRef_RM_Root = "-"
			$MftRefSeqNo_RM_Root = "-"
			$UsnIndex = "-"
			$TxfFileId = "-"

			$LsnUserData = StringMid($InputData, $StartOffset + 48, 16)
			$LsnUserData = _SwapEndian($LsnUserData)
			$LsnUserData = StringMid($LsnUserData,1,StringLen($LsnUserData)-($Counter-1)) & $replacechars
			$LsnUserData = "0x" & $LsnUserData

			$LsnNtfsMetadata = StringMid($InputData, $StartOffset + 64, 16)
			$LsnNtfsMetadata = "0x"&_SwapEndian($LsnNtfsMetadata)

			$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
			$LsnDirectoryIndex = "0x"&_SwapEndian($LsnDirectoryIndex)

			$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
			$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)

		Case $InputDataSize < 49 And $InputDataSize > 32
			$StartOffset = -63

			$MftRef_RM_Root = "-"
			$MftRefSeqNo_RM_Root = "-"
			$UsnIndex = "-"
			$TxfFileId = "-"
			$LsnUserData = "-"

			$LsnNtfsMetadata = StringMid($InputData, $StartOffset + 64, 16)
			$LsnNtfsMetadata = _SwapEndian($LsnNtfsMetadata)
			$LsnNtfsMetadata = StringMid($LsnNtfsMetadata,1,StringLen($LsnNtfsMetadata)-($Counter-1)) & $replacechars
			$LsnNtfsMetadata = "0x" & $LsnNtfsMetadata

			$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
			$LsnDirectoryIndex = "0x"&_SwapEndian($LsnDirectoryIndex)

			$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
			$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)

		Case $InputDataSize < 33 And $InputDataSize > 16
			$StartOffset = -79

			$MftRef_RM_Root = "-"
			$MftRefSeqNo_RM_Root = "-"
			$UsnIndex = "-"
			$TxfFileId = "-"
			$LsnUserData = "-"
			$LsnNtfsMetadata = "-"

			$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
			$LsnDirectoryIndex = _SwapEndian($LsnDirectoryIndex)
			$LsnDirectoryIndex = StringMid($LsnDirectoryIndex,1,StringLen($LsnDirectoryIndex)-($Counter-1)) & $replacechars
			$LsnDirectoryIndex = "0x" & $LsnDirectoryIndex

			$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
			$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)


		Case Else
			$MftRef_RM_Root = "-"
			$MftRefSeqNo_RM_Root = "-"
			$UsnIndex = "-"
			$TxfFileId = "-"
			$LsnUserData = "-"
			$LsnNtfsMetadata = "-"
			$LsnDirectoryIndex = "-"
			$UnknownFlag = "-"

	EndSelect

	If $VerboseOn Then
		_DumpOutput("$MftRef_RM_Root: " & $MftRef_RM_Root & @CRLF)
		_DumpOutput("$MftRefSeqNo_RM_Root: " & $MftRefSeqNo_RM_Root & @CRLF)
		_DumpOutput("$UsnIndex: " & $UsnIndex & @CRLF)
		_DumpOutput("$TxfFileId: " & $TxfFileId & @CRLF)
		_DumpOutput("$LsnUserData: " & $LsnUserData & @CRLF)
		_DumpOutput("$LsnNtfsMetadata: " & $LsnNtfsMetadata & @CRLF)
		_DumpOutput("$LsnDirectoryIndex: " & $LsnDirectoryIndex & @CRLF)
	EndIf
	FileWriteLine($LogFileTxfDataCsv, $RecordOffset&$de&$PredictedRefNumber&$de&$this_lsn&$de&$MftRef_RM_Root&$de&$MftRefSeqNo_RM_Root&$de&$UsnIndex&$de&$TxfFileId&$de&$LsnUserData&$de&$LsnNtfsMetadata&$de&$LsnDirectoryIndex&$de&$UnknownFlag)

EndFunc

Func _WriteCSVHeaderTxfData()
	$TxfData_Csv_Header = "Offset"&$de&"MftRef"&$de&"lf_LSN"&$de&"MftRef_RM_Root"&$de&"MftRefSeqNo_RM_Root"&$de&"UsnIndex"&$de&"TxfFileId"&$de&"LsnUserData"&$de&"LsnNtfsMetadata"&$de&"LsnDirectoryIndex"&$de&"UnknownFlag"
	FileWriteLine($LogFileTxfDataCsv, $TxfData_Csv_Header & @CRLF)
EndFunc

Func _ExtractResidentUpdatesEa($InputData,$EaName)
	$OutResident = $ParserOutDir&"\ResidentExtract\MFT("&$PredictedRefNumber&")_EaName("&$EaName&")_LSN("&$this_lsn&").bin"
	$hFileOutResident = FileOpen($OutResident,18)
	If $VerboseOn Then
		_DumpOutput("_ExtractResidentUpdates(): " & @CRLF)
		_DumpOutput("$OutResident: " & $OutResident & @CRLF)
		_DumpOutput("$hFileOutResident: " & $hFileOutResident & @CRLF)
	EndIf
	FileWrite($hFileOutResident,"0x"&$InputData)
	FileClose($hFileOutResident)
EndFunc
#cs
Global $EaNonResidentArray[1][9]
$EaNonResidentArray[0][0] = "MFTRef"
$EaNonResidentArray[0][1] = "EntrySize"
$EaNonResidentArray[0][2] = "EntryName"
$EaNonResidentArray[0][3] = "Written"
$EaNonResidentArray[0][4] = "LSN"
$EaNonResidentArray[0][5] = "target_attribute"
$EaNonResidentArray[0][6] = "MftClusterIndex"
$EaNonResidentArray[0][7] = "target_vcn"
$EaNonResidentArray[0][8] = "OutputFileName"
#ce
Func _Get_Ea_NonResident($Entry)
	Local $LocalAttributeOffset=1,$OffsetToNextEa=0,$EaName,$EaFlags,$EaNameLength,$EaValueLength,$EaCounter=0,$EaOutputFilename,$BytesProcessed=0,$DoneParsing=0
	If $VerboseOn Then
		_DumpOutput("_Get_Ea_NonResident()" & @crlf)
		_DumpOutput("$this_lsn: " & $this_lsn & @crlf)
		_DumpOutput("$RealMftRef: " & $RealMftRef & @crlf)
		_DumpOutput("$target_attribute: " & $target_attribute & @crlf)
		_DumpOutput("$MftClusterIndex: " & $MftClusterIndex & @crlf)
		_DumpOutput("$target_vcn: " & $target_vcn & @crlf)
		_DumpOutput(_HexEncode("0x"&$Entry) & @crlf)
	EndIf
	$StringLengthInput = StringLen($Entry)
	$BinaryLengthInput = $StringLengthInput/2
	$FoundInTable = _ArraySearch($EaNonResidentArray,$RealMftRef,0,0,0,2,0,0)
	If $FoundInTable > 0 Then ;We have an existing entry for a pair that is not completed writing to disk
		If $target_attribute = $EaNonResidentArray[$FoundInTable][5] And $EaNonResidentArray[$FoundInTable][1] <> $EaNonResidentArray[$FoundInTable][3] Then ;Match
			If $target_vcn - $EaNonResidentArray[$FoundInTable][7] <> 0 And $target_vcn - $EaNonResidentArray[$FoundInTable][7] <> 1 Then
				_DumpOutput("Error: target_vcn was not as expected." & @crlf)
			EndIf
			$EaCounter += 1
			$EaName = $EaNonResidentArray[$FoundInTable][2]
			$TextInformation &= ";EaName("&$EaCounter&")="&$EaName
			$EaOutputFilename = $EaNonResidentArray[$FoundInTable][8]
			If $EaNonResidentArray[$FoundInTable][1] - $EaNonResidentArray[$FoundInTable][3] >= 4096 Then ;Write chunk (EntrySize - Written >= 4096)
				$BytesToWrite = $BinaryLengthInput
				$hFileOutNonResident = FileOpen($EaOutputFilename,17)
				If Not $hFileOutNonResident Then _DumpOutput("Error: FileOpen failed with @error: " & @error & @crlf)
				FileSetPos($hFileOutNonResident, 0,  $FILE_END)
				FileWrite($hFileOutNonResident,"0x"&$Entry)
				FileClose($hFileOutNonResident)
				$EaNonResidentArray[$FoundInTable][3] += $BytesToWrite
				$EaNonResidentArray[$FoundInTable][6] = $MftClusterIndex
				$EaNonResidentArray[$FoundInTable][7] = $target_vcn
				If $BinaryLengthInput < 4096 Then ;Something wrong: not enough data
					_DumpOutput("Error: Chunk contained less data than expected." & @crlf)
				EndIf
				Return
			ElseIf $EaNonResidentArray[$FoundInTable][1] - $EaNonResidentArray[$FoundInTable][3] < 4096 Then ;write chunk + and update array for next pair
				$BytesToWrite = $EaNonResidentArray[$FoundInTable][1] - $EaNonResidentArray[$FoundInTable][3]
				$hFileOutNonResident = FileOpen($EaOutputFilename,17)
				If Not $hFileOutNonResident Then _DumpOutput("Error: FileOpen failed with @error: " & @error & @crlf)
				FileSetPos($hFileOutNonResident, 0,  $FILE_END)
				FileWrite($hFileOutNonResident,"0x"&StringMid($Entry,$LocalAttributeOffset,($BytesToWrite*2)-4))
				FileClose($hFileOutNonResident)
				$EaNonResidentArray[$FoundInTable][3] += $BytesToWrite
				If $EaNonResidentArray[$FoundInTable][1] - $EaNonResidentArray[$FoundInTable][3] = $BinaryLengthInput Then ;Finished writing everything.
					Return
				EndIf
				$Entry = StringMid($Entry,$LocalAttributeOffset+($BytesToWrite*2)-2)
				$StringLengthInput = StringLen($Entry)
				$BinaryLengthInput = $StringLengthInput/2
			EndIf
		Else ;New $EA for same MftRef. Delete existing one?? Slack, lower lsn etc..
;			_DumpOutput("New $EA for same MftRef." & @crlf)
		EndIf
	Else ;New entry, test for valid header
		If $target_vcn <> 0 And $MftClusterIndex <> 0  Then
			_DumpOutput("Error: New entry but $target_vcn=" & $target_vcn & " and $MftClusterIndex=" & $MftClusterIndex & @crlf)
		EndIf
	EndIf

	Do
		$LocalAttributeOffset += ($OffsetToNextEa*2)
		If $LocalAttributeOffset >= $StringLengthInput Then ExitLoop
		$EaCounter+=1
		$OffsetToNextEa = StringMid($Entry,$LocalAttributeOffset,8)
		$OffsetToNextEa = Dec(_SwapEndian($OffsetToNextEa),2)
		If $OffsetToNextEa > 65535 Then Return SetError(1,0,"$OffsetToNextEa="&$OffsetToNextEa)
		$EaFlags = Dec(StringMid($Entry,$LocalAttributeOffset+8,2))
		$EaNameLength = Dec(StringMid($Entry,$LocalAttributeOffset+10,2))
		$EaValueLength = StringMid($Entry,$LocalAttributeOffset+12,4)
		$EaValueLength = Dec(_SwapEndian($EaValueLength))
		If $EaValueLength >= $OffsetToNextEa Then Return SetError(1,0,"($EaValueLength >= $OffsetToNextEa)="&($EaValueLength >= $OffsetToNextEa)&"|"&$EaValueLength&"-"&$OffsetToNextEa)
		$EaName = StringMid($Entry,$LocalAttributeOffset+16,$EaNameLength*2)
		$EaName = _HexToString($EaName)
		If $EaName = "" Then Return SetError(1,0,"$EaName="&$EaName)

		$EaOutputFilename = $ParserOutDir&"\NonResidentExtract\MFT("&$RealMftRef&")_EaName("&$EaName&")_LSN("&$this_lsn&").bin"
		If $LocalAttributeOffset+16+($EaNameLength*2) >= $StringLengthInput Then
			If $LocalAttributeOffset+16+($EaNameLength*2) > $StringLengthInput Then
				_DumpOutput("Error: Pair header is spread across page boundary" & @crlf)
				Return SetError(1,0,"Error: Pair header is spread across page boundary")
			EndIf
			_DumpOutput("Warning: Pair is spread across page boundary" & @crlf)
			$NewArraySize = Ubound($EaNonResidentArray)+1
			ReDim $EaNonResidentArray[$NewArraySize][9]
			$EaNonResidentArray[$NewArraySize-1][0] = $RealMftRef
			$EaNonResidentArray[$NewArraySize-1][1] = 8+$EaNameLength+1+$EaValueLength
			$EaNonResidentArray[$NewArraySize-1][2] = $EaName
			$EaNonResidentArray[$NewArraySize-1][3] += 8+$EaNameLength
			$EaNonResidentArray[$NewArraySize-1][4] = $this_lsn
			$EaNonResidentArray[$NewArraySize-1][5] = $target_attribute
			$EaNonResidentArray[$NewArraySize-1][6] = $MftClusterIndex
			$EaNonResidentArray[$NewArraySize-1][7] = $target_vcn
			$EaNonResidentArray[$NewArraySize-1][8] = $EaOutputFilename
			Return
		EndIf
		$EaValue = StringMid($Entry,$LocalAttributeOffset+16+($EaNameLength*2),$EaValueLength*2)
		$TextInformation &= ";EaName("&$EaCounter&")="&$EaName

		If $VerboseOn Then
			_DumpOutput("_Get_Ea_NonResident():" & @CRLF)
			_DumpOutput("$OffsetToNextEa = " & $OffsetToNextEa & @crlf)
			_DumpOutput("$EaFlags = " & $EaFlags & @crlf)
			_DumpOutput("$EaNameLength = " & $EaNameLength & @crlf)
			_DumpOutput("$EaValueLength = " & $EaValueLength & @crlf)
			_DumpOutput("$EaName = " & $EaName & @crlf)
			_DumpOutput("$EaValue:" & @crlf)
			_DumpOutput(_HexEncode("0x"&$EaValue) & @crlf)
		EndIf

		$NewArraySize = Ubound($EaNonResidentArray)+1
		ReDim $EaNonResidentArray[$NewArraySize][9]
		$EaNonResidentArray[$NewArraySize-1][0] = $RealMftRef
		$EaNonResidentArray[$NewArraySize-1][1] = 8+$EaNameLength+1+$EaValueLength
		$EaNonResidentArray[$NewArraySize-1][2] = $EaName
		If (($LocalAttributeOffset-1+16+($EaNameLength*2)+2)/2)+$EaValueLength <= $BinaryLengthInput Then
			$EaNonResidentArray[$NewArraySize-1][3] += 8+$EaNameLength+1+$EaValueLength
		Else
			$EaNonResidentArray[$NewArraySize-1][3] += ($StringLengthInput-$LocalAttributeOffset-1)/2
			$DoneParsing=1
		EndIf
		$EaNonResidentArray[$NewArraySize-1][4] = $this_lsn
		$EaNonResidentArray[$NewArraySize-1][5] = $target_attribute
		$EaNonResidentArray[$NewArraySize-1][6] = $MftClusterIndex
		$EaNonResidentArray[$NewArraySize-1][7] = $target_vcn
		$EaNonResidentArray[$NewArraySize-1][8] = $EaOutputFilename

		$hFileOutNonResident = FileOpen($EaOutputFilename,17)
		If Not $hFileOutNonResident Then
			_DumpOutput("Error: FileOpen failed with @error: " & @error & @crlf)
			$EaNonResidentArray[$NewArraySize-1][3] = 0
		EndIf
		FileSetPos($hFileOutNonResident, 0,  $FILE_END)
		FileWrite($hFileOutNonResident,"0x"&StringMid($EaValue,3,($EaValueLength*2)-2))
		FileClose($hFileOutNonResident)

		If $DoneParsing Then ExitLoop

		If $OffsetToNextEa*2 >= $StringLengthInput Then ;Nothing more
			Return
		EndIf

;		If ($OffsetToNextEa*2) + 18 >= $StringLengthInput Then ;Header is spread across page boundary
;			_DumpOutput("Error: Header is spread across page boundary" & @crlf)
;			_DumpOutput(_HexEncode("0x"&$Entry) & @crlf)
;			Return
;		EndIf
	Until $LocalAttributeOffset >= $StringLengthInput
	$TextInformation &= ";Search debug.log for " & $this_lsn
EndFunc
