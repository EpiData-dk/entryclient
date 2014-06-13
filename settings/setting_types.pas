unit setting_types;

{$mode objfpc}{$H+}

interface

type
  TSettingRelateMaxRecordReached = (mrrStayOnForm, mrrReturnToParent);
  TSettingRelateRecordChanged = (rcFirstRecord, rcLastRecord, rcNewRecord);


const
  TSettingRelateMaxRecordReachedStrings: array[TSettingRelateMaxRecordReached] of string =
    (
     'Stay on entry form',
     'Return to parent'
    );

  TSettingRelateRecordChangedStrings: array[TSettingRelateRecordChanged] of string =
    (
     'Places child form at first record',
     'Places child form at last record',
     'Start child form with new record'
    );
implementation

end.

