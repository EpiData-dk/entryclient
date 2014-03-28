unit entry_globals;

{$mode objfpc}{$H+}

interface

const
  DataFormCustomDataKey = 'DataFormCustomDataKey';
  PROJECT_RELATION_NODE_KEY = 'PROJECT_RELATION_NODE_KEY';

type
  TRecordChangeEvent = function(Sender: TObject): boolean of object;

implementation

end.

