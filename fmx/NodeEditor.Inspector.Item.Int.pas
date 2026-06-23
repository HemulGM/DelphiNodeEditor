unit NodeEditor.Inspector.Item.Int;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  FMX.EditBox, FMX.SpinBox, System.Rtti;

type
  TFrameInspectorItemInt = class(TFrameInspectorItem)
    SpinBoxValue: TSpinBox;
    procedure SpinBoxValueChangeTracking(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
    procedure SetMin(const Value: Double); override;
    procedure SetMax(const Value: Double); override;
  public
    { Public declarations }
  end;

var
  FrameInspectorItemInt: TFrameInspectorItemInt;

implementation

{$R *.fmx}

{ TFrameInspectorItemInt }

function TFrameInspectorItemInt.GetValue: TValue;
begin
  Result := Trunc(SpinBoxValue.Value);
end;

procedure TFrameInspectorItemInt.SetMax(const Value: Double);
begin
  inherited;
  SpinBoxValue.Max := Value;
end;

procedure TFrameInspectorItemInt.SetMin(const Value: Double);
begin
  inherited;
  SpinBoxValue.Min := Value;
end;

procedure TFrameInspectorItemInt.SetValue(const Value: TValue);
begin
  SpinBoxValue.BeginUpdate;
  SpinBoxValue.Value := Value.AsInt64;
  SpinBoxValue.EndUpdate;
  FChanged := False;
end;

procedure TFrameInspectorItemInt.SpinBoxValueChangeTracking(Sender: TObject);
begin
  FChanged := True;
end;

end.

