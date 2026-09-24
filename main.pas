unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    MainPageCtrl: TPageControl;
    QnhQfe: TTabSheet;
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

end.

