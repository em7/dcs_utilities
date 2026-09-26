program DcsUtilsTestGui;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, test_qnhqfecalc, QnhQfeCalc, test_airspeedcalc,
  AirspeedCalc, GuiTestRunner;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

