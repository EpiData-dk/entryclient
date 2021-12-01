unit settings2_interface;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, settings;

type
  ISettingsFrame = interface ['{6DDCD982-AD90-4BE1-BB7F-46C8C187AB14}']
    procedure SetSettings(Data: PEntrySettings);
    function  ApplySettings: boolean;
  end;

implementation

end.

