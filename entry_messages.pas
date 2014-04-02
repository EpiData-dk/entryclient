unit entry_messages;

{$mode objfpc}{$H+}

interface

uses
  LMessages;

const
  // Main
  LM_CLOSE_PROJECT = LM_USER + 1;
  LM_OPEN_PROJECT  = LM_USER + 2;
  LM_OPEN_RECENT   = LM_USER + 3;

  // Project
  LM_PROJECT_RELATE = LM_USER + 4;   // WParam = TEpiMasterRelation (the relation to go to).

  // Dataform
  LM_DATAFORM_GOTOREC = LM_USER + 5;

implementation

end.

