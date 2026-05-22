unit NodeEditor.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.NodeEditor, FMX.Edit,
  FMX.Grid.Style, FMX.Layouts, FMX.Menus, FMX.EditBox, FMX.SpinBox,
  FMX.Filter.Effects, FMX.Colors, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  System.Rtti, FMX.Grid, FMX.Objects, FMX.NodeEditor.Node,
  FMX.NodeEditor.Node.Defaults, FMX.NodeEditor.JSON, FMX.NodeEditor.Types;

type
  { TMathExprNode — кастомная нода с exec-пинами и values }
  TMathExprNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: Single); override;
    constructor Create(ATitle: string; AX, AY: Single; AWidth: Integer = 200; AHeight: Integer = 200); override;
    procedure SetupPins; override;
  end;

  { TMultiplyNode }
  TMultiplyNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: Single); override;
    constructor Create(ATitle: string; AX, AY: Single; AWidth: Integer = 180; AHeight: Integer = 130); override;
    procedure SetupPins; override;
  end;

  { TStringNode — нода со строковым значением }
  TStringNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: Single); override;
    constructor Create(ATitle: string; AX, AY: Single; AWidth: Integer = 180; AHeight: Integer = 100); override;
    procedure SetupPins; override;
  end;

  { TBranchNode — нода с exec-пинами }
  TBranchNode = class(TCustomNode)
  public
    constructor Create(ATitle: string; AX, AY: Single); override;
    constructor Create(ATitle: string; AX, AY: Single; AWidth: Integer = 180; AHeight: Integer = 140); override;
    procedure SetupPins; override;
  end;

  TFormMain = class(TForm)
    LayoutRender: TLayout;
    Layout1: TLayout;
    MenuBar1: TMenuBar;
    MenuItemFile: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItemView: TMenuItem;
    MenuItemGraph: TMenuItem;
    MenuItemFileNew: TMenuItem;
    MenuItemFileLoad: TMenuItem;
    MenuItemFileSave: TMenuItem;
    MenuItemEditUndo: TMenuItem;
    MenuItemEditRedo: TMenuItem;
    MenuItemEditCopy: TMenuItem;
    MenuItemEditPaste: TMenuItem;
    MenuItemEditDup: TMenuItem;
    MenuItemEditDelete: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItemEditToFront: TMenuItem;
    MenuItemEditToBack: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItemViewFitSel: TMenuItem;
    MenuItemViewFrameAll: TMenuItem;
    MenuItemViewZoom1x1: TMenuItem;
    MenuItemEditDeselect: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItemSnapToGrid: TMenuItem;
    MenuItemAdd: TMenuItem;
    MenuItemGraphValidate: TMenuItem;
    MenuItemAddFloat: TMenuItem;
    MenuItemAddAdd: TMenuItem;
    MenuItemAddMul: TMenuItem;
    MenuItemAddMath: TMenuItem;
    MenuItemAddString: TMenuItem;
    MenuItemAddBranch: TMenuItem;
    MenuItemAddReroute: TMenuItem;
    MenuItemAddComment: TMenuItem;
    MenuItemAddDefault: TMenuItem;
    Layout2: TLayout;
    SpinBoxSize: TSpinBox;
    Layout3: TLayout;
    StyleBookWinUI3Light: TStyleBook;
    PanelInspector: TPanel;
    Layout4: TLayout;
    VertScrollBox1: TVertScrollBox;
    Layout5: TLayout;
    Layout6: TLayout;
    Label1: TLabel;
    EditNodeTitle: TEdit;
    Layout7: TLayout;
    LabelNodeType: TLabel;
    SpinBoxNodeX: TSpinBox;
    Label3: TLabel;
    SpinBoxNodeWidth: TSpinBox;
    Label4: TLabel;
    SpinBoxNodeY: TSpinBox;
    Label5: TLabel;
    SpinBoxNodeHeight: TSpinBox;
    Label6: TLabel;
    Layout8: TLayout;
    Label7: TLabel;
    Layout9: TLayout;
    ComboColorBoxNodeBodyColor: TComboColorBox;
    Label8: TLabel;
    ComboColorBoxNodeHeadColor: TComboColorBox;
    Label9: TLabel;
    CheckBoxNodeCollapsed: TCheckBox;
    Layout10: TLayout;
    Label10: TLabel;
    MemoNodeComment: TMemo;
    Layout11: TLayout;
    Label11: TLabel;
    StringGridNodePins: TStringGrid;
    Layout12: TLayout;
    Label12: TLabel;
    StringGridNodeValues: TStringGrid;
    Layout13: TLayout;
    ButtonNodeApply: TButton;
    ButtonNodeRevert: TButton;
    StringColumnVName: TStringColumn;
    StringColumnVKind: TStringColumn;
    StringColumnVValue: TStringColumn;
    StringColumnPName: TStringColumn;
    StringColumnPDir: TStringColumn;
    StringColumnPType: TStringColumn;
    StringColumnPKind: TStringColumn;
    StyleBookWinUI3: TStyleBook;
    StatusBar1: TStatusBar;
    LabelStat1: TLabel;
    LabelStat4: TLabel;
    LabelStat3: TLabel;
    LabelStat2: TLabel;
    LabelStat5: TLabel;
    Layout14: TLayout;
    TrackBarZoom: TTrackBar;
    Layout15: TLayout;
    Panel1: TPanel;
    SaveDialogJSON: TSaveDialog;
    OpenDialogJSON: TOpenDialog;
    MenuItemJSON: TMenuItem;
    MenuItemJSONLoad: TMenuItem;
    MenuItemJSONSave: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MenuItemFileLoadClick(Sender: TObject);
    procedure MenuItemFileNewClick(Sender: TObject);
    procedure MenuItemFileSaveClick(Sender: TObject);
    procedure MenuItemEditCopyClick(Sender: TObject);
    procedure MenuItemEditDeleteClick(Sender: TObject);
    procedure MenuItemEditDupClick(Sender: TObject);
    procedure MenuItemEditPasteClick(Sender: TObject);
    procedure MenuItemEditRedoClick(Sender: TObject);
    procedure MenuItemEditUndoClick(Sender: TObject);
    procedure MenuItemViewFitSelClick(Sender: TObject);
    procedure MenuItemViewFrameAllClick(Sender: TObject);
    procedure MenuItemViewZoom1x1Click(Sender: TObject);
    procedure MenuItemGraphValidateClick(Sender: TObject);
    procedure MenuItemEditDeselectClick(Sender: TObject);
    procedure MenuItemEditToFrontClick(Sender: TObject);
    procedure MenuItemEditToBackClick(Sender: TObject);
    procedure MenuItemAddFloatClick(Sender: TObject);
    procedure MenuItemAddAddClick(Sender: TObject);
    procedure MenuItemAddBranchClick(Sender: TObject);
    procedure MenuItemAddCommentClick(Sender: TObject);
    procedure MenuItemAddDefaultClick(Sender: TObject);
    procedure MenuItemAddMathClick(Sender: TObject);
    procedure MenuItemAddMulClick(Sender: TObject);
    procedure MenuItemAddRerouteClick(Sender: TObject);
    procedure MenuItemAddStringClick(Sender: TObject);
    procedure MenuItemSnapToGridClick(Sender: TObject);
    procedure SpinBoxSizeChange(Sender: TObject);
    procedure ButtonNodeApplyClick(Sender: TObject);
    procedure StringGridNodeValuesSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ButtonNodeRevertClick(Sender: TObject);
    procedure TrackBarZoomChange(Sender: TObject);
    procedure MenuItemJSONLoadClick(Sender: TObject);
    procedure MenuItemJSONSaveClick(Sender: TObject);
  private
    FEditor: TNodeEditor;
    FJsonNodeEditor: TJsonNodeEditor;

    FDidInitialFrame: Boolean;
    FNodeUpdating: Boolean;

    procedure BuildEditorArea;
    procedure InitDemoGraph;
    procedure RegisterCustomNodes;

    { Event handlers — editor }
    procedure OnSelectionChanged(Sender: TObject);
    procedure OnNodeChanged(Sender: TObject; ANode: TCustomNode);

    { Helpers }
    procedure UpdateStatus;
    function CenterWorldPos: TPointF;
    procedure AddNodeAtCenter(const ANodeType: string);
    procedure RefreshFromSelection;
    procedure ShowNoSelection;
    procedure ClearAllSections;
    procedure OnUpdatedStatus(Sender: TObject);
    procedure OnJsonNodeEditorChanged(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Math, System.JSON, FMX.NodeEditor.Node.Command;

{$R *.fmx}

{ TMathExprNode }

constructor TMathExprNode.Create(ATitle: string; AX, AY: Single; AWidth, AHeight: Integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);

  NodeType := 'math_expr';
  HeaderColor := $FF4080FF;
  BodyColor := $FFF0F8FF;
  // Добавляем значения разных типов — чтобы показать все kinds в инспекторе
  var V := AddValue('expression', nvkString);
  V.StringValue := 'A + B * C';

  V := AddValue('precision', nvkInteger);
  V.IntegerValue := 6;

  V := AddValue('scale', nvkFloat);
  V.FloatValue := 1.0;

  V := AddValue('enabled', nvkBoolean);
  V.BooleanValue := True;

  V := AddValue('meta', nvkJSON);
  V.JSONValue := '{"mode":"fast"}';
end;

constructor TMathExprNode.Create(ATitle: string; AX, AY: Single);
begin
  Create(ATitle, AX, AY, 200, 170);
end;

procedure TMathExprNode.SetupPins;
begin
  ClearPins;
  // Exec-пины
  AddInput('▶ Exec In', 'exec', pkExec, 35);
  AddOutput('▶ Exec Out', 'exec', pkExec, 35);
  // Data-пины
  AddInput('A', 'float', pkData, 75);
  AddInput('B', 'float', pkData, 105);
  AddInput('C', 'float', pkData, 135);
  AddOutput('Result', 'float', pkData, 90);
  // IsRequired demo
  GetInput(1).IsRequired := True;
  GetInput(2).IsRequired := True;
  GetInput(1).DefaultValue := '0.0';
  GetInput(1).Tooltip := 'First operand';
end;

{ TMultiplyNode }

constructor TMultiplyNode.Create(ATitle: string; AX, AY: Single; AWidth, AHeight: Integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'multiply_node';
  HeaderColor := $FF00A0FF;
end;

constructor TMultiplyNode.Create(ATitle: string; AX, AY: Single);
begin
  Create(ATitle, AX, AY, 180, 130);
end;

procedure TMultiplyNode.SetupPins;
begin
  ClearPins;
  AddInput('A', 'float', pkData, 45);
  AddInput('B', 'float', pkData, 75);
  AddOutput('Result', 'float', pkData, 60);
  GetInput(0).IsRequired := True;
  GetInput(1).IsRequired := True;
end;

{ TStringNode }

constructor TStringNode.Create(ATitle: string; AX, AY: Single; AWidth, AHeight: Integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'string_node';
  HeaderColor := $FF00C080;
  var V := AddValue('text', nvkString);
  V.StringValue := 'Hello, Node!';
end;

constructor TStringNode.Create(ATitle: string; AX, AY: Single);
begin
  Create(ATitle, AX, AY, 180, 100);
end;

procedure TStringNode.SetupPins;
begin
  ClearPins;
  AddOutput('Text', 'string', pkData, 45);
end;

{ TBranchNode }

constructor TBranchNode.Create(ATitle: string; AX, AY: Single; AWidth, AHeight: Integer);
begin
  inherited Create(ATitle, AX, AY, AWidth, AHeight);
  NodeType := 'branch_node';
  HeaderColor := $FFC04000;
end;

constructor TBranchNode.Create(ATitle: string; AX, AY: Single);
begin
  Create(ATitle, AX, AY, 180, 140);
end;

procedure TBranchNode.SetupPins;
begin
  ClearPins;
  AddInput('▶ Exec', 'exec', pkExec, 35);
  AddInput('Condition', 'boolean', pkData, 75);
  AddOutput('▶ True', 'exec', pkExec, 55);
  AddOutput('▶ False', 'exec', pkExec, 90);
  GetInput(1).IsRequired := True;
end;

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
begin
  StringGridNodePins.AniCalculations.Animation := True;
  StringGridNodeValues.AniCalculations.Animation := True;

  BuildEditorArea;
  RegisterCustomNodes;
  InitDemoGraph;
  UpdateStatus;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  UpdateStatus;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  if not FDidInitialFrame then
  begin
    FDidInitialFrame := True;
    FEditor.FrameAll;
  end;
end;

procedure TFormMain.ButtonNodeApplyClick(Sender: TObject);
var
  OldJSON, NewJSON: string;
begin
  if FNodeUpdating then
    Exit;
  if (FEditor = nil) or (FEditor.SelectedNodeCount <> 1) then
    Exit;

  var N := FEditor.GetSelectedNode(0);
  if N = nil then
    Exit;

  var OldObj := TJSONObject.Create;
  try
    N.SaveToJSON(OldObj);
    OldJSON := OldObj.ToJSON;
  finally
    OldObj.Free;
  end;

  N.Title := EditNodeTitle.Text;
  N.X := Round(SpinBoxNodeX.Value);
  N.Y := Round(SpinBoxNodeY.Value);
  N.Width := Round(SpinBoxNodeWidth.Value);
  N.Height := Round(SpinBoxNodeHeight.Value);

  N.HeaderColor := ComboColorBoxNodeHeadColor.Color;
  N.BodyColor := ComboColorBoxNodeBodyColor.Color;
  N.Collapsed := CheckBoxNodeCollapsed.IsChecked;

  N.CommentText := MemoNodeComment.Text;

  for var i := 0 to N.ValueCount - 1 do
  begin
    if i >= StringGridNodeValues.RowCount then
      Continue;
    var V := N.GetValue(i);
    if V = nil then
      Continue;
    var VStr := StringGridNodeValues.Cells[2, i].Trim;

    case V.Kind of
      nvkFloat:
        V.FloatValue := StrToFloatDef(VStr, V.FloatValue);
      nvkInteger:
        V.IntegerValue := StrToInt64Def(VStr, V.IntegerValue);
      nvkString:
        V.StringValue := VStr;
      nvkBoolean:
        V.BooleanValue := SameText(VStr, 'true') or (VStr = '1');
      nvkJSON:
        V.JSONValue := VStr;
    end;
  end;
  N.AutoLayoutPins;

  var NewObj := TJSONObject.Create;
  try
    N.SaveToJSON(NewObj);
    NewJSON := NewObj.ToJSON;
  finally
    NewObj.Free;
  end;

  FEditor.ExecuteNodePropertyChange(N, OldJSON, NewJSON);

  FEditor.Graph.DoGraphChanged;
  FEditor.Repaint;

  RefreshFromSelection;
end;

procedure TFormMain.ButtonNodeRevertClick(Sender: TObject);
begin
  RefreshFromSelection;
end;

procedure TFormMain.BuildEditorArea;
begin
  FEditor := TNodeEditor.Create(LayoutRender);
  FEditor.Parent := LayoutRender;
  FEditor.Align := TAlignLayout.Client;
  FEditor.SnapToGrid := False;
  FEditor.GridSize := 40;

  FEditor.OnSelectionChanged := OnSelectionChanged;
  FEditor.OnNodeChanged := OnNodeChanged;
  FEditor.OnUpdatedStatus := OnUpdatedStatus;

  FJsonNodeEditor := TJsonNodeEditor.Create(Self);
  FJsonNodeEditor.NodeEditor := FEditor;
  FJsonNodeEditor.OnChanged := OnJsonNodeEditorChanged;
end;

procedure TFormMain.OnJsonNodeEditorChanged(Sender: TObject);
begin
  RefreshFromSelection;
end;

procedure TFormMain.RegisterCustomNodes;
begin
  FEditor.Graph.Registry.RegisterNodeEx(
    'multiply_node', 'Multiply', 'Math',
    'Multiplies two float values.', 'multiply,mul,math,float',
    TMultiplyNode, $FF00A0FF);

  FEditor.Graph.Registry.RegisterNodeEx(
    'math_expr', 'Math Expression', 'Math',
    'Evaluates a math expression A+B*C with exec pins and multiple value types.',
    'math,expr,expression,exec',
    TMathExprNode, $FF4080FF);

  FEditor.Graph.Registry.RegisterNodeEx(
    'string_node', 'String Value', 'Values',
    'Constant string value.', 'string,text,value',
    TStringNode, $FF00C080);

  FEditor.Graph.Registry.RegisterNodeEx(
    'branch_node', 'Branch', 'Flow',
    'Conditional exec branch (if/else).', 'branch,if,else,exec,flow',
    TBranchNode, $FFC04000);
end;

procedure TFormMain.SpinBoxSizeChange(Sender: TObject);
begin
  var V := Trunc(SpinBoxSize.Value);
  if V > 4 then
  begin
    FEditor.GridSize := V;
    UpdateStatus;
  end;
end;

procedure TFormMain.StringGridNodeValuesSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if ACol = 2 then
    StringGridNodeValues.Options := StringGridNodeValues.Options + [TGridOption.Editing]
  else
    StringGridNodeValues.Options := StringGridNodeValues.Options - [TGridOption.Editing];
  CanSelect := True;
end;

procedure TFormMain.TrackBarZoomChange(Sender: TObject);
begin
  if FNodeUpdating then
    Exit;
  FEditor.SetZoom(TrackBarZoom.Value / 100, FEditor.LocalRect.CenterPoint.Round);
end;

procedure TFormMain.InitDemoGraph;
var
  NFloat1, NFloat2, NFloat3: TCustomNode;
  NAdd, NMul, NMath: TCustomNode;
  NStr: TCustomNode;
  NBranch: TCustomNode;
  NReroute: TCustomNode;
  NComment1, NComment2: TCustomNode;
  NDefault: TCustomNode;
  V: TNodeValue;
begin
  // ── Float sources ──────────────────────────────────────────────
  NFloat1 := FEditor.Graph.Registry.CreateNode('float', 40, 120);
  NFloat1.Title := 'Value A';
  TFloatNode(NFloat1).SetupPins;
  V := NFloat1.FindValue('value');
  if V <> nil then
    V.FloatValue := 3.14;
  FEditor.AddNode(NFloat1);

  NFloat2 := FEditor.Graph.Registry.CreateNode('float', 40, 240);
  NFloat2.Title := 'Value B';
  TFloatNode(NFloat2).SetupPins;
  V := NFloat2.FindValue('value');
  if V <> nil then
    V.FloatValue := 2.71;
  FEditor.AddNode(NFloat2);

  NFloat3 := FEditor.Graph.Registry.CreateNode('float', 40, 360);
  NFloat3.Title := 'Value C';
  TFloatNode(NFloat3).SetupPins;
  V := NFloat3.FindValue('value');
  if V <> nil then
    V.FloatValue := 10.0;
  FEditor.AddNode(NFloat3);

  // ── Add node ───────────────────────────────────────────────────
  NAdd := FEditor.Graph.Registry.CreateNode('add', 280, 160);
  NAdd.Title := 'A + B';
  FEditor.AddNode(NAdd);

  // ── Multiply node (custom) ─────────────────────────────────────
  NMul := FEditor.Graph.Registry.CreateNode('multiply_node', 280, 310);
  NMul.Title := '(A+B) × C';
  FEditor.AddNode(NMul);

  // ── Math Expression (exec + values) ───────────────────────────
  NMath := FEditor.Graph.Registry.CreateNode('math_expr', 520, 180);
  NMath.Title := 'Math Expr';
  FEditor.AddNode(NMath);

  // ── String node ────────────────────────────────────────────────
  NStr := FEditor.Graph.Registry.CreateNode('string_node', 520, 420);
  NStr.Title := 'Label';
  FEditor.AddNode(NStr);

  // ── Branch node (exec flow) ───────────────────────────────────
  NBranch := FEditor.Graph.Registry.CreateNode('branch_node', 760, 160);
  NBranch.Title := 'If Enabled?';
  FEditor.AddNode(NBranch);

  // ── Reroute ────────────────────────────────────────────────────
  NReroute := FEditor.Graph.Registry.CreateNode('reroute', 430, 370);
  FEditor.AddNode(NReroute);

  // ── Default node ───────────────────────────────────────────────
  NDefault := FEditor.Graph.Registry.CreateNode('default', 760, 360);
  NDefault.Title := 'Default Node';
  FEditor.AddNode(NDefault);

  // ── Comment / Frame 1 (Math block) ────────────────────────────
  NComment1 := FEditor.Graph.Registry.CreateNode('comment', 20, 80);
  NComment1.Title := 'Math Block';
  NComment1.Width := 460;
  NComment1.Height := 360;
  NComment1.CommentText := 'Arithmetic: A+B then ×C';
  NComment1.HeaderColor := $FF60A060;
  NComment1.BodyColor := $FFEEFFEE;
  FEditor.AddNode(NComment1);

  // ── Comment / Frame 2 (Flow block) ────────────────────────────
  NComment2 := FEditor.Graph.Registry.CreateNode('comment', 500, 120);
  NComment2.Title := 'Flow Block';
  NComment2.Width := 320;
  NComment2.Height := 200;
  NComment2.CommentText := 'Exec pipeline: Expr → Branch';
  NComment2.HeaderColor := $FF804000;
  NComment2.BodyColor := $FFFFF8E8;
  FEditor.AddNode(NComment2);

  // ── Links: Float → Add ─────────────────────────────────────────
  if FEditor.Graph.CanConnect(NFloat1.GetOutput(0), NAdd.GetInput(0)) then
    FEditor.Graph.AddLink(TNodeLink.Create(NFloat1.GetOutput(0), NAdd.GetInput(0)));

  if FEditor.Graph.CanConnect(NFloat2.GetOutput(0), NAdd.GetInput(1)) then
    FEditor.Graph.AddLink(TNodeLink.Create(NFloat2.GetOutput(0), NAdd.GetInput(1)));

  // ── Links: Add+Float3 → Mul ────────────────────────────────────
  if FEditor.Graph.CanConnect(NAdd.GetOutput(0), NMul.GetInput(0)) then
    FEditor.Graph.AddLink(TNodeLink.Create(NAdd.GetOutput(0), NMul.GetInput(0)));

  // Float3 → Reroute → Mul.B
  if (NReroute.InputCount > 0) and (NReroute.OutputCount > 0) then
  begin
    if FEditor.Graph.CanConnect(NFloat3.GetOutput(0), NReroute.GetInput(0)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NFloat3.GetOutput(0), NReroute.GetInput(0)));

    if FEditor.Graph.CanConnect(NReroute.GetOutput(0), NMul.GetInput(1)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NReroute.GetOutput(0), NMul.GetInput(1)));
  end;

  // ── Links: Mul → Math A, Float1 → Math B, Float2 → Math C ─────
  if NMath.InputCount >= 4 then // exec + A + B + C
  begin
    if FEditor.Graph.CanConnect(NMul.GetOutput(0), NMath.GetInput(1)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NMul.GetOutput(0), NMath.GetInput(1)));
    if FEditor.Graph.CanConnect(NFloat1.GetOutput(0), NMath.GetInput(2)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NFloat1.GetOutput(0), NMath.GetInput(2)));
    if FEditor.Graph.CanConnect(NFloat2.GetOutput(0), NMath.GetInput(3)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NFloat2.GetOutput(0), NMath.GetInput(3)));
  end;

  // ── Links: Math Exec Out → Branch Exec In ──────────────────────
  if (NMath.OutputCount >= 1) and (NBranch.InputCount >= 1) then
    if FEditor.Graph.CanConnect(NMath.GetOutput(0), NBranch.GetInput(0)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NMath.GetOutput(0), NBranch.GetInput(0)));

  // ── Links: Branch True → Default In ───────────────────────────
  if (NBranch.OutputCount >= 1) and (NDefault.InputCount >= 1) then
    if FEditor.Graph.CanConnect(NBranch.GetOutput(0), NDefault.GetInput(0)) then
      FEditor.Graph.AddLink(TNodeLink.Create(NBranch.GetOutput(0), NDefault.GetInput(0)));

  // ── Select Math node — демонстрируем все его values в инспекторе
  FEditor.SelectNode(NMath, False);
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemAddAddClick(Sender: TObject);
begin
  AddNodeAtCenter('add');
end;

procedure TFormMain.MenuItemAddBranchClick(Sender: TObject);
begin
  AddNodeAtCenter('branch_node');
end;

procedure TFormMain.MenuItemAddCommentClick(Sender: TObject);
begin
  AddNodeAtCenter('comment');
end;

procedure TFormMain.MenuItemAddDefaultClick(Sender: TObject);
begin
  AddNodeAtCenter('default');
end;

procedure TFormMain.MenuItemAddFloatClick(Sender: TObject);
begin
  AddNodeAtCenter('float');
end;

procedure TFormMain.MenuItemAddMathClick(Sender: TObject);
begin
  AddNodeAtCenter('math_expr');
end;

procedure TFormMain.MenuItemAddMulClick(Sender: TObject);
begin
  AddNodeAtCenter('multiply_node');
end;

procedure TFormMain.MenuItemAddRerouteClick(Sender: TObject);
begin
  AddNodeAtCenter('reroute');
end;

procedure TFormMain.MenuItemAddStringClick(Sender: TObject);
begin
  AddNodeAtCenter('string_node');
end;

procedure TFormMain.MenuItemEditCopyClick(Sender: TObject);
begin
  FEditor.CopySelectionToClipboard;
  LabelStat5.Text := 'Copied ' + IntToStr(FEditor.SelectedNodeCount) + ' node(s)';
end;

procedure TFormMain.MenuItemEditDeleteClick(Sender: TObject);
begin
  FEditor.DeleteSelection;
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemEditDeselectClick(Sender: TObject);
begin
  FEditor.ClearSelection;
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemEditDupClick(Sender: TObject);
begin
  FEditor.DuplicateSelection;
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemEditPasteClick(Sender: TObject);
begin
  FEditor.PasteFromClipboard;
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemEditRedoClick(Sender: TObject);
begin
  FEditor.Redo;
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemEditToBackClick(Sender: TObject);
begin
  if FEditor.SelectedNodeCount = 0 then
    Exit;
  for var i := 0 to FEditor.SelectedNodeCount - 1 do
    FEditor.Graph.SendNodeToBack(FEditor.GetSelectedNode(i));
  FEditor.Repaint;
  LabelStat5.Text := 'Sent to back';
end;

procedure TFormMain.MenuItemEditToFrontClick(Sender: TObject);
begin
  if FEditor.SelectedNodeCount = 0 then
    Exit;
  for var i := 0 to FEditor.SelectedNodeCount - 1 do
    FEditor.Graph.BringNodeToFront(FEditor.GetSelectedNode(i));
  FEditor.Repaint;
  LabelStat5.Text := 'Brought to front';
end;

procedure TFormMain.MenuItemEditUndoClick(Sender: TObject);
begin
  FEditor.Undo;
  RefreshFromSelection;
end;

procedure TFormMain.MenuItemFileLoadClick(Sender: TObject);
begin
  if OpenDialogJSON.Execute then
  begin
    FEditor.LoadFromFile(OpenDialogJSON.FileName);
    RefreshFromSelection;
    FEditor.FrameAll;
    LabelStat5.Text := 'Loaded: ' + ExtractFileName(OpenDialogJSON.FileName);
  end;
end;

procedure TFormMain.MenuItemFileNewClick(Sender: TObject);
begin
  //if MessageDlg('Clear current graph?',
  //  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FEditor.Clear;
    RefreshFromSelection;
  end;
end;

procedure TFormMain.MenuItemFileSaveClick(Sender: TObject);
begin
  if SaveDialogJSON.Execute then
  begin
    FEditor.SaveToFile(SaveDialogJSON.FileName);
    LabelStat5.Text := 'Saved: ' + ExtractFileName(SaveDialogJSON.FileName);
  end;
end;

procedure TFormMain.MenuItemGraphValidateClick(Sender: TObject);
begin
  var Msgs := TStringList.Create;
  try
    if FEditor.ValidateGraphToStrings(Msgs) then
      ShowMessage('✔ Graph is valid.' + #13#10 + #13#10 + Msgs.Text)
    else
      ShowMessage(Msgs.Text);
  finally
    Msgs.Free;
  end;
end;

procedure TFormMain.MenuItemJSONLoadClick(Sender: TObject);
begin
  if OpenDialogJSON.Execute then
    FJsonNodeEditor.LoadFromFile(OpenDialogJSON.FileName);
end;

procedure TFormMain.MenuItemJSONSaveClick(Sender: TObject);
begin
  if SaveDialogJSON.Execute then
    FJsonNodeEditor.SaveToFile(SaveDialogJSON.FileName);
end;

procedure TFormMain.MenuItemSnapToGridClick(Sender: TObject);
begin
  FEditor.SnapToGrid := MenuItemSnapToGrid.IsChecked;
  UpdateStatus;
end;

procedure TFormMain.MenuItemViewFitSelClick(Sender: TObject);
begin
  if FEditor.SelectedNodeCount > 0 then
    FEditor.FitToSelection
  else
    FEditor.FrameAll;
  UpdateStatus;
end;

procedure TFormMain.MenuItemViewFrameAllClick(Sender: TObject);
begin
  FEditor.FrameAll;
  UpdateStatus;
end;

procedure TFormMain.MenuItemViewZoom1x1Click(Sender: TObject);
begin
  // Сбрасываем zoom к 1:1, центрируем на центр экрана
  FEditor.FrameAll;
  UpdateStatus;
end;

function TFormMain.CenterWorldPos: TPointF;
begin
  Result.X := (Round(FEditor.Width) div 2 - 90);
  Result.Y := (Round(FEditor.Height) div 2 - 60);
  // грубое приближение без доступа к ScreenToWorld — достаточно для демки
  Result.X := (Result.X - 0) / FEditor.Zoom;
  Result.Y := (Result.Y - 0) / FEditor.Zoom;
end;

procedure TFormMain.AddNodeAtCenter(const ANodeType: string);
begin
  var W := CenterWorldPos;
  var N := FEditor.Graph.Registry.CreateNode(ANodeType,
    W.X + Random(60) - 30,
    W.Y + Random(60) - 30);
  FEditor.AddNode(N);
  FEditor.SelectNode(N, False);
  RefreshFromSelection;
end;

procedure TFormMain.OnSelectionChanged(Sender: TObject);
begin
  RefreshFromSelection;
end;

procedure TFormMain.ShowNoSelection;
begin
  FNodeUpdating := True;
  try
    ClearAllSections;
    LabelNodeType.Text := 'Info (no selection)';
    ButtonNodeApply.Enabled := False;
    PanelInspector.Enabled := False;
    ButtonNodeRevert.Enabled := False;
  finally
    FNodeUpdating := False;
  end;
end;

procedure TFormMain.ClearAllSections;
begin
  FNodeUpdating := True;
  try
    LabelNodeType.Text := 'Info';
    EditNodeTitle.Text := '';
    SpinBoxNodeX.Value := 0;
    SpinBoxNodeY.Value := 0;
    SpinBoxNodeWidth.Value := 0;
    SpinBoxNodeHeight.Value := 0;
    ComboColorBoxNodeBodyColor.Color := TAlphaColors.Null;
    ComboColorBoxNodeHeadColor.Color := TAlphaColors.Null;
    CheckBoxNodeCollapsed.IsChecked := False;
    MemoNodeComment.Text := '';
    StringGridNodePins.RowCount := 0;
    StringGridNodeValues.RowCount := 0;
  finally
    FNodeUpdating := False;
  end;
end;

procedure TFormMain.RefreshFromSelection;
var
  N: TCustomNode;
  i: integer;
  P: TNodePin;
  V: TNodeValue;
  VStr: string;
begin
  if (FEditor = nil) or (FEditor.SelectedNodeCount <> 1) then
  begin
    ShowNoSelection;
    Exit;
  end;

  N := FEditor.GetSelectedNode(0);
  if N = nil then
  begin
    ShowNoSelection;
    Exit;
  end;

  FNodeUpdating := True;
  try
    ClearAllSections;

    // --- Info ---
    LabelNodeType.Text := 'Info (' + N.NodeType + ')';

    // --- Basic ---
    EditNodeTitle.Text := N.Title;
    SpinBoxNodeX.Value := N.X;
    SpinBoxNodeY.Value := N.Y;
    SpinBoxNodeWidth.Value := N.Width;
    SpinBoxNodeHeight.Value := N.Height;

    // --- Visual ---
    ComboColorBoxNodeHeadColor.Color := N.HeaderColor;
    ComboColorBoxNodeBodyColor.Color := N.BodyColor;
    CheckBoxNodeCollapsed.IsChecked := N.Collapsed;

    // --- Comment ---
    MemoNodeComment.Text := N.CommentText;

    // --- Pins ---
    StringGridNodePins.RowCount := N.InputCount + N.OutputCount;
    for i := 0 to N.InputCount - 1 do
    begin
      P := N.GetInput(i);
      if P = nil then
        Continue;
      StringGridNodePins.Cells[0, i] := P.EffectiveDisplayName;
      StringGridNodePins.Cells[1, i] := 'In';
      StringGridNodePins.Cells[2, i] :=
        if P.PinType <> nil then P.PinType.TypeId else P.DataType;
      StringGridNodePins.Cells[3, i] :=
        if P.Kind = pkExec then 'exec' else 'data';
    end;
    for i := 0 to N.OutputCount - 1 do
    begin
      P := N.GetOutput(i);
      if P = nil then
        Continue;
      StringGridNodePins.Cells[0, N.InputCount + i] := P.EffectiveDisplayName;
      StringGridNodePins.Cells[1, N.InputCount + i] := 'Out';
      StringGridNodePins.Cells[2, N.InputCount + i] :=
        if P.PinType <> nil then P.PinType.TypeId else P.DataType;
      StringGridNodePins.Cells[3, N.InputCount + i] :=
        if P.Kind = pkExec then 'exec' else 'data';
    end;

    // --- Values ---
    if N.ValueCount > 0 then
    begin
      StringGridNodeValues.RowCount := N.ValueCount;
      for i := 0 to N.ValueCount - 1 do
      begin
        V := N.GetValue(i);
        if V = nil then
          Continue;
        StringGridNodeValues.Cells[0, i] := V.Name;
        StringGridNodeValues.Cells[1, i] := NodeValueKindToStr(V.Kind);

        case V.Kind of
          nvkFloat:
            VStr := FormatFloat('0.######', V.FloatValue);
          nvkInteger:
            VStr := IntToStr(V.IntegerValue);
          nvkString:
            VStr := V.StringValue;
          nvkBoolean:
            VStr := if V.BooleanValue then 'true' else 'false';
          nvkJSON:
            VStr := V.JSONValue;
        else
          VStr := '';
        end;

        StringGridNodeValues.Cells[2, i] := VStr;
      end;
    end
    else
      StringGridNodeValues.RowCount := 0;

    PanelInspector.Enabled := True;
    ButtonNodeApply.Enabled := True;
    ButtonNodeRevert.Enabled := True;
  finally
    FNodeUpdating := False;
  end;
  UpdateStatus;
end;

procedure TFormMain.OnNodeChanged(Sender: TObject; ANode: TCustomNode);
begin
  RefreshFromSelection;
end;

procedure TFormMain.OnUpdatedStatus(Sender: TObject);
begin
  UpdateStatus;
end;

procedure TFormMain.UpdateStatus;
var
  SelStr: string;
begin
  if FEditor.SelectedNodeCount > 1 then
    SelStr := 'Selected: ' + IntToStr(FEditor.SelectedNodeCount) + ' nodes'
  else if FEditor.SelectedNodeCount = 1 then
    SelStr := 'Selected: ' + FEditor.GetSelectedNode(0).Title
  else if FEditor.SelectedLinkCount > 0 then
    SelStr := 'Selected: 1 link'
  else
    SelStr := 'No selection';

  LabelStat1.Text := SelStr;
  LabelStat2.Text :=
    'Nodes: ' + IntToStr(FEditor.Graph.Nodes.Count) +
    '  Links: ' + IntToStr(FEditor.Graph.Links.Count);
  LabelStat3.Text := Format('Zoom: %.0f%%', [FEditor.Zoom * 100]);
  LabelStat4.Text :=
    'Snap: ' + (if FEditor.SnapToGrid then 'ON' else 'OFF') +
    '  Grid: ' + IntToStr(FEditor.GridSize);
  FNodeUpdating := True;
  TrackBarZoom.Value := FEditor.Zoom * 100;
  FNodeUpdating := False;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

