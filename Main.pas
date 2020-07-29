unit Main;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, LazUTF8, base64, Controls,
  LConvEncoding, Forms, Dialogs, LCLType, StdCtrls, Menus, Grids, fpjson,
  ComCtrls, ExtCtrls, IniFiles, FileUtil, twitter, lclintf,
  blcksock, ftpsend, Funktionen, Types;

type

  { TMyThread Deklaration }

  TMyThread = class(TThread)
    procedure FTP_OnStatus(Sender: TObject; Response: Boolean; const Value: string);
  private
    Thr_Type, Thr_Log_Text: string;
    Thr_Fehlerindex: integer;
    Thr_Empfaenger_IP_now, Thr_Empfaenger_IP_all, Thr_Empfaenger_Wache, Thr_Einsatznummer, Thr_Zusatztext: string;
    Thr_Tw_Text, Thr_Tw_ConsumerKey, Thr_Tw_ConsumerSecret, Thr_Tw_AuthToken, Thr_Tw_AuthSecret, Thr_Tw_ProxyHost, Thr_Tw_ProxyPort, Thr_Tw_ProxyUser, Thr_Tw_ProxyPass, Thr_FTP_User, Thr_FTP_Pass: string;
    Thr_Stream: TMemoryStream;
    FTwitter: TTwitter;
    procedure ShowStatus;
	procedure alert_Web;					
    procedure alert_FTP;
    procedure alert_Twitter;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);
  end;

  { TMainForm Deklaration }

  TMainForm = class(TForm)
    I_Alarmbild: TImage;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    GroupBox1: TGroupBox;
    ImageList1: TImageList;
    ImageList2: TImageList;
    Label1: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    L_Auftragsstatus: TLabel;
    Label4: TLabel;
    L_Version: TLabel;
    Label6: TLabel;
    L_Ip: TLabel;
    Fenster1: TMenuItem;
    MenuItem1: TMenuItem;
    AlarmSimulation1: TMenuItem;
    M_StringReplace_Picture: TMemo;
    M_Wachenfilter: TMemo;
    SG_WaipChronik: TStringGrid;
    SG_Twitter_Filter: TStringGrid;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TwitterFenster1: TMenuItem;
    WachalarmFenster1: TMenuItem;
    M_Auftrag: TMemo;
    M_StringReplace_Tweet: TMemo;
    PageControl2: TPageControl;
    PageControl3: TPageControl;
    PG_Verarbeitungsstatus: TProgressBar;
    SG_Twitter: TStringGrid;
    SG_IP_Replace: TStringGrid;
    SG_TweetChronik: TStringGrid;
    StatusBar1: TStatusBar;
    SG_Clients: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    Timer1: TTimer;
    PageControl1: TPageControl;
    MainMenu1: TMainMenu;
    Programm1: TMenuItem;
    Einstellungen1: TMenuItem;
    Beenden1: TMenuItem;
    Hilfe1: TMenuItem;
    ber1: TMenuItem;
    TabSheet2: TTabSheet;
    Verbindung1: TMenuItem;
    Log: TMemo;
    procedure AlarmSimulation1Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure LogChange(Sender: TObject);
    procedure M_StringReplace_PictureEditingDone(Sender: TObject);
    procedure M_StringReplace_TweetEditingDone(Sender: TObject);
    procedure M_WachenfilterEditingDone(Sender: TObject);
    procedure SG_ClientsKeyDown(Sender: TObject; var Key: Word);
    procedure SG_IP_ReplaceEditingDone(Sender: TObject);
    procedure SG_IP_ReplaceKeyDown(Sender: TObject; var Key: Word);
    procedure SG_TweetChronikKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SG_TwitterEditingDone(Sender: TObject);
    procedure SG_TwitterExit(Sender: TObject);
    procedure SG_TwitterKeyDown(Sender: TObject; var Key: Word);
    procedure SG_Twitter_FilterEditingDone(Sender: TObject);
    procedure SG_Twitter_FilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1StopTimer(Sender: TObject);
    procedure TwitterFenster1Click(Sender: TObject);
    procedure Verbindung1Click(Sender: TObject);
    procedure Beenden1Click(Sender: TObject);
    procedure WachalarmFenster1Click(Sender: TObject);
    procedure WAIP_Auslesen;
    procedure Alarmierung_durchfuehren(Simulation: Boolean);
    procedure Twitter_Alarm(T_Wache, T_Einsatznummer, T_Empfanger_IP_all, T_Empfanger_IP_now: String; Simulation: Boolean);
    procedure FTP_Alarm(F_Wache, F_Einsatznummer, F_Empfanger_IP_all, F_Empfanger_IP_now, F_UDP_Text: String; Simulation: Boolean);
	procedure Web_Alarm(Simulation: Boolean);										 
    procedure Client_Status(S_Fehlerindex: integer; S_Typ, S_Wache, S_IP, S_Einsatznummer, S_Meldung: String);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Einstellungen1Click(Sender: TObject);
    procedure ber1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

// Record der Einsatzmittel
Type TEinsatzRecord = Record
  Status: string;
  IP: string;
  Wache: string;
  Fahrzeug: string;
  Zuget_zeit: string;
  Alarm_zeit: string;
  Ausrueck_zeit: string;
end;

// globale Variablen
var
  MainForm: TMainForm;
  Einsatzmittel: Array Of TEinsatzRecord;
  E_Ort, E_Ortsteil, E_Strasse, E_Objekt, E_Objektnummer, E_Objektart, E_Einsatzart, E_Stichwort, 
  E_Sondersignal, E_Einsatznummer, E_Besonderheiten, E_PName, E_Alarmzeit, E_Wachennummer, E_X, E_Y,
  E_Alarmierte_EM, E_Mitausgerueckte_EM, E_UUID, Dir, Slash, Udp_Sound, User, Pass: String;
  Fehlerindex, Anzahl_aktuelle_Alarme, Reset_Timer: Integer;
  Config_INI: TIniFile;

implementation

{$R *.lfm}
{$R credentials.res}

uses
  Config, Alarm_Picture, Twitter_Picture, Simulation;

{==============================================================================}
{=========== TMainForm ========================================================}
{==============================================================================}

procedure TMainForm.FormCreate(Sender: TObject);
var Wa_Log: File;
    RS: TResourceStream;
    i: integer;
begin
  // globale Variablen setzen
  {$ifdef  Windows}
  Slash := '\';
  {$else}
  Slash := '/';
  {$endif}
  Fehlerindex := 0;
  Anzahl_aktuelle_Alarme := 0;
  Reset_Timer := 0;
  DefaultFormatSettings.DateSeparator := '.';
  DefaultFormatSettings.TimeSeparator := ':';
  DefaultFormatSettings.ShortDateFormat := 'dd.mm.yyyy';
  DefaultFormatSettings.ShortTimeFormat := 'hh:nn:ss';
  // IP ermitteln
  L_IP.Caption := GetIpAddrList();
  // PageControl-Seiten auf aktiv setzen
  PageControl1.ActivePage := TabSheet4;
  PageControl2.ActivePage := TabSheet6;
  PageControl3.ActivePage := TabSheet5;
  // aktuelles Verzeichnis der .exe Auslesen
  GetDir(0, Dir);
  // Verzeichnis 'config' erstellen, falls nicht existent
  If Not DirectoryExists(Dir + Slash + 'config') then
    CreateDir (Dir + Slash + 'config');
  Dir := Dir + Slash + 'config';
  // Log-Datei erstellen, falls nicht existent und laden
  if FileExists(Dir + Slash + 'WA-Log.txt') then
  begin
    AssignFile(Wa_Log, Dir + Slash + 'WA-Log.txt');
    ReSet(Wa_Log, 1);
  end
  else
  begin
    AssignFile(Wa_Log, Dir + Slash + 'WA-Log.txt');
    ReWrite(Wa_Log, 1);
  end;
  CloseFile(Wa_Log);
  try
    Log.Lines.LoadFromFile(Dir + Slash + 'WA-Log.txt');
  except
  end;
  // Login-Daten aus Resource laden
  try
    RS := TResourceStream.Create(hinstance, 'FTPLOGIN', RT_RCDATA);
    SetString(Pass, RS.Memory, RS.Size);
    RS.Free;
    // Benutzername und Password ermitteln
    User := copy(Pass, 1, pos(',', Pass) - 1);
    Pass := stringreplace(Pass, User +',', '', []);
  except
    // Falls kein User/Pass ermittelbar (weil z.B. keine Resourcen-Datei), soll auch nichts gesetzt werden
    Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': Benutzername/Passwort konnte nicht eingelesen werden!');
    User := '';
    Pass := '';
  end;
  // Liste der Clients laden
  if IniSectionExists(Dir + Slash + 'config.ini', SG_Clients.Name + '.XML') = true then
    LoadStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Clients)
  else
  begin
    LoadStringGrid_IniLines(Dir + Slash + 'config.ini', SG_Clients);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Clients);
  end;
  // IP-Ersetzungen für mehrere Alarmierungen laden
  if IniSectionExists(Dir + Slash + 'config.ini', SG_IP_Replace.Name + '.XML') = true then
    LoadStringGrid_IniXML(Dir + Slash + 'config.ini', SG_IP_Replace)
  else
  begin
    LoadStringGrid_IniLines(Dir + Slash + 'config.ini', SG_IP_Replace);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_IP_Replace);
  end;
  // Twitter-Chronik laden
  if IniSectionExists(Dir + Slash + 'config.ini', SG_WaipChronik.Name + '.XML') = true then
    LoadStringGrid_IniXML(Dir + Slash + 'config.ini', SG_WaipChronik)
  else
  begin
    LoadStringGrid_IniLines(Dir + Slash + 'config.ini', SG_WaipChronik);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_WaipChronik);
  end;
  // Twitter-Accounts laden
  if IniSectionExists(Dir + Slash + 'config.ini', SG_Twitter.Name + '.XML') = true then
    LoadStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter)
  else
  begin
    LoadStringGrid_IniLines(Dir + Slash + 'config.ini', SG_Twitter);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter);
  end;
  // Twitter-Filter laden
  if IniSectionExists(Dir + Slash + 'config.ini', SG_Twitter_Filter.Name + '.XML') = true then
    LoadStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter_Filter)
  else
  begin
    LoadStringGrid_IniLines(Dir + Slash + 'config.ini', SG_Twitter_Filter);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter_Filter);
  end;
  // Twitter-Chronik laden
  if IniSectionExists(Dir + Slash + 'config.ini', SG_TWeetChronik.Name + '.XML') = true then
    LoadStringGrid_IniXML(Dir + Slash + 'config.ini', SG_TWeetChronik)
  else
  begin
    LoadStringGrid_IniLines(Dir + Slash + 'config.ini', SG_TWeetChronik);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_TWeetChronik);
  end;
  // Memos laden
  LoadMemoLines(Dir + Slash + 'config.ini', M_Wachenfilter);
  LoadMemoLines(Dir + Slash + 'config.ini', M_StringReplace_Tweet);
  LoadMemoLines(Dir + Slash + 'config.ini', M_StringReplace_Picture);
  // Picklist in SG_Twitter_Filter anpassen
  SG_Twitter_Filter.Columns[0].PickList.Clear;
      for i := 1 to SG_Twitter.RowCount - 1 do
        SG_Twitter_Filter.Columns[0].PickList.Add(SG_Twitter.Cells[0, i]);
  // MainForm formatieren
  MainForm.Height := 600;
  MainForm.Width := 1000;
  MainForm.Position := poScreenCenter;
  MainForm.WindowState := wsNormal;
end;

procedure TMainForm.Client_Status(S_Fehlerindex: integer; S_Typ, S_Wache, S_IP, S_Einsatznummer, S_Meldung: String);
var Alarm_Status, info, info_ok, info_err, Wachalarm_Client_Info: string;
    i, Status_Zeile: integer;
    Adresse_bekannt: boolean;
    jData: TJSONData;
begin
  // Variablen zuruecksetzen
  Adresse_bekannt := false;
  Status_Zeile := 0;
  Alarm_Status := '';
  Wachalarm_Client_Info := '';
  info := '';
  info_ok := '';
  info_err := '';
  // Fehlermeldungen festlegen
  if S_Typ = 'WEB' then
  begin
    // Unicode Character 'GLOBE WITH MERIDIANS' (U+1F310)
    S_Typ := #$F0#$9F#$8C#$90 + ' Web';
    // Wachalarm Client-Information von S_Meldung nach info_ok / info_err kopieren
    S_Meldung := 'Siehe externe Anwendung.';
    info_ok := '';
    info_err := '';
  end;		   
  if S_Typ = 'FTP' then
  begin
    // Unicode Character 'TELEVISION' (U+1F4FA)
    S_Typ := #$F0#$9F#$93#$BA + ' Wachalarm';
    // Wachalarm Client-Information von S_Meldung nach info_ok / info_err kopieren
    if pos(' {', S_Meldung) > 0 then
    begin
      Wachalarm_Client_Info := Copy(S_Meldung, pos(' {', S_Meldung), length(S_Meldung));
      S_Meldung := StringReplace(S_Meldung, Wachalarm_Client_Info, '', []);
    end;
    info_ok := 'Wachalarm(e) erfolgreich gesendet.' + Wachalarm_Client_Info;
    info_err := 'Fehler beim senden des Wachalarms, bitte Log-Datei pruefen!' + Wachalarm_Client_Info;
  end;
  if S_Typ = 'Twitter' then
  begin
    // Unicode Character 'BIRD' (U+1F426)
    S_Typ := #$F0#$9F#$90#$A6 + ' Twitter';
    info_ok := 'Tweet erfolgreich gesendet.';
    info_err := 'Fehler beim senden des Tweets, bitte Log-Datei pruefen!';
    // wenn kenn Fehler in Tweet, dann weitere Daten in Tabellen hinterlegen
    if S_Fehlerindex = 0 then
    begin
      jData := GetJSON(S_Meldung);
      try
        // Tweet-ID in Chronik hinterlegen, für spätere Replys
        for i := 1 to SG_TWeetChronik.RowCount - 1 do
        begin
          if (SG_TweetChronik.Cells[0, i] = S_IP) AND (SG_TweetChronik.Cells[1,i] = S_Einsatznummer) then
          begin
            try
              SG_TweetChronik.Cells[3, i] := Jdata.FindPath('id_str').AsString;
            except
              SG_TweetChronik.Cells[3, i] := '';
            end;
          end;
        end;
        // echten Twitter-User-Namen in Accounts hinterlegen für Bild
        for i := 1 to SG_Twitter.RowCount - 1 do
        begin
          if (SG_Twitter.Cells[0, i] = S_IP) and (Jdata.FindPath('user.name').AsString <> '') then
            try
              SG_Twitter.Cells[1, i] := Jdata.FindPath('user.name').AsString;
            except
            end;
        end;
        // Tweet auslesen
        try
          S_Meldung := Jdata.FindPath('EVI-Text').AsString;
        except
          S_Meldung :='Fehler beim Parsen der Twitter-Rueckmeldung!';
        end;
      finally
        jData.Free;
      end;
    end;
    // Chronik auf 100 Einträge begrenzen
    while SG_TWeetChronik.RowCount - 1 > 100 do
    begin
      GridDeleteRow(SG_TweetChronik,1);
    end;
    SG_TweetChronik.AutoSizeColumns;
  end;
  // feststellen ob IP/Twiiter-Account bereits in SG_Clients vorhanden, um Status zuzuordnen
  for i := 1 to SG_Clients.RowCount - 1 do
  begin
    if SG_Clients.Cells[3, i] = S_IP then
    begin
      Adresse_bekannt := true;
      Status_Zeile := i;
    end;
  end;
  // Werte für SC_Clients setzen, wenn kein Fehler
  if S_Fehlerindex = 0 then
  begin
    // Unicode Character 'HEAVY CHECK MARK' (U+2714)
    Alarm_Status := #$E2#$9C#$94 + ' OK';
    info := info_ok;
  end;
  // Werte fuer SC_Clients setzen, wenn ein oder mehrere Fehler
  if S_Fehlerindex <> 0 then
  begin
    // Unicode Character 'CROSS MARK' (U+274C)
    if S_Fehlerindex > 1 then
      Alarm_Status := #$E2#$9D#$8C + ' ERR (' + inttostr(S_Fehlerindex) + ')'
    else
      Alarm_Status := #$E2#$9D#$8C + ' ERR';
    info := info_err;
  end;
  // bestehenden Eintrag in SG_Clients ändern, falls Wache bekannt
  if Adresse_bekannt = true then
  begin
    SG_Clients.Cells[0, Status_Zeile] := Alarm_Status;
    SG_Clients.Cells[1, Status_Zeile] := datetostr(date) + '-' + timetostr(time);
    SG_Clients.Cells[2, Status_Zeile] := S_Typ;
    SG_Clients.Cells[3, Status_Zeile] := S_IP;
    SG_Clients.Cells[4, Status_Zeile] := S_Wache;
    SG_Clients.Cells[5, Status_Zeile] := S_Einsatznummer;
    SG_Clients.Cells[6, Status_Zeile] := S_Meldung;
    SG_Clients.Cells[7, Status_Zeile] := info;
  end
  // neuer Eintrag in SG_Clients, falls Wache noch nicht bekannt
  else
  begin
    SG_Clients.RowCount := SG_Clients.RowCount + 1;
    SG_Clients.Cells[0, SG_Clients.RowCount - 1] := Alarm_Status;
    SG_Clients.Cells[1, SG_Clients.RowCount - 1] := datetostr(date) + '-' + timetostr(time);
    SG_Clients.Cells[2, SG_Clients.RowCount - 1] := S_Typ;
    SG_Clients.Cells[3, SG_Clients.RowCount - 1] := S_IP;
    SG_Clients.Cells[4, SG_Clients.RowCount - 1] := S_Wache;
    SG_Clients.Cells[5, SG_Clients.RowCount - 1] := S_Einsatznummer;
    SG_Clients.Cells[6, SG_Clients.RowCount - 1] := S_Meldung;
    SG_Clients.Cells[7, SG_Clients.RowCount - 1] := info;
  end;
  // Tabelle anpassen und nach Zeit sortieren
  SG_Clients.AutoSizeColumns;
  SG_Clients.SortOrder := soDescending;
  SG_Clients.SortColRow(true, 1);
  // Alarm von der Anzahl der aktuellen Alarme wieder abziehen
  if Anzahl_aktuelle_Alarme > 0 then
    Anzahl_aktuelle_Alarme := Anzahl_aktuelle_Alarme - 1;
end;

procedure TMainForm.WAIP_Auslesen;
var i, j, em: integer;
    Auslesetext, Zeile_I, tmp_Ortslage: string;
begin
  // lokale Variablen zurücksetzen
  Auslesetext := '';
  Zeile_I := '';
  em := 0;
  tmp_Ortslage := '';
  // globale Einsatz-Variablen zurücksetzen
  E_Ort := '';
  E_Ortsteil := '';
  E_Strasse := '';
  E_Objekt := '';
  E_Objektnummer := '';
  E_Objektart := '';
  E_Einsatzart := '';
  E_Stichwort := '';
  E_Sondersignal := '';
  E_Einsatznummer := '';
  E_Besonderheiten := '';
  E_PName := '';
  E_Alarmzeit := '';
  E_Wachennummer := '';
  E_Alarmierte_EM := '';
  E_Mitausgerueckte_EM := '';
  SetLength(Einsatzmittel, 0);
  // Ort auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Ort~', MainForm.M_Auftrag.Text)+5,50);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Ort := Auslesetext;
  // Ortsteil auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Ortsteil~',MainForm.M_Auftrag.Text)+10,50);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Ortsteil := Auslesetext;
  // Ortslage auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Ortslage~',MainForm.M_Auftrag.Text)+10,50);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  tmp_Ortslage := Auslesetext;
  // Orsteil und Ortslage verketten, falls Ortslage vorhanden
  if Trim(tmp_Ortslage) <> '' then
  begin
    // wenn Ortsteil leer, aber Ortslage, dann Ortslage hinterlegen, sonst Ortslage hinzufuegen
    if Trim(E_Ortsteil) = '' then
      E_Ortsteil := tmp_Ortslage
    else
      E_Ortsteil := E_Ortsteil + ' / ' + tmp_Ortslage;
  end;
  // Strasse auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Strasse~',MainForm.M_Auftrag.Text)+9,50);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Strasse := Auslesetext;
  // Objekt auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext:= copy(MainForm.M_Auftrag.Lines.text,pos('Objekt~',MainForm.M_Auftrag.Text)+8,50);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Objekt := TrimLeft(Auslesetext);
  // Objektnummer auslesen, Variable setzen und entfernen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Objektnummer~',MainForm.M_Auftrag.Text)+14,20);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Objektnummer := Auslesetext;
  // Objektart auslesen, Variable setzen und entfernen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Objektart~',MainForm.M_Auftrag.Text)+11,20);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Objektart := Auslesetext;
  // Einsatzart auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Einsatzart~',MainForm.M_Auftrag.Text)+12,21);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Einsatzart := Auslesetext;
  // Alarmgrund (Stichwort) auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Alarmgrund~',MainForm.M_Auftrag.Text)+12,100);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Stichwort := Auslesetext;
  // Sondersignal auslesen, entfernen, Label zuweisen, Variable setzen und auf PictureForm darstellen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Sondersignal~',MainForm.M_Auftrag.Text)+14,20);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Sondersignal := Auslesetext;
  // Einsatznummer auslesen, Variable setzen und entfernen
  Auslesetext:= copy(MainForm.M_Auftrag.Lines.text,pos('Einsatznummer~',MainForm.M_Auftrag.Text)+15,20);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Einsatznummer := Auslesetext;
  // Besonderheiten auslesen, entfernen, Variable setzen und Label zuweisen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Besonderheiten~',MainForm.M_Auftrag.Text)+16,200);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Besonderheiten := Auslesetext;
  // Patientenname auslesen, Variable setzen und entfernen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Name~',MainForm.M_Auftrag.Text)+6,50);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_PName := Auslesetext;
  // Alarmierungszeit auslesen, Variable setzen und entfernen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('Alarmzeit~',MainForm.M_Auftrag.Text)+11,20);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Alarmzeit := Auslesetext;
  // Wachennummer auslesen, Variable setzen und entfernen
  Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('WachennumerFW~',MainForm.M_Auftrag.Text)+15,6);
  Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
  E_Wachennummer := Auslesetext;
  if (pos('WGS84_X~',MainForm.M_Auftrag.Text) > 0) and (pos('WGS84_Y~',MainForm.M_Auftrag.Text) > 0) then
  begin
    // X-Koordinate auslesen, Variable setzen und entfernen
    Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('WGS84_X~',MainForm.M_Auftrag.Text)+9,12);
    Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
    E_X := Auslesetext;
    // Y-Koordinate auslesen, Variable setzen und entfernen
    Auslesetext := copy(MainForm.M_Auftrag.Lines.text,pos('WGS84_Y~',MainForm.M_Auftrag.Text)+9,12);
    Delete(Auslesetext,pos('~',Auslesetext), (length(Auslesetext)-pos('~',Auslesetext)+1));
    E_Y := Auslesetext;
  end;  
  // Beteiligte Einsatzmittel auslesen (inkl. IP und Wachennname)
  for i := 0 to MainForm.M_Auftrag.Lines.Count do
  begin
    // aktuelle Zeile[i] in "Zeile_I" zwischenspeichern
    Zeile_I := MainForm.M_Auftrag.Lines[i];
    if (copy(Zeile_I,pos('MITAUS~',Zeile_I),7)='MITAUS~') or (copy(Zeile_I,pos('ALARM~',Zeile_I),6)='ALARM~') then
    begin
      // länge des Dynamischen Arrays anpassen
      SetLength(Einsatzmittel, length(Einsatzmittel) + 1);
      // zunächst die ersten ~~ entfernen
      Zeile_I := StringReplace(Zeile_I,'~~','',[]);
      // Status des Einsatzmittel auslesen und Text bis nächste ~~ entfernen
      Einsatzmittel[em].Status := Copy(Zeile_I,0,Pos('~~',Zeile_I)-1);
      Zeile_I := StringReplace(Zeile_I,Einsatzmittel[em].Status+'~~','',[]);
      // IP des Einsatzmittel auslesen und Text bis nächste ~~ entfernen
      Einsatzmittel[em].IP := copy(Zeile_I,0,pos('#~~',Zeile_I)-1);
      Zeile_I := StringReplace(Zeile_I,Einsatzmittel[em].IP+'#~~','',[]);
      // vor weiterer Verarbeitung IP-Adresse ggf. noch ersetzten bzw. weitere hinzufügen
      for j := 1 to SG_IP_Replace.RowCount - 1 do
      begin
        // Tabelle mit Einsatzmittel.IP vergleichen
        if Trim(SG_IP_Replace.Cells[0, j]) = Trim(Einsatzmittel[em].IP) then
        begin
          Einsatzmittel[em].IP := StringReplace(Einsatzmittel[em].IP, SG_IP_Replace.Cells[0, j], SG_IP_Replace.Cells[1, j], [rfReplaceAll, rfIgnoreCase]);
        end;
      end;
      // Wache des Einsatzmittel auslesen und Text bis nächste ~~ entfernen
      // Wichtig: Sonderzeichen beachten!
      Einsatzmittel[em].Wache := copy(Zeile_I,0,pos(#195#184+'~~',Zeile_I)-1);
      Zeile_I := StringReplace(Zeile_I,Einsatzmittel[em].Wache+#195#184+'~~','',[]);
      // Funkkenner des Einsatzmittel auslesen und Text bis nächste ~~ entfernen
      Einsatzmittel[em].Fahrzeug := copy(Zeile_I,0,pos('~~',Zeile_I)-1);
      Zeile_I := StringReplace(Zeile_I,Einsatzmittel[em].Fahrzeug+'~~','',[]);
      // Zuteilungszeit des Einsatzmittel auslesen und Text bis nächste ~~ entfernen
      Einsatzmittel[em].Zuget_zeit := copy(Zeile_I,0,pos('~~',Zeile_I)-1);
      Zeile_I := StringReplace(Zeile_I,Einsatzmittel[em].Zuget_zeit+'~~','',[]);
      // Alarmierungszeit des Einsatzmittel auslesen und Text bis nächste ~~ entfernen
      Einsatzmittel[em].Alarm_zeit := copy(Zeile_I,0,pos('~~',Zeile_I)-1);
      Zeile_I := StringReplace(Zeile_I,Einsatzmittel[em].Alarm_zeit+'~~','',[]);
      // Ausrückzeit des Einsatzmittel auslesen
      Einsatzmittel[em].Ausrueck_zeit := copy(Zeile_I,0,pos('~~',Zeile_I)-1);
      // 'em' erhöhen für nächsten Durchlauf
      em := em + 1;
    end;
  end;
end;

procedure TMainForm.Alarmierung_durchfuehren(Simulation: Boolean);
var i, j, direkter_Alarm: integer;
    TmpGuid: TGUID;
    UDP_Funkkenner, Alarmweg_now, Alarmweg_rest, Alarmweg_alarmiert, TMP_E_Ortsteil: string;
begin
  Alarmweg_alarmiert := '';
  // Prüfen ob UUID zu deisem Einsatz bereits existiert
  E_UUID := '';
  for i := 1 to SG_WaipChronik.RowCount - 1 do
  begin
    // Prüfen ob in WAIP-Chronik zu gleicher Einsatznummer (E_Einsatznummer) bereits ein Eintrag vorhanden ist
    if SG_WaipChronik.Cells[0,i] = E_Einsatznummer then
      E_UUID := SG_WaipChronik.Cells[1,i];
  end;
  // UUID erzeugen, falls noch nicht hinterlegt
  if E_UUID = '' then
  begin
    CreateGUID(TmpGuid);
    E_UUID := GUIDToString(TmpGuid);
    E_UUID := LowerCase(E_UUID);
    E_UUID := StringReplace(E_UUID, '{', '', []);
    E_UUID := StringReplace(E_UUID, '}', '', []);
    // Werte in Tabelle hinterlegen
    SG_WaipChronik.Cells[0, SG_WaipChronik.RowCount - 1] := E_Einsatznummer;
    SG_WaipChronik.Cells[1, SG_WaipChronik.RowCount - 1] := E_UUID;
  end;
  // Waip-Chronik auf 100 Einträge begrenzen
  while SG_WaipChronik.RowCount - 1 > 100 do
  begin
    GridDeleteRow(SG_WaipChronik,1);
  end;
  SG_WaipChronik.AutoSizeColumns;
  // Alarm an Wachalarm-Web uebergeben
  Web_Alarm(Simulation);
  // doppelte IP's aus Einsatzmittel.IP entfernen um doppelte Alarmierungen auszuschließen
  for i:=0 to high(Einsatzmittel) do
  begin
    if Einsatzmittel[i].IP <> '' then
    begin
      for j:=0 to i-1 do
      begin
        if Einsatzmittel[i].IP = Einsatzmittel[j].ip then
           Einsatzmittel[i].IP :='';
      end;
    end;
  end;
  // Alarmauftrag je Wache erstellen und versenden
  for i:=0 to high(Einsatzmittel) do
  begin
    // Variablen zurücksetzen
    UDP_Funkkenner := '';
    E_Alarmierte_EM := '';
    E_Mitausgerueckte_EM := '';
    Alarmweg_now := '';
    Alarmweg_rest := '';
    // Alarmierung nur wenn Einsatzmittel.IP in aktueller Zeile vorhanden
    if Einsatzmittel[i].IP <> '' then
    begin
      // Zugriff auf Programm wärend Schleifenverarbeitung ermöglichen
      Application.ProcessMessages;
      // Funkkenner auf "Alarm" oder "Mitaus" zuweisen (für jede Wache unterschiedlich)
      for j:=0 to high(Einsatzmittel) do
      begin
        direkter_Alarm := 0;
        // Korrektur für CELIOS: Zeilen ohne Alarm_zeit nicht alarmieren
        if config.ConfigForm.CB_Alarm_Zeit.Checked then
        begin
          if (Einsatzmittel[j].Status = 'ALARM') AND (Einsatzmittel[j].Alarm_zeit='') AND (Einsatzmittel[i].Wache = Einsatzmittel[j].Wache) then
            direkter_Alarm := 1;
        end
        else
        begin
          if (Einsatzmittel[j].Status = 'ALARM') AND (Einsatzmittel[j].Zuget_zeit <> '') AND (Einsatzmittel[j].Alarm_zeit='') AND (Einsatzmittel[i].Wache = Einsatzmittel[j].Wache) then
            direkter_Alarm := 1;
        end;
        if direkter_Alarm = 1 then
        begin
          // Alarmierte Einsatzmittel ermitteln
          if Einsatzmittel[j].Fahrzeug <> '' then
          begin
            if E_Alarmierte_EM = '' then
              E_Alarmierte_EM := Einsatzmittel[j].Fahrzeug
            else
              E_Alarmierte_EM := E_Alarmierte_EM + ', ' + Einsatzmittel[j].Fahrzeug;
            // Funkkenner für UDP-Packet ermitteln
            if UDP_Funkkenner = '' then
              UDP_Funkkenner := Rightstr(Einsatzmittel[j].Fahrzeug,8)
            else
              UDP_Funkkenner := UDP_Funkkenner + ' '+ Rightstr(Einsatzmittel[j].Fahrzeug,8);
          end;
        end
        else
        begin
          // Mitausrückende Einsatzmittel ermitteln
          if Einsatzmittel[j].Fahrzeug <> '' then
          begin
            if E_Mitausgerueckte_EM = '' then
              E_Mitausgerueckte_EM := Einsatzmittel[j].Fahrzeug
            else
              E_Mitausgerueckte_EM := E_Mitausgerueckte_EM +', ' +Einsatzmittel[j].Fahrzeug
          end;
        end;
      end;
      // eventuelle Leerzeichen am Anfang der Einsatzmittel entfernen
      while copy(E_Alarmierte_EM,0,1)= ' ' do
        E_Alarmierte_EM := StringReplace(E_Alarmierte_EM,' ','',[]);
      while copy(E_Mitausgerueckte_EM,0,1)= ' ' do
        E_Mitausgerueckte_EM := StringReplace(E_Mitausgerueckte_EM,' ','',[]);
      // Alarm nur senden, falls Einsatzmittel noch vorhanden
      if stringreplace(E_Alarmierte_EM,' ', '',[rfReplaceAll]) <> '' then
      begin
        Alarmweg_now := Einsatzmittel[i].IP;
        Alarmweg_rest := Einsatzmittel[i].IP;
        // Fehlerindex auf Null setzen für Auswertung aller Alarmwege
        Fehlerindex := 0;
        // an alle Alarmwege versenden
        while (Alarmweg_rest <> '') do
        begin
          Application.ProcessMessages;
          // Prüfen ob bereits ein Wert verarbeitet wurde
          if pos(',',Alarmweg_rest) = 1 then
            Alarmweg_rest := Stringreplace(Alarmweg_rest,',','',[]);
          // aktuellen Alarmweg ermitteln
          if copy(Alarmweg_rest,0,pos(',',Alarmweg_rest)-1) = '' then
            Alarmweg_now := Alarmweg_rest
          else
            Alarmweg_now := copy(Alarmweg_rest,0,pos(',',Alarmweg_rest)-1);
          // nochmals prüfen, ob Alarm nicht bereits alarmiert (kann durch IP-Replace der Fall sein)
          if  pos(Alarmweg_now,Alarmweg_alarmiert) = 0 then
          begin
            // prüfen ob es sich um Twitter-Account handelt
            if Pos('@', Alarmweg_now) <> 0 then
            begin
              // Tweet mittels hinterlegten Account senden
              Twitter_Alarm(Einsatzmittel[i].Wache, E_Einsatznummer, Einsatzmittel[i].IP, Alarmweg_now, Simulation);
            end
            // wenn kein @ in IP enthalten, dann FTP-Bild/UDP senden
            else
            begin
              // kleine Anpassung des Ortsteils um ein Leerzeichen für UDP-String
              TMP_E_Ortsteil := '';
              if E_Ortsteil <> '' then
                TMP_E_Ortsteil := ' ' + E_Ortsteil;
              // String für UDP-Soundausgabe erzeugen
              Udp_Sound := E_Einsatzart +'|'+ E_Ort + TMP_E_Ortsteil +'|'+ E_Stichwort +'|'+ UDP_Funkkenner + ' (' + StringReplace(E_Alarmierte_EM,', ', ' ',[rfReplaceAll]) + ') ' +'|'+ E_Sondersignal;
              // FTP-Upload durchfuehren
              FTP_Alarm(Einsatzmittel[i].Wache, E_Einsatznummer, Einsatzmittel[i].IP, Alarmweg_now, Udp_Sound, Simulation);
            end;
            // Alarmweg als alarmiert hinterlegen
            if Alarmweg_alarmiert = '' then
              Alarmweg_alarmiert := Alarmweg_now
            else
              Alarmweg_alarmiert := Alarmweg_alarmiert + ', ' + Alarmweg_now;
          end;
          // restliche Alarmwege ermitteln
          Alarmweg_rest := Stringreplace(Alarmweg_rest,Alarmweg_now, '', []);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.Web_Alarm(Simulation: Boolean);
var
  MyThread: TMyThread;
  i: integer;
  JSON_Sondersignal, JSONString: String;
begin
  // Sondersignal anpassen
  if E_Sondersignal = '[mit Sondersignal]' then
    JSON_Sondersignal := '1'
  else
    JSON_Sondersignal := '0';
  // JSON erzeugen
  JSONString := '{' +
    '"einsatzdaten": {' +
      '"uuid": "' + E_UUID + '",' +
      '"nummer": "' + E_Einsatznummer + '",' +
      '"alarmzeit": "' + E_Alarmzeit + '",' +
      '"art": "' + E_Einsatzart + '",' +
      '"stichwort": "' + E_Stichwort + '",' +
      '"sondersignal": ' + JSON_Sondersignal + ',' +
      '"besonderheiten": "' + StringReplace(E_Besonderheiten, #34, '', [rfReplaceAll]) + '",' +
      '"patient": "' + E_PName + '"' +
    '},' +
    '"ortsdaten": {' +
      '"ort": "' + StringReplace(E_Ort, #34, '', [rfReplaceAll]) + '",' +
      '"ortsteil": "' + StringReplace(E_Ortsteil, #34, '', [rfReplaceAll]) + '",' +
      '"strasse": "' + StringReplace(E_Strasse, #34, '', [rfReplaceAll]) + '",' +
      '"objekt": "' + StringReplace(E_Objekt, #34, '', [rfReplaceAll]) + '",' +
      '"objektnr": "' + E_Objektnummer + '",' +
      '"objektart": "' + E_Objektart + '",' +
      '"wachfolge": "' + E_Wachennummer + '",' +
      '"wgs84_x": "' + E_X + '",' +
      '"wgs84_y": "' + E_Y + '"' +
    '},' +
    '"alarmdaten": [';
  for i:=0 to high(Einsatzmittel) do
  begin
    JSONString := JSONString +
      '{"typ": "' + Einsatzmittel[i].Status + '",' +
      '"netzadresse": "' + StringReplace(Einsatzmittel[i].IP, #34, '', [rfReplaceAll]) + '",' +
      '"wachenname": "' + StringReplace(Einsatzmittel[i].Wache, #34, '', [rfReplaceAll]) + '",' +
      '"einsatzmittel": "' + StringReplace(Einsatzmittel[i].Fahrzeug, #34, '', [rfReplaceAll]) + '",' +
      '"zeit_a": "' + Einsatzmittel[i].Zuget_zeit + '",' +
      '"zeit_b": "' + Einsatzmittel[i].Alarm_zeit + '",' +
      '"zeit_c": "' + Einsatzmittel[i].Ausrueck_zeit + '"}';
    if i <> high(Einsatzmittel) then
      JSONString := JSONString + ', '
  end;
  JSONString := JSONString +  ']}';
  // Thread vorbereiten
  MyThread := TMyThread.Create(True); // With the True parameter it doesn't start automatically
  if Assigned(MyThread.FatalException) then
    raise MyThread.FatalException;
  // Variablen an Thread zuweisen
  MyThread.Thr_Type := 'WEB';
  MyThread.Thr_Tw_Text := '';
  MyThread.Thr_Tw_ConsumerKey := '';
  MyThread.Thr_Tw_ConsumerSecret := '';
  MyThread.Thr_Tw_AuthToken := '';
  MyThread.Thr_Tw_AuthSecret := '';
  MyThread.Thr_Tw_ProxyHost := '';
  MyThread.Thr_Tw_ProxyPort := '';
  MyThread.Thr_Tw_ProxyUser := '';
  MyThread.Thr_Tw_ProxyPass := '';
  MyThread.Thr_FTP_User := '';
  MyThread.Thr_FTP_Pass := '';
  MyThread.Thr_Stream := nil;
  MyThread.Thr_Empfaenger_IP_now := ConfigForm.E_ip_web.Text;
  MyThread.Thr_Empfaenger_IP_all := '';
  MyThread.Thr_Empfaenger_Wache := '';
  MyThread.Thr_Einsatznummer := '';
  MyThread.Thr_Zusatztext := JSONString;
  // Simulation?
  if Simulation = false then
  begin
    // Alarm zur Anzahl der aktuellen Alarme hinzuzählen
    Anzahl_aktuelle_Alarme := Anzahl_aktuelle_Alarme + 1;
    // Thread ausfuehren
    MyThread.start;
  end;
end;

procedure TMainForm.FTP_Alarm(F_Wache, F_Einsatznummer, F_Empfanger_IP_all, F_Empfanger_IP_now, F_UDP_Text: string; Simulation: Boolean);
var MyThread: TMyThread;
    E_Ort_WB: String;
begin
  // alle Label auf Alarm-Bild zurücksetzen
  PictureForm.LEinsatzart.Caption := '';
  PictureForm.LAlarmGrund.Caption := '';
  PictureForm.LSonderSig.Caption := '';
  PictureForm.LOrtsdaten.Caption := '';
  PictureForm.LBesonder.Caption := '';
  PictureForm.LEinsatzmittel.Caption := '';
  PictureForm.LMitaus.Caption := '';
  // Label Einsatzart und Stichwort auf Alarm-Bild setzen
  PictureForm.LEinsatzart.Caption := E_Einsatzart;
  PictureForm.LAlarmGrund.Caption := E_Stichwort;
  // Sondersignal setzen
  if E_Sondersignal = '[mit Sondersignal]' then
  begin
    PictureForm.LSonderSig.Font.Style := [];
    PictureForm.LSonderSig.Font.Style := [fsbold];
    PictureForm.LSonderSig.Font.Color := RGB(30,144,255);
    // Unicode Character 'POLICE CARS REVOLVING LIGHT' (U+1F6A8)
    PictureForm.LSonderSig.Caption := #$F0#$9F#$9A#$A8;
  end
  else
  begin
    PictureForm.LSonderSig.Font.Style := [];
    PictureForm.LSonderSig.Font.Style := [fsbold];
    PictureForm.LSonderSig.Font.Color := RGB(255,215,0);
    // Unicode Character 'BELL WITH CANCELLATION STROKE' (U+1F515)
    PictureForm.LSonderSig.Caption := #$F0#$9F#$94#$95;
  end;
  // Wachbereich für BF Cottbus zu E_Ort hinzufügen
  if leftstr(F_Wache, 5) = 'CB FW' then
  begin
    if (E_Wachennummer = '520101') AND (leftstr(E_Ort, 2) <> 'WB') then
      E_Ort_WB := 'WB1 ' + E_Ort;
    if (E_Wachennummer = '520201') AND (leftstr(E_Ort, 2) <> 'WB') then
      E_Ort_WB := 'WB2 ' + E_Ort;
  end
  else
    E_Ort_WB := E_Ort;
  // Ortsdaten zusammenfügen
  if E_Objekt <> '' then
    if PictureForm.LOrtsdaten.Caption <> '' then
      PictureForm.LOrtsdaten.Caption := PictureForm.LOrtsdaten.Caption + #13#10 + E_Objekt
    else
      PictureForm.LOrtsdaten.Caption := E_Objekt;
  if E_Ort_WB <> '' then
    if PictureForm.LOrtsdaten.Caption <> '' then
      PictureForm.LOrtsdaten.Caption := PictureForm.LOrtsdaten.Caption + #13#10 + E_Ort_WB
    else
     PictureForm.LOrtsdaten.Caption := E_Ort_WB;
  if E_Ortsteil <> '' then
    if PictureForm.LOrtsdaten.Caption <> '' then
      PictureForm.LOrtsdaten.Caption := PictureForm.LOrtsdaten.Caption + #13#10 + E_Ortsteil
    else
      PictureForm.LOrtsdaten.Caption := E_Ortsteil;
  if E_Strasse <> '' then
    if PictureForm.LOrtsdaten.Caption <> '' then
      PictureForm.LOrtsdaten.Caption := PictureForm.LOrtsdaten.Caption + #13#10 + E_Strasse
    else
      PictureForm.LOrtsdaten.Caption := E_Strasse;
  // Besonderheiten
  PictureForm.LBesonder.Caption := E_Besonderheiten;
  // Alarmierte Einsatzmittel für Bild untereinander schreiben
  PictureForm.LEinsatzmittel.Caption := StringReplace(E_Alarmierte_EM,', ',#13#10,[rfReplaceAll]);
  // Mitausgerückte Einsatzmittel ggf. mit Umbruch
  PictureForm.LMitaus.Caption :=  E_Mitausgerueckte_EM;
  // Thread vorbereiten
  MyThread := TMyThread.Create(True); // With the True parameter it doesn't start automatically
  if Assigned(MyThread.FatalException) then
    raise MyThread.FatalException;
  // Variablen an Thread zuweisen
  MyThread.Thr_Type := 'FTP';
  MyThread.Thr_Tw_Text := '';
  MyThread.Thr_Tw_ConsumerKey := '';
  MyThread.Thr_Tw_ConsumerSecret := '';
  MyThread.Thr_Tw_AuthToken := '';
  MyThread.Thr_Tw_AuthSecret := '';
  MyThread.Thr_Tw_ProxyHost := '';
  MyThread.Thr_Tw_ProxyPort := '';
  MyThread.Thr_Tw_ProxyUser := '';
  MyThread.Thr_Tw_ProxyPass := '';
  MyThread.Thr_FTP_User := User;
  MyThread.Thr_FTP_Pass := Pass;
  // Alarmbild in Auflösung 1024x768 erstellen
  MyThread.Thr_Stream := Alarmbild(PictureForm, 1024, 786);
  MyThread.Thr_Empfaenger_IP_now := F_Empfanger_IP_now;
  MyThread.Thr_Empfaenger_IP_all := F_Empfanger_IP_all;
  MyThread.Thr_Empfaenger_Wache := F_Wache;
  MyThread.Thr_Einsatznummer := F_Einsatznummer;
  MyThread.Thr_Zusatztext := F_UDP_Text;
  // Simulation?
  if Simulation = false then
  begin
    // Alarm zur Anzahl der aktuellen Alarme hinzuzählen
    Anzahl_aktuelle_Alarme := Anzahl_aktuelle_Alarme + 1;
    // Thread ausfuehren
    MyThread.start;
  end;
end;

procedure TMainForm.Twitter_Alarm(T_Wache, T_Einsatznummer, T_Empfanger_IP_all, T_Empfanger_IP_now: string; Simulation: Boolean);
var i, j, Wachenfilter, Tweetfilter, T_Account_Zeile, Wachen_Zeile :integer;
    nbs, T_Time, T_Date, T_Wachen, T_Einsatzdaten, Tweet, Reply_ID, Old_Str, New_Str: string;
    Wache_doppelt, wache_gefunden: boolean;
    MyThread: TMyThread;
    Arr_Wachen: Array of String;
    Wachen_zu_EM: Array Of TEinsatzRecord;
begin
  // Tweet zusammensetzen nach: [Datum&Uhrzeit] [Stichwort] [Einsatzort und Ortsteil] Wachen: [Alarmierte Wachen] [Dashboard-Link]
  T_Wachen := '';
  T_Einsatzdaten := '';
  SetLength(Arr_Wachen, 0);
  T_Account_Zeile := 0;
  Wachen_Zeile := 0;
  T_Date := datetostr(date);
  T_Time := leftstr(timetostr(time),5);
  Tweet := '';
  Reply_ID := '';
  // nps = non-breaking space; damit Texte auf Twitter an bestimmten stellen umgebrochen werden
  nbs := PChar(#$C2#$A0);
  // als erstes in Twitter-Tabelle nach Account suchen und Zeile merken
  for i := 1 to SG_Twitter.RowCount - 1 do
  begin
    if (SG_Twitter.Cells[0, i] = T_Empfanger_IP_now) then
      T_Account_Zeile := i
  end;
  // prüfen ob Einsatzart für diesen Account erlaubt
  for i := 1 to SG_Twitter_Filter.RowCount - 1 do
  begin
    // wenn Account in Filter-Liste dann auf Einsatzart prüfen
    if SG_Twitter_Filter.Cells[0, i] = SG_Twitter.Cells[0, T_Account_Zeile] then
    begin
      // Wenn zu Einsatzart kein Hacken gesetzt, dann T_Account_Ziele wieder auf 0 (Tweet wird nachfolgend nicht erstellt)
      if (E_Einsatzart = 'Brandeinsatz') and (SG_Twitter_Filter.Cells[1, i] = '0') then
        T_Account_Zeile  := 0;
      if (E_Einsatzart = 'Hilfeleistungseinsatz') and (SG_Twitter_Filter.Cells[2, i] = '0') then
        T_Account_Zeile := 0;
      if (E_Einsatzart = 'Rettungseinsatz') and (SG_Twitter_Filter.Cells[3, i] = '0') then
        T_Account_Zeile := 0;
      if (E_Einsatzart = 'Krankentransport') and (SG_Twitter_Filter.Cells[4, i] = '0') then
        T_Account_Zeile := 0;
      if (E_Einsatzart = 'Sonstiges') and (SG_Twitter_Filter.Cells[5, i] = '0') then
        T_Account_Zeile := 0;
    end;
  end;
  // jetzt Tweet erstellen, falls Account vorhanden/erlaubt
  if T_Account_Zeile = 0 then
    Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) +': Twitter-Account nicht hinterlegt, oder Tweet bei Einsatzart ' + E_Einsatzart + ' verworfen! ('+ T_Empfanger_IP_now + '): ' + Tweet)
  else
  begin
    // Symbol für Sondersignal am beginn anfügen
    if E_Sondersignal = '[mit Sondersignal]' then
      //Unicode Character 'POLICE CARS REVOLVING LIGHT' (U+1F6A8)
      Tweet := #$F0#$9F#$9A#$A8
    else
      //Unicode Character 'BELL WITH CANCELLATION STROKE' (U+1F515)
      Tweet := #$F0#$9F#$94#$95;
    //Datum und Uhrzeit anfühgen
    Tweet := Tweet + nbs + T_Date + nbs + T_Time;
    //Stichwort anfügen
    Tweet := Tweet + ' ' + StringReplace(E_Stichwort, ' ', nbs, [rfReplaceAll]);
    //Symbol für Orte anfügen Unicode Character 'GLOBE WITH MERIDIANS' (U+1F310)
    Tweet := Tweet + ' ' + #$F0#$9F#$8C#$90 + nbs;
    //Ort und Ortsteil anfügen
    if E_Ortsteil = '' then
      Tweet := Tweet + StringReplace(E_Ort, ' ', nbs, [rfReplaceAll])
    else
      Tweet := Tweet + StringReplace(E_Ort, ' ', nbs, [rfReplaceAll]) + ', ' + StringReplace(E_Ortsteil, ' ', nbs, [rfReplaceAll]);
    //Wachen ermitteln, falls für Account gewollt
    if SG_Twitter.Cells[3, T_Account_Zeile] = '1' then
    begin
      //Alarmierte Wachen ermitteln
      for i:=0 to high(Einsatzmittel) do
      begin
        Application.ProcessMessages;
        //vor Zusammenfassung filtern damit _nicht_ alle alarmierten Wachen im Tweet erscheinen
        Wachenfilter := 0;
        for j := 0 to M_Wachenfilter.Lines.Count-1 do
        begin
          if pos(M_Wachenfilter.Lines[j],Einsatzmittel[i].Wache) > 0 then
            Wachenfilter := Wachenfilter + 1;
        end;
        //Wachen für Tweet zusammenfassen, jedoch nur falls Wache nicht in Wachenfilter
        if Wachenfilter > 0 then
        begin
          //prüfen ob Wache nicht bereits im Array vorhanden
          Wache_doppelt := false;
          for j := 0 to high(Arr_Wachen) do
            if Arr_Wachen[j] = Einsatzmittel[i].Wache then
              Wache_doppelt := true;
          //Wache zu Array hinzufügen wenn nicht doppelt
          if Wache_doppelt = false then
          begin
            SetLength(Arr_Wachen, length(Arr_Wachen) + 1);
            Arr_Wachen[high(Arr_Wachen)] := Einsatzmittel[i].Wache;
          end;
        end;
      end;
    end;
    //String-Replace für gesamt Tweet und Arr_Wachen
    for i := 0 to M_StringReplace_Tweet.Lines.Count - 1 do
    begin
      Old_Str := copy(M_StringReplace_Tweet.Lines[i], 0, pos('==', M_StringReplace_Tweet.Lines[i]) - 1);
      New_Str := copy(M_StringReplace_Tweet.Lines[i], pos('==', M_StringReplace_Tweet.Lines[i]) + 2, 100);
      //String-Replace im Tweet
      Tweet := StringReplace(Tweet, Old_Str, New_Str, [rfReplaceAll]);
      //String-Replace in Wachen
      if SG_Twitter.Cells[3, T_Account_Zeile] = '1' then
        for j := 0 to high(Arr_Wachen) do
          Arr_Wachen[j] := StringReplace(Arr_Wachen[j], Old_Str, New_Str, [rfReplaceAll]);
    end;
    //Tweet und Arr_Wachen jetzt zusammenfügen, wenn Wachen gewollt
    if SG_Twitter.Cells[3, T_Account_Zeile] = '1' then
    begin
      for i := 0 to high(Arr_Wachen) do
      begin
        //Wachen modifizieren, damit Word-Wrap auf Twitter nicht greift
        Arr_Wachen[i] := StringReplace(Arr_Wachen[i], ' ', nbs, [rfReplaceAll]);
        if T_Wachen = '' then
          T_Wachen := Arr_Wachen[i]
        else
          T_Wachen := T_Wachen + ', ' + Arr_Wachen[i];
      end;
      if T_Wachen <> '' then
        //Tweet + Wachen, Unicode Character 'FIRE ENGINE' (U+1F692) and 'RIGHTWARDS WHITE ARROW' (U+21E8)
        Tweet := Tweet + ' ' + #$F0#$9F#$9A#$92 + nbs + #$E2#$87#$A8 + nbs + T_Wachen;
    end
    else
    begin
      //Falls Wachen nicht gewollt, trotzdem Variable setzen
      T_Wachen := '-';
    end;
    //abschließend den Tweet auf max 260 Zeichen kürzen, Wichtig UTF8Lenght für richtige länge benutzen! (Puffer für EMOJI)
    if UTF8Length(Tweet) > 280 then
      Tweet := UTF8LeftStr(Tweet, 260) + nbs + '...';
    // Dashboard-URL zum Tweet hinzufügen, falls gewollt, URL zählt nicht in Twitter-Zeichenbegrenzung
    if SG_Twitter.Cells[9, T_Account_Zeile] = '1' then
    begin
      Tweet := Tweet + ' ' + ConfigForm.E_dbrd_link.Text + E_UUID;
    end;
    // T_Einsatzdaten für Abgleich in Chronik zusammensetzen
    T_Einsatzdaten := E_Einsatzart +', '+ E_Stichwort +', '+ E_Ort +', '+ E_Ortsteil +', '+ T_Wachen +', '+ E_Alarmierte_EM +', '+ E_Sondersignal;
    // T_Einsatzdaten in UID umwandeln (kürzerer Text)
    T_Einsatzdaten := inttostr(Unc(T_Einsatzdaten));
    //Prüfen ob Tweet zu deisem Einsatz bereits existiert, oder ob es einen zu verknüpfenden Tweet gibt
    Tweetfilter := 0;
    for i := 1 to SG_TWeetChronik.RowCount - 1 do
    begin
      // Prüfen ob in Chronik zu gleichem Account (T_Empfanger_IP_now) und Einsatznummer (E_Einsatznummer) bereits ein gleicher Tweet vorhanden ist (Symbol, Datum und Uhrzeit werden abgezogen (RightStr -21)
      if (SG_TweetChronik.Cells[0,i] = T_Empfanger_IP_now) AND (SG_TweetChronik.Cells[1,i] = E_Einsatznummer) AND (SG_TweetChronik.Cells[2,i] = T_Einsatzdaten) then
        Tweetfilter := Tweetfilter + 1;
      // Reply_ID übernehmen, falls in Chronik vorhanden gegeben
      if (SG_TweetChronik.Cells[0,i] = T_Empfanger_IP_now) AND (SG_TweetChronik.Cells[1,i] = E_Einsatznummer) then
        Reply_ID := SG_TweetChronik.Cells[3,i];
    end;
    // existiert noch kein gleicher Tweet, dann jetzt das Senden starten, ansonsten abbrechen
    if Tweetfilter > 0 then
      Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': doppelter Tweet wurde verworfen ('+ T_Empfanger_IP_now + ', Einsatz-Nr. ' + E_Einsatznummer + '): ' + Tweet)
    else
    begin
      Application.ProcessMessages;
      // Eintrag in Chronik hinzufügen
      SG_TweetChronik.RowCount := SG_TweetChronik.RowCount + 1;
      SG_TweetChronik.Cells[0, SG_TWeetChronik.RowCount - 1] := T_Empfanger_IP_now;
      SG_TweetChronik.Cells[1, SG_TWeetChronik.RowCount - 1] := E_Einsatznummer;
      SG_TweetChronik.Cells[2, SG_TWeetChronik.RowCount - 1] := T_Einsatzdaten;
      // Bild erstellen, falls gewollt
      if SG_Twitter.Cells[4, T_Account_Zeile] = '1' then
      begin
        // Grunddaten setzen
        TwitterForm.L_At_Account.Caption := SG_Twitter.Cells[0, T_Account_Zeile];
        TwitterForm.L_Account_Name.Caption := SG_Twitter.Cells[1, T_Account_Zeile];
        TwitterForm.L_Datum_Uhrzeit.Caption := T_Date + ' ' + T_Time;
        // Ortsinformationen setzen
        if E_Ortsteil = '' then
          TwitterForm.L_Ort_Ortsteil.Caption := E_Ort
        else
          TwitterForm.L_Ort_Ortsteil.Caption := E_Ort + ', ' + E_Ortsteil;
        if E_Einsatzart = 'Brandeinsatz' then
        begin
          TwitterForm.L_Einsatzart_Langtext.Font.Color := RGB(255, 80, 80);
          TwitterForm.L_Stichwort_Langtext.Font.Color := RGB(255, 80, 80);
        end;
        if E_Einsatzart = 'Hilfeleistungseinsatz' then
        begin
          TwitterForm.L_Einsatzart_Langtext.Font.Color := RGB(0, 172, 229);
          TwitterForm.L_Stichwort_Langtext.Font.Color := RGB(0, 172, 229);
        end;
        if E_Einsatzart = 'Rettungseinsatz' then
        begin
          TwitterForm.L_Einsatzart_Langtext.Font.Color := RGB(255, 161, 78);
          TwitterForm.L_Stichwort_Langtext.Font.Color := RGB(255, 161, 78);
        end;
        if E_Einsatzart = 'Krankentransport' then
        begin
          TwitterForm.L_Einsatzart_Langtext.Font.Color := RGB(30, 144, 255);
          TwitterForm.L_Stichwort_Langtext.Font.Color := RGB(30, 144, 255);
        end;
        if E_Einsatzart = 'Sonstiges' then
        begin
          TwitterForm.L_Einsatzart_Langtext.Font.Color := RGB(245, 245, 245);
          TwitterForm.L_Stichwort_Langtext.Font.Color := RGB(245, 245, 245);
        end;
        // Einsatzart und Stichwort zunächst zurücksetzen
        TwitterForm.L_Stichwort_Langtext.Caption := '';
        TwitterForm.L_Einsatzart_Langtext.Caption := '';
        // String-Replace für Einsatzart oder Stichwort
        for i := 0 to M_StringReplace_Picture.Lines.Count - 1 do
        begin
          Old_Str := copy(M_StringReplace_Picture.Lines[i], 0, pos('==', M_StringReplace_Picture.Lines[i]) - 1);
          New_Str := copy(M_StringReplace_Picture.Lines[i], pos('==', M_StringReplace_Picture.Lines[i]) + 2, 100);
          if E_Stichwort = Old_Str then
            TwitterForm.L_Stichwort_Langtext.Caption := StringReplace(E_Stichwort, Old_Str, New_Str, []);
          if E_Einsatzart = Old_Str then
            TwitterForm.L_Einsatzart_Langtext.Caption:=  StringReplace(E_Einsatzart, Old_Str, New_Str, []) ;
        end;
        // Einsatzart und Stichwort setzen, falls kein String-Replace gefunden wurde
        if TwitterForm.L_Stichwort_Langtext.Caption = '' then
          TwitterForm.L_Stichwort_Langtext.Caption := E_Stichwort;
        if TwitterForm.L_Einsatzart_Langtext.Caption = '' then
          TwitterForm.L_Einsatzart_Langtext.Caption:=  E_Einsatzart;
        // Einsatzmittel je Wache ermitteln, falls Wachen im Tweet gewollt
        TwitterForm.L_Wachen_Einsatzmittel.Caption := '';
        if SG_Twitter.Cells[3, T_Account_Zeile] = '1' then
        begin
          // die Daten aus Einsatzmittel[] in angepasstes Array Wachen_zu_EM übertragen
          SetLength(Wachen_zu_EM, 0);
          for i := 0 to high(Einsatzmittel) do
          begin
            Wache_gefunden := false;
            for j := 0 to high(Wachen_zu_EM) do
            begin
              if Wachen_zu_EM[j].Wache = Einsatzmittel[i].Wache then
              begin
                Wache_gefunden:= true;
                Wachen_Zeile := j
              end;
            end;
            if Wache_gefunden = false then
            begin
              SetLength(Wachen_zu_EM, length(Wachen_zu_EM) + 1);
              Wachen_zu_EM[high(Wachen_zu_EM)].Wache := Einsatzmittel[i].Wache;
              // Unicode Character 'RIGHTWARDS WHITE ARROW' (U+21E8)
              Wachen_zu_EM[high(Wachen_zu_EM)].Status := #$E2#$87#$A8;
              Wachen_zu_EM[high(Wachen_zu_EM)].Fahrzeug := Einsatzmittel[i].Fahrzeug;
            end;
            if Wache_gefunden = true then
            begin
              Wachen_zu_EM[Wachen_Zeile].Wache := Wachen_zu_EM[Wachen_Zeile].Wache;
              Wachen_zu_EM[Wachen_Zeile].Status := Wachen_zu_EM[Wachen_Zeile].Status;
              Wachen_zu_EM[Wachen_Zeile].Fahrzeug := Wachen_zu_EM[Wachen_Zeile].Fahrzeug +  ', '  + Einsatzmittel[i].Fahrzeug;
            end;
          end;
          // ermittelte Wachen und Einsatzmittel jetzt in Bild hinterlegen
          for i := 0 to high(Wachen_zu_EM) do
          begin
            if TwitterForm.L_Wachen_Einsatzmittel.Caption = '' then
              TwitterForm.L_Wachen_Einsatzmittel.Caption := Wachen_zu_EM[i].Wache + '   ' + Wachen_zu_EM[i].Status + '   ' + Wachen_zu_EM[i].Fahrzeug
            else
              TwitterForm.L_Wachen_Einsatzmittel.Caption := TwitterForm.L_Wachen_Einsatzmittel.Caption + #13#10 + Wachen_zu_EM[i].Wache + '   ' + Wachen_zu_EM[i].Status + '   ' + Wachen_zu_EM[i].Fahrzeug ;
          end;
        end;
      end;
      // Thread vorbereiten
      MyThread := TMyThread.Create(True);
      if Assigned(MyThread.FatalException) then
        raise MyThread.FatalException;
      // Variablen an Thread zuweisen
      MyThread.Thr_Type := 'Twitter';
      MyThread.Thr_Tw_Text := Tweet;
      MyThread.Thr_Tw_ConsumerKey := SG_Twitter.Cells[5, T_Account_Zeile];
      MyThread.Thr_Tw_ConsumerSecret := SG_Twitter.Cells[6, T_Account_Zeile];
      MyThread.Thr_Tw_AuthToken := SG_Twitter.Cells[7, T_Account_Zeile];
      MyThread.Thr_Tw_AuthSecret := SG_Twitter.Cells[8, T_Account_Zeile];
      MyThread.Thr_Tw_ProxyHost := ConfigForm.ProxyHost.Text;
      MyThread.Thr_Tw_ProxyPort := ConfigForm.ProxyPort.Text;
      MyThread.Thr_Tw_ProxyUser := ConfigForm.ProxyUser.Text;
      MyThread.Thr_Tw_ProxyPass := ConfigForm.ProxyPass.Text;
	  MyThread.Thr_FTP_User := '';
      MyThread.Thr_FTP_Pass := '';
      // Bild an Thread zuweisen, falls gewollt
      if SG_Twitter.Cells[4, T_Account_Zeile] = '1' then
        MyThread.Thr_Stream := Alarmbild(TwitterForm, 0, 0)
      else
        MyThread.Thr_Stream := nil;
      MyThread.Thr_Empfaenger_IP_now := T_Empfanger_IP_now;
      MyThread.Thr_Empfaenger_IP_all := T_Empfanger_IP_all;
      MyThread.Thr_Empfaenger_Wache := T_Wachen;
      MyThread.Thr_Einsatznummer := T_Einsatznummer;
      MyThread.Thr_Zusatztext := Reply_ID;
      // Simulation?
      if Simulation = false then
      begin
        // Alarm zur Anzahl der aktuellen Alarme hinzuzählen
        Anzahl_aktuelle_Alarme := Anzahl_aktuelle_Alarme + 1;
        // Thread ausfuehren
        MyThread.start;
      end;
    end;
  end;
end;

// zentrale Schnittstellen-Prozedur zum Auslesen der waip.txt
procedure TMainForm.Timer1Timer(Sender: TObject);
var rename, Archiv_Dir, waip_txt, waip_pfad, s: String;
    tfIn: TextFile;
    Einlesen_erfolgreich: Boolean;
    WaipFiles: TStringList;
begin
  // Timer auf 500 ms gestellt
  waip_pfad := '';
  waip_txt := '';
  Einlesen_erfolgreich := false;
  // Übergabedateien auslesen
  if Assigned(ConfigForm) then
  begin
    // Dateien in Übergabeordner gemäßig Config-Vorgaben (präfix * suffix) einlesen
    WaipFiles := TStringList.Create;
    ListFileDir(ConfigForm.E_Pfad.Text + Slash, ConfigForm.E_waip_praefix.Text + '*' + ConfigForm.E_waip_suffix.Text, WaipFiles);
    // erste Übergabedatei in Liste auselsen
    try
      if WaipFiles.Count > 0 then
      begin
        waip_pfad := ConfigForm.E_Pfad.Text + Slash;
        waip_txt := WaipFiles[0]
      end;
    finally
      WaipFiles.Free;
    end;
  end;
  // wenn keine Alarme verarbeitet werden und keine Datei vorhanden, dann alles zurücksetzen
  if (Anzahl_aktuelle_Alarme = 0) AND (waip_txt = '') then
  begin
    L_Auftragsstatus.Font.Color := clgreen;
    L_Auftragsstatus.Caption := 'warte auf neuen Alarm';
    PG_Verarbeitungsstatus.Position := 0;
    Reset_Timer := 0;
  end;
  // wenn keine Alarme verarbeitet werden und neue Übergabedatei vorliegt, dann Alarmierung durchführen
  if (Anzahl_aktuelle_Alarme = 0) AND (FileExists(waip_pfad + waip_txt)) then
  begin
    Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': neue Datei vorhanden. ' + waip_txt + ' wird jetzt verarbeitet.');
    // kleinere GUI-Einstellungen
    L_Auftragsstatus.Font.Color := clred;
    L_Auftragsstatus.Caption := waip_txt + ' wird eingelesen';
    PG_Verarbeitungsstatus.Position := 20;
    Fehlerindex := 0;
    // Textdatei einlesen
    M_Auftrag.Lines.Clear;
    AssignFile(tfIn, waip_pfad + waip_txt);
    try
      // Datei zum lesen öffnen
      reset(tfIn);
      // Zeilen auslesen, bis ende der Datei erreicht ist
      while not eof(tfIn) do
      begin
        readln(tfIn, s);
        M_Auftrag.Append(CP1252ToUTF8(s));
      end;
      // Datei wieder schließen
      CloseFile(tfIn);
      // Nach dem Einlesen waip.txt umbenennen (waip + tag + zeit.txt) und in Archiv verschieben
      L_Auftragsstatus.Caption := waip_txt + ' wird in Archiv verschoben';
      PG_Verarbeitungsstatus.Position := 40;
      Archiv_Dir := waip_pfad + 'waip_archiv_' + StringReplace( copy(datetostr(Date),4,7),'.','_',[rfReplaceAll]);
      // Archiv-Ordner erstellen, sollte dieser noch nicht vorhanden sein
      If Not DirectoryExists(Archiv_Dir) then
        CreateDir (Archiv_Dir);
      // Datei umbennen
      rename := datetostr(Date) +' '+ timetostr(Time);
      rename := StringReplace(rename,':','_',[rfReplaceAll]);
      rename := StringReplace(rename,'.','_',[rfReplaceAll]);
      RenameFile(waip_pfad + waip_txt, Archiv_Dir + Slash + 'waip ' + rename + '.txt');
      // Einlesen OK
      Einlesen_erfolgreich := true;
    except
      on E: EInOutError do
      begin
        Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': Fehler bei Verarbeitung von ' + waip_txt + '; Details: ' + E.Message);
        Einlesen_erfolgreich := false;
      end;
    end;
  end;
  // Alarmierung nach erfolgreichem Einlesen der Übergabedatei durchführen
  if (Anzahl_aktuelle_Alarme = 0) AND (Einlesen_erfolgreich = true) then
  begin
    // eingelesene waip.txt interpretieren und alle Variablen füllen
    L_Auftragsstatus.Font.Color := clred;
    L_Auftragsstatus.Caption := 'Inhalt wird interpretiert';
    PG_Verarbeitungsstatus.Position := 60;
    WAIP_Auslesen;
    // Alarmierung durchführen
    Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': Einsatz ' + E_Einsatznummer + ' wird verarbeitet / gesendet.');
    L_Auftragsstatus.Font.Color := clred;
    L_Auftragsstatus.Caption := 'Alarme werden gesendet';
    PG_Verarbeitungsstatus.Position := 80;
    Alarmierung_durchfuehren(false);
  end;
  // wenn noch Alarme abgearbeitet werden, dann Beschriftung anpassen
  if Anzahl_aktuelle_Alarme > 0 then
  begin
    L_Auftragsstatus.Font.Color := clred;
    L_Auftragsstatus.Caption := 'letzter Auftrag wird abgeschlossen, noch ' + inttostr(Anzahl_aktuelle_Alarme) + ' Alarm(e) offen';
    PG_Verarbeitungsstatus.Position := 100;
  end;
  // Einlese-Prozess reseten, falls nach 1 Minute (120 Timer) noch nicht alle anstehenden Alarme gesendet wurden
  if (Anzahl_aktuelle_Alarme > 0) AND (Reset_Timer > 120) then
  begin
    Anzahl_aktuelle_Alarme := 0;
    Reset_Timer := 0;
  end;
  Reset_Timer := Reset_Timer + 1;
end;

procedure TMainForm.Timer1StopTimer(Sender: TObject);
begin
  L_Auftragsstatus.Caption:='Datei-Schnittstelle gestoppt!';
  L_Auftragsstatus.Font.Color := clred;
end;

procedure TMainForm.SG_TwitterExit(Sender: TObject);
var i: integer;
begin
  // Picklist in SG_Twitter_Filter anpassen
  SG_Twitter_Filter.Columns[0].PickList.Clear;
  for i := 1 to SG_Twitter.RowCount - 1 do
    SG_Twitter_Filter.Columns[0].PickList.Add(SG_Twitter.Cells[0, i]);
end;

procedure TMainForm.SG_TwitterKeyDown(Sender: TObject; var Key: Word);
var i, delete_row: integer;
begin
  if (Key = VK_DELETE) then
  begin
    delete_row := 0;
    // zu löschende Ziele in SG_Twitter_Filter finden
    for i := 1 to SG_Twitter_Filter.RowCount - 1 do
    begin
      if SG_Twitter_Filter.Cells[0, i] = SG_Twitter.Cells[0, SG_Twitter.Row] then
         delete_row := i;
    end;
    // Zeile löschen in SG_Twitter_Filter
    if delete_row <> 0 then
    begin
      GridDeleteRow(SG_Twitter_Filter, delete_row);
      // Picklist in SG_Twitter_Filter anpassen
      SG_Twitter_Filter.Columns[0].PickList.Clear;
      for i := 1 to SG_Twitter.RowCount - 1 do
        SG_Twitter_Filter.Columns[0].PickList.Add(SG_Twitter.Cells[0, i]);
    end;
    delete_row := 0;
    // zu löschende Ziele in SG_Clients finden
    for i := 1 to SG_Clients.RowCount - 1 do
    begin
      if SG_Clients.Cells[3, i] = SG_Twitter.Cells[0, SG_Twitter.Row] then
         delete_row := i;
    end;
    // Ziele löschen in SG_Clients
    if delete_row <> 0 then
      GridDeleteRow(SG_Clients, delete_row);
    // Löschen in SG_Twitter
    GridDeleteRow(SG_Twitter,SG_Twitter.Row);
    // Tabellen neu speichern
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Clients);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter_Filter);
  end;
end;

procedure TMainForm.SG_Twitter_FilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) then
  begin
    GridDeleteRow(SG_Twitter_Filter,SG_Twitter_Filter.Row);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter_Filter);
  end;
end;

procedure TMainForm.SG_ClientsKeyDown(Sender: TObject; var Key: Word);
begin
  if (Key = VK_DELETE) then
  begin
    GridDeleteRow(SG_Clients,SG_Clients.Row);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Clients);
  end;
end;

procedure TMainForm.SG_IP_ReplaceKeyDown(Sender: TObject; var Key: Word);
begin
  if (Key = VK_DELETE) then
  begin
    GridDeleteRow(SG_IP_Replace,SG_IP_Replace.Row);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini',SG_IP_Replace);
  end;
end;

procedure TMainForm.SG_TweetChronikKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) then
  begin
    GridDeleteRow(SG_TweetChronik,SG_TweetChronik.Row);
    SaveStringGrid_IniXML(Dir + Slash + 'config.ini',SG_TweetChronik);
  end;
end;

procedure TMainForm.SG_Twitter_FilterEditingDone(Sender: TObject);
begin
  if SG_Twitter_Filter.Cells[0, SG_Twitter_Filter.RowCount - 1] <> '' then
     SG_Twitter_Filter.RowCount := SG_Twitter_Filter.RowCount + 1;
  SG_Twitter_Filter.AutoSizeColumns;
  SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter_Filter);
end;

procedure TMainForm.M_StringReplace_PictureEditingDone(Sender: TObject);
begin
  SaveMemoLines(Dir + Slash + 'config.ini', M_StringReplace_Picture);
end;

procedure TMainForm.M_StringReplace_TweetEditingDone(Sender: TObject);
begin
  SaveMemoLines(Dir + Slash + 'config.ini', M_StringReplace_Tweet);
end;

procedure TMainForm.SG_TwitterEditingDone(Sender: TObject);
begin
  if SG_Twitter.Cells[0,SG_Twitter.RowCount-1] <> '' then
     SG_Twitter.RowCount := SG_Twitter.RowCount + 1;
  SG_Twitter.AutoSizeColumns;
  SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Twitter);
end;

procedure TMainForm.SG_IP_ReplaceEditingDone(Sender: TObject);
begin
  if SG_IP_Replace.Cells[0,SG_IP_Replace.RowCount-1] <> '' then
     SG_IP_Replace.RowCount := SG_IP_Replace.RowCount+1;
  SG_IP_Replace.AutoSizeColumns;
  SaveStringGrid_IniXML(Dir + Slash + 'config.ini',SG_IP_Replace);
end;

procedure TMainForm.M_WachenfilterEditingDone(Sender: TObject);
var
  tmp: TStringList;
  Duplicates:TDuplicates;
begin
  Duplicates := dupIgnore;
  Assert(Assigned(M_Wachenfilter.Lines), 'SortTStrings: invalid arg');
  if M_Wachenfilter.Lines is TStringList then
  begin
    TStringList(M_Wachenfilter.Lines).Duplicates := Duplicates;
    TStringList(M_Wachenfilter.Lines).Sort;
  end
  else
  begin
    tmp := TStringList.Create;
    try
      tmp.Duplicates := Duplicates;
      tmp.Sorted := True;
      // sortierte Kopie erstellen
      tmp.Assign(M_Wachenfilter.Lines);
      // zurückkopieren
      M_Wachenfilter.Lines.Assign(tmp);
    finally
      tmp.Free;
    end;
  end;
  SaveMemoLines(Dir + Slash + 'config.ini', M_Wachenfilter);
end;

procedure TMainForm.LogChange(Sender: TObject);
begin
  //damit das Log nicht zu groß wird, Zeilen löschen
  while Log.Lines.Count > 10000 do
    Log.Lines.Delete(Log.Lines.Count - 1);
  Log.SelStart := 0;
  //Logdatei speichern
  Log.Lines.SaveToFile(Dir + Slash + 'WA-Log.txt');
end;

procedure TMainForm.Verbindung1Click(Sender: TObject);
begin
  ShowMessage('Zugangsdaten:' + #13#10 + #13#10 +
  'FTP-Username: ' + User + #13#10 +
  'FTP-Passwort: ' + Pass + #13#10 +
  'FTP-Port: 60144 (60143 Passiv)' + #13#10 +
  '1. UDP-Port: 60132 (Waip-Client)' + #13#10 +
  '2. UDP-Port: 60233 (Waip-Web)');
end;

procedure TMainForm.Label3Click(Sender: TObject);
begin
  OpenURL('https://github.com/Robert-112/Wachalarm-IP-Server');
end;

procedure TMainForm.AlarmSimulation1Click(Sender: TObject);
begin
  SimulationForm.Show;
end;

procedure TMainForm.Einstellungen1Click(Sender: TObject);
begin
  ConfigForm.Show;
end;

procedure TMainForm.TwitterFenster1Click(Sender: TObject);
begin
  TwitterForm.Show;
end;

procedure TMainForm.WachalarmFenster1Click(Sender: TObject);
begin
  PictureForm.Show;
end;

procedure TMainForm.ber1Click(Sender: TObject);
begin
  ShowMessage('Wachalarm-IP Server' + #13#10 +
  L_Version.Caption + #13#10 + #13#10 +
  'Entwickelt von Robert Richter - Leitstelle Lausitz');
end;

procedure TMainForm.Beenden1Click(Sender: TObject);
var CanClose_Form: boolean;
begin
  CanClose_Form := true;
  FormCloseQuery(Sender, CanClose_Form);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var Reply,BoxStyle:integer;
begin
  with Application do begin
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    Reply := MessageBox('Moechten Sie WachalarmIP Server wirklich beenden?', 'Programm beenden', BoxStyle);
    // bei yes-Klick Module freigeben und Programm beenden
    if Reply = IDYES then
    begin
      //ShowMessage('Aktuelle Daten werden gespeichert, bitte warten.');
      Timer1.Enabled := false;
      SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_Clients);
      SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_WaipChronik);
      SaveStringGrid_IniXML(Dir + Slash + 'config.ini', SG_TWeetChronik);
      Terminate
    end
    else
    CanClose := false;
  end;
end;

{==============================================================================}
{=========== MyThread =========================================================}
{==============================================================================}

constructor TMyThread.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure TMyThread.ShowStatus;
begin
  // Ergebnisse von FTP-Upload, UDP-Send oder Twitter-Status an MainForm zurück übergeben
  MainForm.Log.Lines.Insert(0, Thr_Log_Text);
  MainForm.Client_Status(Thr_Fehlerindex, Thr_Type, Thr_Empfaenger_Wache, Thr_Empfaenger_IP_now, Thr_Einsatznummer, Thr_Zusatztext);
end;

procedure TMyThread.Execute;
begin
  // Web-Teilthread
  if Thr_Type = 'WEB' then
    alert_Web;
  // FTP-Teilthread
  if Thr_Type = 'FTP' then
    alert_FTP;
  // Twitter-Teilthread
  if Thr_Type = 'Twitter' then
    alert_Twitter;
  Synchronize(@ShowStatus);
end;

procedure TMyThread.alert_Web;
var
  UDP_Port: string;
  IP_UDP: TStringArray;
  UDP: TUDPBlockSocket;
begin
  // Variablen zurücksetzen
  Thr_Log_Text := '';
  IP_UDP := NIL;
  Thr_Fehlerindex := 0;
  // UDP-Socket erstellen und JSON senden
  UDP := TUDPBlockSocket.Create;
  UDP_Port := '60233';
  try
    // sende auch noch einmal an Localhost
    if Thr_Empfaenger_IP_now <> '127.0.0.1:60233' then
    begin
      UDP.Connect('127.0.0.1', UDP_Port);
      UDP.SendString(Thr_Zusatztext);
      UDP.CloseSocket;
    end;
    // sende an Empfaenger-IP
    IP_UDP := Thr_Empfaenger_IP_now.Split(':');
    UDP.Connect(IP_UDP[0], IP_UDP[1]);
    UDP.SendString(Thr_Zusatztext);
    UDP.CloseSocket;
  finally
    UDP.Free;    
  end;
  Thr_Zusatztext := '';
  // Text für Log übergeben
  Thr_Log_Text := (datetostr(date) + '-' + timetostr(time) + ': Web-Alarm fuer ' + Thr_Empfaenger_Wache +' (Einsatz-Nr. ' + Thr_Einsatznummer + ') an ' + Thr_Empfaenger_IP_now + ':' + UDP_Port + ' gesendet.')
end;
procedure TMyThread.alert_FTP;
var
  UDP_Port: string;
  Stream: TMemoryStream;
  FTPClient: TFTPSend;
  UDP: TUDPBlockSocket;
begin
  // Variablen zurücksetzen
  Thr_Log_Text := '';
  Thr_Fehlerindex := 0;
  // Stream übernehmen
  Stream := Thr_Stream;
  // UDP-Socket erstellen und Text versenden
  UDP := TUDPBlockSocket.Create;
  UDP_Port := '60132';
  try
    UDP.Connect(Thr_Empfaenger_IP_now, UDP_Port);
    UDP.SendString(Thr_Zusatztext);
    UDP.CloseSocket;
  finally
    UDP.Free;
  end;
  // FTP-Client erstellen
  FTPClient := TFTPSend.Create;
  //FTPClient.OnStatus:=;
  with FTPClient do
  begin
    // FTP-Protokollierung
    OnStatus := @FTP_OnStatus;
    // FTP-Parameter setzen
    TargetPort := '60144';
    TargetHost := Thr_Empfaenger_IP_now;
    UserName := Thr_FTP_User;
    Password := Thr_FTP_Pass;
    // Bild in FTP-Stream verpacken
    DataStream.LoadFromStream(Stream);
    // Login versuchen
    try
      if not LogIn then
      begin
        Thr_Fehlerindex := 1;
        Thr_Log_Text := (datetostr(date) + '-' + timetostr(time) +': Fehler bei FTP-Upload! '+ Thr_Empfaenger_IP_now + ' (' + Thr_Empfaenger_Wache +', Einsatz-Nr. ' + Thr_Einsatznummer + ') ist nicht erreichbar oder antwortet nicht.');
      end
      else
      begin
        StoreFile('WA_Server.jpg', False);
        LogOut;
        Thr_Log_Text := (datetostr(date) + '-' + timetostr(time) + ': Alarmbild erfolgreich an '+ Thr_Empfaenger_IP_now + ' (' + Thr_Empfaenger_Wache +', Einsatz-Nr. ' + Thr_Einsatznummer + ') gesendet.');
      end;
    finally
      Free;
      Stream.Free;
    end;
  end;
end;

procedure TMyThread.FTP_OnStatus(Sender: TObject; Response: Boolean; const Value: string);
begin
  //220 Welcome 192.168.1.42, {"WachalarmIP-Client": {"Version": "Client 2.8.2","OS": "Windows x64","IP": "Windows-IP-Konfiguration  192.168.56.1  192.168.1.42  ","Anzeige_Screen": {"Anzeige_Width": "2560","Anzeige_Height": "1440"}}};
  if LeftStr(Value, 11) = '220 Welcome' then
  begin
    if pos(', {', Value) > 0 then
      Thr_Zusatztext := Thr_Zusatztext + Copy(Value, pos(', {', Value) + 1, length(Value))
    else
      Thr_Zusatztext := Thr_Zusatztext + ' {keine Client-Informationen verfügbar}';
  end;
end;

procedure TMyThread.alert_Twitter;
var status, media_data, media_ids: string;
    media_data_bytes, i: integer;
    Stream: TMemoryStream;
    jData: TJSONData;
    Fehler_Texte: Array of String;
begin
  // Variablen zurucksetzen
  status := '';
  media_ids := '';
  media_data := '';
  media_data_bytes := 0;
  Thr_Log_Text := '';
  Thr_Fehlerindex := 0;
  SetLength(Fehler_Texte, 0);
  // Twitter-Thread erstellen
  FTwitter := TTwitter.Create;
  // Account und Proxy für Tweet vorbereiten
  FTwitter.ConsumerKey := Thr_Tw_ConsumerKey;
  FTwitter.ConsumerSecret := Thr_Tw_ConsumerSecret;
  FTwitter.AuthToken := Thr_Tw_AuthToken;
  FTwitter.AuthSecret := Thr_Tw_AuthSecret;
  FTwitter.ProxyHost := Thr_Tw_ProxyHost;
  FTwitter.ProxyPort := Thr_Tw_ProxyPort;
  FTwitter.ProxyUser := Thr_Tw_ProxyUser;
  FTwitter.ProxyPass := Thr_Tw_ProxyPass;
  // mit Twitter-Account verbinden
  FTwitter.Connect;
  // Bildzuweisen und zunächst an Twitter senden (falls nicht 'nil')
  Stream := Thr_Stream;
  if Stream <> nil then
  begin
    try
      // Bild in TEXT umwandeln (für HTTP-Post)
      Stream.Position := 0;
      SetLength(media_data, Stream.Size);
      media_data_bytes := Stream.Read(media_data[1], Stream.Size);
      SetLength(media_data, media_data_bytes);
    finally
      Stream.Free;;
    end;
    // Bild-TEXT vor Upload in Base64 umwandeln
    media_data := encodestringbase64(media_data);
    // Bild-TEXT hochladen
    status := FTwitter.UploadDataAndGetResponse(media_data);
    media_data := '' ;
    if (leftstr(status,3) = 'ERR') or (status = '') then
    begin
      SetLength(Fehler_Texte, length(Fehler_Texte) + 1);
      Fehler_Texte[high(Fehler_Texte)] := 'Netzwerk-Fehler - Bild konnte nicht an Twitter gesendet werden';
    end
    else
    begin
      // Media_ID aus Upload-Rückmeldung ermitteln
      jData := GetJSON(status);
      try
        try
          media_ids := Jdata.FindPath('media_id_string').AsString;
        except
          media_ids := '';
          SetLength(Fehler_Texte, length(Fehler_Texte) + 1);
          Fehler_Texte[high(Fehler_Texte)] := 'Parser-Fehler - Bild-ID konnte nicht ermittelt werden';
        end;
      finally
        jData.Free;
      end;
    end;
  end;
  // Zwitschern
  status := FTwitter.TweetAndGetResponse(Thr_Tw_Text, Thr_Zusatztext, media_ids);
  if (leftstr(status,3) = 'ERR') or (status = '') then
  begin
    SetLength(Fehler_Texte, length(Fehler_Texte) + 1);
    Fehler_Texte[high(Fehler_Texte)] := 'Netzwerk-Fehler - Tweet konnte nicht an Twitter gesendet werden';
  end;
  // Tweet-Status an Zusatztext übergeben, damit dieser im Haup-Thread ausgewertet werden kann
  Thr_Zusatztext := status;
  // Status-Rückmeldung um original EVI-Text ergänzen
  SetLength(Thr_Zusatztext, Length(Thr_Zusatztext) -1);
  if Thr_Zusatztext <> '' then
    Thr_Zusatztext := Thr_Zusatztext + ',"EVI-Text":"' + Thr_Tw_Text + '"}'
  else
    Thr_Zusatztext := '{"EVI-Text":"' + Thr_Tw_Text + '","id_str":"","user":{"name":""}}';
  // Fehlerindex festlegen und Texte für Log übergeben
  Thr_Fehlerindex := high(Fehler_Texte) + 1;
  if Thr_Fehlerindex = 0 then
    Thr_Log_Text := (datetostr(date) + '-' + timetostr(time) + ': erfolgreich getwittert ('+ Thr_Empfaenger_IP_now + ', Einsatz-Nr. ' + Thr_Einsatznummer + '): ' + Thr_Tw_Text)
  else
  begin
    for i := 0 to high(Fehler_Texte) do
      Thr_Log_Text := Fehler_Texte[i] + '; ' + Thr_Log_Text;
    Thr_Log_Text := (datetostr(date) + '-' + timetostr(time) + ': Fehler beim Twittern! ('+ Thr_Empfaenger_IP_now + ', Einsatz-Nr. ' + Thr_Einsatznummer + '): ' + Thr_Tw_Text + '; ' + inttostr(high(Fehler_Texte)+1) + ' Fehler: ' + Thr_Log_Text);
  end;
  // Verbindung wieder trennen
  FTwitter.Disconnect;
  FTwitter.Free;
end;

end.
