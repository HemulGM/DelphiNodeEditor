unit NodeEditor.Inspector.Item.Bool;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Controls.Presentation, FMX.Layouts, System.Rtti;

type
  TFrameInspectorItemBool = class(TFrameInspectorItem)
    CheckBoxValue: TCheckBox;
    procedure CheckBoxValueChange(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
  public
  end;

var
  FrameInspectorItemBool: TFrameInspectorItemBool;

implementation

{$R *.fmx}

{ TFrameInspectorItemBool }

function TFrameInspectorItemBool.GetValue: TValue;
begin
  Result := CheckBoxValue.IsChecked;
end;

procedure TFrameInspectorItemBool.SetValue(const Value: TValue);
begin
  CheckBoxValue.BeginUpdate;
  CheckBoxValue.IsChecked := Value.AsBoolean;
  CheckBoxValue.EndUpdate;
  FChanged := False;
end;

procedure TFrameInspectorItemBool.CheckBoxValueChange(Sender: TObject);
begin
  FChanged := True;
end;

end.

