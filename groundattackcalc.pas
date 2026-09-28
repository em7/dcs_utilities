unit GroundAttackCalc;

{$mode ObjFPC}{$H+}

interface

type
  TDiveBombingProfileId = (dbp20Degree, dbp30Degree);
  TSquareTurnDirection = (stdLeft, stdRight);
  THeadingArray = array[0..3] of Integer;

  TDiveBombingProfile = record
    DiveAngleDegrees: Integer;
    DiveInitiationAglFeet: Integer;
    DiveInitiationSpeedKnots: Integer;
    ReleaseAglFeet: Integer;
    ReleaseSpeedMinKnots: Integer;
    ReleaseSpeedMaxKnots: Integer;
    ReticleDepressionMils: Integer;
  end;

function GetDiveBombingProfile(AProfileId: TDiveBombingProfileId): TDiveBombingProfile;
function CalculateMslAltitude(ATargetMslFeet, AHeightAglFeet: Integer): Integer;
function NormalizeHeading(AHeadingDegrees: Integer): Integer;
function CalculateSquareHeadings(AAttackDirectionDegrees: Integer;
  ATurnDirection: TSquareTurnDirection): THeadingArray;

implementation

function GetDiveBombingProfile(AProfileId: TDiveBombingProfileId): TDiveBombingProfile;
begin
  case AProfileId of
    dbp20Degree:
      begin
        Result.DiveAngleDegrees := 20;
        Result.DiveInitiationAglFeet := 5000;
        Result.DiveInitiationSpeedKnots := 350;
        Result.ReleaseAglFeet := 1500;
        Result.ReleaseSpeedMinKnots := 380;
        Result.ReleaseSpeedMaxKnots := 400;
        Result.ReticleDepressionMils := 80;
      end;
    dbp30Degree:
      begin
        Result.DiveAngleDegrees := 30;
        Result.DiveInitiationAglFeet := 6000;
        Result.DiveInitiationSpeedKnots := 350;
        Result.ReleaseAglFeet := 2000;
        Result.ReleaseSpeedMinKnots := 440;
        Result.ReleaseSpeedMaxKnots := 450;
        Result.ReticleDepressionMils := 79;
      end;
  end;
end;

function CalculateMslAltitude(ATargetMslFeet, AHeightAglFeet: Integer): Integer;
begin
  Result := ATargetMslFeet + AHeightAglFeet;
end;

function NormalizeHeading(AHeadingDegrees: Integer): Integer;
begin
  Result := AHeadingDegrees mod 360;
  if Result < 0 then
    Inc(Result, 360);
end;

function CalculateSquareHeadings(AAttackDirectionDegrees: Integer;
  ATurnDirection: TSquareTurnDirection): THeadingArray;
var
  Index: Integer;
  TurnDegrees: Integer;
begin
  if ATurnDirection = stdLeft then
    TurnDegrees := -90
  else
    TurnDegrees := 90;

  for Index := Low(Result) to High(Result) do
    Result[Index] := NormalizeHeading(AAttackDirectionDegrees +
      Index * TurnDegrees);
end;

end.
