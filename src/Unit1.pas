unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, SynEdit, SynMemo, SynUniHighlighter,
  SynEditHighlighter;
type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    List: TComboBox;
    Label3: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Memo1: TSynMemo;
    SynUniSyn1: TSynUniSyn;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses cxpos, ChPos, fDirFunc;
var
  tx, ty: txSearch;
  GUpcaseTable : array[0..255] of char;
  GUpcaseLUT: Pointer;
{$R *.dfm}

function FastPosBack(const aSourceString, aFindString : string; const aSourceLen, aFindLen, StartPos : Integer) : Integer;
var
  SourceLen : Integer;
begin
  if aFindLen < 1 then begin
    Result := 0;
    exit;
  end;
  if aFindLen > aSourceLen then begin
    Result := 0;
    exit;
  end;

  if (StartPos = 0) or  (StartPos + aFindLen > aSourceLen) then
    SourceLen := aSourceLen - (aFindLen-1)
  else
    SourceLen := StartPos;

  asm
          push ESI
          push EDI
          push EBX

          mov EDI, aSourceString
          add EDI, SourceLen
          Dec EDI

          mov ESI, aFindString
          mov ECX, SourceLen
          Mov  Al, [ESI]

    @ScaSB:
          cmp  Al, [EDI]
          jne  @NextChar

    @CompareStrings:
          mov  EBX, aFindLen
          dec  EBX
          jz   @FullMatch

    @CompareNext:
          mov  Ah, [ESI+EBX]
          cmp  Ah, [EDI+EBX]
          Jnz  @NextChar

    @Matches:
          Dec  EBX
          Jnz  @CompareNext

    @FullMatch:
          mov  EAX, EDI
          sub  EAX, aSourceString
          inc  EAX
          mov  Result, EAX
          jmp  @TheEnd
    @NextChar:
          dec  EDI
          dec  ECX
          jnz  @ScaSB

          mov  Result,0

    @TheEnd:
          pop  EBX
          pop  EDI
          pop  ESI
  end;
end;

function FastPosBackNoCase(const aSourceString, aFindString : string; const aSourceLen, aFindLen, StartPos : Integer) : Integer;
var
  SourceLen : Integer;
begin
  if aFindLen < 1 then begin
    Result := 0;
    exit;
  end;
  if aFindLen > aSourceLen then begin
    Result := 0;
    exit;
  end;

  if (StartPos = 0) or  (StartPos + aFindLen > aSourceLen) then
    SourceLen := aSourceLen - (aFindLen-1)
  else
    SourceLen := StartPos;

  asm
          push ESI
          push EDI
          push EBX

          mov  EDI, aSourceString
          add  EDI, SourceLen
          Dec  EDI

          mov  ESI, aFindString
          mov  ECX, SourceLen

          mov  EDX, GUpcaseLUT
          xor  EBX, EBX

          mov  Bl, [ESI]
          mov  Al, [EDX+EBX]

    @ScaSB:
          mov  Bl, [EDI]
          cmp  Al, [EDX+EBX]
          jne  @NextChar

    @CompareStrings:
          PUSH ECX
          mov  ECX, aFindLen
          dec  ECX
          jz   @FullMatch

    @CompareNext:
          mov  Bl, [ESI+ECX]
          mov  Ah, [EDX+EBX]
          mov  Bl, [EDI+ECX]
          cmp  Ah, [EDX+EBX]
          Jz   @Matches

    //Go back to findind the first char
          POP  ECX
          Jmp  @NextChar

    @Matches:
          Dec  ECX
          Jnz  @CompareNext

    @FullMatch:
          POP  ECX

          mov  EAX, EDI
          sub  EAX, aSourceString
          inc  EAX
          mov  Result, EAX
          jmp  @TheEnd
    @NextChar:
          dec  EDI
          dec  ECX
          jnz  @ScaSB

          mov  Result,0

    @TheEnd:
          pop  EBX
          pop  EDI
          pop  ESI
  end;
end;

function IsPunctuation(s : Char):Boolean;
begin
  Result := False;
  if s in [Chr(10), ' ','&','*','%','@','^','|','{','}','+','/','\',':',';','`','"','''','.',',','-','_','?','!','$','(',')','[',']'] then Result := True;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
  S,word,sm,sx : String;
  i,x : integer;
  cont : boolean;
  n1,n2,n3,n : integer;
  m1,m2,m3,m : integer;
  kw:TSynSymbolGroup;
  r:TSynRange;
begin
  Screen.Cursor := crHourGlass;
  memo1.lines.clear;
  word:= edit1.text;
  //if Checkbox1.Checked then word := ' ' + word + ' ';
  case List.ItemIndex of
    0 : S := ReadStringFrom('dictionary-phrases');
    1 : S := ReadStringFrom('dictionary-phrases0');
    2 : S := ReadStringFrom('literature');
    3 : S := ReadStringFrom('films');
    4 : S := ReadStringFrom('theory');
    5 : S := ReadStringFrom('computing');
    6 : S := ReadStringFrom('fortune-cookies');
    7 : S := ReadStringFrom('BNC-Spoken');
    8 : S := ReadStringFrom('BNC-Written');
    9 : S := ReadStringFrom('Brown');
    10: S := ReadStringFrom('corpus_bookworm');
    11: S := ReadStringFrom('Pet2000');
    12: S := ReadStringFrom('UWL');
  end;
  tx := txSearch.Create(word, CheckBox2.Checked);
  i := 1;
      begin
        x := length(S);
        repeat
        cont := true;
        i := tx.Pos(S, i);
        if Checkbox1.Checked then
         begin
          cont := false;
          sx := copy(S,i-1,1);
          if IsPunctuation(sx[1]) = true then cont := true;
          sx := copy(S, i + length(word), 1);
          if (IsPunctuation(sx[1]) = true and cont = true) then cont := true else cont := false;
         end;
        if cont = true then
          begin
            n1 := FastPosBack(S, '.', Length(S), 1, i);
		        n2 := FastPosBack(S, '?', Length(S), 1, i);
		        n3 := FastPosBack(S, '!', Length(S), 1, i);
		        if ((i-n1) < (i-n2)) and ((i-n1) < (i-n3)) then n := n1;
		        if ((i-n2) < (i-n1)) and ((i-n2) < (i-n3)) then n := n2;
		        if ((i-n3) < (i-n1)) and ((i-n3) < (i-n2)) then n := n3;
		        ty := txSearch.Create('.');
		        m1:= ty.Pos(S, i);
		        ty := txSearch.Create('?');
		        m2 := ty.Pos(S, i);
		        ty := txSearch.Create('!');
		        m3 := ty.Pos(S, i);
		        if ((m1-1) < (m2-1)) and ((m1-1) < (m3-1)) then m := m1;
		        if ((m2-1) < (m1-1)) and ((m2-1) < (m3-1)) then m := m2;
		        if ((m3-1) < (m1-1)) and ((m3-1) < (m2-1)) then m := m3;
		        sm := copy(S,i-(i-n)+2,(i-n)+(m-i)-1);
		        if Memo1.Lines.IndexOf(sm) = -1 then Memo1.Lines.Add(sm);
          end;
        inc(i);
        until i = 1;
      end;
      SynUniSyn1.MainRules.Reset;
      synunisyn1.MainRules.Clear;
      Memo1.Highlighter:=nil;
      kw:=TSynSymbolGroup.Create('',TSynHighlighterAttributes.Create('unknown'));
      kw.Name:='Search Results';
      kw.Attribs.Foreground:=clBlack;
      kw.Attribs.Background:=clYellow;
      kw.KeywordsList.add(Edit1.Text);
      {kw.KeywordsList.add(Edit1.Text + 's');
      kw.KeywordsList.add(Edit1.Text + 'ed');
      kw.KeywordsList.add(Edit1.Text + 'ing');
      kw.KeywordsList.add(Edit1.Text + 'er');
      kw.KeywordsList.add(Edit1.Text + 'est'); }
      SynUniSyn1.MainRules.AddSymbolGroup(kw);

  {
  r:=TSynRange.Create(Edit1.Text,' ');
  r.Name:='Strings ".."';
  r.DefaultAttri.Foreground:=clRed;
  r.DefaultAttri.Background:=clWhite;
  r.NumberAttri.Foreground:=clRed;
  r.NumberAttri.Background:=clWhite;
  r.CaseSensitive:=false;
  r.OpenSymbol.BrakeType:=btAny;
  synunisyn1.MainRules.AddRange(r); }

      synunisyn1.MainRules.CaseSensitive := not CheckBox1.Checked;
      Memo1.Highlighter:=SynUniSyn1;
      Screen.Cursor := crDefault;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
Edit1.SetFocus;
end;

end.



