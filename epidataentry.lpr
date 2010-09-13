program epidataentry;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, project_frame, dataform_frame, epidatacore, fieldedit,
  entryprocs, settings;

{$R *.res}

begin
  Application.Title := 'EpiData Entry Client';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

