unit NodeEditor.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.NodeEditor, FMX.Edit,
  FMX.Grid.Style, FMX.Layouts, FMX.Menus, FMX.EditBox, FMX.SpinBox,
  FMX.Filter.Effects, FMX.Colors, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  System.Rtti, FMX.Grid, FMX.Objects, FMX.NodeEditor.Node,
  FMX.NodeEditor.Node.Defaults, FMX.NodeEditor.JSON, FMX.NodeEditor.Types,
  FMX.Ani, FMX.ExtCtrls, FMX.TabControl, FMX.ComboTrackBar, FMX.ListBox,
  FMX.ComboEdit, WinUI3.Form;

type
  { TMathExprNode — кастомная нода с exec-пинами и values }
  TMathExprNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  { TMultiplyNode }
  TMultiplyNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  { TStringNode — нода со строковым значением }
  TStringNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  { TBranchNode — нода с exec-пинами }
  TBranchNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  TPrintNode = class(TCustomNode)
  public
    constructor Create; override;
    procedure SetupPins; override;
  end;

  TTrackBar = class(FMX.StdCtrls.TTrackBar)
  protected
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
  end;

  TFormMain = class(TWinUIForm)
    LayoutRender: TLayout;
    LayoutLeft: TLayout;
    StyleBookWinUI3Light: TStyleBook;
    PanelInspector: TPanel;
    VertScrollBox1: TVertScrollBox;
    SpinBoxNodeWidth: TSpinBox;
    Label4: TLabel;
    SpinBoxNodeHeight: TSpinBox;
    Label6: TLabel;
    Layout13: TLayout;
    ButtonNodeApply: TButton;
    ButtonNodeRevert: TButton;
    StyleBookWinUI3: TStyleBook;
    StatusBar: TStatusBar;
    LabelStat1: TLabel;
    LabelStat4: TLabel;
    LabelStat3: TLabel;
    LabelStat2: TLabel;
    LabelStat5: TLabel;
    Layout14: TLayout;
    TrackBarZoom: TTrackBar;
    LayoutClient: TLayout;
    Panel1: TPanel;
    SaveDialogJSON: TSaveDialog;
    OpenDialogJSON: TOpenDialog;
    LayoutRight: TLayout;
    Panel2: TPanel;
    VertScrollBoxRight: TVertScrollBox;
    LayoutNavigator: TLayout;
    RectangleNav: TRectangle;
    Layout15: TLayout;
    PathLabel1: TPathLabel;
    Label2: TLabel;
    Button1: TButton;
    Panel3: TPanel;
    LayoutLayers: TLayout;
    Layout16: TLayout;
    PathLabel2: TPathLabel;
    Label13: TLabel;
    Button2: TButton;
    Panel4: TPanel;
    Layout3: TLayout;
    Layout17: TLayout;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    PathLabel3: TPathLabel;
    PathLabel4: TPathLabel;
    PathLabel5: TPathLabel;
    PathLabel6: TPathLabel;
    Panel6: TPanel;
    Layout11: TLayout;
    Layout12: TLayout;
    PathLabel8: TPathLabel;
    Label11: TLabel;
    Button5: TButton;
    Panel7: TPanel;
    Layout18: TLayout;
    SpinBoxNodeX: TSpinBox;
    Label3: TLabel;
    SpinBoxNodeY: TSpinBox;
    Label5: TLabel;
    Layout19: TLayout;
    Layout5: TLayout;
    Layout6: TLayout;
    PathLabel9: TPathLabel;
    LabelNodeType: TLabel;
    Button6: TButton;
    Panel8: TPanel;
    Layout4: TLayout;
    EditNodeTitle: TEdit;
    CheckBoxNodeCollapsed: TCheckBox;
    ComboColorBoxNodeHeadColor: TComboColorBox;
    Label9: TLabel;
    Layout7: TLayout;
    Layout8: TLayout;
    PathLabel10: TPathLabel;
    Label1: TLabel;
    Button7: TButton;
    Panel9: TPanel;
    CheckBoxSnapToGrid: TCheckBox;
    CheckBoxSnapToNodes: TCheckBox;
    SpinBoxSize: TSpinBox;
    Label14: TLabel;
    CheckBoxShowFrameTime: TCheckBox;
    CheckBoxShowGrid: TCheckBox;
    CheckBoxShowAxes: TCheckBox;
    CheckBoxShowSnapGuides: TCheckBox;
    CheckBoxLockedAll: TCheckBox;
    LayoutNodeData: TLayout;
    Layout20: TLayout;
    PathLabel11: TPathLabel;
    Label7: TLabel;
    Button8: TButton;
    Panel10: TPanel;
    StringGridNodeValues: TStringGrid;
    StringColumnVName: TStringColumn;
    StringColumnVKind: TStringColumn;
    StringColumnVValue: TStringColumn;
    PopupMenuZoom: TPopupMenu;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MemoNodeComment: TMemo;
    PathLabel12: TPathLabel;
    PathLabel13: TPathLabel;
    PathLabel14: TPathLabel;
    PathLabel15: TPathLabel;
    PathLabel16: TPathLabel;
    PathLabel17: TPathLabel;
    PathLabel18: TPathLabel;
    PathLabel19: TPathLabel;
    LayoutNodeLibrary: TLayout;
    Panel14: TPanel;
    Layout28: TLayout;
    Layout23: TLayout;
    Layout24: TLayout;
    PathLabel21: TPathLabel;
    Label17: TLabel;
    ButtonHideNodeLibrary: TButton;
    Panel16: TPanel;
    Layout9: TLayout;
    Label8: TLabel;
    Label10: TLabel;
    PathLabel20: TPathLabel;
    ListBoxRegistry: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    ListBoxItem1: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxGroupHeader2: TListBoxGroupHeader;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxGroupHeader3: TListBoxGroupHeader;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    LayoutHead: TLayout;
    LayoutCaption: TLayout;
    ButtonSettings: TButton;
    ButtonWinMin: TButton;
    ButtonWinMax: TButton;
    ButtonWinClose: TButton;
    LabelTitle: TLabel;
    Layout42: TLayout;
    ImageIcon: TImage;
    MenuBar1: TMenuBar;
    MenuItemFile: TMenuItem;
    MenuItemFileNew: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItemFileSave: TMenuItem;
    MenuItemFileLoad: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItemFileExit: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItemEditUndo: TMenuItem;
    MenuItemEditRedo: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItemEditCopy: TMenuItem;
    MenuItemEditPaste: TMenuItem;
    MenuItemEditDelete: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItemEditDup: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItemEditToFront: TMenuItem;
    MenuItemEditToBack: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItemEditDeselect: TMenuItem;
    MenuItemView: TMenuItem;
    MenuItemViewFitSel: TMenuItem;
    MenuItemViewFrameAll: TMenuItem;
    MenuItemViewZoom1x1: TMenuItem;
    MenuItemGraph: TMenuItem;
    MenuItemGraphValidate: TMenuItem;
    MenuItemAdd: TMenuItem;
    MenuItemAddFloat: TMenuItem;
    MenuItemAddAdd: TMenuItem;
    MenuItemAddMul: TMenuItem;
    MenuItemAddMath: TMenuItem;
    MenuItemAddString: TMenuItem;
    MenuItemAddBranch: TMenuItem;
    MenuItemAddReroute: TMenuItem;
    MenuItemAddComment: TMenuItem;
    MenuItemAddDefault: TMenuItem;
    MenuItemJSON: TMenuItem;
    MenuItemJSONLoad: TMenuItem;
    MenuItemJSONSave: TMenuItem;
    Layout2: TLayout;
    Panel5: TPanel;
    PathLabel7: TPathLabel;
    ButtonZoomIn2: TButton;
    ButtonZoomOut2: TButton;
    ButtonZoom: TButton;
    PopupZoom: TPopup;
    Panel11: TPanel;
    ButtonZoomIn: TButton;
    ButtonZoomToFit: TButton;
    ButtonZoomOut: TButton;
    ButtonZoomTo200: TButton;
    ButtonZoomTo100: TButton;
    ButtonZoomTo50: TButton;
    Panel12: TPanel;
    Panel13: TPanel;
    SizeGrip1: TSizeGrip;
    PopupTheme: TPopup;
    Panel61: TPanel;
    PopupBoxStyle: TPopupBox;
    ComboColorBoxAccentColor: TComboColorBox;
    ComboColorBoxThemeGradient1: TComboColorBox;
    ComboColorBoxThemeGradient2: TComboColorBox;
    Label122: TLabel;
    Label123: TLabel;
    Layout10: TLayout;
    Button309: TButton;
    Label124: TLabel;
    CheckBoxCustomTitle: TCheckBox;
    CheckBoxCustomAccent: TCheckBox;
    MenuItemNodeLibrary: TMenuItem;
    MenuItem16: TMenuItem;
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
    procedure SpinBoxSizeChange(Sender: TObject);
    procedure ButtonNodeApplyClick(Sender: TObject);
    procedure StringGridNodeValuesSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ButtonNodeRevertClick(Sender: TObject);
    procedure TrackBarZoomChange(Sender: TObject);
    procedure MenuItemJSONLoadClick(Sender: TObject);
    procedure MenuItemJSONSaveClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBoxSnapToGridChange(Sender: TObject);
    procedure MenuItemFileExitClick(Sender: TObject);
    procedure ButtonZoomClick(Sender: TObject);
    procedure ButtonZoomInClick(Sender: TObject);
    procedure ButtonZoomOutClick(Sender: TObject);
    procedure ButtonZoomToFitClick(Sender: TObject);
    procedure ButtonZoomTo50Click(Sender: TObject);
    procedure ButtonZoomTo100Click(Sender: TObject);
    procedure ButtonZoomTo200Click(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
    procedure CheckBoxCustomAccentChange(Sender: TObject);
    procedure CheckBoxCustomTitleChange(Sender: TObject);
    procedure ComboColorBoxAccentColorChange(Sender: TObject);
    procedure ComboColorBoxThemeGradient1Change(Sender: TObject);
    procedure PopupBoxStyleChange(Sender: TObject);
    procedure Button309Click(Sender: TObject);
    procedure ListBoxRegistryDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure ButtonHideNodeLibraryClick(Sender: TObject);
    procedure MenuItemNodeLibraryClick(Sender: TObject);
  protected
    procedure PaintRects(const UpdateRects: array of TRectF); override;
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
    procedure FOnEditorPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure UpdateNodeRegistry;
    procedure FOnItemOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
  protected
    OverTheme: integer;
    OverAccentColor: TAlphaColor;
    procedure DoOnSettingChange; override;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Math, System.JSON, FMX.NodeEditor.Node.Command, System.Messaging,
  WinUI3.Style;

{$R *.fmx}

{ TFormMain }

procedure TFormMain.FormCreate(Sender: TObject);
begin
  OverAccentColor := SystemAccentColor;
  BeginUpdate;
  ComboColorBoxAccentColor.Color := OverAccentColor;
  EndUpdate;
  OverTheme := 0;
  SetSystemWindowControls(ButtonWinClose, ButtonWinMax, ButtonWinMin);
  CaptionControls := [LayoutCaption, LayoutHead, MenuBar1];
  OffsetControls := [LayoutHead];
  TitleControls := [LabelTitle];
  IconControl := ImageIcon;
  HideTitleBar := True;
  //
  StringGridNodeValues.AniCalculations.Animation := True;
  //
  ClearAllSections;

  BuildEditorArea;
  RegisterCustomNodes;
  InitDemoGraph;
  UpdateNodeRegistry;

  UpdateStatus;
end;

procedure TFormMain.FOnItemOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.None;
end;

procedure TFormMain.UpdateNodeRegistry;
begin
  ListBoxRegistry.BeginUpdate;
  try
    ListBoxRegistry.Clear;
    ListBoxRegistry.HitTest := False;
    FEditor.Graph.Registry.SortByCategory;
    var CurCategory := '';
    for var Item in FEditor.Graph.Registry do
    begin
      if CurCategory <> Item.Category then
      begin
        var Header := TListBoxGroupHeader.Create(ListBoxRegistry);
        Header.Text := Item.Category;
        Header.HitTest := True;
        Header.OnDragOver := FOnItemOver;
        ListBoxRegistry.AddObject(Header);
        CurCategory := Item.Category;
      end;
      var ListItem := TListBoxItem.Create(ListBoxRegistry);
      ListItem.HitTest := True;
      ListItem.DragMode := TDragMode.dmAutomatic;
      ListItem.StyleLookup := 'listboxitemstyle_node';
      ListItem.OnDragOver := FOnItemOver;
      ListItem.Text := Item.Caption;
      ListItem.TagString := Item.NodeType;
      ListItem.StylesData['background.Fill.Color'] := ChangeAlpha(Item.Color, $64);
      ListItem.StylesData['background.Stroke.Color'] := Item.Color;
      ListItem.StylesData['icon_bg.Fill.Color'] := Item.Color;
      ListItem.StylesData['path.Data.Data'] := Item.IconPath;
      ListBoxRegistry.AddObject(ListItem);
    end;
  finally
    ListBoxRegistry.EndUpdate;
  end;
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

procedure TFormMain.Button309Click(Sender: TObject);
begin
  Inc(OverTheme);
  if OverTheme > 2 then
    OverTheme := 1;
  DoOnSettingChange;
end;

procedure TFormMain.ButtonHideNodeLibraryClick(Sender: TObject);
begin
  LayoutNodeLibrary.Visible := False;
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

procedure TFormMain.ButtonSettingsClick(Sender: TObject);
begin
  PopupTheme.PlacementTarget := ButtonSettings;
  PopupTheme.Popup;
end;

procedure TFormMain.ButtonZoomClick(Sender: TObject);
begin
  PopupZoom.PlacementTarget := ButtonZoom;
  PopupZoom.Placement := TPlacement.Bottom;
  PopupZoom.HorizontalOffset := -PopupZoom.Width + ButtonZoom.Width;
  PopupZoom.Popup;
end;

procedure TFormMain.ButtonZoomInClick(Sender: TObject);
begin
  FEditor.SetZoom(FEditor.Zoom + 0.25, FEditor.LocalRect.CenterPoint.Round);
  PopupZoom.IsOpen := False;
end;

procedure TFormMain.ButtonZoomOutClick(Sender: TObject);
begin
  FEditor.SetZoom(FEditor.Zoom - 0.25, FEditor.LocalRect.CenterPoint.Round);
  PopupZoom.IsOpen := False;
end;

procedure TFormMain.ButtonZoomTo100Click(Sender: TObject);
begin
  FEditor.SetZoom(1, FEditor.LocalRect.CenterPoint.Round);
  PopupZoom.IsOpen := False;
end;

procedure TFormMain.ButtonZoomTo200Click(Sender: TObject);
begin
  FEditor.SetZoom(2, FEditor.LocalRect.CenterPoint.Round);
  PopupZoom.IsOpen := False;
end;

procedure TFormMain.ButtonZoomTo50Click(Sender: TObject);
begin
  FEditor.SetZoom(0.5, FEditor.LocalRect.CenterPoint.Round);
  PopupZoom.IsOpen := False;
end;

procedure TFormMain.ButtonZoomToFitClick(Sender: TObject);
begin
  FEditor.FrameAll;
  PopupZoom.IsOpen := False;
end;

procedure TFormMain.FOnEditorPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  //
end;

procedure TFormMain.BuildEditorArea;
begin
  FEditor := TNodeEditor.Create(LayoutRender);
  FEditor.Parent := LayoutRender;
  FEditor.Align := TAlignLayout.Client;
  FEditor.OnPaint := FOnEditorPaint;

  FEditor.OnSelectionChanged := OnSelectionChanged;
  FEditor.OnNodeChanged := OnNodeChanged;
  FEditor.OnUpdatedStatus := OnUpdatedStatus;

  FJsonNodeEditor := TJsonNodeEditor.Create(Self);
  FJsonNodeEditor.NodeEditor := FEditor;
  FJsonNodeEditor.OnChanged := OnJsonNodeEditorChanged;

  CheckBoxSnapToGridChange(nil);
end;

procedure TFormMain.OnJsonNodeEditorChanged(Sender: TObject);
begin
  RefreshFromSelection;
end;

procedure TFormMain.RegisterCustomNodes;
begin
  FEditor.Graph.Registry.RegisterNodeEx(
    'multiply_node',
    'Multiply',
    'Math',
    'Multiplies two float values.',
    'multiply,mul,math,float',
    'm13.4 12l6.3-6.3c.4-.4.4-1 0-1.4s-1-.4-1.4 0L12 10.6L5.7 4.3c-.4-.4-1-.4-1.4 0s-.4 1 0 1.4l6.3 6.3l-6.3 6.3c-.2.2-.3.4-.3.7c0 .6.4 1 1 1c.3 0 .5-.1.7-.3l6.3-6.3l6.3 6.3c.2.2.4.3.7.3s.5-.1.7-.3c.4-.4.4-1 0-1.4z',
    TMultiplyNode, $FF4080FF);

  FEditor.Graph.Registry.RegisterNodeEx(
    'math_expr',
    'Math Expression',
    'Math',
    'Evaluates a math expression A+B*C with exec pins and multiple value types.',
    'math,expr,expression,exec',
    'M110 72a6 6 0 0 1-6 6H40a6 6 0 0 1 0-12h64a6 6 0 0 1 6 6m-6 106H78v-26a6 6 0 0 0-12 0v26H40a6 6 0 0 0 0 12h26v26a6 6 0 0 0 12 0v-26h26a6 6 0 0 0 0-12m48-4h64a6 6 0 0 0 0-12h-64a6 6 0 0 0 0 12m64 20h-64a6 6 0 0 0 0 12h64a6 6 0 0 0 0-12m-60.24-93.76a6 6 0 0 0 8.48 0L184 80.49l19.76 19.75a6 6 0 0 0 8.48-8.48L192.49 72l19.75-19.76a6 6 0 0 0-8.48-8.48L184 63.51l-19.76-19.75a6 6 0 0 0-8.48 8.48L175.51 72l-19.75 19.76a6 6 0 0 0 0 8.48',
    TMathExprNode, $FF4080FF);

  FEditor.Graph.Registry.RegisterNodeEx(
    'string_node',
    'String Value',
    'Values',
    'Constant string value.',
    'string,text,value',
    'M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zm9.5 6h-1A1.5 1.5 0 0 1 10 9.5A1.5 1.5 0 0 1 11.5 8h1A1.5 1.5 0 0 1 14 9.5h2A3.5 3.5 0 0 0 12.5 6h-1A3.5 3.5 0 0 0 8 9.5a3.5 3.5 0 0 0 3.5 3.5h1a1.5 1.5 0 0 1 1.5 1.5a1.5 1.5 0 0 1-1.5 1.5h-1a1.5 1.5 0 0 1-1.5-1.5H8a3.5 3.5 0 0 0 3.5 3.5h1a3.5 3.5 0 0 0 3.5-3.5a3.5 3.5 0 0 0-3.5-3.5',
    TStringNode, $FF00C080);

  FEditor.Graph.Registry.RegisterNodeEx(
    'branch_node',
    'Branch',
    'Flow',
    'Conditional exec branch (if/else).',
    'branch,if,else,exec,flow',
    'M22 12h-5M2 9h5m-5 6h5M9 5c6 0 8 3.5 8 7s-2 7-8 7H7V5z',
    TBranchNode, $FFC04000);

  FEditor.Graph.Registry.RegisterNodeEx(
    'print_node',
    'Print',
    'Common',
    'Print input text',
    'common,string,print,text',
    'M16 8V5H8v3H6V3h12v5zM4 10h16zm14 2.5q.425 0 .713-.288T19 11.5t-.288-.712T18 10.5t-.712.288T17 11.5t.288.713t.712.287M16 19v-4H8v4zm2 2H6v-4H2v-6q0-1.275.875-2.137T5 8h14q1.275 0 2.138.863T22 11v6h-4zm2-6v-4q0-.425-.288-.712T19 10H5q-.425 0-.712.288T4 11v4h2v-2h12v2z',
    TPrintNode, $FF843482);
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

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  //
end;

procedure TFormMain.TrackBarZoomChange(Sender: TObject);
begin
  if FNodeUpdating then
    Exit;
  FNodeUpdating := True;
  FEditor.SetZoom((TrackBarZoom.Value) / 100, FEditor.LocalRect.CenterPoint.Round);
  FNodeUpdating := False;
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
  NMath.FixedSize := True;
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

procedure TFormMain.ListBoxRegistryDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.None;
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

procedure TFormMain.MenuItemFileExitClick(Sender: TObject);
begin
  Application.Terminate;
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

procedure TFormMain.MenuItemNodeLibraryClick(Sender: TObject);
begin
  LayoutNodeLibrary.Visible := True;
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
  FEditor.ResetView;
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

procedure TFormMain.CheckBoxCustomAccentChange(Sender: TObject);
begin
  if FUpdating > 0 then
    Exit;
  DoOnSettingChange;
end;

procedure TFormMain.CheckBoxCustomTitleChange(Sender: TObject);
begin
  HideTitleBar := CheckBoxCustomTitle.IsChecked;
end;

procedure TFormMain.CheckBoxSnapToGridChange(Sender: TObject);
begin
  FEditor.SnapToGrid := CheckBoxSnapToGrid.IsChecked;
  FEditor.SnapToNodes := CheckBoxSnapToNodes.IsChecked;
  FEditor.ShowFrameTime := CheckBoxShowFrameTime.IsChecked;
  FEditor.ShowGrid := CheckBoxShowGrid.IsChecked;
  FEditor.ShowAxes := CheckBoxShowAxes.IsChecked;
  FEditor.ShowSnapGuides := CheckBoxShowSnapGuides.IsChecked;
  FEditor.LockedAll := CheckBoxLockedAll.IsChecked;
  UpdateStatus;
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
    LabelNodeType.Text := 'Node (no selection)';
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
    LabelNodeType.Text := 'Node';
    EditNodeTitle.Text := '';
    SpinBoxNodeX.Value := 0;
    SpinBoxNodeY.Value := 0;
    SpinBoxNodeWidth.Value := 0;
    SpinBoxNodeHeight.Value := 0;
    ComboColorBoxNodeHeadColor.Color := TAlphaColors.Null;
    CheckBoxNodeCollapsed.IsChecked := False;
    MemoNodeComment.Text := '';
    StringGridNodeValues.RowCount := 0;
    StringGridNodeValues.Height := StringGridNodeValues.RowCount * StringGridNodeValues.RowHeight + (32 + 8);
    LayoutNodeData.Height := StringGridNodeValues.Height + 40 + 10;
  finally
    FNodeUpdating := False;
  end;
end;

procedure TFormMain.ComboColorBoxAccentColorChange(Sender: TObject);
begin
  if FUpdating > 0 then
    Exit;
  BeginUpdate;
  CheckBoxCustomAccent.IsChecked := True;
  EndUpdate;
  DoOnSettingChange;
end;

procedure TFormMain.ComboColorBoxThemeGradient1Change(Sender: TObject);
begin
  Fill.Kind := TBrushKind.Gradient;
  Fill.Gradient.Color := ComboColorBoxThemeGradient1.Color;
  Fill.Gradient.Color1 := ComboColorBoxThemeGradient2.Color;
end;

procedure TFormMain.RefreshFromSelection;
var
  N: TCustomNode;
  i: integer;
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
    LabelNodeType.Text := 'Node (' + N.NodeType + ')';

    // --- Basic ---
    EditNodeTitle.Text := N.Title;
    SpinBoxNodeX.Value := N.X;
    SpinBoxNodeY.Value := N.Y;
    SpinBoxNodeWidth.Value := N.Width;
    SpinBoxNodeHeight.Value := N.Height;

    // --- Visual ---
    ComboColorBoxNodeHeadColor.Color := N.HeaderColor;
    CheckBoxNodeCollapsed.IsChecked := N.Collapsed;

    // --- Comment ---
    MemoNodeComment.Text := N.CommentText;

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

    StringGridNodeValues.Height := StringGridNodeValues.RowCount * StringGridNodeValues.RowHeight + (32 + 8);
    LayoutNodeData.Height := StringGridNodeValues.Height + 40 + 10;
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

procedure TFormMain.PaintRects(const UpdateRects: array of TRectF);
begin
  RectangleNav.Fill.Bitmap.Bitmap.SetSize(RectangleNav.Size.Size.Round);
  FEditor.RenderNavigator(RectangleNav.Fill.Bitmap.Bitmap);
  inherited;
end;

procedure TFormMain.DoOnSettingChange;
begin
  if CheckBoxCustomAccent.IsChecked then
    OverAccentColor := ComboColorBoxAccentColor.Color
  else
    OverAccentColor := SystemAccentColor;

  // Override theme color
  case OverTheme of
    0:
      ThemeKind := TSystemThemeKind.Unspecified;
    1:
      ThemeKind := TSystemThemeKind.Light;
    2:
      ThemeKind := TSystemThemeKind.Dark;
  end;

  // Set stylebook and color for theme
  if IsDark then
  begin
    // Set accent color for stylebook
    ChangeStyleBookColor(StyleBookWinUI3, OverAccentColor);
    StyleBook := StyleBookWinUI3;
  end
  else
  begin
    // Set accent color for stylebook
    ChangeStyleBookColor(StyleBookWinUI3Light, OverAccentColor);
    StyleBook := StyleBookWinUI3Light;
  end;

  inherited;
  //Fill.Kind := TBrushKind.None;
  TMessageManager.DefaultManager.SendMessage(Self, TStyleChangedMessage.Create(StyleBook, Self), True);
  TMessageManager.DefaultManager.SendMessage(Self, TInternalSettingChangedMessage.Create(StyleBook, Self), True);
end;

procedure TFormMain.PopupBoxStyleChange(Sender: TObject);
begin
  // Set window type
  case PopupBoxStyle.ItemIndex of
    0: // mica
      SystemBackdropType := TWindowBackdropType.Mica;
    1: // tabbed
      SystemBackdropType := TWindowBackdropType.Tabbed;
    2: // acrilyc
      SystemBackdropType := TWindowBackdropType.Acrylic;
    3: // none
      begin
        SystemBackdropType := TWindowBackdropType.Disable;
        Fill.Kind := TBrushKind.None;
      end;
  end;
  UpdateSystemBackdropType;
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
  ButtonZoom.Text := Format('%.0f%%', [FEditor.Zoom * 100]);
  LabelStat4.Text :=
    'Snap: ' + (if FEditor.SnapToGrid then 'ON' else 'OFF') +
    '  Grid: ' + IntToStr(FEditor.GridSize);

  if not FNodeUpdating then
  begin
    FNodeUpdating := True;
    TrackBarZoom.Value := FEditor.Zoom * 100;
    FNodeUpdating := False;
  end;
end;

{ TTrackBar }

procedure TTrackBar.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  LValue: Double;
  OldValue: Double;
  LInc: Double;
begin
  LInc := Frequency;
  if LInc = 0 then
    LInc := 1;
  LInc := LInc * Sign(WheelDelta);
  LValue := Value + LInc;
  OldValue := Value;
  Value := LValue;
  Handled := not SameValue(Value, OldValue);
end;

{ TMathExprNode }

constructor TMathExprNode.Create;
begin
  inherited;
  NodeType := 'math_expr';
  HeaderColor := $FF4080FF;
  BodyColor := $FFF0F8FF;
  IconPath := 'M110 72a6 6 0 0 1-6 6H40a6 6 0 0 1 0-12h64a6 6 0 0 1 6 6m-6 106H78v-26a6 6 0 0 0-12 0v26H40a6 6 0 0 0 0 12h26v26a6 6 0 0 0 12 0v-26h26a6 6 0 0 0 0-12m48-4h64a6 6 0 0 0 0-12h-64a6 6 0 0 0 0 12m64 20h-64a6 6 0 0 0 0 12h64a6 6 0 0 0 0-12m-60.24-93.76a6 6 0 0 0 8.48 0L184 80.49l19.76 19.75a6 6 0 0 0 8.48-8.48L192.49 72l19.75-19.76a6 6 0 0 0-8.48-8.48L184 63.51l-19.76-19.75a6 6 0 0 0-8.48 8.48L175.51 72l-19.75 19.76a6 6 0 0 0 0 8.48';

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
  Width := 200;
  Height := 170;
end;

procedure TMathExprNode.SetupPins;
begin
  ClearPins;
  // Exec-пины
  AddInputPin('▶ Exec In', 'exec', pkExec, 35);
  AddOutputPin('▶ Exec Out', 'exec', pkExec, 35);
  // Data-пины
  AddInputPin('A', 'float', pkData, 75);
  AddInputPin('B', 'float', pkData, 105);
  AddInputPin('C', 'float', pkData, 135);
  AddOutputPin('Result', 'float', pkData, 90);
  // IsRequired demo
  GetInput(1).IsRequired := True;
  GetInput(2).IsRequired := True;
  GetInput(1).DefaultValue := '0.0';
  GetInput(1).Tooltip := 'First operand';
end;

{ TMultiplyNode }

constructor TMultiplyNode.Create;
begin
  inherited;
  NodeType := 'multiply_node';
  HeaderColor := $FF4080FF;
  IconPath := 'm14 9l3 5.063M4 9l6 6m-6 0l6-6m10 0l-4.8 9';
  Width := 180;
  Height := 130;
end;

procedure TMultiplyNode.SetupPins;
begin
  ClearPins;
  AddInputPin('A', 'float', pkData, 45);
  AddInputPin('B', 'float', pkData, 75);
  AddOutputPin('Result', 'float', pkData, 60);
  GetInput(0).IsRequired := True;
  GetInput(1).IsRequired := True;
end;

{ TStringNode }

constructor TStringNode.Create;
begin
  inherited;
  NodeType := 'string_node';
  HeaderColor := $FF00C080;
  IconPath := 'M3 5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2zm9.5 6h-1A1.5 1.5 0 0 1 10 9.5A1.5 1.5 0 0 1 11.5 8h1A1.5 1.5 0 0 1 14 9.5h2A3.5 3.5 0 0 0 12.5 6h-1A3.5 3.5 0 0 0 8 9.5a3.5 3.5 0 0 0 3.5 3.5h1a1.5 1.5 0 0 1 1.5 1.5a1.5 1.5 0 0 1-1.5 1.5h-1a1.5 1.5 0 0 1-1.5-1.5H8a3.5 3.5 0 0 0 3.5 3.5h1a3.5 3.5 0 0 0 3.5-3.5a3.5 3.5 0 0 0-3.5-3.5';
  var V := AddValue('text', nvkString);
  V.StringValue := 'Hello, Node!';
  Width := 180;
  Height := 70;
end;

procedure TStringNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('Text', 'string', pkData, 45);
end;

{ TBranchNode }

constructor TBranchNode.Create;
begin
  inherited;
  NodeType := 'branch_node';
  HeaderColor := $FFC04000;
  IconPath := 'M22 12h-5M2 9h5m-5 6h5M9 5c6 0 8 3.5 8 7s-2 7-8 7H7V5z';
  Width := 180;
  Height := 140;
end;

procedure TBranchNode.SetupPins;
begin
  ClearPins;
  AddInputPin('▶ Exec', 'exec', pkExec, 35);
  AddInputPin('Condition', 'boolean', pkData, 75);
  AddOutputPin('▶ True', 'exec', pkExec, 55);
  AddOutputPin('▶ False', 'exec', pkExec, 90);
  GetInput(1).IsRequired := True;
end;

{ TPrintNode }

constructor TPrintNode.Create;
begin
  inherited;
  NodeType := 'print_node';
  IconPath := 'M16 8V5H8v3H6V3h12v5zM4 10h16zm14 2.5q.425 0 .713-.288T19 11.5t-.288-.712T18 10.5t-.712.288T17 11.5t.288.713t.712.287M16 19v-4H8v4zm2 2H6v-4H2v-6q0-1.275.875-2.137T5 8h14q1.275 0 2.138.863T22 11v6h-4zm2-6v-4q0-.425-.288-.712T19 10H5q-.425 0-.712.288T4 11v4h2v-2h12v2z';
  Width := 180;
  Height := 70;
end;

procedure TPrintNode.SetupPins;
begin
  inherited;
  ClearPins;
  AddInputPin('Text', 'string', pkData, 45);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

