unit Simulation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls;

type

  { TSimulationForm }

  TSimulationForm = class(TForm)
    B_Simulieren: TButton;
    B_Einlesen: TButton;
    L_Information: TLabel;
    Memo_Vorlage5: TMemo;
    Memo_Vorlage4: TMemo;
    Memo_Vorlage3: TMemo;
    Memo_Vorlage2: TMemo;
    Memo_Vorlage1: TMemo;
    PageControl1: TPageControl;
    P_Information: TPanel;
    P_Button: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    procedure B_EinlesenClick(Sender: TObject);
    procedure B_SimulierenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo_Einlesen;
    procedure Memo_Vorlage1EditingDone(Sender: TObject);
    procedure Memo_Vorlage1Exit(Sender: TObject);
    procedure Memo_Vorlage2EditingDone(Sender: TObject);
    procedure Memo_Vorlage3EditingDone(Sender: TObject);
    procedure Memo_Vorlage4EditingDone(Sender: TObject);
    procedure Memo_Vorlage5EditingDone(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SimulationForm: TSimulationForm;
  M1_Edit, M2_Edit, M3_Edit, M4_Edit, M5_Edit: boolean;
  Dir, Slash: string;

implementation

{$R *.lfm}

uses
  Main, funktionen;

{ TSimulationForm }

procedure TSimulationForm.FormCreate(Sender: TObject);
begin
  // Variablen setzten
  {$ifdef  Windows}
    Slash := '\';
  {$else}
    Slash := '/';
  {$endif}
  getdir(0,Dir);
  Dir := Dir + Slash + 'config';
  // Form-Layout festlegen
  PageControl1.ActivePage := TabSheet1;
  SimulationForm.Height := 600;
  SimulationForm.Width := 800;
  // Einstellungen aus Config.ini laden
  LoadMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage1);
  M1_Edit := false;
  LoadMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage2);
  M2_Edit := false;
  LoadMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage3);
  M3_Edit := false;
  LoadMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage4);
  M4_Edit := false;
  LoadMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage5);
  M5_Edit := false;
end;

procedure TSimulationForm.Memo_Einlesen;
begin
  if PageControl1.ActivePageIndex = 0 then
    MainForm.M_Auftrag.Lines.Text := Memo_Vorlage1.Lines.Text;
  if PageControl1.ActivePageIndex = 1 then
    MainForm.M_Auftrag.Lines.Text := Memo_Vorlage2.Lines.Text;
  if PageControl1.ActivePageIndex = 2 then
    MainForm.M_Auftrag.Lines.Text := Memo_Vorlage3.Lines.Text;
  if PageControl1.ActivePageIndex = 3 then
    MainForm.M_Auftrag.Lines.Text := Memo_Vorlage4.Lines.Text;
  if PageControl1.ActivePageIndex = 4 then
    MainForm.M_Auftrag.Lines.Text := Memo_Vorlage5.Lines.Text;
end;

procedure TSimulationForm.Memo_Vorlage1Exit(Sender: TObject);
begin
  if M1_Edit = true then
  begin
    SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage1);
    M1_Edit := false;
  end;
  if M2_Edit = true then
  begin
    SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage2);
    M2_Edit := false;
  end;
  if M3_Edit = true then
  begin
    SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage3);
    M3_Edit := false;
  end;
  if M4_Edit = true then
  begin
    SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage4);
    M4_Edit := false;
  end;
  if M5_Edit = true then
  begin
    SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage5);
    M5_Edit := false;
  end;
end;

procedure TSimulationForm.Memo_Vorlage1EditingDone(Sender: TObject);
begin
  M1_Edit := true;
end;

procedure TSimulationForm.Memo_Vorlage2EditingDone(Sender: TObject);
begin
  //SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage2);
  M2_Edit := true;
end;

procedure TSimulationForm.Memo_Vorlage3EditingDone(Sender: TObject);
begin
 // SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage3);
  M3_Edit := true;
end;

procedure TSimulationForm.Memo_Vorlage4EditingDone(Sender: TObject);
begin
 // SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage4);
  M4_Edit := true;
end;

procedure TSimulationForm.Memo_Vorlage5EditingDone(Sender: TObject);
begin
 // SaveMemoLines(Dir + Slash + 'config.ini', Memo_Vorlage5);
  M5_Edit := true;
end;

procedure TSimulationForm.B_EinlesenClick(Sender: TObject);
begin
  Memo_Einlesen;
  // Memo Auswerten
  MainForm.L_Auftragsstatus.Font.Color := clred;
  MainForm.L_Auftragsstatus.Caption := 'Inhalt wird interpretiert';
  MainForm.PG_Verarbeitungsstatus.Position := 60;
  MainForm.WAIP_Auslesen;
  // Alarmierung nur simulieren
  MainForm.Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': Testeinsatz (Simulation) wird einglesen.');
  MainForm.L_Auftragsstatus.Font.Color := clred;
  MainForm.L_Auftragsstatus.Caption := 'Alarme werden gesendet';
  MainForm.PG_Verarbeitungsstatus.Position := 80;
  MainForm.Alarmierung_durchfuehren(true);
end;

procedure TSimulationForm.B_SimulierenClick(Sender: TObject);
begin
  Memo_Einlesen;
  // Memo Auswerten
  MainForm.L_Auftragsstatus.Font.Color := clred;
  MainForm.L_Auftragsstatus.Caption := 'Inhalt wird interpretiert';
  MainForm.PG_Verarbeitungsstatus.Position := 60;
  MainForm.WAIP_Auslesen;
  // echte Alarmierung durchführen
  MainForm.Log.Lines.Insert(0, datetostr(date) + '-' + timetostr(time) + ': Testeinsatz (Simulation) wird verarbeitet / gesendet.');
  MainForm.L_Auftragsstatus.Font.Color := clred;
  MainForm.L_Auftragsstatus.Caption := 'Alarme werden gesendet';
  MainForm.PG_Verarbeitungsstatus.Position := 80;
  MainForm.Alarmierung_durchfuehren(false);
end;

end.

