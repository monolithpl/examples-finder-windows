unit Ordinals; // previously Ordnums unit
{$I QUIET.INC}
{$WEAKPACKAGEUNIT ON}
{.$G+}
{$J-} //no-writeableconst
//{$G+} //imported data on
{.$D-}//no-debug

{
  Fast & (not too) primitive ordinal number conversion
  (byte, shortint, smallint, word, dword, integer, int64)
  strictly speaking this is a 'not real' unit

  Copyright (c) 2004, Adrian H., Ray F. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  mailto: aa<@AT>softindo<@DOT>net
  http://delphi.softindo.net

  Compiler: D5, D7, maybe works also on D4, but not D3 (because of default args value)

  //delete this insulting text upon upload...
    I dont like D7 code editor, the font-rendering too sparsed, I had to get
    a font editor and create my own font to replace my favorite lucida console,
    so it displayed as tight as it did in old D5.

    The most annoying thing is that the message view is constantly blaming that MY code
    was error- she couldn't invoke the code completion (when i was writing asm lines).
    even when i turned off the code-completion features; and either explicitly close
    or open the message view; everytime i typed an advanced space, that f^(&!*@ b!^(#
    keeps appears and disappering makes the screen flickers. also when i teared it up
    and put it outside, it will then blown up & change the focus to itself!!! what A....
    (I then instantly felt an urge to kill that error message inventor).

    Others are good, pretty much better than D5 (still Delphi is the best), I've
    been waiting for that customizable Code-Completion Width/Height, yet only the new
    complete set of asm ops alone was the unavoidable reason for me to switch to D7.
    (I'm not considering D6 or D8, ever not- I liked Delphi's even number release)

  +collection from other source:
    pseudo random generator (Agner Fog, http://www.agner.org) - fixed, enhanced.
    fastcode (InttoStr & Int64toStr)
    ReverseBits from russian's QString by Andrew Dryazgov & Sergey G. Shcherbakov

===============================================================
CHANGES
  Version: 1.0.0.8b, LastUpdated: 2005.09.2
    note: what a mess :(
    added: 3-digits Fold argument in octn, to support Ordinals Type Editor
    added: uintostr for Int64 (inttostr for unsigned int64)

  Version: 1.0.0.8a, LastUpdated: 2005.09.1
    changed: using two separated routines instead (more convenient):
             - hexb: buffer dump (read from first byte to the end)
             - hexn: buffer as hex number (internally reversed, read from the last)
                     in effect interprets buffer as a (Big-Endian) hex number

             the two's above accept args: (char) Delimiter, xsLowercase and xsByteSwap
             note that Delimiter = #0 (default value) means NOT-delimited at all

             example: @Int64, value : $0123456789ABCDEF
                            (all delimited with space)
             hexb               EF CD AB 89 67 45 23 01
             hexb (ByteSwap)    FE DC BA 98 76 54 32 10

             hexn               01 23 45 67 89 AB CD EF
             hexn (ByteSwap)    10 32 54 76 98 BA DC FE

    changed: also bins become binb and binn (paralel with hex- above)
    changed: octb and octn works in paralel with above, octs remains.

  Version: 1.0.0.8, LastUpdated: 2005.09.0
     changed: hexs redesigned completely; now using THexStyles argument
              (xsLowercase, xsReverse, xsSwapByte)

  Version: 1.0.0.7, LastUpdated: 2005.08.0
    fix: bug 0 intoStr, using: ( >0 ) when it used to be: ( >= 0 )
    changed: bins(Buffer), uniform simple dword instr should be faster
             (also fixed bug in old version which erroneously using SHL in place of SHR)
             todo: making/stating the most convenient way to access bins
    add/changed: add new "octs" routine; previous "octs" changed to "octs_b"
    add: Reverse Bits (from QString by Andrew Dryazgov & Sergey G. Shcherbakov)
    add: Reverse string to support big/little-endian convert (notably "octb/octn" & "octs")
         dword per-move, arranged to avoid AGI-stall, (but unwatch for unaligned dword).
    add: bintoi, bintoi64, binary-string (bin, hex and octal) to integer conversion routines
    changed: new hexs for buffers seems to be OK, (and correct). prior versions
             (for int, byte word etc) are deprecated and will at last be declined.

  Version: 1.0.0.6, LastUpdated: 2005.06.0
    Remove dependency to system (Str & StrLong, slow conversion of integer
    to string), replaced/rearrange with code winner from www.fastcode.dk (author: John O'Harrow)
    added: uintostr, unsigned cardinal to string conversion (cardinal version only,
           derived from fastcode, much faster than using Int64 converter, when
           value to be converted is greater than maxint (2147483647)).

  Version: 1.0.0.5b, LastUpdated: 2005.05.0
    published: getBitsWide, get bits wide of specified value
    added: Shuffle function, flexible range min..max inclusive
    changed: regarding above, change name: RandShuffle to RandCycle,
            (in fact it is actually "cycled" or "Rolled", not "shuffled")
    added: RandomizeEx function, just a simple wrapper of RDTSC
    added: DivMod64, get int64 dividend and quotient / modulo at once

  Version: 1.0.0.5, LastUpdated: 2005.04.1
    added: ROR & ROL ~ why aren't they built-in in the System unit? :(
    add/changed: bin to bins (as in hexs), now better & works also with buffer
    add: octs (bins and hexs complement)
    add/moved from ACommon unit: Blocks (in pure pascal!)
    fixed: bins (negative value should not have to always be widened to 64-bits)
    add: shld/shrd now functional, slightly different (extended) from asm instruction
    fixed: slippery bug min/max for int64

    bug report, please...
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// The random functions is originated from Uniform Random Number Generator.
// Copyrighted by Agner Fog, http://www.agner.org/random/, licensed under GNU GPL.
// -
// we did a small fix of floating issue, (ought to be?) better initialization
// (at least it really do -what the original version was trying to- with real
// number), enhance double to extended (from full 64-bits wide, not just a
// plain casting), arrange history to directly accomodate int64 result,
// refine min/max range, etc. Delphi's specific.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// as Neumann says, -Anyone who consider arithmetic means of producing random
// number is, of course, in a state of sin- use this only if you worry about
// different implementation of random function across delphi version
//

interface
uses ACConsts; //const YES = TRUE;

type
  TInts = ACConsts.TInts;
  TArInts = ACConsts.TArInts;
  TStrs = ACConsts.TStrs;

  r64 = packed record
    Lo, hi: integer;
  end;

  tHexStyle = (
    xsLowerCase, // you now it; default = FALSE, means Uppercase
    xsReverse, // BigEndian vs Little Endian (as a whole)
    xsSwapByte, // properly stated: swap-nibbles at every byte-boundaries
    xsBlockWise // unimplemented, Reverse at every block-boundaries
    );
  tHexStyles = set of tHexStyle;

//type TBytesWide = (bwByte, bwWord, bwInteger, bwInt64, bwInt256, bwBigInt, bwVeryBigInt, bwHugeInt);

// ====================================================================
// TEST AREA, TEST AREA, TEST AREA, TEST AREA, TEST AREA, TEST AREA,
// --------------------------------------------------------------------

function hexs_countspace(const Buffer: pointer; const BufLen: integer; const BlockLen: integer;
  const Delimiter: char = ' '; const HexStyles: THexStyles = []): integer; overload;

//function hexs_ord_inprogress_(const Buffer: pointer; const BufLen: integer; BlockLen: integer;
//  Delimiter: char; const HexStyles: THexStyles): integer; overload;

function getL64(const I: Int64): integer;

//function Int64uStr(const I: Int64; const Digits: byte = 0): string;
//function I64uStr(x64: Int64): string;

// --------------------------------------------------------------------
// END TEST AREA
//================================================================================

//  never used:
//
//  TBits = class
//  private
//    fSize: integer;
//    fBits: Pointer;
//    procedure Error;
//    procedure setSize(Value: integer);
//    procedure setBit(Index: integer; Value: Boolean);
//    function getBit(Index: integer): Boolean;
//  public
//    destructor Destroy; override;
//    function OpenBit: integer;
//    property Bits[Index: integer]: Boolean read getBit write setBit; default;
//    property Size: integer read fSize write setSize;
//  end;

function setBit(const BitNo, I: integer): integer; overload;
function ResetBit(const BitNo, I: integer): integer; overload;
function ToggleBit(const BitNo, I: integer): integer; overload;
function isBitSet(const BitNo, I: integer): Boolean; overload;

function setBit(const BitNo: integer; const I: Int64): Int64; overload;
function ResetBit(const BitNo: integer; const I: Int64): Int64; overload;
function ToggleBit(const BitNo: integer; const I: Int64): Int64; overload;
function isBitSet(const BitNo: integer; const I: Int64): boolean; overload;

procedure ReverseBits(Buffer: Pointer; BitCount: cardinal);

//(yet another) reverse a string, using dword per move (thanks to bswap)
function Reverse(const S: string): string;

// get bits wide of a number (locate the highest bit of specified number), 1-based.
// will use preferredbitswide instead if the highest bit is LOWER than given preferredBitsWide
function getBitsWide(const I: Int64; const preferredBitsWide: integer = 0): integer;

// makes a binary (bits) string from a value
// at this time, no formatting provided. use function "blocks" instead
// binb works as bytes dump, whereas binn will interprets the whole Buffer as a value
function binb(const Buffer: pointer; const BufferLength: integer): string;
function binn(const Buffer: pointer; const BufferLength: integer): string;

//LEGACY_CODE: (used for sample implementation only)
//function bins(const I: Int64; const BitsWide: integer = 32): string; overload;
//function bins(const Buffer: pointer; const BufferLength: integer): string; overload;
//function bins(const I: Int64; const blockwidth: integer; const blockdelimiter: char; const BitsWide: integer = 32): string; overload;
//function bins(const I: Int64; const blockdelimiter: char; const BitsWide: integer = 32; const blockwidth: integer = 4): string; overload;

// makes an octal string from buffer as a one contiguous bits
function octb(const Buffer: pointer; const BufferLength: integer): string; overload;

// interprets octal buffer as an octal value
function octn(const Buffer: pointer; const BufferLength: integer; const Fold3digits: boolean = FALSE): string;

// in the ordinary usage, the data/buffer always seen as group of bytes not bits.
// that was not the case in the octal format, the next or previous bits in 3 bytes
// group will contains one or two bits remains of the octal value.
//
// the other ordinals routines (hexsb and binb) also interpret buffer as bytes
// that is actually the "wrong" sight of bits order; for intstance, the value
// 12h or 1100-0010b actually stored as 21 or 0100-0011 in memory (big-endian)
//
// the octb routine did contrawise with hex/bin. since it is not possible to
// truncate data per-byte which might be broken on the middle of an octal value
//
// in the consequence of that, the octn result (interpret as value) would be
// no different with a reversed string of octb result.

// makes an octal string from a value byte-per-byte rather than continuous
function octs(const Buffer: pointer; const BufferLength: integer; const Delimiter: Char = #0): string; overload;

//LEGACY_CODE: (used for sample implementation only)
//function octs(const I: Int64; const Delimiter: string = ''): string; overload;
//function octs(const I: integer; const Delimiter: string = ''): string; overload;

//LEGACY_CODE: (used for sample implementation only)
//function octs(const I: Int64; const Delimiter: string = '.'): string; overload;
//function octs(const I: integer; const Delimiter: string = '.'): string; overload;

// the simple difference between "octb/octn" and "octs" is by example,
// of value 256 ($0100),  octn result = 400, whereas octs result = 1000 (001 000)
// the practical uses of octs is, for instance, converting IP digit number from an integer,
// whereas octb/octn is used for.. i dont know, it simply a base-8 number converter :)
//

// pretty formatted hexa number
function hexb(const Buffer: pointer = nil; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;

function hexn(const Buffer: pointer = nil; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;

function hexs(const Buffer: pointer; const BufLen: integer; const HexStyles: THexStyles;
  const Delimiter: char): string; overload;
//LEGACY_CODE
//function hexs(const Buffer: pointer; const BufLen: integer; const Delimiter: Char = #0;
//  UpperCase: boolean = TRUE): string; overload; forward;
//OBSOLETE_CODE
//function hexs(const byte: byte; const uppercase: boolean = YES): string; overload;
//function hexs(const word: word; const uppercase: boolean = YES): string; overload;
//function hexs(const integer: integer; const uppercase: boolean = YES): string; overload;
//function hexs(const I: Int64; const uppercase: boolean = YES): string; overload;

// bintoi & bintoi64, string to integer conversion routines for binary, octal
// and hex number with suffix "b", "o" and "h" respectively, so we could say:
// "111 0001 1011b", or "000111 0001-1011_b", or "07 - 11H". all are equals
// since the middle delimiters are treated as nondestructive whitespaces (ignored)
// as in:  "+---11o" (octal) = "-1-0-0---1 b"  = -9.
//
// You may change default delimiters (charset) at run time by assigning
// a new value to the global variable: "ordDelimiters", currently are:
// HYPEN (see notes below), COLON, SPACE and ANY control characters.
// (most likely to be out-of-sync with this text. see the actual value
//  of GlobalVar "orDelimiters" instead).
//
// note: preceding series of DASHes/HYPENs (also PLUSes) will be
//       interpreted as multiplied negative/positive sign.
//       The PLUS sign in the middle of numbers is an error
//
// note: "octs" function works as byte-per-byte translator e.g.
//       12345 = $3039 (means: $30, $39) = "060071" (means: 060, 071);
//       whereas in bintoi, 12345 should be written as: "30071o"
//       = 3*(8*8*8)  +  0*(8*8)  +  0*(8*8)  +  7*8  +  1  = 30071_o
//
//       another example of "octs" output: 1234567 = $12D687 ($12, $D6, $87) = "22326207"
//       in bintoi should be written as: "4553207_o"
//       = 4(8^6) + 5(8^5) + 5(8^4) + 3(8^3) + 2(8^2) + 0*8 + 7
//
// on conversion error, the errCode contains value > 0
//   high byte:
//     01h: blank string
//     02h: too small a string
//     03h: invalid suffix (other than upper/lower 'B','O' and 'H')
//     04h: not a number
//     05h,06h,07h: invalid character in bin/oct/hex string respectively
//   low byte: if applicable, indicates the position of error.
//
// note:
//   no overflow error checks, the function will happily interpret any
//   syntaxly correct string such as "+---01234567-890ABCDEF-01234567-890ABCDEF-.....01234567h"
//   anyhow it will gives the proper least-fit integer value: "19088743" ($01234567),
//   or "-8526495043095935641" ($890ABCDEF01234567) for int64 value
//

//bintoi for integer and int64
function bintoi(const S: string; out errCode: integer): integer; overload;
function bintoi64(const S: string; out errCode: integer): Int64; overload;

// simple wrapper, on conversion error the result value will be
// the lowest int number: $80000000 (integer) or $8000000000000000 (int64)
//
// as always, do not put these declarations before/above called routines,
// since they are blindly stupid assembler routines, who does not give
// a damn about number of arguments, they call whichever comes first at
// declaration order
function bintoi(const S: string): integer; overload;
function bintoi64(const S: string): Int64; overload;

//OBSOLETE:
//function hexss(const integer: integer; const uppercase: boolean = YES): shortstring; overload;
//function hexss(const I: int64; const uppercase: boolean = YES): shortstring; overload;
//
//function hexs(const Buffer: pointer; const BufLen: integer; UpperCase: boolean): string; overload;
//function hexs_b(const Buffer: pointer; const BufferLength: integer;
//  const Delimiter: Char = #0; const Uppercase: boolean = YES): string; overload;
//function hexs(const Buffer: pointer; const BufferLength: integer;
//  const Uppercase: boolean; const Delimiter: Char = #0): string; overload;

// just a speedy wrapper for Inttostr, IntToHex and StrToInt
// function intoStr(const I: cardinal; const Digits: integer = 8): string; overload;

// note that the CARDINAL type will be treated by the compiler as int64
// since high(cardinal) > high(integer), therefore if you are not specifying Digits,
// for cardinal type argument, it is default to Int64's digit size (16 chars width)

// as rule of thumb, always specifies Digits (length) for cardinal type argument

// IsHex is just an auto prepend '$' hex-specifier,
// so do not call IsHex = YES, if the S has already had '$'

function IntoHex(const I: integer; const Digits: byte = sizeof(integer) * 2; UpperCase: boolean = YES): string;
register overload;
//function IntoHex(const I: cardinal; const Digits: byte = Sizeof(integer) * 2; UpperCase: boolean = YES): string; register overload;
function IntoHex(const I: Int64; const Digits: byte = sizeof(Int64) * 2; UpperCase: boolean = YES): string;
register overload;
//function IntoHex(const I: Int64; const Digits: integer = 0; UpperCase: boolean = YES): string; register overload;
//function IntoHex_old(const I: Int64; const Digits: byte = sizeof(byte)): string; register;
function IntoStr(const I: integer; const digits: integer = 0): string; register; overload;
function IntoStr(const I: Int64; const digits: integer = 0): string; register; overload;
function IntOf(const S: string; const DefaultValue: integer = 0): integer; register; overload;
function uintostr(const I: integer): string; overload; // unsigned intostr, derived from fastCode
function uintostr(const I: Int64): string; overload; // unsigned intostr, derived from fastCode
//function IntOf(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer; overload;
//function Int64Of(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64; overload;
//function IntOf(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
//function Int64Of(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;

// much simpler StrToIntDef clones, do not expect too much
function Str2Int(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer;
overload;
function Str2Int64(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64;
overload;
function Str2Int(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
function Str2Int64(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;

// minmax functions // better use minmaxmid unit
function Min(const a, b: integer): integer; register overload
function Max(const a, b: integer): integer; register overload
function UMin(const a, b: cardinal): cardinal; register overload //unsigned integer
function UMax(const a, b: cardinal): cardinal; register overload //unsigned integer
function Min(const a, b: Int64): Int64; register overload //unsigned integer
function Max(const a, b: Int64): Int64; register overload //unsigned integer
function uMin(const a, b: Int64): Int64; register; overload //unsigned int64
function uMax(const a, b: Int64): Int64; register; overload //unsigned int64

// ROL & ROR family, which should have been included in the System unit
function rol(const I: integer): integer; register overload;
function ror(const I: integer): integer; register overload;
function rol(const I: Int64): Int64; register overload;
function ror(const I: Int64): Int64; register overload;

function rol(const I: integer; const ShiftCount: integer): integer; register overload;
function ror(const I: integer; const ShiftCount: integer): integer; register overload;
function rol(const I: Int64; const ShiftCount: integer): Int64; register overload;
function ror(const I: Int64; const ShiftCount: integer): Int64; register overload;

// and why aren't shlr & shld either? :)
procedure shld(var A: integer; const B: integer); register overload;
procedure shrd(var A: integer; const B: integer); register overload;
procedure shld(var A: Int64; const B: Int64); register overload;
procedure shrd(var A: Int64; const B: Int64); register overload;

// unlike (better than) asm shld/shrd, this routines will shift the second argument
// into the first argument until *all* of them are zeroed (up to 64 shifts)
procedure shld(var A: integer; const B: integer; const ShiftCount: byte); register overload;
procedure shrd(var A: integer; const B: integer; const ShiftCount: byte); register overload;

// unlike (better than) asm shld/shrd, this routines will shift the second argument
// into the first argument until *all* of them are zeroed (up to 128 shifts)
procedure shld(var A: Int64; const B: Int64; const ShiftCount: byte); register overload;
procedure shrd(var A: Int64; const B: Int64; const ShiftCount: byte); register overload;

// note:
//   the optimization by the compiler will lead to integer version of ROL/ROR
//   if the value of I is within the range of integer (you should typecasted it to Int64).
//
//  // priorly ShiftCount is of type byte, now changed to integer,
//  // this note is no longer applicable; this only for remainder,
//  // on the similar circumtance, this comment is still valid though.
//  // obsolete:  BEWARE if you (on slippery) supplied an integer type
//  // obsolete:  (NOT byte) of ShiftCount, EVEN if I is type of int64,
//  // obsolete:  the compiler will take an integer version of ROL/ROR.
//  // obsolete:  (you MUST explicitly typecasted it to byte)
//
//   to avoid confusion, rol for int64 idname might better be changed to (ie.) rol64 instead
//

// get Quotient and Remainder at once // for D4 below change "out" with "var"
function DivMod64(const Dividend, Divisor: Int64; out Quotient: Int64): Int64;

// block string formatting, distribute string in blocks of BlockLen length,
// customizable block length and delimiter, leftwise or rightwise, e.g.:
//
//   1234567890 -> 123 456 789 0  (length = 3 (default), delim = A SPACE, leftwise)
//   1234567890 -> 1 234 567 890  (length = 3 (default), delim = A SPACE, righwise)
//
// Prefix and Suffix length are number of firstly/lastly characters to be
// ignored in formatting
//
// note: to format Buffer as hex use Hexs function instead!
//
// originally i used blocks to format money, that way it is default to 3.
// now i feel urge to change them to 4 to format integer which currently
// i intensively working on. after-all, this in fact is an ORDINALS unit, isn't it?
// any comments for this?
//
function Blocks(const S: string; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
function Blocks(const I: integer; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;

// many often i just want to change the blocklength
function Blocks(const S: string; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
function Blocks(const I: integer; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;

// - RANDOM -
// These pseudo random function will generates a predictive reproductable result (the same
// sequence of numbers) by the same RandSeed numbers or the same RandomInit argument.

// see notes below
function Rand64: Int64; overload
function Rand(const Max: cardinal = high(cardinal)): cardinal; register overload
function Rand(const Min, Max: integer): integer; register overload
function RandEx: Extended;

// remember to call this function first (and feed it your own exotic magic numbers)
// usually the argument is time-tick value; to produce an unpredictable numbers sequence
procedure RandInit(const I: integer = __AAMAGIC0__); register

// All right then, you lazy... We give you Randomize function here at last :(
procedure RandomizeEx;

// Shuffle: generate array of non repeatable integers of specified range in min..max (inclusive)
// the min/max value may be negative as long as min..max range (inclusive) does not exceed
// 4 GB boundary, no error checking, since the array itself would not even permit that huge.
// note that this function is NOT including initialization of random / randomize (neither did-
// the other random functions), it will gives a repeatable sequence when given the same init value

// function _Shuffle(Range: integer): TInts;
function Shuffle(const Max: integer; const Min: integer = 0): TInts;

const
{$J+}
  RandseedEx: array[0..4] of integer = (__AAMAGIC0__, __AAMAGIC1__, __AAMAGIC2__, integer(__CRC32Poly__), -1);
  // note that all of the magic numbers above will be trashed anyway upon init
  // presented just in case you forgot to call randomizeEx function

  //threadvar
  ordDelimiters: set of char = [#0..' ', ':', '.', '_'];
{$J-}

const
  BitsperByte = 8;
  BitsperWord = sizeof(word) * BitsPerByte;
  BitsperInt = sizeof(integer) * BitsPerByte;
  BitsperInt64 = sizeof(Int64) * BitsPerByte;

  // ====================================================
  //         TEST AREA...
  // ====================================================

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // private debug/test only, DO NOT use!
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  {
  type
    TIDStr = class
    private
      fInts: TInts;
      fStrs: TStrs;
      fMaxID: integer;
      fCount: integer;
      function getValue(const ID: integer): string;
      procedure setValue(const ID: integer; const Value: string);
      procedure setCount(const Value: integer);
    public
      destructor Destroy; override;
      constructor Create; overload;
      constructor Create(const Size: integer); overload;
      property Strings[const ID: integer]: string read getValue write setValue; default;
      function IDOf(const Value: string): integer;
      function IDAtPos(const Pos: integer): integer; // ordinal position (0-based)
      function ValueAtPos(const Pos: integer): string; // ordinal position (0-based)
      property Count: integer read fCount write setCount;
      function delete(const ID: integer): boolean;
      procedure join(const IntStr: TIDStr);
      procedure Clear;
    end;
  }

implementation
//uses MinMaxMid

//type
//  TBinaryType (binBoolean, binByte, binWord, binDword, binInt64
// function _fillzero(const S: string; const digits: integer; const positive: boolean): string;
// // dont ever let anything critical called under the try..except/finally construct
// // for that would degrade the performance down, the compiler inserts fs: everywhere
// var
//   n: integer;
// begin
//   n := length(S);
//   if digits <= n then Result := S
//   else begin
//     if positive then
//       Result := StringOfchar(zero, digits - n) + S
//     else
//       Result := dash + StringOfChar(zero, digits - n) + copy(S, 2, n);
//   end;
// end;
//end;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Notes:
//   Min-Max functions excerpted from unit MinMaxMid
//   (produced by the same authors)
//   please get the recent version
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Min(const a, b: integer): integer; overload asm
   cmp a, b; jle @end
     mov a, b
   @end:
end;

function Max(const a, b: integer): integer; overload asm
   cmp a, b; jge @end
     mov a, b
   @end:
end;

function UMin(const a, b: cardinal): cardinal; overload asm
  cmp a, b; jbe @@done
    mov a, b
  @@done:
end;

function UMax(const a, b: cardinal): cardinal; overload asm
  cmp a, b; jae @@done
  mov a, b
  @@done:
end;

function uMin(const a, b: Int64): Int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp edx, b.r64.hi; jbe @@end
  cmp eax, b.r64.Lo; jbe @@end
  mov eax, b.r64.Lo
  mov edx, b.r64.hi
  @@end:
end;

function uMax(const a, b: Int64): Int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp edx, b.r64.hi; jae @@end
  cmp eax, b.r64.Lo; jae @@end
  mov eax, b.r64.Lo
  mov edx, b.r64.hi
  @@end:
end;

// minint64 actually is identical in structure with maxint64

function Min(const a, b: Int64): Int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp b.r64.hi, edx; jg @@end; js @@less
  cmp b.r64.Lo, eax; jae @@end
  @@less: mov eax, b.r64.Lo; mov edx, b.r64.hi
  @@end:
end;

// maxint64 actually is identical in structure with minint64

function Max(const a, b: Int64): Int64; overload asm
  mov edx, a.r64.hi; mov eax, a.r64.lo
  cmp edx, b.r64.hi; jg @@end; js @@less
  cmp eax, b.r64.Lo; jae @@end
  @@less: mov eax, b.r64.Lo; mov edx, b.r64.hi
  @@end:
end;

//~~~~~~~~~~~~~~~~~~~~~~
// end minmax functions
//~~~~~~~~~~~~~~~~~~~~~~

//~~~~~~~~~~~~~~~~~~~~~~
// ROL/ROR
//~~~~~~~~~~~~~~~~~~~~~~

function rol(const I: integer): integer; overload asm rol I, 1
end;

function rol(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    shl eax, 1; rcl edx, 1
    jnc @done; or eax, 1
  @done: //popfd
end;

function ror(const I: integer): integer; overload asm ror I, 1
end;

function ror(const I: Int64): Int64; overload asm
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo //  in Pentium they could also be run parallelized
    shr edx, 1; rcr eax, 1
    jnc @done; or edx, 1 shl 31
  @done: //popfd
end;

function rol(const I: Int64; const ShiftCount: integer): Int64; register overload asm
    mov ecx, ShiftCount // as Intel says, upon shift this value will be taken MODULO 32
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    and ecx, $3f; jz @exit
    cmp cl, 32; jb @begin
    //xchg eax, edx   // avoid LOCK prefixed xchg instruction
    mov eax, edx      // simple move should be faster & pairing enable
    mov edx, I.r64.lo //
    jz @exit
  @begin:
    push ebx; mov ebx, eax
    shld eax, edx, cl
    shld edx, ebx, cl
  @done: pop ebx
  @exit:
end;

function ror(const I: Int64; const ShiftCount: integer): Int64; register overload asm
    mov ecx, ShiftCount // as Intel says, upon shift this value will be taken MODULO 32
    mov edx, I.r64.hi  // using register is faster than directly accessing memory
    mov eax, I.r64.lo // in Pentium they could also be run parallelized
    and ecx, $3f; jz @exit
    cmp cl, 32; jb @begin
    //xchg eax, edx   // avoid LOCK prefixed xchg instruction
    mov eax, edx      // simple move should be faster & pairing enable
    mov edx, I.r64.lo //
    jz @exit
  @begin:
    push ebx; mov ebx, edx
    shrd edx, eax, cl
    shrd eax, ebx, cl
  @done: pop ebx
  @exit:
end;

function rol(const I: integer; const ShiftCount: integer): integer; register overload asm
  mov ecx, ShiftCount; rol I, cl
end;

function ror(const I: integer; const ShiftCount: integer): integer; register overload asm
  mov ecx, ShiftCount; ror I, cl
end;

procedure shld(var A: integer; const B: integer); register overload asm shld [A], B, 1
end;

procedure shld(var A: integer; const B: integer; const ShiftCount: byte); register overload asm
  //mov cl, ShiftCount
  cmp cl, 3fh; jbe @1
  mov dword[A], 0; jmp @end
@1: test cl, cl; jz @end
  cmp cl, 20h; jb @B
  mov [A], B; xor B, B
@B: shld [A], B, ShiftCount
  @end:
end;

procedure shld(var A: Int64; const B: Int64); register overload asm
// A in [eax]; B in stack (not in register);
  mov edx, A.r64.lo
  shld A.r64.hi, edx, 1
  mov ecx, B.r64.hi
  shl edx, 1
  or ecx, ecx; jns @end; or edx, 1
  @end: mov A.r64.lo, edx
end;

procedure shrd(var A: integer; const B: integer); register overload asm shrd [A], B, 1
end;

procedure shrd(var A: integer; const B: integer; const ShiftCount: byte); register overload asm
//mov cl, ShiftCount
  cmp cl, 3fh; jbe @1
  mov dword[A], 0; jmp @end
@1: test cl, cl; jz @end
  cmp cl, 20h; jb @B
  mov [A], B; xor B, B
@B: shrd [A], B, ShiftCount
  @end:
end;

procedure shrd(var A: Int64; const B: Int64); register overload asm
  // A in [eax]; B in stack (not in register);
  mov edx, A.r64.hi
  shrd A.r64.lo, edx, 1
  mov ecx, B.r64.lo
  shr edx, 1
  test ecx, 1; jz @end; or edx, 1 shl 31
  @end: mov A.r64.hi, edx
end;

procedure _shld(var A: Int64; const B: Int64; const ShiftCount: byte); register overload asm
  // A in [eax]; B in stack (not in register);
  mov cl, ShiftCount
  cmp cl, $3f; jbe @1
  xor edx, edx
  mov A.r64.hi, edx
  mov A.r64.lo, edx
  jmp @end
@1: test cl, -1; jz @end
  push ebx
  mov ebx, B.r64.hi
  mov edx, A.r64.lo
  cmp cl, 32; jb @A

  mov A.r64.hi, edx
  mov A.r64.lo, ebx
  jz @E //shift = 32
@2:
  mov edx, ebx  // edx := B.r64.hi
  mov ebx, B.r64.lo
@A:
  shld A.r64.hi, edx, cl
  shld edx, ebx, cl
  mov A.r64.lo, edx
@E: pop ebx
  @end:
end;

procedure _shrd(var A: Int64; const B: Int64; const ShiftCount: byte); register overload asm
  // A in [eax]; B in stack (not in register);
  mov cl, ShiftCount
  cmp cl, $3f; jbe @1
   xor edx, edx
   mov A.r64.hi, edx
   mov A.r64.lo, edx
   jmp @end
@1: test cl, -1; jz @end
  push ebx
  mov ebx, B.r64.lo
  mov edx, A.r64.hi
  cmp cl, 32; jb @A

  mov A.r64.lo, edx
  mov A.r64.hi, ebx
  jz @E //shift = 32
@2:
  mov edx, ebx  // edx := B.r64.lo
  mov ebx, B.r64.hi
@A:
  shrd A.r64.lo, edx, cl
  shrd edx, ebx, cl
  mov A.r64.hi, edx

@E: pop ebx
  @end:
end;

procedure shld(var A: Int64; const B: Int64; const ShiftCount: byte); register overload;
begin
  if ShiftCount > 127 then
    A := 0
  else if ShiftCount > 63 then
    A := B shl (ShiftCount and 63)
  else
    _shld(A, B, ShiftCount);
end;

procedure shrd(var A: Int64; const B: Int64; const ShiftCount: byte); register overload;
begin
  if ShiftCount > 127 then
    A := 0
  else if ShiftCount > 63 then
    A := B shr (ShiftCount and 63)
  else
    _shrd(A, B, ShiftCount);
end;

// check the highest bit was made because BSR may takes upto 72 clocks!
// this doesnt have to be faster, but at least i try :)

function getBitsWide(const I: Int64; const preferredBitsWide: integer = 0): integer; assembler asm
  mov ecx, preferredBitsWide
  xor eax, eax; mov al, 64
    test  I.r64.hi, -1; jnz @@check; shr al, 1   // 32
  mov edx, I.r64.lo
    test edx, 0ffff0000h; jnz @@check; shr al, 1 // 16
    test edx, 0ff00h; jnz @@check; shr al, 1     // 8
    test edx, 0f0h; jnz @@check; shr al, 1       // 4
    test edx, 1100b; jnz @@check; shr al, 1      // 2
    test edx, 10b; jnz @@check; shr al, 1        // 1
  @@check: cmp ecx, eax; jl @@end
  @@userSize: mov eax, ecx
  @@end: //and eax, $ff
end;

// LStrClearAndSetLength - a simple routine to clear and allocate a new string.
// At last, after tired of calling the same sequence of System's routines.
// it should have been one of the routine i've made first. :(, better than never.

function __LStrCLSet(var S; const Length): {string} PChar; overload asm
// * no register destroyed, result EAX points to the first char *
     push ecx; push edx; push eax
     mov edx, [eax]; test edx, edx; je @nil
     mov dword[eax], 0; lea eax, [edx-8]
     mov edx, dword[edx-8]; test edx, edx; jl @nil // neg refCount = constant string
     nop // to avoid AGI-stall
LOCK dec dword[eax]; jnz @nil  // dec refCount, (dont free it if still used by another S)
     call System.@FreeMem    // this call zeroes eax, ecx & edx
@nil: xor eax, eax
     mov edx, [esp+4]
     test edx, edx; jz @done
     add edx, +4 +4 +1       // ask for more +9 = sizeof(refCnt + refLen + asciiz#0)
     mov eax, [esp]
     call System.@GetMem     // result in eax; ecx=eax
     mov edx, [esp+4]
     add eax, 8              // shift offset to the first char position
     mov dword[eax-4], edx  // length of the string
     mov dword[eax-8], 1    // put RefCount
     mov byte[eax+edx], 0   // asciiz trailing#0
@done: pop edx; mov [edx], eax // temp edx of original eax alias S
     ;                         // put @S[1] alias PChar(S) there
     //  mov eax, edx // turn it back to owner (or you may left it returning PChar(S)
     // i think returning PChar will be more useful, we may forego since the var S now
     // has been properly initialized; this way we dont have to dereference S furthermore
     pop edx; pop ecx        //
end;

const
  Shiftable: set of byte = [1, 2, 4, 8, 16, 32, 64, 128];

procedure __CountSeparators(const eax; BufLen: integer; BlockLen: byte); assembler asm
  // Result in edx; ecx trimmed to byte
  and ecx, 0ffh; cmp ecx, BufLen; jg @tst // if BlockLen >= BufLen, BlockLen zeroed
  xor ecx, ecx
  @tst: test ecx, ecx; jnz @begin // if BlockLen 0; none any separator exists
  //cmovz edx, ecx
  xor edx, edx; ret
  @begin: lea BufLen, BufLen-1;
    // the formula for counting spaces-between is: Buflen-1 div BlockLen
    // (BufLen dec-by-1 to eliminate the overfluous space of modulo-0 result)
    jpe @_div // since 0 has been filtered out. in no way it might be an even-bit's byte
    cmp cl, 5; ja @_more; je @_div
    shr cl, 1; jmp @_count
  @_more: bt dword[Shiftable], ecx; jnc @_div; bsf ecx, ecx
  @_count: shr BufLen, cl; inc ch; shl ch, cl; shr ch, 8; ret
  @_div: push eax; mov eax, edx
     xor edx, edx; div ecx; pop eax; ret //; jmp @end
    //mov eax, BufLen; mov edx, PReciprocalInt
    //mul dword[edx+ecx*4]; jmp @end
  @end:
end;

function __LStrSetL(var S; const Length): PChar; assembler asm
  push ecx; push ebx; push esi
  mov ebx, eax; mov esi, Length
  mov eax, [ebx]
  sub eax, 8
  add Length, 9
  push eax
  mov eax, esp
  call System.@ReallocMem
  pop eax
  add eax, 8
  mov [ebx], eax
  mov [eax-4], esi
  mov byte[eax+esi], 0
  pop esi; pop ebx; pop ecx
end;

function Reverse(const S: string): string; assembler asm
    test S, S; jg @@Start; ret
  @@Start: push esi; push edi
    mov esi, S; mov eax, @Result

    call System.@LStrClr
    mov edx, [esi-4]; push edx
    call System.@LStrSetLength
    mov ecx, [esp]; mov edi, [eax]
    lea edi, edi+ecx-4
    shr ecx, 2; jz @small
  @Loop:
    mov eax, [esi]; bswap eax; lea esi, esi+4
    mov dword[edi], eax; lea edi, edi-4
    dec ecx; jg @loop
  @small: pop ecx; and ecx, 3
    lea edi, edi+4; jz @done
  @loop2: dec edi
   mov al, byte[esi]; inc esi
   mov byte[edi], al
   dec ecx; jg @loop2

  @done: mov eax, edi

  @end: pop edi; pop esi
  @@Stop:
end;

{
  CountSpaceNeeded algorithm:
  ---------------------------
  note that all options, are quite interdependent with each other,
  thus they are eventuallly will be all tested.

  special cases:
    if delimiter = #0 then output format is undelimited (no separator)
    if blockLen < 1 blockLen will be set to 1 if Delimiter <> #0,
      otherwise for xsBlockWise BlockLen will be set equal with BufLen
      (which also means undelimited)
    if blockLen > bufLen then blockLen will be set equal with bufLen
      (which also means undelimited)

  known:
    BufLen (static)
    BlockLen (modifiable)

  calculated:
    calc: SeparatorCount = (BufLen-1) div BlockLen
    calc: BlockCount = SeparatorCount +1

  calculation procedure
    case xsBlockWise:
      BufLen = ? (static)
      BlockLen = ? (modifiable)
      SeparatorCount = ? (calculate)
      BlockCount = ? (calculate)
      calc: BlockSize = BlockLen * 2
      calc: BlockSpaceNeeded = BlockCount * BlockSize
      calc: SpaceNeeded = BlockSpaceNeeded + SeparatorCount
    esac
    case not xsBlockWise:
      BufLen = ? (static)
      SeparatorCount = ? (calculate)
      calc: SpaceNeeded = BufLen * 2 + SeparatorCount
    esac
  end calculation procedure

  special case1:
    if BLockLen < 1 then
       case xsBlockWise:
         if Delimiter = #0 then
           forced: BlockLen = BufLen
           forced: BlockCount = 1;
           SeparatorCount = 0
         -> SpaceNeeded = 1 * BufLen * 2 + SeparatorCount
         else
           forced: BlockLen = 1
           forced: BlockCount = BufLen;
           SeparatorCount = BufLen - 1
         -> SpaceNeeded = BufLen * 1 * 2 + SeparatorCount
         fi
       esac
       case not xsBlockWise:
         forced: BlockLen = 1
         if Delimiter = #0 then
           SeparatorCount = 0
         else
           SeparatorCount = BufLen -1
         fi
         -> SpaceNeeded = BufLen * 2 + SeparatorCount
       esac
       calc: SpaceNeeded = BufLen * 2 + SeparatorCount
       exit
    fi

  special case2:
    if Delimiter == #0 then
      forced: SeparatorCount = 0
      case BlockWise:
        BlockCount = ?
        BlockSize = BlockLen * 2
        calc: BlockSpaceNeeded = BlockCount * BlockSize
        calc: SpaceNeeded = BlockCount * BlockSize + 0
      esac
      case not xsBlockWise:
        -> SpaceNeeded = BufLen * 2 + 0;
        calc: SpaceNeeded = Buflen * 2
        exit
      esac
    fi
}

procedure __CountSpaceNeeded;
asm
{  usage:
{    calculates the spaces needed by specified    }
{    BufLen, hexStyles and Delimiter              }
{                                                 }
{  see also: CountSpaceNeeded algorithm above     }
{                                                 }
{  input:                                         }
{    -> bl: Delimiter bh: HexStyles {xsBlockWise) }
{    -> edx: BufLen                               }
{    -> ecx: BlockLen                             }
{                                                 }
{  ouput:                                         }
{    <- ecx: Validated BlockLen                   }
{    <- edx: Count Space Needed                   }
{    <- edi: Buflen (original value of edx)       }
{    <- eax: separators count                     }
{            (valid only if Delimiter <> #0)      }
{    <- bl=0: modified only if BlockLen forced    }
{             to be equal with BufLen             }
{                                                 }
{  registers modified: eax, edx, ecx, edi, bl     }
{                                                 }

  mov edi, edx; lea eax,edx-1; shl edx,1
  cmp ecx,edi; jb @tst1; mov ecx,edi; mov bl, 0; jmp @LSetDone

  @tst1: cmp ecx, 1; jg @tst_dlm; je @_adl
    xor ecx, ecx; inc cl //; jmp @_adl
    test bl, bl; jnz @_adx
    test bh, 1 shl xsBlockWise; jz @LSetDone
    mov ecx,edi; jmp @LSetDone

  @tst_dlm: test bl, bl; jnz @SetLn
  test bh, 1 shl xsBlockWise; jz @LSetDone

  @SetLn:
    cmp ecx, 80h; je @_shift; ja @_div; jnp @_div
    cmp ecx, 1 shl 2 +1; je @_div; ja @_shift
    push ecx; shr ecx, 1; jnz @_count
  @LSet2p: pop ecx; jmp @_adx

  @_shift: bt dword[Shiftable], ecx; jnc @_div
  @_shiftable: push ecx; bsf ecx, ecx
  @_count: shr eax, cl
    test bh, 1 shl xsBlockWise; jz @LSet2p
    lea edx, eax+1;
    shl edx, cl; shl edx, 1
    pop ecx; jmp @_adl

  @_div: xor edx, edx; div ecx // eax = mid-separators count
    test bh, 1 shl xsBlockWise; jnz @_dm
      lea edx, edi*2+eax; jmp @LSetDone
  @_dm: push eax
    inc eax                 // block count
    lea edx, [ecx*2]          // block size (blocklen*2 //+1space)
    mul edx; mov edx, eax; pop eax
  @_adl: test bl, bl; jz @LSetDone
  @_adx: add edx, eax; jmp @LSetDone
  @LSetDone:
end;

function hexs_countspace(const Buffer: pointer; const BufLen: integer; const BlockLen: integer;
const Delimiter: char; const HexStyles: THexStyles): integer; overload asm
  @Start: test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  @e:xor eax, eax; jmp @Stop
  //@begin: pushad; pushad //AX=28; DX=24; CX=20; BX=16; SP=12; BP=8; SI=4; DI=0
  @begin: push esi; push edi; push ebx
  xor ebx, ebx; mov bl, Delimiter; mov bh, HexStyles
  mov esi, Buffer; //mov edi, BufLen
  call __CountSpaceNeeded
  mov eax,edx
  @end: pop ebx; pop edi; pop esi
  @Stop:
end;

const
  TABLE_HEXDIGITS: packed array[0..31] of char = '0123456789ABCDEF0123456789abcdef';
  { // interprets buffer as one big hex number (read from last byte as in big endian mode)     }
  { // this is option xsReversed in THexStyle, (note that the default option is not Reversed)  }
  { // not directly used/implemented. used as a building block for hexs_n.                     }
  { // see also: hexs_b & hexn                                                                 }
  { function hexs_n(const Buffer: pointer = nil; const BufLen: integer = 0;                    }
  { const Lowercase: boolean = FALSE): string; asm                                             }
  {   test Buffer, Buffer; jz @Stop                                                            }
  {   test BufLen, -1; jg @begin                                                               }
  {   xor eax, eax; jmp @Stop;                                                                 }
  {   @begin: push esi; push edi; push ebx                                                     }
  {     mov esi, Buffer; xor ebx, ebx                                                          }
  {     mov bl, LowerCase; and bl,1; shl bl, 4                                                 }
  {     lea ebx, ebx+TABLE_HEXDIGITS                                                           }
  {     lea ecx, edx-1; shl edx, 1                                                             }
  {     mov eax, Result; call __LStrCLSet                                                      }
  {     mov edi, eax                                                                           }
  {     xor eax, eax; xor edx, edx                                                             }
  {   @Loop:                                                                                   }
  {     mov al, esi+ecx; mov dl, al                                                            }
  {     and dl,0fh; mov dl, ebx+edx                                                            }
  {     shr al,04h; mov al, ebx+eax                                                            }
  {     mov [edi], al; mov [edi+1], dl                                                         }
  {     lea edi, edi+2;                                                                        }
  {   dec ecx; jge @Loop // difference with hexs_b                                             }
  {   @end: pop ebx; pop edi; pop esi                                                          }
  {   @Stop:                                                                                   }
  { end;                                                                                       }
  {                                                                                            }
  { // interprets buffer as one big hex number (read from last byte as in big endian mode)     }
  { // this is option xsReversed in THexStyle, (note that the default option is not Reversed)  }
  { // not directly used/implemented. used as a building block for hexs_n.                     }
  { // see also: hexs_b & hexn                                                                 }
  { function hexs_nswap(const Buffer: pointer = nil; const BufLen: integer = 0;                }
  { const Lowercase: boolean = FALSE): string; asm                                             }
  {   test Buffer, Buffer; jz @Stop                                                            }
  {   test BufLen, -1; jg @begin                                                               }
  {   xor eax, eax; jmp @Stop;                                                                 }
  {   @begin: push esi; push edi; push ebx                                                     }
  {     mov esi, Buffer; xor ebx, ebx                                                          }
  {     mov bl, LowerCase; and bl,1; shl bl, 4                                                 }
  {     lea ebx, ebx+TABLE_HEXDIGITS                                                           }
  {     lea ecx, edx-1; shl edx, 1                                                             }
  {     mov eax, Result; call __LStrCLSet                                                      }
  {     mov edi, eax                                                                           }
  {     xor eax, eax; xor edx, edx                                                             }
  {   @Loop:                                                                                   }
  {     mov al, esi+ecx; mov dl, al                                                            }
  {     and dl,0fh; mov dl, ebx+edx                                                            }
  {     shr al,04h; mov al, ebx+eax                                                            }
  {     mov [edi], dl; mov [edi+1], al // the only difference with noswap                      }
  {     lea edi, edi+2;                                                                        }
  {   dec ecx; jge @Loop // difference with hexs_b                                             }
  {   @end: pop ebx; pop edi; pop esi                                                          }
  {   @Stop:                                                                                   }
  { end;                                                                                       }
  {                                                                                            }
  { // read and interprets buffer byte-per-byte (read from the first byte).                    }
  { // this is the default mode in THexStyles (xsReversed = FALSE)                             }
  { // not directly used/implemented. used as a building block for hexs_b.                     }
  { // see also: hexs_n & hexb                                                                 }
  { function hexs_b(const Buffer: pointer = nil; const BufLen: integer = 0;                    }
  { const Lowercase: boolean = FALSE): string; asm                                             }
  {   test Buffer, Buffer; jz @Stop                                                            }
  {   test BufLen, -1; jg @begin                                                               }
  {   xor eax, eax; jmp @Stop;                                                                 }
  {   @begin: push esi; push edi; push ebx                                                     }
  {     mov esi, Buffer; xor ebx, ebx                                                          }
  {     mov bl, LowerCase; and bl,1; shl bl, 4                                                 }
  {     lea ebx, ebx+TABLE_HEXDIGITS                                                           }
  {     lea ecx, edx-1; shl edx, 1                                                             }
  {     mov eax, Result; call __LStrCLSet                                                      }
  {     mov edi, eax                                                                           }
  {     xor eax, eax; xor edx, edx                                                             }
  {     lea esi, esi+ecx; neg ecx // different with hexs_n                                     }
  {   @Loop:                                                                                   }
  {     mov al,esi+ecx; mov dl, al                                                             }
  {     and dl,0fh; mov dl, ebx+edx                                                            }
  {     shr al,04h; mov al, ebx+eax                                                            }
  {     mov [edi], al; mov [edi+1], dl //different with Swap                                   }
  {     lea edi, edi+2;                                                                        }
  {     inc ecx; jle @Loop // different with hexs_n                                            }
  {   @end: pop ebx; pop edi; pop esi                                                          }
  {   @Stop:                                                                                   }
  { end;                                                                                       }
  {                                                                                            }
  { // read and interprets buffer byte-per-byte (read from the first byte).                    }
  { // this is the default mode in THexStyles (xsReversed = FALSE)                             }
  { // not directly used/implemented. used as a building block for hexs_b.                     }
  { // see also: hexs_n & hexb                                                                 }
  { function hexs_bswap(const Buffer: pointer = nil; const BufLen: integer = 0;                }
  { const Lowercase: boolean = FALSE): string; asm                                             }
  {   test Buffer, Buffer; jz @Stop                                                            }
  {   test BufLen, -1; jg @begin                                                               }
  {   xor eax, eax; jmp @Stop;                                                                 }
  {   @begin: push esi; push edi; push ebx                                                     }
  {     mov esi, Buffer; xor ebx, ebx                                                          }
  {     mov bl, LowerCase; and bl,1; shl bl, 4                                                 }
  {     lea ebx, ebx+TABLE_HEXDIGITS                                                           }
  {     lea ecx, edx-1; shl edx, 1                                                             }
  {     mov eax, Result; call __LStrCLSet                                                      }
  {     mov edi, eax                                                                           }
  {     xor eax, eax; xor edx, edx                                                             }
  {     lea esi, esi+ecx; neg ecx // different with hexs_n                                     }
  {   @Loop:                                                                                   }
  {     mov al,esi+ecx; mov dl, al                                                             }
  {     and dl,0fh; mov dl, ebx+edx                                                            }
  {     shr al,04h; mov al, ebx+eax                                                            }
  {     mov [edi], dl; mov [edi+1], al //the only difference with noswap                       }
  {     lea edi, edi+2;                                                                        }
  {     inc ecx; jle @Loop // different with hexs_n                                            }
  {   @end: pop ebx; pop edi; pop esi                                                          }
  {   @Stop:                                                                                   }
  { end;                                                                                       }
  {                                                                                            }

  // not directly used. hexb (along with hexn) provides a building block for _hexa.
  // supported THexStyle option are: xsLowerCase & xsSwapByte (other options are ignored)
  // unfolded, prefer speed of space (i hope :))

function hexb(const Buffer: pointer = nil; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;
asm
  test Buffer, Buffer; jz @Stop; test BufLen, -1; jg @begin
  xor eax, eax; jmp @Stop;
  @begin: push esi; push edi; push ebx
    mov esi, Buffer; xor ebx, ebx
    movzx eax, HexStyles; mov ah, Delimiter; push eax
    test al, 1 shl xsLowerCase; setnz bl; shl bl, 4
    lea ebx, ebx+TABLE_HEXDIGITS
    lea ecx, edx-1; lea edx, [edx*2]
    test ah, ah; jz @LSet; add edx, ecx
    @LSet: mov eax, Result; call __LStrCLSet
    mov edi, eax; pop eax; xor edx, edx
     lea esi, esi+ecx; neg ecx
     test al, 1 shl xsSwapByte; jnz @Swapped
  @NoSwap: test ah, ah; jnz @nsLoopD; xor eax, eax
   @nsLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], al; mov [edi+1], dl  // the only difference with Swap :)
    lea edi, edi+2;
    inc ecx; jle @nsLoop; jmp @done
   @nsLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], al; mov [edi+1], dl; mov [edi+2], ah // the only difference with noSwap :)
    lea edi, edi+3;
    inc ecx; jle @nsLoopD
    mov byte[edi-1],0; jmp @done
  @Swapped: test ah, ah; jnz @swLoopD; xor eax, eax
   @swLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)
    lea edi, edi+2;
    inc ecx; jle @swLoop; jmp @done
   @swLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)
    lea edi, edi+3;
    inc ecx; jle @swLoopD
    mov byte[edi-1],0; jmp @done
  @done:
  @end: pop ebx; pop edi; pop esi
  @Stop:
end;

// not directly used. hexn (along with hexb) provides a building block for _hexa.
// supported THexStyle option are: xsLowerCase & xsSwapByte (other options are ignored)
// unfolded, prefer speed of space (i hope :))

function hexn(const Buffer: pointer = nil; const BufLen: integer = 0;
  const HexStyles: THexStyles = []; const Delimiter: char = #0): string;
asm
  test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  xor eax, eax; jmp @Stop;
   @begin: push esi; push edi; push ebx
    mov esi, Buffer; xor ebx, ebx
    movzx eax, HexStyles; mov ah, Delimiter; push eax
    test al, 1 shl xsLowerCase; setnz bl; shl bl, 4
    lea ebx, ebx+TABLE_HEXDIGITS
    lea ecx, edx-1; lea edx, [edx*2]
    test ah, ah; jz @LSet; add edx, ecx
    @LSet: mov eax, Result; call __LStrCLSet
    mov edi, eax; pop eax; xor edx, edx
     //lea esi, esi+ecx; neg ecx
     test al, 1 shl xsSwapByte; jnz @Swapped
   @NoSwap: test ah, ah; jnz @nsLoopD; xor eax, eax
   @nsLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], al; mov [edi+1], dl
    lea edi, edi+2;
  dec ecx; jge @nsLoop; jmp @done
   @nsLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], al; mov [edi+1], dl; mov [edi+2], ah
    lea edi, edi+3;
  dec ecx; jge @nsLoopD
  mov byte[edi-1],0; jmp @done
   @Swapped: test ah, ah; jnz @swLoopD; xor eax, eax
   @swLoop:
    mov al, [esi+ecx]; mov dl, al
    and dl,0fh; mov dl, ebx+edx
    shr al,04h; mov al, ebx+eax
    mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)
    lea edi, edi+2;
  dec ecx; jge @swLoop; jmp @done
   @swLoopD:
    mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx
    mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx
    mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)
    lea edi, edi+3;
  dec ecx; jge @swLoopD
  mov byte[edi-1],0; jmp @done
   @done:
   @end: pop ebx; pop edi; pop esi
  @Stop:
end;

// INC ECX = 41h  JGE = 7Dh  JG = 7Fh
// DEC ECX = 49h  JLE = 7Eh  JL = 7Ch

// hexs contains all of the functionalities of hexn and hexb plus option to switch
// between those two modes; makes supported features: xsLowerCase, xsSwapByte & xsReverse

function hexs(const Buffer: pointer; const BufLen: integer; const HexStyles: THexStyles;
  const Delimiter: char): string; overload;
asm
  test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  xor eax, eax; jmp @Stop

  @begin: push esi; push edi; push ebx
    mov esi, Buffer; xor ebx, ebx
    movzx eax, Delimiter; mov ah, HexStyles; push eax

    test ah, 1 shl xsLowerCase; setnz bl; shl bl, 4
    lea ebx, ebx+TABLE_HEXDIGITS
    lea ecx, edx-1; shl edx, 1
    test al, al; jz @SetLength
    add edx, ecx

    @SetLength: mov eax, Result; call __LStrCLSet
    mov edi, eax; mov ebp, ecx

    pop ecx; test ch, 1 shl xsReverse; jnz @prepare

      lea esi, esi+ebp; neg ebp

    @prepare: xor eax, eax; xor edx, edx

    @Loop:
      mov al, [esi+ebp]; mov dl, al
      and dl, 0fh; mov dl, ebx+edx
      shr al, 04h; mov al, ebx+eax

      test ch, 1 shl xsSwapByte; jz @nos

      @swp: mov [edi], dl; mov [edi+1], al; jmp @1_ // swap byte/nibble
      @nos: mov [edi], al; mov [edi+1], dl; jmp @1_ // no-swap

      @1_: test cl, cl; jz @2_
        mov [edi+2], cl; lea edi, edi+1
      @2_: lea edi, edi+2

      //test ebp, ebp; jz @done; jl @inc // not a "branch-prediction friendly"
      test ch, 1 shl xsReverse; jz @inc  // reverse means last to first <contrawise> dump Buffer

    @dec: dec ebp; jge @Loop; jmp @Lastb // reverse
    @inc: inc ebp; jle @loop; jmp @Lastb // dump

    @Lastb: test cl, cl; jz @Done
    ; mov byte[edi-1], 0

  @Done:

  @end: pop ebx; pop edi; pop esi
  @Stop:
end;

{  // hexs contains all of the functionalities of hexn and hexb plus option to switch         }
{  // between those two modes; makes supported features: xsLowerCase, xsSwapByte & xsReverse  }
{  function _hexa(const Buffer: pointer; const BufLen: integer; const HexStyles: THexStyles;  }
{  const Delimiter: char): string; overload; asm                                              }
{    test Buffer, Buffer; jz @Stop                                                            }
{    test BufLen, -1; jg @begin                                                               }
{    xor eax, eax; jmp @Stop;                                                                 }
{                                                                                             }
{    @begin: push esi; push edi; push ebx                                                     }
{      mov esi, Buffer; xor ebx, ebx                                                          }
{      movzx eax, HexStyles; mov ah, Delimiter; push eax                                      }
{      test al, 1 shl xsLowerCase; setnz bl; shl bl, 4                                        }
{      lea ebx, ebx+TABLE_HEXDIGITS                                                           }
{      lea ecx, edx-1; lea edx, edx*2                                                         }
{      test ah, ah; jz @LSet; add edx, ecx                                                    }
{      @LSet: mov eax, Result; call __LStrCLSet                                               }
{      mov edi, eax; pop eax; xor edx, edx                                                    }
{                                                                                             }
{      test al, 1 shl xsReverse jnz @Reversed                                                 }
{                                                                                             }
{      lea esi, esi+ecx; neg ecx                                                              }
{                                                                                             }
{      test al, 1 shl xsSwapByte; jnz @Swapped                                                }
{    @NoSwap: test ah, ah; jnz @nsLoopD; xor eax, eax                                         }
{      @nsLoop:                                                                               }
{        mov al, [esi+ecx]; mov dl, al                                                        }
{        and dl,0fh; mov dl, ebx+edx                                                          }
{        shr al,04h; mov al, ebx+eax                                                          }
{        mov [edi], al; mov [edi+1], dl                                                       }
{        lea edi, edi+2;                                                                      }
{      inc ecx; jle @nsLoop; jmp @done // the only difference with reversed Direction         }
{                                                                                             }
{      @nsLoopD:                                                                              }
{        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx                                       }
{        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx                                       }
{        mov [edi], al; mov [edi+1], dl; mov [edi+2], ah                                      }
{        lea edi, edi+3;                                                                      }
{      inc ecx; jle @nsLoopD // the only difference with reversed Direction                   }
{      mov byte[edi-1],0; jmp @done                                                           }
{                                                                                             }
{    @Swapped: test ah, ah; jnz @swLoopD; xor eax, eax                                        }
{                                                                                             }
{      @swLoop:                                                                               }
{        mov al, [esi+ecx]; mov dl, al                                                        }
{        and dl,0fh; mov dl, ebx+edx                                                          }
{        shr al,04h; mov al, ebx+eax                                                          }
{        mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)                 }
{        lea edi, edi+2;                                                                      }
{      inc ecx; jle @swLoop; jmp @done // the only difference with reversed Direction         }
{                                                                                             }
{      @swLoopD:                                                                              }
{        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx                                       }
{        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx                                       }
{        mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)}
{        lea edi, edi+3;                                                                      }
{      inc ecx; jle @swLoopD                                                                  }
{      mov byte[edi-1],0; jmp @done                                                           }
{                                                                                             }
{    @Reversed: test al, 1 shl xsSwapByte; jnz @rSwapped                                      }
{                                                                                             }
{    @rNoSwap: test ah, ah; jnz @rnsLoopD; xor eax, eax                                       }
{                                                                                             }
{      @rnsLoop:                                                                              }
{        mov al, [esi+ecx]; mov dl, al                                                        }
{        and dl,0fh; mov dl, ebx+edx                                                          }
{        shr al,04h; mov al, ebx+eax                                                          }
{        mov [edi], al; mov [edi+1], dl                                                       }
{        lea edi, edi+2;                                                                      }
{      dec ecx; jge @rnsLoop; jmp @rdone // the only difference with non-reversed Direction   }
{                                                                                             }
{      @rnsLoopD:                                                                             }
{        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx                                       }
{        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx                                       }
{        mov [edi], al; mov [edi+1], dl; mov [edi+2], ah                                      }
{        lea edi, edi+3;                                                                      }
{      dec ecx; jge @rnsLoopD // the only difference with non-reversed Direction              }
{      mov byte[edi-1],0; jmp @rdone                                                          }
{                                                                                             }
{    @rSwapped: test ah, ah; jnz @rswLoopD; xor eax, eax                                      }
{                                                                                             }
{      @rswLoop:                                                                              }
{        mov al, [esi+ecx]; mov dl, al                                                        }
{        and dl,0fh; mov dl, ebx+edx                                                          }
{        shr al,04h; mov al, ebx+eax                                                          }
{        mov [edi], dl; mov [edi+1], al // the only difference with noSwap :)                 }
{        lea edi, edi+2;                                                                      }
{      dec ecx; jge @rswLoop; jmp @rdone // the only difference with non-reversed Direction   }
{                                                                                             }
{      @rswLoopD:                                                                             }
{        mov dl, [esi+ecx]; shr dl,04h; mov al, ebx+edx                                       }
{        mov dl, [esi+ecx]; and dl,0fh; mov dl, ebx+edx                                       }
{        mov [edi], dl; mov [edi+1], al; mov [edi+2], ah // the only difference with NoSwap :)}
{        lea edi, edi+3;                                                                      }
{      dec ecx; jge @rswLoopD // the only difference with non-reversed Direction              }
{      mov byte[edi-1],0; jmp @rdone                                                          }
{                                                                                             }
{    @done:                                                                                   }
{    @rdone:                                                                                  }
{                                                                                             }
{    @end: pop ebx; pop edi; pop esi                                                          }
{    @Stop:                                                                                   }
{  end;                                                                                       }
{                                                                                             }
//LEGACY_CODE
//function hexs_byte(const Buffer: pointer; const BufLen: integer; const Delimiter: Char = #0;
//const HexStyles: THexStyles = []): string; overload asm
//  test Buffer, Buffer; jz @Stop
//  //and BlockLen, 0ffh; jz @e
//  test BufLen, -1; jg @Start
//  @e: xor eax,eax; jmp @Stop
//  @Start: push esi; push edi; push ebx
//    xor ebx, ebx; test HexStyles, 1 shl xsLowerCase; setnz bl
//    shl bl, 4; lea ebx, ebx+TABLE_HEXDIGITS
//    push BufLen; shl BufLen, 1
//    and ecx, 0ffh; push ecx; jz @SetL
//    shr Buflen, 1; lea BufLen, BufLen*2+BufLen-1
//  @SetL: mov esi, Buffer; mov eax, Result
//    call __LStrCLSet; mov edi, eax; xor eax, eax
//    test HexStyles, 1 shl xsSwapByte; jnz @@ByteSwap
//
//    cmp cl,0;  mov ecx, [esp+4]; mov edx, eax; jnz @Ch1
//  @Ch0: shr ecx, 1; jz @r1
//    @Ch0Loop: mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov ah, byte[ebx+eax]
//      shr dl, 04h; mov al, byte[ebx+edx]; rol eax, 10h
//
//      mov dl, byte[esi+1]; lea esi, esi+2; mov al, dl
//      and dl, 0fh; mov ah, byte[ebx+edx]
//      mov dl, al; shr dl, 4; mov al, byte[ebx+edx]
//      rol eax, 10h; mov dword[edi], eax; lea edi, edi+4
//      dec ecx; jg @Ch0Loop; jmp @r1
//
//  @Ch1: shr ecx, 1; jz @r1
//    @Ch1Loop: mov dl, byte[esi]; mov eax, edx
//      shr al, 04h; mov al, byte[ebx+eax]; ror eax, 8
//      and dl, 0fh; mov al, byte[ebx+edx]
//      mov ah, byte[esp]; rol eax, 8
//      mov dword[edi], eax; lea edi, edi+3
//
//      mov dl, byte[esi+1]; lea esi, esi+2; mov eax, edx
//      shr al, 04h; mov al, byte[ebx+eax]; ror eax, 8
//      and dl, 0fh; mov al, byte[ebx+edx]
//      mov ah, byte[esp]; rol eax, 8
//      mov dword[edi], eax; lea edi, edi+3
//      dec ecx; jg @Ch1Loop; mov byte[edi-1],0
//
//    @r1: pop ecx; pop edx; test dl,1; jz @done
//      mov dl, byte[esi]; mov eax, edx
//      shr al, 04h; mov al, byte[ebx+eax]
//      and dl, 0fh; mov ah, byte[ebx+edx]
//      mov word[edi], ax; jmp @done
//
//  @@ByteSwap:
//    cmp cl,0;  mov ecx, [esp+4]; mov edx, eax; jnz @_Ch1
//  @_Ch0: shr ecx, 1; jz @_r1
//    @_Ch0Loop: mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]
//      shr dl, 4; mov ah, byte[ebx+edx]; rol eax, 10h
//      mov dl, byte[esi+1]; lea esi, esi+2; mov al, dl
//      shr dl, 4; mov ah, byte[ebx+edx]
//      mov dl, al; and dl, 0fh; mov al, byte[ebx+edx]
//      rol eax, 10h; mov dword[edi], eax; lea edi, edi+4
//      dec ecx; jg @_Ch0Loop; jmp @_r1
//
//  @_Ch1: shr ecx, 1; jz @_r1
//    @_Ch1Loop: mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]; ror eax, 8
//      shr dl, 4; mov al, byte[ebx+edx]
//      mov ah, byte[esp]; rol eax, 8
//      mov dword[edi], eax; lea edi, edi+3
//
//      mov dl, byte[esi+1]; lea esi, esi+2; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]; ror eax, 8
//      shr dl, 4; mov al, byte[ebx+edx]
//      mov ah, byte[esp]; rol eax, 8
//      mov dword[edi], eax; lea edi, edi+3
//      dec ecx; jg @_Ch1Loop; mov byte[edi-1],0
//
//    @_r1: pop ecx; pop edx; test dl,1; jz @done
//      mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]
//      shr dl, 4; mov ah, byte[ebx+edx]
//      mov word[edi], ax; jmp @done
//
//  @done: pop ebx; pop edi; pop esi
//  @Stop:
//end;

//LEGACY_CODE
//function hexs(const Buffer: pointer; const BufLen: integer; const Delimiter: Char = #0;
//  UpperCase: boolean = TRUE): string; overload;
//var hs: tHexStyles;
//begin
//  hs := [];
//  if not UpperCase then include(hs, xsLowerCase);
//  Result := hexn(Buffer, BufLen, hs, Delimiter);
//  test Buffer, Buffer; jz @Stop
//  //and BlockLen, 0ffh; jz @e
//  test BufLen, -1; jg @Start
//  @e: xor eax,eax; jmp @Stop
//  @Start: push esi; push edi; push ebx
//    xor ebx, ebx; and LowerCase, 1; setnz bl
//    shl bl, 4; lea ebx, ebx+TABLE_HEXDIGITS
//    push BufLen; shl BufLen, 1
//    and ecx, 0ffh; mov LowerCase, Delimiter; jz @SetL
//    shr Buflen, 1; lea BufLen, BufLen*2+BufLen-1
//  @SetL: mov esi, Buffer; mov eax, Result
//    call __LStrCLSet; mov edi, eax; xor eax, eax
//    cmp cl,0;  mov ecx, [esp]; mov edx, eax; jnz @Ch1
//  @Ch0: shr ecx, 1; jz @r1
//    @Ch0Loop: mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]
//      shr dl, 4; mov ah, byte[ebx+edx]; rol eax, 10h
//      mov dl, byte[esi+1]; lea esi, esi+2; mov al, dl
//      shr dl, 4; mov ah, byte[ebx+edx]
//      mov dl, al; and dl, 0fh; mov al, byte[ebx+edx]
//      rol eax, 10h; mov dword[edi], eax; lea edi, edi+4
//      dec ecx; jg @Ch0Loop; jmp @r1
//
//  @Ch1: shr ecx, 1; jz @r1
//    @Ch1Loop: mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]; ror eax, 8
//      shr dl, 4; mov al, byte[ebx+edx]
//      mov ah, LowerCase; rol eax, 8
//      mov dword[edi], eax; lea edi, edi+3
//
//      mov dl, byte[esi+1]; lea esi, esi+2; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]; ror eax, 8
//      shr dl, 4; mov al, byte[ebx+edx]
//      mov ah, LowerCase; rol eax, 8
//      mov dword[edi], eax; lea edi, edi+3
//      dec ecx; jg @Ch1Loop; mov byte[edi-1],0
//
//    @r1: pop edx; test dl,1; jz @done
//      mov dl, byte[esi]; mov eax, edx
//      and al, 0fh; mov al, byte[ebx+eax]
//      shr dl, 4; mov ah, byte[ebx+edx]
//      mov word[edi], ax
//
//  @done: pop ebx; pop edi; pop esi
//  @Stop:
//end;

//const _AX = 28; _DX = 24; _CX = 20; _BX = 16; _SP = 12; _BP = 8; _SI = 4; _DI = 0;
//
//type //from typInfo
//  TOrdType = (otSByte, otUByte, otSWord, otUWord, otSLong, otULong);

function hexs_ord_inprogress_(const Buffer: pointer; const BufLen: integer; BlockLen: integer;
Delimiter: char; const HexStyles: THexStyles): integer; overload asm
  @Start: test Buffer, Buffer; jz @Stop
  test BufLen, -1; jg @begin
  @e:xor eax, eax; jmp @Stop
  @begin: pushad; pushad
  //AX:28, DX:24, CX:20, BX:16, SP:12, BP:08, SI:04, DI:00
  mov esi, Buffer;
  xor ebx, ebx; test HexStyles, 1 shl xsLowerCase; setnz bl
  shl bl, 4; lea ebx, TABLE_HEXDIGITS+ebx
  //push [ebx];push [ebx+4];push [ebx+8];push [ebx+12];
  mov eax,[ebx]; mov [esp],eax; mov eax,[ebx+4]; mov [esp+4],eax
  mov eax,[ebx+8]; mov [esp+8],eax; mov eax,[ebx+12]; mov [esp+12],eax

  mov bl, Delimiter; mov bh, HexStyles
  call __CountSpaceNeeded
  mov Delimiter, bl

  @SetL: mov eax, Result; call __LStrCLSet; push edi
   xor edx, edx; test bh, bh;
   mov ebx, edi; mov edi, eax; mov eax, edx;
   jnz @BLOCKED


  @NONBLOCK: jmp @ff_

  @Blocked: cmp ecx, 1; je @NonBlock; jg @BlockN
     mov al, Delimiter; test al, al; jnz @bnd

  @Block00: jmp @ff_


  @BlockN: bt dword[HexStyles], xsSwapByte; jc @bnds

  @bnd: jmp @ff_


  @bnds: dec esi // global offset by -1
  @bnds_0: sub ebx, ecx; jle @bnds_l; jz @bnds_l2
  //@bnds_err: xor edx, edx; div edx
  @bnds_g: push esi; push ecx
    @bnds_i:
      mov dl, [esi+ecx]; {dec esi;}
      mov al, dl; and al, 0fh; shr dl, 04h;
      dec ecx;
      mov al, [esp+eax+12]; mov ah, [esp+edx+12]
      mov [edi], ax; lea edi, edi+2
      jg @bnds_i
      mov al, Delimiter; mov byte[edi], al; inc edi
      pop ecx; pop esi; lea esi, esi+ecx
      //sub ebx, ecx; jg @bnds_g  // => equ @bndsn
      jmp @bnds_0

    @bnds_l: add ecx, ebx; jz @bnds_z
    @bnds_l1: inc ebx; mov word[edi], '00'; lea edi, edi+2; jnz @bnds_l1
      //lea esi, esi+ecx
    @bnds_l2:
      mov dl, [esi+ecx]; {dec esi;}
      mov al, dl; and al, 0fh; shr dl, 04h;
      dec ecx;
      mov al, [esp+eax+12]; mov ah, [esp+edx+12]
      mov [edi], ax; lea edi, edi+2
      jg @bnds_l2

  @bnds_z:  mov byte[edi], 0;




  @ff_:
  pop edx
  add esp, 10h

  @end: add esp, 040h
  @Stop:
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Blocks. Moved in from ACommon unit
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Blocks(const S: string; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
const
  MINBLOCKLEN: integer = 1;
var
  i, j, k, l, r: integer;
  prefix, suffix: string;
begin
  l := length(S);
  k := SkipPrefixLength + SkipSuffixLength;
  if (delimiter = '') or (l <= 1) or (SkipPrefixLength < 0) or (SkipSuffixLength < 0) or (l - k <= 1) then
    Result := S
  else begin
    if SkipPrefixLength > 0 then
      prefix := copy(S, 1, SkipPrefixLength);
    if SkipSuffixLength > 0 then
      suffix := copy(S, l - k + 1, SkipSuffixLength);
    Result := copy(S, SkipPrefixLength + 1, l - k);
    j := Max(word(BlockLen), MINBLOCKLEN); // max.65535

    l := length(Result);
    i := l div j;
    if (l mod j = 0) then
      dec(i);

    if LeftWise then
      for r := i downto 1 do
        insert(delimiter, Result, (r * j) + 1)
    else begin
      for r := i downto 1 do
        insert(delimiter, Result, length(Result) - (r * j) + 1);
    end;

    if SkipPrefixLength > 0 then
      Result := prefix + Result;
    if SkipSuffixLength > 0 then
      Result := Result + suffix;
  end;
end;

function Blocks(const I: integer; const delimiter: string = SPACE; const BlockLen: integer = 4;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(IntoStr(I), delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

function Blocks(const S: string; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(S, delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

function Blocks(const I: integer; const BlockLen: integer; const delimiter: string = SPACE;
  const LeftWise: Boolean = FALSE; //const Interval: integer = 1;
  const SkipPrefixLength: integer = 0; const SkipSuffixLength: integer = 0): string; overload;
begin
  Result := blocks(IntoStr(I), delimiter, BlockLen, LeftWise, SkipPrefixLength, SkipSuffixLength);
end;

const
  zero = CHAR_ZERO; //'0'; //
  dash = CHAR_DASH; //'-'; //

function IntToStr_JOH_IA32_4(Value: integer): string; forward;
function IntToStr64_JOH_IA32_4(Value: Int64): string; forward;

function intoStr(const I: integer; const Digits: integer = 0): string; overload;
var
  n: integer;
begin
  Result := IntToStr64_JOH_IA32_4(I);
  n := length(Result);
  if digits > n then begin
    if I >= 0 then
      Result := StringOfchar(zero, digits - n) + Result
    else
      Result := dash + StringOfChar(zero, digits - n) + Copy(Result, 2, n);
  end;
end;

function intoStr64(const I: Int64; const Digits: integer = 0): string; overload;
var
  n: integer;
begin
  //Str(I: 0, Result); // replaced by fastcode
  Result := IntToStr64_JOH_IA32_4(I);
  n := length(Result);
  if digits > n then begin
    if I >= 0 then
      Result := StringOfchar(zero, digits - n) + Result
    else
      Result := dash + StringOfChar(zero, digits - n) + Copy(Result, 2, n);
  end;
end;

function intoStr(const I: Int64; const Digits: integer = 0): string; overload asm
// Int64 always passed via stack, here eax = Digits and edx = @Result
// note: cardinal type will be treated as Int64, since (high cardinal) > (high integer)
// to overcome this either cast argument to integer, or specify width explicitly
    mov ecx, dword[I.r64.hi]
    test ecx, ecx; jz @testCard0 // MSB = 0, test for cardinality
    cmp ecx, -1; jne @I64 // if MSB = -1, test for sign-extended
  @testSignex:
    mov ecx, dword[I.r64.lo]
    test ecx, ecx; js @I32  // if LSB also negative, call faster I32 instead
    jmp @I64
  @testCard0:
    mov ecx, dword[I.r64.lo]
    test ecx, ecx; jns @I32 // if LSB positive, call faster I32 instead
    //jmp @I64
  @I64:
    PUSH dword[I.r64.hi]; PUSH dword[I.r64.lo]
    call intoStr64
    jmp @end
  @I32:
    mov ecx, Result
    mov edx, Digits
    mov eax, dword[I.r64.lo]
    call intoStr
  @end:
end;

function IntOf(const S: string; const DefaultValue: integer = 0): integer; // lightweight version
var
  e: integer;
begin
  val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function Intf(const S: string; const DefaultValue: integer = 0): integer; // lightweight version
var
  d: double;
  e: integer;
begin
  val(S, d, e);
  if e <> 0 then
    Result := DefaultValue
  else
    Result := trunc(d)
end;

function Intf64(const S: string; const DefaultValue: integer = 0): Int64; // lightweight version
var
  d: double;
  e: integer;
begin
  val(S, d, e);
  if e <> 0 then
    Result := DefaultValue
  else
    Result := trunc(d)
end;

function Str2Int64(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: Int64 = 0): Int64;
  overload;
var
  e: integer;
begin
  if IsHex then begin
    if (S <> '') and (S[1] <> '$') then
      Val('$0' + S, Result, e)
    else
      Val(S, Result, e)
  end
  else
    Val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function Str2Int(const S: string; const IsHex: Boolean = FALSE; const DefaultValue: integer = 0): integer;
  overload;
var
  e: integer;
begin
  //Result := StringToInt64(S, IsHex, DefaultValue);
  if IsHex then
    Val('$0' + S, Result, e)
  else
    Val(S, Result, e);
  if e <> 0 then
    Result := DefaultValue;
end;

function Str2Int(const S: string; const DefaultValue: integer; const IsHex: Boolean = FALSE): integer; overload;
begin
  Result := Str2Int(S, isHex, DefaultValue);
end;

function Str2Int64(const S: string; const DefaultValue: Int64; const IsHex: Boolean = FALSE): Int64; overload;
begin
  Result := Str2Int64(S, isHex, DefaultValue);
end;

function Digitize(const S: string; const Digits: integer; Negative: boolean = FALSE; UpperCase: boolean = YES):
  string;
//function Min(a, b: integer): integer; asm
//  cmp a, b; jle @end
//    mov a, b
//  @end:
//  end;
type
  TNegative = boolean;
  TUpperCase = boolean;
const
  ef = 'f';
  zero = CHAR_ZERO;
  space = CHAR_SPACE;
  UPPING = not ord(space);
  fills: array[TUpperCase, TNegative] of char = ((zero, ef), (zero, char(ord(ef) and UPPING)));

  function firstNonZero: integer;
  var
    fill: char;
  begin
    if S = '' then
      Result := 0
    else if Negative then
      Result := 1
    else begin
      fill := fills[UpperCase, Negative];
      for Result := 1 to length(S) do
        if S[Result] <> fill then
          break
    end;
    //debug:
    //if Result = 0 then
    //  Result := 1;
  end;

var
  L: integer;
begin
  Result := S;
  if Digits > 0 then begin
    L := length(S);
    if Digits < L then
      Result := copy(S, min(L - Digits + 1, firstNonZero), L)
    else if Digits > L then
      Result := stringofchar(fills[UpperCase, Negative], Digits - L) + S
  end;
end;

//LEGACY_CODE: (used for sample implementation only)

function IntoHex(const I: integer; const Digits: byte = sizeof(integer) * 2; UpperCase: boolean = YES): string;
  register overload;
var
  b: integer;
begin
  b := 4;
  if i >= 0 then
    if i <= high(byte) then
      b := 1
    else if i <= high(word) then
      b := 2;
  if UpperCase then
    Result := hexn(@i, b)
  else
    Result := hexn(@i, b, [xsLowerCase]);
  Result := Digitize(Result, Digits, i < 0, UpperCase);
end;

//LEGACY_CODE: (used for sample implementation only)

function IntoHex(const I: Int64; const Digits: byte = sizeof(Int64) * 2; UpperCase: boolean = YES): string;
  register overload;
var
  hs: THexStyles;
begin
  hs := [];
  if not UpperCase then
    include(hs, xsLowerCase);
  //if r64(I).hi<>0 then
  if (I < Low(integer)) or (I > high(integer)) then
    Result := Digitize(hexn(@i, sizeof(Int64), hs), Digits, i < 0)
  else
    Result := intoHex(integer(i), Digits, UpperCase)
end;

//System
//procedure _StrLong(Val, Width: Longint; var S: ShortString);
//procedure _LStrSetLength{var Str: ANSIString; NewLength: integer};
//procedure _LStrFromString(var Dest: ANSIString; const Source: ShortString);
//procedure _LStrOfCharCc: Char; count: integer): ANSIString;

//procedure  _NewAnsiString{Length: Longint};

//procedure UniqueString(var Str: string);
//procedure _LStrAsg{var Dest: ANSIString; Source: ANSIString};
//procedure _LStrLAsg{var Dest: ANSIString; Source: ANSIString};

//LEGACY_CODE
//  function bins_OK(const Buffer: pointer; const BufferLength: integer): string; register overload assembler asm
//  @@Start:
//    or eax, eax; jz @@Stop     // insanity checks
//    or edx, edx; jg @@Begin    // can not exceed 2GB
//    xor eax, eax
//    jmp @@Stop
//  @@Begin:
//    push esi; push edi; push ebx
//    mov esi, Buffer
//    // edx (as well as ecx), usually destroyed by Str operation
//    mov ebx, edx               // BufLen
//    mov eax, Result            // where the result will be stored
//    call System.@LStrClr       // cleared for ease
//    //shl edx, 3
//    lea edx, [ebx*8]           // BufferLength * 8 bits
//    call System.@LStrSetLength // result: new allocation pointer in EAX
//    mov edi, [eax]               // put new allocated ptr of @Result to edi
//
//    push edi
//
//    lea ecx, [ebx*2]
//    mov eax, '0000'; rep stosd
//
//    mov edi, [esp]
//    //mov ecx, ebx               // get bufferlength back to ecx
//    mov Ch, '1'                  // buffer fillin value
//
//  @@Loop: lodsb; mov cl, 8
//
//    @inner:
//      shl al, 1; jnc @_; mov [edi], Ch
//      @_: lea edi, edi+1
//      dec cl; jg @inner
//    dec ebx; jg @@Loop
//
//    pop eax
//
//  @@End: pop ebx; pop edi; pop esi
//  @@Stop:
//end;

function octn(const Buffer: pointer; const BufferLength: integer; const Fold3digits: boolean = FALSE): string;
register overload assembler asm
  @@start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jg @@Begin    // can not exceed 2GB
    xor eax, eax; jmp @@Stop
  @@Begin: push esi; push edi; push ebx
    mov esi, Buffer; mov ebx, BufferLength
    and ecx, 1; mov edi, ecx; jnz @3Fold
  @unfold:// using precise digits count
    lea eax, [ebx*8+2]              // 8n + 2
    mov ecx, 55555555h+1; mul ecx   // = div 3
    jmp @SetL
  @3Fold: // using 3-digits fold
    lea eax, [ebx*8+8]              // 8n + 8
    mov ecx, 1C71C71Ch+1; mul ecx   // = div 9
    mov eax, edx
    xor ecx, ecx; mov cl, 3; mul ecx
    mov edx, eax
  @SetL: mov eax, Result; call __LStrCLSet
    test edi, edi; mov edi, eax; jz @Prep_
    mov word[edi], '00';
  @Prep_:
    mov eax, edi-4; lea edi, edi+eax-1
    dec ebx; lea esi, esi+ebx; neg ebx
    @byte1: mov al, [esi+ebx]//lodsb;
      mov ah,al; movzx edx,al
      shr ah,3; shr dl,6
      and eax,0707h; or ax,'00'; //stosw
      mov [edi],al; mov [edi-1],ah; lea edi, edi-2
      //dec ebx; jge @byte2
      inc ebx; jle @byte2
      mov al,dl
      and al,07h; or al,'0'; //stosb
      mov [edi], al; lea edi,edi-1
      jmp @@Done
    @byte2: mov al, [esi+ebx]//lodsb;
      mov ah,al; mov dh,al
      shL al,2; or dl,al
      shr dh,1; rol edx,16
      mov dl,ah; shr dl,4
      test ah,ah; setl dh
      //dec ebx; jge @byte3
      inc ebx; jle @byte3
      rol edx,16; mov eax,edx;
      and eax,07070707h; or eax,'0000'; //stosd
      bswap eax; mov [edi-3], eax; lea edi,edi-4
      jmp @@Done
    @byte3: mov al, [esi+ebx]//lodsb;
      mov ah,al
      shl al,1; or dh,al; rol edx,16
      and edx,07070707h; or edx,'0000'
      bswap edx; mov [edi-3], edx; lea edi,edi-4
      //mov [edi],edx; lea edi,edi+4
      mov al,ah; shr al,2; shr ah,5
      and ax,0707h; or ax,'00'; //stosw
      mov [edi],al; mov [edi-1],ah; lea edi, edi-2
      //dec ebx; jge @byte1
      inc ebx; jle @byte1
  @@Done: //pop eax
  @@End: pop ebx; pop edi; pop esi
  @@Stop:
  end;

function octb(const Buffer: pointer; const BufferLength: integer): string; register overload assembler asm
  @@start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jg @@Begin    // can not exceed 2GB
    xor eax, eax; jmp @@Stop
  @@Begin: push esi; push edi; push ebx
    mov esi, Buffer; mov ebx, BufferLength
    mov eax, Result; push eax
    call System.@LStrClr       // cleared first to avoid invalid ptr assignment
    lea eax, [ebx*8+2]
    mov ecx,  55555556h; mul ecx // = div 3
    pop eax; call System.@LStrSetLength
    mov edi, [eax]; push eax;
    dec ebx; lea esi, esi+ebx; neg ebx
    @byte1: mov al, [esi+ebx]//lodsb;
      mov ah,al; movzx edx,al
      shr ah,3; shr dl,6
      and eax,0707h; or ax,'00'; stosw
      //dec ebx; jge @byte2
      inc ebx; jle @byte2
      mov al,dl
      and al,07h; or al,'0'; stosb
      jmp @@Done
    @byte2: mov al, [esi+ebx]//lodsb;
      mov ah,al; mov dh,al
      shL al,2; or dl,al
      shr dh,1; rol edx,16
      mov dl,ah; shr dl,4
      test ah,ah; setl dh
      //dec ebx; jge @byte3
      inc ebx; jle @byte3
      rol edx,16; mov eax,edx;
      and eax,07070707h; or eax,'0000'; stosd
      jmp @@Done
    @byte3: mov al, [esi+ebx]//lodsb;
      mov ah,al
      shl al,1; or dh,al; rol edx,16
      and edx,07070707h; or edx,'0000'
      mov [edi],edx; lea edi,edi+4
      mov al,ah; shr al,2; shr ah,5
      and ax,0707h; or ax,'00'; stosw
      //dec ebx; jge @byte1
      inc ebx; jle @byte1
  @@Done: pop eax
  @@End: pop ebx; pop edi; pop esi
  @@Stop:
end;

//BAK
//function octb_OLD(const Buffer: pointer; const BufferLength: integer): string; register overload assembler asm
//  @@start:
//    or eax, eax; jz @@Stop     // insanity checks
//    or edx, edx; jg @@Begin    // can not exceed 2GB
//    xor eax, eax; jmp @@Stop
//  @@Begin: push esi; push edi; push ebx
//    mov esi, Buffer
//    mov ebx, BufferLength
//    mov eax, Result
//    push eax
//    call System.@LStrClr       // cleared first to avoid invalid ptr assignment
//    lea eax, [ebx*8+2]
//    mov ecx,  55555556h; mul ecx // = div 3
//    pop eax
//    call System.@LStrSetLength
//    mov edi, [eax]; push eax
//    @byte1: lodsb; mov ah,al; movzx edx,al
//      shr ah,3; shr dl,6
//      and eax,0707h; or ax,'00'; stosw
//      dec ebx; jg @byte2
//      mov al,dl
//      and al,07h; or al,'0'; stosb
//      jmp @@Done
//    @byte2: lodsb; mov ah,al; mov dh,al
//      shL al,2; or dl,al
//      shr dh,1; rol edx,16
//      mov dl,ah; shr dl,4
//      test ah,ah; setl dh
//      dec ebx; jg @byte3
//      rol edx,16; mov eax,edx;
//      and eax,07070707h; or eax,'0000'; stosd
//      jmp @@Done
//    @byte3: lodsb; mov ah,al
//      shl al,1; or dh,al; rol edx,16
//      and edx,07070707h; or edx,'0000'
//      mov [edi],edx; lea edi,edi+4
//      mov al,ah; shr al,2; shr ah,5
//      and ax,0707h; or ax,'00'; stosw
//      dec ebx; jg @byte1
//
//  @@Done: pop eax
//  @@End: pop ebx; pop edi; pop esi
//  @@Stop:
//end;

function octb(const I: Int64; const Delimiter: string = ''): string; overload;
begin
  Result := Reverse(blocks(octb(@I, 8), Delimiter));
end;

function octb(const I: integer; const Delimiter: string = ''): string; overload;
begin
  Result := Reverse(blocks(octb(@I, 4), Delimiter));
end;

//LEGACY_CODE

function octs(const Buffer: pointer; const BufferLength: integer; const Delimiter: Char = #0): string; register
overload assembler asm
// to add space every 3 digits, uncomments +space: below
// use blocks function for more flexibility
  @@start:
    or eax, eax; jz @@Stop     // insanity checks
    or edx, edx; jg @@Begin    // can not exceed 2GB
    xor eax, eax; jmp @@Stop
  @@Begin: push esi; push edi; push ebx
    mov esi, Buffer
    mov ebx, BufferLength
    mov eax, Result

    push ecx
    call System.@LStrClr       // cleared first to avoid invalid ptr assignment
    lea edx, [ebx*2+ebx]
    mov ecx, [esp]
    test cl, -1; jz @_dlm
    add edx, ebx
    //+ add edx, ebx; push edx     //+space:
    @_dlm:
    call System.@LStrSetLength // edx will be destroyed!
    //+ pop edx                    //+space:
    pop ecx
    mov edi, [eax];
    push eax
    test cl, -1; jnz @@Loop4

  @@Loop3: lodsb; mov ah, al
      and al, $07; or al, '0'; stosb
      mov al, ah; shr al, 3; shr ah, 6
      and ax, $0707; or ax, '00'; stosw
      //+ mov al, '.'; stosb //+space:
    dec ebx; jg @@Loop3; jmp @@_ok
  @@Loop4: lodsb; mov ah, al
      and al, $07; or al, '0'; stosb
      mov al, ah; shr al, 3; shr ah, 6
      and ax, $0707; or ax, '00'; stosw
      //+ mov al, '.'; stosb //+space:
      mov al, cl; stosb
    dec ebx; jg @@Loop4; jmp @@_ok
  @@_ok:
    pop eax
    test cl, -1; jz @@End
    //+ dec edx //+space
    //+ call System.@LStrSetLength //+space, remove trailing dot
    dec edx
    call System.@LStrSetLength //+space, remove trailing dot

  @@End: pop ebx; pop edi; pop esi
  @@Stop:
  end;

// OBSOLETE:
// function octs_b_old1(const I: Int64): string; overload asm
//   mov ecx, I.r64.lo
//   mov edx, I.r64.hi
//   //xchg cl, ch; rol ecx, 16; xchg cl, ch
//   //xchg dl, dh; rol edx, 16; xchg dl, dh
//   bswap ecx; bswap edx
//   push ecx; push edx
//   mov ecx, @Result // @Result is currently in eax
//   mov edx, 8; mov eax, esp
//   call octs
//   pop ecx; pop edx
// end;
//
// function octs_b_old1(const I: integer): string; overload asm
//   //xchg al, ah; rol eax, 16; xchg al, ah
//   bswap eax; push eax
//   mov ecx, @Result  // @Result is currently in edx
//   mov edx, 4; mov eax, esp
//   call octs
//   add esp, 4
// end;

//LEGACY_CODE: (used for sample implementation only)
//function octs(const I: Int64; const Delimiter: string = '.'): string; overload;
//begin
//  Result := Reverse(blocks(octs(@I, 8), Delimiter, 3));
//end;
//
//function octs(const I: integer; const Delimiter: string = '.'): string; overload;
//begin
//  Result := Reverse(blocks(octs(@I, 4), Delimiter, 3));
//end;
//
//function octs_(const I: Int64; const Delimiter: string = '.'): string; overload;
//begin
//  Result := Reverse(blocks(octs(@I, 8), Delimiter, 3));
//end;
//
//function octs_(const I: integer; const Delimiter: string = '.'): string; overload;
//begin
//  Result := Reverse(blocks(octs(@I, 4), Delimiter, 3));
//end;

function binn(const Buffer: pointer; const BufferLength: integer): string; register overload assembler asm
  @@Start:
    or Buffer, Buffer; jz @@Stop     // insanity checks
    or BufferLength, BufferLength; jg @@begin // may not exceed 2GB
    xor eax, eax; ret
  @@Begin: push esi; push edi; push ebx
    push Result
    mov ebx, edx; shl edx, 3 // save BufLen, request BufLen * 8
    mov esi, Buffer
    mov eax, Result; call __LStrCLSet
    mov edi, eax
    lea ecx, ebx-1  // i'd rather using ecx for loss 1 clock
  @@Loop: mov al, [esi+ecx]//lodsb;
      // CPU loves uniform instructions
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; rol ebx, 16
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; //rol ebx, 8

      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; rol edx, 16
      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; //rol edx, 8

      or ebx, '0000'; or edx, '0000'

      mov[edi], edx; mov [edi+4], ebx
      lea edi, [edi+8]
    dec ecx; jge @@Loop;

    pop eax // Result
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

function binb(const Buffer: pointer; const BufferLength: integer): string; register overload assembler asm
  @@Start:
    or Buffer, Buffer; jz @@Stop     // insanity checks
    or BufferLength, BufferLength; jg @@begin // may not exceed 2GB
    xor eax, eax; ret
  @@Begin: push esi; push edi; push ebx
    push Result
    mov ebx, edx; shl edx, 3 // save BufLen, request BufLen * 8
    mov esi, Buffer
    mov eax, Result; call __LStrCLSet
    mov edi, eax
    mov ecx, ebx  // i'd rather using ecx for loss 1 clock
    lea esi, esi+ecx; neg ecx;
  @@Loop: mov al, esi[ecx]//lodsb;
      // CPU loves uniform instructions
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; rol ebx, 16
      shr al,1; setc bh; //rol ebx, 8
      shr al,1; setc bl; //rol ebx, 8

      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; rol edx, 16
      shr al,1; setc dh; //rol edx, 8
      shr al,1; setc dl; //rol edx, 8

      or ebx, '0000'; or edx, '0000'

      mov[edi], edx; mov [edi+4], ebx
      lea edi, [edi+8]
    inc ecx; jl @@Loop

    pop eax // Result
  @@end: pop ebx; pop edi; pop esi
  @@Stop:
end;

//LEGACY_CODE
//function bins(const I: Int64; const BitsWide: integer = 32): string; overload;
//const
//  Ch: array[boolean] of Char = ('0', '1');
//var
//  n, r: integer;
//begin
//  n := getBitsWide(abs(I), BitsWide);
//  setlength(Result, n);
//  fillchar(Result[1], n, '0');
//  for r := n - 1 downto 0 do
//    if (r < 65) and boolean(i shr r and 1) then
//      Result[n - r] := '1';
//end;
//
//function bins(const I: Int64; const blockwidth: integer; const blockdelimiter: char; const BitsWide: integer = 32): string; overload;
//begin
//  Result := blocks(binn(@I, BitsWide), blockdelimiter, blockwidth, FALSE)
//end;
//
//function bins(const I: Int64; const blockdelimiter: char; const BitsWide: integer = 32; const blockwidth: integer = 4): string; overload;
//begin
//  Result := blocks(binn(@I, BitsWide), blockdelimiter, blockwidth, FALSE)
//end;

//OBSOLETE:
// function Hexs(const byte: byte; const uppercase: boolean = YES): string; overload asm
//   and eax, 0ffh
//   push esi
//     push eax
//       test uppercase, 1; mov edx, 0; setz dl
//       shl edx, 4
//       lea esi, TABLE_HEXDIGITS+edx
//
//       mov eax, Result
//       call System.@LStrClr
//       mov edx, 2
//       call System.@LStrSetLength
//       mov eax, [eax]
//
//       mov edx, [esp]
//       shr edx, 4
//       and edx, 0fh
//
//     pop ecx
//     and ecx, 0fh
//
//     mov dl, esi[edx]
//     mov cl, esi[ecx]
//     mov [eax], dl
//     mov [eax+1], cl
//   pop esi
// end;
//
// function Hexs(const word: word; const uppercase: boolean = YES): string; overload asm
//   and eax, 0ffffh
//   push esi
//     push eax
//       test uppercase, 1; mov edx, 0; setz dl
//       shl edx, 4
//       lea esi, TABLE_HEXDIGITS+edx
//
//       mov eax, Result
//       call System.@LStrClr
//       mov edx, 4
//       call System.@LStrSetLength
//       mov eax, [eax]
//
//     pop ecx
//     push ebx
//       mov edx, ecx; shr ecx,4
//       and edx, 0fh; movzx ebx, byte esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       mov [eax], ebx
//
//     pop ebx
// end;
//
// function Hexs(const integer: integer; const uppercase: boolean = YES): string; overload asm
//   //and eax, 0ffffh
//   push esi
//     push eax
//       test uppercase, 1; mov edx, 0; setz dl
//       shl edx, 4
//       lea esi, TABLE_HEXDIGITS+edx
//
//       mov eax, Result
//       call System.@LStrClr
//       mov edx, 8
//       call System.@LStrSetLength
//       mov eax, [eax]
//
//     pop ecx
//     push ebx
//       mov edx, ecx; shr ecx,4
//       and edx, 0fh; movzx ebx, byte esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       mov [eax+4], ebx
//
//       mov edx, ecx; shr ecx,4
//       and edx, 0fh; movzx ebx, byte esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       rol ebx, 8; mov edx, ecx; shr ecx,4
//       and edx, 0fh; mov bl, esi[edx]
//
//       mov [eax], ebx
//
//     pop ebx
//
//   pop esi
// end;
//
//OBSOLETE:
// function Hexs(const I: Int64; const uppercase: boolean = YES): string; overload asm
// //  asm //@Result in stack
//     PUSH ebx
//     lea ebx, TABLE_HEXDIGITS // init ebx with default value
//     test uppercase, 1         // is uppercase flag = YES?
//       jne @skipsetlocase      // nz = YES, then dont bother to kowercase
//     lea ebx, TABLE_HEXDIGITS +16 // uppercase flags = FALSE
//     @skipsetlocase:
//
//     mov eax, I.r64.lo; db $f,$c8   // bswap eax
//     mov I.r64.lo, eax
//
//     mov eax, I.r64.hi; db $f,$c8   // bswap eax
//     mov I.r64.hi, eax
//
//     mov eax, Result           // where the result will be stored
//     call System.@LStrClr      // cleared for ease
//     mov edx, 16//I64Digits        // how much length of str requested
//     call System.@LStrSetLength// result: new allocation pointer in EAX
//     mov edx, [eax]            // eax contains the new allocated pointer -Differ-
//
//     mov eax, I.r64.hi
//     mov ecx, 4; mov ch, al
//
//   @Loop1:
//     shr al, 4
//     and al, $f; xlat
//     mov [edx], al
//     lea edx, edx +1
//
//     mov al, ch; //shr al, 4
//     and al, $f; xlat
//     mov [edx], al
//     lea edx, edx +1
//
//     shr eax, 8
//     mov ch, al
//     dec cl
//     jnz @Loop1
//
//     mov eax, I.r64.lo
//     mov ecx, 4; mov ch, al
//
//   @Loop2:
//     shr al, 4
//     and al, $f; xlat
//     mov [edx], al
//     lea edx, edx +1
//
//     mov al, ch; //shr al, 4
//     and al, $f; xlat
//     mov [edx], al
//     lea edx, edx +1
//
//     shr eax, 8
//     mov ch, al
//     dec cl
//     jnz @Loop2
//
//     pop ebx
//     mov eax, @Result
// end;
// //end;
//
// function Hexs_b(const Buffer: pointer; const BufferLength: integer;
// const Delimiter: Char = #0; const Uppercase: boolean = YES): string; overload asm
// //asm //@Result in stack
//   @@Start:
//     or eax, eax; jz @@Stop     // insanity checks
//     or edx, edx; jg @@Begin//jle @@Stop
//     xor eax, eax
//     jmp @@Stop
//
//   @@Begin:
//     PUSH esi; PUSH edi
//     mov esi, buffer
//     mov edi, bufferlength      // save buflength first!
//
//     shl edx, 1                 // edx = Bufferlength * 2
//     and ecx, $ff               // note: ecx IS delimiter
//     PUSH ecx                   // save it, will be destroyed by LStrSetLength
//
//     cmp ecx, 0; jz @nolimit    // if delim = #0 then skip increase length
//     lea edx, edx+edi           // ~> inc(edx, edi)
//     dec edx                    // we don't need trailing delimiter
//
//   @nolimit:
//     mov eax, Result            // where the result will be stored
//     push edx
//     call System.@LStrClr       // cleared for ease
//     pop edx
//     call System.@LStrSetLength // result: new allocation pointer in EAX
//     //call System.UniqueString;
//                                // ecx, edx destroyed
//
//     mov ecx, edi               // get bufferlength back
//
//     //wrong!mov edi, eax               // WRONG! eax contains the new allocated pointer
//                                // we got the storage as well at once
//     mov edi, [eax]             // eax contains the new allocated pointer -Differ-
//
//     pop edx                    // get delimiter back
//
//     PUSH ebx;
//     lea ebx, TABLE_HEXDIGITS  // get Translation Table
//     test Uppercase, 1; jne @skipsetlocase  // is uppercase flag = YES?
//     lea ebx, TABLE_HEXDIGITS +16 // uppercase flags = FALSE
//
//   @skipsetlocase:
//
//     cmp edx, 0
//     Jz @@WithoutDelimiter
//
//     dec ecx
//     jz @LastByte
//
//     @@WithDelimiter:
//       lodsb                    // load byte to AL
//       mov ah, al               // copy to AH for second nibble translation
//
//       shr al, 4                // extract high nibble
//       xlat; mov [edi], al      // translate and store result
//       mov al, ah; and al, $f   // extract low nibble; validate
//       xlat; mov edi+1, al      // translate and store result
//       mov edi+2, dl            // put delimiter
//       lea edi, edi+3           // inc edi by 3
//       dec ecx; jg @@WithDelimiter
//
//    @LastByte:
//       lodsb                    // load byte to AL
//       mov ah, al               // copy to AH for second nibble translation
//
//       shr al, 4                // extract high nibble
//       xlat; mov [edi], al      // translate and store result
//       mov al, ah; and al, $f   // extract low nibble; validate
//       xlat; mov edi+1, al      // translate and store result
//       //we donot need these anymore...
//       //lea edi, edi+3           // inc edi by 3
//       //mov edi+2, dl            // put delimiter
//       //dec ecx; jg @@WithDelimiter
//       jmp @@Done
//
//     @@WithoutDelimiter:
//       lodsb                    // load byte to AL
//       mov ah, al               // copy to AH for second nibble translation
//
//       shr al, 4                // extract high nibble
//       xlat; mov [edi], al      // translate and store result
//       mov al, ah; and al, $f   // extract low nibble; validate
//       xlat; mov edi+1, al      // translate and store result
//       //mov edi+2, dl            // put delimiter
//       //lea edi, edi+3           // inc edi by 3
//       lea edi, edi+2           // inc edi only 2 in this block
//       dec ecx; jg @@WithoutDelimiter
//       jmp @@Done
//
//     @@Done:pop ebx; pop edi; pop esi
//     mov eax, @Result
//   @@Stop:
// end;
//
// //function Hexs(const Buffer: pointer; const BufferLength: integer;
// //  const Uppercase: boolean; const Delimiter: Char = #0): string; overload;
// //begin
// //  Result := Hexs(Buffer, BufferLength, Delimiter, Uppercase);
// //end;

const
  hexCharset: set of char = HEXDIGITS;
  ordSuffix: set of char = ['b', 'B', 'h', 'H', 'o', 'O'];

function bintoi(const S: string; out errCode: integer): integer; overload assembler asm
  mov dword[errCode], 10h
  test S, S; jz @@err1
  mov ecx, [S-4]
  cmp ecx, 2; jl @@err2
  movzx ecx, byte[S+ecx-1]
  bt dword[ordSuffix], ecx; jc @@Start

@@err3: add dword[errCode], 10h
@@err2: add dword[errCode], 10h
@@err1: ret

@@Start:
  push esi; push edi; push ebx; push errCode
  lea esi, S-2; mov edi, S-4
  xor eax, eax; xor ebx, ebx; xor edx, edx

  or cl, 20h // oops.. i forgot :(

@loop_0:
  inc esi; dec edi
  cmp byte[esi+1], '+'; jz @loop_0
  cmp byte[esi+1], '-'; jne @getLoop
  xor bl, 1; jmp @loop_0

@getLoop: test edi, edi; mov dl, 4; jz @@err10
  cmp cl, 'h'; je @hLoop
  cmp cl, 'o'; je @oLoop

@bLoop: inc esi; dec edi; jl @ntos_ah
  mov dl, [esi]
  cmp dl, '0'; je @bcount
  cmp dl, '1'; je @bcount
  bt dword[ordDelimiters], dx; jb @bLoop
  mov dl, 5; jmp @@err10

@bCount: sub dl, '0'
  lea eax, [eax*2+edx]; jmp @bLoop

@oLoop: inc esi; dec edi; jl @ntos_ah
  mov dl, [esi]
  cmp dl, '0'; jb @ck2
  cmp dl, '7'; jbe @ocount

@ck2: bt dword[ordDelimiters], dx; jb @oLoop
  mov dl, 6; jmp @@err10

@oCount: sub dl, '0'
  lea eax, [eax*8+edx]; jmp @oLoop

@hLoop: inc esi; dec edi; jl @ntos_ah
  mov dl, [esi]
  bt dword[HexCharset], dx; jb @hCount
  bt dword[ordDelimiters], dx; jb @hLoop
  mov dl, 7; jmp @@err10

@hCount:
  cmp dl, '9'; jbe @base0
  or dl, 20h
  sub dl, 'a'-'0'-10

@base0:
  sub dl, '0'
  shl eax, 4; add eax, edx
  jmp @hLoop

@@err10: shl edx,8; add edx, esi
mov ebx, [esp]; mov [ebx], edx; jmp @end

@ntos_ah:
  and ebx, 1; neg ebx
  xor eax, ebx
  sub eax, ebx
  mov ebx, [esp]; mov dword[ebx], 0
@end: pop ebx; pop ebx; pop edi; pop esi
end;

function bintoi64(const S: string; out errCode: integer): Int64; overload assembler asm
  mov dword[errCode], 10h
  test S, S; jz @@err1
  mov ecx, [S-4]
  cmp ecx, 2; jl @@err2
  movzx ecx, byte[S+ecx-1]
  bt dword[ordSuffix], ecx; jc @@Start

@@err3: add dword[errCode], 10h
@@err2: add dword[errCode], 10h
@@err1: ret

@@Start:
  push esi; push edi; push ebx; push errCode
  lea esi, S-2; mov edi, S-4
  xor eax, eax; xor edx, edx; xor ebx, ebx

  or cl, 20h // oops.. i forgot :(

@loop_0:
  inc esi; dec edi
  cmp byte[esi+1], '+'; jz @loop_0
  cmp byte[esi+1], '-'; jne @getLoop
  xor bl, 1; jmp @loop_0

@getLoop: test edi,edi; mov bh, 4h; jz @@err10
  cmp cl, 'h'; je @hLoop
  cmp cl, 'o'; je @oLoop

@bLoop: inc esi; dec edi; jl @ntos_ah
  mov cl, [esi]
  cmp cl, '0'; je @bcount
  cmp cl, '1'; je @bcount
  bt dword[ordDelimiters], dx; jb @bLoop
  mov bh, 5h; jmp @@err10

@bCount: sub cl, '0'
  shl edx, 1; shl eax,1
  adc edx, 0; or eax, ecx; jmp @bLoop

@oLoop: inc esi; dec edi; jl @ntos_ah
  mov cl, [esi]
  cmp cl, '0'; jb @ck2
  cmp cl, '7'; jbe @ocount

@ck2: bt dword[ordDelimiters], cx; jb @oLoop
  mov bh, 6h; jmp @@err10

@oCount: sub cl, '0'
  shld edx, eax, 3; lea eax, [eax*8+ecx]; jmp @oLoop

@hLoop: inc esi; dec edi; jl @ntos_ah
  mov cl, [esi]
  bt dword[HexCharset], cx; jb @hCount
  bt dword[ordDelimiters], cx; jb @hLoop
  mov bh, 7h; jmp @@err10

@hCount: cmp cl, '9'; jbe @base0
  or cl, 20h; sub cl, 'a'-'0'-10

@base0: sub cl, '0'
  shld edx, eax, 4; shl eax, 4
  or eax, ecx; jmp @hLoop

@@err10: movzx edx, bh; shl edx,8; add edx, esi
mov ecx, [esp]; mov [ecx], ebx; jmp @end

@ntos_ah: xor ecx, ecx; and ebx, 1
  mov ebx, [esp]; mov [ebx], ecx; jz @end
  neg eax; adc edx,0; neg edx

@end: pop ebx; pop ebx; pop edi; pop esi
@@Stop:
end;

function bintoi(const S: string): integer; overload assembler asm
  push edx; mov edx, esp
  call bintoi
  pop edx
  test edx, edx; jz @done
  mov eax, 1 shl 31
 @done:
end;

function bintoi64(const S: string): Int64; overload assembler asm
  push edx; mov edx, esp
  call bintoi64
  pop ecx
  test ecx, ecx; jz @done
  xor eax, eax
  mov edx, 1 shl 31
 @done:
end;

function setBit(const BitNo, I: integer): integer; overload;
begin
  Result := I or (1 shl BitNo);
end;

function isBitSet(const BitNo, I: integer): Boolean; overload;
begin
  Result := (I and (1 shl BitNo)) <> 0;
end;

function ResetBit(const BitNo, I: integer): integer; overload;
begin
  Result := I and ((1 shl BitNo) xor -1);
end;

function ToggleBit(const BitNo, I: integer): integer; overload;
begin
  Result := I xor (1 shl BitNo);
end;

function setBit(const BitNo: integer; const I: Int64): Int64; overload;
begin
  Result := I or (Int64(1) shl BitNo);
end;

function isBitSet(const BitNo: integer; const I: Int64): boolean; overload;
begin
  Result := (I and (Int64(1) shl BitNo)) <> 0;
end;

function ResetBit(const BitNo: integer; const I: Int64): Int64; overload;
begin
  Result := I and ((Int64(1) shl BitNo) xor Int64(-1));
end;

function ToggleBit(const BitNo: integer; const I: Int64): Int64; overload;
begin
  Result := I xor (Int64(1) shl BitNo);
end;

const
  RevBits: array[byte] of byte = (
    $00, $80, $40, $C0, $20, $A0, $60, $E0, $10, $90, $50, $D0, $30, $B0, $70, $F0,
    $08, $88, $48, $C8, $28, $A8, $68, $E8, $18, $98, $58, $D8, $38, $B8, $78, $F8,
    $04, $84, $44, $C4, $24, $A4, $64, $E4, $14, $94, $54, $D4, $34, $B4, $74, $F4,
    $0C, $8C, $4C, $CC, $2C, $AC, $6C, $EC, $1C, $9C, $5C, $DC, $3C, $BC, $7C, $FC,
    $02, $82, $42, $C2, $22, $A2, $62, $E2, $12, $92, $52, $D2, $32, $B2, $72, $F2,
    $0A, $8A, $4A, $CA, $2A, $AA, $6A, $EA, $1A, $9A, $5A, $DA, $3A, $BA, $7A, $FA,
    $06, $86, $46, $C6, $26, $A6, $66, $E6, $16, $96, $56, $D6, $36, $B6, $76, $F6,
    $0E, $8E, $4E, $CE, $2E, $AE, $6E, $EE, $1E, $9E, $5E, $DE, $3E, $BE, $7E, $FE,
    $01, $81, $41, $C1, $21, $A1, $61, $E1, $11, $91, $51, $D1, $31, $B1, $71, $F1,
    $09, $89, $49, $C9, $29, $A9, $69, $E9, $19, $99, $59, $D9, $39, $B9, $79, $F9,
    $05, $85, $45, $C5, $25, $A5, $65, $E5, $15, $95, $55, $D5, $35, $B5, $75, $F5,
    $0D, $8D, $4D, $CD, $2D, $AD, $6D, $ED, $1D, $9D, $5D, $DD, $3D, $BD, $7D, $FD,
    $03, $83, $43, $C3, $23, $A3, $63, $E3, $13, $93, $53, $D3, $33, $B3, $73, $F3,
    $0B, $8B, $4B, $CB, $2B, $AB, $6B, $EB, $1B, $9B, $5B, $DB, $3B, $BB, $7B, $FB,
    $07, $87, $47, $C7, $27, $A7, $67, $E7, $17, $97, $57, $D7, $37, $B7, $77, $F7,
    $0F, $8F, $4F, $CF, $2F, $AF, $6F, $EF, $1F, $9F, $5F, $DF, $3F, $BF, $7F, $FF
    );

  {
    Picked from QStrings (almost a verbatim copy other than style)
    Copyright (2000-2003) Andrew Dryazgov (ndrewdr@newmail.ru) and
    (2000) Sergey G. Shcherbakov (mover@mail.ru, mover@rada.gov.ua)
  }

procedure ReverseBits(Buffer: Pointer; BitCount: cardinal); assembler asm
  push ebx; push esi; push edi
  mov ebx, edx
  shr ebx, 3; and BitCount, 7; jz @int
  push Buffer; mov edi, Buffer
  inc ebx; xor ecx, ecx; mov cl, 8
  sub cl, dl; xor BitCount, BitCount
  push ebx
@mod: xor eax, eax; mov al, byte[edi]
  shl eax, cl; or eax, edx
  mov byte[edi], al
  xor edx, edx; mov dl, ah
  inc edi; dec ebx; jnz @mod
  pop ebx; pop Buffer
@int: lea ecx, [eax+ebx-1]
@Loop: cmp eax, ecx; jge @@done
  movzx esi, byte[eax]
  movzx edi, byte[ecx]
  mov dh, byte[RevBits+esi]
  mov byte[ecx], dh
  mov dl, byte[RevBits+edi]
  mov byte[eax], dl
  inc eax; dec ecx; jmp @Loop
@@done: pop edi; pop esi; pop ebx
end;

// ~~~~~~~~~~~~~~~~~~~~~~~
// Pseudo-random generator
// ~~~~~~~~~~~~~~~~~~~~~~~
var
  factors: array[boolean] of Int64 = ($13FB7DD4FFC7, 7627861919189 - 1);
  X: integer absolute RandSeedEx;
  f: integer absolute factors;

function RandCycle: Int64; register asm
  push edi

  mov eax, f.0; mul X.16              // x4
  mov ecx, eax; mov eax, X.12         // x3
    mov edi, edx
  mov X.16, eax; mul f.8
  add ecx,eax; mov eax, X.8           // x2
    adc edi, edx
  mov X.12, eax; mul f.12
  add ecx, eax; mov eax, X.0          // x0
    adc edi, edx
  mov X.8, eax; mul f.4
    add eax, ecx; adc edx, edi
    add eax, X.4; adc edx, 0
  mov X.0, eax; mov X.4, edx          // x1

  pop edi
end;

function Rand64: Int64; register asm call RandCycle
end;

function Rand(const Max: cardinal): cardinal; register asm
  test Max, -1; jnz @begin; ret
@begin: push Max
  call RandCycle; pop edx
  mul edx; mov eax, edx
end;

function Rand(const Min, Max: integer): integer; register asm
// Result range in Min..Max inclusif
// Min-Max range should not exceed cardinal boundary minus 1
// (max difference = 4294967295)
  sub max, min; jns @_
    xor eax, eax; ret  // zeronize
  @_: inc max          // difference = (max - min) +1
  push min; push max   // ...save
  call RandCycle     // get R
  pop edx; pop ecx     // ..restore
  mul edx              // multiply R by difference (truncated)
  lea eax, edx + ecx
end;

type
  f80 = packed record // 80 bits extended floating point
    lo, hi: integer;
    exp: word;
  end;

function RandEx: Extended; register asm
  call RandCycle     //  edx:eax
  or edx, 1 shl 31     //  normalized bit-63 in edx
  mov Result.f80.lo, eax
  mov Result.f80.hi, edx
  mov Result.f80.exp, -1 shr 18 // 3fffh
  fLd1                 //  load 1.0, since...
  fLd Result           //  1 < Result < 2
  fSubrP               //  after sub, now 0 < Result < 1
  fStp Result          //  store back, pop!
  wait                 //  be polite, please...
end;

{ Original version
  RandomDbl PROC NEAR
  public RandomDbl
    CALL    RandomBit            ; random bits
    mov  EDX, EAX             ; fast conversion to float
    SHR     EAX, 12
    OR      EAX, 3FF00000H
    SHL     EDX, 20
    mov  dword[TEMP+4], EAX
    mov  dword[TEMP], EDX
    FLD1
    FLD     Qword[TEMP]     ; partial memory stall here
    FSUBR
    RET
  RandomDbl ENDP
}

procedure RandInit(const I: integer = __AAMAGIC0__); register
const
  PRIME0 = 7;
  PRIME1 = $01C8E80D; // 29943821 : 1 1100 1000 1110 1000 0000 1101 ~ 1 11001000 11101000 00010101
  e: extended = 0; // use extended to allow broader range of generated number
asm
  push edi; mov edi, 4
  @LFill:
    imul eax, PRIME1
    dec eax; mov X[edi*4], eax
    dec edi; jge @LFill

  mov edi, PRIME0
  @@LRand: call RandEx
    fstp e // note: for consistency, never directly alter X in RandomExt
    mov eax, e.f80.lo; xor X, eax
    //warn: we should not use edx, since it has been convoluted.
    //(the highest bit is always 1)
    //mov edx, e.ext.hi; mov X.4, edx
    dec edi; jnz @@LRand
  pop edi
end;

const
  CPUID = $A20F;
  RDTSC = $310F;

procedure RandomizeEx; assembler asm
 {$IFDEF DELPHI_6_UP} // i dont know whether is D6 behave as D7?
 rdtsc
 {$ELSE}
 dw rdtsc
 {$ENDIF}
 call RandInit
end; //rdtsc

//function _Shuffle(Range: integer): TInts;
//var
//  i, n, m: integer;
//begin
//  setlength(Result, Range);
//  dec(Range);
//  for i := 0 to Range do
//    Result[i] := i;
//  if (Range > 0) then begin
//    for i := 0 to Range - 1 do begin // I = domain
//      n := RandomInt(i + 1, Range); // N = codomain
//      m := Result[i];
//      Result[i] := Result[n];
//      Result[n] := m;
//    end;
//  end;
//end;

function Shuffle(const Max: integer; const Min: integer = 0): TInts;
var
  i, n, m: integer;
  Range: integer;
begin
  Range := Max - Min + 1;
  setlength(Result, Range);
  dec(Range);
  for i := 0 to Range do
    Result[i] := i;
  if (Range > 0) then begin
    for i := 0 to Range - 1 do begin // I = domain
      n := Rand(i + 1, Range); // N = codomain
      m := Result[i];
      Result[i] := Result[n];
      Result[n] := m;
    end;
    if (Min <> 0) then
      for i := 0 to Range do
        Result[i] := Result[i] + Min
  end;
end;

//NOT_EVER_USED
//const
//  BitsperByte = 8;
//  BitsPerInt = SizeOf(integer) * BitsPerByte;
//
//type
//  TBitEnum = 0..BitsPerInt - 1;
//  TBitSet = set of TBitEnum;
//  PBitArray = ^TBitArray;
//  TBitArray = array[0..4096] of TBitSet;
//
//destructor TBits.Destroy;
//begin
//  setSize(0);
//  inherited Destroy;
//end;
//
//procedure TBits.Error;
//begin
//  raise Self.Create;
//end;
//
//procedure TBits.setSize(Value: integer);
//var
//  NewMem: Pointer;
//  NewMemSize: integer;
//  OldMemSize: integer;
//
//  function Min(X, Y: integer): integer;
//  begin
//    Result := X;
//    if X > Y then
//      Result := Y;
//  end;
//
//begin
//  if Value <> Size then begin
//    if Value < 0 then
//      Error;
//    NewMemSize := ((Value + BitsPerInt - 1) div BitsPerInt) * sizeof(integer);
//    OldMemSize := ((Size + BitsPerInt - 1) div BitsPerInt) * sizeof(integer);
//    if NewMemSize <> OldMemSize then begin
//      NewMem := nil;
//      if NewMemSize <> 0 then begin
//        GetMem(NewMem, NewMemSize);
//        FillChar(NewMem^, NewMemSize, 0);
//      end;
//      if OldMemSize <> 0 then begin
//        if NewMem <> nil then
//          Move(fBits^, NewMem^, Min(OldMemSize, NewMemSize));
//        FreeMem(fBits, OldMemSize);
//      end;
//      fBits := NewMem;
//    end;
//    fSize := Value;
//  end;
//end;
//
//procedure TBits.setBit(Index: integer; Value: Boolean); assembler asm
//  cmp Index, [eax].fSize
//  jae @@exSize
//@@proc: mov eax, [eax].fBits
//  or Value, Value; jz @@testNReset
//  bts [eax], Index; RET
//@@testNReset: btr [eax], Index; RET
//@@exSize: cmp Index, 0; jl TBits.Error
//  push eax {Self}; push Index; push ecx {Value}
//  inc Index; CALL TBits.setSize
//  pop ecx {Value}; pop Index; pop Self; jmp @@proc
//end;
//
//function TBits.getBit(Index: integer): Boolean; assembler asm
//  cmp Index, [eax].fSize; jae TBits.Error
//  mov eax, [eax].fBits
//  bt [eax], Index; sbb eax, eax
//  and eax, 1
//end;
//
//function TBits.OpenBit: integer;
//var
//  i: integer;
//  b: TBitSet;
//  e: TBitEnum;
//  n: integer;
//begin
//  n := (Size + BitsPerInt - 1) div BitsPerInt - 1;
//  for i := 0 to n do
//    if PBitArray(fBits)^[i] <> [0..BitsPerInt - 1] then begin
//      b := PBitArray(fBits)^[i];
//      for e := Low(e) to High(e) do begin
//        if not (e in b) then begin
//          Result := i * BitsPerInt + e;
//          if Result >= Size then
//            Result := Size;
//          Exit;
//        end;
//      end;
//    end;
//  Result := Size;
//end;

function DivMod64(const Dividend, Divisor: Int64; out Quotient: Int64): Int64; assembler asm
//   DivMod64 - unsigned int64 division, get dividend and remainder
//
// Entry: Arguments are passed via stack:
//     1st pushed: divisor (QWORD)
//     2nd pushed: dividend (QWORD)
//   EAX: pointer to QWORD (Quotient result)
//
// Exit:
//   EDX:EAX contains the remainder (divided % divisor)
//   QWORD Quotient contains the quotient (dividend/divisor)
//
    push ebx; push esi; push edi

//  If the divisor is less than 4G, use a simple algorithm with word divides,

    //mov edi, [Quotient] !WRONG!
    mov edi, Quotient
    mov eax, r64.HI(Divisor)      //  is divisor < 4G
    or eax, eax; jnz @L1          //  if it is not, use binary division
    mov ecx, r64.LO(Divisor)      //  load divisor
    mov eax, r64.HI(Dividend)     //  load high word of dividend
    xor edx, edx
    div ecx                       //  get high order bits of quotient
    mov ebx, eax                  //  save high bits of quotient
    mov eax, r64.LO(Dividend)     //  edx:eax <- remainder:lo word of dv
    div ecx                       //  get low order bits of quotient
    mov esi, eax                  //  ebx:esi <- quotient

//  Now we need to do a multiply so that we can compute the remainder.
    mov eax, ebx                  //  set up high word of quotient
    mul dword ptr r64.LO(Divisor) //  HI(QUOT) * Divisor
    mov ecx, eax                  //  save the result in ecx
    mov eax, esi                  //  set up low word of quotient
    mul dword ptr r64.LO(Divisor) //  LO(QUOT) * Divisor
    add edx, ecx                  //  EDX:EAX = QUOT * Divisor
    jmp @L2                       //  complete remainder calculation

//  Binary division. note that eax contains Divisor.HI
@L1:
    mov ecx, eax                //  ecx:ebx <- divisor
    mov ebx, r64.LO(Divisor)
    mov edx, r64.HI(Dividend)   //  edx:eax <- dividend
    mov eax, r64.LO(Dividend)

@L3:
    shr ecx, 1    //  shift divisor right one bit. hi bit <- 0
    rcr ebx, 1
    shr edx, 1    //  shift dividend right one bit. hi bit <- 0
    rcr eax, 1
    or ecx, ecx
    jnz @L3                     //  loop until divisor < 4G
    div ebx                     //  now divide, ignore remainder
    mov esi, eax                //  save quotient

//  May be off by one, so to check, we will multiply the quotient
//  by the divisor and check the result against the orignal dividend
//  Note that we must also check for overflow, which can occur if the
//  dividend is close to 2**64 and the quotient is off by 1.

    mul dword ptr r64.HI(Divisor) //  QUOT * HI(Divisor)
    mov ecx, eax
    mov eax, r64.LO(Divisor)
    mul esi                     //  QUOT * LO(Divisor)
    add edx, ecx                //  EDX:EAX = QUOT * Divisor
    jc @L4                      //  carry means Quotient is off by 1

//  do long compare here between original dividend and the result of
//  the multiply in edx:eax. If original is larger or equal, we are OK,
//  otherwise subtract one (1) from the quotient.

    cmp edx, r64.HI(Dividend)   //  cmp hi words of result & original
    ja @L4                      //  if result > original, do subtract
    jb @L5                      //  if result < original, we are ok
    cmp eax, r64.LO(Dividend)   //  hi words are equal, cmp lo words
    jbe @L5                     //  if less or equal we are ok, else subtract

@L4:
    dec esi                     //  subtract 1 from quotient
    sub eax, r64.LO(Divisor)    //  subtract divisor from result
    sbb edx, r64.HI(Divisor)

@L5:
    xor ebx, ebx                //  ebx:esi <- quotient

@L2:
//  Calculate remainder by subtracting the result from the original
//  dividend. Since the result is already in a register, we will do the
//  subtract in the opposite direction and negate the result.

    sub eax, r64.LO(Dividend)   //  subtract dividend from result
    sbb edx, r64.HI(Dividend)
    neg edx; neg eax            //  otherwise, negate the result
    sbb edx, 0

//  Remainder in edx:eax. Now we need to get the quotient
    mov r64.HI(edi), ebx
    mov r64.LO(edi), esi

    pop edi; pop esi; pop ebx
end;

//OBSOLETE: use uintostr
//function I64uStr(x64: Int64): string;
//var
//  r, lC, lS: integer;
//  C: string;
//  S: string;
//begin
//  if x64 >= 0 then
//    Result := intoStr(x64)
//  else begin
//    C := '0' + intoStr(high(x64));
//    S := intoStr(high(x64) + x64);
//    lC := length(C);
//    lS := length(S);
//    r := 2;
//    repeat
//      r := r + ord(C[lC]) - ord('0');
//      if lS > 0 then
//        r := r + ord(S[lS]) - ord('0');
//      C[lC] := Char((r mod 10) + ord('0'));
//      r := r div 10;
//      dec(lC); dec(lS);
//    until lC < 1;
//    Result := C;
//  end;
//end;
//
//OBSOLETE: use uintostr
//function Int64uStr(const I: Int64; const Digits: byte = 0): string;
//var
//  r, lC, lS: integer;
//  C: string;
//  S: string;
//begin
//  if I >= 0 then
//    Result := intoStr(I, Digits)
//  else begin
//    C := '0' + intoStr(high(I));
//    S := intoStr(high(I) + I);
//    lC := length(C);
//    lS := length(S);
//    r := 2;
//    repeat
//      r := r + ord(C[lC]) - ord('0');
//      if lS > 0 then
//        r := r + ord(S[lS]) - ord('0');
//      C[lC] := Char((r mod 10) + ord('0'));
//      r := r div 10;
//      dec(lC); dec(lS);
//    until lC < 1;
//    Result := C;
//  end;
//end;

// ====================================================================
// EXPERIMENT AREA; TRY AND ERROR, AND ERROR, AND ERROR, AND ERROR,....
// --------------------------------------------------------------------

function getL64(const I: Int64): integer;
const
  //int64 //_1e19 =  -8446744073709551616
  _1e19 = $8AC7230489E80000; _1e19h = $8AC72304; _1e19L = $89E80000;
  _1e18 = $0DE0B6B3A7640000; _1e18h = $0DE0B6B3; _1e18L = $A7640000;
  _1e17 = $016345785D8A0000; _1e17h = $01634578; _1e17L = $5D8A0000;
  _1e16 = $002386F26FC10000; _1e16h = $002386F2; _1e16L = $6FC10000;
  _1e15 = $00038D7EA4C68000; _1e15h = $00038D7E; _1e15L = $A4C68000;
  _1e14 = $00005AF3107A4000; _1e14h = $00005AF3; _1e14L = $107A4000;
  _1e13 = $000009184E72A000; _1e13h = $00000918; _1e13L = $4E72A000;
  _1e12 = $000000E8D4A51000; _1e12h = $000000E8; _1e12L = $D4A51000;
  _1e11 = $000000174876E800; _1e11h = $00000017; _1e11L = $4876E800;
  _1e10 = $00000002540BE400; _1e10h = $00000002; _1e10L = $540BE400;

  //integer
  _1e09 = $3B9ACA00; _1e08 = $05F5E100;
  _1e07 = $00989680; _1e06 = $000F4240; _1e05 = $000186A0;

  //word/byte
  _1e04 = $2710; _1e03 = $03E8; _1e02 = $64; _1e01 = $A; _1e00 = 0;

var
  Len: integer;
begin
  // look at that code; pretty isn't?
  // sexier than britney spears!
  if I < _1e19 then
    Len := 19
  else if I > _1e09 then
    if I > _1e14 then
      if I > _1e16 then
        if I > _1e18 then
          Len := 19
        else if I > _1e17 then
          Len := 18
        else
          Len := 17
      else if I > _1e15 then
        Len := 16
      else
        len := 15
    else if I > _1e11 then
      if I > _1e13 then
        Len := 14
      else if I > _1e12 then
        Len := 13
      else
        Len := 14
    else if I > _1e10 then
      Len := 11
    else
      Len := 10
  else begin
    if I < 0 then
      Len := 20
    else if I < _1e01 then
      Len := 1
    else if I < _1e05 then
      if I < _1e03 then
        if I < _1e02 then
          Len := 02
        else
          Len := 03
      else if I < _1e04 then
        Len := 04
      else
        Len := 05
    else if I < _1e07 then
      if I < _1e06 then
        Len := 06
      else
        Len := 07
    else if I > _1e08 then
      Len := 08
    else
      Len := 09;
  end;
  Result := Len;
end;

// --------------------------------------------------------------------
// END EXPERIMENT AREA
// ====================================================================

// this is a fast inttostr by O'Harrow,
// with clever tricks, producing 2 digits in one cycle
// using reciprocal value $51eb851f (cardinal / 0.32)

const
  deca: packed array[0..100] of array[boolean] of Char = (
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', #0#0
    );
  d01 = 10;
  d02 = 100;
  d03 = 1000;
  d04 = 10000;
  d05 = 100000;
  d06 = 1000000;
  d07 = 10000000;
  d08 = 100000000;
  d09 = 1000000000;
  d10 = 10000000000;
  _032 = $51EB851F;

const
  PMinInt64: pchar = '-9223372036854775808';

function IntToStr_JOH_IA32_4(Value: integer): string; assembler asm
  push ebx; push edi; push esi
  mov ebx, eax; mov edi, edx     {Value / Result Address}
  sar ebx, 31                    {0 for +ve Value or -1 for -ve Value}
  xor eax, ebx; sub eax, ebx     {ABS(Value)}
  mov edx, 10                    {Default Digit Count}
  cmp eax, d04; jae @@5orMoreDigits
  cmp eax, d02; jae @@3or4Digits
  cmp eax, d01; mov dl, 2; jmp @@SetLength  {1 or 2 Digits}
@@3or4Digits:
  cmp eax, d03; mov dl, 4; jmp @@SetLength  {3 or 4 Digits}
@@5orMoreDigits:
  cmp eax, d06; jae @@7orMoreDigits
  cmp eax, d05; mov dl, 6; jmp @@SetLength  {5 or 6 Digits}
@@7orMoreDigits:
  cmp eax, d08; jae @@9or10Digits
  cmp eax, d07; mov dl, 8; jmp @@SetLength  {7 or 8 Digits}
@@9or10Digits: cmp eax, d09                 {9 or 10 Digits}
@@SetLength:
  sbb edx, ebx                   {Digits (Including Sign Character)}
  mov ecx, [edi]                 {Result}
  mov esi, edx                   {Digits (Including Sign Character)}
  test ecx, ecx; je @@Alloc      {Result Not Already Allocated}
  cmp dword[ecx-8], 1; jne @@Alloc      {Reference Count <> 1}
  cmp edx, [ecx-4]; je @@SizeOk              {Existing Length = Required Length}
@@Alloc:
  push eax                       {ABS(Value)}
  mov eax, edi
  call system.@LStrSetLength     {Create Result String}
  pop eax                        {ABS(Value)}
@@SizeOk:
  mov edi, [edi]                 {@Result}
  add esi, ebx                   {Digits (Excluding Sign Character)}
  mov byte[edi], '-'             {Store '-' Character (May be Overwritten)}
  sub edi, ebx                   {Destination of 1st Digit}
  sub esi, 2                     {Digits (Excluding Sign Character) - 2}
  jle @@FinalDigits              {1 or 2 Digits}
  mov ecx, _032                  {Multiplier for Division by 100}

@@Loop:
  mov ebx, eax                {Dividend}
  mul ecx; shr edx, 5         {Dividend DIV 100}
  mov eax, edx                {Set Next Dividend}
  lea edx, [edx*4+edx];
  lea edx, [edx*4+edx];
  shl edx, 2                  {Dividend DIV 100 * 100}
  sub ebx, edx                {Dividend MOD 100}
  sub esi, 2
  //movzx ebx, word[deca+ebx*2]
  //mov [edi+esi+2], bx
  mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bl; mov [edi+esi+3], bh
  jg @@Loop                  {Loop Until 1 or 2 Digits Remaining}

@@FinalDigits:
  jnz @@LastDigit
  //movzx eax, word[deca+eax*2]
  //mov [edi], ax               {Save Final 2 Digits}
  mov eax, dword[deca+eax*2]
  mov [edi], al; mov [edi+1], ah
  jmp @@Done
@@LastDigit:
  add al , '0'                {Ascii Adjustment}
  mov [edi], al               {Save Final Digit}
@@Done: pop esi; pop edi; pop ebx
end;

const
  //JOH_IA32_4_MinInt64s: string = '-9223372036854775808';
  d10_hi = $02; d10_lo = $0540BE400;
  d11_hi = $017; d11_lo = $04876E800;
  d12_hi = $0E8; d12_lo = $0D4A51000;
  d13_hi = $0918; d13_lo = $04E72A000;
  d14_hi = $05AF3; d14_lo = $0107A4000;
  d15_hi = $038D7E; d15_lo = $0A4C68000;
  d16_hi = $02386F2; d16_lo = $06FC10000;
  d17_hi = $01634578; d17_lo = $05D8A0000;
  d18_hi = $0DE0B6B3; d18_lo = $0A7640000;
  d19_hi = $08AC72304; d19_lo = $089E80000;

function IntToStr64_JOH_IA32_4(Value: Int64): string; overload asm
  mov ecx, Value.r64.lo//[ebp+8]  {Low Integer of Value}
  mov edx, Value.r64.hi//[ebp+12] {High Integer of Value}
  test ecx, ecx; jnz @@CheckValue
  cmp edx, 1 shl 31; jnz @@CheckValue
  //mov edx, SMinInt64; call system.@LStrAsg; jmp @@Exit
  mov ecx, 20; mov edx, PMinInt64; call system.@LStrFromPCharLen; jmp @@Exit

@@CheckValue: push ebx; xor ebp, ebp                      {Clear Sign Flag (EBP Already Pushed)}
  mov ebx, ecx                      {Low Integer of Value}
  test edx, edx; jnl @@AbsValue
  mov ebp, 1                        {EBP = 1 for -ve Value or 0 for +ve Value}
  neg ecx; adc edx, 0; neg edx
@@AbsValue:                         {EDX:ECX = Abs(Value)}
  test edx, edx; jnz @@Large
  test ecx, ecx; js @@Large
  mov edx, eax                      {@Result}
  mov eax, ebx                      {Low Integer of Value}
  call IntToStr_JOH_IA32_4          {Call Fast Integer IntToStr Function}
  pop ebx

@@Exit: pop ebp; ret 8              {Restore Stack and Exit}

@@Large: push edi; push esi;
  mov edi, eax; xor ebx, ebx; xor eax, eax

@@Test15:                           {Test for 15 or More Digits}
  cmp edx, d14_hi; jne @@Check15 {1e14}
  cmp ecx, d14_lo

@@Check15: jb @@Test13

@@Test17:                           {Test for 17 or More Digits}
  cmp edx, d16_hi; jne @@Check17    {1e16}
  cmp ecx, d16_lo

@@Check17: jb @@Test15or16

@@Test19:                           {Test for 19 Digits}
  cmp edx, d18_hi; jne @@Check19    {1e18}
  cmp ecx, d18_lo

@@Check19:jb @@Test17or18
  mov al, 19; jmp @@SetLength

@@Test17or18: mov bl, 18             {17 or 18 Digits}
  cmp edx, d17_hi; jne @@SetLen      {1e17}
  cmp ecx, d17_lo; jmp @@SetLen

@@Test15or16: mov bl, 16             {15 or 16 Digits}
  cmp edx, d15_hi; jne @@SetLen      {1e15}
  cmp ecx, d15_lo; jmp @@SetLen

@@Test13:                            {Test for 13 or More Digits}
  cmp edx, d12_hi; jne @@Check13     {1e12}
  cmp ecx, d12_lo

@@Check13: jb @@Test11

@@Test13or14: mov bl, 14             {13 or 14 Digits}
  cmp edx, d13_hi; jne @@SetLen      {1e13}
  cmp ecx, d13_lo;jmp @@SetLen

@@Test11: {10, 11 or 12 Digits}
  cmp edx, d10_hi; jne @@Check11     {1e10}
  cmp ecx, d10_lo

@@Check11: mov bl, 11;
  jb @@SetLen {10 Digits}

@@Test11or12: mov bl, 12             {11 or 12 Digits}
  cmp edx, d11_hi; jne @@SetLen      {1e11}
  cmp ecx, d11_lo

@@SetLen: sbb eax, 0; add eax, ebx   {Adjust for Odd/Even Digit Count}

@@SetLength:                         {Abs(Value) in EDX:ECX, Digits in EAX}
  push ecx; push edx                 {Save Abs(Value)}
  lea edx, [eax+ebp]                 {Digits Needed (Including Sign Character)}
  mov ecx, [edi]                     {@Result}
  mov esi, edx                       {Digits Needed (Including Sign Character)}

  test ecx, ecx; je @@Alloc           {Result Not Already Allocated}
  cmp dword[ecx-8], 1; jne @@Alloc    {Reference Count <> 1}
  cmp edx, [ecx-4]; je @@SizeOk       {Existing Length = Required Length}

@@Alloc:
  push eax; mov eax, edi        {ABS(Value)}
    call system.@LStrSetLength  {Create Result String}
  pop eax                       {ABS(Value)}
@@SizeOk:
  mov edi, [edi]                {@Result}
  sub esi, ebp                  {Digits Needed (Excluding Sign Character)}
  mov byte[edi], '-'            {Store '-' Character (May be Overwritten)}
  add edi, ebp                  {Destination of 1st Digit}
  pop edx; pop eax              {Restore Abs(Value)}

  cmp esi, 17;
    jl @@LessThan17Digits       {Digits < 17}
    je @@SetDigit17             {Digits = 17}
  cmp esi, 18; je @@SetDigit18  {Digits = 18}

@@SetDigit19: mov cl, '0' - 1; mov ebx, d18_lo; mov ebp, d18_hi {1e18}
@@CalcDigit19: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit19
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1
@@SetDigit18: mov cl, '0' - 1; mov ebx, d17_lo; mov ebp, d17_hi {1e17}
@@CalcDigit18: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit18
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1
@@SetDigit17:  mov cl, '0' - 1; mov ebx, d16_lo; mov ebp, d16_hi {1e16}
@@CalcDigit17: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit17
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1     {Update Destination}
  mov esi, 16                   {Set 16 Digits Left}

@@LessThan17Digits:             {Process Next 8 Digits}
  mov ecx, d08; div ecx         {EDX:EAX = Abs(Value) = Dividend}

  mov ebp, eax; mov ebx, edx    {Dividend DIV 100000000}
  mov eax, edx; mov edx, _032   {Dividend MOD 100000000}
  mul edx; shr edx, 5           {Dividend DIV 100}
  mov eax, edx                  {Set Next Dividend}
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    {Dividend DIV 100 * 100}
  sub ebx, edx                  {Remainder (0..99)}
  movzx ebx, word[deca+ebx*2]
  shl ebx, 16
  mov edx, _032; mov ecx, eax   {Dividend}
  mul edx; shr edx, 5           {Dividend DIV 100}
  mov eax, edx
                                {Dividend DIV 100 * 100}
  lea edx, [edx*4+edx];
  lea edx, [edx*4+edx];
  shl edx, 2

  sub ecx, edx                  {Remainder (0..99)}
  or bx, word[deca+ecx*2]

  mov [edi+esi-4], ebx          {Store 4 Digits}
  mov ebx, eax; mov edx, _032
  mul edx; shr edx, 5           {EDX := Dividend DIV 100}
  lea eax, [edx*4+edx];
  lea eax, [eax*4+eax]
  shl eax, 2                    {EDX = Dividend DIV 100 * 100}
  sub ebx, eax                  {Remainder (0..99)}
  movzx ebx, word[deca+ebx*2]
  movzx ecx, word[deca+edx*2]
  shl ebx, 16; or ebx, ecx
  //mov ebx, dword[deca+ebx*2]
  //mov ecx, dword[deca+edx*2]
  //shl ebx, 16; mov bx, cx
  mov [edi+esi-8], ebx          {Store 4 Digits}
  mov eax, ebp                  {Remainder}
  sub esi, 10                   {Digits Left - 2}
  jz @@Last2Digits
@@SmallLoop:                    {Process Remaining Digits}
  mov edx, _032; mov ebx, eax                  {Dividend}
  mul edx; shr edx, 5           {EDX := Dividend DIV 100}
  mov eax, edx                  {Set Next Dividend}
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    {EDX = Dividend DIV 100 * 100}
  sub ebx, edx                  {Remainder (0..99)}
  sub esi, 2
  movzx ebx, word[deca+ebx*2]   //mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bx
  jg @@SmallLoop                {Repeat Until Less than 2 Digits Remaining}
  jz @@Last2Digits
  add al, '0'; mov [edi], al    {Save Final Digit}
  jmp @@Done
@@Last2Digits:
  movzx eax, word[deca+eax*2]   //mov eax, dword[deca+eax*2]
  mov [edi], ax                 {Save Final 2 Digits}
@@Done: pop esi; pop edi; pop ebx
end;

function uintostr(const I: integer): string; overload assembler asm
  push ebx; push edi; push esi
  mov ebx, eax; mov edi, edx                {Value / Result Address}
  //sar ebx, 31                               {0 for +ve Value or -1 for -ve Value}
  //xor eax, ebx; sub eax, ebx                {ABS(Value)}
  //xor ebx,ebx
  mov edx, 10                               {Default Digit Count}
  cmp eax, d04; jae @@5orMoreDigits
  cmp eax, d02; jae @@3or4Digits
  cmp eax, d01; mov dl, 2; jmp @@SetLength  {1 or 2 Digits}
@@3or4Digits:
  cmp eax, d03; mov dl, 4; jmp @@SetLength  {3 or 4 Digits}
@@5orMoreDigits:
  cmp eax, d06; jae @@7orMoreDigits
  cmp eax, d05; mov dl, 6; jmp @@SetLength  {5 or 6 Digits}
@@7orMoreDigits:
  cmp eax, d08; jae @@9or10Digits
  cmp eax, d07; mov dl, 8; jmp @@SetLength  {7 or 8 Digits}
@@9or10Digits: cmp eax, d09                 {9 or 10 Digits}
@@SetLength:
  sbb edx, 0                                {Digits (Including Sign Character)}
  mov ecx, [edi]                            {Result}
  mov esi, edx                              {Digits (Including Sign Character)}
  test ecx, ecx; je @@Alloc                 {Result Not Already Allocated}
  cmp dword[ecx-8], 1; jne @@Alloc          {Reference Count <> 1}
  cmp edx, [ecx-4]; je @@SizeOk             {Existing Length = Required Length}
@@Alloc:
  push eax; mov eax, edi                    {ABS(Value)}
  call system.@LStrSetLength                {Create Result String}
  pop eax                                   {ABS(Value)}
@@SizeOk:
  mov edi, [edi]                            {@Result}
  //add esi, ebx                              {Digits (Excluding Sign Character)}
  //mov byte[edi], '-'                        {Store '-' Character (May be Overwritten)}
  //sub edi, ebx                              {Destination of 1st Digit}
  sub esi, 2; jle @@FinalDigits             {Digits (Excluding Sign Character) - 2}
  mov ecx, _032                             {Multiplier for Division by 100}

@@Loop:
  mov ebx, eax                              {Dividend}
  mul ecx; shr edx, 5                       {Dividend DIV 100}
  mov eax, edx                              {Set Next Dividend}
  lea edx, [edx*4+edx];
  lea edx, [edx*4+edx];
  shl edx, 2                                {Dividend DIV 100 * 100}
  sub ebx, edx                              {Dividend MOD 100}
  sub esi, 2
  movzx ebx, word[deca+ebx*2]               //mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bx; jg @@Loop            {Loop Until 1 or 2 Digits Remaining}

@@FinalDigits: jnz @@LastDigit
  movzx eax, word[deca+eax*2]               //mov eax, dword[deca+eax*2]
  mov [edi], ax; jmp @@Done                 {Save Final 2 Digits}
@@LastDigit: add al, '0'; mov [edi], al     {Save Final Digit}
@@Done: pop esi; pop edi; pop ebx
end;

//LEGACY_CODE
{
const
  JustOverMax: array[0..20] of char = '09223372036854775809'#0;

function uintostr_OK(const I: Int64): string; overload;
asm // result in EAX!!!
  mov edx, dword[I.r64.hi]
  test edx,edx; jl @begin; jz @int32
  push edx; push dword[I]; call IntToStr64_JOH_IA32_4; jmp @@Stop
  @int32: mov edx, Result; mov eax, dword[I]; call uintostr; jmp @@Stop
  @begin: push edi; push ebx
  mov ecx, dword[I]; mov ebx, edx; lea edx, JustOverMax//JOH_IA32_4_MinInt64
  test ecx, ecx; jnz @f18; cmp ebx, 1 shl 31; je @hardcoded

  @f18:
    add ecx, -1; adc ebx, MaxInt;
    cmp ebx, 0DE0B6B3h; ja @JOH_Int64
    cmp ecx, 0A7640000h; ja @JOH_Int64; jnz @f1

  @hardcoded:
    mov ebx, Result; push ecx; call system.@LStrAsg;
    mov edx, 20; call System.@LStrSetLength // MUST be set explicitly
    mov edx, [eax]; pop ecx; test ecx,ecx; jnz @max
    @min: mov byte[edx+19], '8'; jmp @done
    @max: mov word[edx], '01';  jmp @done

  @f1:
    push eax; push ebx; push ecx; mov ebx, Result
    fild qword[esp]; fbstp [esp]; wait

  @proceed: xor edx, edx; mov dl, 20; call __LStrCLset
    mov edi, eax; xor eax, eax; xor ecx, ecx
    mov cl, 19; //mov bl, 8;
    pop edx

  @Loop:
    mov al, dl; shr edx, 4
    and al, 0fh; add ah, al
    mov al, byte[JustOverMax+ecx]; sub al, '0'; add al, ah
    cmp al, 10; setae ah; jb @store; sub al, 10
    cmp al, 10; jb @store; sub al, 10; inc ah
    @store: or al, '0'; mov [edi+ecx], al
    //dec bl; jg @next; mov bl, 8; pop edx
    @p1:cmp cl, 19-8+1; jne @p2; pop edx
    @p2:cmp cl, 19-8-8+1; jne @next pop edx
    @next: dec ecx; jge @Loop; jmp @done

  @JOH_Int64: push ebx; push ecx; mov ebx, eax; call IntToStr64_JOH_IA32_4
    mov eax, [ebx]; movzx edi, byte[eax-4];
    xor ecx, ecx; mov ch, 8
    cmp byte[eax], '-'; jne @loop1; mov byte[eax], '0'

    @loop1:
      mov cl, [edi+eax-1];
      and dl, 0f0h; sub cl, '0'; or dl, cl; ror edx,4
      dec ch; jg @dec; mov ch, 8; push edx; xor edx, edx
      @dec: dec edi; jg @loop1

    shr ecx, 8; shl cl, 2; shr edx, cl
    pop eax; pop ecx
    push edx; push eax; push ecx
    mov eax, ebx; jmp @proceed

  @done:
  @fixup: mov eax, ebx
     mov edi, [ebx]; cmp byte[edi], '0'; jne @end;
     push esi; mov esi, edi
     @scasb: inc esi; cmp byte[esi],'0'; je @scasb
     mov ecx, [edi-4]; add ecx, edi; sub ecx, esi
     push ecx; rep movsb
     pop edx; call System.@LStrSetLength
     pop esi
  @end: pop ebx; pop edi
@@stop:
end;
}

function uintostr(const I: Int64): string; overload asm
  mov ecx, I.r64.lo//[ebp+8]  {Low Integer of Value}
  mov edx, I.r64.hi//[ebp+12] {High Integer of Value}
  test ecx, ecx; jnz @@CheckValue
  cmp edx, 1 shl 31; jnz @@CheckValue
  //mov edx, SMinInt64; call system.@LStrAsg; jmp @@Exit
  //mov edx, SMinInt64; call system.@LStrFromPChar; jmp @@Exit
  mov ecx, 20; mov edx, PMinInt64; call system.@LStrFromPCharLen; jmp @@Exit

@@CheckValue: push ebx; xor ebp, ebp {Clear Sign Flag (EBP Already Pushed)}
  mov ebx, ecx                       {Low Integer of Value}
  //test edx, edx; jnl @@AbsValue
  //mov ebp, 1                         {EBP = 1 for -ve Value or 0 for +ve Value}
  //neg ecx; adc edx, 0; neg edx
@@AbsValue:                          {EDX:ECX = Abs(Value)}
  test edx, edx; jnz @@Large
  //test ecx, ecx; js @@Large
  mov edx, eax                       {@Result}
  mov eax, ebx                       {Low Integer of Value}
  //call IntToStr_JOH_IA32_4           {Call Fast Integer IntToStr Function}
  call uintostr  // 32bit version of uintostr declaration MUST be put over/above int64
  pop ebx

@@Exit: pop ebp; ret 8               {Restore Stack and Exit}

@@Large: push edi; push esi;
  mov edi, eax; xor ebx, ebx; xor eax, eax
@@Test15: cmp edx, d14_hi; jne @@Check15; cmp ecx, d14_lo
@@Check15: jb @@Test13
@@Test17: cmp edx, d16_hi; jne @@Check17; cmp ecx, d16_lo
@@Check17: jb @@Test15or16
@@Test19: cmp edx, d18_hi; jne @@Check19; cmp ecx, d18_lo
@@Check19:jb @@Test17or18
  //mov al, 19; jmp @@SetLength
  mov bl, 20;
  cmp edx, d19_hi; jne @@SetLen
  cmp eax, d19_lo; jmp @@SetLen

@@Test17or18: mov bl, 18             {17 or 18 Digits}
  cmp edx, d17_hi; jne @@SetLen      {1e17}
  cmp ecx, d17_lo; jmp @@SetLen

@@Test15or16: mov bl, 16             {15 or 16 Digits}
  cmp edx, d15_hi; jne @@SetLen      {1e15}
  cmp ecx, d15_lo; jmp @@SetLen

@@Test13:                            {Test for 13 or More Digits}
  cmp edx, d12_hi; jne @@Check13     {1e12}
  cmp ecx, d12_lo

@@Check13: jb @@Test11

@@Test13or14: mov bl, 14             {13 or 14 Digits}
  cmp edx, d13_hi; jne @@SetLen      {1e13}
  cmp ecx, d13_lo; jmp @@SetLen

@@Test11: {10, 11 or 12 Digits}
  cmp edx, d10_hi; jne @@Check11     {1e10}
  cmp ecx, d10_lo

@@Check11: mov bl, 11; jb @@SetLen   {10 Digits}

@@Test11or12: mov bl, 12             {11 or 12 Digits}
  cmp edx, d11_hi; jne @@SetLen      {1e11}
  cmp ecx, d11_lo

@@SetLen: sbb eax, 0; add eax, ebx   {Adjust for Odd/Even Digit Count}

@@SetLength:                         {Abs(Value) in EDX:ECX, Digits in EAX}
  push ecx; push edx                 {Save Abs(Value)}
  //lea edx, [eax+ebp]               {Digits Needed (Including Sign Character)}
  mov edx, eax
  mov ecx, [edi]; mov esi, edx       {Digits Needed (Including Sign Character)}

  test ecx, ecx; je @@Alloc          {Result Not Already Allocated}
  cmp dword[ecx-8], 1; jne @@Alloc   {Reference Count <> 1}
  cmp edx, [ecx-4]; je @@SizeOk      {Existing Length = Required Length}

@@Alloc:
  push eax; mov eax, edi             {ABS(Value)}
  call system.@LStrSetLength         {Create Result String}
  pop eax                            {ABS(Value)}
@@SizeOk:
  mov edi, [edi]                     {@Result}
  //sub esi, ebp                       {Digits Needed (Excluding Sign Character)}
  //mov byte[edi], '-'                 {Store '-' Character (May be Overwritten)}
  //add edi, ebp                       {Destination of 1st Digit}
  pop edx; pop eax                   {Restore Abs(Value)}

  cmp esi, 17;
    jl @@LessThan17Digits            {Digits < 17}
    je @@SetDigit17                  {Digits = 17}

  cmp esi, 19;
    jl @@SetDigit18  {Digits = 18}
    je @@SetDigit19  {Digits = 19}

@@SetDigit20:  mov cl, '0' - 1; mov ebx, d19_lo; mov ebp, d19_hi           {1e19}
@@CalcDigit20: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit20
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1

@@SetDigit19: mov cl, '0' - 1; mov ebx, d18_lo; mov ebp, d18_hi            {1e18}
@@CalcDigit19: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit19
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1

@@SetDigit18: mov cl, '0' - 1; mov ebx, d17_lo; mov ebp, d17_hi            {1e17}
@@CalcDigit18: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit18
  add eax, ebx; adc edx, ebp; mov [edi], cl; add edi, 1

@@SetDigit17: mov cl, '0' - 1; mov ebx, d16_lo; mov ebp, d16_hi            {1e16}
@@CalcDigit17: add ecx, 1; sub eax, ebx; sbb edx, ebp; jnc @@CalcDigit17

  add eax, ebx; adc edx, ebp;
  mov [edi], cl; add edi, 1     {Update Destination}
  mov esi, 16                   {Set 16 Digits Left}

@@LessThan17Digits:             {Process Next 8 Digits}
  mov ecx, d08; div ecx         {EDX:EAX = Abs(Value) = Dividend}
  mov ebp, eax; mov ebx, edx    {Dividend DIV 100000000}
  mov eax, edx; mov edx, _032   {Dividend MOD 100000000}
  mul edx; shr edx, 5           {Dividend DIV 100}
  mov eax, edx                  {Set Next Dividend}
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    {Dividend DIV 100 * 100}
  sub ebx, edx                  {Remainder (0..99)}
  movzx ebx, word[deca+ebx*2]
  shl ebx, 16; mov edx, _032
  mov ecx, eax                  {Dividend}
  mul edx; shr edx, 5           {Dividend DIV 100}
  mov eax, edx
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    {Dividend DIV 100 * 100}
  sub ecx, edx                  {Remainder (0..99)}
  or bx, word[deca+ecx*2]

  mov [edi+esi-4], ebx          {Store 4 Digits}
  mov ebx, eax; mov edx, _032
  mul edx; shr edx, 5           {EDX := Dividend DIV 100}
  lea eax, [edx*4+edx];
  lea eax, [eax*4+eax]
  shl eax, 2                    {EDX = Dividend DIV 100 * 100}
  sub ebx, eax                  {Remainder (0..99)}
  movzx ebx, word[deca+ebx*2]
  movzx ecx, word[deca+edx*2]
  shl ebx, 16; or ebx, ecx
  //mov ebx, dword[deca+ebx*2]
  //mov ecx, dword[deca+edx*2]
  //shl ebx, 16; mov bx, cx
  mov [edi+esi-8], ebx          {Store 4 Digits}
  mov eax, ebp                  {Remainder}
  sub esi, 10                   {Digits Left - 2}
  jz @@Last2Digits
@@SmallLoop:                    {Process Remaining Digits}
  mov edx, _032; mov ebx, eax   {Dividend}
  mul edx; shr edx, 5           {EDX := Dividend DIV 100}
  mov eax, edx                  {Set Next Dividend}
  lea edx, [edx*4+edx]
  lea edx, [edx*4+edx]
  shl edx, 2                    {EDX = Dividend DIV 100 * 100}
  sub ebx, edx                  {Remainder (0..99)}
  sub esi, 2
  movzx ebx, word[deca+ebx*2]   //mov ebx, dword[deca+ebx*2]
  mov [edi+esi+2], bx
  jg @@SmallLoop                {Repeat Until Less than 2 Digits Remaining}
  jz @@Last2Digits
  add al, '0'; mov [edi], al    {Save Final Digit}
  jmp @@Done
@@Last2Digits:
  movzx eax, word[deca+eax*2]   //mov eax, dword[deca+eax*2]
  mov [edi], ax                 {Save Final 2 Digits}
@@Done: pop esi; pop edi; pop ebx
end;

end.

