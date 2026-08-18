unit NodeEditor.Frame.Progress;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TFrameProgress = class(TFrame)
    ProgressBarValue: TProgressBar;
    LabelMsg: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrameProgress: TFrameProgress;

implementation

{$R *.fmx}

end.

