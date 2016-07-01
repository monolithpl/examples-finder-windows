unit ACConsts;
{.$G+}
{$I QUIET.INC}
{
  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto: aa\\AT@|s.o.f.t,i.n.d.o|DOT-net,
  mailto (dont strip underbar): zero_inge\AT/\y.a,h.o.o\@DOT\\com
  http://delphi.softindo.net

  Version: 2.0.0
  Dated: 2005.12.01
}

{$J-} // these are truly constants
interface

const
  CR_ = #10;
  LF_ = #13;
  CRLF = #13#10;
  CR2 = #10#10;
  CRLF2 = CRLF + CRLF;
  CHAR_TAB = #9;
  CHAR_COLON = ':';
  CHAR_DOT = '.';
  CHAR_DASH = '-';
  CHAR_SLASH = '/';
  CHAR_BACKSLASH = '\';
  CHAR_STAR = '*';
  CHAR_SPACE = ' ';
  CHAR_ZERO = '0';
  CHAR_COMMA = ',';

  COMMA = CHAR_COMMA;
  SPACE = CHAR_SPACE;
  COMMASPACE = CHAR_COMMA + CHAR_SPACE;
  COLONSPACE = CHAR_COLON + CHAR_SPACE;

  DEFAULT_DELIMITER = COMMA;

  TAB = CHAR_TAB;
  TAB2 = TAB + TAB;
  TABCT = TAB + CHAR_COLON + TAB;
  TABCS = TAB + CHAR_COLON + CHAR_SPACE;

  ESCAPE = #27;
  BKSPACE = #8;
  BACKSPACE = BKSPACE;

  //CR2: string[2] = CR_ + CR_;
  //TAB2: string[2] = TAB + TAB;
  //CRLF2: string[4] = CRLF + CRLF;

  YES = TRUE;
  NAY = not TRUE;
  OFF = not TRUE;
  // OOH = not YES; NOO = OOH; //that means OOH-NOO equal with NAY

  IYA = TRUE;
  Enggak = not IYA;
  GAK = Enggak;

  DECIMAL_DIGIT = ['0'..'9'];
  NUMERIC = DECIMAL_DIGIT;

  HEXLOCASE = NUMERIC + ['a'..'f'];
  HEXUPCASE = NUMERIC + ['A'..'F'];

  HEXDIGITS = HEXLOCASE + HEXUPCASE;

  ALPHALOCASE = ['a'..'z'];
  ALPHAUPCASE = ['A'..'Z'];

  ALPHABET = ALPHALOCASE + ALPHAUPCASE;
  ALPHANUMERIC = ALPHABET + NUMERIC;

  COMMON_NAVIGATIONKEYS = [BACKSPACE, TAB, CR_, LF_, ESCAPE];

  DEFAULT_BLOCKDIGITS = 5;
  DEFAULT_DELIMITERS = [',', '.', '-', ' ', ':', '/', '=']; //[',', '.', '-', ' ',':','/'];

  //var
  //  __DELIMITERS: set of char = DEFAULT_DELIMITERS;
  //  __HEXNUM_UPPERCASE: string[16] = '0123456789ABCDEF';
  //  __HEXNUM_LOWERCASE: string[16] = '0123456789abcdef';

  __CRC32Poly__ = $EDB88320; // widely used CRC32 Polynomial
  __AAMAGIC0__ = $19091969; // my birthdate
  __AAMAGIC1__ = $22101969; // my wife's birthdate
  __AAMAGIC2__ = $09022004; // my (first) son's birthdate
  __AAMAGIC3__ = $04012006; // my second son's
  _1K = 1024;
  _1M = _1K * _1K;

  _Error_ = 'Error ';
  Elipsis = '...';
  Unknown = 'Unknown';

type
  TChar_AlphaUpCase = 'A'..'Z';
  TChar_AlphaLoCase = 'a'..'z';
  TChar_Numeric = '0'..'9';
  TChar_HexLoCase = 'a'..'f';
  TChar_HexUpCase = 'A'..'F';
  TChar_Control = #0..#$1F;

  TWords = packed array of word;
  TArWords = packed array of TWords;
  TInts = packed array of integer;
  TArInts = packed array of TInts;
  TStrs = packed array of string;
  TBools = packed array of boolean;

  PIntegerArray = ^IntegerArray;
  IntegerArray = array[Word] of integer;
  PCardinal = ^Cardinal;

{$IFNDEF USES_SYSUTILS_6UP}
  PWordArray = ^TWordArray;
  TWordArray = packed array[0..16 * _1K - 1] of Word;

  PByteArray = ^TByteArray;
  TByteArray = packed array[0..32 * _1K - 1] of Byte;

  PInteger = ^Integer;
  PWord = ^Word;
  PByte = ^Byte;

  PCurrency = ^Currency;
  PDouble = ^Double;
  PSingle = ^Single;
  PExtended = ^Extended;
{$ENDIF}

const
  MaxCardinal = 4294967295; // high(Cardinal), 10 digits
  MaxInt64 = 9223372036854775807; // high(Int64), 19 digits
  MaxCardinal64S = '18446744073709551615'; // unsigned Int64, 20 digits
  MaxInt64x = $7FFFFFFFFFFFFFFF;
  EXTPI = 3.141592653589793238462643383279502884197169399375105820974944592307;
  _1e19 = $8AC7230489E80000; // -8446744073709551616
  //_1e18 = $0DE0B6B3A7640000;
  //SMinInt64: string = '-9223372036854775808';

implementation
{$ALIGN ON}
const
  TABLE_HEXDIGITS: packed array[0..31] of char = '0123456789ABCDEF0123456789abcdef';
  TABLE_HEXDIGITS2: packed array[0..1023] of char = '0123456789ABCDEF0123456789abcdef';

  // MUST be power of 2 of range 256 to 32K ($100..$8000);
  RECIPROCAL_INT_ELEMENTS = $400;

type
  TReciprocalInt = packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of cardinal;
  TReciprocalInt64 = packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of Int64;

var // these are actually global constants
  //ReciprocalInt64: packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of int64;
  //ReciprocalInt: packed array[0..RECIPROCAL_INT_ELEMENTS - 1] of cardinal;
  PReciprocalInt: ^TReciprocalInt;
  PReciprocalInt64: ^TReciprocalInt64;

  //implementation

procedure _bri(const Buffer; const Int64Size: boolean); assembler asm
  test eax, eax; jnz @@Start; ret
@@Start: push edi; push ebx; mov edi, [eax]
  mov eax, 1 shl 31; xor ecx, ecx
  and edx, 1               // make sure it's either 0 or 1
  //lea edx, edx*4+4       // how many bytes
  //lea edx, edx*8-1       // how many bits (in-excess of 1)
  mov edx, -1
  mov [edi], ecx; mov [edi+4], eax
  mov [edi+8], edx; mov [edi+12], edx
  mov [edi+16], ecx; mov [edi+20], eax
  jnz @@1; mov [edi], eax; mov [edi+4], edx; mov [edi+8], eax

@@1: setnz cl
  lea eax, [ecx*4]           //equ above
  lea eax, eax*8+31          //equ above
  ; push eax
  fld1; fst st(1); fadd st, st
  fild dword[esp]
  ; pop eax
  fld st(1); fscale
  fsub st, st(3)             //dec-by-one
  fstp st(1)

@preLoop: xor ebx, ebx; mov bl, 3
    @Loop:
    //                    // BEFORE              |  AFTER
    //1: high(I) div n    // st0  st1  st2  st3  |  st0  st1  st2  st3
       fld st(2)          //  X    n    1    -   |   1    X    n    1
       fadd st, st(2)     //  1    X    n    1   |  n+1   X    n    1
       fst st(2)          // n+1   X    n    1   |  n+1   X   n+1   1
       fdivr st, st(1)    //

    //2: high(I) added by (n-1) before divided by n
    //  fld st(2)
    //  fadd st, st(2)
    //  fst st(2)
    //  fld
    //  fadd
    //  fdiv st, st(2)

    //fistp qword[esp]; mov eax, [esp]; mov edx, [esp+4]
    //test cl,1; jnz @8
    //  @4: mov edi+ebx*4, eax; jmp @Loope
    //  @8: mov edi+ebx*8, eax; mov edi+ebx*8+4, edx

    test cl,1; jnz @8
      @4: fistp dword ptr[edi+ebx*4]; jmp @Loope
      @8: fistp qword ptr[edi+ebx*8]

    @Loope: inc ebx;  test bh, RECIPROCAL_INT_ELEMENTS shr 8; jz @Loop
    fstp st(1); fstp st(1); ffree st
  @@Stop: pop ebx; pop edi
end;

procedure _buildReciprocalInt;
begin
  getmem(PReciprocalInt, sizeof(PReciprocalInt^));
  getmem(PReciprocalInt64, sizeof(PReciprocalInt64^));
  //fillchar(PReciprocalInt^, sizeof(PReciprocalInt^), $11);
  //fillchar(PReciprocalInt64^, sizeof(PReciprocalInt64^), $11);
  _bri(PReciprocalInt, FALSE);
  _bri(PReciprocalInt64, TRUE);
end;

procedure _buildhexcharset; assembler asm
  xor ecx, ecx
  @loop1: mov eax, ecx; mov ah, al
    shr al, 04h; and ah, 0fh
    cmp al, 9; jbe @upAL; add al, 'A'-'0'-10
    @upAL: add al, '0'
    cmp ah, 9; jbe @upAH; add ah, 'A'-'0'-10
    @upAH: add ah, '0'
    mov word [TABLE_HEXDIGITS2+ecx*2], ax
  inc cl; jnz @loop1

  @loop2: mov eax, ecx; mov ah, al
    shr al, 04h; and ah, 0fh
    cmp al, 9; jbe @loAL; add al, 'a'-'0'-10
    @loAL: add al, '0'
    cmp ah, 9; jbe @loAH; add ah, 'a'-'0'-10
    @loAH: add ah, '0'
    mov word [TABLE_HEXDIGITS2+ecx*2+512], ax
  inc cl; jnz @loop2

end;

procedure init;
begin
  _buildhexcharset;
  _buildReciprocalInt
end;

initialization init;

end.

