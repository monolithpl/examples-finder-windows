unit fDirFunc;
{$WEAKPACKAGEUNIT ON}
{$J-} //no-writeableconst
{$R-} //no-rangechecking
{$Q-} //no-overflowchecking
{.$D-}//no-debug
{.$DEFINE USING_MBCS}
//MBCS only affects these two functions here
//function LastDelimiter(const Delimiters, S: string): integer;
//function IsPathDelimiter(const S: string; Index: integer): Boolean;
{
  Copyright (c) 2004, aa, Adrian H., Ray AF. & Inge DR.
  Property of PT SOFTINDO Jakarta.
  All rights reserved.

  (this format should stop spammer-bot, to be stripped are:
   at@, brackets[], comma,, overdots., and dash-
   DO NOT strip underscore_)

  mail,to:@[zero_inge]AT@-y.a,h.o.o.@DOTcom,
  mail,to:@[aa]AT@-s.o.f.t,i.n.d.o.@DOTnet
  http://delphi.softindo.net

  Version: 1.0.0.3
  Dated: 2004.10.11
  LastUpdated: 2005.02.07
}

interface

//reinventing the wheel, no-need more explanations
function ExtractFileExt(const Filename: string): string;
function ChangeFileExt(const Filename, Extension: string): string;
function ExtractFileDir(const Filename: string): string;
function ExtractFilename(const Filename: string): string;
function ExtractFilePath(const Filename: string): string; // backslash appended

//function IncludeTrailingBackslash(const S: string): string; forward;
//function ExcludeTrailingBackslash(const S: string): string; forward;
function Backslashed(const S: string): string;
function Unbackslashed(const S: string): string;

function FileExists(const Filename: string): Boolean;
function DirectoryExists(const Name: string): Boolean; // +
function isAbsolutePath(const fn: string): boolean;

function CreateDir(const Dir: string): Boolean;
function CreateDirTree(DirTree: string): Boolean; // +

function DeleteFile(const Filename: string): boolean; overload;
function RenameFile(const SrcFilename, DestFilename: string): boolean; overload;
function CopyFile(const SrcFilename, DestFilename: string;
  const OverwriteExisting: boolean = TRUE): boolean; overload;

function DeleteFiles(const PathMask: string): integer; // +
function MoveFiles(const PathMask, DestDir: string): integer; overload;
function CopyFiles(const PathMask, DestDir: string): integer; overload;

function GetFileSize(const Filename: string): Integer; // +
function GetLongFileSize(const Filename: string): Int64; // +

//function fhandleOpenReadGetSize(const Filename: string; var handle: integer): Int64; // +
function fHandleOpenReadOnly(const Filename: string): integer;
function fHandleRead(Handle: integer; var Buffer; Count: integer): integer;
function fHandleSetPos(Handle, Offset, Origin: Integer): Integer;
function fhandleGetLongSize(handle: integer): int64;
function ExpandFileName(const FileName: string): string;

//function StringReadFrorm(const FileName: string): string;
function ReadStringFrom(const FileName: string; unixing: boolean = FALSE): string;
function WriteStringTo(const FileName: string; const S: string; const MakeBackupIfAlreadyExist: boolean): integer;
//function BufferSaveTo(const FileName: string; const Buffer; const MakeBackup: boolean): integer;

function fHandleOpen(const Filename: string; const OpenModes, CreationMode, Attributes: Longword): integer;
procedure fHandleClose(Handle: integer);

function MakeBackupFilename(const Filename: string; const BackupExtension: string = '';
  const BackupSubDir: string = '' {'backup'}): string;

function GetBakFilename(const Filename: string; const NewExtension: string = '.';
  const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = TRUE): string;

// procedure InitSysLocale; forward;
// you should call this first when Regional Language changed // not likely

function SimpleBrowseDirectory(const RootDir: string = ''; const Title: string = 'Browse Folder...'): string;
// deprecated, it's quite complex and consumes significant amount of resources.
// full-capability features separated to stand-alone unit (dbrowser)

procedure MakeManifestFile(const AppName: string);

const
// Borrowed from SysUtils
  { Open Mode }
  fmOpenRead = $0000;
  fmOpenWrite = $0001;
  fmOpenReadWrite = $0002;
  fmOpenQuery = $0003;

  fmShareCompat = $0000;
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead = $0030;
  fmShareDenyNone = $0040;

  { Creation Mode }
  //CREATE_NONE = 0; {$EXTERNALSYM CREATE_NONE}
  //CREATE_NEW = 1; {$EXTERNALSYM CREATE_NEW}
  //CREATE_ALWAYS = 2; {$EXTERNALSYM CREATE_ALWAYS}
  //OPEN_EXISTING = 3; {$EXTERNALSYM OPEN_EXISTING}
  //OPEN_ALWAYS = 4; {$EXTERNALSYM OPEN_ALWAYS}
  //TRUNCATE_EXISTING = 5; {$EXTERNALSYM TRUNCATE_EXISTING}

  fcCreateNone = 0; //none specified //$000;//CREATE_NONE;
  fcCreateNew = 1; //fail if already existed //$0100;//CREATE_NEW;
  fcCreateAlways = 2; //create, overwrite if already existed //$0200;//CREATE_ALWAYS;
  fcOpenExisting = 3; //open-only, fail if not already existed //$0300;//OPEN_EXISTING;
  fcOpenAlways = 4; //open file, create if not exist //$0400;//OPEN_ALWAYS;
  fcTruncateExisting = 5; //truncate existing file 0-size, fail if not already existed //$0500;//TRUNCATE_EXISTING;

  { File attribute constants }
  faNone = $0;
  faReadOnly = $00000001;
  faHidden = $00000002;
  faSysFile = $00000004;
  faVolumeID = $00000008;
  faDirectory = $00000010;
  faArchive = $00000020;
  faAnyFile = $0000003F;
  faNormal = $00000080;

  fPosFromBeginning = 0;
  fPosFromCurrent = 1;
  fPosFromEnd = 2;

implementation
uses
{$IFDEF USING_MBCS}MBCSdlm, {$ENDIF}
  ACConsts, Ordinals;

function LastDelimiter(const Delimiters, S: string): Integer; forward;
function IsPathDelimiter(const S: string; Index: Integer): Boolean; forward;

function isAbsolutePath(const fn: string): boolean;
var
  l: integer;
begin
  l := length(fn);
  Result := ((l > 0) and (fn[1] = '\')) or ((l > 1) and (fn[2] = ':'))
end;

function ExtractFileDrive(const Filename: string): string;
var
  i, j: integer;
begin
  if (Length(Filename) >= 2) and (Filename[2] = ':') then
    Result := Copy(Filename, 1, 2)
  else if (Length(Filename) >= 2) and (Filename[1] = '\') and
    (Filename[2] = '\') then begin
    j := 0;
    i := 3;
    while (i < Length(Filename)) and (j < 2) do begin
      if Filename[i] = '\' then
        inc(j);
      if j < 2 then
        inc(i);
    end;
    if Filename[i] = '\' then
      dec(i);
    Result := Copy(Filename, 1, i);
  end
  else
    Result := '';
end;

function ExtractFilename(const Filename: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('\:', Filename);
  Result := Copy(Filename, i + 1, MaxInt);
end;

function ExtractFileExt(const Filename: string): string;
var
  i: integer;
begin
  i := LastDelimiter('.\:', Filename);
  if (i > 0) and (Filename[i] = '.') then
    Result := Copy(Filename, i, MaxInt)
  else
    Result := '';
end;

function ChangeFileExt(const Filename, Extension: string): string;
var
  i: integer;
begin
  i := LastDelimiter('.\:', Filename);
  if (i = 0) or (Filename[i] <> '.') then
    i := MaxInt;
  Result := Copy(Filename, 1, i - 1) + Extension;
end;

type
  THandle = Longword;
  DWORD = Longword; {$EXTERNALSYM DWORD}
  BOOL = longbool; {$EXTERNALSYM BOOL}

const
  FA_DIRECTORY = $10;
  MAX_PATH = 260; {$EXTERNALSYM MAX_PATH}
  INVALID_HANDLE_VALUE = DWORD(-1); {$EXTERNALSYM INVALID_Handle_VALUE}
  _INVALID_ = INVALID_HANDLE_VALUE;

type
  //PFileTime = ^TFileTime;
  TFileTime = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;

  //PWin32FindData = ^TWin32FindData;
  TWin32FindData = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFilename: array[0..MAX_PATH - 1] of AnsiChar;
    cAlternateFilename: array[0..13] of AnsiChar;
  end;

const
  kernel32 = 'kernel32.dll';

function FindFirstFile(lpFilename: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name 'FindFirstFileA'; {$EXTERNALSYM FindFirstFile}

function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL; stdcall; external kernel32 name 'FindNextFileA'; {$EXTERNALSYM FindNextFile}

function FindCloseFile(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose'; {$EXTERNALSYM FindCloseFile}

function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'FileTimeToLocalFileTime'; {$EXTERNALSYM FileTimeToLocalFileTime}

function FileTimeToDOSDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL; stdcall; external kernel32 name 'FileTimeToDosDateTime'; {$EXTERNALSYM FileTimeToDosDateTime}

function GetFullPathNameA(lpFileName: PAnsiChar; nBufferLength: DWORD; lpBuffer: PAnsiChar; var lpFilePart: PAnsiChar): DWORD; stdcall; external kernel32 name 'GetFullPathNameA'; {$EXTERNALSYM GetFullPathNameA}

function ExpandFileName(const FileName: string): string;
const
  MAX_PATH = 260;
var
  FName: PChar;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  SetString(Result, Buffer, GetFullPathNameA(PChar(FileName), SizeOf(Buffer), Buffer, FName));
end;

type
  LongRec = packed record
    Lo, Hi: word;
  end;

  Int64Rec = packed record
    Lo, Hi: DWORD;
  end;

type
  TFilename = string;
  TSearchRec = record
    Time: integer;
    Size: integer;
    Attr: integer;
    Name: TFilename;
    ExcludeAttr: integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
  end;

  //procedure FindClose(var F: TSearchRec);
  //begin
  //  if F.FindHandle <> INVALID_Handle_VALUE then begin
  //    FindCloseFile(F.FindHandle);
  //    F.FindHandle := INVALID_Handle_VALUE;
  //  end;
  //end;

//function FileAge(const Filename: string): integer;
//const  FILE_ATTRIBUTE_DIRECTORY = $00000010; // {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
//var
//  Handle: THandle;
//  FindData: TWin32FindData;
//  LocalFileTime: TFileTime;
//begin
//  Handle := FindFirstFile(PChar(Filename), FindData);
//  if Handle <> INVALID_Handle_VALUE then begin
//    FindCloseFile(Handle);
//    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
//      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
//      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
//        LongRec(Result).Lo) then
//        Exit;
//    end;
//  end;
//  Result := -1;
//end;
//
//function FileExists(const Filename: string): Boolean;
//begin
//  Result := FileAge(Filename) <> -1;
//end;

function fileexists(const filename: string): boolean;
const
  FILE_ATTRIBUTE_DIRECTORY = $00000010; // {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
var
  ff: THandle;
  FindData: TWin32FindData;
begin
  ff := FindFirstFile(PChar(Filename), FindData);
  Result := ff <> INVALID_Handle_VALUE;
  if Result then begin
    FindCloseFile(ff);
    Result := (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0
  end
end;

function GetBakFilename(const Filename: string; const NewExtension: string = '.';
  const CounterDigits: integer = 3; const AutoPrependExtensionWithDot: Boolean = YES): string;
const
  DOT = CHAR_DOT;
var
  i: Cardinal;
  Dir, fn, e, ext: string;
begin
  if (NewExtension = '') then
    ext := ExtractFileExt(Filename)
  else begin
    ext := NewExtension;
    if (ext[1] <> DOT) and AutoPrependExtensionWithDot then
      ext := DOT + ext;
  end;
  i := 0;
  if CounterDigits < 1 then
    e := ext
  else
    e := ext + intoStr(i, CounterDigits);
  Dir := ExtractFilePath(Filename);
  fn := ExtractFilename(Filename);
  if FileExists(Dir + fn) then
    fn := ChangeFileExt(fn, e);
  while FileExists(Dir + fn) do begin
    fn := ChangeFileExt(fn, ext + IntoStr(i, CounterDigits)); //format('%.1u', [i]));
    if i >= high(Cardinal) then
      ;
      //pending: raise exception.Create('too many tries');
    inc(i);
  end;
  Result := fn;
end;

//function ExtractFileDir(const Filename: string): string; forward;
//function Backslashed(const S: string): string; forward;
//function Unbackslashed(const S: string): string; forward;
//function CreateDir(const Dir: string): Boolean; forward;
//procedure DeleteFile(Filename: string); overload; forward;
//procedure RenameFile(SrcFilename, DestFilename: string); overload; forward;

function MakeBackupFilename(const Filename: string; const BackupExtension: string = '';
  const BackupSubDir: string = '' {'backup'}): string;
var
  Dir, DirSub, fname, bakname, _ext: string;
begin
  if not FileExists(Filename) then
    Result := Filename
  else begin
    fname := ExtractFilename(Filename);
    if BackupExtension <> '' then
      _ext := BackupExtension
    else
      _ext := ExtractFileExt(GetBakFilename(Filename));
    //ext := ExtractFileExt(Filename);
    Dir := ExtractFileDir(Filename);
    if (Dir <> '') and (BackupSubDir <> '') then
      DirSub := Backslashed(Dir) + BackupSubDir
    else
      DirSub := Dir + BackupSubDir;
    if (DirSub <> '') then
      DirSub := Backslashed(DirSub);
    bakname := DirSub + ChangeFileExt(fname, '') + _ext;
    if (DirSub <> '') and not DirectoryExists(DirSub) then
      CreateDirTree(DirSub);
    if FileExists(bakname) then
      DeleteFile(PChar(bakname));
    if not FileExists(bakname) then
      RenameFile(PChar(Filename), bakname);
    Result := bakname;
  end;
end;

function CreateFile(Filename: PChar; DesiredAccess, ShareMode: Longword;
  SecurityAttributes: pointer {PSecurityAttributes}; CreationDisposition,
  FlagsAndAttributes: Longword; hTemplateFile: integer): integer; stdcall;
  external kernel32 name 'CreateFileA'; {$EXTERNALSYM CreateFile}

function CloseHandle(Handle: THandle): Longbool; stdcall;
  external kernel32 name 'CloseHandle'; {$EXTERNALSYM CloseHandle}

procedure fHandleClose(Handle: integer);
begin
  CloseHandle(THandle(Handle));
end;

function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: pointer {POverlapped}): BOOL; stdcall;
  external kernel32 name 'ReadFile'; {$EXTERNALSYM ReadFile}

function fHandleRead(Handle: integer; var Buffer; Count: integer): integer;
begin
  if not ReadFile(THandle(Handle), Buffer, Count, Longword(Result), nil) then
    Result := -1;
end;

function WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;
  var lpNumberOfBytesWritten: DWORD; lpOverlapped: pointer {POverlapped}): BOOL; stdcall;
  external kernel32 name 'WriteFile'; {$EXTERNALSYM WriteFile}

function fHandleWrite(Handle: integer; var Buffer; Count: integer): integer;
begin
  if not WriteFile(THandle(Handle), Buffer, Count, Longword(Result), nil) then
    Result := -1;
end;

function fHandleOpen(const Filename: string; const OpenModes, CreationMode, Attributes: Longword): integer;
const
  GENERIC_READ = DWORD($80000000);
  GENERIC_WRITE = $40000000;
  //GENERIC_EXECUTE = $20000000; // GENERIC_ALL = $10000000;
  FILE_SHARE_READ = $00000001;
  FILE_SHARE_WRITE = $00000002;
  AccessMode: array[0..3] of Longword = (GENERIC_READ, GENERIC_WRITE, GENERIC_READ or GENERIC_WRITE, 0);
  ShareMode: array[0..4] of Longword = (0, 0, FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := integer(CreateFile(PChar(Filename), AccessMode[OpenModes and 3],
    ShareMode[(OpenModes and $F0) shr 4], nil, CreationMode, Attributes, 0));
end;

function fHandleOpenReadOnly(const Filename: string): integer;
begin
  Result := fHandleOpen(Filename, fmOpenRead or fmShareDenyNone, fcOpenExisting, faNormal);
end;

function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
  external kernel32 name 'SetFilePointer'; {$EXTERNALSYM SetFilePointer}

function fHandleSetPos(Handle, Offset, Origin: Integer): Integer;
begin
  Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
end;

function fHandleGetFileSize(hFile: Longword; lpFileSizeHigh: Pointer): Cardinal; stdcall;
  external kernel32 name 'GetFileSize'; {$EXTERNALSYM fHandleGetFileSize}

function fhandleGetLongSize(handle: integer): int64;
begin
  Int64Rec(Result).Lo := fhandleGetFileSize(handle, @Int64Rec(Result).Hi);
end;

function fhandleOpenReadGetSize(const Filename: string; var handle: integer): Int64;
begin
  handle := fHandleOpenReadOnly(Filename);
  if handle = integer(_INVALID_) then
    Result := -1
  else begin
    Int64Rec(Result).Lo := fhandleGetFileSize(handle, @Int64Rec(Result).Hi);
    // CloseHandle(h);
  end;
end;

function GetFileSize(const FileName: string): integer {Int64};
var
  Data: TWin32FindData;
begin
  Result := FindFirstFile(PChar(FileName), Data);
  if Result <> integer(INVALID_HANDLE_VALUE) then begin
    CloseHandle(Result);
    if not ((Data.dwFileAttributes and FA_DIRECTORY) = 0) then
      Result := -1
    else begin
      //int64Rec(Result).Hi := Data.FileSizeHigh;
      //int64Rec(Result).Lo := Data.FileSizeLow;
      Result := Data.nFileSizeLow;
    end;
  end;
end;

function GetLongFileSize(const FileName: string): Int64;
var
  Data: TWin32FindData;
begin
  Result := FindFirstFile(PChar(FileName), Data);
  if Result <> INVALID_HANDLE_VALUE then begin
    CloseHandle(Result);
    if not ((Data.dwFileAttributes and FA_DIRECTORY) = 0) then
      Result := -1
    else begin
      int64Rec(Result).Hi := Data.nFileSizeHigh;
      int64Rec(Result).Lo := Data.nFileSizeLow;
      //Result := Data.FileSizeLow;
    end;
  end;
end;

function GetFileAttributes(lpFilename: PChar): Cardinal; stdcall;
  external kernel32 name 'GetFileAttributesA'; {$EXTERNALSYM GetFileAttributes}

function DirectoryExists(const Name: string): Boolean; //const faDirectory = $00000010;
var
  AttributeFlags: integer;
begin
  AttributeFlags := GetFileAttributes(PChar(Name));
  Result := (AttributeFlags <> -1) and (faDirectory and AttributeFlags <> 0);
end;

function Backslashed(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + '\';
end;

function Unbackslashed(const S: string): string;
begin
  Result := S;
  if IsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result) - 1);
end;

function ExtractFilePath(const Filename: string): string;
var
  i: integer;
begin
  i := LastDelimiter('\:', Filename);
  Result := Copy(Filename, 1, i);
end;

function ExtractFileDir(const Filename: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('\:', Filename);
  if (i > 1) and (Filename[i] = '\') and not (Filename[i - 1] in ['\', ':']) then
    dec(i);
    //(ByteType(Filename, i-1) = mbTrailByte)) then dec(i);
  Result := Copy(Filename, 1, I);
end;

function CreateDirectory(lpPathName: PChar; lpSecurityAttributes: pointer): BOOL; stdcall;
  external kernel32 name 'CreateDirectoryA'; {$EXTERNALSYM CreateDirectory}

function CreateDir(const Dir: string): Boolean;
begin
  Result := CreateDirectory(PChar(Dir), nil);
end;

function CreateDirTree(DirTree: string): Boolean;
const
  MINLEN = 2;
begin
  Result := YES;
  if Length(DirTree) = 0 then
    exit;
    //raise Exception.CreateRes(@SCannotCreateDir);
    //raise Exception.Create(Err_fCreate);
  DirTree := Unbackslashed(DirTree);
  if (Length(DirTree) > MINLEN) and not DirectoryExists(DirTree) and (ExtractFilePath(DirTree) <> DirTree) then
    // avoid 'xyz:\' problem.
    Result := CreateDirTree(ExtractFilePath(DirTree)) and CreateDir(DirTree);
end;

function GetLastError: DWORD; stdcall; external kernel32 name 'GetLastError'; {$EXTERNALSYM GetLastError}

function FindMatchingFile(var F: TSearchRec): integer;
var
  LocalFileTime: TFileTime;
begin
  with F do begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFilename;
  end;
  Result := 0;
end;

function findFirst(const Path: string; Attr: integer; var F: TSearchRec): integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_Handle_VALUE then begin
    Result := FindMatchingFile(F);
    if Result <> 0 then
      FindCloseFile(cardinal(@F));
  end
  else
    Result := GetLastError;
end;

function DeleteFile(Filename: PChar): BOOL; stdcall; overload;
  external kernel32 name 'DeleteFileA'; {$EXTERNALSYM DeleteFile}

function CopyFile(SrcFilename, DestFilename: PChar; FailIfExist: BOOL): BOOL; stdcall; overload;
  external kernel32 name 'CopyFileA'; {$EXTERNALSYM CopyFile}

function RenameFile(SrcFilename, DestFilename: PChar): BOOL; stdcall; overload;
  external kernel32 name 'MoveFileA'; {$EXTERNALSYM RenameFile}

function DeleteFile(const Filename: string): boolean; overload;
begin
  Result := DeleteFile(PChar(Filename));
end;

function CopyFile(const SrcFilename, DestFilename: string;
  const OverwriteExisting: boolean = TRUE): boolean; overload;
begin
  Result := CopyFile(PChar(SrcFilename), PChar(DestFileName), not OverwriteExisting);
end;

function RenameFile(const SrcFilename, DestFilename: string): boolean; overload;
begin
  Result := RenameFile(PChar(SrcFilename), PChar(DestFilename));
end;

function FindNext(var F: TSearchRec): integer;
begin
  if FindNextFile(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F)
  else
    Result := GetLastError;
end;

{
procedure Deletefiles(const PathMask: string);
var
  SDir: string;
  SFile: string;
  sRec: TSearchRec;
  found: word;
begin
  SDir := ExtractFileDir(PathMask);
  SFile := ExtractFileName(PathMask);
  found := findfirst(PathMask, 0, SRec);
  while found = 0 do begin
    DeleteFile(SDir + '\' + SRec.Name);
    found := FindNext(SRec);
  end;
  FindClose(srec);
end;                                                  windows
}

function DeleteFiles(const PathMask: string): integer;
var
  SPath: string;
  shrek: TSearchRec;
  found: integer;
begin
  Result := 0;
  SPath := ExtractFilePath(PathMask);
  found := findfirst(PathMask, 0, shrek);
  if found = 0 then begin
    while found = 0 do begin
      inc(Result);
      DeleteFile(pChar(SPath + shrek.Name));
      found := findnext(shrek);
    end;
    findCloseFile(cardinal(@shrek));
  end;
end;

function CopyFiles(const PathMask, DestDir: string): integer; overload;
var
  SourcePath, DestPath: string;
  shrek: TSearchRec;
  found: integer;
begin
  Result := 0;
  SourcePath := ExtractFilePath(PathMask); //Backslashed(SourceDir);
  DestPath := Backslashed(DestDir);
  found := findfirst(PathMask, 0, shrek);
  if found = 0 then begin
    while found = 0 do begin
      inc(Result);
      CopyFile(pChar(SourcePath + Shrek.name), pChar(DestPath + Shrek.Name), FALSE);
      found := findnext(shrek);
    end;
    findCloseFile(cardinal(@shrek));
  end;
end;

function MoveFiles(const PathMask, DestDir: string): integer; overload;
var
  SourcePath, DestPath: string;
  shrek: TSearchRec;
  found: integer;
begin
  Result := 0;
  SourcePath := ExtractFilePath(PathMask);
  DestPath := Backslashed(DestDir);
  found := findfirst(PathMask, 0, shrek);
  if found = 0 then begin
    while found = 0 do begin
      inc(Result);
      RenameFile(pChar(SourcePath + Shrek.name), pChar(DestPath + Shrek.Name));
      found := findnext(shrek);
    end;
    findCloseFile(cardinal(@shrek));
  end;
end;

{$IFDEF USING_MBCS}

function LastDelimiter(const Delimiters, S: string): integer;
begin
  Result := MBCSdlm.LastDelimiter(Delimiters, S);
end;

function IsPathDelimiter(const S: string; Index: integer): Boolean;
begin
  Result := MBCSdlm.IsPathDelimiter(S, Index);
end;

{$ELSE IFNDEF USING_MBCS}

function LastDelimiter(const Delimiters, S: string): integer;
var
  i, j: integer;
begin
  Result := 0;
  for i := length(S) downto 1 do
    for j := 1 to length(Delimiters) do
      if S[i] = Delimiters[j] then begin
        Result := i;
        exit; //break; // do not use break (under inner loop)
      end;
end;

function IsPathDelimiter(const S: string; Index: integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = '\')
   //and (ByteType(S, Index) = mbSingleByte);
end;
{$ENDIF}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~  MOVED TO unit MBCSdlm
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~ type
//~   UINT = Longword; {$EXTERNALSYM UINT}
//~   LCID = DWORD; {$EXTERNALSYM LCID}
//~   LANGID = Word; {$EXTERNALSYM LANGID}
//~
//~   TSysLocale = packed record
//~     DefaultLCID: LCID;
//~     PriLangID: LANGID;
//~     SubLangID: LANGID;
//~     FarEast: Boolean;
//~     MiddleEast: Boolean;
//~   end;
//~
//~ var
//~   SysLocale: TSysLocale = (DefaultLCID: 0);
//~   LeadBytes: set of char = [];
//~
//~ type
//~   TMBCSByteType = (mbSingleByte, mbLeadByte, mbTrailByte);
//~
//~ function ByteTypeTest(P: PChar; Index: Integer): TMbcsByteType;
//~ var
//~   I: Integer;
//~   //LeadBytes: set of char;
//~ begin
//~   Result := mbSingleByte;
//~   //LeadBytes := WinGlobal.LeadBytes;
//~   if (P = nil) or (P[Index] = #$0) then Exit;
//~   if (Index = 0) then begin
//~     if P[0] in LeadBytes then Result := mbLeadByte;
//~   end
//~   else begin
//~     I := Index - 1;
//~     while (I >= 0) and (P[I] in LeadBytes) do dec(I);
//~     if ((Index - I) mod 2) = 0 then Result := mbTrailByte
//~     else if P[Index] in LeadBytes then Result := mbLeadByte;
//~   end;
//~ end;
//~
//~ function ByteType(const S: string; Index: Integer): TMbcsByteType;
//~ begin
//~   Result := mbSingleByte;
//~   if {WinGlobal.} SysLocale.FarEast then
//~     Result := ByteTypeTest(PChar(S), Index - 1);
//~ end;
//~
//~ // from SysUtils
//~ { StrScan returns a pointer to the first occurrence of Chr in Str. If Chr
//~   does not occur in Str, StrScan returns NIL. The null terminator is
//~   considered to be part of the string. }
//~
//~ function StrScan(const Str: PChar; Chr: Char): PChar; assembler;
//~ // due to low performance do not use for long-string (string with great length)
//~ // use only for small string such as Filename / path name
//~ asm
//~     push edi
//~     push eax
//~     mov edi, str
//~     mov ecx, 0ffffffffh
//~     xor al, al
//~     repne scasb
//~     not ecx
//~     pop edi
//~     mov al, chr
//~     repne scasb
//~     mov eax, 0
//~     jne @@1
//~     mov eax, edi
//~     dec eax
//~   @@1: pop edi
//~ end;
//~
//~ //procedure InitSysLocale; forward;
//~
//~ function LastDelimiter(const Delimiters, S: string): Integer;
//~ var
//~   P: PChar;
//~ begin
//~   if SysLocale.DefaultLCID = 0 then InitSysLocale;
//~   Result := Length(S);
//~   P := PChar(Delimiters);
//~   while Result > 0 do begin
//~     if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
//~       if (ByteType(S, Result) = mbTrailByte) then
//~         dec(Result)
//~       else Exit;
//~     dec(Result);
//~   end;
//~ end;
//~
//~ function IsPathDelimiter(const S: string; Index: Integer): Boolean;
//~ begin
//~   if SysLocale.DefaultLCID = 0 then InitSysLocale;
//~   Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = '\')
//~     and (ByteType(S, Index) = mbSingleByte);
//~ end;
//~
//~ const
//~   MAX_LEADBYTES = 12; {$EXTERNALSYM MAX_LEADBYTES} // 5 ranges, 2 bytes ea., 0 term.
//~   MAX_DEFAULTCHAR = 2; {$EXTERNALSYM MAX_DEFAULTCHAR} // whether single or double byte
//~
//~ type
//~   TCPInfo = record
//~     MaxCharSize: UINT; { max length (bytes) of a char }
//~     DefaultChar: array[0..MAX_DEFAULTCHAR - 1] of Byte; { default character }
//~     LeadByte: array[0..MAX_LEADBYTES - 1] of Byte; { lead byte ranges }
//~   end;
//~
//~ const
//~   user32 = 'user32.dll';
//~
//~ function GetSystemMetrics(nIndex: Integer): Integer; stdcall; external user32 name 'GetSystemMetrics'; {$EXTERNALSYM GetSystemMetrics}
//~ function GetThreadLocale: LCID; stdcall; external kernel32 name 'GetThreadLocale'; {$EXTERNALSYM GetThreadLocale}
//~ function GetCPInfo(CodePage: UINT; var lpCPInfo: TCPInfo): BOOL; stdcall; external kernel32 name 'GetCPInfo'; {$EXTERNALSYM GetCPInfo}
//~
//~ procedure InitSysLocale;
//~ const
//~   LANG_ENGLISH = $09;
//~   SUBLANG_ENGLISH_US = $01;
//~
//~   SM_DBCSENABLED = 42; //{$EXTERNALSYM SM_DBCSENABLED}
//~   SM_MIDEASTENABLED = 74; //{$EXTERNALSYM SM_MIDEASTENABLED}
//~
//~   CP_ACP = 0; //{$EXTERNALSYM CP_ACP} // ANSI code page
//~   //CP_OEMCP = 1; {$EXTERNALSYM CP_OEMCP} // OEM  code page
//~   //CP_MACCP = 2; {$EXTERNALSYM CP_MACCP} // MAC  code page
//~
//~ var
//~   DefaultLCID: LCID;
//~   DefaultLangID: LANGID;
//~   AnsiCPInfo: TCPInfo;
//~   i: Integer;
//~   b: Byte;
//~ begin
//~   { Set default to English (US). }
//~   SysLocale.DefaultLCID := $0409;
//~   SysLocale.PriLangID := LANG_ENGLISH;
//~   SysLocale.SubLangID := SUBLANG_ENGLISH_US;
//~
//~   DefaultLCID := GetThreadLocale;
//~   if DefaultLCID <> 0 then SysLocale.DefaultLCID := DefaultLCID;
//~
//~   DefaultLangID := Word(DefaultLCID);
//~   if DefaultLangID <> 0 then begin
//~     SysLocale.PriLangID := DefaultLangID and $3FF;
//~     SysLocale.SubLangID := DefaultLangID shr 10;
//~   end;
//~
//~   SysLocale.MiddleEast := GetSystemMetrics(SM_MIDEASTENABLED) <> 0;
//~   SysLocale.FarEast := GetSystemMetrics(SM_DBCSENABLED) <> 0;
//~   if not SysLocale.FarEast then Exit;
//~
//~   GetCPInfo(CP_ACP, AnsiCPInfo);
//~   with AnsiCPInfo do begin
//~     i := 0;
//~     while (i < MAX_LEADBYTES) and ((LeadByte[i] or LeadByte[i + 1]) <> 0) do begin
//~       for b := LeadByte[i] to LeadByte[i + 1] do
//~         Include(LeadBytes, Char(b));
//~       inc(i, 2);
//~     end;
//~   end;
//~ end;
//~

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
// Read/Write String from/to File
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

function ReadStringFrom(const FileName: string; unixing: boolean = FALSE): string;
var
  h: THandle;
  sz: integer;
begin
  Result := '';
  if FileExists(filename) then begin
    h := fHandleOpenReadOnly(filename);
    if h <> _INVALID_ then begin
      try
        sz := fHandleGetFileSize(h, nil);
        if sz > 0 then begin
          SetLength(Result, sz);
          fHandleSetPos(h, 0, fPosFromBeginning);
          if fHandleRead(h, Result[1], sz) < 0 then
            Result := '';
        end;
      finally
        fHandleClose(h);
      end;
    end;
  end;
end;

function BufferSaveTo(const FileName: string; const Buffer; const MakeBackup: boolean): integer;
begin
  Result := -1;
end;

function WriteStringTo(const FileName: string; const S: string; const MakeBackupIfAlreadyExist: boolean): integer;
var
  h: THandle;
  Buffer: string;
begin
  Result := -1;
  if S <> '' then begin
    if FileExists(filename) then
      if MakeBackupIfAlreadyExist then
        MakeBackupFilename(filename);
    h := fHandleOpen(FileName, fmOpenReadWrite, fcCreateAlways, faNormal);
    if h <> _INVALID_ then begin
      try
        Buffer := S;
        Result := fHandleWrite(h, Buffer[1], length(S));
      finally
        fHandleClose(h);
      end;
    end;
  end;
end;

procedure MakeManifestFile(const AppName: string);
const
  _Manifest = '.Manifest';
  ApplicationManifest =
    ''^j +
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'^j +
    '<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">'^j +
    ^i'<assemblyIdentity'^j +
    ^i^i'processorArchitecture="*"'^j +
    ^i^i'version="5.1.0.0"'^j +
    ^i^i'type="win32"'^j +
    ^i^i'name="Microsoft.Windows.Shell.shell32"'^j +
    ^i^i'/>'^j +
    ^i'<description>Windows Shell</description>'^j +
    ^i'<dependency>'^j +
    ^i^i'<dependentAssembly>'^j +
    ^i^i^i'<assemblyIdentity'^j +
    ^i^i^i^i'type="win32"'^j +
    ^i^i^i^i'name="Microsoft.Windows.Common-Controls"'^j +
    ^i^i^i^i'version="6.0.0.0"'^j +
    ^i^i^i^i'publicKeyToken="6595b64144ccf1df"'^j +
    ^i^i^i^i'language="*"'^j +
    ^i^i^i^i'processorArchitecture="*"'^j +
    ^i^i^i^i'/>'^j +
    ^i^i'</dependentAssembly>'^j +
    ^i'</dependency>'^j +
    '</assembly>'^j +
    '';

var
  fx: string;
begin
  fx := AppName + _Manifest;
  if not FileExists(fx) then WriteStringTo(fx, ApplicationManifest, FALSE);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
// FILE / DIR BROWSER
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
//uses ShlObj;

const
  { For finding a folder to start document searching: }
  BIF_RETURNONLYFSDIRS = $0001; {$EXTERNALSYM BIF_RETURNONLYFSDIRS}
  { For starting the Find Computer: }
  BIF_DONTGOBELOWDOMAIN = $0002; {$EXTERNALSYM BIF_DONTGOBELOWDOMAIN}
  BIF_STATUSTEXT = $0004; {$EXTERNALSYM BIF_STATUSTEXT}
  BIF_RETURNFSANCESTORS = $0008; {$EXTERNALSYM BIF_RETURNFSANCESTORS}
  BIF_EDITBOX = $0010; {$EXTERNALSYM BIF_EDITBOX}
  BIF_VALIDATE = $0020; {$EXTERNALSYM BIF_VALIDATE} { insist on valid result (or CANCEL) }
  BIF_BROWSEFORCOMPUTER = $1000; { Browsing for Computers. }{$EXTERNALSYM BIF_BROWSEFORCOMPUTER}
  BIF_BROWSEFORPRINTER = $2000; { Browsing for Printers }{$EXTERNALSYM BIF_BROWSEFORPRINTER}
  BIF_BROWSEINCLUDEFILES = $4000; { Browsing for Everything }{$EXTERNALSYM BIF_BROWSEINCLUDEFILES}

type
  HWND = type LongWord;
  WPARAM = longint; {$EXTERNALSYM WPARAM}
  UINT = Longword; {$EXTERNALSYM UINT}
  LPARAM = longint; {$EXTERNALSYM LPARAM}
  //LRESULT = Longint;

  BFFCALLBACK = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer stdcall;
  TFNBFFCallBack = type BFFCALLBACK; {$EXTERNALSYM BFFCALLBACK}

  { TItemIDList -- List if item IDs (combined with 0-terminator) }
  //simplified
  PItemIDList = ^TItemIDList;
  TItemIDList = record
    cb: word; { Size of the ID (including cb itself) }
    abID: array[0..0] of byte; { The item ID (variable length) }
  end;

  TBrowseInfo = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PAnsiChar; { Return display name of item selected. }
    lpszTitle: PAnsiChar; { text to go in the banner over the tree. }
    ulFlags: UINT; { Flags that control the return stuff }
    lpfn: TFNBFFCallBack;
    lParam: LPARAM; { extra info that's passed back in callbacks }
    iImage: integer; { output var: where to return the Image index. }
  end;

const
  shell32 = 'shell32.dll';

function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList; stdcall;
  external Shell32 name 'SHBrowseForFolderA';

function BrowseCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer; stdcall;
begin //not yet finished
  Result := 0;
end;

function SimpleBrowseDirectory(const RootDir, Title: string): string;
var
  DirName: array[byte] of Char;
  pb: TBrowseInfo;

begin
  fillchar(pb, sizeof(pb), #0);
  pb.hwndOwner := 0; //CommonHandle;
  pb.pszDisplayName := DirName;
  pb.lpszTitle := pChar(Title);
  pb.ulFlags := BIF_RETURNONLYFSDIRS or BIF_DONTGOBELOWDOMAIN or
    BIF_RETURNFSANCESTORS or BIF_STATUSTEXT;
  pb.lpfn := @BrowseCallBack;
  ShBrowseForFolder(pb);
  Result := string(DirName);
end;

end.

