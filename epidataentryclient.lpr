program epidataentryclient;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, clocale,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, printer4lazarus, lnetbase, virtualtreeview_package, main,
  project_frame, dataform_frame, fieldedit, entryprocs, settings, about,
  sysutils, UniqueInstanceRaw, epidatacore, notes_form,
  dataform_field_calculations, settings2, settings2_interface,
  settings2_paths_frame, settings2_colours_frame, settings_general_frame,
  searchform, resultlist_form, settings2_fonts_frame, shortcuts,
  entry_messages, entrylabel, control_types, entrysection, entry_globals,
  notes_report, documentfile_ext, new_record_form, settings2_relate_frame,
  setting_types, picklist2, admin_authenticator, entry_statusbar, 
entry_statusbaritem_navigator, entry_statusbaritem_keyvalues;

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

  // Initialize the application (and widgetset), we may
  // need it during commandline options (windows doesn't have
  // a console, so help/versioninfo is displayed in a window).
  Application.Initialize;

  // Parse commandline options!
  ParseCommandLineOpts;

  // Load ini before anything else - it contains start-up info.
  LoadIniFiles;

  if (not EntrySettings.MultipleInstances) and
     InstanceRunning(EpiDataApplicationName) then exit;

  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

