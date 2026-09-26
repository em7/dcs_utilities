{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit DcsUtilsUIComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
   AltimeterGauge, QnhQfeCalc, AirspeedGauge, AirspeedCalc, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('AltimeterGauge', @AltimeterGauge.Register);
  RegisterUnit('AirspeedGauge', @AirspeedGauge.Register);
end;

initialization
  RegisterPackage('DcsUtilsUIComponents', @Register);
end.
