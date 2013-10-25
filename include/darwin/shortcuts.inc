{%MainUnit ../../shortcuts.pas}

procedure InitShortCuts;
begin
  // Mainform
  M_Exit := KeyToShortCut(VK_Q, [ssMeta]);
  M_NewProject := KeyToShortCut(VK_UNKNOWN, []);  // Should probably be deleted? Entry cannot create projects?
  M_Settings := KeyToShortCut(VK_OEM_COMMA, [ssMeta]);
  M_OpenRecent := KeyToShortCut(VK_UNKNOWN, [ssShift, ssMeta]);
  M_ShowAbout := KeyToShortCut(VK_UNKNOWN, []);
  M_CopyProjectInfo := KeyToShortCut(VK_UNKNOWN, []);
  M_CheckVersion := KeyToShortCut(VK_UNKNOWN, []);
  M_DefaultPos := KeyToShortCut(VK_UNKNOWN, []);
  M_CloseProject := KeyToShortCut(VK_W, [ssMeta]);
  M_OpenProject := KeyToShortCut(VK_O, [ssMeta]);

  // Project
  P_SaveProject := KeyToShortCut(VK_S, [ssMeta]);

  // Dataform
  D_BrowseData           := KeyToShortCut(VK_D, [ssMeta]);
  D_FieldNotes := KeyToShortCut(VK_N, [ssShift, ssMeta]);

  D_MoveFirstRec := KeyToShortCut(VK_LEFT, [ssShift, ssMeta]);
  D_MoveSkipPrevRec := KeyToShortCut(VK_LEFT, [ssMeta]);
  D_MovePrevRec := KeyToShortCut(VK_LEFT, [ssShift]);
  D_MoveNextRev := KeyToShortCut(VK_RIGHT, [ssShift]);
  D_MoveSkipNextRec := KeyToShortCut(VK_RIGHT, [ssMeta]);
  D_MoveLastRec := KeyToShortCut(VK_RIGHT, [ssShift, ssMeta]);

  D_NewRec := KeyToShortCut(VK_N, [ssMeta]);
  D_GotoRec := KeyToShortCut(VK_G, [ssMeta]);

  D_SideUp := KeyToShortCut(VK_UP, [ssMeta]);
  D_SideDown := KeyToShortCut(VK_DOWN, [ssMeta]);
  D_SearchRecordEmpty := KeyToShortCut(VK_F, [ssShift, ssMeta]);
  D_SearchRecordFilled := KeyToShortCut(VK_F, [ssMeta]);
  D_SearchRepeatForward := KeyToShortCut(VK_G, [ssMeta]);
  D_SearchRepeatBackward := KeyToShortCut(VK_G, [ssMeta, ssShift]);
  D_SearchRecordList := KeyToShortCut(VK_L, [ssMeta]);
  D_CopyRecordToClipBoard := KeyToShortCut(VK_C, [ssMeta, ssShift]);
  D_PrintForm             := KeyToShortCut(VK_P, [ssMeta, ssShift]);
  D_PrintFormWithData     := KeyToShortCut(VK_P, [ssMeta]);
end;
