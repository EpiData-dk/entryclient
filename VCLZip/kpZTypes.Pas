{**********************************************************************}
{ Unit archived using GP-Version                                       }
{ GP-Version is Copyright 1997 by Quality Software Components Ltd      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.qsc.u-net.com                                             }
{**********************************************************************}

{ $Log:  D:\Util\GP-Version\Archives\Components\VCLZip\Component Files\kpZTypes.UFV 
{
{   Rev 1.2    Sat 04 Jul 1998   16:25:30  Supervisor
{ Modified ULONG to U_LONG because of ULONG 
{ definition in C++ Builder.
}
{
{   Rev 1.1    Mon 27 Apr 1998   17:31:48  Supervisor
{ Added new exception that is thrown when output files get 
{ larger than should be.
}

{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: UZTypes.pas                                                       }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, CIS: boylank                                        }
{                                Internet: boylank@compuserve.com                    }
{                                                                                    }
{ ********************************************************************************** }
type

{ UNZIP }
  {$IFDEF HAS_64_BIT_INT}
  BIGINT = INT64;
  {$ELSE}
  BIGINT = LongInt;
  {$ENDIF}
  CharArrayPtr = ^CharArray;
  CharArray = array[0..MaxInt-1] of Char;
  ByteArrayPtr = ^ByteArray;
  ByteArray = array[0..MaxInt-1] of Byte;
  IntegerArrayPtr = ^IntegerArray;
  IntegerArray = array[0..MAX_SHORT-1] of Integer;
  IntPtr = ^Integer;
 BYTEPTR = PByte;
  WORDPTR = ^WORD;
 short_int = smallint;
  shrinktype = packed Record
     Prefix_of: array [0..HSIZE+2] of short_int;
     Suffix_of: array [0..HSIZE+2] of Byte;
     Stack    : array [0..HSIZE+2] of Byte;
  end;
  DataDescriptorType = packed Record
     Sig:     LongInt;
     crc32:   LongInt;
     compressed_size: LongInt;
     uncompressed_size: LongInt;
  end;

{$IFNDEF INFLATE_ONLY}
{ UNSHRINK }
{ EXPLODE }
{ UNREDUCE }
 f_array = array[0..255,0..63] of Byte;
  f_arrayPtr = ^f_array;      { 5/18/98  2.13 }
{$ENDIF}

{ INFLATE }
 huftptr = ^huft;
  huftptrptr = ^huftptr;
  huftarrayptr = ^huftarray;
  huft = packed Record
   e:  Byte;
     b:  Byte;
  v:  Record
      case Integer of
         0: (  n:  WORD );
         1: (  t:  huftptr );
     end;
  end;
  huftarray = packed array[-1..1000] of huft;
 llarrayptr = ^llarraytype;
 llarraytype = packed array [0..(286+30-1)] of WORD;

{ FILE }

 slidearray = array [0..WSIZE-1] of byte;
  slidearrayptr = ^slidearray;
  work = packed Record
     case Integer of
      0: (  shrink: shrinktype );
      1: ( Slide: slidearray);
   end;
 pString = ^String;
  ppString = ^pString;
  TZipFilename = String; {[FILENAME_LEN]; }
 TZipPathname = String; {[PATH_LEN]; }

 TNewDiskEvent = procedure(Sender: TObject; var S: TStream) of Object;

