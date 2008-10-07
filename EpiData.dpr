program EPIData;

uses
  Forms,
  classes,
  sysUtils,
  MainUnit in 'MainUnit.pas' {MainForm},
  EdUnit in 'EdUnit.pas' {EdForm},
  PickListUnit in 'PickListUnit.pas' {PickListForm},
  SplashUnit in 'SplashUnit.pas' {SplashForm},
  EPITypes in 'EPITypes.pas',
  SelectFilesUnit in 'SelectFilesUnit.pas' {SelectFilesForm},
  FileUnit in 'FileUnit.pas',
  ExportFormUnit in 'ExportFormUnit.pas' {ExportForm},
  OptionsUnit in 'OptionsUnit.pas' {OptionsForm},
  Xls in 'xls.pas',
  WelcomeUnit in 'WelcomeUnit.pas' {WelcomeForm},
  AboutUnit in 'AboutUnit.pas' {AboutForm},
  BackUpUnit in 'BackUpUnit.pas' {BackupForm},
  DataFormUnit in 'DataFormUnit.pas' {DataForm},
  PeekCheckUnit in 'PeekCheckUnit.pas' {pCheckForm},
  ProgressUnit in 'ProgressUnit.pas' {ProgressForm},
  InputFormUnit in 'InputFormUnit.pas' {InputForm},
  LabelEditUnit in 'LabelEditUnit.pas' {LabelEditForm},
  LegalPickListUnit in 'LegalPickListUnit.pas' {LegalPickForm},
  prExpr in 'prExpr.pas',
  CheckErrorUnit in 'CheckErrorUnit.pas' {CheckErrorForm},
  ValDupUnit in 'ValDupUnit.pas' {ValDupForm},
  CopyStrucUnit in 'CopyStrucUnit.pas' {CopyDatafileForm},
  FmxUtils in 'Fmxutils.pas',
  ImportUnit in 'ImportUnit.pas' {ImportForm},
  GridUnit in 'GridUnit.pas' {GridForm},
  MergeUnit in 'MergeUnit.pas' {MergeForm},
  CountValuesUnit in 'CountValuesUnit.pas' {CountForm},
  epiUDFTypes in 'epiUDFTypes.pas',
  UExtUDF in 'UExtUDF.pas',
  RelateTreeUnit in 'RelateTreeUnit.pas' {RelateTreeForm},
  HintFormUnit in 'HintFormUnit.pas' {HintForm},
  ColorTabelUnit in 'ColorTabelUnit.pas' {ColorTabelForm},
  DCPcrypt in 'DCPcrypt.pas',
  Base64 in 'Base64.pas',
  PasswordUnit in 'PasswordUnit.pas' {PasswordForm},
  Rijndael in 'Rijndael.pas',
  CheckObjUnit in 'CheckObjUnit.pas',
  SearchFormUnit in 'SearchFormUnit.pas' {SearchForm},
  VCLZip in 'VCLZip\VCLZip.pas',
  VCLUnZip in 'VCLZip\VCLUnZip.pas',
  ZipFormUnit in 'ZipFormUnit.pas' {ZipForm},
  SHA1 in 'dcpcrypt\SHA1.pas',
  KpLib in 'VCLZip\KPLib.pas',
  kpSStrm in 'VCLZip\kpSStrm.pas',
  kpSHuge in 'VCLZip\kpSHuge.pas',
  kpZcnst in 'VCLZip\Kpzcnst.pas',
  kpMatch in 'VCLZip\kpMatch.pas',
  kpZipObj in 'VCLZip\kpZipObj.pas',
  kpCntn in 'VCLZip\kpCntn.pas',
  ShellBrowser in 'ShellBrowser.pas',
  unitGCPInit in 'unitGCPInit.pas' {formGCPAdminInit},
  unitGCPAdmin in 'unitGCPAdmin.pas' {formGCPAdmin},
  unitGCPClasses in 'unitGCPClasses.pas';


{$R *.RES}

var
  showsplash: boolean;

begin
  ShowSplash:=true;
  if paramcount>0 then
    if AnsiUpperCase(ParamStr(1))='/NOSPLASH' then ShowSplash:=false;
  Try
    SplashForm:=TSplashForm.Create(Application);
    if (not ShowSplash) then SplashForm.Timer1.Interval:=1;
    SplashForm.Show;
    SplashForm.Update;
    Application.Initialize;
    Application.Title := 'EpiData';
    Application.HelpFile:='EpiData.Hlp';
    Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPickListForm, PickListForm);
  Application.CreateForm(TformGCPAdmin, formGCPAdmin);
  Repeat
      Application.ProcessMessages;
    Until SplashForm.CloseQuery;
    SplashForm.Close;
  Finally
    SplashForm.Free;
  END;
  Application.Run;
end.
