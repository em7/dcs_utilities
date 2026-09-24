unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Spin,
  StdCtrls, AltimeterGauge, QnhQfeCalc;

type

  { TMainForm }

  TMainForm = class(TForm)
    Altimeter: TTabSheet;
    AltimeterGaugeCtrl: TAltimeterGauge;
    AltitudeLabel: TLabel;
    AltitudeSpinEdit: TSpinEdit;
				AltitudeMLabel: TLabel;
				PressureMmLabel: TLabel;
    MainPageCtrl: TPageControl;
    PressureInLabel: TLabel;
				PressureHpaLabel: TLabel;
    PressureInSpinEdit: TFloatSpinEdit;
    QnhQfe: TTabSheet;
				PressureHpaSpinEdit: TSpinEdit;
				AltitudeMSpinEdit: TSpinEdit;
				PressureMmSpinEdit: TSpinEdit;

				procedure AltitudeMSpinEditChange(Sender: TObject);
    procedure AltitudeSpinEditChange(Sender: TObject);
				procedure MainPageCtrlChange(Sender: TObject);
				procedure PressureHpaSpinEditChange(Sender: TObject);
    procedure PressureInSpinEditChange(Sender: TObject);
				procedure PressureMmSpinEditChange(Sender: TObject);

  private
    // Stops updating UI to distinguish between update made by user
    // and auto-updates from the code.
    StopUiUpdate: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StopUiUpdate := False;
end;

procedure TMainForm.AltitudeSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
     Exit;

  StopUiUpdate := True;
  AltimeterGaugeCtrl.Altitude := AltitudeSpinEdit.Value;
  AltitudeMSpinEdit.Value := QnhQfeCalc.FeetToMeters(AltitudeSpinEdit.Value);
  StopUIUpdate := False;
end;

procedure TMainForm.AltitudeMSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
     Exit;

  StopUiUpdate := True;
  AltitudeSpinEdit.Value := QnhQfeCalc.MetersToFeet(AltitudeMSpinEdit.Value);
  AltimeterGaugeCtrl.Altitude := AltitudeSpinEdit.Value;
  StopUIUpdate := False;
end;

procedure TMainForm.MainPageCtrlChange(Sender: TObject);
begin

end;

procedure TMainForm.PressureHpaSpinEditChange(Sender: TObject);
begin
	  if StopUiUpdate then
	    Exit;

	  StopUiUpdate := True;
	  PressureMmSpinEdit.Value := QnhQfeCalc.HpaToMmHg(PressureHpaSpinEdit.Value);
	  PressureInSpinEdit.Value := QnhQfeCalc.HpaToInHg(PressureHpaSpinEdit.Value);
	  AltimeterGaugeCtrl.PressureInHg := PressureInSpinEdit.Value;
	  StopUIUpdate := False;
end;

procedure TMainForm.PressureInSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
     Exit;

  StopUiUpdate := True;
  PressureHpaSpinEdit.Value := QnhQfeCalc.InHgToHpa(PressureInSpinEdit.Value);
  PressureMmSpinEdit.Value := QnhQfeCalc.HpaToMmHg(PressureHpaSpinEdit.Value);
  AltimeterGaugeCtrl.PressureInHg := PressureInSpinEdit.Value;
  StopUIUpdate := False;
end;

procedure TMainForm.PressureMmSpinEditChange(Sender: TObject);
begin
  if StopUiUpdate then
     Exit;

  StopUiUpdate := True;
  PressureHpaSpinEdit.Value := QnhQfeCalc.MmHgToHpa(PressureMmSpinEdit.Value);
  PressureInSpinEdit.Value := QnhQfeCalc.HpaToInHg(PressureHpaSpinEdit.Value);
  AltimeterGaugeCtrl.PressureInHg := PressureInSpinEdit.Value;
  StopUIUpdate := False;
end;

initialization
  RegisterClass(TSpinEdit);

end.

