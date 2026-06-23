unit NodeEditor.Inspector.Item.Color;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Controls.Presentation, FMX.Layouts, FMX.Colors,
  System.Rtti;

type
  TFrameInspectorItemColor = class(TFrameInspectorItem)
    ComboColorBoxValue: TComboColorBox;
    procedure ComboColorBoxValueChange(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
  public
    { Public declarations }
  end;

var
  FrameInspectorItemColor: TFrameInspectorItemColor;

implementation

{$R *.fmx}

{ TFrameInspectorItemColor }

function TFrameInspectorItemColor.GetValue: TValue;
begin
  Result := TValue.From<TAlphaColor>(ComboColorBoxValue.Color);
end;

procedure TFrameInspectorItemColor.SetValue(const Value: TValue);
begin
  ComboColorBoxValue.BeginUpdate;
  ComboColorBoxValue.Color := Value.AsType<TAlphaColor>;
  ComboColorBoxValue.EndUpdate;
  FChanged := False;
end;

procedure TFrameInspectorItemColor.ComboColorBoxValueChange(Sender: TObject);
begin
  FChanged := True;
end;

end.

