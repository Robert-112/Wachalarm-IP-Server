unit Funktionen;

interface

uses process, Classes, sysutils, StdCtrls, Graphics, Forms, Grids, IniFiles, strutils;

type
  UInt64 = 0..9223372036854775807;

procedure SaveStringGrid_IniLines(FileName : String; StringGrid : TStringGrid);
procedure LoadStringGrid_IniLines(FileName : TFileName; var StringGrid : TStringGrid);
procedure SaveStringGrid_IniXML(FileName : String; StringGrid : TStringGrid);
procedure LoadStringGrid_IniXML(FileName : TFileName; var StringGrid : TStringGrid);
procedure GridDeleteRow(const Grid : TStringGrid; RowNumber : Integer);
procedure SaveMemoLines(FileName : String; Memo : TMemo);
procedure LoadMemoLines(FileName : TFileName; var Memo : TMemo);
procedure GetFilesInDirectory(Directory: string; const Mask: string; List: TStrings; WithSubDirs, ClearList: Boolean);
procedure ListFileDir(Path: string; const Mask: string; FileList: TStrings);
function IniSectionExists(FileName : TFileName; SectionName : String): Boolean;
function GetIpAddrList(): string;
function Unc(s: string): UInt64;
function Alarmbild(Form_for_Image: TForm; Image_Width, Image_Height: Integer): TMemoryStream;
function memofindtext(AMemo:TMemo;Search_Text:string;Direction,Case_Sensitiv:boolean):integer;

implementation

uses
  Main, Config;

function Alarmbild(Form_for_Image: TForm; Image_Width, Image_Height: Integer): TMemoryStream;
var FormImage: TBitmap;
    Jpg: TJpegImage;
begin
  result := nil;
  // Bilderstellung starten
  result := TMemoryStream.Create;
  Jpg := TJpegImage.Create;
    if Image_Height <> 0 then
      Form_for_Image.Height := Image_Height;
    if Image_Width <> 0 then
      Form_for_Image.Width := Image_Width;
  // Screenshot von Form erstellen, Form muss dafür kurz auf Visible gesetzt werden
  // ToDo: bessere Funktion für Windows und Linux finden
  try
    Form_for_Image.show;
    FormImage := Form_for_Image.GetFormImage;
    FormImage.Canvas.Changed;
    // JPG aus BMP erstellen
    MainForm.I_Alarmbild.Picture.Assign(FormImage);
    Jpg.Assign(FormImage);
    jpg.CompressionQuality := strtoint(inttostr(ConfigForm.T_Qualli.Position) + '0');
  finally
    FormImage.Free;
    Form_for_Image.hide;
    try
      Jpg.SaveToStream(result);
    finally
      Jpg.Free;
    end;
  end;
end;

function IniSectionExists(FileName : TFileName; SectionName : String): Boolean;
var
  IniFile : TIniFile;
begin
  result := false;
  if (FileExists(FileName)) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      if IniFile.SectionExists(SectionName) then
        result := true;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
end;

function GetIpAddrList(): string;
var
  AProcess: TProcess;
  s: string;
  sl: TStringList;
  i: integer;
  {$IFDEF UNIX}
  n: integer;
  {$ENDIF}
begin
  Result:='';
  sl:=TStringList.Create();
  {$IFDEF WINDOWS}
  AProcess:=TProcess.Create(nil);
  AProcess.Executable  := 'ipconfig.exe';
  AProcess.Options := AProcess.Options + [poUsePipes, poNoConsole];
  try
    AProcess.Execute();
    Sleep(500); // poWaitOnExit not working as expected
    sl.LoadFromStream(AProcess.Output);
  finally
    AProcess.Free();
  end;
  for i:=0 to sl.Count-1 do
  begin
    if (Pos('IPv4', sl[i])=0) and (Pos('IP-', sl[i])=0) and (Pos('IP Address', sl[i])=0) then Continue;
    s:=sl[i];
    s:=Trim(Copy(s, Pos(':', s)+1, 999));
    if Pos(':', s)>0 then Continue; // IPv6
    Result:=Result+s+'  ';
  end;
  {$ENDIF}
  {$IFDEF UNIX}
  AProcess:=TProcess.Create(nil);
  AProcess.Executable := '/sbin/ifconfig';
  AProcess.Options := AProcess.Options + [poUsePipes, poWaitOnExit];
  try
    AProcess.Execute();
    //Sleep(500); // poWaitOnExit not working as expected
    sl.LoadFromStream(AProcess.Output);
  finally
    AProcess.Free();
  end;

  for i:=0 to sl.Count-1 do
  begin
    n:=Pos('inet addr:', sl[i]);
    if n=0 then Continue;
    s:=sl[i];
    s:=Copy(s, n+Length('inet addr:'), 999);
    Result:=Result+Trim(Copy(s, 1, Pos(' ', s)))+'  ';
  end;
  {$ENDIF}
  sl.Free();
end;

function Unc(s: string): UInt64;
var
  x: Integer;
begin
  Result := 0;
  for x := 1 to Length(s) do Result := Result + ((Ord(s[x])) shl ((x - 1) * 8));
end;

function MemoToHexString(MEMO: TMemo): string;
  function StrToHexString(const s : string):string;
  begin
     if s = '' then
        Result := ''
     else
     begin
        SetLength(Result, Length(s)*2);
        BinToHex(PChar(s), PChar(Result), Length(s));
     end;
  end;
  begin
  Result := StrToHexString(MEMO.Lines.CommaText);
  end;

  function HexStringToMemo(HS: String):string;
  function HexStringToStr(s : string):string;
  begin
     if s = '' then
        Result := ''
     else
     begin
        if Odd(length(s)) then
           s := '0'+s;
        SetLength(Result, Length(s) div 2);
        HexToBin(Pchar(s), PChar(Result), Length(Result));
     end;
  end;
begin
result := hexstringtostr(hs);
end;

function memofindtext(AMemo:TMemo;Search_Text:string;Direction,Case_Sensitiv:boolean):integer;
var switch_list:array[32..255] of integer;
    j,i,sstart,sendpos,searchpos,jumpvalve:integer;
    ordvalve:byte;
    cut:string;
begin
  sstart:=AMemo.SelStart;
  sendpos:=length(AMemo.lines.text);
  if Case_sensitiv=false then
    Search_text:=ansilowercase(Search_Text);
  //direction=true  - forward
  //direction=false - backward
  if Direction = True then
  begin
    //Create switch_list forward
    for j:=32 to 255 do
    begin
      switch_list[j]:=length(Search_Text);
      for i:=length(Search_Text) downto 1 do
      begin
        if chr(j)=Search_Text[i] then
        begin
          switch_list[j]:=length(Search_Text)-i;
          break;
        end;
      end;
    end;
    //Create switch list forward
    searchpos:=sstart+1;
    jumpvalve:=0;
    repeat
      searchpos:=searchpos+jumpvalve;
      if Case_sensitiv=false then
        ordvalve:= ord(ansilowercase(AMemo.lines.text[searchpos+1])[1])
      else
       ordvalve:= ord(AMemo.lines.text[searchpos+1]);
      if ordvalve<32 then
        jumpvalve:=length(Search_text)
      else
        jumpvalve:=switch_list[ordvalve];
      if jumpvalve=0 then
      begin
        result:=searchpos-length(search_text)+1;
        cut:=copy(AMemo.lines.text,searchpos-length(Search_Text)+2,length(search_text));
        if case_sensitiv=false then
          cut:=ansilowercase(cut);
        if (searchpos-sstart>=length(Search_Text)) and (cut=Search_text) then
          exit
        else
          inc(searchpos);
      end;
    until (searchpos>=sendpos);
  end
  else
  begin
    //Create switch_list backward
    for j:=32 to 255 do
    begin
      switch_list[j]:=length(Search_Text);
      for i:=1 to length(Search_Text) do
      begin
        if chr(j)=Search_Text[i] then
        begin
          switch_list[j]:=i-1;
          break;
        end;
      end;
    end;
    //Create switch_list backward
    searchpos:=sstart-1;
    jumpvalve:=0;
    repeat
      searchpos:=searchpos-jumpvalve;
      if Case_sensitiv=false then
        ordvalve:= ord(ansilowercase(AMemo.lines.text[searchpos+1])[1])
      else
        ordvalve:= ord(AMemo.lines.text[searchpos+1]);
      if ordvalve<32 then
        jumpvalve:=length(Search_text)
      else
        jumpvalve:=switch_list[ordvalve];
      if jumpvalve=0 then
      begin
        result:=searchpos;
        cut:=copy(AMemo.lines.text,searchpos+1,length(search_text));
        if case_sensitiv=false then
          cut:=ansilowercase(cut);
        if (sstart-searchpos>=length(Search_Text)) and (cut=search_text) then
          exit
        else
          dec(searchpos);
      end;
    until (searchpos<=0);
  end;
  result:=-1; //text not found
end;

procedure SaveStringGrid_IniLines(FileName : String; StringGrid : TStringGrid);
var
  IndexA  : Integer;
  IndexB  : Integer;
  IniFile : TIniFile;
begin
  if (FileName <> '') then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      IniFile.WriteInteger(StringGrid.Name + '.Main', 'Cols', StringGrid.ColCount);
      IniFile.WriteInteger(StringGrid.Name + '.Main', 'Rows', StringGrid.RowCount);
      for IndexA := 0 to Pred(StringGrid.ColCount) do
      begin
        for IndexB := 0 to Pred(StringGrid.RowCount) do
        begin
          Application.ProcessMessages;
          IniFile.WriteString(StringGrid.Name + '.' + IntToStr(Succ(IndexB)), IntToStr(Succ(IndexA)), StringGrid.Cells[IndexA, IndexB]);
        end;
      end;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
end;

procedure LoadStringGrid_IniLines(FileName : TFileName; var StringGrid : TStringGrid);
var
  IndexA  : Integer;
  IndexB  : Integer;
  IniFile : TIniFile;
  SectionExists : Boolean;
begin
  SectionExists := false;
  if (FileExists(FileName)) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      if IniFile.SectionExists(StringGrid.Name + '.Main') then
      begin
        SectionExists := true;
        //kleine Anpassung, denn ColCount gebe ich im Programm vor
        //StringGrid.ColCount := IniFile.ReadInteger(StringGrid.Name + '.Main', 'Cols', 1);
        StringGrid.RowCount := IniFile.ReadInteger(StringGrid.Name + '.Main', 'Rows', 1);
        for IndexA := 0 to Pred(StringGrid.ColCount) do
        begin
          Application.ProcessMessages;
          for IndexB := 0 to Pred(StringGrid.RowCount) do
          begin
            Application.ProcessMessages;
            StringGrid.Cells[IndexA, IndexB] := IniFile.ReadString(StringGrid.Name + '.' + IntToStr(Succ(IndexB)), IntToStr(Succ(IndexA)), '');
          end;
        end;
        StringGrid.AutoSizeColumns;
      end;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
  if SectionExists = false then
    // deaktiviert, da veraltet
    // SaveStringGrid_IniLines(Filename,StringGrid);
end;

procedure SaveStringGrid_IniXML(FileName : String; StringGrid : TStringGrid);
var
  IniFile: TIniFile;
  StringGridData_Bytes: Integer;
  StringGridData: String;
  AStream: TMemoryStream;
begin
  if (FileName <> '') then
  begin
    StringGridData := '';
    StringGridData_Bytes := 0;
    AStream := TMemoryStream.Create;
    try
      Application.ProcessMessages;
      StringGrid.SaveOptions := [soDesign,soPosition,soAttributes,soContent];
      StringGrid.SaveToStream(AStream);
      AStream.Position := 0;
      SetLength(StringGridData, AStream.Size);
      StringGridData_Bytes := AStream.Read(StringGridData[1], AStream.Size);
      SetLength(StringGridData, StringGridData_Bytes);
      // Zeilenumbrüche entfernen
      StringGridData := StringReplace(StringGridData, #13#10, '', [rfReplaceAll]);
    finally
      AStream.Free;
    end;
    IniFile := TIniFile.Create(FileName);
    try
      IniFile.WriteString(StringGrid.Name + '.XML', 'XML-Data', StringGridData);
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
end;

procedure LoadStringGrid_IniXML(FileName : TFileName; var StringGrid : TStringGrid);
var
  IniFile : TIniFile;
  SectionExists : Boolean;
  Len: integer;
  AString: AnsiString;
  AStream: TMemoryStream;
begin
  AString := '';
  SectionExists := false;
  if (FileExists(FileName)) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      if IniFile.SectionExists(StringGrid.Name + '.XML') then
      begin
        SectionExists := true;
        Application.ProcessMessages;
        AString := IniFile.ReadString(StringGrid.Name + '.XML', 'XML-Data', '');
        AStream := TMemoryStream.Create;
        try
          Len := Length(AString);
          AStream.Size := Len;
          AStream.Position := 0;
          AStream.Write(PChar(AString)^, Len);
          AStream.Position := 0;
          StringGrid.SaveOptions := [soDesign,soPosition,soAttributes,soContent];
          StringGrid.LoadFromStream(AStream);
        finally
          AStream.Free;
        end;
        StringGrid.AutoSizeColumns;
      end;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
  if SectionExists = false then
    SaveStringGrid_IniXML(Filename,StringGrid);
end;

procedure GridDeleteRow(const Grid : TStringGrid; RowNumber : Integer);
var
  i : Integer;
begin
  for i := RowNumber to Grid.RowCount - 2 do
  begin
    Application.ProcessMessages;
    Grid.Rows[i].Assign(Grid.Rows[i+ 1]);
  end;
  Grid.Rows[Grid.RowCount-1].Clear;
  Grid.RowCount := Grid.RowCount - 1;
end;

procedure SaveMemoLines(FileName : String; Memo : TMemo);
var
  I       : Integer;
  IniFile : TIniFile;
begin
  if (FileName <> '') then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      if Memo.Lines.Count <> 0 then
      begin
        IniFile.Writeinteger(Memo.Name + '.Main', 'Lines', Memo.Lines.Count - 1);
        for I := 0 to Memo.Lines.Count - 1 do
        begin
          Application.ProcessMessages;
          IniFile.WriteString(Memo.Name + '.Lines', 'Line_' + IntToStr(I), Memo.Lines.Strings[I]);
        end;
      end;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
end;

procedure LoadMemoLines(FileName : TFileName; var Memo : TMemo);
var
  I       : Integer;
  IniFile : TIniFile;
  SectionExists : Boolean;
begin
  SectionExists := false;
  if (FileExists(FileName)) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      if IniFile.SectionExists(Memo.Name + '.Main') then
      begin
        SectionExists := true;
        Memo.Lines.Clear;
        for I := 0 to IniFile.ReadInteger(Memo.Name + '.Main', 'Lines', - 1) do
        begin
          Application.ProcessMessages;
          Memo.Lines.Add(IniFile.readstring(Memo.Name + '.Lines', 'Line_' + IntToStr(I), '-' ));
        end;
      end;
    finally
      IniFile.Free;
      IniFile := nil;
    end;
  end;
  if SectionExists = false then
    SaveMemoLines(Filename, Memo);
end;

procedure GetFilesInDirectory(Directory: string; const Mask: string;
List: TStrings; WithSubDirs, ClearList: Boolean);

  procedure ScanDir(const Directory: string);
  var
    SR: TSearchRec;
  begin
    if FindFirst(Directory + Mask, faAnyFile and not faDirectory, SR) = 0 then try
      repeat
        List.Add({'Directory + }SR.Name)
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;

    if WithSubDirs then begin
      if FindFirst(Directory + '*.*', faAnyFile, SR) = 0 then try
        repeat
          if ((SR.attr and faDirectory) = faDirectory) and
             (SR.Name <> '.') and (SR.Name <> '..') then
            ScanDir(Directory + SR.Name + '\');
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;

begin
  List.BeginUpdate;
  try
    if ClearList then
      List.Clear;
    if Directory = '\' then Exit;
    if Directory[Length(Directory)] <> '\' then
      Directory := Directory + '\';
    ScanDir(Directory);
  finally
    List.EndUpdate;
  end;
end;

procedure ListFileDir(Path: string; const Mask: string; FileList: TStrings);
var
  SR: TSearchRec;
begin
  if FindFirst(Path + Mask, faAnyFile and not faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        FileList.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;

  end;
  FindClose(SR);
end;

end.
