unit NodeEditor.Inspector.Item.Bitmap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  NodeEditor.Inspector.Item, FMX.Controls.Presentation, FMX.Layouts, FMX.Objects,
  System.Rtti;

type
  TFrameInspectorItemBitmap = class(TFrameInspectorItem)
    ImageValue: TImage;
    ButtonChoose: TButton;
    OpenDialogImage: TOpenDialog;
    procedure ButtonChooseClick(Sender: TObject);
  protected
    function GetValue: TValue; override;
    procedure SetValue(const Value: TValue); override;
  public
    { Public declarations }
  end;

var
  FrameInspectorItemBitmap: TFrameInspectorItemBitmap;

implementation

{$R *.fmx}

{ TFrameInspectorItemBitmap }

procedure TFrameInspectorItemBitmap.ButtonChooseClick(Sender: TObject);
begin
  if OpenDialogImage.Execute then
  begin
    ImageValue.Bitmap.LoadFromFile(OpenDialogImage.FileName);
    FChanged := True;
  end;
end;

function TFrameInspectorItemBitmap.GetValue: TValue;
begin
  Result := ImageValue.Bitmap;
end;

procedure TFrameInspectorItemBitmap.SetValue(const Value: TValue);
begin
  ImageValue.BeginUpdate;
  ImageValue.Bitmap.Assign(Value.AsType<TBitmap>);
  ImageValue.EndUpdate;
  FChanged := False;
end;

end.

