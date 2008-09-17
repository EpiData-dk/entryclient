{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: File.pas                                                          }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, boylank@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }
{$Q-} { turn off overflow checking }
{$R-} { turn off range checking }

function xFlushOutput: WORD;
var
  len, savelen: WORD;
  Percent: LongInt;
  Cancel: Boolean;
begin
 if (outcnt <> 0) then
  begin
     len := outcnt;
     savelen := outcnt;
     outptr := outbuf;
     { 4/16/98 2.11 }  { moved to before the Write, 7/15/98  2.14 }
     If (MemZipping) then
      begin
        If (len > MemLeft) then
           raise EBiggerThanUncompressed.Create('File is larger than uncompressed size!');
        Repeat
           if (not FTestMode) then  { 12/3/98  2.17P+ }
            begin
              If (BufferLength > 0) and ((LongInt(CurrMem)-LongInt(MemBuffer)) + outcnt > BufferLength) then
                 len := BufferLength - (LongInt(CurrMem)-LongInt(MemBuffer));
              MoveMemory(CurrMem, outptr, len);
              Dec(outcnt,len);
              Dec(MemLeft,len);
              Inc(CurrMem,len);
              Inc(outptr, len);
              len := outcnt;
              If (outcnt>0) or ((BufferLength>0) and (MemLeft = 0)) then
               begin
                 Cancel := MemLeft = 0; { Cancel = True for last call }
                 FOnGetNextBuffer(Self, MemBuffer, file_info.directory+file_info.filename,
                                  (LongInt(CurrMem)-LongInt(MemBuffer)), CurrentDisk+1, Cancel);
                 If (MemLeft > 0) and (Cancel) then
                    raise EUserCanceled.Create('User canceled Buffered Memory UnZip');
                 Inc(CurrentDisk);
                 CurrMem := MemBuffer;
              end;
            end
           Else
              outcnt := 0;
        Until (outcnt = 0);
      end
     Else
      begin
        If (zip_out_file.Position+len) > file_info.uncompressed_size then
           {$IFDEF NO_RES}
           raise EBiggerThanUncompressed.Create('File is larger than uncompressed size!');
           {$ELSE}
           raise EBiggerThanUncompressed.Create(LoadStr(IDS_OUTPUTTOLARGE));
           {$ENDIF}
        if (zip_out_file.Write( outbuf^, len ) <> len) then
           {$IFDEF NO_RES}   { 2/9/00 2.20+ }
           raise ECantWriteUCF.Create('Cant write uncompressed file!');
           {$ELSE}
           raise ECantWriteUCF.Create(LoadStr(IDS_CANTWRITEUCF));
           {$ENDIF}
     end;
     Update_CRC_buff( outbuf, savelen );
     Inc(outpos, savelen);
     if Assigned(FOnFilePercentDone) then
      begin
        Percent := CRate( file_info.uncompressed_size, outpos );
        {Percent := min(((outpos * 100) div file_info.uncompressed_size), 100 ); }
        FOnFilePercentDone( self, Percent );
      end;
     if Assigned(FOnTotalPercentDone) then
      begin
        TotalBytesDone := TotalBytesDone + savelen;
        {Inc(TotalBytesDone, outcnt);}
        Percent := CBigRate( TotalUncompressedSize, TotalBytesDone );
        {Percent := min(((TotalBytesDone * 100) div TotalUncompressedSize), 100 );}
        FOnTotalPercentDone( self, Percent );
      end;
     outcnt := 0;
     outptr := outbuf;
  end;
 Result := 0;
end;

function ReadByte( var x: WORD ): Integer;
var
 number_to_read, number_read: Integer;
  tmpbuf: BYTEPTR;
begin
  If csize <= 0 then
   begin
   Dec(csize);
   Result := 0;
     exit;
   end;
  Dec(csize);
  If incnt = 0 then
   begin
     If DoProcessMessages then
      begin
        {$IFNDEF KPSMALL}
        Application.ProcessMessages;
        {$ELSE}
        YieldProcess;
        {$ENDIF}
        If CancelOperation then
         begin
           CancelOperation := False;
           raise EUserCanceled.Create('User Aborted Operation');
         end;
      end;
     number_to_read := kpmin( file_info.compressed_size, LongInt(INBUFSIZ) );
     file_info.compressed_size := file_info.compressed_size - number_to_read;
     number_read := zip_in_file.Read( inbuf^, number_to_read );
     incnt := number_read;
     If (((ecrec.this_disk = 0) or (not (Assigned(FOnGetNextDisk))))
        and (incnt < number_to_read)) then
           raise EFatalUnzipError.Create('Premature end of file reached');
     tmpbuf := inbuf;
     While (incnt < number_to_read) do  {2/1/98 Changed If to While}
      begin
        zip_in_file := SwapDisk( CurrentDisk+2 );
        If zip_in_file = nil then  {2/1/98}
           raise EUserCanceled.Create('User Aborted Operation');
        Inc(tmpbuf,number_read);
        number_read := zip_in_file.Read( tmpbuf^, number_to_read-incnt );
        Inc(incnt, number_read);
      end;
     If file_info.Encrypted then
        decrypt_buff( inbuf, number_to_read );
     { Cant do the following to a property}
     {Dec(file_info.compressed_size, number_to_read);}
     If incnt <= 0 then
      begin
        Result := 0;
        exit;
      end;
     inptr := inbuf;
   end;
  x := inptr^;
  Inc(inptr);
  Dec(incnt);
  Result := 8;
end;

function FillBitBuffer: Integer;
var
 temp: WORD;
begin
  zipeof := True;
  while (bits_left < 25) and (ReadByte(temp) = 8) do
   begin
     bitbuf := bitbuf or U_LONG((U_LONG(temp) shl bits_left));
     Inc(bits_left, 8);
     zipeof := False;
   end;
  Result := 0;
end;

{ MACRO'S}
procedure OUTB( intc: BYTE );
begin
  outptr^ := intc;
  Inc(outptr);
  Inc(outcnt);
  If outcnt = OUTBUFSIZ then
     xFlushOutput
end;

procedure READBIT( nbits: WORD; var zdest: short_int );
begin
  if nbits > bits_left then
     FillBitBuffer;
  zdest :=  short_int(WORD(bitbuf) and mask_bits[nbits]);
  bitbuf := U_LONG(bitbuf shr nbits);
  Dec(bits_left, nbits);
end;

procedure NEEDBITS(n: WORD; var b: U_LONG; var k: WORD);
begin
 while (k < n) do
   begin
     ReadByte(bytebuf);
     b := b or U_LONG((U_LONG(bytebuf) shl k));
     Inc(k,8);
   end;
end;

procedure DUMPBITS( n: WORD; var b: U_LONG; var k: WORD );
begin
  b := U_LONG(b shr n);
  Dec(k,n);
end;

{ 7/9/98 6:47:18 PM 
{ Version 2.13
{ 
{ 1) New property ResetArchiveBitOnZip causes each file's 
{ archive bit to be turned  off after being zipped.
{ 
{ 2) New Property SkipIfArchiveBitNotSet causes files 
{ who's archive bit is not set to be skipped during zipping 
{ operations.
{ 
{ 3) A few modifications were made to allow more 
{ compatibility with BCB 1.
{ 
{ 4) Modified how directory information is used when 
{ comparing filenames to be unzipped.  Now it is always 
{ used.
}
{
{ Sat 04 Jul 1998   16:24:12
{ Modified ULONG to U_LONG because of ULONG 
{ definition in C++ Builder.
}
{
{ Mon 27 Apr 1998   18:03:25
{ Modified to raise exception if output file is larger than 
{ uncompressed size
}

