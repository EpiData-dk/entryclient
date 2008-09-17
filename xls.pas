unit Xls;

{Purpose : Create binary Micro$oft Excel files}

{Author : Eddy Sterckx - eddysterckx@hotmail.com
Last revision date : 25/02/2000
Status : Freeware

Delphi rewrite from original C-code by Jason Morrill
and the xls-fileformat description from www.wotsit.org}

{Tested with Delphi 1 and 5 ; Excel 5.0 and Office 97}
{Should work with other Delphi/Excel versions}

{Excel uses a file format called BIFF (Binary File Format).
There are many types of BIFF records.  Each has a 4 byte header.
The first two bytes are an opcode that specifies the record type.
The second two bytes specify record length.
The rest of the record is the data itself

Word-values are stored in byte-reversed form (lsbf - least significant byte first).
Double-values (8 byte floats) are stored in IEEE format}

{
Usage example :

(Calling form Uses : add Xls)

Var
  FileHandle : Integer;
begin
  FileHandle := Xls_Create('c:\test\delphi.xls');

  Xls_SetFormat(FileHandle,'yyyy-mm-dd hh:mm:ss');  // user defined additional format 21

  // Xls_SetProtection(FileHandle, True);  // protect entire worksheet
  // Xls_SetAttributeByte1(True, True);  // Hidden, Locked -> only works if sheet is protected

  // some titles in the first column
  Xls_SetString(FileHandle, 0, 0, 'A random string :)');
  Xls_SetString(FileHandle, 1, 0, 'A lucky integer');
  Xls_SetString(FileHandle, 2, 0, 'Pi (in a box) - yuk :)');
  Xls_SetString(FileHandle, 3, 0, 'Today :');

  Xls_SetString(FileHandle, 0, 1, 'Hello World'); // couldn't resist the temptation
  Xls_SetInteger(FileHandle, 1, 1, 13);  // integer : lucky 13

  Xls_SetAttributeByte3(False, True, True, True, True, 0);  // show all borders
  Xls_SetDouble(FileHandle, 2, 1, Pi);  // pi = double = 3.141572...
  Xls_SetAttributeByte3(False, False, False, False, False, 0);  // reset

  Xls_SetAttributeByte2(0, 21);  // use user defined format 21
  Xls_SetDouble(FileHandle, 3, 1, Now);  // datetime
  Xls_SetAttributeByte2(0, 0);  // reset

  Xls_SetColWidth(FileHandle, 0, 17);    // set column width
  Xls_SetColWidth(FileHandle, 1, 25);    // set column width

  Xls_Close (FileHandle);  // closing stuff
end;
}

interface

uses
  SysUtils;

Function Xls_Create (FileName : String) : Integer;
Procedure Xls_Close (FileHandle : Integer);

Procedure Xls_SetAttributeByte1(Hidden, Locked : Boolean);
Procedure Xls_SetAttributeByte2(FontNumber, FormatCode : Byte);
Procedure Xls_SetAttributeByte3(Shaded, BottomBorder, TopBorder, RightBorder, LeftBorder : Boolean ; AlignMent : Byte);

Procedure Xls_SetBof(FileHandle : Integer ; Version : Word ; DocType : Word);
Procedure Xls_SetEof(FileHandle : Integer);

Procedure BiffRecordHeader(FileHandle : Integer ; OpCode : Word ; Length : Word);
Procedure BiffRecordValueWord(FileHandle : Integer ; Value : Word);
Procedure BiffRecordValueByte(FileHandle : Integer ; Value : Byte);
Procedure BiffRecordValueString(FileHandle : Integer ; Value : String);
Procedure BiffRecordValueDouble(FileHandle : Integer ; Value : Double);

Procedure Xls_SetInteger(FileHandle : Integer ; Row, Column : Word ; Value : Word);
Procedure Xls_SetBoolean(FileHandle : Integer ; Row, Column : Word ; Value : Boolean);
Procedure Xls_SetString(FileHandle : Integer ; Row, Column : Word ; Value : String);
Procedure Xls_SetDouble(FileHandle : Integer ; Row, Column : Word ; Value : Double);
Procedure Xls_SetFormatCount(FileHandle : Integer ; Count : Integer);
Procedure Xls_SetFormat(FileHandle : Integer ; FormatString : String);
Procedure Xls_SetColWidth(FileHandle : Integer ; Column: Integer ; Width : Word);
Procedure Xls_SetProtection(FileHandle : Integer ; Protect : Boolean);

Implementation
Var
  AttributeByte1 : Byte;
  AttributeByte2 : Byte;
  AttributeByte3 : Byte;

{**************************************************}
Function Xls_Create (FileName : String) : Integer;
{**************************************************}
Var
  FileHandle : Integer;
Begin
  FileHandle := FileCreate(FileName);  {result = filehandle}
  {Create bof record}
  Xls_SetBof(FileHandle, 5, 16);    {version = 5 (doesn't seem to matter) ; doctype 16 = worksheet}

  {Set initial attributebyte-values}
  Xls_SetAttributeByte1(False, False);  {Hidden, Locked -> only works if sheet is protected too}
  Xls_SetAttributeByte2(0, 0);  {fontnumber 0 = default, formatcode 0 = general}
  {Shaded, BottomBorder, TopBorder, RightBorder, LeftBorder, Alignment
  Alignment 3 = Right ; Alignment 2 = Center ; Alignment 1 = Left ; Alignment 0 = general}
  Xls_SetAttributeByte3(False, False, False, False, False, 0);

  {set initial standard Excel formats}
  Xls_SetFormatCount(FileHandle,21);  {21 standard formats (0-based)}
  Xls_SetFormat(FileHandle,'General');
  Xls_SetFormat(FileHandle,'0');
  Xls_SetFormat(FileHandle,'0.00');
  Xls_SetFormat(FileHandle,'#,##0');
  Xls_SetFormat(FileHandle,'#,##0.00');
  Xls_SetFormat(FileHandle,'\"$\"#,##0_);\\(\"$\"#,##0\\)');
  Xls_SetFormat(FileHandle,'\"$\"#,##0_);[Red]\\(\"$\"#,##0\\)');
  Xls_SetFormat(FileHandle,'\"$\"#,##0.00_);\\(\"$\"#,##0.00\\)');
  Xls_SetFormat(FileHandle,'\"$\"#,##0.00_);[Red]\\(\"$\"#,##0.00\\)');
  Xls_SetFormat(FileHandle,'0%');
  Xls_SetFormat(FileHandle,'0.00%');
  Xls_SetFormat(FileHandle,'0.00E+00');
  Xls_SetFormat(FileHandle,'m/d/yy');
  Xls_SetFormat(FileHandle,'d\\-mmm\\-yy');
  Xls_SetFormat(FileHandle,'d\\-mmm');
  Xls_SetFormat(FileHandle,'mmm\\-yy');
  Xls_SetFormat(FileHandle,'h:mm\\ AM/PM');
  Xls_SetFormat(FileHandle,'h:mm:ss\\ AM/PM');
  Xls_SetFormat(FileHandle,'h:mm');
  Xls_SetFormat(FileHandle,'h:mm:ss');
  Xls_SetFormat(FileHandle,'m/d/yy\\ h:mm');

  Result := FileHandle;    {return filehandle}
end;

{*******************************************}
Procedure Xls_Close (FileHandle : Integer);
{*******************************************}
Begin
  Xls_SetEof(FileHandle);  {create eof-record}

  FileClose(FileHandle);  {free filehandle}
end;

{*************************************************************}
Procedure Xls_SetAttributeByte1(Hidden, Locked : Boolean);
{*************************************************************}
Begin
  AttributeByte1 := 0;
  If Hidden = True Then
    AttributeByte1 := AttributeByte1 + 128;  {set bit 7}
  If Locked = True Then
    AttributeByte1 := AttributeByte1 + 64;  {set bit 6}
  {Bits 5->0 are reserved}
end;

{*****************************************************************}
Procedure Xls_SetAttributeByte2(FontNumber, FormatCode : Byte);
{*****************************************************************}
Begin
  AttributeByte2 := (FontNumber SHL 6) + FormatCode;
end;

{**************************************************************************************************************************}
Procedure Xls_SetAttributeByte3(Shaded, BottomBorder, TopBorder, RightBorder, LeftBorder : Boolean ; AlignMent : Byte);
{**************************************************************************************************************************}
Begin
  AttributeByte3 := Alignment;   {set bits 1-0}
  If Shaded = True Then   {set bit 7}
    AttributeByte3 := AttributeByte3 + 128;
  If BottomBorder = True Then  {set bit 6}
    AttributeByte3 := AttributeByte3 + 64;
  If TopBorder = True Then  {set bit 5}
    AttributeByte3 := AttributeByte3 + 32;
  If RightBorder = True Then  {set bit 4}
    AttributeByte3 := AttributeByte3 + 16;
  If LeftBorder = True Then  {set bit 3}
    AttributeByte3 := AttributeByte3 + 8;
end;

{**************************************************************************}
Procedure BiffRecordHeader(FileHandle : Integer ; OpCode : Word ; Length : Word);
{**************************************************************************}
Begin
  {Write the standard recordheader to the file}
  BiffRecordValueWord(FileHandle, OpCode);
  BiffRecordValueWord(FileHandle, Length);
end;

{**************************************************************************}
Procedure BiffRecordValueWord(FileHandle : Integer ; Value : Word);
{**************************************************************************}
Var
  Buffer : Array[0..1] of Char;
Begin
  {Write a word value to the file}
  Buffer[0] := Chr(Lo(Value)); {lsbf}
  Buffer[1] := Chr(Hi(Value));

  FileWrite(FileHandle, Buffer, 2);
end;


{**************************************************************************}
Procedure BiffRecordValueString(FileHandle : Integer ; Value : String);
{**************************************************************************}
Var
  Buffer : Array[0..255] of Char;
  i : Integer;
Begin
  {Write a string to the file}
  For i := 1 To Length(Value) do
    Buffer[i-1] := Value[i];

  FileWrite(FileHandle, Buffer, Length(Value));
end;

{**************************************************************************}
Procedure BiffRecordValueDouble(FileHandle : Integer ; Value : Double);
{**************************************************************************}
Var
  WorkDouble : Double;
  ByteArray : Array[0..7] of Byte ABSOLUTE WorkDouble;  {point to same memory address as workdouble}
  Buffer : Array[0..7] of Char;
  i : Integer;
Begin
  {Write a double to the file}
  WorkDouble := Value;
  For i := 0 to 7 do    {Delphi uses IEEE double format internally -> simple memory copy is ok}
    Buffer[i] := Chr(ByteArray[i]);

  FileWrite(FileHandle, Buffer, 8);
end;

{**************************************************************************}
Procedure BiffRecordValueByte(FileHandle : Integer ; Value : Byte);
{**************************************************************************}
Var
  Buffer : Array[0..0] of Char;  {weird code requirement fulfilled :) }
Begin
  {Write a byte to the file}
  Buffer[0] := Chr(Value);
  FileWrite(FileHandle, Buffer, 1);
end;

{**************************************************************************}
Procedure Xls_SetBof(FileHandle : Integer ; Version : Word ; DocType : Word);
{**************************************************************************}
Begin
  {Write a beginning of file (bof) record}
  BiffRecordHeader(FileHandle, 9, 4);      {9 = opcode bof, length of data}
  BiffRecordValueWord(FileHandle, Version);
  BiffRecordValueWord(FileHandle, DocType);
end;


{**************************************************************************}
Procedure Xls_SetEof(FileHandle : Integer);
{**************************************************************************}
Begin
  {Write an end of file (eof) record}
  BiffRecordHeader(FileHandle, 10, 0);    {10 = opcode eof}
end;

{************************************************************************************}
Procedure Xls_SetInteger(FileHandle : Integer ; Row, Column : Word ; Value : Word);
{************************************************************************************}
Begin
  {Write an integer value to row, column (0-based)
  Caveat : only for unsigned, possitive integers that fit in a word : 0-65535 (or whatever)}
  BiffRecordHeader(FileHandle,2,9);   {2 = Opcode Integer}
  BiffRecordValueWord(FileHandle,Row);
  BiffRecordValueWord(FileHandle,Column);

  BiffRecordValueByte(FileHandle,AttributeByte1); {attributes define the look of the cell}
  BiffRecordValueByte(FileHandle,AttributeByte2);
  BiffRecordValueByte(FileHandle,AttributeByte3);
  BiffRecordValueWord(FileHandle,Value);
end;

{************************************************************************************}
Procedure Xls_SetBoolean(FileHandle : Integer ; Row, Column : Word ; Value : Boolean);
{************************************************************************************}
Begin
  {Write an boolean value to row, column (0-based)
  Added 28.mar.2000 by Michael Bruus}
  BiffRecordHeader(FileHandle,5,9);   {5 = Opcode BoolErr}
  BiffRecordValueWord(FileHandle,Row);
  BiffRecordValueWord(FileHandle,Column);

  BiffRecordValueByte(FileHandle,AttributeByte1); {attributes define the look of the cell}
  BiffRecordValueByte(FileHandle,AttributeByte2);
  BiffRecordValueByte(FileHandle,AttributeByte3);
  IF Value THEN BiffRecordValueByte(FileHandle,1)  //Write true or false value
  ELSE BiffRecordValueByte(FileHandle,0);
  BiffRecordValueByte(FileHandle,0);     //Specifies value is boolean, not errorcode
end;


{*************************************************************************************}
Procedure Xls_SetString(FileHandle : Integer ; Row, Column : Word ; Value : String);
{*************************************************************************************}
Begin
  {Write a string to row, column}
  BiffRecordHeader(FileHandle,4,8 + Length(Value));   {4 = Opcode String/Label}
  BiffRecordValueWord(FileHandle,Row);
  BiffRecordValueWord(FileHandle,Column);

  BiffRecordValueByte(FileHandle,AttributeByte1);  {attributes define the look of the cell}
  BiffRecordValueByte(FileHandle,AttributeByte2);
  BiffRecordValueByte(FileHandle,AttributeByte3);
  BiffRecordValueByte(FileHandle,Length(Value));
  BiffRecordValueString(FileHandle,Value);
end;

{************************************************************************************}
Procedure Xls_SetDouble(FileHandle : Integer ; Row, Column : Word ; Value : Double);
{************************************************************************************}
Begin
  {Write a double value to row, column}
  {Caveat : Dates are just doubles with formatting applied}
  BiffRecordHeader(FileHandle, 3, 15);   {3 = Opcode Double}
  BiffRecordValueWord(FileHandle, Row);
  BiffRecordValueWord(FileHandle, Column);

  BiffRecordValueByte(FileHandle, AttributeByte1); {attributes define the look of the cell}
  BiffRecordValueByte(FileHandle, AttributeByte2);
  BiffRecordValueByte(FileHandle, AttributeByte3);

  BiffRecordValueDouble(FileHandle, Value);
end;


{*************************************************************************}
Procedure Xls_SetFormatCount(FileHandle : Integer ; Count : Integer);
{*************************************************************************}
Begin
  {Define the number of standard formats : (21)}
  BiffRecordHeader(FileHandle, 31, 2);   {31 = Opcode Formatcount}
  BiffRecordValueWord(FileHandle, Count);
end;

{*************************************************************************}
Procedure Xls_SetFormat(FileHandle : Integer ; FormatString : String);
{*************************************************************************}
Begin
  {Add an additional format-string to the internal formatlist}
  BiffRecordHeader(FileHandle, 30, Length(FormatString) + 1);   {30 = Opcode Format}
  BiffRecordValueByte(FileHandle, Length(FormatString));
  BiffRecordValueString(FileHandle, FormatString);
end;

{*********************************************************************************}
Procedure Xls_SetColWidth(FileHandle : Integer ; Column: Integer ; Width : Word);
{*********************************************************************************}
Begin
  BiffRecordHeader(FileHandle, 36, 4);   {36 = Opcode colwidth}
  BiffRecordValueByte(FileHandle, Column);  {starting column}
  BiffRecordValueByte(FileHandle, Column);  {ending column}
  BiffRecordValueWord(FileHandle, Width * 256);  {width is defined in 1/256 of a character}
end;

{*********************************************************************}
Procedure Xls_SetProtection(FileHandle : Integer ; Protect : Boolean);
{*********************************************************************}
Begin
  {Set general protection setting of worksheet}
  BiffRecordHeader(FileHandle, 18, 2);      {18 = opcode protected worksheet}
  If Protect = True Then
    BiffRecordValueWord(FileHandle, 1)
  else
    BiffRecordValueWord(FileHandle, 0);
end;



end.



