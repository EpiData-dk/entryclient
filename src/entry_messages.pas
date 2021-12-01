unit entry_messages;

{$mode objfpc}{$H+}

interface

uses
  LMessages;

const
  // Main
  LM_CLOSE_PROJECT             = LM_USER + 1;
  LM_OPEN_PROJECT              = LM_CLOSE_PROJECT + 1;   // WParam: 0 = show dialog, else full filename path
  LM_OPEN_RECENT               = LM_OPEN_PROJECT + 1;    // WPARAM: Full filename path

  // Project
  LM_PROJECT_RELATE            = LM_OPEN_RECENT + 1;     // WParam: TEpiMasterRelation (the relation to go to).
                                                         // LParam: 0 = parent->child
                                                         //         1 = child->parent, explicit return
                                                         //         2 = child->parent, implicit return -> check for next child

  // Dataform
  LM_DATAFORM_GOTOREC          = LM_PROJECT_RELATE + 1;

implementation

end.

