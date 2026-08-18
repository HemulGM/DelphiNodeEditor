unit NodeEditor.Inspector.Item.Memo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Layouts, FMX.Controls.Presentation, FMX.Edit,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, System.Rtti;

type
  TFrameInspectorItemMemo = class(TFrameInspectorItem)
    MemoValue: TMemo;
    procedure MemoValueChangeTracking(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
  end;

var
  FrameInspectorItemMemo: TFrameInspectorItemMemo;

implementation

{$R *.fmx}

procedure TFrameInspectorItemMemo.MemoValueChangeTracking(Sender: TObject);
begin
  FChanged := True;
end;

function TFrameInspectorItemMemo.GetValue: TValue;
begin
  Result := MemoValue.Text;
end;

procedure TFrameInspectorItemMemo.SetValue(const Value: TValue);
begin
  MemoValue.BeginUpdate;
  MemoValue.Text := Value.AsString;
  MemoValue.EndUpdate;
  FChanged := False;
end;

end.

