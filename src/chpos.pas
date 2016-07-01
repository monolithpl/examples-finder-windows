unit chpos;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug

{$I QUIET.INC}

// *fast* charpos unit
// extracted originally from unit cxpos ver 2.0.1.5
// search/pos character centrist (works also for repeated char)
// intended for extensive, heavy use
//
// ====================================================================
//  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
//  Property of PT SOFTINDO Jakarta.
//  All rights reserved.
// ====================================================================
//
//  mailto: aa\\AT|s.o.f.t,i.n.d.o\|DOT-net,
//  mailto (dont strip underbar): zero_inge\AT/\y.a,h.o.o|\DOT\\com
//  http://delphi.softindo.net
//

// CHANGES:
// =======

// 1.0.3.2c (2005.03.10)
// added: dirty variants of upper/lowercase function: UpperCased & LowerCased
// added: charset variants of trim functions
//
// SameBuffer (CompareMem) needs rework

// 1.0.3.2b
// fixed bug on wcharpos (_cwordpos)

// 1.0.3.2a
// internal

// 1.0.3.2
// fixed bug on _iCompare & _piCompare // a bad-bad.. bug
// extend several charpos functions to accept characters class
// (using TCharIndexTable, indexed character set; for speed;
//  use InitIndexTable to initialize it);
//
// 1.0.3.0
// fixed bug on _cCompare & _pcCompare
//
// note:
//   Under BackPos search, StartPos means the starting position
//   of the search. Normally it should be equal with the end of
//   the string to be searched (the length of the string).
//   -----------------------------------------------------
//   You MUST supply the StartPos value manually, since it
//   could be given ANY value.
//   -----------------------------------------------------
//   The function will start the search from the StartPos value
//   given, if this value is less than the length of the string,
//   then it will ignore the characters after that position
//   (it behaves as override for the length of the string,
//   except when the StartPos value is greater than the length
//   of the string, the function will be failed anyway).
//

interface

function {TxSearch} CharPos(const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const BackPos: boolean = FALSE): integer; register overload

function {TxSearch} CharPos(const Ch: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE;
  const BackPos: boolean = FALSE): integer; register overload
// since the normal search (with or without case sesnsitivirty)
// is much more commonly used than the backspos search, we put
// the BackPos argument last

function {TxSearch} CharCount(const Ch: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE;
  const BackPos: boolean = FALSE): integer; register overload

function {TxSearch} CharCount(const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const BackPos: boolean = FALSE): integer; register overload

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// sometimes it is more useful to find a pair of chars
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// here WChar means a pair of Chars (double-chars)

function {TxSearch} WCharPos(const firstChar, secondChar: Char;
  const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload

function {TxSearch} WCharPos(const firstChar, secondChar: Char;
  const S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function {TxSearch} WCharPos(const CharsPair, S: string;
  const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload

function {TxSearch} WCharPos(const CharsPair, S: string;
  const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function {TxSearch} WCharCount(const firstChar, secondChar: Char;
  const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload

function {TxSearch} WCharCount(const firstChar, secondChar: Char;
  const S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function {TxSearch} WCharCount(const CharsPair, S: string;
  const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload

function {TxSearch} WCharCount(const CharsPair, S: string;
  const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload

function UpperStr(const S: string): string; //overload;
function LowerStr(const S: string): string; //overload;
//procedure UpperStr(var Buffer; const Length: integer); overload;
//procedure LowerStr(var Buffer; const Length: integer); overload;
procedure UpperBuff(var Buffer; const Length: integer);
procedure LowerBuff(var Buffer; const Length: integer);

// Dirty (and fast) version of upper/lowercase
function Uppercased(const S: string): string;
function Lowercased(const S: string): string;

function trimStr(const S: string): string; overload;
function trimStrL(const S: string): string; overload;
function trimStrR(const S: string): string; overload;

type
  TChPosCharset = set of Char; // equal with TSysCharset

function trimmed(const S: string; const Delimiter: char): string; overload;
function trimmed(const S: string; const Delimiters: TChPosCharset): string; overload;

function trimStr(const S: string; const Delimiters: TChPosCharset): string; overload;
function trimStrL(const S: string; const Delimiters: TChPosCharset): string; overload;
function trimStrR(const S: string; const Delimiters: TChPosCharset): string; overload;

function SameText(const S1, S2: string; const IgnoreCase: boolean = TRUE): boolean;
function SameBuffer(const P1, P2; const Length: integer; const IgnoreCase: boolean = TRUE): boolean; forward;
procedure xMove(const Src; var Dest; Count: integer); register assembler; forward

// used only for monotoned/repeated chars as 'cccc','xxxxxx'
// function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
//  const RepCount: integer; const IgnoreCase: boolean): integer;
function RepPos(const Ch: Char; const S: string; const RepCount: integer;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer;

function PRepPos(const Ch: Char; const P: PChar; const StartPos: cardinal;
  const PLength: cardinal; const RepCount: integer;
  const IgnoreCase: boolean): integer; register overload
function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
  const RepCount: integer; const IgnoreCase: boolean): integer;

// implementation samples
// returns position of N-th occurrence of specified char (same rule also for WordNth below)
function CharNth(const Index: integer; const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const BackPos: boolean = FALSE): integer; register overload
// Index is 1-based, 0 means error (either S is blank or StartPos is out-of-range)
// function CharAtIndex(const Index: integer; const Ch: Char; const S: string;
//   const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
//   const BackPos: boolean = FALSE): integer; register overload

function WordNth(const Index: integer; const S: string; const delimiter: Char; //= ' ';
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE; const BackPos: boolean = FALSE): string;
// Index is 1-based, 0 means error (either S is blank or StartPos is out-of-range)
// function WordAtIndex(const Index: integer; const S: string; const delimiter: Char = ' ';
//   const StartPos: integer = 1; const backpos: boolean = FALSE; const IgnoreCase: boolean = FALSE): string;

function fetchWord(const S: string; var StartPos: integer; const Delimiter: char): string; overload;
// get a word and update StartPos to the next word position (immediately AFTER delimiter position)

function WordCount(const S: string; const delimiter: Char {= ' '}; const StartPos: integer = 1;
  const BackPos: boolean = FALSE; const IgnoreCase: boolean = FALSE): integer; overload;
// actually it is not quite a word count, but count of substring with delimited by one
// particular char, used for array or list of known formatted string with specific delimiter
// such as CSV (comma separated Values) or tab/space separated values etc.
// no harm for other (non formatted, arbitrary text), just doesn't make sense
// maybe ignoreCase better be turned off since delimiter should be case-sensitive anyway
// (deprecated, now its simply equal with CharCount +1, except for an empty string which
// returns 0, we dont know whether this is appropriate, since an empty string still is
// containing a string, despite it is blank)
// Default Delimiter commented since it very easy to overlooked
// note: IgnoreCase applies to Delimiter NOT to word to be searched for

function WordIndexOf(const SubStr, S: string; const Delimiter: char;
  const LengthToBeCompared: integer = MaxInt; const ignoreCaseSubStr: boolean = TRUE;
  const StartPos: integer = 1; const BackPos: boolean = FALSE;
  const ignoreCaseDelimiter: boolean = FALSE): integer;
// note: IgnoreCaseSubStr applies to SubStr to be searched for
//       IgnoreCaseDelimiter applies to Delimiter

//function PosCRLF(const S: string; const StartPos: integer = 1): integer;
//function UNIXed(const CRLFText: string): string;
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// test...
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

type
  TCharIndexTable = packed array[char] of integer; // CXGlobal

// TCharIndexTable specifies the word/non-word character by zeroing at their ordinal position
// used for finding Class of chars.
// such as: elemen[SPACE] := 0 ~> if SPACE is not counted as a word's character
// initialization example:
// var
//   Ch:Char;
//   CharTable:TCharIndexTable;
// const
//   ALPHANUMERIC = ['0'..'9', 'A'..'Z', 'a'..'z'];
// ...
//   fillchar(CharsTable, sizeOf(CharsTable), 0);
//   for Ch := Low(Ch) to high(Ch) do
//     if Ch in ALPHANUMERIC then
//       CharsTable[Ch] := 1;
// ...

procedure InitIndexTable(var IndexTable: TCharIndexTable; const Charset: TChPosCharset);

function CharPos(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer; overload;
//function CharClassPos(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer;
function CharNthPos(const table: TCharIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload;
//function CharIndexPos(const table: TCharIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer; overload;
//function CharClassIndexPos(const table: TCharIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
function CharCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer; overload;
//function CharClassCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer;
function WordCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer; overload;
//function WordClassCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer;

// (we just realize that they are quite a useful functions; hence we add a character class extension for them)
// DelimitersClass table is complement of WordClass table, so we may call at our convenience
function fetchWord(const S: string; var StartPos: integer; const DelimitersClass: TCharIndexTable): string; overload;
function fetchWord(const S: string; const WordClass: TCharIndexTable; var StartPos: integer): string; overload;
//function CharClassfetchWord(const S: string; var StartPos: integer; const table: TCharIndexTable): string;

// pack words (replace all non-words-characters by single char/delimiter)
// consecutive non-word characters will produce a single delimiter only
function PackWords(const WordClass: TCharIndexTable; const S: string; const delimiter: char): string; overload;
function PackWordsUppercase(const WordClass: TCharIndexTable; const S: string; const delimiter: char): string; overload;

function PackWords(const WordClass: TChPosCharset; const S: string; const delimiter: char): string; overload;
function PackWordsUppercase(const WordClass: TChPosCharset; const S: string; const delimiter: char): string; overload;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// miscellaneous
// obsolete, use character class instead
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ControlCharPos(const S: string; const StartPos: integer = 1): integer;
function HiBitCharPos(const S: string; const StartPos: integer = 1): integer;
function HiBitCharCount(const S: string; const StartPos: integer = 1): integer;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Low level-routines. NOT overloaded anymore to avoid ambiguities
//  Naming convention:
//  a. Source
//     _ : string version
//     p : pChar version
//  b. Direction
//     (none) : normal/forward
//     b : backpos
//  c. Case option
//     c : case-sensitive
//     i : ignorecase (non-sensitive)
//
///finalized
function pcCharPos(const Ch: Char; const P: PChar; const StartPos,
  PLength: cardinal): integer register assembler; //overload forward
function piCharPos(const Ch: Char; const P: PChar; const StartPos,
  PLength: cardinal): integer register assembler; //overload forward
function pcWCharPos(const Word: Word; const P: PChar; const StartPos,
  PLength: cardinal): integer register assembler; //overload forward
function piWCharPos(const Word: Word; const P: PChar; const StartPos,
  PLength: cardinal): integer register assembler; //overload forward

{.$DEFINE DEBUG}// to make them globally accessible
{$IFDEF DEBUG}
function _cCharPos(const Ch: Char; const S: string;
  const StartPos: integer = 1): integer register assembler; //overload forward
function _iCharPos(const Ch: Char; const S: string;
  const StartPos: integer = 1): integer register assembler; //overload forward

function pbcCharPos(const Ch: Char; const P: PChar;
  const StartPos, PLength: cardinal): integer register assembler; //overload forward
function pbiCharPos(const Ch: Char; const P: PChar;
  const StartPos, PLength: cardinal): integer register assembler; //overload forward
function _bcCharPos(const Ch: Char; const S: string;
  const StartPos: integer = {0} 1): integer register assembler; //overload forward
function _biCharPos(const Ch: Char; const S: string;
  const StartPos: integer = 0): integer register assembler; //overload forward

function pcCharCount(const Ch: Char; const P: PChar;
  const StartPos, PLength: cardinal): integer register assembler; //overload forward
function piCharCount(const Ch: Char; const P: PChar;
  const StartPos, PLength: cardinal): integer register assembler; //overload forward
function _cCharCount(const Ch: Char; const S: string;
  const StartPos: integer = 1): integer register assembler; //overload forward
function _iCharCount(const Ch: Char; const S: string;
  const StartPos: integer = 1): integer register assembler; //overload forward

function _cCompare(const S1, S2: string): integer; //forward;
function _iCompare(const S1, S2: string): integer; //forward;

function pcCompare(const P1, P2; const L1, L2: integer): integer; //forward;
function piCompare(const P1, P2; const L1, L2: integer): integer; //forward;
///

// tryout: experimental-stage3 status:OK
// returns position of N-th occurrence of char
function _cCharIndexPos(const Ch: Char; const S: string;
  const StartPos: integer { = 1}; const Index: integer): integer;
function _iCharIndexPos(const Ch: Char; const S: string;
  const StartPos: integer { = 1}; const Index: integer): integer;

// tryout: experimental-stage2 status:OK
function _bcCharIndexPos(const Ch: Char; const S: string;
  const StartPos: integer { = 1}; const Index: integer): integer;
function _biCharIndexPos(const Ch: Char; const S: string;
  const StartPos: integer { = 1}; const Index: integer): integer;

// tryout: experimental-stage2 status:OK
function _bcCharCount(const Ch: Char; const S: string;
  const StartPos: integer = 1): integer register assembler; //overload forward
function _biCharCount(const Ch: Char; const S: string;
  const StartPos: integer = 1): integer register assembler; //overload forward

function _cWordPos(const Word: Word; const S: ANSIString;
  const StartPos: integer = 1): integer;
function _cWordCount(const Word: Word; const S: ANSIString;
  const StartPos: integer = 1): integer;
function _icWordPos(const Word: Word; const S: ANSIString;
  const StartPos: integer = 1): integer;
function _icWordCount(const Word: Word; const S: ANSIString;
  const StartPos: integer = 1): integer;

{$ENDIF DEBUG}
implementation
uses CXGlobal;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  ChPos ~ String version
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function _cCharPos_old(const Ch: Char; const S: string;
const StartPos: integer = 1): integer; assembler asm
  @@Start: push esi
    test S, S; jz @@zero // check S length
    mov esi, S.SzLen
    cmp StartPos, esi; jle @@begin
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push S
    sub StartPos, esi; add S, esi
  @_Loop:
    cmp al, byte ptr S[StartPos-1]; je @@found
    inc StartPos; jle @_Loop
  @@notfound: xor eax, eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos
  @@end: pop S
  @@Stop: pop esi
end;

function _cCharPos(const Ch: Char; const S: string;
const StartPos: integer = 1): integer; assembler asm
  // using simpler base-index should be faster
  // or at least pairing enabled
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; je @@found
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

function _iCharPos_old(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
  @@Start: push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: //movzx eax, &Ch
    //mov al, &Ch
    and eax, MAXBYTE
    push edi
    lea edi, locasetable
  @@begin: push esi; push S
    sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    mov al, byte ptr S[StartPos-1];
    cmp bl, edi[eax]; je @@found
    inc StartPos; jle @_Loop
    jmp @@notfound
  @_LoopNC:
    cmp al, byte ptr S[StartPos-1]; je @@found
    inc StartPos; jle @_LoopNC
  @@notfound: xor eax,eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos
  @@end: pop S; pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

function _iCharPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
  @@Start: push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: //movzx eax, &Ch
    //mov al, &Ch
    and eax, MAXBYTE
    push edi
    lea edi, locasetable
  @@begin: push esi; push S
    sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //mov al, byte ptr S[StartPos-1];
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@found
    inc StartPos; jle @_Loop
    jmp @@notfound
  @_LoopNC:
    //cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; lea esi, esi +1; je @@found
    inc StartPos; jle @_LoopNC
  @@notfound: xor eax,eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos
  @@end: pop S; pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

//BackPos

function _bcCharPos_old(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
  @@Start: push esi
    test S, S; jz @@zero // check S length
    mov esi, S.SzLen
    cmp StartPos, esi; jle @@begin
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push S
    sub StartPos, esi; add S, esi
  @_Loop:
    cmp al, byte ptr S[StartPos-1]; je @@found
    dec StartPos; jg @_Loop
    xor eax,eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos
  @@end: pop S
  @@Stop: pop esi
end;

function _bcCharPos(const Ch: Char; const S: string;
const StartPos: integer = {0} 1): integer; assembler asm
  // using simpler base-index should be faster
  // or at least pairing enabled
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin
  @@zero: xor eax, eax; ret //jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp al, [esi]; je @@found
    lea esi, esi -1; dec StartPos; jg @_Loop
  @@notfound: mov StartPos, 0
  @@found: mov eax, StartPos
  @@end: pop esi
  @@Stop:
end;

function _biCharPos_old(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
  @@Start: push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: //movzx eax, &Ch
    //mov al, &Ch
    and eax, MAXBYTE
    push edi
    lea edi, locasetable
  @@begin: push esi; push S
    sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    mov al, byte ptr S[StartPos-1];
    cmp bl, edi[eax]; je @@found
    lea esi, esi -1; dec StartPos; jg @_Loop
    jmp @@notfound
  @_LoopNC:
    cmp al, byte ptr S[StartPos-1]; je @@found
    lea esi, esi -1; dec StartPos; jg @_LoopNC
  @@notfound: xor eax,eax; jmp @@end
  @@found: sub S, [esp]; lea eax, S + StartPos
  @@end: pop S; pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

function _biCharPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
  @@Start: push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero
    mov ebx, S.szLen
    cmp StartPos, ebx; jle @@Open
  @@zero: xor eax, eax; jmp @@Stop
  @@Open: //movzx eax, &Ch
    //mov al, &Ch
    and eax, MAXBYTE
    push edi
    lea edi, locasetable
  @@begin: push esi//old:; push S
    //old: sub StartPos, ebx; add S, ebx
    lea esi, S + StartPos -1
    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //old: mov al, byte ptr S[StartPos-1];
    mov al, [esi]; cmp bl, edi[eax]; je @@found
    lea esi, esi -1; dec StartPos; jg @_Loop
    jmp @@notfound
  @_LoopNC:
    //old: cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; je @@found;
    lea esi, esi -1; dec StartPos; jg @_LoopNC
  @@notfound: xor eax,eax; jmp @@end
  @@found: mov eax, StartPos//old: sub S, [esp]; lea eax, S + StartPos
  @@end: {old: pop S; }pop esi
  @@Close: pop edi
  @@Stop: pop ebx
end;

function _cCharCount(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jne @_
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@EXIT:
end;

function _iCharCount(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax
      jne @_; inc S
    @_:inc StartPos; jle @_Loop; jmp @@done
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1; jne @e
      ; inc S
    @e: inc StartPos; jle @_LoopNC
    @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function _bcCharCount(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@Start
  @@zero:  xor eax, eax; jmp @@EXIT
  @@Start: push esi
    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S,0; jg @@found
    cmp StartPos, S.SzLen; mov S, 0; jg @@done
    @_Loop:
      cmp al, [esi]; lea esi, esi -1; jne @_
      ; inc S
    @_: dec StartPos; jg @_Loop
  @@done: mov eax, S
  @@Stop: pop esi
  @@EXIT:
end;

function _biCharCount(const Ch: Char; const S: string;
const StartPos: integer { = 1}): integer; assembler asm
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, S + StartPos -1
    //sub StartPos, S.SzLen; mov S, 0; jg @_found
    cmp StartPos, S.SzLen; mov S, 0; jg @@done
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi -1
      cmp bl, edi + eax; jne @_
      ; inc S
    @_:dec StartPos; jg @_Loop; jmp @@done
    @_LoopNC:
      cmp al, [esi]; lea esi, esi -1; jne @e
      ; inc S
    @e: dec StartPos; jg @_LoopNC
    @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function _cCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; jne @_//je @@found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop
  @@notfound: mov esi, [esp]
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop esi
  @@Stop:
end;

function _iCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: //push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
  @@warning_esi_pushed: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.szLen; jle @@begin
  @@Warning_esi_poped: pop esi // orphaned pop
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: //movzx eax, &Ch
    {old: push esi;} push edi; push S
    lea edi, locasetable
    //mov al, &Ch
    and eax, MAXBYTE
    mov S, Index; dec S; jl @@notfound

    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //old: mov al, byte ptr S[StartPos-1];
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; jne @_//je @@found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop; jmp @@notfound
  @_LoopNC:
    //old: cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; lea esi, esi +1; jne @e//je @@found
    dec S; jl @@found
  @e:inc StartPos; jle @_LoopNC
  @@notfound: mov [esp], esi
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop edi; pop esi
  @@Stop: //pop ebx
end;

function _bcCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push S
    lea esi, S + StartPos -1
    //alt: sub StartPos, S.SzLen; jg @@notfound
    cmp StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
  @_Loop:
    cmp al, [esi]; jne @_//je @@found
    dec S; jl @@found
  @_:dec StartPos; lea esi, esi -1; jg @_Loop
  @@notfound: mov esi, [esp]; dec esi
  @@found: sub esi, [esp]; lea eax, esi +1
  @@end: pop S; pop esi
  @@Stop:
end;

function _biCharIndexPos(const Ch: Char; const S: string;
const StartPos: integer { = 1}; const Index: integer): integer; assembler asm
  @@Start: //push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jle @@zero // still need to be checked
  @@warning_esi_pushed: push esi
    lea esi, S + StartPos -1
    //sub StartPos, S.szLen; jle @@begin
    cmp StartPos, S.szLen; jle @@begin
  @@Warning_esi_poped: pop esi // orphaned pop
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: //movzx eax, &Ch
    {old: push esi;} push edi; push S
    lea edi, locasetable
    //mov al, &Ch
    and eax, MAXBYTE
    mov S, Index; dec S; jl @@notfound

    mov al, edi[eax]
    cmp al, byte ptr UPCASETABLE[eax]; je @_LoopNC
    mov bl, al
  @_Loop:
    //old: mov al, byte ptr S[StartPos-1];
    mov al, [esi]; cmp bl, edi[eax]; jne @_//je @@found
    dec S; jl @@found;
    @_:dec StartPos; ; lea esi, esi -1;jg @_Loop; jmp @@notfound
  @_LoopNC:
    //old: cmp al, byte ptr S[StartPos-1]; je @@found
    cmp al, [esi]; jne @e//je @@found
    dec S; jl @@found
    @e:dec StartPos; lea esi, esi -1; jg @_LoopNC
  @@notfound: mov esi, [esp]; dec esi
  @@found: sub esi, [esp]; lea eax, esi +1
  @@end: pop S; pop edi; pop esi
  @@Stop: //pop ebx
end;

function _RepPos(const Ch: Char; const S: string; const StartPos: integer;
const RepCount: integer; const IgnoreCase: boolean): integer; assembler asm
  @@Start: push esi
    or S, S; je @@zero
    test StartPos, StartPos; jle @@zero
    cmp StartPos, S.szLen; jle @begin
  @@zero: xor eax, eax; jmp @@Stop
  @begin: push esi; push edi; push ebx
    mov esi, S
    push esi            // save original address
    // mov al, &Ch
    and eax, MAXBYTE
    mov edi, esi
    lea esi, esi + StartPos -1
    add edi, edi.szLen
    mov ecx, RepCount
    dec ecx
    mov edx, ecx; sub edi, ecx
    test IgnoreCase, 1; jnz @@CaseInsensitive

    @@CaseSensitive:
    @_Repeat:
      cmp esi, edi; jg @@notfound  // note!
      cmp al, esi[edx]; jne @_skip
    @_Loop:
      dec ecx; jl @@found
      cmp al, esi[ecx]; je @_Loop
    @_forward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_Repeat
    @_skip:
      lea esi, esi + edx +1; jmp @_Repeat

    @@CaseInsensitive:
      xor ebx, ebx
      mov bl, byte ptr locasetable[eax]
      cmp bl, byte ptr UPCASETABLE[eax]
      je @@CaseSensitive

    @_iRepeat:
      cmp esi, edi; jg @@notfound
      mov al, esi[edx]
      cmp bl, byte ptr locasetable[eax]; jne @_iSkip
    @_iLoop:
      dec ecx; jl @@found
      mov al, esi[ecx]
      cmp bl, byte ptr locasetable[eax]; je @_iLoop
    @_iForward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_iRepeat
    @_iSkip:
      lea esi, esi + edx +1; jmp @_iRepeat

  @@notfound: lea eax, esi +1; mov [esp], eax
  @@found: pop edi; sub esi, edi; lea eax, esi +1
  @@end: pop ebx; pop edi; pop esi
  @@Stop: pop esi
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// implementation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function {txSearch} CharPos(const Ch: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE;
  const BackPos: boolean = FALSE): integer;
begin
  if not BackPos then
    if IgnoreCase then
      Result := _iCharPos(Ch, S, StartPos)
    else
      Result := _cCharPos(Ch, S, StartPos)
  else if IgnoreCase then
    Result := _biCharPos(Ch, S, StartPos)
  else
    Result := _bcCharPos(Ch, S, StartPos)
end;

function {txSearch} CharPos(const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const BackPos: boolean = FALSE): integer;
begin
  Result := CharPos(Ch, S, StartPos, IgnoreCase, BackPos)
end;

function {txSearch} RepPos(const Ch: Char; const S: string; const RepCount: integer;
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE): integer;
begin
  if RepCount < 2 then
    Result := CharPos(Ch, S, StartPos, IgnoreCase)
  else
    Result := _RepPos(Ch, S, StartPos, RepCount, IgnoreCase);
end;

function {txSearch} CharCount(const Ch: Char; const S: string;
  const StartPos: integer; const IgnoreCase: boolean = FALSE;
  const BackPos: boolean = FALSE): integer;
begin
  if BackPos then
    if IgnoreCase then
      Result := _biCharCount(Ch, S, StartPos)
    else
      Result := _bcCharCount(Ch, S, StartPos)
  else if IgnoreCase then
    Result := _iCharCount(Ch, S, StartPos)
  else
    Result := _cCharCount(Ch, S, StartPos)
end;

function {txSearch} CharCount(const Ch: Char; const S: string;
  const IgnoreCase: boolean = FALSE; const StartPos: integer = 1;
  const BackPos: boolean = FALSE): integer;
begin
  Result := CharCount(Ch, S, StartPos, IgnoreCase, BackPos)
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  expos ~ PChar version
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function pcCharPos_old(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm //untested!
  @@Start: push esi
    test P, P; jz @@notfound
    // additional test for integer:
    // test StartPos, StartPos; jle @@zero
    mov esi, PLength
    cmp StartPos, esi; jbe @@begin // jle for integer
    xor eax, eax; jmp @@Stop
  @@begin:
    sub StartPos, esi; add esi, P
    @Loop:
      cmp al, byte ptr esi[StartPos -1]; je @@found
      inc StartPos; jnz @Loop
      //last-char to be checked
      inc StartPos; cmp al, byte ptr esi[StartPos -1]; je @@found
  @@notfound: xor eax, eax; jmp @@end
  @@found: sub esi, P; lea eax, esi + StartPos
  @@end:
  @@Stop: pop esi
end;

function pcCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  // using simpler base-index should be faster
  // or at least pairing enabled
  @@begin: push esi
    lea esi, P + StartPos -1
    sub StartPos, PLength; ja @@notfound // jg for integer?
  @_Loop:
    cmp al, [esi]; lea esi, esi +1; je @@found
    inc StartPos; jle @_Loop
  @@notfound: xor eax, eax; jmp @@end
  @@found: mov eax, esi; sub eax, P
  @@end: pop esi
end;

function piCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, P + StartPos -1
    sub StartPos, PLength; ja @_notfound // jg for integer?
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax; je @@found
      inc StartPos; jle @_Loop
      jmp @_notfound
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1; je @@found
      inc StartPos; jle @_LoopNC
    @_notfound: xor eax, eax; jmp @@end
  @@found: mov eax, esi; sub eax, P
  @@end: pop ebx; pop edi; pop esi
end;

function pbcCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi
    and eax, MAXBYTE
    lea esi, P + StartPos -1
    cmp StartPos, PLength; ja @_notfound // jg for integer
    @_Loop:
      cmp al, [esi]; lea esi, esi -1; je @@found
      sub StartPos, 1; jnb @_Loop
    @_notfound: xor eax, eax; jmp @@end
  @@found: lea eax, StartPos +1//mov eax, esi; sub eax, P
  @@end: pop esi
end;

function pbiCharPos(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, P + StartPos -1
    cmp StartPos, PLength; ja @_notfound // jg for integer
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax; je @@found
      sub StartPos, 1; jnb @_Loop
      jmp @_notfound
    @_LoopNC:
      cmp al, [esi]; lea esi, esi -1; je @@found
      sub StartPos, 1; jnb @_LoopNC
    @_notfound: xor eax, eax; jmp @@end
  @@found: lea eax, StartPos +1//mov eax, esi; sub eax, P
  @@end: pop ebx; pop edi; pop esi
end;

function pcCharCount(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi
    lea esi, P + StartPos -1
    xor P, P
    sub StartPos, PLength; ja @@found//jg @@found
    @_Loop:
      cmp al, [esi]; lea esi, esi +1; jne @_
      ; lea P, P+1
    @_: inc StartPos; jle @_Loop
  @@found: mov eax, P
  @@end: pop esi
end;

function piCharCount(const Ch: Char; const P: PChar;
const StartPos, PLength: cardinal): integer; assembler asm
  @@begin: push esi; push edi; push ebx
    and eax, MAXBYTE
    lea edi, locasetable
    lea esi, P + StartPos -1
    xor P, P
    sub StartPos, PLength; ja @_found//jg @_found
    mov bl, edi + eax
    cmp bl, byte ptr UPCASETABLE[eax]; je @_LoopNC
    @_Loop:
      mov al, [esi]; lea esi, esi +1
      cmp bl, edi + eax; jne @_
      ; lea P, P +1
      @_:inc StartPos; jle @_Loop; jmp @_found
    @_LoopNC:
      cmp al, [esi]; lea esi, esi +1
      jne @e; lea P, P+1
      @e: inc StartPos; jle @_LoopNC
    @_found: mov eax, P
  @@end: pop ebx; pop edi; pop esi
end;

function PRepPos(const Ch: Char; const P: PChar; const StartPos: cardinal;
  const PLength: cardinal; const RepCount: integer;
const IgnoreCase: boolean): integer; register overload assembler asm
  @@Start:
    or P, P; je @@zero
    test StartPos, StartPos; jle @@zero  // StartPos = 0?
    cmp StartPos, PLength; jle @begin    // StartPos >= Length(S) ?

  @@zero: xor eax, eax; jmp @@Stop
  @begin: push esi; push edi; push ebx
    mov esi, P
    push esi            // save original address
    //mov al, &Ch
    and eax, MAXBYTE
    mov edi, esi
    lea esi, esi + StartPos -1
    add edi, PLength
    mov ecx, RepCount
    dec ecx
    mov edx, ecx; sub edi, ecx
    test IgnoreCase, 1; jnz @@CaseInsensitive

    @@CaseSensitive:
    @_Repeat:
      cmp esi, edi; jg @@notfound  // note!
      cmp al, esi[edx]; jne @_skip
    @_Loop:
      dec ecx; jl @@found
      cmp al, esi[ecx]; je @_Loop
    @_forward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_Repeat
    @_skip:
      lea esi, esi + edx +1; jmp @_Repeat

    @@CaseInsensitive:
      xor ebx, ebx
      mov bl, byte ptr locasetable[eax]
      cmp bl, byte ptr UPCASETABLE[eax]
      je @@CaseSensitive

    @_iRepeat:
      cmp esi, edi; jg @@notfound
      mov al, esi[edx]
      cmp bl, byte ptr locasetable[eax]; jne @_iSkip
    @_iLoop:
      dec ecx; jl @@found
      mov al, esi[ecx]
      cmp bl, byte ptr locasetable[eax]; je @_iLoop
    @_iForward:
      lea esi, esi + ecx +1; mov ecx, edx
      jmp @_iRepeat
    @_iSkip:
      lea esi, esi + edx +1; jmp @_iRepeat

  @@notfound: lea eax, esi +1; mov [esp], eax
  @@found: pop edi; sub esi, edi; lea eax, esi +1
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Chars Pair / Double Chars routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//function _cWordPos_old2(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start:
//    test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; je @@found; lea esi, esi +1
//    add StartPos, 2; jl @_Loop
//  @@notfound: mov esi, S
//  @@found: sub esi, S; mov eax, esi
//  @@end: pop esi
//  @@Stop:
//end;

//function _cWordCount_old2(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start:
//    test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; mov S, 0; jge @@done
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@done
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; jne @@_
//    ; inc S
//    @@_:add StartPos, 2; jl @_Loop
//  @@done: mov eax, S
//  @@end: pop esi
//  @@Stop:
//end;

//function _cWordPosbug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start:
//    test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; je @@found
//    add StartPos, 2; jl @_Loop
//  @@notfound: mov esi, S; inc esi
//  @@found: sub esi, S; lea eax, esi -1
//  @@end: pop esi
//  @@Stop:
//end;

function _cWordPos(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jge @@notfound
  @_Loop: // better play safe here
    cmp al, [esi]; lea esi, esi +1; je @@found1
    inc StartPos; jl @_Loop; jmp @@notfound
  @@found1:
    cmp ah, [esi]; je @@found
    inc StartPos; jl @_Loop
  @@notfound: mov esi, S;// inc esi
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//function _cWordCount_bug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start:
//    test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    lea esi, S + StartPos -1
//    sub StartPos, S.SzLen; mov S, 0; jge @@done
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@done
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; jne @@_
//    ; inc S
//    @@_:add StartPos, 2; jl @_Loop
//  @@done: mov eax, S
//  @@end: pop esi
//  @@Stop:
//end;

function _cWordCount(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jge @@done
  @_Loop: // better play safe here
    cmp al, [esi]; lea esi, esi +1; je @@found1
    inc StartPos; jl @_Loop; jmp @@done
  @@found1:
    cmp ah, [esi]; jne @@_
    ; inc S
    @@_:inc StartPos; jl @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@Stop:
end;

//function _icWordPos_bug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: push ebx
//    test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push edi; push esi
//  lea esi, S + StartPos -1
//  sub StartPos, S.SzLen; jge @@notfound
//    lea edi, locasetable
//    xor ebx, ebx
//    mov bl, ah
//    mov bh, edi[ebx]
//    and eax, MAXBYTE
//    mov bl, edi[eax]
//  @@test1:
//    cmp bl, eax[UPCASETABLE]; jne @@_LoopCC
//  @@test2:
//    mov al, bh
//    cmp bh, eax[UPCASETABLE]; jne @@_LoopCC
//    mov eax, ebx
//  @@_LoopNC:
//    cmp al, [esi]; lea esi, esi +1; je @@foundNC
//    inc StartPos; jl @@_LoopNC; jmp @@notfound
//  @@foundNC:
//    cmp ah, [esi]; lea esi, esi +1; je @@found;
//    add StartPos, 2; jl @@_LoopNC; jmp @@notfound
//  @@_LoopCC: // better play safe here
//    mov al, [esi]; lea esi, esi +1
//    cmp bl, edi[eax]; je @@foundCC;
//    inc StartPos; jl @@_LoopCC; jmp @@notfound
//  @@foundCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bh, edi[eax]; je @@found;
//    add StartPos, 2; jl @@_LoopCC
//  @@notfound: mov esi, S; inc esi
//  @@found: sub esi, S; lea eax, esi-1
//  @@end: pop esi; pop edi
//  @@Stop: pop ebx
//end;

function _icWordPos(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start: push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push edi; push esi
  lea esi, S + StartPos -1
  sub StartPos, S.SzLen; jge @@notfound
    lea edi, locasetable
    xor ebx, ebx
    mov bl, ah
    mov bh, edi[ebx]
    and eax, MAXBYTE
    mov bl, edi[eax]
  @@test1:
    cmp bl, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
  @@test2:
    mov al, bh
    cmp bh, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
    mov eax, ebx
  @@_LoopNC:
    cmp al, [esi]; lea esi, esi +1; je @@foundNC
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@foundNC:
    cmp ah, [esi]; je @@found;
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@_LoopCC: // better play safe here
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@foundCC;
    inc StartPos; jl @@_LoopCC; jmp @@notfound
  @@foundCC:
    mov al, [esi];
    cmp bh, edi[eax]; je @@found;
    inc StartPos; jl @@_LoopCC
  @@notfound: mov esi, S; //inc esi //botch! :(
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi; pop edi
  @@Stop: pop ebx
end;

//function _icWordCount_bug1(const Word: Word; const S: ANSIString;
//const StartPos: integer = 1): integer; assembler asm
//  @@Start: push ebx
//    test S, S; jz @@zero // check S length
//    or StartPos, StartPos; jg @@begin //still need to be checked
//  @@zero: xor eax, eax; jmp @@Stop
//  @@begin: push edi; push esi
//  lea esi, S + StartPos -1
//  sub StartPos, S.SzLen; mov S, 0; jge @@done
//    lea edi, locasetable
//    xor ebx, ebx
//    mov bl, ah
//    mov bh, edi[ebx]
//    and eax, MAXBYTE
//    mov bl, edi[eax]
//  @@test1:
//    cmp bl, eax[UPCASETABLE]; jne @@_LoopCC
//  @@test2:
//    mov al, bh
//    cmp bh, eax[UPCASETABLE]; jne @@_LoopCC
//    mov eax, ebx
//  @@_LoopNC:
//    cmp al, [esi]; lea esi, esi +1; je @@foundNC
//    inc StartPos; jl @@_LoopNC; jmp @@done
//  @@foundNC:
//    cmp ah, [esi]; lea esi, esi +1; jne @@_NC; inc S
//  @@_NC:add StartPos, 2; jl @@_LoopNC; jmp @@done
//  @@_LoopCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bl, edi[eax]; je @@foundCC
//    inc StartPos; jl @@_LoopCC; jmp @@done
//  @@foundCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bh, edi[eax]; jne @@_CC; inc S
//    @@_CC:add StartPos, 2; jl @@_LoopCC
//  //@@notfound: mov esi, S
//  //@@found: sub esi, S; mov eax, esi
//  @@done: mov eax, S
//  @@end: pop esi; pop edi
//  @@Stop: pop ebx
//end;

function _icWordCount(const Word: Word; const S: ANSIString;
const StartPos: integer = 1): integer; assembler asm
  @@Start: push ebx
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push edi; push esi
  lea esi, S + StartPos -1
  sub StartPos, S.SzLen; mov S, 0; jge @@done
    lea edi, locasetable
    xor ebx, ebx
    mov bl, ah
    mov bh, edi[ebx]
    and eax, MAXBYTE
    mov bl, edi[eax]
  @@test1:
    cmp bl, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
  @@test2:
    mov al, bh
    cmp bh, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
    mov eax, ebx
  @@_LoopNC:
    cmp al, [esi]; lea esi, esi +1; je @@foundNC
    inc StartPos; jl @@_LoopNC; jmp @@done
  @@foundNC: cmp ah, [esi]; jne @@_NC; inc S
  @@_NC:inc StartPos; jl @@_LoopNC; jmp @@done
  @@_LoopCC:
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@foundCC
    inc StartPos; jl @@_LoopCC; jmp @@done
  @@foundCC:
    mov al, [esi];
    cmp bh, edi[eax]; jne @@_CC; inc S
    @@_CC:inc StartPos; jl @@_LoopCC
  //@@notfound: mov esi, S
  //@@found: sub esi, S; mov eax, esi
  @@done: mov eax, S
  @@end: pop esi; pop edi
  @@Stop: pop ebx
end;

// doublebyte

//function pcWCharPos_bug1(const Word: Word; const P: PChar; const StartPos,
//PLength: cardinal): integer register; assembler asm //overload forward
//  //@@Start:
//  //  test S, S; jz @@zero // check S length
//  //  or StartPos, StartPos; jg @@begin //still need to be checked
//  //@@zero: xor eax, eax; jmp @@Stop
//  @@begin: push esi
//    and eax, MAXWORD
//    lea esi, P + StartPos -1
//    sub StartPos, PLength; jge @@notfound
//  @_Loop: // better play safe here
//    cmp al, [esi]; lea esi, esi +1; je @@found1
//    inc StartPos; jl @_Loop; jmp @@notfound
//  @@found1:
//    cmp ah, [esi]; lea esi, esi +1; je @@found
//    add StartPos, 2; jl @_Loop
//  @@notfound: xor eax, eax; jmp @@end//mov esi, S; inc esi
//  @@found: sub esi, P; lea eax, esi -1
//  @@end: pop esi
//  @@Stop:
//end;

function pcWCharPos(const Word: Word; const P: PChar; const StartPos,
PLength: cardinal): integer register; assembler asm //overload forward
  @@Start:
    test P, P; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, P + StartPos -1
    sub StartPos, PLength; jge @@notfound
  @_Loop: // better play safe here
    cmp al, [esi]; lea esi, esi +1; je @@found1
    inc StartPos; jl @_Loop; jmp @@notfound
  @@found1:
    cmp ah, [esi]; je @@found
    inc StartPos; jl @_Loop
  @@notfound: xor eax, eax; jmp @@end
  @@found: sub esi, P; mov eax, esi
  @@end: pop esi
  @@Stop:
end;

//function piWCharPos_bug1(const Word: Word; const P: PChar; const StartPos,
//PLength: cardinal): integer register; assembler asm //overload forward
//  @@begin: push ebx; push edi; push esi
//  lea esi, P + StartPos -1
//  sub StartPos, PLength; jge @@notfound
//    lea edi, locasetable
//    xor ebx, ebx
//    mov bl, ah
//    mov bh, edi[ebx]
//    and eax, MAXBYTE
//    mov bl, edi[eax]
//  @@test1:
//    cmp bl, eax[UPCASETABLE]; jne @@_LoopCC
//  @@test2:
//    mov al, bh
//    cmp bh, eax[UPCASETABLE]; jne @@_LoopCC
//    mov eax, ebx
//  @@_LoopNC:
//    cmp al, [esi]; lea esi, esi +1; je @@foundNC
//    inc StartPos; jl @@_LoopNC; jmp @@notfound
//  @@foundNC:
//    cmp ah, [esi]; lea esi, esi +1; je @@found;
//    add StartPos, 2; jl @@_LoopNC; jmp @@notfound
//  @@_LoopCC: // better play safe here
//    mov al, [esi]; lea esi, esi +1
//    cmp bl, edi[eax]; je @@foundCC;
//    inc StartPos; jl @@_LoopCC; jmp @@notfound
//  @@foundCC:
//    mov al, [esi]; lea esi, esi +1
//    cmp bh, edi[eax]; je @@found;
//    add StartPos, 2; jl @@_LoopCC
//  @@notfound: mov esi, P; inc esi
//  @@found: sub esi, P; lea eax, esi-1
//  @@end: pop esi; pop edi; pop ebx
//end;

function piWCharPos(const Word: Word; const P: PChar; const StartPos,
PLength: cardinal): integer register; assembler asm //overload forward
  @@begin: push ebx; push edi; push esi
  lea esi, P + StartPos -1
  sub StartPos, PLength; jge @@notfound
    lea edi, locasetable
    xor ebx, ebx
    mov bl, ah
    mov bh, edi[ebx]
    and eax, MAXBYTE
    mov bl, edi[eax]
  @@test1:
    cmp bl, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
  @@test2:
    mov al, bh
    cmp bh, byte ptr eax[UPCASETABLE]; jne @@_LoopCC
    mov eax, ebx
  @@_LoopNC:
    cmp al, [esi]; lea esi, esi +1; je @@foundNC
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@foundNC:
    cmp ah, [esi]; je @@found
    inc StartPos; jl @@_LoopNC; jmp @@notfound
  @@_LoopCC: // better play safe here
    mov al, [esi]; lea esi, esi +1
    cmp bl, edi[eax]; je @@foundCC;
    inc StartPos; jl @@_LoopCC; jmp @@notfound
  @@foundCC:
    mov al, [esi];
    cmp bh, edi[eax]; je @@found;
    inc StartPos; jl @@_LoopCC
  @@notfound: mov esi, P; //inc esi //booogie! :(((
  @@found: sub esi, P; mov eax, esi
  @@end: pop esi; pop edi; pop ebx
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  move, compare & conversion routines
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure xMove(const Src; var Dest; Count: integer); assembler asm
// effective only for bulk transfer
// moving 4 bytes at the speed of 1,
// pairing enabled, no AGI-stalls
    push esi; push edi
    mov esi, Src; mov edi, Dest
    mov ecx, Count; mov eax, ecx
    sar ecx, 2; js @@end
    push eax; jz @@recall
  @@LoopDWord:
    mov eax, [esi]; lea esi, esi +4
    mov [edi], eax; lea edi, edi +4
    dec ecx; jg @@LoopDWord
  @@recall: pop ecx
    and ecx, 03h; jz @@LoopDone
  @@LoopByte:
    mov al, [esi]; lea esi, esi +1
    mov [edi], al; lea edi, edi +1
    dec ecx; jg @@LoopByte
  @@LoopDone:
  @@end:
    pop edi; pop esi
end;

function iCompare_old(const S1, S2: string): integer; assembler asm
  @@Start:
    push esi; push edi; push ebx
    mov esi, eax; mov edi, edx
    xor ebx, ebx
    or eax, eax; je @@zeroS1
    mov eax, eax.SzLen
  @@zeroS1:
    or edx, edx; je @@zeroS2
    mov edx, edx.SzLen
  @@zeroS2:
    mov ecx, eax
    cmp ecx, edx; jbe @@2
    mov ecx, edx
  @@2: dec ecx; jl @@done
  @@3:
    mov bl, [esi]; lea esi, esi +1
    cmp bl, [edi]; lea edi, edi +1
    je @@2
    mov bl, byte ptr LOCASETABLE[ebx]
    cmp bl, [edi -1]; je @@3
    xor eax, eax; mov al, [esi-1]
    xor edx, edx; mov dl, [edi-1]
  @@done:
    sub eax, edx
    pop ebx; pop edi; pop esi
  @@Stop:
end;

function _cCompare(const S1, S2: string): integer; assembler asm //
// efficient for long string
  @@Start:
    push esi; push edi; push ebx
    mov esi, S1; mov edi, S2

    test S1, S1; jz @_DoneAXLen; mov eax, S1.SzLen; @_DoneAXLen:
    test S2, S2; jz @_DoneDXLen; mov edx, S2.SzLen; @_DoneDXLen:

    mov ecx, eax; cmp ecx, edx; jbe @_prep
    mov ecx, edx

  @_prep: push ecx; shr ecx, 2; jz @_single

  @_Loop4: dec ecx; jl @_single
    mov ebx, [edi]; lea edi, edi +4
    cmp ebx, [esi]; lea esi, esi +4
    je @_Loop4

    //mov eax, [esi]; mov edx, ebx; jmp @_atremain //bug!
    mov eax, [esi-4]; mov edx, ebx; jmp @_atremain //fixed

  @_Loopremain: ror eax, 8; ror edx, 8
  @_atremain: cmp al, dl; je @_Loopremain
  @_remdone:
    and eax, $ff; and edx, $ff
    pop ecx; jmp @@done

  @_single: pop ecx; and ecx, 3; jz @@done

  @_Loop1: dec ecx; jl @@done
    mov bl, [esi]; lea esi, esi +1
    cmp bl, [edi]; lea edi, edi +1
    je @_Loop1

    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed

  @@done:
    sub eax, edx
    pop ebx; pop edi; pop esi
  @@Stop:
end;

function _iCompare(const S1, S2: string): integer; assembler asm //
  //call System.@LStrCmp
  @@Start:
    push esi; push edi; push ebx; push ebp
    mov esi, S1; mov edi, S2
    xor ebx, ebx; test S1, S1; je @_Zero1

    mov eax, S1.SzLen
  @_Zero1: test edx, edx; je @_Zero2
    mov edx, S2.SzLen
  //@_Zero2: mov ecx, eax; cmp ecx, edx; jbe @@2
  //  mov ecx, edx
  //@@2: dec ecx; jl @@done
  @_Zero2: mov ecx, 0;
    mov ebp, eax; cmp ebp, edx; jbe @@2
    mov ebp, edx
  @@2: dec ebp; jl @@done
  @Loop3:
    mov bl, [esi]; mov cl, [edi];
    lea esi, esi +1; lea edi, edi +1
    mov bl, byte ptr locasetable[ebx]
    mov cl, byte ptr locasetable[ecx]
    cmp bl, cl; je @@2  //fixed
    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed
    @@done:
    sub eax, edx
    pop ebp; pop ebx; pop edi; pop esi
  @@Stop:
end;

function pcCompare(const P1, P2; const L1, L2: integer): integer; assembler asm //
// efficient for large buffer
  @@Start:
    push esi; push edi; push ebx
    mov esi, P1; mov edi, P2

    test P1, P1; je @_doneAX; mov eax, L1//eax.SzLen
  @_doneAX:
    test P2, P2; je @_doneDX; mov edx, L2//edx.SzLen
  @_doneDX:
    mov ecx, eax; cmp ecx, edx; jbe @_prep

    mov ecx, edx
  @_prep: push ecx; shr ecx, 2; jz @_single

  @_Loop4: dec ecx; jl @_single
    mov ebx, [edi]; lea edi, edi +4
    cmp ebx, [esi]; lea esi, esi +4
    je @_Loop4

    //mov eax, [esi]; mov edx, ebx; jmp @_atremain //bug!
    mov eax, [esi-4]; mov edx, ebx; jmp @_atremain //fixed

  @_Loopremain: ror eax, 8; ror edx, 8
  @_atremain: cmp al, dl; je @_Loopremain

    and eax, $ff; and edx, $ff
    pop ecx; jmp @@done

  @_single: pop ecx; and ecx, 3; jz @@done

  @_Loop1: dec ecx; jl @@done
    mov bl, [esi]; lea esi, esi +1
    cmp bl, [edi]; lea edi, edi +1
    je @_Loop1

    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed

  @@done:
    sub eax, edx
    pop ebx; pop edi; pop esi
  @@Stop:
end;

function piCompare(const P1, P2; const L1, L2: integer): integer; assembler asm //
  @@Start:
    push esi; push edi; push ebx; push ebp
    mov esi, P1; mov edi, P2
    xor ebx, ebx; test eax, eax; je @_Zero1
    mov eax, L1//eax.SzLen
  @_Zero1: test P2, P2; je @_Zero2
    mov edx, L2//edx.SzLen
  //@_Zero2: mov ecx, eax; cmp ecx, edx; jbe @@2
  //  mov ecx, edx
  //@@2: dec ecx; jl @@done
  @_Zero2: mov ecx, 0;
    mov ebp, eax; cmp ebp, edx; jbe @@2
    mov ebp, edx
  @@2: dec ebp; jl @@done
  @Loop3:
    mov bl, [esi]; mov cl, [edi];
    lea esi, esi +1; lea edi, edi +1
    mov bl, byte ptr locasetable[ebx]
    mov cl, byte ptr locasetable[ecx]
    cmp bl, cl; je @@2  //fixed
    xor eax, eax; mov al, bl
    //xor edx, edx; mov dl, [edi] //bug!
    xor edx, edx; mov dl, [edi-1] //fixed
  @@done:
    sub eax, edx
    pop ebp; pop ebx; pop edi; pop esi
  @@Stop:
end;

procedure CaseStr(var S: string; const CharsTable); assembler asm
  @@Start:
    mov S, [S] // S is a VAR! normalize.
    or S, S; jz @@Stop
    push esi; push edi
    push ecx
    mov esi, S
    mov edi, CharsTable
    mov ecx, esi.SzLen
    xor eax, eax
  @@Loop:
    dec ecx; jl @@end
    mov al, esi[ecx]
    cmp al, edi[eax]
    je @@Loop
    mov al, edi[eax]
    mov esi[ecx], al
    jmp @@Loop
  @@end:
    pop ecx
    pop edi; pop esi
  @@Stop:
end;

procedure transBuffer(var Buffer; const Length: integer; const CharsTable); assembler asm
  @@Start:
    mov Buffer, [Buffer] // Buffer is a VAR! normalize.
    or Buffer, Buffer; jz @@Stop
    push esi; push edi
    push ecx
    mov esi, Buffer
    mov edi, CharsTable
    mov ecx, Length//esi.SzLen
    xor eax, eax
  @@Loop:
    dec ecx; jl @@end
    mov al, esi[ecx]
    cmp al, edi[eax]
    je @@Loop
    mov al, edi[eax]
    mov esi[ecx], al
    jmp @@Loop
  @@end:
    pop ecx
    pop edi; pop esi
  @@Stop:
end;

function Uppercased(const S: string): string; assembler asm
// Result = EDX
  test eax, eax; jz @@end
  push esi; push edi
    mov esi, S

    mov eax, Result               // where the result will be stored
    call System.@LStrClr          // cleared for ease
    mov edx, esi.szLen            // how much length of str requested
    call System.@LStrSetLength    // result: new allocation pointer in EAX
    mov edi, [eax]                // eax contains the new allocated pointer
                                  // we got the storage as well at once
    mov edx, 'az'                 // DX=$617A -> DH=$61, DL=$7A
    mov ecx, esi.szLen
    dec ecx                       // 0-wise
    @@Loop:
      mov al, esi+ecx
      cmp al, dl; ja @@store
      cmp al, dh; jb @@store
      sub al, $20
    @@store: mov edi+ecx, al
      dec ecx; jge @@loop         //

    mov eax, edi                  // Result
  pop edi; pop esi
  @@end:
end;

function LowerCased(const S: string): string; assembler asm
// Result = EDX
  test eax, eax; jz @@end
  push esi; push edi
    mov esi, S

    mov eax, Result               // where the result will be stored
    call System.@LStrClr          // cleared for ease
    mov edx, esi.szLen            // how much length of str requested
    call System.@LStrSetLength    // result: new allocation pointer in EAX
    mov edi, [eax]                // eax contains the new allocated pointer
                                  // we got the storage as well at once
    mov edx, 'AZ'                 // DX=$415A -> DH=$41, DL=$5A
    mov ecx, esi.szLen
    dec ecx                       // 0-wise
    @@Loop:
      mov al, esi+ecx
      cmp al, dl; ja @@store
      cmp al, dh; jb @@store
      or al, $20
    @@store: mov edi+ecx, al
      dec ecx; jge @@loop

    mov eax, edi                  // Result
  pop edi; pop esi
  @@end:
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// implementation & samples
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function UPPERSTR(const S: string): string;
begin
  Result := S;
  //SetLength(Result, length(S));
  UniqueString(Result);
  CaseStr(Result, UPCASETABLE);
end;

function lowerstr(const S: string): string;
begin
  Result := S;
  //SetLength(Result, length(S));
  UniqueString(Result);
  CaseStr(Result, locasetable);
end;

function trimStr(const S: string): string;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] <= ' ') do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] <= ' ' do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimStr(const S: string; const Delimiters: TChPosCharset): string; //overload;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] in Delimiters) do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] in Delimiters do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimmed(const S: string; const Delimiter: char): string; //overload;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] = Delimiter) do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] = Delimiter do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimmed(const S: string; const Delimiters: TChPosCharset): string; //overload;
var
  i, Len: integer;
begin
  i := 1;
  Len := Length(S);
  while (i <= Len) and (S[i] in Delimiters) do
    inc(i);
  if i > Len then
    Result := ''
  else begin
    while S[Len] in Delimiters do
      dec(Len);
    Result := Copy(S, i, Len - i + 1);
  end;
end;

function trimStrL(const S: string): string;
var
  i, L: integer;
begin
  i := 1;
  L := Length(S);
  while (i <= L) and (S[i] <= ' ') do
    inc(i);
  if i > L then
    Result := ''
  else begin
    while S[L] <= ' ' do
      dec(L);
    Result := Copy(S, i, L - i + 1);
  end;
end;

function trimStrL(const S: string; const Delimiters: TChPosCharset): string; //overload;
var
  i, L: integer;
begin
  i := 1;
  L := Length(S);
  while (i <= L) and (S[i] in Delimiters) do
    inc(i);
  if i > L then
    Result := ''
  else begin
    while S[L] in Delimiters do
      dec(L);
    Result := Copy(S, i, L - i + 1);
  end;
end;

function trimStrR(const S: string): string;
var
  i: integer;
begin
  i := Length(S);
  while (i > 0) and (S[i] <= ' ') do
    dec(i);
  Result := Copy(S, 1, i);
end;

function trimStrR(const S: string; const Delimiters: TChPosCharset): string; //overload;
var
  i: integer;
begin
  i := Length(S);
  while (i > 0) and (S[i] in Delimiters) do
    dec(i);
  Result := Copy(S, 1, i);
end;

function SameText(const S1, S2: string; const IgnoreCase: boolean = TRUE): boolean;
begin
  if IgnoreCase then
    //Result := iCompare_old(S1, S2) = 0
    Result := _iCompare(S1, S2) = 0
  else
    Result := _cCompare(S1, S2) = 0
end;

function SameBuffer(const P1, P2; const Length: integer;
  const IgnoreCase: boolean = TRUE): boolean;
begin
  Result := pointer(P1) = pointer(P2);
  if not Result then
    if IgnoreCase then
      Result := piCompare(P1, P2, Length, Length) = 0
    else
      Result := pcCompare(P1, P2, Length, Length) = 0
end;

procedure UPPERBUFF(var Buffer; const Length: integer);
//procedure UPPERSTR(var Buffer; const Length: integer);
begin
  //Result := S;
  //SetLength(Result, length(S));
  //UniqueString(Result);
  transBuffer(Buffer, Length, UPCASETABLE);
end;

procedure lowerbuff(var Buffer; const Length: integer);
//procedure lowerstr(var Buffer; const Length: integer);
begin
  //Result := S;
  //SetLength(Result, length(S));
  //UniqueString(Result);
  transBuffer(Buffer, Length, locasetable);
end;

function CharNth(const Index: integer; const Ch: Char; const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1; const BackPos: boolean = FALSE): integer; register overload
begin
  if BackPos then
    if IgnoreCase then
      Result := _biCharIndexPos(Ch, S, StartPos, Index)
    else
      Result := _bcCharIndexPos(Ch, S, StartPos, Index)
  else if IgnoreCase then
    Result := _iCharIndexPos(Ch, S, StartPos, Index)
  else
    Result := _cCharIndexPos(Ch, S, StartPos, Index)
end;

function WordNth(const Index: integer; const S: string; const delimiter: Char; //= ' ';
  const StartPos: integer = 1; const IgnoreCase: boolean = FALSE;
  const BackPos: boolean = FALSE): string;
// function WordAtIndex(const Index: integer; const S: string; const delimiter: Char = ' ';
// const StartPos: integer = 1; const BackPos: boolean = FALSE; const IgnoreCase: boolean = FALSE): string;
// no outrange/wordcount checking!!! wordnth(200000, 'abc', anychar) will result: 'abc'
// note 2004.10.05: outrange check now fixed.
var
  n1, n2: integer;
begin
  if (Index < 1) then // simple outrange checks: or (Index > length(S)) then
    Result := ''
  else begin
    if not BackPos then begin
      if Index = 1 then begin
        n2 := CharNth(Index, delimiter, S, IgnoreCase, StartPos, BackPos);
        if n2 = 0 then
          n2 := length(S) + 1;
        Result := Copy(S, StartPos, n2 - StartPos);
      end
      else begin
        n1 := CharNth(Index - 1, delimiter, S, IgnoreCase, StartPos, BackPos);
        if n1 < 1 then
          Result := ''
        else begin
          inc(n1);
          n2 := CharNth(Index, delimiter, S, IgnoreCase, StartPos, BackPos);
          if n2 = 0 then
            n2 := length(S) + 1;
          Result := Copy(S, n1, n2 - n1);
        end;
      end;
    end
    else begin
      //backpos doesnot yet checked further for an outrange wordcount
      if index = 1 then
        n1 := StartPos + 1
      else
        n1 := CharNth(Index - 1, delimiter, S, IgnoreCase, StartPos, BackPos);
      n2 := CharNth(Index, delimiter, S, IgnoreCase, StartPos, BackPos) + 1;
      // //if n2 < 1 then n2 := length(S) + 1; //!
      Result := Copy(S, n2, n1 - n2);
    end;
  end
end;

// function WordCount_old(const S: string; const delimiter: Char = ' '; const StartPos: integer = 1; const BackPos: boolean = FALSE; const IgnoreCase: boolean = FALSE): integer;
// var
//   Len, n: integer;
// begin
//   Len := length(S);
//   if (StartPos < 1) or (StartPos > Len) then Result := 0
//   else begin
//   //if (StartPos > 0) and (Len >= StartPos) then begin
//     Result := CharCount(delimiter, S, StartPos, IgnoreCase, BackPos);
//     n := Len - StartPos + 1;
//     if S[StartPos] = delimiter then
//       dec(Result);
//     if BackPos then
//       if S[1] <> delimiter then
//         inc(Result)
//       else
//         if S[n] <> delimiter then
//           inc(Result)
//   end;
// end;

function WordCount(const S: string; const delimiter: Char {= ' '}; const StartPos: integer = 1;
  const BackPos: boolean = FALSE; const IgnoreCase: boolean = FALSE): integer;
begin
  if S = '' then
    Result := 0
  else
    Result := CharCount(delimiter, S, StartPos, IgnoreCase, BackPos) + 1;
end;

function fetchWord(const S: string; var StartPos: integer; const Delimiter: char): string;
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos.CharPos(Delimiter, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L)
          ;
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function WordIndexOf(const SubStr, S: string; const Delimiter: char;
  const LengthToBeCompared: integer = MaxInt; const ignoreCaseSubStr: boolean = TRUE;
  const StartPos: integer = 1; const BackPos: boolean = FALSE;
  const ignoreCaseDelimiter: boolean = FALSE): integer;

function min(const a, b: integer): integer; assembler asm
    cmp a, b; jle @end
    mov a, b;
    @end:
  end;

var
  i: integer;
  CS, CSubStr: string;
  M: integer;
begin
  Result := -1;
  if (S <> '') and (SubStr <> '') and (LengthToBeCompared > 0) then begin
    M := min(Length(SubStr), LengthToBeCompared);
    if (length(S) >= M) then begin
      CS := S;
      CSubStr := copy(SubStr, 1, M);
      if ignoreCaseSubStr then begin
        CS := UPPERSTR(CS);
        CSubStr := UPPERSTR(CSubStr);
      end;
      for i := 1 to WordCount(CS, Delimiter, StartPos, BackPos, IgnoreCaseDelimiter) do
        if copy(WordNth(i, CS, Delimiter, StartPos, ignoreCaseDelimiter, BackPos), 1, M) = CSubStr then begin
          Result := i;
          break;
        end;
    end;
  end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// miscellaneous
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function {TxSearch} WCharPos(const firstChar, secondChar: Char;
  const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function {TxSearch} WCharPos(const firstChar, secondChar: Char;
  const S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function {TxSearch} WCharPos(const CharsPair, S: string;
  const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function {TxSearch} WCharPos(const CharsPair, S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordPos(I, S, StartPos)
  else
    Result := _cwordPos(I, S, StartPos)
end;

function {TxSearch} WCharCount(const firstChar, secondChar: Char;
  const S: string; const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

function {TxSearch} WCharCount(const firstChar, secondChar: Char;
  const S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := ord(secondChar) shl 8 or ord(firstChar);
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

function {TxSearch} WCharCount(const CharsPair, S: string;
  const IgnoreCase: boolean = FALSE;
  const StartPos: integer = 1): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

function {TxSearch} WCharCount(const CharsPair, S: string; const StartPos: integer;
  const IgnoreCase: boolean = FALSE): integer; register overload
var
  I: integer;
begin
  I := 0;
  if CharsPair <> '' then
    move(CharsPair[1], I, sizeOf(word));
  if IgnoreCase then
    Result := _icwordCount(I, S, StartPos)
  else
    Result := _cwordCount(I, S, StartPos)
end;

const
  SPACE = ' ';

function ControlCharPos(const S: string; const StartPos: integer): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp byte ptr[esi], SPACE
    lea esi, esi +1; jb @@found
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
  end;

procedure InitIndexTable(var IndexTable: TCharIndexTable; const Charset: TChPosCharset);
var
  Ch: char;
begin
  fillchar(IndexTable, sizeOf(TCharIndexTable), 0);
  for Ch := Low(Ch) to high(Ch) do
    if Ch in Charset then
      IndexTable[Ch] := 1;
end;

function CharPos(const table: TCharIndexTable; const S: string; const StartPos: integer): integer;
//function CharClassPos(const table: TCharIndexTable; const S: string; const StartPos: integer): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi +1; jnz @@found // NZ = found; ZF = notfound
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function NonCharPos(const table: TCharIndexTable; const S: string; const StartPos: integer): integer;
//function CharClassPos(const table: TCharIndexTable; const S: string; const StartPos: integer): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi +1; jz @@found // NZ = found; ZF = notfound
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function CharCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer;
//function CharClassCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin // still need to be checked
  @@zero:
    xor eax, eax; jmp @@EXIT
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
    mov edi, table; xor eax, eax; mov ebx, 1
    @_Loop:
      mov al, [esi]; test [edi+eax*4], ebx
      lea esi, esi +1; jz @_ // ZF = notfound; NZ = found
      ; inc S
    @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop ebx; pop edi; pop esi
  @@EXIT:
end;

function CharNthPos(const table: TCharIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
//function CharClassIndexPos(const table: TCharIndexTable; const S: string; const StartPos: integer { = 1}; const Index: integer): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx; push S
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov S, Index; dec S; jl @@notfound
    mov edi, table; xor eax, eax; mov ebx, 1
  @_Loop:
    mov al, [esi]; test [edi+eax*4], ebx
    lea esi, esi +1; jz @_// ZF = notfound; NZ = found
    dec S; jl @@found
  @_:inc StartPos; jle @_Loop
  @@notfound: mov esi, [esp]
  @@found: sub esi, [esp]; mov eax, esi
  @@end: pop S; pop ebx; pop edi; pop esi
  @@Stop:
end;

function WordCount(const table: TCharIndexTable; const S: string; const StartPos: integer = 1): integer;
begin
  if S = '' then
    Result := 0
  else
    Result := CharCount(table, S, StartPos) + 1;
end;

function fetchWord(const S: string; const WordClass: TCharIndexTable; var StartPos: integer): string;
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos.NonCharPos(WordClass, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L)
          ;
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function fetchWord(const S: string; var StartPos: integer; const DelimitersClass: TCharIndexTable): string;
//function CharClassfetchWord(const S: string; var StartPos: integer; const table: TCharIndexTable): string;
var
  L, p: integer;
begin
  L := length(S);
  Result := '';
  if StartPos > L then
    StartPos := 0
  else if StartPos > 0 then begin
    p := ChPos.CharPos(DelimitersClass, S, StartPos);
    if p = 0 then begin
      if StartPos = 1 then
        Result := S
      else
        Result := copy(S, StartPos, L)
          ;
      StartPos := 0;
    end
    else begin
      Result := copy(S, StartPos, p - StartPos);
      StartPos := p + 1;
    end
  end;
end;

function PackWords(const WordClass: TCharIndexTable; const S: string; const Delimiter: char): string;
var
  i, k, Len, decLen: integer;
  Buf: pChar;
begin
  Result := S;
  if S <> '' then begin
    Len := length(S);
    decLen := Len - 1;
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        xMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (WordClass[S[i]] = 0) do
            inc(i);
          while (i <= len) and (WordClass[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < decLen then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        xMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWordsUpperCase(const WordClass: TCharIndexTable; const S: string; const delimiter: char): string;
var
  i, k, Len: integer;
  Buf: pChar;
begin
  Result := S;
  if S <> '' then begin
    Len := length(S);
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        xMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (WordClass[S[i]] = 0) do
            inc(i);
          while (i <= len) and (WordClass[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < i - 1 then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        xMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWords(const WordClass: TChPosCharset; const S: string; const delimiter: char): string;
var
  i, k, Len, decLen: integer;
  Buf: pChar;
  table: TCharIndexTable;
begin
  Result := S;
  if S <> '' then begin
    InitIndexTable(table, WordClass);
    Len := length(S);
    decLen := Len - 1;
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        xMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (table[S[i]] = 0) do
            inc(i);
          while (i <= len) and (table[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < decLen then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        xMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

function PackWordsUppercase(const WordClass: TChPosCharset; const S: string; const delimiter: char): string;
var
  i, k, Len: integer;
  Buf: pChar;
  table: TCharIndexTable;
begin
  Result := S;
  if S <> '' then begin
    Len := length(S);
    InitIndexTable(table, WordClass);
    if (Len > 0) then begin
      getmem(Buf, len);
      try
        xMove(S[1], buf[0], len);
        i := 1; k := 0;
        repeat
          while (i <= Len) and (table[S[i]] = 0) do
            inc(i);
          while (i <= len) and (table[S[i]] <> 0) do begin
            Buf[k] := S[i];
            inc(i); inc(k);
          end;
          if k < i - 1 then begin
            buf[k] := Delimiter;
            inc(k);
          end;
        until i > Len;
        while (k > 0) and (buf[k - 1] = Delimiter) do
          dec(k);
        SetLength(Result, k);
        xMove(buf[0], Result[1], k);
      finally
        freemem(buf);
      end;
    end;
  end;
end;

{
function packWord(const table: TCharIndexTable; const S: string; const StartPos: integer; const delimiter: char): string;
//const DELIMITER = ' ';
asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push edi; push ebx
    lea esi, S + StartPos -1
    mov ebx, table  // put them here, mov ebx, eax
    sub StartPos, S.SzLen; mov eax, 0; jg @@end
    push ecx                  // ecx = StartPos
    mov eax, Result           // where the result will be stored
    call System.@LStrClr      // cleared for ease
    mov edx, [ESP]            // [esp] is prior ecx value (negative)
    neg edx                   // how much length of str requested
    call System.@LStrSetLength// result: new allocation pointer in EAX
    mov S, [eax]            // eax contains the new allocated pointer -Differ-
    mov edi, [eax]
    mov Result, edi
    pop ecx                   // ecx = StartPos
    xor eax, eax
  @_Loop:
    mov al, [esi]; mov [edi], al
    lea edi, edi +1
    mov eax, ebx + eax*4
    test eax, 1
    lea esi, esi +1; jnz @_ //
    mov al, Delimiter
    cmp [edi-1], al; jnz @_
    dec edi
    mov [edi], al
  @_: inc StartPos; jle @_Loop
    mov eax, Result
    mov edx, eax.SzLen
    sub edi, eax
    cmp edi, edx; jz @@end
    lea eax, Result
    call System.@LStrSetLength
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;
}

const
  HIBIT = $7F;

function AlphaNumCharPos(const S: string; const StartPos: integer; const table): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi; push ebx
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
    mov ebx, table
    xor ecx, ecx
  @_Loop:
    mov cl, byte ptr[esi]
    cmp byte ptr[esi], SPACE
    lea esi, esi +1; jb @@found
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop ebx; pop esi
  @@Stop:
  end;

function HiBitCharPos(const S: string; const StartPos: integer): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; jg @@notfound
  @_Loop:
    cmp byte ptr[esi], hibit
    lea esi, esi +1; ja @@found
    inc StartPos; jle @_Loop
  @@notfound: mov esi, S
  @@found: sub esi, S; mov eax, esi
  @@end: pop esi
  @@Stop:
  end;

function HiBitCharCount(const S: string; const StartPos: integer = 1): integer;
assembler asm
  @@Start:
    test S, S; jz @@zero // check S length
    or StartPos, StartPos; jg @@begin //still need to be checked
  @@zero: xor eax, eax; jmp @@Stop
  @@begin: push esi
    lea esi, S + StartPos -1
    sub StartPos, S.SzLen; mov S, 0; jg @@done
  @_Loop:
    cmp byte ptr[esi], hibit
    lea esi, esi +1; jna @_
    ;inc S
  @_: inc StartPos; jle @_Loop
  @@done: mov eax, S
  @@end: pop esi
  @@Stop:
  end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// test...
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

const
  _CR = ^m; // $0D
  _LF = ^j; // $0A
  _CRLF = ord(_CR) or (ord(_LF) shr 8); // $0A$0D

function PosCRLF(const S: string; const StartPos: integer = 1): integer;
begin
  //Result := _cWordPos(WideChar(_CRLF), S, StartPos);
  Result := _cWordPos(_CRLF, S, StartPos);
end;

type
  par = ^tar;
  tar = array[0..0] of Char;

function UNIXed(const CRLFText: string): string;
// strip CR from CRLF, CRLF to LF only (unix style)
var
  i, j, k, L: integer;
  Buf: Par;
  S: string;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  if L > 0 then begin
    getMem(Buf, L);
    try
      j := 0; k := 0;
      for i := 1 to ChPos.WordCount(CRLFText, ^m) do begin
        inc(k);
        S := ChPos.WordNth(1, CRLFText, ^m, k);
        L := length(S);
        move(S[1], Buf^[j], L);
        inc(j, L); inc(k, L);
      end;
      if j > 0 then begin
        SetLength(Result, j);
        move(Buf^[0], Result[1], j);
      end;
    finally
      freemem(Buf);
    end;
  end;
end;

// should be faster - untested yet, no time

function UNIXed2(const CRLFText: string): string;
// strip CR from CRLF, CRLF to LF only (unix style)
var
  i, j, k, L: integer;
  Buf: Par;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  if L > 0 then begin
    getMem(Buf, L);
    try
      i := PosCRLF(CRLFText);
      if i > 0 then begin
        j := 1; k := 0;
        while i > 0 do begin
          L := i - j;
          move(CRLFText[j], Buf^[k], L);
          inc(k, L); Buf^[k] := ^j; inc(k);
          j := i + 2;
          i := PosCRLF(CRLFText, j);
        end;
        L := length(CRLFText) - j;
        move(CRLFText[j], Buf^[k], L);

        inc(j, L);
        SetLength(Result, j);
        move(Buf^[0], Result[1], j);
      end;
    finally
      freemem(Buf);
    end;
  end;
end;

function MACed(const CRLFText: string): string;
// strip LF from CRLF, CRLF to CR only (MAC style)
var
  i, j, k, L: integer;
  Buf: Par;
begin
  Result := CRLFText;
  L := Length(CRLFText);
  if L > 0 then begin
    getMem(Buf, L);
    try
      j := 1; k := 0;
      i := PosCRLF(CRLFText);
      if i > 1 then begin
        repeat
          L := i - j - 1; // ecxluding the last-char
          move(CRLFText[j], Buf^[k], L);
          inc(k, L);
          j := i;
          i := PosCRLF(CRLFText, j + 1);
        until i < 1;
      end;
      if j > 1 then begin
        SetLength(Result, j);
        move(Buf^[0], Result[1], j);
      end;
    finally
      freemem(Buf);
    end;
  end;
end;

end.

