program epidataentryclient;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetbase, main, project_frame, dataform_frame, fieldedit,
  entryprocs, settings, about, epidatacore, picklist, sysutils,
  UniqueInstanceRaw;

{$R *.res}


function EpiDataApplicationName: string;
begin
  result := 'epidataentryclient';
end;

begin
  OnGetApplicationName := @EpiDataApplicationName;

  LoadIniFile;
  if (not EntrySettings.MultipleInstances) and
     InstanceRunning(EpiDataApplicationName) then exit;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

