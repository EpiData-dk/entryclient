unit shortcuts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

var
  // Mainform
  M_Exit,
  M_NewProject,
  M_Settings,
  M_OpenRecent,
  M_ShowAbout,
  M_CopyProjectInfo,
  M_CheckVersion,
  M_DefaultPos,
  M_CloseProject,
  M_OpenProject:
    TShortCut;

  // Project
  P_SaveProject:
    TShortCut;

  // Dataform
  D_BrowseData,
  D_FieldNotes,
  D_MoveFirstRec,
  D_MoveSkipPrevRec,
  D_MovePrevRec,
  D_MoveNextRev,
  D_MoveSkipNextRec,
  D_MoveLastRec,
  D_NewRec,
  D_GotoRec,
  D_SideUp,
  D_SideDown,
  D_SearchRecordEmpty,
  D_SearchRecordFilled,
  D_SearchRepeatForward,
  D_SearchRepeatBackward,
  D_SearchRecordList,
  D_CopyRecordToClipBoard,
  D_CopyFieldToClipBoard,
  D_PrintForm,
  D_PrintFormWithData:
    TShortCut;


implementation

uses
  LCLType;

{$I shortcuts.inc}

initialization
  InitShortCuts;


end.

