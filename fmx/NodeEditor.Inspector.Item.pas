unit NodeEditor.Inspector.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Rtti, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation;

type
  TFrameInspectorItem = class(TFrame)
    LabelPropName: TLabel;
    LayoutDesc: TLayout;
    LayoutControl: TLayout;
    PathLabelIcon: TPathLabel;
    PanelBG: TPanel;
  private
    FMin: Double;
    FMax: Double;
  protected
    FPropName: string;
    FChanged: Boolean;
    procedure SetMin(const Value: Double); virtual;
    procedure SetMax(const Value: Double); virtual;
    procedure SetPropName(const Value: string); virtual;
    function GetValue: TValue; virtual; abstract;
    procedure SetValue(const Value: TValue); virtual; abstract;
    function GetIsChanged: Boolean; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property Value: TValue read GetValue write SetValue;
    property PropName: string read FPropName write SetPropName;
    property IsChanged: Boolean read GetIsChanged;
    property Min: Double read FMin write SetMin;
    property Max: Double read FMax write SetMax;
  end;

implementation

{$R *.fmx}

{ TFrameInspectorItem }

constructor TFrameInspectorItem.Create(AOwner: TComponent);
begin
  inherited;
  Name := '';
end;

function TFrameInspectorItem.GetIsChanged: Boolean;
begin
  Result := FChanged;
end;

procedure TFrameInspectorItem.SetMax(const Value: Double);
begin
  FMax := Value;
end;

procedure TFrameInspectorItem.SetMin(const Value: Double);
begin
  FMin := Value;
end;

procedure TFrameInspectorItem.SetPropName(const Value: string);
begin
  FPropName := Value;
  LabelPropName.Text := FPropName;
end;

end.

