unit Twitter_Picture;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TTwitterForm }

  TTwitterForm = class(TForm)
    I_Background: TImage;
    L_Account_Name: TLabel;
    L_Einsatzart_Langtext: TLabel;
    L_Datum_Uhrzeit: TLabel;
    L_Ort_Ortsteil: TLabel;
    L_At_Account: TLabel;
    L_Wachen_Einsatzmittel: TLabel;
    L_Text_Einsatzort: TLabel;
    L_Text_Einsatzgrund: TLabel;
    L_Stichwort_Langtext: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure L_Einsatzart_LangtextResize(Sender: TObject);
    procedure L_Ort_OrtsteilResize(Sender: TObject);
    procedure L_Stichwort_LangtextResize(Sender: TObject);
    procedure L_Wachen_EinsatzmittelResize(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  TwitterForm: TTwitterForm;

implementation

{$R *.lfm}

{ TTwitterForm }

procedure TTwitterForm.FormShow(Sender: TObject);
begin
  L_Wachen_Einsatzmittel.AdjustFontForOptimalFill;
  L_Wachen_Einsatzmittel.AdjustSize;
  L_Ort_Ortsteil.AdjustFontForOptimalFill;
  L_Ort_Ortsteil.AdjustSize;
  L_Stichwort_Langtext.AdjustFontForOptimalFill;
  L_Stichwort_Langtext.AdjustSize;
  L_Einsatzart_Langtext.AdjustFontForOptimalFill;
  L_Einsatzart_Langtext.AdjustSize;
end;

procedure TTwitterForm.FormCreate(Sender: TObject);
var Dir, Slash: string;
begin
  {$ifdef  Windows}
  Slash := '\';
  {$else}
  Slash := '/';
  {$endif}
  GetDir(0, Dir);
  Dir := Dir + Slash + 'config';
  // eigenen Twitter-Hintergrund laden, falls vorhanden
  try
    TwitterForm.I_Background.Picture.LoadFromFile(Dir + Slash + 'twitter_background.jpg');
  except
  end;
  // Schriftart DejaVu Sans setzen, sofern vorhanden, sonst default
  if Screen.Fonts.IndexOf('DejaVu Sans') <> -1 then
  begin
    L_Account_Name.Font.Name := 'DejaVu Sans';
    L_Text_Einsatzort.Font.Name := 'DejaVu Sans';
    L_Ort_Ortsteil.Font.Name := 'DejaVu Sans';
    L_Text_Einsatzgrund.Font.Name := 'DejaVu Sans';
    L_Einsatzart_Langtext.Font.Name := 'DejaVu Sans';
    L_Stichwort_Langtext.Font.Name := 'DejaVu Sans';
    L_Wachen_Einsatzmittel.Font.Name := 'DejaVu Sans';
    L_Datum_Uhrzeit.Font.Name := 'DejaVu Sans';
    L_At_Account.Font.Name := 'DejaVu Sans';
  end;
end;

procedure TTwitterForm.L_Wachen_EinsatzmittelResize(Sender: TObject);
begin
  L_Wachen_Einsatzmittel.AdjustFontForOptimalFill;
  L_Wachen_Einsatzmittel.AdjustSize;
end;

procedure TTwitterForm.L_Ort_OrtsteilResize(Sender: TObject);
begin
  L_Ort_Ortsteil.AdjustFontForOptimalFill;
  L_Ort_Ortsteil.AdjustSize;
end;

procedure TTwitterForm.L_Stichwort_LangtextResize(Sender: TObject);
begin
  L_Stichwort_Langtext.AdjustFontForOptimalFill;
  L_Stichwort_Langtext.AdjustSize;
end;

procedure TTwitterForm.L_Einsatzart_LangtextResize(Sender: TObject);
begin
  L_Einsatzart_Langtext.AdjustFontForOptimalFill;
  L_Einsatzart_Langtext.AdjustSize;
end;

end.

