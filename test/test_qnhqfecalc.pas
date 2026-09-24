unit test_qnhqfecalc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, QnhQfeCalc;

type

  TQnhQfeCalc= class(TTestCase)
  published
    procedure SeaLevelQnhEqualsQfe;
    procedure QnhToQfeAndBackRoundTrips;
    procedure PressureUnitConversions;
  end;

implementation

procedure TQnhQfeCalc.SeaLevelQnhEqualsQfe;
begin
  AssertEquals(1013.25, QnhToQfe(1013.25, 0), 0.01);
end;

procedure TQnhQfeCalc.QnhToQfeAndBackRoundTrips;
var
  QnhHpa: Double;
  QfeHpa: Double;
begin
  QnhHpa := 1013.25;
  QfeHpa := QnhToQfe(QnhHpa, 1000);
  AssertEquals(QnhHpa, QfeToQnh(QfeHpa, 1000), 0.01);
end;

procedure TQnhQfeCalc.PressureUnitConversions;
begin
  AssertEquals(29.92, HpaToInHg(1013.25), 0.01);
  AssertEquals(760.0, HpaToMmHg(1013.25), 0.1);
end;

initialization

  RegisterTest(TQnhQfeCalc);
end.

