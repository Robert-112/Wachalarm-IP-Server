unit Alarm_Picture;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type

  { TPictureForm }

  TPictureForm = class(TForm)
    LBesonder: TLabel;
    LEinsatzart: TLabel;
    LOrtsdaten: TLabel;
    LSondersig: TLabel;
    LMitaus: TLabel;
    LAlarmGrund: TLabel;
    LEinsatzmittel: TLabel;
    P_Top: TPanel;
    P_Center: TPanel;
    P_Right: TPanel;
    P_Left: TPanel;
    P_Button: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure LAlarmGrundResize(Sender: TObject);
    procedure LBesonderResize(Sender: TObject);
    procedure LEinsatzartResize(Sender: TObject);
    procedure LEinsatzmittelResize(Sender: TObject);
    procedure Form_anpassen;
    procedure LMitausResize(Sender: TObject);
    procedure LOrtsdatenResize(Sender: TObject);
    procedure LSondersigResize(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;
                                               
var
  PictureForm: TPictureForm;                      

implementation

{$R *.lfm}

{ TPictureForm }

procedure TPictureForm.FormCreate(Sender: TObject);
begin
  // finales Formdesign erst zur Laufzeit anpassen
  P_Top.BevelOuter := bvNone;
  P_Center.BevelOuter := bvNone;
  P_Left.BevelOuter := bvNone;
  P_Right.BevelOuter := bvNone;
  P_Button.BevelOuter := bvNone;
  PictureForm.Color := clBlack;
end;

procedure TPictureForm.Form_anpassen;
begin
  // Oben ausrichten und Label anpassen
  P_Top.Height := Round(PictureForm.Height * 0.25);
  LEinsatzart.Height := Round(P_Top.Height * 0.55);
  LAlarmGrund.Height := Round(P_Top.Height * 0.45);
  LSondersig.Width := LSondersig.Height;
  // Mitte ausrichten und Label anpassen
  P_Center.Height := Round(PictureForm.Height * 0.65);
  P_Left.Width := Round(PictureForm.Width * 0.55);
  P_Right.Width := Round(PictureForm.Width * 0.45);
  LOrtsdaten.Height := Round(P_Left.Height * 0.8);
  LBesonder.Height := Round(P_Left.Height * 0.2);
  // Unten ausrichten
  P_Button.Height := Round(PictureForm.Height * 0.1);
end;

procedure TPictureForm.FormResize(Sender: TObject);
begin
  Form_anpassen;
end;

procedure TPictureForm.FormWindowStateChange(Sender: TObject);
begin
  Form_anpassen;
end;

procedure TPictureForm.FormShow(Sender: TObject);
begin
  LMitaus.AdjustFontForOptimalFill;
  LMitaus.AdjustSize;
  LOrtsdaten.AdjustFontForOptimalFill;
  LOrtsdaten.AdjustSize;
  LSondersig.AdjustFontForOptimalFill;
  LSondersig.AdjustSize;
  LEinsatzmittel.AdjustFontForOptimalFill;
  LEinsatzmittel.AdjustSize;
  LAlarmGrund.AdjustFontForOptimalFill;
  LAlarmGrund.AdjustSize;
  LBesonder.AdjustFontForOptimalFill;
  LBesonder.AdjustSize;
  LEinsatzart.AdjustFontForOptimalFill;
  LEinsatzart.AdjustSize;
end;

procedure TPictureForm.LMitausResize(Sender: TObject);
begin
  LMitaus.AdjustFontForOptimalFill;
  LMitaus.AdjustSize;
end;

procedure TPictureForm.LOrtsdatenResize(Sender: TObject);
begin
  LOrtsdaten.AdjustFontForOptimalFill;
  LOrtsdaten.AdjustSize;
end;

procedure TPictureForm.LSondersigResize(Sender: TObject);
begin
  LSondersig.AdjustFontForOptimalFill;
  LSondersig.AdjustSize;
end;

procedure TPictureForm.LEinsatzmittelResize(Sender: TObject);
begin
  LEinsatzmittel.AdjustFontForOptimalFill;
  LEinsatzmittel.AdjustSize;
end;

procedure TPictureForm.LAlarmGrundResize(Sender: TObject);
begin
  LAlarmGrund.AdjustFontForOptimalFill;
  LAlarmGrund.AdjustSize;
end;

procedure TPictureForm.LBesonderResize(Sender: TObject);
begin
  LBesonder.AdjustFontForOptimalFill;
  LBesonder.AdjustSize;
end;

procedure TPictureForm.LEinsatzartResize(Sender: TObject);
begin
  LEinsatzart.AdjustFontForOptimalFill;
  LEinsatzart.AdjustSize;
end;

end.
