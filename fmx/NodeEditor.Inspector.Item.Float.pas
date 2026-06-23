unit NodeEditor.Inspector.Item.Float;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  FMX.EditBox, FMX.SpinBox, System.Rtti;

type
  TFrameInspectorItemFloat = class(TFrameInspectorItem)
    SpinBoxValue: TSpinBox;
    procedure SpinBoxValueChangeTracking(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
    procedure SetMin(const Value: Double); override;
    procedure SetMax(const Value: Double); override;
  private
  public
    { Public declarations }
  end;

var
  FrameInspectorItemFloat: TFrameInspectorItemFloat;

implementation

{$R *.fmx}

{ TFrameInspectorItemFloat }

function TFrameInspectorItemFloat.GetValue: TValue;
begin
  Result := SpinBoxValue.Value;
end;

procedure TFrameInspectorItemFloat.SetMax(const Value: Double);
begin
  inherited;
  SpinBoxValue.Max := Value;
end;

procedure TFrameInspectorItemFloat.SetMin(const Value: Double);
begin
  inherited;
  SpinBoxValue.Min := Value;
end;

procedure TFrameInspectorItemFloat.SetValue(const Value: TValue);
begin
  SpinBoxValue.BeginUpdate;
  SpinBoxValue.Value := Value.AsExtended;
  SpinBoxValue.EndUpdate;
  FChanged := False;
end;

procedure TFrameInspectorItemFloat.SpinBoxValueChangeTracking(Sender: TObject);
begin
  FChanged := True;
end;

end.

