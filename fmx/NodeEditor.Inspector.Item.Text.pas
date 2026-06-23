unit NodeEditor.Inspector.Item.Text;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit,
  System.Rtti;

type
  TFrameInspectorItemText = class(TFrameInspectorItem)
    EditValue: TEdit;
    procedure EditValueChangeTracking(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
  public
    { Public declarations }
  end;

var
  FrameInspectorItemText: TFrameInspectorItemText;

implementation

{$R *.fmx}

{ TFrameInspectorItemText }

procedure TFrameInspectorItemText.EditValueChangeTracking(Sender: TObject);
begin
  FChanged := True;
end;

function TFrameInspectorItemText.GetValue: TValue;
begin
  Result := EditValue.Text;
end;

procedure TFrameInspectorItemText.SetValue(const Value: TValue);
begin
  EditValue.BeginUpdate;
  EditValue.Text := Value.AsString;
  EditValue.EndUpdate;
  FChanged := False;
end;

end.

