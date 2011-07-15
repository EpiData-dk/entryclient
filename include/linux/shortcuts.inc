{%MainUnit ../../shortcuts.pas}

procedure InitShortCuts;
begin
  // Mainform
  M_Exit := KeyToShortCut(VK_F10, []);
  M_NewProject := KeyToShortCut(VK_UNKNOWN, []);  // Should probably be deleted? Entry cannot create projects?
  M_Settings := KeyToShortCut(VK_S, [ssAlt]);
  M_OpenRecent := KeyToShortCut(VK_UNKNOWN, [ssShift, ssCtrl]);
  M_ShowAbout := KeyToShortCut(VK_UNKNOWN, []);
  M_CopyProjectInfo := KeyToShortCut(VK_UNKNOWN, []);
  M_CheckVersion := KeyToShortCut(VK_UNKNOWN, []);
  M_DefaultPos := KeyToShortCut(VK_UNKNOWN, []);
  M_CloseProject := KeyToShortCut(VK_F4, [ssCtrl]);
  M_OpenProject := KeyToShortCut(VK_O, [ssCtrl]);

  // Project
  P_SaveProject := KeyToShortCut(VK_S, [ssCtrl]);

  // Dataform
  D_FieldNotes := KeyToShortCut(VK_F12, []);
  D_MoveFirstRec := KeyToShortCut(VK_HOME, [ssCtrl]);
  D_MoveSkipPrevRec := KeyToShortCut(VK_LEFT, [ssCtrl]);
  D_MovePrevRec := KeyToShortCut(VK_LEFT, [ssShift]);
  D_MoveNextRev := KeyToShortCut(VK_RIGHT, [ssShift]);
  D_MoveSkipNextRec := KeyToShortCut(VK_RIGHT, [ssCtrl]);
  D_MoveLastRec := KeyToShortCut(VK_END, [ssCtrl]);
  D_NewRec := KeyToShortCut(VK_N, [ssCtrl]);
  D_GotoRec := KeyToShortCut(VK_G, [ssCtrl]);
  D_SideUp := KeyToShortCut(VK_PRIOR, []);
  D_SideDown := KeyToShortCut(VK_NEXT, []);
  D_SearchRecordEmpty := KeyToShortCut(VK_F, [ssShift, ssCtrl]);
  D_SearchRecordFilled := KeyToShortCut(VK_F, [ssCtrl]);
  D_SearchRepeatForward := KeyToShortCut(VK_F3, []);
  D_SearchRepeatBackward := KeyToShortCut(VK_F3, [ssShift]);
  D_SearchRecordList := KeyToShortCut(VK_L, [ssCtrl]);
end;