program DcsUtilsTestGui;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, test_qnhqfecalc, QnhQfeCalc, GuiTestRunner;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

