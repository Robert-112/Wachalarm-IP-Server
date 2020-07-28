program WachalarmIPServer;

{$mode objfpc}{$H+}

uses

  {$ifdef unix}
    cthreads,
  {$endif}

  Forms, Interfaces, Splash,
  Main in 'Main.pas' {MainForm},
  Config in 'Config.pas' {ConfigForm},
  Alarm_Picture in 'Alarm_Picture.pas' {PictureForm},
  Twitter_Picture in 'Twitter_Picture.pas' {TwitterForm},
  Simulation in 'Simulation.pas' {SimulationForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Splash, Frm_Splash);
  frm_Splash.ShowModal;
  frm_Splash.Free;
  frm_Splash := nil;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfigForm, ConfigForm);
  Application.CreateForm(TPictureForm, PictureForm);
  Application.CreateForm(TTwitterForm, TwitterForm);
  Application.CreateForm(TSimulationForm, SimulationForm);
  Application.Run;
end.
