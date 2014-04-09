unit entry_messages;

{$mode objfpc}{$H+}

interface

uses
  LMessages;

const
  // Main
  LM_CLOSE_PROJECT             = LM_USER + 1;
  LM_OPEN_PROJECT              = LM_CLOSE_PROJECT + 1;
  LM_OPEN_RECENT               = LM_OPEN_PROJECT + 1;

  // Project
  LM_PROJECT_RELATE            = LM_OPEN_RECENT + 1;     // WParam = TEpiMasterRelation (the relation to go to).

  // Dataform
  LM_DATAFORM_GOTOREC          = LM_PROJECT_RELATE + 1;

implementation

end.

