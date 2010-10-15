program epidataentry;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetbase, main, project_frame, dataform_frame, epidatacore, fieldedit,
  entryprocs, settings, about;

{$R *.res}

begin
  Application.Title := 'epidataentryclient';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

