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
  FMX.ComboEdit, WinUI3.Form, FMX.SearchBox, System.Math.Vectors;

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
    LayoutClient: TLayout;
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
    PanelEditor: TPanel;
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
    MenuBarMain: TMenuBar;
    MenuItemFile: TMenuItem;
    MenuItemFileNew: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItemFileSave: TMenuItem;
    MenuItemFileLoad: TMenuItem;
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
    MenuItemGraph: TMenuItem;
    MenuItemGraphValidate: TMenuItem;
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
    SizeGrip: TSizeGrip;
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
    SearchBox1: TSearchBox;
    Layout1: TLayout;
    Layout21: TLayout;
    PathLabel22: TPathLabel;
    Label12: TLabel;
    Label15: TLabel;
    LayoutMobileMenu: TLayout;
    RadioButtonMenuProjects: TRadioButton;
    RadioButtonMenuSettings: TRadioButton;
    RadioButtonMenuRun: TRadioButton;
    RadioButtonMenuGraph: TRadioButton;
    CornerButtonMenuAdd: TCornerButton;
    PathLabel23: TPathLabel;
    PanelMobileOverlay: TPanel;
    LayoutMobileOverlay: TLayout;
    LayoutZoomMobile: TLayout;
    Button3: TButton;
    Button4: TButton;
    MenuItem15: TMenuItem;
    MenuItem17: TMenuItem;
    ButtonZoomReset: TButton;
    ButtonZoomToSelect: TButton;
    ComboBoxVisualLinkType: TComboBox;
    Label16: TLabel;
    PathLabel24: TPathLabel;
    CheckBoxLinkGradient: TCheckBox;
    PathLabel25: TPathLabel;
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
    procedure MenuItemGraphValidateClick(Sender: TObject);
    procedure MenuItemEditDeselectClick(Sender: TObject);
    procedure MenuItemEditToFrontClick(Sender: TObject);
    procedure MenuItemEditToBackClick(Sender: TObject);
    procedure SpinBoxSizeChange(Sender: TObject);
    procedure ButtonNodeApplyClick(Sender: TObject);
    procedure StringGridNodeValuesSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ButtonNodeRevertClick(Sender: TObject);
    procedure MenuItemJSONLoadClick(Sender: TObject);
    procedure MenuItemJSONSaveClick(Sender: TObject);
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
    procedure LayoutMobileMenuResize(Sender: TObject);
    procedure CornerButtonMenuAddClick(Sender: TObject);
    procedure RadioButtonMenuSettingsChange(Sender: TObject);
    procedure ButtonZoomResetClick(Sender: TObject);
    procedure ButtonZoomToSelectClick(Sender: TObject);
    procedure ComboBoxVisualLinkTypeChange(Sender: TObject);
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
    procedure RefreshFromSelection;
    procedure ClearAllSections;
    procedure OnUpdatedStatus(Sender: TObject);
    procedure OnJsonNodeEditorChanged(Sender: TObject);
    procedure FOnEditorPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure UpdateNodeRegistry;
    procedure FOnItemOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
  protected
    OverTheme: integer;
    OverAccentColor: TAlphaColor;
    procedure MobileMode;
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
  CaptionControls := [LayoutCaption, LayoutHead];
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

  LayoutMobileMenu.Visible := False;
  LayoutZoomMobile.Visible := False;
  PanelMobileOverlay.Visible := False;
  //
  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  MobileMode;
  {$ENDIF}
  //

  UpdateStatus;
end;

procedure TFormMain.MobileMode;
begin
  HideTitleBar := False;
  PanelEditor.StyleLookup := 'Panelstyle_background';
  LayoutZoomMobile.Visible := True;
  LayoutLeft.Visible := False;
  LayoutRight.Visible := False;
  LayoutNodeLibrary.Visible := False;
  LayoutHead.Visible := False;
  Constraints.MinHeight := 0;
  Constraints.MinWidth := 400;
  StatusBar.Visible := False;
  LayoutMobileMenu.Visible := True;
  RadioButtonMenuProjects.StylesData['path.Data.Data'] := 'M20 6h-8l-1.41-1.41C10.21 4.21 9.7 4 9.17 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2m-3.06 10.41L15 15.28l-1.94 1.13a.502.502 0 0 1-.74-.55l.51-2.2l-1.69-1.46c-.33-.29-.16-.84.28-.88l2.23-.19l.88-2.06c.17-.4.75-.4.92 ' +
    '0l.88 2.06l2.23.19a.5.5 0 0 1 .28.88l-1.69 1.46l.51 2.2a.49.49 0 0 1-.72.55';
  RadioButtonMenuGraph.StylesData['path.Data.Data'] := 'M2.998 5.246a2.25 2.25 0 0 1 2.25-2.25h2.507a2.25 2.25 0 0 1 2.25 2.25v2.507a2.25 2.25 0 0 1-2.25 2.25H7.25v3.707q.07.051.134.116l2.79 2.79q.065.065.117.135h3.714v-.5a2.25 2.25 0 0 1 2.25-2.25h2.494a2.25 ' +
    '2.25 0 0 1 2.25 2.25v2.504a2.25 2.25 0 0 1-2.25 2.25h-2.494a2.25 2.25 0 0 1-2.25-2.25v-.504H10.29a1 1 0 0 1-.115.133l-2.791 2.792a1.25 1.25 0 0 1-1.768 0l-2.792-2.791a1.25 1.25 0 0 1 0-1.768l2.792-2.792a1 ' +
    '1 0 0 1 .134-.116v-3.706h-.502a2.25 2.25 0 0 1-2.25-2.25z';

  RadioButtonMenuRun.StylesData['path.Data.Data'] := 'M12.225 4.462C9.89 3.142 7 4.827 7 7.508V24.5c0 2.682 2.892 4.368 5.226 3.045l14.997-8.498c2.367-1.341 2.366-4.751 0-6.091z';
  RadioButtonMenuSettings.StylesData['path.Data.Data'] := 'M1.911 7.383a8.5 8.5 0 0 1 1.78-3.08a.5.5 0 0 1 .54-.135l1.918.686a1 1 0 0 0 1.32-.762l.366-2.006a.5.5 0 0 1 .388-.4a8.5 8.5 0 0 1 3.554 0a.5.5 0 0 1 .388.4l.366 2.006a1 1 0 0 0 1.32.762l1.919-.686a.5.5 ' +
    '0 0 1 .54.136a8.5 8.5 0 0 1 1.78 3.079a.5.5 0 0 1-.153.535l-1.555 1.32a1 1 0 0 0 0 1.524l1.555 1.32a.5.5 0 0 1 .152.535a8.5 8.5 0 0 1-1.78 3.08a.5.5 0 0 1-.54.135l-1.918-.686a1 1 0 0 0-1.32.762l-.366 2.007a.5.5 ' +
    '0 0 1-.388.399a8.5 8.5 0 0 1-3.554 0a.5.5 0 0 1-.388-.4l-.366-2.006a1 1 0 0 0-1.32-.762l-1.918.686a.5.5 0 0 1-.54-.136a8.5 8.5 0 0 1-1.78-3.079a.5.5 0 0 1 .152-.535l1.555-1.32a1 1 0 0 0 0-1.524l-1.555-1.32a.5.5 ' +
    '0 0 1-.152-.535m1.06-.006l1.294 1.098a2 2 0 0 1 0 3.05l-1.293 1.098c.292.782.713 1.51 1.244 2.152l1.596-.57q.155-.055.315-.085a2 2 0 0 1 2.326 1.609l.304 1.669a7.6 7.6 0 0 0 2.486 0l.304-1.67a1.998 1.998 ' +
    '0 0 1 2.641-1.524l1.596.571a7.5 7.5 0 0 0 1.245-2.152l-1.294-1.098a1.998 1.998 0 0 1 0-3.05l1.294-1.098a7.5 7.5 0 0 0-1.245-2.152l-1.596.57a2 2 0 0 1-2.64-1.524l-.305-1.669a7.6 7.6 0 0 0-2.486 0l-.304 ' +
    '1.669a2 2 0 0 1-2.64 1.525l-1.597-.571a7.5 7.5 0 0 0-1.244 2.152M7.502 10a2.5 2.5 0 1 1 5 0a2.5 2.5 0 0 1-5 0m1 0a1.5 1.5 0 1 0 3 0a1.5 1.5 0 0 0-3 0';
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
      ListItem.Hint := Item.Description;
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
    FEditor.Fit;
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
  PanelMobileOverlay.Visible := False;
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
      TNodeValueKind.Float:
        V.FloatValue := StrToFloatDef(VStr, V.FloatValue);
      TNodeValueKind.Integer:
        V.IntegerValue := StrToInt64Def(VStr, V.IntegerValue);
      TNodeValueKind.string:
        V.StringValue := VStr;
      TNodeValueKind.Boolean:
        V.BooleanValue := SameText(VStr, 'true') or (VStr = '1');
      TNodeValueKind.JSON:
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
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(FEditor.Zoom + 0.25, FEditor.LocalRect.CenterPoint.Round);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomOutClick(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(FEditor.Zoom - 0.25, FEditor.LocalRect.CenterPoint.Round);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomResetClick(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.ResetView;
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomTo100Click(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(1, FEditor.LocalRect.CenterPoint.Round);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomTo200Click(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(2, FEditor.LocalRect.CenterPoint.Round);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomTo50Click(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(0.5, FEditor.LocalRect.CenterPoint.Round);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomToFitClick(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.Fit;
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomToSelectClick(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  if FEditor.SelectedNodeCount > 0 then
    FEditor.FitSelection
  else
    FEditor.Fit;
  UpdateStatus;
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
  NFloat1 := FEditor.Graph.Registry.CreateNode('float', PointF(40, 120));
  NFloat1.Title := 'Value A';
  TFloatNode(NFloat1).SetupPins;
  V := NFloat1.FindValue('value');
  if V <> nil then
    V.FloatValue := 3.14;
  FEditor.AddNode(NFloat1);

  NFloat2 := FEditor.Graph.Registry.CreateNode('float', PointF(40, 240));
  NFloat2.Title := 'Value B';
  TFloatNode(NFloat2).SetupPins;
  V := NFloat2.FindValue('value');
  if V <> nil then
    V.FloatValue := 2.71;
  FEditor.AddNode(NFloat2);

  NFloat3 := FEditor.Graph.Registry.CreateNode('float', PointF(40, 360));
  NFloat3.Title := 'Value C';
  TFloatNode(NFloat3).SetupPins;
  V := NFloat3.FindValue('value');
  if V <> nil then
    V.FloatValue := 10.0;
  FEditor.AddNode(NFloat3);

  // ── Add node ───────────────────────────────────────────────────
  NAdd := FEditor.Graph.Registry.CreateNode('add', PointF(280, 160));
  NAdd.Title := 'A + B';
  FEditor.AddNode(NAdd);

  // ── Multiply node (custom) ─────────────────────────────────────
  NMul := FEditor.Graph.Registry.CreateNode('multiply_node', PointF(280, 310));
  NMul.Title := '(A+B) × C';
  FEditor.AddNode(NMul);

  // ── Math Expression (exec + values) ───────────────────────────
  NMath := FEditor.Graph.Registry.CreateNode('math_expr', PointF(520, 180));
  NMath.Title := 'Math Expr';
  NMath.FixedSize := True;
  FEditor.AddNode(NMath);

  // ── String node ────────────────────────────────────────────────
  NStr := FEditor.Graph.Registry.CreateNode('string_node', PointF(520, 420));
  NStr.Title := 'Label';
  FEditor.AddNode(NStr);

  // ── Branch node (exec flow) ───────────────────────────────────
  NBranch := FEditor.Graph.Registry.CreateNode('branch_node', PointF(760, 160));
  NBranch.Title := 'If Enabled?';
  FEditor.AddNode(NBranch);

  // ── Reroute ────────────────────────────────────────────────────
  NReroute := FEditor.Graph.Registry.CreateNode('reroute', PointF(240, 470));
  FEditor.AddNode(NReroute);

  // ── Default node ───────────────────────────────────────────────
  NDefault := FEditor.Graph.Registry.CreateNode('default', PointF(760, 360));
  NDefault.Title := 'Default Node';
  FEditor.AddNode(NDefault);

  // ── Comment / Frame 1 (Math block) ────────────────────────────
  NComment1 := FEditor.Graph.Registry.CreateNode('comment', PointF(20, 80));
  NComment1.Title := 'Math Block';
  NComment1.Width := 460;
  NComment1.Height := 360;
  NComment1.CommentText := 'Arithmetic: A+B then ×C';
  NComment1.HeaderColor := $FF60A060;
  NComment1.BodyColor := $FFEEFFEE;
  FEditor.AddNode(NComment1);

  // ── Comment / Frame 2 (Flow block) ────────────────────────────
  NComment2 := FEditor.Graph.Registry.CreateNode('comment', PointF(500, 120));
  NComment2.Title := 'Flow Block';
  NComment2.Width := 320;
  NComment2.Height := 200;
  NComment2.CommentText := 'Exec pipeline: Expr → Branch';
  NComment2.HeaderColor := $FF804000;
  NComment2.BodyColor := $FFFFF8E8;
  FEditor.AddNode(NComment2);

  // ── Links: Float → Add ─────────────────────────────────────────
  FEditor.AddLink(NFloat1.GetOutput(0), NAdd.GetInput(0));
  FEditor.AddLink(NFloat2.GetOutput(0), NAdd.GetInput(1));

  // ── Links: Add+Float3 → Mul ────────────────────────────────────
  FEditor.AddLink(NAdd.GetOutput(0), NMul.GetInput(0));

  // Float3 → Reroute → Mul.B
  if (NReroute.InputCount > 0) and (NReroute.OutputCount > 0) then
  begin
    FEditor.AddLink(NFloat3.GetOutput(0), NReroute.GetInput(0));
    FEditor.AddLink(NReroute.GetOutput(0), NMul.GetInput(1));
  end;

  // ── Links: Mul → Math A, Float1 → Math B, Float2 → Math C ─────
  if NMath.InputCount >= 4 then // exec + A + B + C
  begin
    FEditor.AddLink(NMul.GetOutput(0), NMath.GetInput(1));
    FEditor.AddLink(NFloat1.GetOutput(0), NMath.GetInput(2));
    FEditor.AddLink(NFloat2.GetOutput(0), NMath.GetInput(3));
  end;

  // ── Links: Math Exec Out → Branch Exec In ──────────────────────
  if (NMath.OutputCount >= 1) and (NBranch.InputCount >= 1) then
    FEditor.AddLink(NMath.GetOutput(0), NBranch.GetInput(0));

  // ── Links: Branch True → Default In ───────────────────────────
  if (NBranch.OutputCount >= 1) and (NDefault.InputCount >= 1) then
    FEditor.AddLink(NBranch.GetOutput(0), NDefault.GetInput(0));

  // ── Select Math node — демонстрируем все его values в инспекторе
  FEditor.SelectNode(NMath, False);
  RefreshFromSelection;
end;

procedure TFormMain.LayoutMobileMenuResize(Sender: TObject);
begin
  for var Control in LayoutMobileMenu.Controls do
    Control.Width := Trunc(LayoutMobileMenu.Width / 5);
  CornerButtonMenuAdd.XRadius := Min(CornerButtonMenuAdd.Width / 2, CornerButtonMenuAdd.Height / 2);
  CornerButtonMenuAdd.YRadius := CornerButtonMenuAdd.XRadius;
end;

procedure TFormMain.ListBoxRegistryDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.None;
end;

procedure TFormMain.MenuItemEditCopyClick(Sender: TObject);
begin
  FEditor.CopySelectionToClipboard;
  LabelStat5.Text := Format('Copied %d node(s)', [FEditor.SelectedNodeCount]);
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
    FEditor.SendNodeToBack(FEditor.GetSelectedNode(i));
  LabelStat5.Text := 'Sent to back';
end;

procedure TFormMain.MenuItemEditToFrontClick(Sender: TObject);
begin
  if FEditor.SelectedNodeCount = 0 then
    Exit;
  for var i := 0 to FEditor.SelectedNodeCount - 1 do
    FEditor.BringNodeToFront(FEditor.GetSelectedNode(i));
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
    FEditor.Fit;
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
  Feditor.LinkGradient := CheckBoxLinkGradient.IsChecked;
  UpdateStatus;
end;

procedure TFormMain.OnSelectionChanged(Sender: TObject);
begin
  RefreshFromSelection;
end;

procedure TFormMain.ClearAllSections;
begin
  FNodeUpdating := True;
  try
    LabelNodeType.Text := 'Node (no selection)';
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
    ButtonNodeApply.Enabled := False;
    PanelInspector.Enabled := False;
    ButtonNodeRevert.Enabled := False;
  finally
    FNodeUpdating := False;
  end;
end;

procedure TFormMain.ComboBoxVisualLinkTypeChange(Sender: TObject);
begin
  FEditor.LinkVisualType := TLinkVisualType(ComboBoxVisualLinkType.ItemIndex);
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

procedure TFormMain.CornerButtonMenuAddClick(Sender: TObject);
begin
  for var Control in LayoutMobileOverlay.Controls do
    Control.Visible := False;
  LayoutNodeLibrary.Parent := LayoutMobileOverlay;
  LayoutNodeLibrary.Align := TAlignLayout.Client;
  LayoutNodeLibrary.Visible := True;
  LayoutNodeLibrary.Margins.Left := 0;
  PanelMobileOverlay.Visible := True;
  PanelMobileOverlay.BringToFront;
end;

procedure TFormMain.RadioButtonMenuSettingsChange(Sender: TObject);
begin
  var Layout: TControl := nil;
  if RadioButtonMenuSettings.IsChecked then
    Layout := LayoutRight
  else if RadioButtonMenuGraph.IsChecked then
    Layout := LayoutLeft;
  if Layout <> nil then
  begin
    for var Control in LayoutMobileOverlay.Controls do
      Control.Visible := False;
    Layout.Parent := LayoutMobileOverlay;
    Layout.Align := TAlignLayout.Client;
    Layout.Visible := True;
    Layout.Margins.Left := 0;
    PanelMobileOverlay.Visible := True;
    PanelMobileOverlay.BringToFront;
  end
  else
    PanelMobileOverlay.Visible := False;
end;

procedure TFormMain.RefreshFromSelection;
var
  N: TCustomNode;
  i: integer;
  V: TNodeValue;
  VStr: string;
begin
  UpdateStatus;
  if (FEditor = nil) or (FEditor.SelectedNodeCount <> 1) then
  begin
    ClearAllSections;
    if FEditor.SelectedNodeCount > 1 then
      LabelNodeType.Text := 'Node (multiple)';
    Exit;
  end;

  N := FEditor.GetSelectedNode(0);
  if N = nil then
  begin
    ClearAllSections;
    Exit;
  end;

  FNodeUpdating := True;
  try
    ClearAllSections;

    // --- Info ---
    LabelNodeType.Text := Format('Node (%s)', [N.NodeType]);

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
          TNodeValueKind.Float:
            VStr := FormatFloat('0.######', V.FloatValue);
          TNodeValueKind.Integer:
            VStr := IntToStr(V.IntegerValue);
          TNodeValueKind.string:
            VStr := V.StringValue;
          TNodeValueKind.Boolean:
            VStr := if V.BooleanValue then 'true' else 'false';
          TNodeValueKind.JSON:
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
begin       //FF2C4361 - FF0B1E39
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
  if IsDark then
  begin
    //Fill.Kind := TBrushKind.None;
    Fill.Kind := TBrushKind.Gradient;
    Fill.Gradient.Color := $FF2C4361;
    Fill.Gradient.Color1 := $FF0B1E39;
  end;
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
    SelStr := Format('Selected: %d nodes', [FEditor.SelectedNodeCount])
  else if FEditor.SelectedNodeCount = 1 then
    SelStr := 'Selected: ' + FEditor.GetSelectedNode(0).Title
  else if FEditor.SelectedLinkCount = 1 then
    SelStr := 'Selected: 1 link'
  else if FEditor.SelectedLinkCount > 0 then
    SelStr := Format('Selected: %d links', [FEditor.SelectedLinkCount])
  else if FEditor.SelectedPinCount = 1 then
    SelStr := 'Selected: 1 pin'
  else if FEditor.SelectedPinCount > 0 then
    SelStr := Format('Selected: %d pins', [FEditor.SelectedPinCount])
  else
    SelStr := 'No selection';

  LabelStat1.Text := SelStr;
  LabelStat2.Text := Format('Nodes: %d | Links: %d', [FEditor.Graph.Nodes.Count, FEditor.Graph.Links.Count]);
  LabelStat3.Text := Format('Zoom: %.0f%%', [FEditor.Zoom * 100]);
  ButtonZoom.Text := Format('%.0f%%', [FEditor.Zoom * 100]);
  LabelStat4.Text :=
    'Snap: ' + (if FEditor.SnapToGrid then 'ON' else 'OFF') +
    '  Grid: ' + IntToStr(FEditor.GridSize);
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
  var V := AddValue('expression', TNodeValueKind.string);
  V.StringValue := 'A + B * C';

  V := AddValue('precision', TNodeValueKind.Integer);
  V.IntegerValue := 6;

  V := AddValue('scale', TNodeValueKind.Float);
  V.FloatValue := 1.0;

  V := AddValue('enabled', TNodeValueKind.Boolean);
  V.BooleanValue := True;

  V := AddValue('meta', TNodeValueKind.JSON);
  V.JSONValue := '{"mode":"fast"}';
  Width := 200;
  Height := 170;
end;

procedure TMathExprNode.SetupPins;
begin
  ClearPins;
  // Exec-пины
  AddInputPin('▶ Exec In', 'exec', TPinKind.Exec, 35);
  AddOutputPin('▶ Exec Out', 'exec', TPinKind.Exec, 35);
  // Data-пины
  AddInputPin('A', 'float', TPinKind.Data, 75);
  AddInputPin('B', 'float', TPinKind.Data, 105);
  AddInputPin('C', 'float', TPinKind.Data, 135);
  AddOutputPin('Result', 'float', TPinKind.Data, 90);
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
  AddInputPin('A', 'float', TPinKind.Data, 45);
  AddInputPin('B', 'float', TPinKind.Data, 75);
  AddOutputPin('Result', 'float', TPinKind.Data, 60);
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
  var V := AddValue('text', TNodeValueKind.string);
  V.StringValue := 'Hello, Node!';
  Width := 180;
  Height := 70;
end;

procedure TStringNode.SetupPins;
begin
  ClearPins;
  AddOutputPin('Text', 'string', TPinKind.Data, 45);
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
  AddInputPin('▶ Exec', 'exec', TPinKind.Exec, 35);
  AddInputPin('Condition', 'boolean', TPinKind.Data, 75);
  AddOutputPin('▶ True', 'exec', TPinKind.Exec, 55);
  AddOutputPin('▶ False', 'exec', TPinKind.Exec, 90);
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
  AddInputPin('Text', 'string', TPinKind.Data, 45);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

