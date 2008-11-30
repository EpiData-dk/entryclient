unit EPITypes;

//{$DEFINE epidat}

interface

USES
  stdctrls,classes,comctrls, Forms, Graphics, controls,Windows,
  SysUtils, Dialogs, Buttons, extctrls, menus, UExtUDF, epiUDFTypes,
  ShellAPI,Rijndael,Base64, unitGCPClasses
  {$IFNDEF epidat},fmxUtils{$ENDIF};

{$IFNDEF epidat}
  {$R English.res}
  {$R EpdRes.Res}
{$ENDIF}


TYPE
  str10=String[10];
  str15=String[15];
  str30=String[30];
  TdynArrayString=array of string;


CONST
EpiDataVersion='3.3 beta';
//VersionNumber=2.12;
VersionNumber=3.1;
BuildNo='271008';
TESTVERSION=true;
NumChars:        Set of CHAR=['0'..'9'];
AlfaNumChars:    Set of CHAR=['0'..'9','A'..'Z','a'..'z'];
AlfaChars:       Set of CHAR=['A'..'Z','a'..'z'];
IntegerChars:    Set of CHAR=['0'..'9','-','+'];
FloatChars:      Set of CHAR=['0'..'9', '.', ',', '-', '+'];
DateChars:       Set of CHAR=['0'..'9','/'];
BooleanChars:    Set of CHAR=['y','Y','n','N','1','0'];
BooleanYesChars: Set of CHAR=['y','Y','1'];
BooleanNoChars:  Set of CHAR=['n','N','0'];
DaysInMonth:     ARRAY[1..12] OF BYTE = (31,29,31,30,31,30,31,31,30,31,30,31);
TerminatorChars: Set of CHAR=['!','?','^'];
NewLine:Byte=13;
LineFeed:Byte=10;
MaxRecLineLength=78;
FieldNameLen:Byte=10;
//LineSpacing=18;  //LineSpacing in Dataforms
TopMargin=30;    //TopMargin in pixels in DataForms
LeftMargin=20;   //Left margin in pixels in DataForms
NewRecord:LongInt=-1;
MinNumber:Double=5E-325;
MaxNumber:Double=1.7E308;
MaxNumberOfDatafiles=30;
MaxIndices=20;
MaxFindExCrites=10;   //Max number of search critirias
MaxPws=5;   //Max number of remembered password in encrypted files

ColorNames:ARRAY[0..17] OF str10 = ('AQUA','BLACK','BLUE','DKGRAY','FUCHSIA','GRAY',
  'GREEN','LIME','LTGRAY','MAROON','NAVY','OLIVE','PURPLE','RED','SILVER','TEAL','WHITE','YELLOW');
ColorValues:ARRAY[0..17] OF TColor = (clAqua, clBlack, clBlue, clDkGray, clFuchsia,
  clGray, clGreen, clLime, clLtGray, clMaroon, clNavy, clOlive,
  clPurple, clRed, clSilver, clTeal, clWhite, clYellow);
TextColors:array[0..15] of TColor = (clBlack,clNavy,clGreen,clTeal,
                        clMaroon,clPurple,clOlive,clSilver,clGray,
                        clBlue,clLime,clAqua,clRed,clFuchsia,clYellow,clWhite);
BgColors:array[0..7] of TColor = (clBlack,clNavy,clGreen,clTeal,clMaroon,clPurple,clOlive,clSilver);


{$IFDEF epidat}
epi_OK=0;
EPI_NO_MEMORY=1;
epi_OPEN_FILE_ERROR=2;
epi_FILE_NOT_EXISTS=3;
epi_WRITE_ERROR=4;
epi_DATAFILE_FORMAT_ERROR=5;
epi_CREATE_FILE_ERROR=6;
epi_READ_FILE_ERROR=7;
EPI_TABLEFULL_ERROR=8;
epi_DATAFILE_NOT_OPEN=9;
epi_RECORD_NOT_FOUND=10;
EPI_INVALID_FIELDHANDLE=11;
epi_VALUE_NOT_NUMBER_ERROR=12;
epi_TOO_MANY_FIELDS_ERROR=13;
EPI_CHECKFILE_ERROR=14;
EPI_FILE_OERROR=15;
EPI_INVALID_HANDLE=16;
EPI_OPEN_WRMODE=17;
EPI_HEADER_NOTCOMMIT=18;
EPI_INVALID_FIELDNAME=19;
EPI_BUFFER_TOO_SMALL=20;
EPI_INVALID_PASSWORD=21;
{$ENDIF}


TYPE
  str45=string[45];
  ByteFile=File of Byte;
  RecBuf=Array[0..20000] OF Char;
  PRecBuf=^RecBuf;
  TFelttyper = (ftInteger,ftAlfa,ftDate,ftUpperAlfa,ftCheckBox,
                ftBoolean,ftFloat,ftPhoneNum,ftTime,ftLocalNum,
                ftToday,ftEuroDate,ftIDNUM,ftRes4,ftRes5,
                ftQuestion,ftEuroToday,ftSoundex,ftCrypt,ftYMDDate,ftYMDToday);    //&&
  PLabelRec=^TLabelRec;
  TLabelRec=Record
      Value:String[30];
      Text:String[80];
      Next:Pointer;
    END;
  PRelateInfo=^TRelateInfo;
  TRelateInfo=Record
      RelFileNo:    Integer;
      RelFieldNo:   Integer;
      CmdInFieldNo: Integer;
      One2One:      Boolean;
      Next:         Pointer;
    END;
  TRelActions=(raNothing,raOpenFileInEditor,raOpenTwoFilesInEditor);
  TOpenRelAction=Record
    Action: TRelActions;
    File1:  TFilename;
    File2:  TFilename;
    end;
  TExportTypes=(etTxt,etDBase,etXLS,etStata,etRecToQes,etListData,etSPSS,etSAS,etEpiData,etCodebook);
  TBeepTypes=(btWarning,btConfirmation,btStandard);
  TIndexFields=Array[1..MaxIndices] OF Integer;
  TIndexIsUnique=Array[1..MaxIndices] OF Boolean;
  TIndexFile=File of str30;
  TScopes=(scLocal,scGlobal,scCumulative);
  TDirections=(dirForward,dirBackward,dirFirst,dirLast,dirAbsolute);
  TLastSelectFilestype=(sfNone,sfMakeDatafile,sfRevise,sfAssert,sfRecode,sfRec2Qes,sfValDup,
                        sfImportStata,sfMerge);

  //Types related to searching datafiles
  TSearchStyle=(ssEquals,ssBeginsWith,ssContains);
  TScopeStyle=(ssForward,ssBackWard,ssAll);

  TFindOperators = (opNone,opEq,opNEq,opGT,opLT,opBW,opEW,opCON);

  TCrites=Record
    Fieldno: Integer;
    Opr: TFindOperators;
    SearchText: String;
    SearchValue: Double;
  END;

  TPwRec=Record
    DataFilename: String;
    key: String;
    Time: TDateTime;
  END;


  PFindOptions=^TFindByExOptions;
  TFindByExOptions=Record
    StartRecord:         LongInt;
    BckColor:            TColor;
    NumCrites:           Integer;
    Crites:              Array[1..MaxFindExCrites] of TCrites;
    CanUseIndex:         Boolean;
    FoundRecs:           TStringList;
    Scope:               TScopeStyle;
    CurFoundRec:         Integer;
    IgnoreDeleted:       Boolean;
    CaseSensitive:       Boolean;
    WholeWordsOnly:      Boolean;
  END;


  Commands=(cmdIF,cmdHelp,cmdHide,cmdUnhide,cmdClear,cmdGoTo,cmdComLegal,
            cmdExit,cmdDefine,cmdAutosave,cmdConfirm,cmdTypeString,
            cmdRelate,cmdIgnoreMissing,cmdWriteNote,cmdBackup,cmdBeep,cmdLoad,cmdExecute,
            cmdColor,cmdMissingAll,cmdQuit,cmdCopyToClipboard,cmdShowLastRecord,cmdDefaultAll,cmdLet,cmdComment,cmdLeaveField);       //¤¤
            //NB! Insert new codes BEFORE cmdLet
                                                                                                             //cmdLeaveField is only used internally (in conn. with relate)

CONST
  CommandNames:Array[Commands] of String[16]=
    ('IF','HELP','HIDE','UNHIDE','CLEAR','GOTO','COMMENT','EXIT','DEFINE',
    'AUTOSAVE','CONFIRM','TYPE','RELATE','IGNOREMISSING','WRITENOTE','BACKUP',
    'BEEP','LOAD','EXECUTE','COLOR','MISSINGVALUE','QUIT','COPYTOCLIPBOARD',
    'SHOWLASTRECORD','DEFAULTVALUE',
    'LET','dummy','leavefield');                                            //¤¤


TYPE
  TChangeFieldActions=(cfNext,cfPrev,cfFirst,cfLast,cfValidate);
  TLeaveStyles=(lsEnter,lsBrowse,lsJumpFirst,lsJumpLast,lsChangeRec,lsNone);
  PCmds=^TCmds;
  TCmds=RECORD
          Next: PCmds;
          CASE Command: Commands OF
            cmdIF:
               (IfExpr:          String[200];
                IfShowExpr:      String[200];
                IfCmds:          TList;
                ElseCmds:        TList);
            cmdHelp:
               (HelpString:      String[250];
                HelpType:        TMsgDlgType;
                HelpKeys:        String[10]);
            cmdHide,cmdUnHide,cmdClear,cmdGoto:
               (HideVarNumber:   Integer;
                HideVarName:     String[10]);
            cmdComLegal:
               (clVarNumber:     Integer;
                ValueLabel:      String[40];
                CommentLegalRec: PLabelRec;
                ShowList:        Boolean);
            cmdTypeString:
               (tsVarNumber:     Integer;
                TypeText:        String[40];
                Typecolor:       TColor);
            cmdRelate:
               (RelField:        String[10];
                RelFileNo:       Integer;
                RelFileStr:      String[200];
                One2One:         Boolean);
            cmdLet:
               (VarName:         String[20];
                VarNumber:       Integer;
                VarIsField:      Boolean;
                CodedWithLET:    Boolean;
                LetExpr:         String[200]);
            cmdComment:
               (Comment:         String[200]);
            cmdDefine:
               (FName:           String[20];
                FeltType:        TFelttyper;
                FLength:         Integer;
                FNumDecimals:    Byte;
                FScope:          TScopes);
            cmdWriteNote:
               (FNote:           String[200];
                ShowNotes:       Boolean);
            cmdCopyToClipboard:
               (CopyStr:         String[200]);
            cmdBackup:
               (DestLib:         String[200];
                zipit:           Boolean;
                encryptit:       Boolean;
                filename:        String[200];
                pw:              string[30];
                dateit:          Boolean);
            cmdBeep:
               (BeepType:        TBeepTypes);
            cmdLoad:
               (DLLName:         String[200]);
            cmdExecute:
               (ExecCmdLine:     String[255];
                ExecParams:      String[255];
                ExecHide:        Boolean;
                ExecWait:        Boolean);
            cmdLeaveField:
               (cLeaveStyle:     TLeaveStyles;
                IsLastField:     Boolean);
            cmdColor:
               (ColorCmd:        Byte;      //1=color question, 2=color data,  3=color background, 4=color fieldname
                TxtColor:        Byte;
                BgColor:         Byte;
                IsEpiInfoNo:     Boolean;
                CFieldno:        Byte);
          END;

  PAssert=^TAssert;
  TAssert=RECORD
      AssName: String[40];
      AssExpr: String[200];
      OrigExpr: String[200];
      ViolCount: Integer;
      Violaters: String;
    END;

  PeField=^TeField;
  TeField=RECORD
      FName:            Str10;
      FVariableLabel:   String[80];   //Variable label
      Felttype:         TFelttyper;   //Field type
      FLength:          Byte;         //Length of data in field
      FCryptEntryLength:Byte;         //Entrylength of encrypt fields (Flength is coded length)   //&&
      FNumDecimals:     Byte;         //Number of decimals in numeric fields
      FQuestion:        String[80];   //The field's question (to the left of field)
      FOriginalQuest:   String[80];   //Question as it is saved in REC-file
      LastField:        Boolean;      //True if field is last field in dataform
      FFieldText:       String;       //Entry made in the field (= text property)
      FStartPos:        Integer;       //Start position in datafile record of field
      {Entryfield coordinates}
      FQuestTop:        Integer;      //Question pixel-based top-position   *
      FQuestLeft:       Integer;      //Question pixel-based left-position   *
      FFieldTop:        Integer;      //Entry field's pixel-based top         *
      FFieldLeft:       Integer;      //Entry field's pixel-based left         *
      FFieldWidth:      Integer;      //Entry field's width in pixels          *
      FFieldX,FFieldY:  Integer;      //Field's coordinates in characters
      FQuestX,FQuestY:  Integer;      //Question's coordinates in characters
      {Check related properties}
      FMustEnter:       Boolean;      //True if MUSTENTER is set
      FRepeat:          Boolean;      //True if REPEAT is set
      FMin:             String;       //Mininum value (set by RANGE)
      FMax:             String;       //Maximum value (set by RANGE)
      FLegal:           String;       //Legal values (incl. RANGE values)
      FRangeDefined:    Boolean;      //True if FLegal includes a Range definition
      FCommentLegalRec: PLabelRec;    //Pointer to comment legal record (value label)
      FShowLegalPickList: Boolean;    //True if Comment Legal Show (forces picklist to be shown)
      FPickListNoSelect: Boolean;     //If True then no item is automatically selected in LegalPickList
      FValueLabel:      String[40];   //Name of value label = Comment legal label
      FJumps:           String;       //Jumps definitions
      FJumpResetChar:   Char;         //Fill char when JUMPS RESET "-" is used
      {autosearch properties}
      FAutosearch:      Boolean;      //True if field has autosearch
      FAutoFields:      String;       //CSV-string of fields to autosearch
      FAutoList:        Boolean;      //True if Autosearch has LIST parameter set
      {other properties}
      FNoEnter:         Boolean;
      EntryField:       Pointer;      //Pointer to TEntryField on Dataform
      FFieldComments:   String;       //Comments in checkfile in fieldblock - used only in checkfilemode
      FieldN:           Integer;      //'Free' property for different uses
      FIndex:           Byte;         //Key number = index number
      FIsTypeStatusBar: Boolean;      //Indicates if field has TYPE STATUSBAR
      FTypeComments:    Boolean;      //Fields has TYPE COMMENT
      FTypeString:      Boolean;      //Indicates that field has a TYPE "lkjlkj" command
      FTypeCommentField: Integer;     //Used with TYPE COMMENT fieldname - holds number of field to receive the comment
      FTypeField:       TLabel;       //Label on dataform with TYPE-text
      FTypeColor:       TColor;       //Color of TYPE-label
      FConfirm:         Boolean;      //If true then confirm with ENTER before field is left (overrides df^.Confirm)
      AfterCmds:        TList;        //Commands run After Entry
      BeforeCmds:       TList;        //Commands run Before Entry
      OldReadOnly:      Boolean;      //Used to save the ReadOnly status before setting ReadOnly=True during Relate-operations
      FTopOfScreen:     Boolean;      //True=Move field to top of screen when entered ("New Page")
      FTopOfScreenLines: Byte;        //Number of lines to move topofscreen field down
      FMissingValues:    Array[0..2] of str15;    //legal missing values
      FHasGlobalMissing: Boolean;   //Set if MISSINGVALUE var1-var2 9 8 7 type command is run previously
      FDefaultValue:     string;      //A default value of the field defined by DEFAULTVALUE x
      FHasGlobalDefaultValue: Boolean;   //A default value define by DEFAULTVALUE ALL X or DEFAULTVALUE field-field, field X
      FIsVarified:       Boolean;     //True if field is varifield during double entry
    END;


  PDatafileInfo=^TDatafileInfo;
  TDatafileInfo=RECORD
    {Filenames}
    RECFilename:       TFilename;
    QESFilename:       TFilename;
    CHKFilename:       TFilename;
    IndexFilename:     TFilename;

    {Datafile properties}
    //Datfile:           ByteFile;       //The datafile
    //Datfile:           File;
    DatFile:           TFileStream;    //The datafile
    Offset:            Longint;        //pointer in datafile where data begins
    RecLength:         Word;           //Length of one record in datafile incl. NewLine and terminator
    ShortRecLength:    Word;           //Length of one record excl. newline and terminator
    HasEOFMarker:      Boolean;        //True if datafile has an EOF marker
    NumRecords:        Integer;        //Total number of records in datafile
    HasCheckFile:      Boolean;        //does the datafile have a checkfile?
    RecBuf:            PRecBuf;        //Buffer for reading and writing to/from datafile

    {Field properties}
    FieldList:         TList;          //List of eFields Records
    FieldNames:        TStringList;    //List of fieldnames (excl. questions) - created only when needed
    FieldNamesList:    TStringList;    //List of fieldnames+fieldlabel - created only when needed by dataformunit.FindField1Click
    NumFields:         Integer;        //Number of fields in datafile excl. question-fields
    CurField:          Integer;        //Used in CheckFileMode to indicate current field
    LeaveStyle:        TLeaveStyles;   //Indicates how a field is exited
    CanExit:           Boolean;        //Flag to indicate if field can be exited
    FocusedField:      Integer;        //Used in PeekApplyCheckFile to indicate current field

    {Record properties}
    CurRecord:         Integer;        //Record number of current record
    CurRecDeleted:     Boolean;        //Is current record marked as deleted?
    CurRecVerified:    Boolean;        //Is current record marked as verified with ^-marker?
    CurRecModified:    Boolean;        //Has current record been modified?
    dfModified:        Boolean;        //Has as record been saved in this session?

    {IDNumber properties}
    IDNUMField:        Integer;        //does the datafile contain a IDNUM field?
    FirstIDNumber:     LongInt;        //First IDNumber used in new datafiles
    CurIDNumber:       Longint;        //Current IDNumber

    {Forms}
    DatForm:           TObject;        //Pointer to the dataform - if created
    ChkForm:           TObject;        //Pointer to the CheckForm - if created
    SearchForm:        TObject;
    DataFormCreated:   Boolean;        //True if DataForm is created
    CheckFormCreated:  Boolean;        //True if CheckForm is created

    {Create fields properties}
    EpiInfoFieldNaming:Boolean;        //Flag to indicate how fieldnames are created
    UpdateFieldnameInQuestion: Boolean;
    ValueLabels:       TStrings;       //List of valueLabels (pLabelRecs) used
    HasLongFieldNames: Boolean;        //Flag to indicate if 10-chars fieldnames occur

    {Type Statusbar properties}
    TypeStatusBarField:Integer;        //Fieldno. of TYPE STATUSBAR field
    TypeStatusBarText: ShortString;    //Prefix text in TYPE STATUSBAR
    TypeStatusBarColor: TColor;        //Color to write Type StatusBar in

    {Index related vars}
    IndexCount:        Byte;           //Number of used indices
    Index:             TMemoryStream;  //Index values sorted by rec-no.
    SortIndex:         TMemoryStream;  //List of rec-numbers (integers) that points to Index (used to sort index)
    IndexFields:       TIndexFields;   //Fieldnumber of fields with index
    IndexIsUnique:     TIndexIsUnique; //TRUE means that index[n] is unique
    IndexFile:         TIndexFile;     //IndexFile = File of Str30
//    ComIndex:          TStringList;    //Common index for all indices

    {Define vars}
    HasDefined:        Boolean;        //True if checkfile contains define
    DefList:           TStringList;    //List of defined variables

    {Encrypt properties}
    HasCrypt:          Boolean;        //Indicates that a encrypt fields exists in datafile    //&&
    Key:               String;         //encrypt key
    DontGetPassword:   Boolean;        //Used to avoid prompt for password (e.g. in rec2qes)

    {Relate properties}
    IsRelateTop:       Boolean;        //True if is the 'main' entryform
    IsRelateFile:      Boolean;        //True if entryform is to be called via RELATE
    CanActivate:       Boolean;        //Used to indicate if a RelateFile may be activated
    RelateMother:      PDatafileInfo;  //Pointer to calling entryform
    One2One:           Boolean;        //True if RELATE fieldname Filename 1 was used
    RelateReturned:    Boolean;
    RelateCalled:      Boolean;        //Set in the mother when a relate file is called
    IsInRelate:        Boolean;        //Set in the relatefile when mother calls it
    LastCommands:      TList;          //Used to store cmds after RELATE command
    tmpLastCmds:       TList;          //Used to handle multiple RELATEs in same before/after entry block
    RelateField:       PeField;        //Used in the relatefile (to restore enabled state)
    OldEnabledState:   Boolean;        //Stores old Enabled state of relatefield
    MotherRecNum:      Integer;        //CurRecNum of Mother when relate was called
    HasRelate:         Boolean;        //Indicates that the datafile contains at least one relate command
    RelateInfo:        PRelateInfo;    //Information on relates in the datafile

    {Filter properties}
    UseFilter:         Boolean;        //True if filter is activated
    FilterField:       Integer;        //Number of field to use filter on
    FilterText:        String;         //The filter

    {UDF properties}
    ModuleInfo:        TEpiDataModuleInfo;
    UDFList:           TEpiExternalUDFList;

    {Colors}
    QuestionText:      TColor;
    QuestionBg:        TColor;
    FieldText:         TColor;
    FieldBg:           TColor;
    BackGround:        TColor;

    {double entry properties}
    DoubleEntry:       Boolean;        //true = in double entry proces
    dbFilename:        String;         //File of original datafile
    dbDf:              PDatafileInfo;  //Pointer to open, original datafile
    dbIgnoretext:      Boolean;        //true = ignore text fields during double entry
    dbOrigKeyfieldno:  Integer;        //Number of keyfield in original datafile - default=-1
    dbNewKeyfieldno:   Integer;        //Number of keyfield in new (db-entry) datafile
    dbKeyfieldname:    String;         //Name of keyfield
    dbKeyfieldvalue:   String;         //Entered value of keyfield

    {GCP project properties}
    GCPproject:           TGCPProject;

    {Misc.}
    ChkTopComments:    TStringList;    //Commentlines in the top of the checkfile - used only in checkfilemode
    FileLabel:         String[50];     //Label for datafile
    HasRepeatField:    Boolean;        //If one or more fields have a Repeat check
    BeforeFileCmds:    TList;          //Commands to be run when file is opened
    AfterFileCmds:     TList;          //Commands to be run when file is closed
    BeforeRecordCmds:  TList;          //Commands to be run before current record changes
    AfterRecordCmds:   TList;          //Commands to be run when changing current record
    RecodeCmds:        TList;          //Commands to be run during Recode Datafile
    AssertList:        TStringList;    //used only to store Asserts for checkfilemode
    Confirm:           Boolean;        //If true then a field is not let automatically when filled out
    AutoSave:          Boolean;        //IF true then user is not asked "Save record to disk?"
    LatestActiveControl:TObject;
    IsReadOnly:        Boolean;        //Marks df as ReadOnly - used in relate-operations
    BackupList:        TStringList;    //List of files to backup
    OKToBackup:        Boolean;
    FieldCheckSum:     Integer;        //checksum used in control of esc-files
    IsFinding:         Boolean;
    IsInSearchForm:     Boolean;
    FieldHighlightAct: Boolean;     //highlight active field
    FieldHighlightCol: TColor;       //color af highlight of active field
    IsInBeforeCmds:    Boolean;   //&&
    HasIncludeCmd:     Boolean;   //checkfile uses one or more Include commands
    GlobalMissingValues: Array[0..2] of str15;
    GlobalDefaultValue:  string;    //Global default value defined by DEFAULTVALUE ALL X or DEFAULTVALUE field-field, field X
    GlobalTypeCom:       Boolean;   //Show that all fields has a Type Comment Fieldname
    GlobalTypeComColor:  Integer;
    FindOpt:           PFindOptions;   //Options and parameters for finding records in datafiles during dataentry
    ShowLastRecord:    Boolean;        //if set, then last record is shown when datafile is opened; if false (default) then new, blank record is shown
    END;

  PDefVar=^TDefVar;
  TDefVar=RECORD
    FName:             String[16];
    Felttype:          TFelttyper;
    FLength:           Integer;
    FNumDecimals:      Byte;
    FFieldText:        String;
    FScope:            TScopes;
    END;



  TFieldCase=(fcUpper,fcLower,fcDontChange);
  TMissingAction=(maIgnoreMissing,maRejectMissing);
  TRecentFiles=ARRAY[1..8] of string;
  TCharSet=Set of Char;
  TFontRecord=Record
                Name:String[30];
                Color:TColor;
                Size:Integer;
                Style:Byte;    {bit-coded Bold=0001b Italic=0010b
                               Underline=0100b  StrikeOut=1000b}
              END;

  Tesc_header=Record
    scrHeight:      Integer;
    scrWidth:       Integer;
    fntSize:        Integer;
    fntStyle:       Byte;
    fntPPI:         Integer;
    fntName:        str30;
    numFields:      Integer;
    chkFields:      Integer;
    END;

  Tesc_field=record
    QuestTop:     Integer;
    QuestLeft:    Integer;
    FieldLeft:    Integer;
    FieldTop:     Integer;
    FieldWidth:   Integer;
    END;

VAR
  NumberOfOpenDatafiles:Integer;
  eField: PeField;
  eFieldList: TList;
  eFieldListCreated: Boolean;
  DontApplyCheckFile: Boolean;
  FeltListe:TList;
  FeltListeCreated: BOOLEAN;
  PickListCreated: Boolean;
  RapFormCreated:BOOLEAN;
  CreateIndtastningsFormError:BOOLEAN;
  Datafile:File of Byte;
  eDay,eMonth,eYear:Word;
  QES: TStrings;
  LastActiveEd: TRichEdit;
  RecentFiles,RecentQes:TRecentFiles;
  TestingDataForm:Boolean;
  DontMakeFieldNames:Boolean;
  QesFilename,RecFilename,CheckFilename:String;
  DontShowDataForm:Boolean;
  CreatingRECtoQES:Boolean;
  RecToQesFilename:TFilename;
  epiEdFont, epiDataFormFont, epiDocuFont:TFont;
  EdColor,DataFormColor, DocuColor:TColor;
  FieldNameCase:TFieldCase;
//  LatestActiveControl:TWinControl;   //used to identify the current EntryField
  CheckFileMode: Boolean;
  EvenTabValue:Integer;
  ShowWelcomeWindow:Boolean;
  StataVersion:Integer;                 //Version of Stata to use in export
  ExportSortByIndex: Boolean;
  ViewerSortByRec: Boolean;        //IF true then sortorder in viewer is by recordnum else by indexorder
  StataLetterCase: TFieldCase;
  DontCheckEntries:Boolean;
  CreatingFromQesFile:Boolean;    //Flag to indicate if dataform is made from qes-file or rec-file (used in overset.inc)
  BackUpDir:String;
  TestDataFormRect:TRect;
  CodeHelpOn:Boolean;
  NumberOfTabChars:Byte;
  WindowNum:Byte;
  TestDf: PDatafileInfo;
  TestDataFormCreated: Boolean;
  FirstIDNumber:LongInt;
  NoUpDateCurRecEdit:Boolean;
  UserAborts:Boolean;          //Flag to indicate that user presses ESC to Abort
  HideToolBarsDuringDataEntry:Boolean;
  OldWorkProcessToolBar,OldEditorToolbar:Boolean;
  WorkProcessToolBarOn,EditorToolBarOn:Boolean;
  EnforceMustEnter:Boolean;
  EpiInfoFieldNaming:Boolean;
  UpdateFieldNameInQuestion:Boolean;
  ShowCheckFileCheckmark:Boolean;
  ComLegalCounter: Integer;
  LegalPickFormWidth, LegalPickFormHeight, FieldNamesListWidth: Integer;
  ShowExprErrors: Boolean;
  AndBtn1, AndBtn2:boolean;
  ExitExecutionBlock: Boolean;
  FieldColor,FieldHighlightColor: TColor;
  FieldStyle: Byte;    // 0=3D-look,  1=Flat w/ border,  2=Flat w/o border
  FieldHighlightActive: Boolean;
  LastActiveOptionsPage: Integer;
  LineHeight: Integer;
  GlobalAutoSave,GlobalConfirm: Boolean;
  LanStr: TStringList;
  CurLanguage: String;
  UsesEnglish: Boolean;
  HandleVarsDf: PDatafileInfo;
  HelpBoxLegalKeys: String[10];
  ResultVar: Integer;     //Value of the predefined variable RESULT (used in connection with HELP ".." KEYS="..")
  {Global vars concerning RELATE}
  RelateFiles: TStringList;
  RelateMothers: TList;
  RelateNodes: TList;
  GlobalDefList: TStringList;
  OpenWithRelate: Boolean;
  LastSelectFilestype: TLastSelectFilestype;
  LastSelectFile1,LastSelectFile2: TFilename;
  IniFilename: TFilename;
  SaveDlgPos,HelpBoxPos: TPoint;
  PickListPos: TPoint;
  SearchBoxPos: TPoint;
  RelateTreeRect: TRect;  //coordinates of RelateTreeForm (saved in INI-file)
  RelateTreeDock: Byte;   //0=don't dock,  1=dock left,   2=dock rigth
  DataEntryNotesPos: TRect;
  FieldTypeNames:ARRAY[0..20] OF String;  //&&
  ResultEqualsMissing: Boolean;
  ShowMouseWarning, HasShownMousewarning: Boolean;
  MissingAction: TMissingAction;
  NumMissingVariables, NumVariables: Integer;
  WarningSounds, DoUseSounds: Boolean;
  epiErrorCode: Integer;
  OldDockPanelWidth: Integer;
  RelateTreecount: Integer;
  PaintProperWorkbar: Boolean;
  MakeFQuestionSum: Boolean;
  ActiveRelatefile: PDatafileInfo;
  LatestViewedDataForm: TForm;
  RebuildIndex: TStringList;
  Cipher: TDCP_Rijndael;  //&&
  ChangeGoingOn:BOOLEAN;
  LangVersionCounter:Integer;
  NoLangError: Boolean;
  IsZipping: Boolean;
  pws: Array[1..Maxpws] of TPwRec;
  {('Numeric','Text','Date (mdy)',
  'Uppercase text','Checkbox','Boolean','Numeric','Phonenumber',
  'Time','Local phonenum.','Today (mdy)','Date (dmy)','ID-number','ftRes4',
  'ftRes5','ftQuestion','Today (dmy)','Soundex')}




  Procedure DestroyFieldList(VAR AList:TList);
  Function  IsDriveReady(DriveLetter:Char):Boolean;
  Function  FontStyleToByte(AStyle:TFontStyles):Byte;
  Function  ByteToFontStyle(AByte:Byte):TFontStyles;
  Function  eStrToFloat(s: String):Double;
  Function  cFill(c:Char; Len:Integer):String;
  Procedure ResetDatafile(VAR df:PDatafileInfo);
  Function  ZeroFormatInteger(q: Integer):String;
  Function  GetDatafilePointer(VAR df:PDatafileInfo):Boolean;
  Procedure DisposeCommandList(VAR AList:TList);
  Procedure DisposeDatafilePointer(VAR df:PDatafileInfo);
  Procedure DisposeLabelRec(VAR ALabel:PLabelRec);
  Procedure DisposeRelateInfo(VAR ARelateInfo: PRelateInfo);
  Function  IsInteger(s:String):Boolean;
  Function  IsFloat(s:String):Boolean;
  Function  IsLeapYear(AYear: Word):Boolean;
  Function  dkDayOfWeek(ADate: TDateTime):Integer;
  FUNCTION  WeekNum(ADate: TDateTime):Integer;
  FUNCTION  NameIsUnique(VAR TempName:String; df:PDatafileInfo; WantedLength:Byte):Boolean;
  Function  FirstWord(s:String):str10;
  Function  mibStrToDate(s:String; Style:TFelttyper):TDateTime;
  Function  mibIsDate(VAR s:String; Style:TFelttyper):Boolean;
  Function  mibDateToStr(d:TDateTime; Style:TFelttyper):String;
  Function  GetCommentLegalText(CONST s:String; ComLegRec: PlabelRec):String;
  Function  GetValueFromCommentLegal(CONST s:String; ComLegRec: PLabelRec):String;
  Procedure ResetCheckProperties(VAR AField: PeField);
  Procedure CopyCheckProperties(VAR Source,Destination: PeField);  
  Function  HasCheckProperties(VAR AField: PeField):Boolean;
  Function  HasSpecialChecks(VAR AField: PeField):Boolean;
  Function  IsCompliant(s:String; Style:TFelttyper):Boolean;
  Procedure Double2SingleQuotes(VAR s:String);
  Procedure Single2DoubleQuotes(VAR s:String);
  Function  GetFieldNumber(Const s:String; VAR df:PDatafileInfo):Integer;
  Function  GetField(CONST s:String; VAR df:PDatafileInfo):PeField;
  Function  GetDefField(Const s:String; VAR df:PDatafileInfo):PDefVar;
  Function  FitLength(s:String;L: Integer):String;
  Function  ReadFromIndex(VAR df:PDatafileInfo; IndexNo,RecNo: Integer):str30;
  Procedure WriteToIndex(VAR df:PDatafileInfo; IndexNo,RecNo: Integer; s:Str30);
  Function  SearchIndex(VAR df: PDatafileInfo; IndexNo: Integer; SearchStr: Str30):LongInt;
  Function  SearchIndexFrom(VAR df: PDatafileInfo; IndexNo: Integer; SearchStr: str30; RecNo:Integer; direction:TDirections):LongInt;
  Function  IndexHasDuplicates(VAR df:PDatafileinfo; IndexNo:Integer):Boolean;
  Procedure DecryptIndex(VAR df:PDatafileInfo);    //&&
  Function  Soundex(s: String):String;
  Function  Lang(no: Integer):String;
  {$IFNDEF epidat}
  Procedure TranslateForm(AForm: TForm);
  Procedure InitLanguage;
  Procedure ErrorMsg(CONST s:String);
  Function  WarningDlg(CONST s:String):Word;
  Function  NoYesDlg(CONST s:String):Word;
  Function  SaveDlg(CONST s:String; Btns: TMsgDlgButtons):WORD;
  Function  eDlg(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt):Word;
  Function  eDlgPos(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt; VAR x,y:Integer):Word;
  Function  AddEditDlg(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt):Word;
  Function  OriginalNewEditDlg(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt):Word;
  Function  eInputBox(const ACaption, APrompt, ADefault: string): string;
  Procedure AddToNotesFile(VAR odf: PDatafileInfo; CONST s:String);
  function  fileExec(const aCmdLine,aParams: String; aHide, aWait: Boolean; VAR ExitCode:Cardinal): Boolean;
  {$ENDIF}
  Procedure InitSortIndex(VAR df:PDatafileInfo);
  Function  ReadIndexNoFromSortIndex(VAR df:PDatafileInfo; SortPos: Integer):Integer;
  Function  GetRecentFilename(FileExt: String):String;
  Function  GetRecentFiledir:String;
  Function  InsertFieldContents(VAR df: PDatafileInfo; CONST tmpStr:String):String;
  Function  ProgressStep(CONST MaxVal,CurVal: Integer):Boolean;
  Function  FormatNumberToIndex(s:String):str30;
  Function  GetColors(s:String; VAR txtcolor,bgcolor, HighLightColor:Byte; VAR IsEpiInfo:Boolean):Boolean;
  Procedure SaveScreenCoords(VAR df: PDatafileInfo);
  Function  LoadScreenCoords(VAR df: PDatafileInfo):Boolean;
  Procedure InitCryptograph;   //&&
  Function  EncryptString(CONST s,key: String):String;
  Function  DecryptString(CONST s,key: String):String;
  Function  GetEncodedLength(decodedlength: byte):byte;     //&&
  Function  GetDecodedLength(encodedlength: byte):byte;     //&&
  Function  RemoveQuotes(s:String):String;
  Function  GetPw(Filename: String):String;
  Procedure StorePw(Filename, pw:String);
  Procedure ResetVarifiedFlag(df:PDatafileInfo);
  Procedure SetVarifiedFlag(df:PDataFileInfo);
  function  PasswordIslegal(const pw: string):boolean;
  function  getRandomPadding(len: integer):string;
  function  boolean2string(val: boolean):string;
  function  string2boolean(val: string):boolean;
  function explode(const s:string;separator:char):TdynArrayString;

implementation

{$IFNDEF epidat}
USES
  MainUnit, BackUpUnit, CheckErrorUnit;
{$ENDIF}



PROCEDURE DestroyFieldList(VAR AList:TList);
VAR
  n:integer;
BEGIN
  FOR n:=0 TO AList.Count-1 DO
    Dispose(AList.Items[n]);
  AList.Free;
  AList:=NIL;
END;  //DestroyFieldList

PROCEDURE DestroyValueLabels(VAR ALabelList:TStrings);
VAR
  n:Integer;
  tmpLabelRec,NextLabelRec:PLabelRec;
BEGIN
  IF ALabelList.Count>0 THEN
    BEGIN
      FOR n:=0 TO ALabelList.Count-1 DO
        BEGIN
          tmpLabelRec:=PLabelRec(ALabelList.Objects[n]);
          NextLabelRec:=NIL;
          REPEAT
            IF tmpLabelRec<>NIL THEN NextLabelRec:=tmpLabelRec^.Next;
            IF tmpLabelRec<>NIL THEN Dispose(tmpLabelRec);
            tmpLabelRec:=NextLabelRec;
          UNTIL NextLabelRec=NIL;
        END;  //for n
    END;  //if count>0
  ALabelList.Free;
  ALabelList:=NIL;
END;

Function IsDriveReady(DriveLetter:Char):Boolean;
VAR
  OldErrorMode:Word;
  OldDir:String;
BEGIN
  OldErrorMode:=SetErrorMode(SEM_NOOPENFILEERRORBOX);
  GetDir(0,OldDir);
  {$I-}
  ChDir(DriveLetter+':\');
  {$I+}
  IF IOResult<>0 THEN Result:=False ELSE Result:=True;
  ChDir(OldDir);
  SetErrorMode(OldErrorMode);
END;  //IsDriveReady

Function FontStyleToByte(AStyle:TFontStyles):Byte;
VAR
  b:Byte;
BEGIN
  {Result is bit-coded
  Bold=0001b Italic=0010b
  Underline=0100b  StrikeOut=1000b}
  b:=0;
  IF (fsBold in AStyle) THEN b:=1;
  IF (fsItalic in AStyle) THEN b:=b OR 2;
  IF (fsUnderLine in AStyle) THEN b:=b OR 4;
  IF (fsStrikeOut in AStyle) THEN b:=b OR 8;
  Result:=b;
END;  //function FontStyleToByte

Function ByteToFontStyle(AByte:Byte):TFontStyles;
VAR
  s:TFontStyles;
BEGIN
  s:=[];
  IF (AByte AND 1)=1 THEN s:=[fsBold];
  IF (AByte AND 2)=2 THEN s:=s+[fsItalic];
  IF (AByte AND 4)=4 THEN s:=s+[fsUnderLine];
  IF (AByte AND 8)=8 THEN s:=s+[fsStrikeOut];
  Result:=s;
END;  //function ByteToFontStyle

Function  eStrToFloat(s: String):Double;
VAR
  n:Integer;
BEGIN
  FOR n:=1 TO Length(s) DO
    BEGIN
      IF s[n]=',' THEN s[n]:=DecimalSeparator;
      IF s[n]='.' THEN s[n]:=DecimalSeparator;
    END;
  Result:=StrToFloat(s);
END;  //function eStrToFloat

Function cFill(c:Char; Len:Integer):String;
VAR
  s:String;
  n:Integer;
BEGIN
  s:='';
  FOR n:=1 TO Len DO s:=s+c;
  Result:=s;
END;   //function Fill

Procedure DisposeCommandList(VAR AList:TList);
VAR
  n:Integer;
  tmpCmdRec:TCmds;
BEGIN
  FOR n:=0 TO AList.Count-1 DO
    BEGIN
      tmpCmdRec:=PCmds(AList.Items[n])^;
      CASE tmpCmdRec.Command OF
        cmdIF:
          BEGIN
            IF tmpCmdRec.IfCmds<>NIL THEN DisposeCommandList(tmpCmdRec.IfCmds);
            IF tmpCmdRec.ElseCmds<>NIL THEN DisposeCommandList(tmpCmdRec.ElseCmds);
          END;
      END;  //case
      Dispose(Alist.Items[n]);
    END;  //for
  AList.Free;
  AList:=NIL;
END;  //procedure DisposeCommandList


Procedure DisposeFieldList(VAR AList:TList);
VAR
  n:Integer;
BEGIN
  FOR n:=0 TO AList.Count-1 DO
    BEGIN
      IF PeField(AList.Items[n])^.AfterCmds<>NIL
      THEN DisposeCommandList(PeField(AList.Items[n])^.AfterCmds);
      IF PeField(AList.Items[n])^.BeforeCmds<>NIL
      THEN DisposeCommandList(PeField(AList.Items[n])^.BeforeCmds);
      Dispose(AList.Items[n]);
    END;
  AList.Free;
  AList:=NIL;
END;  //procedure DisposeFieldList

Procedure ResetDatafile(VAR df:PDatafileInfo);
VAR
  n:Integer;
BEGIN
  WITH df^ DO
    BEGIN
      if assigned(df^.GCPproject) then df^.GCPproject.LogAppend(df,LOG_RECCLOSED,0,'','');
      RECFilename:='';
      QESFilename:='';
      CHKFilename:='';
      IndexFilename:='';
      FileLabel:='';
      IF Assigned(FieldList) THEN DisposeFieldList(FieldList);
      IF Assigned(ValueLabels) THEN DestroyValueLabels(ValueLabels);
      IF Assigned(RecBuf) THEN FreeMem(RecBuf);
      Datfile.Free;  //§§§
      Datfile:=NIL;  //§§§
      {$I-}
      //CloseFile(Datfile);
      //n:=IOResult;
      CloseFile(IndexFile);
      n:=IOResult;
      {$I+}
      HasCheckFile:=False;
      HasRepeatField:=False;
      IDNUMField:=-1;
      Offset:=0;
      RecLength:=0;
      ShortRecLength:=0;
      CurRecord:=0;
      CurRecDeleted:=False;
      CurRecVerified:=False;
      CurRecModified:=False;
      NumRecords:=0;
      CurIDNumber:=0;
      FirstIDNumber:=0;
      DatForm:=NIL;
      DataFormCreated:=False;
      ChkForm:=NIL;
      CheckFormCreated:=False;
      ChkTopComments:=NIL;
      EpiInfoFieldNaming:=False;
      UpdateFieldnameInQuestion:=False;
      TypeStatusBarField:=-1;
      IF Index<>NIL THEN Index.Free;
      Index:=NIL;
      IF SortIndex<>NIL THEN SortIndex.Free;
      SortIndex:=NIL;
      FOR n:=1 TO MaxIndices DO
        BEGIN
//          IF Index[n]<>NIL THEN Index[n].Free;
//          Index[n]:=NIL;
          IndexFields[n]:=-1;
          IndexIsUnique[n]:=False;
        END;
      IndexCount:=0;
//      IF ComIndex<>NIL THEN ComIndex.Free;
      IF FieldNames<>NIL THEN FieldNames.Free;
      FieldNames:=NIL;
      IF FieldNamesList<>NIL THEN FieldNamesList.Free;
      FieldNamesList:=NIL;
      HasDefined:=False;
      IF DefList<>NIL THEN
        BEGIN
          FOR n:=0 TO DefList.Count-1 DO
            Dispose(Pointer(DefList.Objects[n]));
          DefList.Free;
          DefList:=NIL;
        END;
      IF (NumberOfOpenDatafiles=0) AND (GlobalDefList<>NIL) THEN
        BEGIN
          FOR n:=0 TO GlobalDefList.Count-1 DO
            Dispose(Pointer(GlobalDefList.Objects[n]));
          GlobalDefList.Free;
          GlobalDefList:=NIL;
        END;
      IF NumberOfOpenDatafiles=0 THEN
        BEGIN
          RelateFiles.Free;
          RelateMothers.Free;
          RelateFiles:=NIL;
          RelateMothers:=NIL;
          MissingAction:=maRejectMissing;
        END;
      IF Assigned(BeforeFileCmds)   THEN DisposeCommandList(BeforeFileCmds);
      IF Assigned(AfterFileCmds)    THEN DisposeCommandList(AfterFileCmds);
      IF Assigned(BeforeRecordCmds) THEN DisposeCommandList(BeforeRecordCmds);
      IF Assigned(AfterRecordCmds)  THEN DisposeCommandList(AfterRecordCmds);
      IF Assigned(RecodeCmds)       THEN DisposeCommandList(RecodeCmds);
      IF Assigned(LastCommands)     THEN DisposeCommandList(LastCommands);
      IF Assigned(AssertList)       THEN AssertList.Free;
      IF Assigned(BackupList)       THEN BackupList.Free;
      BackupList:=NIL;
      IsRelateTop:=False;
      IsRelateFile:=False;
      HasRelate:=False;
      RelateMother:=NIL;
      One2One:=False;
      LatestActiveControl:=NIL;
      CanActivate:=False;
      RelateCalled:=False;
      UseFilter:=False;
      OKToBackup:=False;
      HasCrypt:=False;
      HasIncludeCmd:=False;
      GlobalTypeCom:=False;
      GlobalMissingValues[0]:='';
      GlobalMissingValues[1]:='';
      GlobalMissingValues[2]:='';
      GlobalDefaultValue:='';
      if assigned(GCPproject) then GCPProject.Free;
      GCPProject:=NIL;
      IF FindOpt<>NIL THEN Dispose(FindOpt);
      IsInSearchForm:=False;
      Key:='';
      IsInBeforeCmds:=False;   //&&
      IF Assigned(UDFList) THEN UDFList.Free;
      UDFList:=NIL;
      IF ModuleInfo.ModuleID>0 THEN EpiUnLoadModule(ModuleInfo);
      IF RelateInfo<>NIL THEN
        BEGIN
          DisposeRelateInfo(RelateInfo);
          RelateInfo:=NIL;
        END;
      SearchForm:=NIL;
      IF Assigned(dbDf) THEN DisposeDataFilePointer(dbDf);
      ShowLastRecord:=False;
    END;  //with
END;  //procedure ResetDatafile

{$IFNDEF epidat}
Procedure ErrorMsg(CONST s:String);
BEGIN
  Screen.Cursor:=crDefault;
  eDlg(s,mtError,[mbOK],0);
END;  //procedure ErrorMsg
{$ENDIF}

Function ZeroFormatInteger(q: Integer):String;
BEGIN
  Result:=IntToStr(q);
  IF (q<10) AND (q>=0) THEN Result:='0'+Result;
END;   //ZeroFormatInteger

Function GetDatafilePointer(VAR df:PDatafileInfo):Boolean;
VAR
  n:Integer;
BEGIN
  df:=NIL;
  IF NumberOfOpenDatafiles=MaxNumberOfDatafiles THEN
    BEGIN
      {$IFDEF epidat}
      epiErrorCode:=EPI_TABLEFULL_ERROR;
      {$ENDIF}
      Result:=False;
      Exit;
    END;
  INC(NumberOfOpenDatafiles);
  TRY
    New(df);
    FillChar(df^,SizeOf(TDatafileInfo),#0);
    df^.FieldList:=TList.Create;
    df^.ValueLabels:=TStringList.Create;
    df^.TypeStatusBarField:=-1;
    IF NumberOfOpenDatafiles=1 THEN GlobalDefList:=TStringList.Create;
    Result:=True;
  EXCEPT
    {$IFNDEF epidat}
    ErrorMsg(format(Lang(20204),[121]));   //'Out of memory (reference-code 121).'
    {$ELSE}
    epiErrorCode:=EPI_NO_MEMORY;
    {$ENDIF}
    df^.FieldList.Free;
    df^.ValueLabels.Free;
    IF df<>NIL THEN Dispose(df);
    IF NumberOfOpenDatafiles>0 THEN DEC(NumberOfOpenDatafiles);
    Result:=False;
  END;  //try..Except
  df^.Index:=NIL;
  df^.SortIndex:=NIL;
  FOR n:=1 TO MaxIndices DO
    BEGIN
//      df^.Index[n]:=NIL;
      df^.IndexFields[n]:=-1;
      df^.IndexIsUnique[n]:=False;
    END;
  WITH df^ DO
    BEGIN
//      ComIndex:=NIL;
      RecBuf:=NIL;
      DefList:=NIL;
      BeforeFileCmds:=NIL;
      AfterFileCmds:=NIL;
      BeforeRecordCmds:=NIL;
      AfterRecordCmds:=NIL;
      RecodeCmds:=NIL;
      AssertList:=NIL;
      LastCommands:=NIL;
      ChkTopComments:=NIL;
      AutoSave:=GlobalAutoSave;
      Confirm:=GlobalConfirm;

      IsRelateTop:=False;
      IsRelateFile:=False;
      IsInRelate:=False;
      RelateMother:=NIL;
      One2One:=False;
      LatestActiveControl:=NIL;
      CanActivate:=False;
      RelateCalled:=False;
      UseFilter:=False;
      Datfile:=NIL;
      BackupList:=NIL;
      OKToBackup:=False;
      UDFList:=NIL;
      ModuleInfo.ModuleID:=0;
      FieldNames:=NIL;
      FieldNamesList:=NIL;
      RelateInfo:=NIL;
      QuestionText:=COLOR_ENDCOLORS;
      QuestionBg:=COLOR_ENDCOLORS;
      FieldText:=COLOR_ENDCOLORS;
      FieldBg:=COLOR_ENDCOLORS;
      BackGround:=COLOR_ENDCOLORS;
      IsFinding:=False;
      FieldHighlightAct:=FieldHighlightActive;
      fieldHighlightCol:=FieldHighlightColor;
      dfModified:=False;
      HasCrypt:=False;   //&&
      Key:='';         //&&
      DontGetPassword:=False;
      isInBeforeCmds:=False;  //&&
      HasIncludeCmd:=False;
      GlobalTypeCom:=False;
      GlobalMissingValues[0]:='';
      GlobalMissingValues[1]:='';
      GlobalMissingValues[2]:='';
      GCPProject:=NIL;
      FindOpt:=NIL;
      IsInSearchForm:=False;
      SearchForm:=NIL;
      DoubleEntry:=False;
      dbFilename:='';
      dbDf:=NIL;
      dbIgnoretext:=False;
      DatForm:=NIL;
      ShowLastRecord:=False;
    END;
END;  //function GetDatafilePointer

Procedure DisposeDatafilePointer(VAR df:PDatafileInfo);
VAR
  //tmpList: TStringList;
  DoBackup: Boolean;
BEGIN
  DoBackup:=False;
  IF df=NIL THEN Exit;
  //{$IFNDEF epidat}
  //IF (NOT df^.IsRelateFile) AND (df^.BackupList<>NIL) AND (df^.OKToBackup) THEN
  //  BEGIN
  //    DoBackup:=True;
  //    tmpList:=TStringList.Create;
  //    tmpList.AddStrings(df^.BackupList);
  //  END;
  //{$ENDIF}
  IF NumberOfOpenDatafiles>0 THEN DEC(NumberOfOpenDatafiles);
  ResetDatafile(df);
  Dispose(df);
  df:=NIL;
  //{$IFNDEF epidat}
  //IF DoBackup THEN
  //  BEGIN
  //    BackupCommand(tmpList);
  //    tmpList.Free;
  //  END;
  //{$ENDIF}
END;

Procedure DisposeLabelRec(VAR ALabel:PLabelRec);
VAR
  NextLabelRec:PLabelRec;
BEGIN
  WHILE ALabel<>NIL DO
    BEGIN
      NextLabelRec:=ALabel^.Next;
      Dispose(ALabel);
      ALabel:=NextLabelRec;
    END;
END;

Procedure DisposeRelateInfo(VAR ARelateInfo: PRelateInfo);
VAR
  NextInfo: PRelateInfo;
BEGIN
  WHILE ARelateInfo<>NIL DO
    BEGIN
      NextInfo:=ARelateInfo^.Next;
      Dispose(ARelateInfo);
      ARelateInfo:=NextInfo;
    END;
END;


Function IsInteger(s:String):Boolean;
VAR
  t:Integer;
BEGIN
  Result:=True;
  s:=trim(s);
  IF s='' THEN Result:=False;
  IF POS(' ',s)>0 THEN Result:=False;
  IF POS('-',s)>1 THEN Result:=False;
  IF Pos('+',s)>1 THEN Result:=False;
  IF Result THEN
    FOR t:=1 TO Length(s) DO
      IF NOT (s[t] in IntegerChars) THEN Result:=False;
END;   //Function IsInteger

Function IsFloat(s:String):Boolean;
VAR
  t:Integer;
BEGIN
  Result:=True;
  s:=trim(s);
  FOR t:=1 TO Length(s) DO
    IF NOT ( s[t] in FloatChars ) THEN Result:=False;
  IF POS(' ',s)>0 THEN Result:=False;
  IF POS('-',s)>1 THEN Result:=False;
END;  //function IsFloat

Function IsLeapYear(AYear: Word):Boolean;
BEGIN
  Result:=FALSE;
  IF (AYear MOD 4 = 0) THEN Result:=TRUE;
  IF (AYear MOD 100 = 0) AND (AYear MOD 400 <> 0) THEN Result:=False;
END;   //IsLeapYear

Function dkDayOfWeek(ADate: TDateTime):Integer;
{Makes DayOfWeek where monday=1, sunday=7}
BEGIN
  Result:=DayOfWeek(ADate);
  IF Result=1 THEN Result:=7 ELSE DEC(Result);
END;   //dkDayOfWeek


FUNCTION WeekNum(ADate: TDateTime):Integer;
VAR
  midWeekNum:Integer;
  FirstDayWeekOne:TDateTime;
  CurY,CurM,curD:Word;

BEGIN  //WeekNum
  DecodeDate(ADate,CurY,CurM,CurD);
  FirstDayWeekOne:=EncodeDate(CurY,1,4)-
                   (dkDayOfWeek(EncodeDate(CurY,1,4))-1);
  IF ADate<FirstDayWeekOne THEN
    BEGIN
      MidWeekNum:=52;
      {Prev. year has 53 weeks if 1st January is a Thursday
       or if previous year is a leap year and 1st January is a Wednessday}
      IF (dkDayOfWeek(EncodeDate(CurY-1,1,1))=4)
          OR ( (dkDayOfWeek(EncodeDate(CurY-1,1,1))=3)
               AND (IsLeapYear(CurY-1)) )
          THEN INC(MidWeekNum);
    END
  ELSE
    BEGIN
      MidWeekNum:=Trunc((ADate-FirstDayWeekOne)/7)+1;
      IF MidWeekNum=53 THEN
        BEGIN  //Has current year 53 weeks?
          IF (dkDayOfWeek(EncodeDate(CurY,1,1))=4)
              OR ( (dkDayOfWeek(EncodeDate(CurY,1,1))=3)
                   AND (IsLeapYear(CurY)) )
              THEN MidWeekNum:=53 ELSE MidWeekNum:=1;
        END;  //if MidWeekNum=53
    END;   //if not ADate<FirstDayWeekOne
  WeekNum:=MidWeekNum;
END;   //WeekNum


FUNCTION NameIsUnique(VAR TempName:String; df:PDatafileInfo; WantedLength:Byte):Boolean;
VAR
  StillLooking:BOOLEAN;
  NumStr:STRING[3];
  i, n, Number: Integer;
  AlfaStr,tName:STRING[10];

BEGIN
  Result:=True;
  IF df=NIL THEN Exit;
  IF df^.FieldList=NIL THEN Exit;
  IF df^.FieldList.Count=0 THEN Exit;
  tName:=trim(AnsiUpperCase(TempName));
  n:=0;
  REPEAT
    IF ANSIUpperCase(trim(PeField(df^.FieldList.Items[n])^.FName))=tName THEN Result:=False;
    INC(n);
  UNTIL (NOT Result) OR (n>df^.FieldList.Count-1);
  IF NOT Result THEN
    BEGIN  //a dublicate name is found
      IF (Length(TempName)>WantedLength)
        THEN TempName:=COPY(TempName,1,WantedLength);
      WHILE (Length(TempName)<WantedLength) DO TempName:=TempName+' ';
      NumStr:='';
      StillLooking:=TRUE;
      i:=WantedLength;
      WHILE (i>0) AND (Length(NumStr)<3) AND StillLooking DO
        IF (TempName[i] in NumChars) THEN
          BEGIN
            NumStr:=TempName[i]+NumStr;
            TempName[i]:=' ';
          END
        ELSE IF (TempName[i] in AlfaChars) THEN StillLooking:=FALSE
             ELSE DEC(i);
      IF (i=0) OR (NumStr='') THEN Number:=0
      ELSE Number:=StrToInt(NumStr);
      INC(Number);
      IF (Number>999) THEN TempName:='DUMMY1'
      ELSE
        BEGIN
          NumStr:=IntToStr(Number);
          AlfaStr:=trim(COPY(TempName,1,i));    //  <====   AlfaStr:=COPY(TempName,1,i-1)
          WHILE (Length(AlfaStr)+Length(NumStr)>WantedLength) DO
            AlfaStr:=COPY(AlfaStr,1,Length(AlfaStr)-1);
          TempName:=AlfaStr+NumStr;
        END;   //if new number<1000
      WHILE (Length(TempName)<WantedLength) DO TempName:=TempName+' ';
    END;   //a dublicate name is found
END;   //NameIsUnique



Function FirstWord(s:String):str10;
VAR
  n:Integer;
BEGIN
  s:=trim(s);
  WHILE Pos(#9,s)>0 DO s[Pos(#9,s)]:=' ';
  n:=Pos(' ',s);
  IF n=0 THEN n:=Length(s)+1;
  IF n>FieldNameLen THEN n:=FieldNameLen+1;
//  IF n>0 THEN Result:=Copy(s,1,n-1) ELSE Result:='';
  Result:=Copy(s,1,n-1);
END;  //function FirstWord


Function mibDateToStr(d:TDateTime; Style:TFeltTyper):String;
BEGIN
  IF (Style=ftEuroDate) or (Style=ftEuroToday) THEN Result:=FormatDateTime('dd"/"mm"/"yyyy',d)
  ELSE IF (Style=ftYMDDate) or (Style=ftYMDtoday) THEN Result:=FormatDateTime('yyyy"/"mm"/"dd',d)  //&&
  ELSE Result:=FormatDateTime('mm"/"dd"/"yyyy',d);
END;

Function mibIsDate(VAR s:String; Style:TFeltTyper):Boolean;

VAR
  tmpS,eMonthStr,eDayStr,eYearStr:String[10];
  day,month,year,tmpDay:Word;
  d2,m2:Word;
  tmpDate:TDateTime;
  qq:Integer;  //&&
BEGIN
  Result:=True;
  tmpS:=s;
  IF trim(tmpS)='' THEN
    BEGIN
      Result:=False;
      Exit;
    END;
  IF pos('/',tmpS)<>0 THEN
    BEGIN   //first slash is found
      IF (Style=ftYMDDate) OR (Style=ftYMDToday) THEN  //&&
        BEGIN
          qq:=pos('/',tmpS);
          tmpS[qq]:='¤';
          IF pos('/',tmpS)>0 THEN
            BEGIN
              //String has two slashes meaning year is included
              eYearStr:=Copy(tmpS,1,pos('¤',tmpS)-1);
              Delete(tmpS,1,pos('¤',tmpS));    //deletes year and separator
              eMonthStr:=copy(tmpS,1,pos('/',tmpS)-1);
              Delete(tmpS,1,pos('/',tmpS));   //deletes month and second separator
              eDayStr:=tmpS;
            END
          ELSE
            BEGIN
              //String has one slash meaning year is not included
              eYearStr:='';
              eMonthStr:=copy(tmpS,1,pos('¤',tmpS)-1);
              Delete(tmpS,1,pos('¤',tmpS));  //deletes month and separator
              eDayStr:=tmpS;
            END;
        END  //if ftYMDDate
      ELSE
        BEGIN
          eDayStr:=Copy(tmpS,1,pos('/',tmpS)-1);
          Delete(tmpS,1,pos('/',tmpS));
          IF pos('/',tmpS)<>0 THEN
            BEGIN  //second slash is found
              eMonthStr:=Copy(tmpS,1,pos('/',tmpS)-1);
              Delete(tmpS,1,pos('/',tmpS));
              eYearStr:=tmpS;
              IF trim(eYearStr)='' THEN eYearStr:='';
            END
          ELSE
            BEGIN
              eMonthStr:=tmpS;
              IF trim(eDayStr)='' THEN eDayStr:='';
              eYearStr:='';
            END;   //if there is a second slash
        END;  //if not YMDDate
    END   //if there is a first slash
  ELSE
    BEGIN   //the string contains no slash
      IF (Style=ftYMDDate) OR (Style=ftYMDToday) THEN  //&&
        BEGIN
          eMonthStr:='';
          eDayStr:='';
          eYearStr:='';
          CASE Length(tmpS) OF
            1,2: eDayStr:=trim(tmpS);
            4:   BEGIN
                   eMonthStr:=Copy(tmpS,1,2);
                   eDayStr:=Copy(tmpS,3,2);
                 END;
            6:   BEGIN
                   eYearStr:=Copy(tmpS,1,2);
                   eMonthStr:=Copy(tmpS,3,2);
                   eDayStr:=Copy(tmpS,5,2);
                 END;
            8:   BEGIN
                   eYearStr:=Copy(tmpS,1,4);
                   eMonthStr:=Copy(tmpS,5,2);
                   eDayStr:=Copy(tmpS,7,2);
                 END;
          ELSE
            result:=False;
          END;  //case
        END  //if ftYMDDate
      ELSE
        BEGIN
          While Length(tmpS)<8 DO tmpS:=tmpS+' ';
          eDayStr:=Copy(tmpS,1,2);
          eMonthStr:=Copy(tmpS,3,2);
          eYearStr:=Copy(tmpS,5,4);
        END;
    END;  //if string has no slash
  IF (trim(eMonthStr)<>'') AND (isInteger(eMonthStr))
    THEN Month:=StrToInt(trim(eMonthStr)) ELSE Result:=False;
  IF (trim(eDayStr)<>'') AND (IsInteger(eDayStr))
    THEN Day:=StrToInt(trim(eDayStr)) ELSE Result:=False;
  IF (trim(eYearStr)='') THEN
    BEGIN
      DecodeDate(Date,Year,m2,d2);
      eYearStr:=IntToStr(Year);
    END
  ELSE
    IF IsInteger(eYearStr)
      THEN Year:=StrToInt(trim(eYearStr))
    ELSE
      BEGIN
        Result:=False;
        Year:=0;
      END;
  IF (Style=ftDate) or (Style=ftToday) THEN
    BEGIN
      tmpDay:=Day;
      Day:=Month;
      Month:=tmpDay;
    END;
  IF (Year>=0)  AND (Year<50)  THEN Year:=Year+2000;
  IF (Year>=50) AND (Year<100) THEN Year:=Year+1900;
  IF (Month>12) OR  (Month<1)  THEN Result:=False
  ELSE
    BEGIN
      IF (Day<1) OR (Day>DaysInMonth[Month]) THEN Result:=False;
      IF (Result) AND (Day=29) AND (Month=2)
        THEN IF IsLeapYear(Year) THEN Result:=True ELSE Result:=False;
    END;
  {Formatter output}
  IF Result THEN  //legal date entered
    BEGIN
      tmpDate:=EncodeDate(Year,Month,Day);
      s:=mibDateToStr(tmpDate,Style);
    END;
END;

Function mibStrToDate(s:String; Style:TFeltTyper):TDateTime;
VAR
  day,month,year,tmpDay:word;
BEGIN
  IF mibIsDate(s,Style) THEN
    BEGIN
      IF (Style=ftYMDDate) OR (Style=ftYMDToday) THEN  //&&
        BEGIN
          year:=StrToInt(Copy(s,1,4));
          month:=StrToInt(Copy(s,6,2));
          day:=StrToInt(Copy(s,9,2));
        END
      ELSE
        BEGIN
          day:=StrToInt(Copy(s,1,2));
          month:=StrToInt(Copy(s,4,2));
          year:=StrToInt(Copy(s,7,4));
          IF (Style=ftDate) or (Style=ftToday) THEN
            BEGIN
              tmpDay:=Day;
              Day:=Month;
              Month:=tmpDay;
            END;
        END;
      Result:=EncodeDate(year,month,day);
    END
  ELSE Result:=0;
END;

Function GetCommentLegalText(CONST s:String; ComLegRec: PlabelRec):String;
BEGIN
  Result:='';
  IF ComLegRec<>NIL THEN
    BEGIN
      WHILE (ComLegRec<>NIL) AND (Result='') DO
        BEGIN
          IF ComLegRec^.Value[1]<>'*' THEN    //###
            BEGIN
              IF trim(s)=trim(ComLegRec^.Value) THEN Result:=ComLegRec^.Text;
            END;
          ComLegRec:=ComLegRec^.Next;
        END;  //while
    END;  //if
END;  //function GetCommentLegalText

Function GetValueFromCommentLegal(CONST s:String; ComLegRec: PLabelRec):String;
BEGIN
  Result:='';
  IF ComLegRec<>NIL THEN
    BEGIN
      WHILE (ComLegRec<>NIL) AND (Result='') DO
        BEGIN
          IF ComLegRec^.Value[1]<>'*' THEN  //###
            BEGIN
              IF trim(s)=trim(ComLegRec^.Text) THEN Result:=ComLegRec^.Value;
            END;
          ComLegRec:=ComLegRec^.Next;
        END;  //while
    END;  //if
END;   //function GetValueFromCommentLegal

Procedure ResetCheckProperties(VAR AField: PeField);
BEGIN
  WITH AField^ DO
    BEGIN
      FMustEnter:=False;
      FRepeat:=False;
      FMin:='';
      FMax:='';
      FLegal:='';
      FRangeDefined:=False;
      FCommentLegalRec:=NIL;
      FShowLegalPickList:=False;
      FPickListNoSelect:=False;
      FFieldComments:='';
      FValueLabel:='';
      FJumps:='';
      FJumpResetChar:=#0;
      FNoEnter:=False;
      FIndex:=0;
      FIsTypeStatusBar:=False;
      FTypeColor:=0;
      FTypeComments:=False;
      FTypeString:=False;
      FTypeCommentField:=-1;
      FConfirm:=False;
      FTopOfScreen:=False;
      FTopOfScreenLines:=0;
      FTypeField:=NIL;
      AfterCmds:=NIL;
      BeforeCmds:=NIL;
      FMissingValues[0]:='';
      FMissingValues[1]:='';
      FMissingValues[2]:='';
      FHasGlobalMissing:=false;
      FAutosearch:=False;
      FAutoFields:='';
      FAutoList:=False;
      FDefaultValue:='';
      FHasGlobalDefaultValue:=false;
    END;
END;  //procedure ResetCheckProperties

Procedure CopyCheckProperties(VAR Source,Destination: PeField);
BEGIN
  WITH Destination^ DO
    BEGIN
      FMustEnter:=Source^.FMustEnter;
      FRepeat:=Source^.FRepeat;
      FMin:=Source^.FMin;
      FMax:=Source^.FMax;
      FLegal:=Source^.FLegal;
      FRangeDefined:=Source^.FRangeDefined;
      FCommentLegalRec:=Source^.FCommentLegalRec;
      FShowLegalPickList:=Source^.FShowLegalPickList;
      FPickListNoSelect:=Source^.FPickListNoSelect;
      FFieldComments:=Source^.FFieldComments;
      FValueLabel:=Source^.FValueLabel;
      FJumps:=Source^.FJumps;
      FJumpResetChar:=Source^.FJumpResetChar;
      FNoEnter:=Source^.FNoEnter;
      FIndex:=Source^.FIndex;
      FIsTypeStatusBar:=Source^.FIsTypeStatusBar;
      FTypeColor:=Source^.FTypeColor;
      FTypeComments:=Source^.FTypeComments;
      FTypeString:=Source^.FTypeString;
      FTypeCommentField:=Source^.FTypeCommentField;
      FConfirm:=Source^.FConfirm;
      FTopOfScreen:=Source^.FTopOfScreen;
      FTopOfScreenLines:=Source^.FTopOfScreenLines;
      FTypeField:=NIL;
      AfterCmds:=Source^.AfterCmds;
      BeforeCmds:=Source^.BeforeCmds;
      FMissingValues[0]:=Source^.FMissingValues[0];
      FMissingValues[1]:=Source^.FMissingValues[1];
      FMissingValues[2]:=Source^.FMissingValues[2];
      FHasGlobalMissing:=Source^.FHasGlobalMissing;
      FAutosearch:=Source^.FAutosearch;
      FAutoFields:=Source^.FAutoFields;
      FAutoList:=Source^.FAutoList;
      FDefaultValue:=Source^.FDefaultValue;
      FHasGlobalDefaultValue:=Source^.FHasGlobalDefaultValue;
    END;
END;  //procedure CopyCheckProperties



Function  HasCheckProperties(VAR AField: PeField):Boolean;
BEGIN
  WITH AField^ DO
    BEGIN
      IF (FMin<>'') OR (FMax<>'') OR (FLegal<>'') OR (FJumps<>'')
      OR (trim(FValueLabel)<>'') OR (FMustEnter=True) OR (FRepeat=True)
      OR (FDefaultValue<>'')
      OR (FFieldComments<>'') OR (AfterCmds<>NIL) OR (BeforeCmds<>NIL)
      OR (FNoEnter=True) OR (FIsTypeStatusBar=True) OR (FTypeComments)
      OR (FIndex>0) OR (FConfirm) OR (FTopOfScreen) OR (FAutosearch)
      OR (FMissingValues[0]<>'') OR (FMissingValues[1]<>'') OR (FMissingValues[2]<>'')
      THEN Result:=True ELSE Result:=False;
    END;
END;  //function HasCheckProperties

Function HasSpecialChecks(VAR AField: PeField):Boolean;
BEGIN
  WITH AField^ DO
    BEGIN
      IF (FFieldComments<>'') OR (AfterCmds<>NIL) OR (BeforeCmds<>NIL)
      OR (FNoEnter=True) OR (FIsTypeStatusBar=True) OR (FTypeComments)
      OR (FIndex>0) OR (FConfirm)
      THEN Result:=True ELSE Result:=False;
    END;
END;  //function HasSpecialChecks


Function  IsCompliant(s:String; Style:TFelttyper):Boolean;
BEGIN
  Result:=True;
  CASE Style OF
    ftInteger,ftIDNUM: IF NOT IsInteger(s) THEN Result:=False;
    ftFloat:   IF NOT IsFloat(s)   THEN Result:=False;
    ftBoolean: IF NOT (s[1] in BooleanChars) THEN Result:=False;
    ftDate,ftEuroDate,ftToday,ftEuroToday,ftYMDDate,ftYMDToday: IF NOT mibIsDate(s,Style) THEN Result:=False;
    ftUpperAlfa: IF s<>AnsiUpperCase(s) THEN Result:=False;
  END;
END;  //function IsComliant

Procedure Double2SingleQuotes(VAR s:String);
BEGIN
  WHILE pos('"',s)>0 DO
    s[Pos('"',s)]:='''';
END;

Procedure Single2DoubleQuotes(VAR s:String);
BEGIN
  WHILE pos('''',s)>0 DO
    s[Pos('''',s)]:='"';
END;

Function GetFieldNumber(Const s:String; VAR df:PDatafileInfo):Integer;
VAR
  n:Integer;
  tmpS:String;
BEGIN
  Result:=-1;
  IF df^.FieldList=NIL THEN Exit;
  IF df^.FieldList.Count=0 THEN Exit;
  tmpS:=trim(s);
  n:=-1;
  REPEAT
    INC(n);
    //IF tmpS=AnsiUpperCase(trim(PeField(df^.FieldList.Items[n])^.FName))
    IF CompareText(tmpS,trim(PeField(df^.FieldList.items[n])^.FName))=0
    THEN Result:=n;
  UNTIL (n=df^.FieldList.Count-1) or (Result<>-1);
END;


Function GetField(CONST s:String; VAR df:PDatafileInfo):PeField;
VAR
  n:Integer;
  tmpS:String;
BEGIN
  Result:=NIL;
  IF df^.FieldList=NIL THEN Exit;
  IF df^.FieldList.Count=0 THEN Exit;
  tmpS:=trim(s);
  n:=-1;
  REPEAT
    INC(n);
    //IF tmpS=AnsiUpperCase(trim(PeField(df^.FieldList.Items[n])^.FName))
    IF Comparetext(tmpS,trim(PeField(df^.FieldList.items[n])^.FName))=0
    THEN Result:=PeField(df^.FieldList.Items[n]);
  UNTIL (n=df^.FieldList.Count-1) OR (Result<>NIL);
END;  //function GetField



Function GetDefField(Const s:String; VAR df:PDatafileInfo):PDefVar;
VAR
  n:Integer;
  Found: Boolean;
BEGIN
  Result:=NIL;
  n:=-1;
  Found:=False;
  IF Assigned(df^.DefList) THEN
    BEGIN
      IF (df^.DefList<>NIL) AND (df^.DefList.Count<>0) THEN
        BEGIN
          REPEAT
            INC(n);
            IF AnsiUpperCase(trim(s))=AnsiUpperCase(trim(df^.defList[n])) THEN Found:=True;
          UNTIL (n=df^.defList.Count-1) or (Found);
          IF Found THEN Result:=PDefVar(df^.DefList.Objects[n]);
        END;
    END;
  {Search list of global vars}
  IF Assigned(GlobalDefList) AND (result=NIL) THEN
    BEGIN
      IF (result=NIL) AND (GlobalDefList<>NIL) AND (GlobalDefList.Count>0) THEN
        BEGIN
          n:=-1;
          Found:=False;
          REPEAT
            INC(n);
            IF AnsiUpperCase(trim(s))=AnsiUpperCase(trim(GlobalDefList[n])) THEN Found:=True;
          UNTIL (n=globalDefList.Count-1) OR (Found);
          IF Found THEN Result:=PDefVar(GlobalDefList.Objects[n]);
        END;
    END;
END;


{$IFNDEF epidat}
Procedure InitLanguage;
VAR
  s,HomePageStr:String;
  tmpVal:Double;
  tmpChar: Char;
  n:Integer;
BEGIN
  IF UsesEnglish THEN LanStr.Clear
  ELSE
    BEGIN
      s:=ExtractFileDir(ParamStr(0))+'\'+CurLanguage+'.lang.txt';
      TRY
        LanStr.LoadFromFile(s);
      EXCEPT
        ErrorMsg(Format('Could not open languagefile %s',[s]));
        UsesEnglish:=True;
        CurLanguage:='English';
      END;
      IF NOT UsesEnglish THEN
        BEGIN
          s:=Lang(101);
          TRY
            tmpVal:=eStrToFloat(s);
          EXCEPT
            tmpVal:=0;
          END;
          IF tmpVal<VersionNumber THEN
            BEGIN
              IF NoLangError=False THEN
                BEGIN
                  //AND (LangVersionCounter<2)
                  //HomePageStr:=Lang(120);
                  //UsesEnglish:=True;
                  //IF (HomePageStr[1]<>'*') AND (HomePageStr[1]<>'[')
                  //THEN s:=s+'Please see '+HomePageStr+' if a language file in '+CurLanguage+
                  //  ' for EpiData '+EpiDataVersion+' exists.'
                  //ELSE s:=s+'Please see www.EpiData.dk if a language file in '+CurLanguage+
                  //  ' for EpiData '+EpiDataVersion+' exists.';
                  TRY
                    CheckErrorForm:=TCheckErrorForm.Create(NIL);
                    WITH CheckErrorForm DO
                      BEGIN
                        IF Lang(50300)='**50300**' THEN
                          BEGIN
                            Label1.Caption:='Incorrect version of language file.';
                            Label2.Caption:='Search www.EpiData.dk for update.';
                            Label4.Caption:='Do you want to use english instead?';
                            CheckBox1.Caption:='Do not show this warning again';
                          END
                        ELSE
                          BEGIN
                            Label1.Caption:=Lang(50300);  //50300=Incorrect version of language file.
                            Label2.Caption:=Lang(50302);  //50302=Search www.EpiData.dk for update.
                            Label4.Caption:=Lang(50304);  //50304=Do you want to use english instead?
                            CheckBox1.Caption:=Lang(50306);  //50306=Do not show this warning again
                          END;
                        Label3.Caption:='';
                        CheckBox1.Checked:=False;
                        IF LangVersionCounter<2 THEN CheckBox1.Visible:=False;
                        n:=ShowModal;
                        IF CheckBox1.Checked THEN NoLangError:=True;
                        INC(LangVersionCounter);
                      END;  //with
                  FINALLY
                    CheckErrorForm.Free;
                  END;  //try..finally
                  IF n=mrYes THEN
                    BEGIN
                      UsesEnglish:=True;
                      CurLanguage:='English';
                    END;
                END;  //IF NoLangError:=False
            END;  //if too low languageversion
          END;
        IF NOT UsesEnglish THEN
          BEGIN
            IF Lang(105)<>'**105**' THEN s:=ExtractFileDir(ParamStr(0))+'\EpiData_'+Lang(105)+'.hlp';
            IF FileExists(s) THEN Application.HelpFile:=s;
          END;
    END;  //if not usesEnglish
  MainForm.InitTranslations;
END;
{$ENDIF}

Function Lang(no: Integer):String;
VAR
  a: Array[0..255] OF Char;
BEGIN
  {$IFNDEF epidat}
  IF UsesEnglish THEN
    BEGIN
      IF LoadString(hInstance,no,a,SizeOf(a))<>0 THEN
        BEGIN
          Result:=StrPas(a);
          WHILE Pos('~',Result)>0
          DO Result[Pos('~',Result)]:=#13;
        END
      ELSE Result:='**'+IntToStr(no)+'**'
    END
  ELSE
    BEGIN
      Result:=LanStr.Values[IntToStr(no)];
      IF Result='' THEN Result:='**'+IntToStr(no)+'**'
      ELSE
        BEGIN
          WHILE Pos('~',Result)>0
          DO Result[Pos('~',Result)]:=#13;
        END;
    END;
  {$ELSE}
  Result:='';
  {$ENDIF}
END;


Function  FitLength(s:String;L: Integer):String;
{Makes sure that a string is exactly L chars in length}
BEGIN
  IF Length(s)>L THEN Result:=Copy(s,1,L)
  ELSE IF Length(s)<L THEN Result:=s+cFill(' ',L-Length(s))
  ELSE Result:=s;
END;

{$IFNDEF epidat}
Procedure TranslateForm(AForm: TForm);
VAR
  n,n2,aTag: Integer;
  s: String;
  AComp: TComponent;
BEGIN
  IF AForm.Tag<>0 THEN AForm.Caption:=Lang(AForm.Tag);
  FOR n:=0 TO AForm.ComponentCount-1 DO
    BEGIN
      aTag:=AForm.Components[n].Tag;
      IF aTag=0 then CONTINUE;
      s:=Lang(aTag);
      (* only for components with Tag <> 0 *)
      if trim(s)='' then CONTINUE;
      AComp:=AForm.Components[n];

      IF AComp is TSpeedButton THEN
        BEGIN
          IF aTag>10000 THEN (AComp AS TSpeedButton).Hint:=s
          ELSE (AComp AS TSpeedButton).Caption:=s;
        END
      ELSE IF AComp is TLabel       THEN (AComp AS TLabel).Caption:=s
      ELSE IF AComp is TStaticText  THEN (AComp AS TStaticText).Caption:=s
      ELSE IF AComp is TPanel       THEN (AComp AS TPanel).Caption:=s
      ELSE IF AComp is TMenuItem    THEN (AComp AS TMenuItem).Caption:=s
      ELSE IF AComp is TGroupBox    THEN (AComp AS TGroupBox).Caption:=s
      ELSE IF AComp is TCheckBox    THEN (AComp AS TCheckBox).Caption:=s
      ELSE IF AComp is TRadioButton THEN (AComp AS TRadioButton).Caption:=s
      ELSE IF AComp is TButton      THEN (AComp AS TButton).Caption:=s
      ELSE IF AComp is TBitBtn      THEN (AComp AS TBitBtn).Caption:=s
      ELSE IF AComp is TPageControl THEN
        BEGIN
          //Translate all pages
          FOR n2:=0 TO (AComp AS TPageControl).PageCount-1 DO
            IF (AComp AS TPageControl).Pages[n2].Tag<>0
            THEN (AComp AS TPageControl).Pages[n2].Caption:=Lang( (AComp AS TPageControl).Pages[n2].Tag );
        END
      ELSE IF AComp is TRadioGroup THEN
        BEGIN
          (AComp AS TRadiogroup).Caption:=s;
          FOR n2:=0 TO (AComp AS TRadiogroup).Items.Count-1 DO
            (AComp AS TRadiogroup).Items[n2]:=Lang(aTag+1+n2);
        END
      ELSE IF AComp is TComboBox THEN
        BEGIN
          FOR n2:=0 TO (AComp AS TComboBox).Items.Count-1 DO
            (AComp AS TComboBox).Items[n2]:=Lang(aTag+n2);
        END;
    END;  //for
END;
{$ENDIF}


Function ReadFromIndex(VAR df:PDatafileInfo; IndexNo,RecNo: Integer):str30;
VAR
  tmpS:str30;
  ptmpS:Array[0..30] of byte absolute tmpS;
BEGIN
  df^.Index.Position:=31+( (RecNo-1)*(31*df^.IndexCount) ) + ( 31*(IndexNo-1) );
  df^.Index.Read(ptmpS,31);
  Result:=tmpS;
END;

Function ReadCommonIndex(VAR df:PDatafileInfo; RecNo: Integer):String;
VAR
  pS:Array[0..310] of Char;
  n:Integer;
BEGIN
  FillChar(pS,310,0);
  df^.Index.Position:=31+((RecNo-1)*(31*df^.IndexCount));
  df^.Index.Read(pS,31*df^.IndexCount);
  Result:=StrPas(pS);
  FOR n:=1 TO df^.IndexCount Do
    Delete(Result,((n-1)*31)+1,1);
END;  //function ReadCommonIndex

Function ReadIndexNoFromSortIndex(VAR df:PDatafileInfo; SortPos: Integer):Integer;
VAR
  n: Integer;
  pN: Array[0..3] of Byte Absolute n;
BEGIN
  df^.SortIndex.Position:=(SortPos-1)*4;
  df^.SortIndex.Read(pN,4);
  Result:=n;
END;  //function ReadIndexNoFromSortIndex


Procedure WriteIndexNoToSortIndex(VAR df:PDatafileInfo; SortPos,num:Integer);
VAR
  pNum:ARRAY[0..3] of byte absolute num;
BEGIN
  df^.SortIndex.Position:=(SortPos-1)*4;
  df^.SortIndex.Write(pNum,4);
END;


Function ReadCommonViaSortIndex(VAR df:PDatafileInfo; SortPos: Integer):String;
VAR
  n:Integer;
  tmpS:String;
BEGIN
  {Returns the common indexvalue pointer to by SortIndex[Posi]}
  n:=ReadIndexNoFromSortIndex(df,SortPos);
  tmpS:=ReadCommonIndex(df,n);
  Result:=tmpS;
END;  //function ReadCommonViaSortIndex


Procedure WriteToIndex(VAR df:PDatafileInfo; IndexNo,RecNo: Integer; s:Str30);
VAR
  tmpS:str30;
  ptmpS:Array[0..30] of byte absolute tmpS;
BEGIN
  df^.Index.Position:=31+( (RecNo-1)*(31*df^.IndexCount) ) + ( 31*(IndexNo-1) );
  tmpS:=s;
  df^.Index.Write(ptmpS,31);
END;

Function SearchIndex(VAR df: PDatafileInfo; IndexNo: Integer; SearchStr: Str30):LongInt;
VAR
  Found:Boolean;
  tmpCurRec: LongInt;
BEGIN
  Found:=False;
  tmpCurRec:=0;
  WHILE (tmpCurRec<df^.NumRecords) AND (NOT Found) DO
    BEGIN
      INC(tmpCurRec);
      Found:=(AnsiCompareText(SearchStr,ReadFromIndex(df,IndexNo,tmpCurRec))=0);
    END;
  IF Found THEN Result:=tmpCurRec ELSE Result:=-1;
END;

Function SearchIndexFrom(VAR df: PDatafileInfo; IndexNo: Integer; SearchStr: str30; RecNo:Integer; direction:TDirections):LongInt;
VAR
  Found:Boolean;
  tmpCurRec,EndRec: LongInt;
BEGIN
  Found:=False;
  tmpCurRec:=RecNo;
  CASE direction OF
    dirForward,dirFirst:  BEGIN  EndRec:=df^.NumRecords;  DEC(tmpCurRec);   END;
    dirBackward,dirLast:  BEGIN  EndRec:=1;               INC(tmpCurRec);   END;
    dirAbsolute:          BEGIN  EndRec:=RecNo;           INC(tmpCurRec);   END;
  END;
  WHILE (tmpCurRec<>EndRec) AND (NOT Found) DO
    BEGIN
      IF (direction=dirForward) OR (direction=dirFirst) THEN INC(tmpCurRec) ELSE DEC(tmpCurRec);
      Found:=(AnsiCompareText(SearchStr,trim(ReadFromIndex(df,IndexNo,tmpCurRec)))=0);
    END;  //while
  IF Found THEN Result:=tmpCurRec ELSE Result:=-1;
END;

Procedure DecryptIndex(VAR df:PDatafileInfo);    //&&
VAR
  AField: PeField;
  n,CurRec: Integer;
  s: str30;
BEGIN
  IF (NOT df^.HasCrypt) OR (df^.Key='') THEN Exit;
  FOR n:=1 TO df^.IndexCount DO
    BEGIN
      AField:=PeField(df^.FieldList.Items[df^.IndexFields[n]]);
      IF AField^.Felttype=ftCrypt THEN
        BEGIN
          FOR CurRec:=1 TO df^.NumRecords DO
            BEGIN
              s:=ReadFromIndex(df,n,CurRec);
              s:=DecryptString(trim(s),df^.Key);
              s:=Format('%-30s',[s]);
              WriteToIndex(df,n,CurRec,s);
            END;  //for
        END;  //if ftCrypt
    END;  //for
END;   //procedure DecryptIndex


Procedure DoSort(VAR df:PDatafileInfo; L,R:Integer);
VAR
  P:String;
  I,J,n2,n3: Integer;
BEGIN
  repeat
    I := L;
    J := R;
    P := ReadCommonViaSortIndex(df,(L+R) shr 1);
    repeat
      while ReadCommonViaSortIndex(df,I) < P do
        INC(I);
      while ReadCommonViaSortIndex(df,J) > P do
        DEC(J);
      if I <= J then
      begin
        n2:=ReadIndexNoFromSortIndex(df,I);
        n3:=ReadIndexNoFromSortIndex(df,J);
        WriteIndexNoToSortIndex(df,I,n3);
        WriteIndexNoToSortIndex(df,J,n2);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then DoSort(df,L, J);
    L := I;
  until I >= R;
END;  //procedure DoSort


Procedure InitSortIndex(VAR df:PDatafileInfo);
VAR
  n:Integer;
  pn:ARRAY[0..3] OF Byte Absolute n;
BEGIN
  {Initialize}
  df^.SortIndex:=TMemoryStream.Create;
  df^.SortIndex.SetSize(df^.NumRecords*4);
  df^.SortIndex.Position:=0;
  FOR n:=1 TO df^.NumRecords DO
    df^.SortIndex.Write(pn,4);

  Screen.Cursor:=crHourGlass;
  DoSort(df,1,df^.NumRecords);
  Screen.Cursor:=crDefault;
END;  //procedure InitSortIndex

Function IndexHasDuplicates(VAR df:PDatafileinfo; IndexNo:Integer):Boolean;
VAR
  FirstRec,SecondRec:Integer;
  pSecondrec,pFirstRec:Pointer;
BEGIN
  Result:=True;
  FirstRec:=0;
  WHILE (FirstRec<=df^.NumRecords-1) AND (Result) DO
    BEGIN
      INC(FirstRec);
      pFirstRec:=Pointer(LongInt(df^.Index.Memory)+31+( (FirstRec-1)*(31*df^.Indexcount) ) + (31*(IndexNo-1))+1);
      SecondRec:=FirstRec;
      WHILE (SecondRec<=df^.NumRecords) AND (Result) DO
        BEGIN
          INC(SecondRec);
          pSecondrec:=Pointer(LongInt(df^.Index.Memory)+31+( (SecondRec-1)*(31*df^.Indexcount) ) + (31*(IndexNo-1))+1);
          Result:=NOT CompareMem(pFirstRec,pSecondRec,30);
        END;  //while Secondrec
    END;  //while FirstRec
  {$IFNDEF epidat}
  IF NOT Result
  THEN eDlg(Format('%s'+#13+Lang(20126),
    [ExtractFilename(df^.RECFilename),
    trim(PeField(df^.FieldList.Items[df^.IndexFields[IndexNo]])^.FName),
    FirstRec,SecondRec]),mtWarning,[mbOK],0);  //20126=The field %s is KEY UNIQUE, but duplicate keys are found in records %d and %d
  {$ENDIF}
END;  //IndexHasDuplicates


Function Soundex(s: String):String;
TYPE
  Tg=ARRAY[0..6] OF Set of Char;
CONST
  WHChars:Set of CHAR=['W','H'];
  g:Tg=(['A','E','I','O','U','Y','Æ','Ø','Å','H','W'],
       ['B','F','P','V'],
       ['C','G','J','K','Q','S','X','Z'],
       ['D','T'],
       ['L'],
       ['M','N'],
       ['R']);
VAR
  n:Integer;
  Prev:Byte;
  Ignore:Boolean;

  Function sx(c: Char):Integer;
  VAR
    n:Integer;
  BEGIN
    Result:=0;
    FOR n:=1 TO 6 DO
      IF (c in g[n]) THEN result:=n;
  END;

  BEGIN  //function Soundex
  s:=trim(AnsiUpperCase(s));
  result:='';
  IF s='' THEN Exit;
  {Find surname}
  n:=Length(s);
  IF n>0 THEN
    BEGIN
      WHILE (s[n]<>' ') AND (n>1) DO DEC(n);
      IF n>1 THEN s:=COPY(s,n+1,Length(s)-n);
      {Remove everything that isn't alfa}
      FOR n:=1 TO Length(s) DO
        IF (s[n] in AlfaChars) THEN result:=result+s[n];
      s:=result+' ';
      result:=s[1]+'-';
      Ignore:=False;
      Prev:=sx(s[1]);
      FOR n:=2 TO Length(s)-1 DO
        BEGIN
          {apply rules}
          IF sx(s[n])=sx(s[n-1]) THEN Ignore:=True;  //adjacent consonants of same group ignored
          IF (s[n] in WHChars) AND (sx(s[n-1])=sx(s[n+1])) THEN Ignore:=True;  //W or H surrounded by letters of same code group
          IF n>2 THEN
            IF (s[n-1] in WHChars) AND (sx(s[n-2])=sx(s[n])) THEN Ignore:=True;   //prev. letter is W or H surrounded by letters of same code group
          IF Length(result)=5 THEN Ignore:=True;

          IF (NOT Ignore) AND (sx(s[n])<>0) THEN Result:=Result+IntToStr(sx(s[n]));
          Ignore:=False;
        END;   //for
      WHILE Length(result)<5 DO Result:=Result+'0';
    END;  //if Length(s)>0
END;   //function soundex


{$IFNDEF epidat}
Function WarningDlg(CONST s:String):Word;
VAR
  n:Integer;
BEGIN
  WITH CreateMessageDialog(s,mtWarning,[mbOK,mbCancel]) DO
    BEGIN
      TRY
        Caption:=Lang(4900);
        FOR n:=0 TO ControlCount-1 DO
          IF (Controls[n] is TButton) THEN
            IF TButton(Controls[n]).Name='Cancel' THEN
              BEGIN
                TButton(Controls[n]).TabOrder:=0;
                TButton(Controls[n]).Caption:=Lang(3116);  //cancel
              END
            ELSE IF TButton(Controls[n]).Name='OK' THEN TButton(Controls[n]).Caption:=Lang(3114);  //ok
        IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
        Result:=ShowModal;
      FINALLY
        Free;
      END;  //try..finally
    END;  //with
END;  //function WarningDlg

Function NoYesDlg(CONST s:String):Word;
VAR
  n:Integer;
BEGIN
  WITH CreateMessageDialog(s,mtWarning,[mbYes,mbNo]) DO
    BEGIN
      TRY
        Caption:=Lang(4900);
        FOR n:=0 TO ControlCount-1 DO
          IF (Controls[n] is TButton) THEN
            BEGIN
              IF TButton(Controls[n]).Name='No' THEN TButton(Controls[n]).TabOrder:=0;
              IF TButton(Controls[n]).Name='Yes'         THEN TButton(Controls[n]).Caption:=Lang(20210)
              ELSE IF TButton(Controls[n]).Name='No'      THEN TButton(Controls[n]).Caption:=Lang(20212);
            END;
        IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
        Result:=ShowModal;
      FINALLY
        Free;
      END;  //try..finally
    END;  //with
END;  //function WarningDlg


Function SaveDlg(CONST s:String; Btns: TMsgDlgButtons):WORD;
VAR
  n: Integer;
  b: TButton;
BEGIN
  WITH CreateMessageDialog(s,mtConfirmation,Btns) DO
    BEGIN
      TRY
        IF SaveDlgPos.x>=0 THEN Left:=SaveDlgPos.x ELSE Left:=(MainForm.ClientWidth DIV 2) - (Width DIV 2);
        IF SaveDlgPos.y>=0 THEN Top:=SaveDlgPos.y ELSE Top:=(MainForm.ClientHeight DIV 2) - (Height DIV 2);
        IF Left+Width > Screen.Width THEN Left:=Screen.Width-Width;
        IF Top+Height > Screen.Height THEN Top:=Screen.Height-Height;
        Caption:=Lang(50000);  //'Confirmation'
        FOR n:=0 TO ControlCount-1 DO
          BEGIN
            IF (Controls[n] is TButton) THEN
              BEGIN
                b:=TButton(Controls[n]);
                IF b.Name='Yes'         THEN b.Caption:=Lang(20210)
                ELSE IF b.Name='No'      THEN b.Caption:=Lang(20212)
                ELSE IF b.Name='Cancel'  THEN b.Caption:=Lang(3116)
                ELSE IF b.Name='OK'      THEN b.Caption:=Lang(3114)
                ELSE IF b.Name='Ignore'  THEN b.Caption:=Lang(50002)   //'Ignore'
                ELSE IF b.Name='Help'    THEN b.caption:=Lang(50004)   //'Help'
                ELSE IF b.Name='Abort'   THEN b.Caption:=Lang(50006)   //'Abort'
                ELSE IF b.Name='All'     THEN b.Caption:=Lang(50008)   //'All';
              END;  //if
          END;  //for
        Result:=ShowModal;
        SaveDlgPos.x:=Left;
        SaveDlgPos.y:=Top;
      FINALLY
        Free;
      END;  //try..finally
    END;  //With
END;  //function SaveDlg




Function eDlgPos(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt; VAR x,y:Integer):Word;
VAR
  n:Integer;
  b: TButton;
BEGIN
  WITH CreateMessageDialog(s,DlgType,Btns) DO
    BEGIN
      TRY
        IF x>=0 THEN Left:=x;
        IF y>=0 THEN Top:=y;
        IF Left<0 THEN Left:=0;
        IF Top<0 THEN Top:=0;
        CASE DlgType OF
          mtWarning:      BEGIN
                            Caption:=Lang(4900);
                            IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
                          END;
          mtError:
                          BEGIN
                            Caption:=Lang(3200);
                            IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
                          END;
          mtInformation:
                          BEGIN
                            Caption:=Lang(50010);   //'Information'
                            IF DoUseSounds THEN MessageBeep(MB_ICONQUESTION);
                          END;
          mtConfirmation: BEGIN
                            Caption:=Lang(50000);   //'Confirmation'
                            IF DoUseSounds THEN MessageBeep(MB_OK);
                          END;
          mtCustom:       Caption:=Application.Title;
        END;

        HelpContext := HelpCtx;
        FOR n:=0 TO ControlCount-1 DO
          BEGIN
            IF (Controls[n] is TButton) THEN
              BEGIN
                b:=TButton(Controls[n]);
                IF b.Name='Yes'         THEN b.Caption:=Lang(20210)
                ELSE IF b.Name='No'      THEN b.Caption:=Lang(20212)
                ELSE IF b.Name='Cancel'  THEN b.Caption:=Lang(3116)
                ELSE IF b.Name='OK'      THEN b.Caption:=Lang(3114)
                ELSE IF b.Name='Ignore'  THEN b.Caption:=Lang(50002)   //'Ignore'
                ELSE IF b.Name='Help'    THEN b.caption:=Lang(50004)   //'Help'
                ELSE IF b.Name='Abort'   THEN b.Caption:=Lang(50006)   //'Abort'
                ELSE IF b.Name='All'     THEN b.Caption:=Lang(50008);  //'All'
              END;  //if
          END;  //for
        Result:=ShowModal;
        x:=Left;
        y:=Top;
      FINALLY
        Free;
      END;  //try..finally
    END;  //with
END;  //eDlgPos


Function eDlg(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt):Word;
VAR
  n:Integer;
BEGIN
  n:=-1;
  Result:=eDlgPos(s,DlgType,Btns,HelpCtx,n,n);
END;  //function eDlg


Function AddEditDlg(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt):Word;
VAR
  n,x,y:Integer;
  b: TButton;
BEGIN
  x:=-1;
  y:=-1;
  WITH CreateMessageDialog(s,DlgType,Btns) DO
    BEGIN
      TRY
        IF x>=0 THEN Left:=x;
        IF y>=0 THEN Top:=y;
        IF Left<0 THEN Left:=0;
        IF Top<0 THEN Top:=0;
        CASE DlgType OF
          mtWarning:      BEGIN
                            Caption:=Lang(4900);
                            IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
                          END;
          mtError:
                          BEGIN
                            Caption:=Lang(3200);
                            IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
                          END;
          mtInformation:
                          BEGIN
                            Caption:=Lang(50010);   //'Information'
                            IF DoUseSounds THEN MessageBeep(MB_ICONQUESTION);
                          END;
          mtConfirmation: BEGIN
                            Caption:=Lang(50000);   //'Confirmation'
                            IF DoUseSounds THEN MessageBeep(MB_OK);
                          END;
          mtCustom:       Caption:=Application.Title;
        END;

        HelpContext := HelpCtx;
        FOR n:=0 TO ControlCount-1 DO
          BEGIN
            IF (Controls[n] is TButton) THEN
              BEGIN
                b:=TButton(Controls[n]);
                IF b.Name='Yes'         THEN b.Caption:=Lang(20210)
                ELSE IF b.Name='No'      THEN b.Caption:=Lang(20212)
                ELSE IF b.Name='Cancel'  THEN b.Caption:=Lang(3116)
                ELSE IF b.Name='OK'      THEN b.Caption:=Lang(3114)
                ELSE IF b.Name='Ignore'  THEN b.Caption:=Lang(50002)   //'Ignore'
                ELSE IF b.Name='Help'    THEN b.caption:=Lang(50004)   //'Help'
                ELSE IF b.Name='Abort'   THEN b.Caption:=Lang(25032)   //&1 Edit
                ELSE IF b.Name='All'     THEN b.Caption:=Lang(25034)   //&2 Add
              END;  //if
          END;  //for
        Result:=ShowModal;
        x:=Left;
        y:=Top;
      FINALLY
        Free;
      END;  //try..finally
    END;  //with
END;  //AddEditDlg

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;


function eInputQuery(const ACaption, APrompt: string; var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      ClientHeight := MulDiv(63, DialogUnits.Y, 8);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      with Prompt do
      begin
        Parent := Form;
        AutoSize := True;
        Left := MulDiv(8, DialogUnits.X, 4);
        Top := MulDiv(8, DialogUnits.Y, 8);
        Caption := APrompt;
      end;
      Edit := TEdit.Create(Form);
      with Edit do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := MulDiv(19, DialogUnits.Y, 8);
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 255;
        Text := Value;
        SelectAll;
      end;
      ButtonTop := MulDiv(41, DialogUnits.Y, 8);
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := Lang(3114);  //OK
        ModalResult := mrOk;
        Default := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := Lang(3116);  //Cancel
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      if ShowModal = mrOk then
      begin
        Value := Edit.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;
end;



Function eInputBox(const ACaption, APrompt, ADefault: string): string;
BEGIN
  Result := ADefault;
  eInputQuery(ACaption, APrompt, Result);
END;


Function OriginalNewEditDlg(CONST s:String; DlgType:TMsgDlgType; Btns: TMsgDlgButtons; HelpCtx:LongInt):Word;
VAR
  n,x,y:Integer;
  b: TButton;
BEGIN
  x:=-1;
  y:=-1;
  WITH CreateMessageDialog(s,DlgType,Btns) DO
    BEGIN
      TRY
        IF x>=0 THEN Left:=x;
        IF y>=0 THEN Top:=y;
        IF Left<0 THEN Left:=0;
        IF Top<0 THEN Top:=0;
        CASE DlgType OF
          mtWarning:      BEGIN
                            Caption:=Lang(4900);
                            IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
                          END;
          mtError:
                          BEGIN
                            Caption:=Lang(3200);
                            IF DoUseSounds THEN MessageBeep(MB_ICONEXCLAMATION);
                          END;
          mtInformation:
                          BEGIN
                            Caption:=Lang(50010);   //'Information'
                            IF DoUseSounds THEN MessageBeep(MB_ICONQUESTION);
                          END;
          mtConfirmation: BEGIN
                            Caption:=Lang(50000);   //'Confirmation'
                            IF DoUseSounds THEN MessageBeep(MB_OK);
                          END;
          mtCustom:       Caption:=Application.Title;
        END;

        HelpContext := HelpCtx;
        FOR n:=0 TO ControlCount-1 DO
          BEGIN
            IF (Controls[n] is TButton) THEN
              BEGIN
                b:=TButton(Controls[n]);
                IF b.Name='Yes'         THEN b.Caption:=Lang(20210)
                ELSE IF b.Name='No'      THEN b.Caption:=Lang(20212)
                ELSE IF b.Name='Cancel'  THEN b.Caption:=Lang(3116)
                ELSE IF b.Name='OK'      THEN b.Caption:=Lang(3114)
                ELSE IF b.Name='Abort'  THEN b.Caption:=Lang(25032)   //&1 Edit
                ELSE IF b.Name='Ignore'   THEN b.Caption:=Lang(25036)   //&2 New
                ELSE IF b.Name='All'     THEN b.Caption:=Lang(25038)    //&3 Original
              END;  //if
          END;  //for
        Invalidate;
        Result:=ShowModal;
        x:=Left;
        y:=Top;
      FINALLY
        Free;
      END;  //try..finally
    END;  //with
END;  //OriginalNewEditDlg



{$ENDIF}

Function GetRecentFilename(FileExt: String):String;
BEGIN
  Result:='';
  FileExt:=AnsiUpperCase(FileExt);
  IF AnsiUpperCase(ExtractFileExt(RecentFiles[1]))=FileExt
  THEN Result:=RecentFiles[1];
END;

Function GetRecentFiledir:String;
BEGIN
  Result:=ExtractFileDir(RecentFiles[1]);
END;


{$IFNDEF epidat}
Procedure AddToNotesFile(VAR odf: PDatafileInfo; CONST s:String);
VAR
  DesFilename: TFilename;
  DesFile: TextFile;
BEGIN
  DesFilename:=ChangeFileExt(odf^.RECFilename,'.not');
  IF NOT FileExists(DESFilename) THEN
    BEGIN
      TRY
        AssignFile(DesFile,DESFilename);
        ReWrite(DesFile);
        WriteLN(DesFile,Format(Lang(22000),[odf^.RECFilename]));   //Dataentry notes for %s
        WriteLN(DesFile,cFill('-',80));
        WriteLN(DesFile);
        CloseFile(DesFile);
      EXCEPT
        ErrorMsg(Format(Lang(22002),[DESFilename])+#13#13+Lang(20206));  //'A dataentry notes file by the name %s cannot be created.  / Check if the file is in use and that the filename is legal.'
        Exit;
      END;  //try..Except
    END;  //if not fileExists
  AssignFile(DesFile,DESFilename);
  Append(DesFile);
  WriteLN(DesFile);
  WriteLN(DesFile,FormatDateTime('dd mmm yyyy hh":"nn',now));
  WriteLn(DesFile,s);
  CloseFile(DesFile);
END;
{$ENDIF}

Function InsertFieldContents(VAR df: PDatafileInfo; CONST tmpStr:String):String;
{Replaces @fieldname with the contents of the field fieldname
 double @s are replaced by single @}
VAR
  n,t: Integer;
  tmpResult,s: String;
  ok: Boolean;
  tmpDefVar: PDefVar;
BEGIN
  n:=1;
  tmpResult:='';
  IF tmpStr<>'' THEN
    BEGIN
      REPEAT
        IF tmpStr[n]<>'@' THEN
          BEGIN
            tmpResult:=tmpResult+tmpStr[n];
            INC(n);
          END
        ELSE
          BEGIN
            ok:=False;
            IF n<Length(tmpStr)
            THEN IF tmpStr[n+1]='@' THEN ok:=True;
            IF ok THEN
              BEGIN
                //allow @@ to be written as @
                tmpResult:=tmpResult+'@';
                INC(n,2);
              END
            ELSE
              //a single @ was found
              BEGIN
                s:='';
                REPEAT
                  INC(n);
                  IF n<=Length(tmpStr) THEN s:=s+tmpStr[n];
                UNTIL (n>Length(tmpStr)) or (NOT (tmpStr[n] in AlfaNumChars));
                t:=GetFieldNumber(s,df);
                IF t<>-1 THEN tmpResult:=tmpResult+trim(PeField(df^.FieldList.Items[t])^.FFieldText)
                ELSE
                  BEGIN
                    tmpDefVar:=GetDefField(s,df);
                    IF tmpDefVar<>NIL THEN tmpResult:=tmpResult+trim(tmpDefVar^.FFieldText);
                  END;
              END;
          END;  //if @ found
      UNTIL n>=Length(tmpStr)+1;
    END;
  Result:=tmpResult;
END;  //InsertFieldcontents

Function ProgressStep(CONST MaxVal,CurVal: Integer):Boolean;
VAR
  m,c:Double;
BEGIN
  m:=MaxVal;
  c:=CurVal;
  IF MaxVal<20 THEN Result:=True
  ELSE IF (c/m < 0.05) AND (CurVal<1000) AND ((CurVal-1) MOD 4 = 0) THEN Result:=True
  ELSE IF ((CurVal-1) MOD (MaxVal DIV 20) = 0) THEN Result:=True
  ELSE Result:=False;
END;  //function progressStep

Function FormatNumberToIndex(s:String):str30;
VAR
  n:Double;
BEGIN
  IF trim(s)='' THEN Result:=Format('%30s',[s])
  ELSE
    BEGIN
      IF IsInteger(s) THEN
        BEGIN
          n:=StrToFloat(s);
          Result:=Format('%30g',[n]);
        END
      ELSE Result:=Format('%30s',[s]);
    END;
END;

{$IFNDEF epidat}
function fileExec(const aCmdLine,aParams: String; aHide, aWait: Boolean; VAR ExitCode:Cardinal): Boolean;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  SEI: PShellExecuteInfo;
  fhandle: THandle;
begin
  {setup the startup information for the application }
  TRY
    New(SEI);
    FillChar(SEI^, SizeOf(SEI^),0);
    SEI^.cbSize:=SizeOf(TShellexecuteInfo);
    SEI^.fMask:=SEE_MASK_NOCLOSEPROCESS;
    SEI^.Wnd:=mainform.Handle;
    SEI^.lpFile:=PChar(aCmdLine);
    IF aParams<>'' THEN SEI^.lpParameters:=PChar(aParams);
    IF aHide THEN SEI^.nShow:=SW_HIDE ELSE SEI^.nShow:=SW_SHOWNORMAL;
    Result:=ShellExecuteEx(SEI);
    ResultVar:=-1;
    IF NOT Result THEN Exit;
    IF aWait THEN
      BEGIN
        WaitForInputIdle(SEI^.hProcess,INFINITE);
        WaitforSingleObject(SEI^.hProcess,INFINITE);
        GetExitCodeProcess(SEI^.hProcess,ExitCode);
        ResultVar:=ExitCode;
      END;
  FINALLY
    Dispose(SEI);
  END;
end;
{$ENDIF}


Function GetColors(s:String; VAR txtcolor,bgcolor, HighLightColor:Byte; VAR IsEpiInfo:Boolean):Boolean;
VAR
  n: Integer;
  s2,s3: String;
BEGIN
  //input can be either a epi info color code (one number)
  //or 1-2 EpiData color words
  //one word present: s2=word, s='', s3=''
  //two words present: s2=word1, s=word2,  s3=''
  //three words present:  s2=word1,  s=word2,  s3=word3
  txtcolor:=255;
  bgcolor:=255;
  HighLightColor:=255;
  s:=AnsiUpperCase(trim(s));
  n:=pos(' ',s);
  IF n=0 THEN
    BEGIN
      s2:=s;
      s:='';
    END
  ELSE
    BEGIN
      s2:=copy(s,1,n-1);
      s:=copy(s,n+1,length(s));
      //is third word present?
      n:=pos(' ',s);
      IF n=0 THEN s3:=''
      ELSE
        BEGIN
          s3:=trim(copy(s,n+1,length(s)));;
          s:=copy(s,1,n-1);
        END;
    END;
  IF IsInteger(s2) THEN
    BEGIN
      //input is a epi info color number
      IsEpiInfo:=True;
      n:=StrToInt(s2);
      IF n>255 THEN
        BEGIN
          Result:=False;
          Exit;
        END;
      n:=n AND $7F;  //clear first bit which indicates flashing text in epi info
      bgcolor:=(n AND $F0) SHR 4;
      txtcolor:=(n AND $0F);
      Result:=True;
      Exit;
    END
  ELSE
    BEGIN
      //input is one, two or three EpiData color words
      IsEpiInfo:=False;
      FOR n:=0 TO 17 DO
        IF s2=ColorNames[n] THEN txtcolor:=n;
      Result:=False;
      IF txtcolor=255 THEN Exit;
      IF s<>'' THEN
        BEGIN
          //get second word - if present
          FOR n:=0 TO 17 DO
            IF s=ColorNames[n] THEN bgcolor:=n;
          IF bgcolor=255 THEN Exit;
        END;
      IF s3<>'' THEN
        BEGIN
          //get 3rd word - if present
          FOR n:=0 TO 17 DO
            IF s3=ColorNames[n] THEN HighLightColor:=n;
          IF HighLightColor=255 THEN Exit;
        END;
      Result:=True
    END;
END;  //function GetColors

Procedure SaveScreenCoords(VAR df: PDatafileInfo);
VAR
  esc: TFileStream;
  esc_head: Tesc_header;
  esc_field: Tesc_field;
  n: Integer;
  s: String;
  ok: Boolean;
  AField: Pefield;
BEGIN
  //1. Findes recfile.esc?
  //2. Hvis ja - er den OK?  Hvis OK så exit
  //3. Hvis ikke OK så lav en ny
  EXIT;
  esc:=NIL;
  TRY
    s:=ChangeFileExt(df^.RECFilename,'.esc');
    IF FileExists(s) THEN
      BEGIN
        esc:=TFileStream.Create(s,fmOpenRead);
        esc.Read(esc_head,sizeOf(esc_head));
        ok:=False;
        IF  (esc_head.scrHeight=screen.Height)
        AND (esc_head.scrWidth=screen.Width)
        AND (esc_head.fntSize=EpiDataFormFont.Size)
        AND (esc_head.fntStyle=FontStyleToByte(EpiDataFormFont.Style))
        AND (esc_head.fntPPI=EpiDataFormFont.PixelsPerInch)
        AND (esc_head.fntName=Copy(EpiDataFormFont.Name,1,30))
        AND (esc_head.numFields=df^.NumFields)
        AND (esc_head.chkFields=df^.FieldCheckSum) THEN ok:=True;
        IF ok THEN Exit;   //a esc-file exists and is still valid
        ok:=deletefile(s);
      END;
    //Make the esc-file
    esc:=TFileStream.Create(s,fmCreate);
    WITH esc_head DO
      BEGIN
        scrHeight:=screen.Height;
        scrWidth:=screen.Width;
        fntSize:=EpiDataFormFont.Size;
        fntStyle:=FontStyleToByte(EpiDataFormFont.Style);
        fntPPI:=EpiDataFormFont.PixelsPerInch;
        fntName:=Copy(EpiDataFormFont.Name,1,30);
        numFields:=df^.Numfields;
        chkFields:=df^.FieldCheckSum;
      END;  //with
    esc.Write(esc_head,sizeOf(esc_head));
    FOR n:=0 TO df^.FieldList.count-1 DO
      BEGIN
        AField:=PeField(df^.FieldList.Items[n]);
        esc_field.QuestTop:=AField^.FQuestTop;
        esc_field.QuestLeft:=AField^.FQuestLeft;
        esc_field.FieldLeft:=AField^.FFieldLeft;
        esc_field.FieldTop:=AField^.FFieldTop;
        esc_field.FieldWidth:=AField^.FFieldWidth;
        esc.Write(esc_field,sizeOf(esc_field));
      END;
  FINALLY
    IF Assigned(esc) THEN esc.free;
  END;
END;  //procedure SaveScreenCoords

Function LoadScreenCoords(VAR df: PDatafileInfo):Boolean;
VAR
  esc: TFileStream;
  esc_head: Tesc_header;
  esc_field: Tesc_field;
  n: Integer;
  s: String;
  ok: Boolean;
  AField: Pefield;
BEGIN
  Result:=False;
  exit;
  esc:=NIL;
  TRY
    s:=ChangeFileExt(df^.RECFilename,'.esc');
    IF NOT FileExists(s) THEN Exit;
    esc:=TFileStream.Create(s,fmOpenRead);
    esc.Read(esc_head,sizeOf(esc_head));
    ok:=False;
    IF  (esc_head.scrHeight=screen.Height)
    AND (esc_head.scrWidth=screen.Width)
    AND (esc_head.fntSize=EpiDataFormFont.Size)
    AND (esc_head.fntStyle=FontStyleToByte(EpiDataFormFont.Style))
    AND (esc_head.fntPPI=EpiDataFormFont.PixelsPerInch)
    AND (esc_head.fntName=Copy(EpiDataFormFont.Name,1,30))
    AND (esc_head.numFields=df^.NumFields)
    AND (esc_head.chkFields=df^.FieldCheckSum) THEN ok:=True;
    IF NOT ok THEN Exit;   //Existing esc-file is not valid
    FOR n:=0 TO df^.FieldList.Count-1 DO
      BEGIN
        AField:=PeField(df^.FieldList.Items[n]);
        esc.Read(esc_field,sizeOf(esc_field));
        AField^.FQuestTop:=esc_field.QuestTop;
        AField^.FQuestLeft:=esc_field.QuestLeft;
        AField^.FFieldLeft:=esc_field.FieldLeft;
        AField^.FFieldTop:=esc_field.FieldTop;
        AField^.FFieldWidth:=esc_field.FieldWidth;
      END;
    Result:=True;
  FINALLY
    IF Assigned(esc) THEN esc.free;
  END;
END;  //procedure LoadScreenCoords


Procedure InitCryptograph;     //&&
BEGIN
  Cipher:=TDCP_Rijndael.create(nil);
END;


Function  EncryptString(CONST s,key: String):String;   //&&
VAR
  ss: String;
BEGIN
  IF (NOT Assigned(Cipher)) THEN InitCryptograph;
  Cipher.InitStr(key);    // initialize the cipher with the key
  ss:=s;
  Cipher.EncryptCFB(ss[1],ss[1],Length(ss));  // encrypt all of the strings
  result:=B64Encode(ss);        // Base64 encode the string to ensure all characters are printable
  Cipher.Reset;         // we are using CFB chaining mode so we must reset after each block of encrypted/decrypts
  Cipher.Burn;
END;

Function  DecryptString(CONST s,key: String):String;       //&&
VAR
  ss: String;
BEGIN
  IF (NOT Assigned(Cipher)) THEN InitCryptograph;
  Cipher.InitStr(key);    // initialize the cipher with the key
  ss:=s;
  ss:= B64Decode(ss);        // decode the Base64 encoded string
  Cipher.DecryptCFB(ss[1],ss[1],Length(ss));  // decrypt all of the strings
  result:= ss;
  Cipher.Reset;            // we are using CFB chaining mode so we must reset after each block of encrypted/decrypts
  Cipher.Burn;
END;

Function  GetEncodedLength(decodedlength: byte):byte;   //&&
BEGIN
  Result:=((decodedlength+2) div 3)*4;
END;

Function  GetDecodedLength(encodedlength: byte):byte;   //&&
BEGIN
  Result:=(encodedlength div 4)*3;
END;

Function RemoveQuotes(s:String):String;
VAR
  n,QStart,EndQ:Integer;
  KeepQ:Boolean;
  tmpS:String;
BEGIN
  IF s='' THEN Exit;
  n:=1;
  QStart:=0;
  EndQ:=0;
  KeepQ:=False;
  tmpS:='';
  REPEAT
    IF (QStart>0) AND ( (s[n]=',') OR (s[n]=' ') ) THEN KeepQ:=True
      ELSE IF (QStart>0) AND (s[n]='"') THEN
        BEGIN
          EndQ:=n;
          IF NOT KeepQ THEN tmpS:=tmpS+Copy(s,QStart+1,EndQ-QStart-1)
          ELSE tmpS:=tmpS+Copy(s,QStart,EndQ-QStart+1);
          QStart:=0;
        END  //if EndQuote found
        ELSE IF (s[n]='"') AND (QStart=0) THEN
          BEGIN
            QStart:=n;
            KeepQ:=False;
          END
          ELSE IF QStart=0 THEN tmpS:=tmpS+s[n];
    INC(n);
  UNTIL n>Length(s);
  Result:=tmpS;
END;  //function RemoveQuotes


Function  GetPw(Filename: String):String;
VAR
  n: Integer;
  s: String;
BEGIN
  Result:='';
  s:=AnsiUpperCase(Filename);
  FOR n:=1 TO MaxPws DO
    BEGIN
      IF pws[n].DataFilename<>'' THEN
        BEGIN
          IF now-pws[n].Time>(5/1440) THEN pws[n].DataFilename:=''
          ELSE IF AnsiUpperCase(pws[n].DataFilename)=s THEN
            BEGIN
              Result:=pws[n].key;
              pws[n].Time:=now;
            END;
        END;  //if
    END;  //for
END;

Procedure StorePw(Filename, pw:String);
VAR
  IsStored: Boolean;
  n: Integer;
  OldestEntry: Integer;
  OldestTime: TDateTime;
BEGIN
  OldestTime:=now+365;
  FOR n:=1 TO MaxPws DO
    BEGIN
      IF pws[n].DataFilename<>'' THEN
        BEGIN
          IF now-pws[n].Time>(5/1440) THEN pws[n].DataFilename:=''
          ELSE
            BEGIN
              IF pws[n].Time<OldestTime THEN
                BEGIN
                  OldestTime:=pws[n].Time;
                  OldestEntry:=n;
                END;  //if
            END;  //else
        END;  //if
    END;  //for
  IsStored:=False;
  FOR n:=1 TO MaxPws DO
    BEGIN
      IF pws[n].DataFilename='' THEN
        BEGIN
          IsStored:=True;
          pws[n].DataFilename:=Filename;
          pws[n].key:=pw;
          pws[n].Time:=now;
        END;
    END;
  IF (NOT IsStored) THEN
    BEGIN
      pws[OldestEntry].DataFilename:=Filename;
      pws[OldestEntry].key:=pw;
      pws[OldestEntry].Time:=now;
    END;
END;


Procedure ResetVarifiedFlag(df:PDatafileInfo);
VAR
  n:Integer;
BEGIN
  IF (NOT Assigned(df)) THEN Exit;
  FOR n:=0 TO df^.FieldList.Count-1 DO
    PeField(df^.FieldList.Items[n])^.FIsVarified:=False;
END;

Procedure SetVarifiedFlag(df:PDataFileInfo);
VAR
  n:Integer;
BEGIN
  IF (NOT Assigned(df)) THEN Exit;
  FOR n:=0 TO df^.FieldList.Count-1 DO
    PeField(df^.FieldList.Items[n])^.FIsVarified:=True;
END;

function  PasswordIslegal(const pw: string):boolean;
var
  hasNumChars,hasLower,hasUpper:boolean;
  n:integer;
begin
  hasNumChars:=false;
  hasLower:=false;
  hasUpper:=false;
  result:=false;
  if length(pw)<6 then exit;
  for n:=1 to length(pw) do
    begin
      if (pw[n] in NumChars) then hasNumChars:=true
      else if (pw[n] in ['A'..'Z','Æ','Ø','Å']) then hasUpper:=true
      else if (pw[n] in ['a'..'z','æ','ø','å']) then hasLower:=true;
    end;
  result:=(hasNumChars and hasLower and hasUpper);
end;

function  getRandomPadding(len: integer):string;
CONST
  chars='23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!?/*+-';
begin
  result:='';
  Randomize;
  if len=0 then exit;
  while (length(result)<len) do result:=result+chars[Random(length(chars))+1];
end;

function  boolean2string(val: boolean):string;
begin
  if val=true then result:='true' else result:='false';
end;

function  string2boolean(val: string):boolean;
begin
  if AnsiLowerCase(val)='true' then result:=true else result:=false;
end;

function explode(const s:string;separator:char):TdynArrayString;
var
  n,numelems,no: integer;
  tmp,s2: string;
begin
  numelems:=0;
  for n:=1 to length(s) do
    if s[n]=separator then inc(numelems);
  if numelems=0 then numelems:=1;
  SetLength(result,numelems+1);
  tmp:=s;
  no:=0;
  while length(tmp)>0 do
    begin
      n:=pos(separator,tmp);
      if n=0 then
        begin
          result[no]:=tmp;
          tmp:='';
        end
      else
        begin
          s2:=copy(tmp,1,n-1);
          result[no]:=s2;
          delete(tmp,1,n);
        end;
      inc(no);
    end;
end;

end.
