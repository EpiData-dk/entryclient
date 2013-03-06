unit control_types;

{$mode objfpc}{$H+}
{$interfaces corba}

interface

uses
  Classes, SysUtils;

type
  IEntryControl = interface ['IEntryControl']
    procedure UpdateSettings;
  end;

implementation

end.

