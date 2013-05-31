program epidataentryclient;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  cwstring, clocale,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, printer4lazarus, lnetbase, main, project_frame, dataform_frame,
  fieldedit, entryprocs, settings, about, epidatacore, picklist, sysutils,
  UniqueInstanceRaw, notes_form, dataform_field_calculations, settings2,
  settings2_interface, settings2_paths_frame, settings2_colours_frame,
  settings_general_frame, searchform, search, resultlist_form,
  settings2_fonts_frame, shortcuts, entry_messages, entrylabel, control_types,
  entrysection, entry_globals, notes_report, dataform_script_executor;

{$R *.res}


function EpiDataApplicationName: string;
begin
  result := 'epidataentryclient';
end;

function EpiDataVendorName: string;
begin
  result := 'epidata';
end;

begin
  Application.Title := 'EpiData EntryClient';
  OnGetApplicationName := @EpiDataApplicationName;
  OnGetVendorName := @EpiDataVendorName;

  LoadIniFile;
  if (not EntrySettings.MultipleInstances) and
     InstanceRunning(EpiDataApplicationName) then exit;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

