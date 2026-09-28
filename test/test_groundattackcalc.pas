unit test_groundattackcalc;

{$mode ObjFPC}{$H+}

interface

uses
  fpcunit, testregistry, GroundAttackCalc;

type
  TGroundAttackCalcTest = class(TTestCase)
  published
    procedure Returns20DegreeProfile;
    procedure Returns30DegreeProfile;
    procedure AddsAglHeightToTargetMslAltitude;
    procedure NormalizesHeadings;
    procedure CalculatesLeftTurnHeadings;
    procedure CalculatesRightTurnHeadings;
  end;

implementation

procedure TGroundAttackCalcTest.Returns20DegreeProfile;
var
  Profile: TDiveBombingProfile;
begin
  Profile := GetDiveBombingProfile(dbp20Degree);
  AssertEquals(20, Profile.DiveAngleDegrees);
  AssertEquals(5000, Profile.DiveInitiationAglFeet);
  AssertEquals(350, Profile.DiveInitiationSpeedKnots);
  AssertEquals(1500, Profile.ReleaseAglFeet);
  AssertEquals(380, Profile.ReleaseSpeedMinKnots);
  AssertEquals(400, Profile.ReleaseSpeedMaxKnots);
  AssertEquals(80, Profile.ReticleDepressionMils);
end;

procedure TGroundAttackCalcTest.Returns30DegreeProfile;
var
  Profile: TDiveBombingProfile;
begin
  Profile := GetDiveBombingProfile(dbp30Degree);
  AssertEquals(30, Profile.DiveAngleDegrees);
  AssertEquals(6000, Profile.DiveInitiationAglFeet);
  AssertEquals(350, Profile.DiveInitiationSpeedKnots);
  AssertEquals(2000, Profile.ReleaseAglFeet);
  AssertEquals(440, Profile.ReleaseSpeedMinKnots);
  AssertEquals(450, Profile.ReleaseSpeedMaxKnots);
  AssertEquals(79, Profile.ReticleDepressionMils);
end;

procedure TGroundAttackCalcTest.AddsAglHeightToTargetMslAltitude;
begin
  AssertEquals(6500, CalculateMslAltitude(1500, 5000));
  AssertEquals(4500, CalculateMslAltitude(-500, 5000));
  AssertEquals(1500, CalculateMslAltitude(0, 1500));
end;

procedure TGroundAttackCalcTest.NormalizesHeadings;
begin
  AssertEquals(0, NormalizeHeading(0));
  AssertEquals(359, NormalizeHeading(359));
  AssertEquals(0, NormalizeHeading(360));
  AssertEquals(1, NormalizeHeading(721));
  AssertEquals(359, NormalizeHeading(-1));
  AssertEquals(270, NormalizeHeading(-450));
end;

procedure TGroundAttackCalcTest.CalculatesLeftTurnHeadings;
var
  Headings: THeadingArray;
begin
  Headings := CalculateSquareHeadings(45, stdLeft);
  AssertEquals(45, Headings[0]);
  AssertEquals(315, Headings[1]);
  AssertEquals(225, Headings[2]);
  AssertEquals(135, Headings[3]);
end;

procedure TGroundAttackCalcTest.CalculatesRightTurnHeadings;
var
  Headings: THeadingArray;
begin
  Headings := CalculateSquareHeadings(350, stdRight);
  AssertEquals(350, Headings[0]);
  AssertEquals(80, Headings[1]);
  AssertEquals(170, Headings[2]);
  AssertEquals(260, Headings[3]);
end;

initialization
  RegisterTest(TGroundAttackCalcTest);
end.
