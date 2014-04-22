unit entry_globals;

{$mode objfpc}{$H+}

interface

const
  DataFormCustomDataKey = 'DataFormCustomDataKey';
  PROJECT_RELATION_NODE_KEY = 'PROJECT_RELATION_NODE_KEY';

type
  TRecordChangeEvent = function(Sender: TObject): boolean of object;

  TRelateReason = (
    rrRecordChange,   // A master changed it's current record number
    rrNewRecord,      // A master commited a new record (sub-state of record change)
    rrFocusShift,     // A shift in focused frame (eg. by clicking mouse.
    rrReturnToParent  // A child form is returning to the parent (using shortcut, 1:1 relation, etc.)
  );

implementation

end.

