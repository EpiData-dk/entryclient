unit kpSStrm;

{ Secrets of Delphi 2, by Ray Lischner. (1996, Waite Group Press).
  Chapter 3: Streams and File I/O
  Copyright © 1996 The Waite Group, Inc. }

{ Buffered I/O stream and buffered text stream. }

{ $Log:  D:\Util\GP-Version\Archives\Components\VCLZip\Library\kpSStrm.UFV 
{
{   Rev 1.1    Sun 05 Jul 1998   09:13:48  Supervisor
{ Changed Cardinal to LongInt
}

{$P-} { turn off open parameters }
{$Q-} { turn off overflow checking }
{$R-} { turn off range checking }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }

interface

uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinTypes,
{$ENDIF}
  Classes, SysUtils;

type
  TS_BufferState = (bsUnknown, bsRead, bsWrite);
  TS_BufferStream = class(TStream)
  private
    fStream: TStream;
    fBuffer: PChar;
    fBufPtr: PChar;
    fBufEnd: PChar;
    fBufSize: Cardinal;
    fState: TS_BufferState;
    {$IFDEF WIN32}
    fFlushOnDestroy: Boolean;
    fWritten: Boolean;
    {$ENDIF}
    fOnFillBuffer: TNotifyEvent;
    fOnFlushBuffer: TNotifyEvent;
    function GetBufPosition: Integer;
  protected
    function FillBuffer: Boolean; virtual;
    function FlushBuffer: Boolean; virtual;
    procedure PutBack(Ch: Char); virtual;
    procedure AfterFillBuffer; virtual;
    procedure AfterFlushBuffer; virtual;
    property Buffer: PChar read fBuffer;
    property BufPtr: PChar read fBufPtr;
    property BufSize: Cardinal read fBufSize;
    property BufEnd: PChar read fBufEnd;
    property BufPosition: Integer read GetBufPosition;
    property State: TS_BufferState read fState;
    property Stream: TStream read fStream;
  public
    constructor Create(Stream: TStream; BufferSize: Integer); virtual;
    destructor Destroy; override;
    function Read(var Buffer; Count: LongInt): LongInt; override;
    function Write(const Buffer; Count: LongInt): LongInt; override;
    function Seek(Offset: LongInt; Origin: Word): LongInt; override;
    function IsEof: Boolean;
    {$IFDEF WIN32}
    property FlushOnDestroy: Boolean read FFlushOnDestroy write FFlushOnDestroy default False;
    {$ENDIF}
    property OnFillBuffer: TNotifyEvent read fOnFillBuffer
        write fOnFillBuffer;
    property OnFlushBuffer: TNotifyEvent read fOnFlushBuffer
        write fOnFlushBuffer;
  end;

{const
   BufferSize: Integer = 524288;}  { changed to property 05/11/00  2.20+  }
                                   { to increase speed esp for spanning }
implementation

uses
{$IFNDEF WIN32}
  WinProcs,
  kpLib,
{$ENDIF}
  kpSHuge{$IFNDEF NO_RES}, kpzcnst {$ENDIF} {, kpStrRes};

{ Create and initialize a buffer stream. }
constructor TS_BufferStream.Create(Stream: TStream; BufferSize: Integer);
begin
  inherited Create;
  fStream := Stream;
  fBufSize := BufferSize;
  { Allocate the buffer. }
  GetMem(fBuffer, BufSize);
  fBufEnd := Buffer + BufSize;
  fState := bsUnknown;
  {$IFDEF WIN32}
  fFlushOnDestroy := False;
  fWritten := False;
  {$ENDIF}
end;

{ Destroy the buffer stream. If the buffer is in write mode, then
  make sure the last bufferful is written to the stream. }
destructor TS_BufferStream.Destroy;
begin
  if State = bsWrite then
    FlushBuffer;
    {$IFDEF WIN32}
    if FFlushOnDestroy and FWritten then
     if Stream is THandleStream then
        FlushFileBuffers((Stream as THandleStream).Handle);
    {$ENDIF}
  FreeMem(fBuffer {$IFNDEF WIN32}, BufSize {$ENDIF});
  inherited Destroy;
end;

{ Fill the input buffer. }
function TS_BufferStream.FillBuffer: Boolean;
var
  NumBytes: LongInt;
begin
  { Read from the actual stream. }
  NumBytes := Stream.Read(Buffer^, BufSize);
  { Set the buffer pointer and end. }
  fBufPtr := Buffer;
  fBufEnd := Buffer + NumBytes;
  { If nothing was read, it must be the end of file. }
  Result := NumBytes > 0;
  if Result then
    fState := bsRead
  else
    fState := bsUnknown;
  AfterFillBuffer;
end;

{ Write the output buffer to the stream. When done, the
  buffer is empty, so set the state back to bsUnknown. }
function TS_BufferStream.FlushBuffer: Boolean;
var
  NumBytes: LongInt;
begin
  { Determine the number of bytes in the buffer. }
  NumBytes := BufPtr - Buffer;
  { Write the buffer contents. }
  Result := NumBytes = Stream.Write(Buffer^, NumBytes);
  { Th ebuffer is empty, so reset the state. }
  fBufPtr := Buffer;
  fState := bsUnknown;
  AfterFlushBuffer;
end;

{ Read Count bytes. Copy first from the input buffer, and then
  fill the input buffer repeatedly, until fetching all Count bytes.
  Return the number of bytes read. If the state was Write, then
  flush the output buffer before reading. }
function TS_BufferStream.Read(var Buffer; Count: LongInt): LongInt;
var
  Ptr: PChar;
  NumBytes: LongInt;
begin
  if State = bsWrite then
    FlushBuffer
  else if BufPtr = nil then
    fBufPtr := BufEnd; { empty buffer, so force a FillBuffer call }

  { The user might ask for more than one bufferful.
    Prepare to loop until all the requested bytes have been read. }
  Ptr := PChar(@Buffer);
  Result := 0;
  while Count > 0 do
  begin
    { If the buffer is empty, then fill it. }
    if BufPtr = BufEnd then
      if not FillBuffer then
        Break;
    NumBytes := BufEnd - BufPtr;
    if Count < NumBytes then
      NumBytes := Count;

    { Copy the buffer to the user's memory. }
    HMemCpy(Ptr, BufPtr, NumBytes);
    { Increment the pointers. The stream’s buffer is always within a single
      segment, but the user's buffer might cross segment boundaries. }
    Dec(Count, NumBytes);
    Inc(fBufPtr, NumBytes);
    Inc(Result, NumBytes);
    Ptr := HugeOffset(Ptr, NumBytes);
  end;
end;

{ Write Count bytes from Buffer to the stream. If the state was
  bsRead, then reposition the stream to match. }
function TS_BufferStream.Write(const Buffer; Count: LongInt): LongInt;
var
  Ptr: Pointer;
  NumBytes: LongInt;
begin
  { If the stream is for reading, then ignore the current buffer
    by forcing the position of the underlying stream to match
    the buffered stream's position. }
  if State = bsRead then
    fStream.Position := Position
  else if BufPtr = nil then
  begin
    { Unknown state, so start with an empty buffer. }
    fBufPtr := fBuffer;
    fBufEnd := fBuffer + BufSize;
  end;

  { The user might write more than one bufferful.
    Prepare to loop until all the requested bytes have been written. }
  Ptr := @Buffer;
  Result := 0;                   { Total number of bytes written. }
  while Count > 0 do
  begin
    { Calculate the number of bytes remaining in the buffer. }
    NumBytes := BufEnd - BufPtr;
    if Count < NumBytes then
      NumBytes := Count;
    { Copy from the user's memory to the buffer. }
    HMemCpy(BufPtr, Ptr, NumBytes);
    { Increment the pointers. The stream's buffer is always in
      a single segment, but the user's buffer might cross
      segment boundaries.}
    Dec(Count, NumBytes);
    Inc(fBufPtr, NumBytes);
    Inc(Result, NumBytes);
    Ptr := HugeOffset(Ptr, NumBytes);
    if BufPtr = BufEnd then
      if not FlushBuffer then
        Break;
  end;
  { If anything remains in the buffer, then set the state to bsWrite. }
  if BufPtr <> fBuffer then
    fState := bsWrite;
  {$IFDEF WIN32}
  fWritten := True;
  {$ENDIF}
end;

{ Seek to a new position. Calling Seek to learn the current
  position is a common idiom, so do not disturb the buffers
  and just return the position, taking the current buffer
  position into account. If the Seek is to move to a different
  position in the stream, the dump the buffer and reset the state. }
function TS_BufferStream.Seek(Offset: LongInt; Origin: Word): LongInt;
var
  CurrentPosition: LongInt;

  { this function needed because Stream.Size is not always the actual end }
  { of the file.  There is likely some in the buffer not flushed out yet  }
  { Added by Kevin L. Boylan, KpGb Software, 10/09/97 }
  function RealSize: LongInt;
  begin
     Result := Stream.Position + BufPosition;
     If Result < Stream.Size then
        Result := Stream.Size;
  end;

begin
  { Determine the current position. }
  CurrentPosition := Stream.Position + BufPosition;

  { Determine the new position }
  case Origin of
  soFromBeginning: Result := Offset;
  soFromCurrent:   Result := Stream.Position + BufPosition + Offset;
  {soFromEnd:       Result := Stream.Size - Offset;}
  { Modified 10/09/97 by Kevin L. Boylan, KpGb Software }
  { Needed Abs() because a negative offset number is expected with soFromEnd }
  { Needed RealSize, see function above }
  soFromEnd:       Result := RealSize - Abs(Offset);
  else
     {$IFDEF NO_RES}
        raise Exception.CreateFmt('\030Invalid seek origin (%d)', [Origin]);
     {$ELSE}
        raise Exception.CreateFmt(LoadStr(IDS_SEEKORIGINERROR), [Origin]);
     {$ENDIF}
  end;

  { Is the desired position different? }
  if Result <> CurrentPosition then
  begin
    { Flush a partial write. }
    if (State = bsWrite) and not FlushBuffer then
     {$IFDEF NO_RES}
        raise EStreamError.Create('\012Seek error');
     {$ELSE}
        raise Exception.CreateFmt(LoadStr(IDS_SEEKERROR), [Origin]);
     {$ENDIF}
    { Reset the stream. }
    Stream.Position := Result;
    { Discard the current buffer. }
    fBufPtr := nil;
    fState := bsUnknown;
  end;
end;

{ Return an offset that can be added to Stream.Position to
  yield the effective position in the stream. }
function TS_BufferStream.GetBufPosition: Integer;
begin
  Result := 0;
  case State of
  bsUnknown:
    Result := 0;
  bsRead:
    Result := BufPtr - BufEnd;
  bsWrite:
    Result := BufPtr - Buffer;
  end;
end;

{ Push a character back onto the input buffer. }
procedure TS_BufferStream.PutBack(Ch: Char);
begin
  if fBufPtr <= fBuffer then
    {$IFDEF NO_RES}
     raise EStreamError.Create('\020Putback overflow');
    {$ELSE}
     raise EStreamError.Create(LoadStr(IDS_PUTBACKOVERFLOW));
    {$ENDIF}
  Dec(fBufPtr);
  BufPtr[0] := Ch;
end;

{ Return whether the current position is at the end of the file. }
function TS_BufferStream.IsEof: Boolean;
begin
  Result := (BufPtr = BufEnd) and (Stream.Position = Stream.Size);
end;

procedure TS_BufferStream.AfterFillBuffer;
begin
  if Assigned(fOnFillBuffer) then
    fOnFillBuffer(Self);
end;

procedure TS_BufferStream.AfterFlushBuffer;
begin
  if Assigned(fOnFlushBuffer) then
    fOnFlushBuffer(Self);
end;

end.
