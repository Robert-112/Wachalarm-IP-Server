unit Config;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, IniFiles, LCLIntf;

type

  { TConfigForm }

  TConfigForm = class(TForm)
    Btn_OpenDir: TButton;
    Btn_SelectDir: TButton;
    CB_Alarm_Zeit: TCheckBox;
    E_dbrd_link: TEdit;
    E_waip_praefix: TEdit;
    E_ip_web: TEdit;
    E_waip_suffix: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    L_ip_web: TLabel;
    L_dbrd_link: TLabel;
    ProxyHost: TEdit;
    E_Pfad: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    L_Prozent: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    L_Bildqual: TLabel;
    ProxyPass: TEdit;
    ProxyPort: TEdit;
    ProxyUser: TEdit;
    T_Qualli: TTrackBar;
    Btn_Back: TButton;
    procedure Btn_BackClick(Sender: TObject);
    procedure Btn_OpenDirClick(Sender: TObject);
    procedure Btn_SelectDirClick(Sender: TObject);
    procedure CB_Alarm_ZeitChange(Sender: TObject);
    procedure E_dbrd_linkEditingDone(Sender: TObject);
    procedure E_ip_webEditingDone(Sender: TObject);
    procedure E_PfadEditingDone(Sender: TObject);
    procedure E_waip_praefixEditingDone(Sender: TObject);
    procedure E_waip_suffixEditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProxyHostEditingDone(Sender: TObject);
    procedure ProxyPassEditingDone(Sender: TObject);
    procedure ProxyPortEditingDone(Sender: TObject);
    procedure ProxyUserEditingDone(Sender: TObject);
    procedure T_QualliChange(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ConfigForm: TConfigForm;
  Dir, slash: string;
  Config_INI: TIniFile;
  Create_Form: Boolean;
implementation

uses Main;

{$R *.lfm}

{ TConfigForm }

procedure SaveConfig;
begin
  if Create_Form = false then
  begin
    Create_Form := True;
    Config_INI:=TIniFile.Create(dir + slash + 'config.ini');
    try
      Config_INI.WriteString('Einstellungen','Pfad',ConfigForm.E_Pfad.Text);
      Config_INI.WriteInteger('Einstellungen','Bild_Quali',ConfigForm.T_Qualli.Position);
      Config_INI.WriteString('Einstellungen','Waip_Praefix',ConfigForm.E_waip_praefix.Text);
      Config_INI.WriteString('Einstellungen','Waip_Suffix',ConfigForm.E_waip_suffix.Text);
      Config_INI.WriteString('Einstellungen','Waip-Web_IP',ConfigForm.E_ip_web.Text);
      Config_INI.WriteString('Einstellungen','Dashboard-Link',ConfigForm.E_dbrd_link.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Host',ConfigForm.ProxyHost.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Port',ConfigForm.ProxyPort.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Benutzer',ConfigForm.ProxyUser.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Passwort',ConfigForm.ProxyPass.Text);
      Config_INI.WriteBool('Einstellungen','Alarm_Zeit',ConfigForm.CB_Alarm_Zeit.Checked);
    finally
      Config_INI.free;
    end;
    Create_Form := false;
  end;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  {$ifdef  Windows}
  slash := '\';
  {$else}
  slash := '/';
  {$endif}
  Create_Form := True;
  getdir(0,Dir);
  Dir := Dir + slash + 'config';
  // Einstellungen in Config.ini Speichern
  if FileExists(Dir + slash + 'config.ini') then
  begin
    Config_INI:=TIniFile.Create(dir + slash + 'config.ini');
    try
      ConfigForm.E_Pfad.Text := Config_INI.ReadString('Einstellungen','Pfad','');
      ConfigForm.T_Qualli.Position := Config_INI.ReadInteger('Einstellungen','Bild_Quali',0);
      ConfigForm.E_waip_praefix.Text := Config_INI.ReadString('Einstellungen','Waip_Praefix','');
      ConfigForm.E_waip_suffix.Text := Config_INI.ReadString('Einstellungen','Waip_Suffix','');
      ConfigForm.E_ip_web.Text := Config_INI.ReadString('Einstellungen','Waip-Web_IP','');
      ConfigForm.E_dbrd_link.Text := Config_INI.ReadString('Einstellungen','Dashboard-Link','');
      ConfigForm.ProxyHost.Text := Config_INI.ReadString('Einstellungen','Proxy_Host','');
      ConfigForm.ProxyPort.Text := Config_INI.ReadString('Einstellungen','Proxy_Port','');
      ConfigForm.ProxyUser.Text := Config_INI.ReadString('Einstellungen','Proxy_Benutzer','');
      ConfigForm.ProxyPass.Text := Config_INI.ReadString('Einstellungen','Proxy_Passwort','');
      ConfigForm.CB_Alarm_Zeit.Checked := Config_INI.ReadBool('Einstellungen','Alarm_Zeit',true);
    finally
      Config_INI.free;
    end;
  end
  else
  begin
    Config_INI:=TIniFile.Create(dir + slash + 'config.ini');
    try
      Config_INI.WriteString('Einstellungen','Pfad',ConfigForm.E_Pfad.Text);
      Config_INI.WriteInteger('Einstellungen','Bild_Quali',ConfigForm.T_Qualli.Position);
      Config_INI.WriteString('Einstellungen','Waip_Praefix',ConfigForm.E_waip_praefix.Text);
      Config_INI.WriteString('Einstellungen','Waip_Suffix',ConfigForm.E_waip_suffix.Text);
      Config_INI.WriteString('Einstellungen','Waip-Web_IP',ConfigForm.E_ip_web.Text);
      Config_INI.WriteString('Einstellungen','Dashboard-Link',ConfigForm.E_dbrd_link.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Host',ConfigForm.ProxyHost.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Port',ConfigForm.ProxyPort.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Benutzer',ConfigForm.ProxyUser.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Passwort',ConfigForm.ProxyPass.Text);
      Config_INI.WriteBool('Einstellungen','Alarm_Zeit',ConfigForm.CB_Alarm_Zeit.Checked);
    finally
      Config_INI.free;
    end;
  end;
  // Standardwerte laden, falls noch keine Einstellungen vorhanden sind
  if E_Pfad.Text = '' then
    {$ifdef  Windows}
      E_Pfad.Text := 'C:\';
    {$else}
      E_Pfad.Text := '/';
  {$endif}
  if E_waip_praefix.Text = '' then
    E_waip_praefix.Text := 'waip';
  if E_waip_suffix.Text = '' then
    E_waip_suffix.Text := 'txt';
  // sonstige GUI-Werte
  ConfigForm.L_Prozent.Caption := inttostr(ConfigForm.T_Qualli.Position*10) + '% ';
  MainForm.StatusBar1.Panels[0].Text := 'Waip.txt-Pfad: ' + ConfigForm.E_Pfad.Text;
  Create_form := false;
end;

procedure TConfigForm.ProxyHostEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.ProxyPassEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.ProxyPortEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.ProxyUserEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.T_QualliChange(Sender: TObject);
begin
  SaveConfig;
  ConfigForm.L_Prozent.Caption := inttostr(ConfigForm.T_Qualli.Position*10) + '% ';
end;

procedure TConfigForm.E_PfadEditingDone(Sender: TObject);
begin
  SaveConfig;
  MainForm.StatusBar1.Panels[0].Text := 'Pfad zur Übergabedatei: ' + ConfigForm.E_Pfad.Text;
end;

procedure TConfigForm.E_waip_praefixEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.E_waip_suffixEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.Btn_BackClick(Sender: TObject);
begin
  ConfigForm.Hide;
end;

procedure TConfigForm.Btn_OpenDirClick(Sender: TObject);
begin
  OpenDocument(E_Pfad.Text);
end;

procedure TConfigForm.Btn_SelectDirClick(Sender: TObject);
var uebergabeordner, tmp_dir: String;
begin
  getdir(0, tmp_dir);
  if selectdirectory('Bitte wählen Sie den Ordner aus, in welchem die Übergabedateien liegen', tmp_dir, uebergabeordner) then
  begin
    E_Pfad.Text := uebergabeordner;
    SaveConfig;
  end;
end;

procedure TConfigForm.CB_Alarm_ZeitChange(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.E_dbrd_linkEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.E_ip_webEditingDone(Sender: TObject);
begin
  SaveConfig;
end;

procedure TConfigForm.FormClose(Sender: TObject);
begin
  ConfigForm.Hide;
end;

end.
