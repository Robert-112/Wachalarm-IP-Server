unit Config;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, IniFiles;

type

  { TConfigForm }

  TConfigForm = class(TForm)
    E_waip_praefix: TEdit;
    E_waip_suffix: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    M_DirectoryList: TMemo;
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
      Config_INI.WriteString('Einstellungen','Proxy_Host',ConfigForm.ProxyHost.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Port',ConfigForm.ProxyPort.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Benutzer',ConfigForm.ProxyUser.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Passwort',ConfigForm.ProxyPass.Text);
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
      ConfigForm.ProxyHost.Text := Config_INI.ReadString('Einstellungen','Proxy_Host','');
      ConfigForm.ProxyPort.Text := Config_INI.ReadString('Einstellungen','Proxy_Port','');
      ConfigForm.ProxyUser.Text := Config_INI.ReadString('Einstellungen','Proxy_Benutzer','');
      ConfigForm.ProxyPass.Text := Config_INI.ReadString('Einstellungen','Proxy_Passwort','');
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
      Config_INI.WriteString('Einstellungen','Proxy_Host',ConfigForm.ProxyHost.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Port',ConfigForm.ProxyPort.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Benutzer',ConfigForm.ProxyUser.Text);
      Config_INI.WriteString('Einstellungen','Proxy_Passwort',ConfigForm.ProxyPass.Text);
    finally
      Config_INI.free;
    end;
  end;
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

procedure TConfigForm.FormClose(Sender: TObject);
begin
  ConfigForm.Hide;
end;

end.
