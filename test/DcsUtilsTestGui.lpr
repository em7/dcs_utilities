program DcsUtilsTestGui;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, test_qnhqfecalc, QnhQfeCalc, test_airspeedcalc,
  test_groundattackcalc, AirspeedCalc, GroundAttackCalc, GuiTestRunner;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

