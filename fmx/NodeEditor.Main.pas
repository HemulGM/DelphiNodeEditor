unit NodeEditor.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.NodeEditor, FMX.Edit,
  FMX.Edit.Style.New, FMX.Grid.Style, FMX.Layouts, FMX.Menus, FMX.EditBox,
  FMX.SpinBox, FMX.Filter.Effects, FMX.Colors, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, System.Rtti, FMX.Grid, FMX.Objects, FMX.NodeEditor.Node,
  FMX.NodeEditor.Node.Defaults, FMX.NodeEditor.Parser.JSON, FMX.NodeEditor.Types,
  FMX.Ani, FMX.ExtCtrls, FMX.TabControl, FMX.ComboTrackBar, FMX.ListBox,
  FMX.ComboEdit, WinUI3.Form, FMX.SearchBox, System.Math.Vectors,
  System.ImageList, FMX.ImgList, NodeEditor.LegendItem,
  FMX.NodeEditor.Executor.Runtime, System.Actions, FMX.ActnList,
  NodeEditor.Inspector.Item.Float, NodeEditor.Inspector.Item.Color,
  NodeEditor.Inspector.Item, NodeEditor.Inspector.Item.Bitmap,
  NodeEditor.Inspector.Item.Text, NodeEditor.Inspector.Item.Int,
  NodeEditor.Inspector.Item.Bool, NodeEditor.Inspector.Item.Memo;

type
  {$SCOPEDENUMS ON}
  TLogKind = (None, Info, Warn, Error, Succ);

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
    ButtonColNavi: TButton;
    Panel3: TPanel;
    PanelEditor: TPanel;
    LayoutTransform: TLayout;
    Layout12: TLayout;
    PathLabel8: TPathLabel;
    Label11: TLabel;
    ButtonColTransform: TButton;
    Panel7: TPanel;
    Layout18: TLayout;
    SpinBoxNodeX: TSpinBox;
    Label3: TLabel;
    SpinBoxNodeY: TSpinBox;
    Label5: TLabel;
    Layout19: TLayout;
    LayoutNodeInfo: TLayout;
    Layout6: TLayout;
    PathLabel9: TPathLabel;
    LabelNodeType: TLabel;
    ButtonNodeInfo: TButton;
    Panel8: TPanel;
    Layout4: TLayout;
    EditNodeTitle: TEdit;
    CheckBoxNodeCollapsed: TCheckBox;
    ComboColorBoxNodeHeadColor: TComboColorBox;
    Label9: TLabel;
    LayoutNodeData: TLayout;
    Layout20: TLayout;
    PathLabel11: TPathLabel;
    Label7: TLabel;
    ButtonNodeData: TButton;
    Panel10: TPanel;
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
    LayoutHead: TLayout;
    LayoutCaption: TLayout;
    ButtonSettings: TButton;
    ButtonWinMin: TButton;
    ButtonWinMax: TButton;
    ButtonWinClose: TButton;
    LabelTitle: TLabel;
    LayoutHeadIcon: TLayout;
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
    MenuItemGraph: TMenuItem;
    MenuItemGraphValidate: TMenuItem;
    MenuItemJSONLoad: TMenuItem;
    MenuItemJSONSave: TMenuItem;
    LayoutHeadZoom: TLayout;
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
    ImageListDummy: TImageList;
    ButtonUndo: TButton;
    ButtonRedo: TButton;
    PathLabel26: TPathLabel;
    PathLabel28: TPathLabel;
    MenuItem4: TMenuItem;
    MenuItemDemoExec: TMenuItem;
    LayoutDebug: TLayout;
    ButtonRun: TButton;
    PathLabel22: TPathLabel;
    ButtonDebugToggleBreak: TButton;
    PathLabel30: TPathLabel;
    ButtonDebugContinue: TButton;
    PathLabel31: TPathLabel;
    ButtonDebugStepOver: TButton;
    PathLabel32: TPathLabel;
    ButtonDebugStepInto: TButton;
    PathLabel33: TPathLabel;
    ButtonDebugStop: TButton;
    PathLabel34: TPathLabel;
    ButtonDebugPause: TButton;
    PathLabel51: TPathLabel;
    ButtonDebugClearBreaks: TButton;
    PathLabel52: TPathLabel;
    Panel14: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    MenuItemRun: TMenuItem;
    MenuItemRunRun: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItemRunPause: TMenuItem;
    MenuItemRunReset: TMenuItem;
    MenuItemRunStepOver: TMenuItem;
    MenuItemRunTraceInto: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItemRunContinue: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItemRunBreakpoints: TMenuItem;
    MenuItemRunToggleBreakpoint: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItemRunClearBreakpoints: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItemGraphClear: TMenuItem;
    ExpanderMessages: TExpander;
    MemoLog: TMemo;
    LayoutOverlay: TLayout;
    ListBoxMessages: TListBox;
    ActionList1: TActionList;
    VertScrollBoxProps: TVertScrollBox;
    MenuItem20: TMenuItem;
    Panel18: TPanel;
    Layout25: TLayout;
    RadioButtonToolsHistory: TRadioButton;
    PathLabel36: TPathLabel;
    RadioButtonToolsAlign: TRadioButton;
    PathLabel37: TPathLabel;
    RadioButtonToolsLegend: TRadioButton;
    PathLabel38: TPathLabel;
    RadioButtonToolsLibrary: TRadioButton;
    PathLabel29: TPathLabel;
    TabControlTools: TTabControl;
    TabItemHistory: TTabItem;
    Layout26: TLayout;
    Layout27: TLayout;
    PathLabel27: TPathLabel;
    Label20: TLabel;
    Panel6: TPanel;
    ListBoxExecutedCommands: TListBox;
    ListBoxItem13: TListBoxItem;
    TabItemLegend: TTabItem;
    Layout14: TLayout;
    Layout22: TLayout;
    PathLabel35: TPathLabel;
    Label18: TLabel;
    Panel15: TPanel;
    VertScrollBox3: TVertScrollBox;
    FrameLegendItem1: TFrameLegendItem;
    FrameLegendItem2: TFrameLegendItem;
    FrameLegendItem3: TFrameLegendItem;
    FrameLegendItem4: TFrameLegendItem;
    FrameLegendItem5: TFrameLegendItem;
    FrameLegendItem6: TFrameLegendItem;
    FrameLegendItem7: TFrameLegendItem;
    Label35: TLabel;
    FrameLegendItem9: TFrameLegendItem;
    FrameLegendItem10: TFrameLegendItem;
    FrameLegendItem11: TFrameLegendItem;
    FrameLegendItem12: TFrameLegendItem;
    FrameLegendItem13: TFrameLegendItem;
    FrameLegendItem14: TFrameLegendItem;
    FrameLegendItem15: TFrameLegendItem;
    Label36: TLabel;
    Panel19: TPanel;
    Label37: TLabel;
    Panel20: TPanel;
    FrameLegendItem8: TFrameLegendItem;
    Button11: TButton;
    TabItemAlign: TTabItem;
    Layout29: TLayout;
    Layout30: TLayout;
    PathLabel39: TPathLabel;
    Label19: TLabel;
    Panel17: TPanel;
    VertScrollBox2: TVertScrollBox;
    ButtonAlignLeft: TButton;
    PathLabel40: TPathLabel;
    Label24: TLabel;
    ButtonAlignVert: TButton;
    PathLabel41: TPathLabel;
    Label29: TLabel;
    ButtonAlignHorz: TButton;
    PathLabel42: TPathLabel;
    Label28: TLabel;
    ButtonAlignBottom: TButton;
    PathLabel43: TPathLabel;
    Label27: TLabel;
    ButtonAlignRight: TButton;
    PathLabel44: TPathLabel;
    Label26: TLabel;
    ButtonAlignTop: TButton;
    PathLabel45: TPathLabel;
    Label25: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    ButtonMatchHeight: TButton;
    PathLabel46: TPathLabel;
    Label32: TLabel;
    ButtonMatchBoth: TButton;
    PathLabel47: TPathLabel;
    Label34: TLabel;
    Label23: TLabel;
    ButtonDistrHorz: TButton;
    PathLabel48: TPathLabel;
    Label30: TLabel;
    ButtonDistrVert: TButton;
    PathLabel49: TPathLabel;
    Label31: TLabel;
    ButtonMatchWidth: TButton;
    PathLabel50: TPathLabel;
    Label33: TLabel;
    TabItemToolsLibrary: TTabItem;
    Layout23: TLayout;
    Layout24: TLayout;
    PathLabel21: TPathLabel;
    Label17: TLabel;
    Panel16: TPanel;
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
    SearchBox1: TSearchBox;
    Layout28: TLayout;
    Layout9: TLayout;
    PathLabel20: TPathLabel;
    Label8: TLabel;
    Label10: TLabel;
    TabItemSettings: TTabItem;
    LayoutSettingsView: TLayout;
    Layout8: TLayout;
    PathLabel10: TPathLabel;
    Label1: TLabel;
    Button7: TButton;
    Panel9: TPanel;
    SpinBoxSize: TSpinBox;
    Label14: TLabel;
    PathLabel15: TPathLabel;
    CheckBoxShowFrameTime: TCheckBox;
    PathLabel16: TPathLabel;
    CheckBoxShowGrid: TCheckBox;
    PathLabel14: TPathLabel;
    CheckBoxShowAxes: TCheckBox;
    PathLabel17: TPathLabel;
    CheckBoxShowSnapGuides: TCheckBox;
    PathLabel18: TPathLabel;
    ComboBoxVisualLinkType: TComboBox;
    Label16: TLabel;
    PathLabel24: TPathLabel;
    CheckBoxLinkGradient: TCheckBox;
    PathLabel25: TPathLabel;
    CheckBoxLinksOverNodes: TCheckBox;
    PathLabel53: TPathLabel;
    LayoutSettingsBehaviour: TLayout;
    Layout16: TLayout;
    PathLabel2: TPathLabel;
    Label13: TLabel;
    Button2: TButton;
    Panel4: TPanel;
    CheckBoxSnapToGrid: TCheckBox;
    PathLabel12: TPathLabel;
    CheckBoxSnapToNodes: TCheckBox;
    PathLabel13: TPathLabel;
    CheckBoxLockedAll: TCheckBox;
    PathLabel19: TPathLabel;
    RadioButtonToolsSettings: TRadioButton;
    PathLabel3: TPathLabel;
    VertScrollBoxSettings: TVertScrollBox;
    Button12: TButton;
    Button10: TButton;
    Button9: TButton;
    Button13: TButton;
    LabelNoData: TLabel;
    CheckBoxPanAnimation: TCheckBox;
    PathLabel4: TPathLabel;
    TimerLoading: TTimer;
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
    procedure LayoutMobileMenuResize(Sender: TObject);
    procedure CornerButtonMenuAddClick(Sender: TObject);
    procedure RadioButtonMenuSettingsChange(Sender: TObject);
    procedure ButtonZoomResetClick(Sender: TObject);
    procedure ButtonZoomToSelectClick(Sender: TObject);
    procedure ComboBoxVisualLinkTypeChange(Sender: TObject);
    procedure ButtonCloseWorkHistoryClick(Sender: TObject);
    procedure ChangeToolsTab(Sender: TObject);
    procedure ButtonAlignLeftClick(Sender: TObject);
    procedure ButtonAlignTopClick(Sender: TObject);
    procedure ButtonAlignRightClick(Sender: TObject);
    procedure ButtonAlignBottomClick(Sender: TObject);
    procedure ButtonAlignHorzClick(Sender: TObject);
    procedure ButtonAlignVertClick(Sender: TObject);
    procedure ButtonDistrHorzClick(Sender: TObject);
    procedure ButtonDistrVertClick(Sender: TObject);
    procedure ButtonMatchHeightClick(Sender: TObject);
    procedure ButtonMatchWidthClick(Sender: TObject);
    procedure ButtonMatchBothClick(Sender: TObject);
    procedure ButtonUndoClick(Sender: TObject);
    procedure ButtonRedoClick(Sender: TObject);
    procedure MenuItemDemoExecClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonRunClick(Sender: TObject);
    procedure ButtonDebugToggleBreakClick(Sender: TObject);
    procedure ButtonDebugContinueClick(Sender: TObject);
    procedure ButtonDebugStepOverClick(Sender: TObject);
    procedure ButtonDebugStepIntoClick(Sender: TObject);
    procedure ButtonDebugStopClick(Sender: TObject);
    procedure ButtonDebugPauseClick(Sender: TObject);
    procedure ButtonDebugClearBreaksClick(Sender: TObject);
    procedure MenuItemGraphClearClick(Sender: TObject);
    procedure ButtonColTransformClick(Sender: TObject);
    procedure ButtonNodeInfoClick(Sender: TObject);
    procedure ButtonNodeDataClick(Sender: TObject);
    procedure ButtonColNaviClick(Sender: TObject);
    procedure TimerLoadingTimer(Sender: TObject);
  protected
    procedure PaintRects(const UpdateRects: array of TRectF); override;
  private
    FEditor: TNodeEditor;
    FJsonNodeEditor: TJsonNodeEditor;

    FDidInitialFrame: Boolean;
    FNodeUpdating: Boolean;
    FAppendSourcePinId: string;
    FAppendPosition: TPointF;

    procedure BuildEditorArea;
    procedure RegisterCustomNodes;

    { Event handlers — editor }
    procedure OnSelectionChanged(Sender: TObject);
    procedure OnNodeChanged(Sender: TObject; ANode: TCustomNode);

    { Helpers }
    procedure UpdateStatus;
    procedure RefreshFromSelection;
    procedure ClearAllSections;
    procedure OnUpdatedStatus(Sender: TObject);
    procedure FOnEditorPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure UpdateNodeRegistry;
    procedure FOnItemOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure OnHistoryChanged(Sender: TObject);
    procedure OnEditorExecutionStateChanged(Sender: TObject);
    procedure OnEditorExecutionNodeChanged(Sender: TObject; ANode: TExecutableNode);
    procedure OnEditorExecutionFinished(Sender: TObject; Success: boolean; const ErrorMessage: string);
    procedure OnEditorCompatibleNodeRequest(Sender: TObject; ASourcePin: TNodePin; const Position: TPointF);
    function GetNodeRuntimeInfo(ANode: TExecutableNode): string;
    procedure InitDemoGraphExec;
    procedure FindNode(Position: TPointF; TargetPinType: TNodeValueKind);
  protected
    OverTheme: integer;
    OverAccentColor: TAlphaColor;
    procedure MobileMode;
    procedure DoOnSettingChange; override;
    procedure Log(const Text: string; Kind: TLogKind);
    procedure LogClear;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.Math, System.JSON, System.Messaging, WinUI3.Dialogs,
  FMX.NodeEditor.Node.Graphic, FMX.NodeEditor.Node.Engineering,
  FMX.NodeEditor.Form.Search, FMX.NodeEditor.Node.JSON, System.Threading,
  FMX.NodeEditor.Node.ControlFlow, WinUI3.Style, System.IOUtils,
  NodeEditor.Frame.Progress;

{$R *.fmx}

{ TFormMain }

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FEditor) and FEditor.IsExecutionRunning then
  begin
    if TWinUIDialog.Show(Self, 'Warning', 'Execution is running. Stop it?', ['Yes', 'No', 'Cancel'], 2, 2, True) = 0 then
      FEditor.StopExecution
    else
      CanClose := False;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  OverAccentColor := SystemAccentColor;
  BeginUpdate;
  ComboColorBoxAccentColor.Color := OverAccentColor;
  EndUpdate;
  OverTheme := 2;
  SetSystemWindowControls(ButtonWinClose, ButtonWinMax, ButtonWinMin);
  CaptionControls := [LayoutCaption, LayoutHead];
  OffsetControls := [LayoutHead];
  TitleControls := [LabelTitle];
  IconControl := ImageIcon;
  {$IFDEF MSWINDOWS}
  HideTitleBar := True;
  {$ELSE}
  HideTitleBar := False;
  LayoutCaption.Visible := False;
  LabelTitle.Visible := False;
  LayoutHeadIcon.Visible := False;
  {$ENDIF}
  //
  RadioButtonToolsLibrary.IsChecked := False;
  RadioButtonToolsLibrary.IsChecked := True;
  LogClear;
  //
  ClearAllSections;

  BuildEditorArea;
  RegisterCustomNodes;
  UpdateNodeRegistry;

  LayoutMobileMenu.Visible := False;
  LayoutZoomMobile.Visible := False;
  PanelMobileOverlay.Visible := False;
  //
  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  MobileMode;
  {$ENDIF}
  //
  InitDemoGraphExec;
  UpdateStatus;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FEditor.OnPaint := nil;

  FEditor.OnSelectionChanged := nil;
  FEditor.OnNodeChanged := nil;
  FEditor.OnUpdatedStatus := nil;

  FEditor.OnExecutionStateChanged := nil;
  FEditor.OnExecutionNodeChanged := nil;
  FEditor.OnExecutionFinished := nil;

  FEditor.Controller.OnChanged := nil;
end;

procedure TFormMain.MobileMode;
begin
  HideTitleBar := False;
  PanelEditor.StyleLookup := 'Panelstyle_background';
  LayoutZoomMobile.Visible := True;
  LayoutLeft.Visible := False;
  LayoutRight.Visible := False;
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
  FEditor.Graph.Registry.SortByCategory;

  ListBoxRegistry.BeginUpdate;
  try
    ListBoxRegistry.Clear;
    ListBoxRegistry.HitTest := False;
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

function TFormMain.GetNodeRuntimeInfo(ANode: TExecutableNode): string;
begin
  Result := ANode.Title;

  if (ANode = nil) or (FEditor = nil) or (FEditor.Debugger = nil) then
    Exit;

  with FEditor.ExecutionContext do
  begin
    if ANode is TForLoopNode then
    begin
      var Idx := NodeValueToIntDef(GetVariableValue('last_for_index_' + ANode.Id), -1);
      if Idx >= 0 then
        Result := ANode.Title + ' [i=' + IntToStr(Idx) + ']';
    end
    else if ANode is TIsPrimeFlagNode then
    begin
      var Idx := NodeValueToIntDef(GetVariableValue('last_prime_check_index'), -1);
      var B := GetVariableBool('last_prime_check_value', False);
      Result := Format('%s [index=%d, isPrime=%s]', [ANode.Title, Idx, BoolToStr(B, True)]);
    end
    else if ANode is TSetPrimeFlagNode then
    begin
      var Idx := NodeValueToIntDef(GetVariableValue('last_set_prime_index'), -1);
      var B := GetVariableBool('last_set_prime_value', False);
      Result := Format('%s [index=%d, value=%s]', [ANode.Title, Idx, BoolToStr(B, True)]);
    end
    else if ANode is TCollectPrimeNode then
    begin
      var Idx := NodeValueToIntDef(GetVariableValue('last_collected_prime'), -1);
      var S := GetVariableStr('primes', '');
      Result := Format('%s [prime=%d, list=%s]', [ANode.Title, Idx, S]);
    end
    else if ANode is TBranchNode then
    begin
      var B := GetVariableBool('BranchResult_' + ANode.Id, False);
      Result := Format('%s [condition=%s]', [ANode.Title, BoolToStr(B, True)]);
    end
    else if ANode is TPrintNode then
    begin
      var Str := GetVariableStr('Print_' + ANode.Id, '');
      Result := Format('%s: %s', [ANode.Title, Str]);
    end;
  end;
end;

procedure TFormMain.Button309Click(Sender: TObject);
begin
  Inc(OverTheme);
  if OverTheme > 2 then
    OverTheme := 1;
  DoOnSettingChange;
end;

procedure TFormMain.ButtonColNaviClick(Sender: TObject);
begin
  if LayoutNavigator.Height = 45 then
  begin
    LayoutNavigator.Height := LayoutNavigator.Tag;
    ButtonColNavi.StylesData['icon.RotationAngle'] := 0;
  end
  else
  begin
    LayoutNavigator.Height := 45;
    ButtonColNavi.StylesData['icon.RotationAngle'] := 180;
  end;
end;

procedure TFormMain.ButtonColTransformClick(Sender: TObject);
begin
  if LayoutTransform.Height = 45 then
  begin
    LayoutTransform.Height := LayoutTransform.Tag;
    ButtonColTransform.StylesData['icon.RotationAngle'] := 0;
  end
  else
  begin
    LayoutTransform.Height := 45;
    ButtonColTransform.StylesData['icon.RotationAngle'] := 180;
  end;
end;

procedure TFormMain.ButtonAlignBottomClick(Sender: TObject);
begin
  FEditor.Controller.AlignSelectedNodes(TAlignMode.Bottom);
end;

procedure TFormMain.ButtonAlignHorzClick(Sender: TObject);
begin

  FEditor.Controller.AlignSelectedNodes(TAlignMode.CenterHorizontal);
end;

procedure TFormMain.ButtonAlignLeftClick(Sender: TObject);
begin
  FEditor.Controller.AlignSelectedNodes(TAlignMode.Left);
end;

procedure TFormMain.ButtonAlignRightClick(Sender: TObject);
begin
  FEditor.Controller.AlignSelectedNodes(TAlignMode.Right);
end;

procedure TFormMain.ButtonAlignTopClick(Sender: TObject);
begin
  FEditor.Controller.AlignSelectedNodes(TAlignMode.Top);
end;

procedure TFormMain.ButtonAlignVertClick(Sender: TObject);
begin
  FEditor.Controller.AlignSelectedNodes(TAlignMode.CenterVertical);
end;

procedure TFormMain.ButtonCloseWorkHistoryClick(Sender: TObject);
begin
  PanelMobileOverlay.Visible := False;
end;

procedure TFormMain.ButtonDebugClearBreaksClick(Sender: TObject);
begin
  if Assigned(FEditor) then
  begin
    FEditor.ClearAllBreakpoints;
    Log('All breakpoints cleared', TLogKind.Info);
  end;
end;

procedure TFormMain.ButtonDebugContinueClick(Sender: TObject);
begin
  if Assigned(FEditor) then
    FEditor.ContinueExecution;
end;

procedure TFormMain.ButtonDebugPauseClick(Sender: TObject);
begin
  if Assigned(FEditor) then
  begin
    FEditor.PauseExecution;
    Log('Execution paused', TLogKind.Info);
  end;
end;

procedure TFormMain.ButtonDebugStepIntoClick(Sender: TObject);
begin
  if Assigned(FEditor) then
    FEditor.StepIntoExecution;
end;

procedure TFormMain.ButtonDebugStepOverClick(Sender: TObject);
begin
  if Assigned(FEditor) then
    FEditor.StepOverExecution;
end;

procedure TFormMain.ButtonDebugStopClick(Sender: TObject);
begin
  if Assigned(FEditor) then
  begin
    FEditor.StopExecution;
    Log('Execution stopped', TLogKind.Warn);
    FEditor.DebugViewMode := False;
    FEditor.CurrentDebugNode := nil;
  end;
end;

procedure TFormMain.ButtonDebugToggleBreakClick(Sender: TObject);
begin
  if Assigned(FEditor) and (FEditor.SelectedNodeCount > 0) then
  begin
    var Node := FEditor.GetSelectedNode(0);
    FEditor.ToggleBreakpoint(Node);
    Log('Breakpoint toggled on node: ' + Node.Title, TLogKind.Info);
  end;
end;

procedure TFormMain.ButtonDistrHorzClick(Sender: TObject);
begin
  FEditor.Controller.DistributeSelectedNodes(TDistributeMode.Horizontal);
end;

procedure TFormMain.ButtonDistrVertClick(Sender: TObject);
begin
  FEditor.Controller.DistributeSelectedNodes(TDistributeMode.Vertical);
end;

procedure TFormMain.ButtonMatchBothClick(Sender: TObject);
begin
  FEditor.Controller.MakeSelectedNodesSameSize(TMatchSizeMode.Both);
end;

procedure TFormMain.ButtonMatchHeightClick(Sender: TObject);
begin
  FEditor.Controller.MakeSelectedNodesSameSize(TMatchSizeMode.Height);
end;

procedure TFormMain.ButtonMatchWidthClick(Sender: TObject);
begin
  FEditor.Controller.MakeSelectedNodesSameSize(TMatchSizeMode.Width);
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

  for var Control in VertScrollBoxProps.Content.Controls do
    if Control is TFrameInspectorItem then
    begin
      var Item := TFrameInspectorItem(Control);
      if not Item.IsChanged then
        Continue;
      var V := N.GetValue(Item.PropName);
      if not Assigned(V) then
        Continue;
      case V.Kind of
        TNodeValueKind.Float:
          V.FloatValue := Item.Value.AsExtended;
        TNodeValueKind.Integer:
          V.IntegerValue := Item.Value.AsInteger;
        TNodeValueKind.string:
          V.StringValue := Item.Value.AsString;
        TNodeValueKind.Boolean:
          V.BooleanValue := Item.Value.AsBoolean;
        TNodeValueKind.JSON:
          V.JSONValue := Item.Value.AsString;
        TNodeValueKind.Bitmap:
          begin
            var BO := TBitmapObject.Create;
            V.BitmapValue := BO;
            var BMP := TBitmap.Create;
            BO.SetBitmap(BMP);
            BMP.Assign(Item.Value.AsType<TBitmap>);
          end;
        TNodeValueKind.Color:
          V.ColorValue := Item.Value.AsType<TAlphaColor>;
        TNodeValueKind.Point:
          V.PointValue := Item.Value.AsType<TPointF>;
      end;
    end;
  N.UpdateNodeData;
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

procedure TFormMain.ButtonNodeDataClick(Sender: TObject);
begin
  if LayoutNodeData.Height = 45 then
  begin
    LayoutNodeData.Height := LayoutNodeData.Tag;
    ButtonNodeData.StylesData['icon.RotationAngle'] := 0;
  end
  else
  begin
    LayoutNodeData.Height := 45;
    ButtonNodeData.StylesData['icon.RotationAngle'] := 180;
  end;
end;

procedure TFormMain.ButtonNodeInfoClick(Sender: TObject);
begin
  if LayoutNodeInfo.Height = 45 then
  begin
    LayoutNodeInfo.Height := LayoutNodeInfo.Tag;
    ButtonNodeInfo.StylesData['icon.RotationAngle'] := 0;
  end
  else
  begin
    LayoutNodeInfo.Height := 45;
    ButtonNodeInfo.StylesData['icon.RotationAngle'] := 180;
  end;
  LayoutNodeInfo.Repaint;
end;

procedure TFormMain.ButtonNodeRevertClick(Sender: TObject);
begin
  RefreshFromSelection;
end;

procedure TFormMain.ButtonRedoClick(Sender: TObject);
begin
  FEditor.Redo;
end;

procedure TFormMain.ButtonRunClick(Sender: TObject);
begin
  if FEditor.IsExecutionRunning then
    Exit;
  LogClear;
  if FEditor.ExecuteGraph then
  begin
    Log('Graph execution started...', TLogKind.Info);
    ExpanderMessages.IsExpanded := True;
    FEditor.DebugViewMode := True;
  end
  else
    Log('Failed to start: ' + FEditor.GetLastRuntimeError, TLogKind.Error);
end;

procedure TFormMain.ButtonSettingsClick(Sender: TObject);
begin
  PopupTheme.PlacementTarget := ButtonSettings;
  PopupTheme.Popup;
end;

procedure TFormMain.ButtonUndoClick(Sender: TObject);
begin
  FEditor.Undo;
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
  FEditor.SetZoom(FEditor.Zoom + 0.25, FEditor.LocalRect.CenterPoint);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomOutClick(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(FEditor.Zoom - 0.25, FEditor.LocalRect.CenterPoint);
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
  FEditor.SetZoom(1, FEditor.LocalRect.CenterPoint);
  UpdateStatus;
end;

procedure TFormMain.ButtonZoomTo200Click(Sender: TObject);
begin
  PopupZoom.IsOpen := False;
  FEditor.SetZoom(2, FEditor.LocalRect.CenterPoint);
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
  FEditor.DebugMode := True;              // Enable debug visualization
  FEditor.DebugViewMode := False;
  FEditor.OnPaint := FOnEditorPaint;

  FEditor.OnSelectionChanged := OnSelectionChanged;
  FEditor.OnNodeChanged := OnNodeChanged;
  FEditor.OnUpdatedStatus := OnUpdatedStatus;
  FEditor.OnCompatibleNodeRequest := OnEditorCompatibleNodeRequest;

  FEditor.OnExecutionStateChanged := OnEditorExecutionStateChanged;
  FEditor.OnExecutionNodeChanged := OnEditorExecutionNodeChanged;
  FEditor.OnExecutionFinished := OnEditorExecutionFinished;

  FEditor.OnGraphChanged := OnHistoryChanged;

  FJsonNodeEditor := TJsonNodeEditor.Create(FEditor);

  CheckBoxSnapToGridChange(nil);
end;

procedure TFormMain.RegisterCustomNodes;
begin
  RegisterEngineeringNodes(FEditor.Graph.Registry);
  RegisterControlFlowNodes(FEditor.Graph.Registry);
  RegisterGraphicNodes(FEditor.Graph.Registry);
  RegisterJSONValueNodes(FEditor.Graph.Registry);
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

procedure TFormMain.TimerLoadingTimer(Sender: TObject);
begin
  if Assigned(FrameProgress) then
  begin
    FrameProgress.ProgressBarValue.Value := FJsonNodeEditor.GetProgress * 100;
    FrameProgress.LabelMsg.Text := FJsonNodeEditor.GetProgressMsg;
  end;
end;

procedure TFormMain.InitDemoGraphExec;
var
  Seq: TSequence3Node;
  NConst, TwoConst: TIntConstNode;
  BoolTrue, BoolFalse: TBoolConstNode;
  PrimesNameConst, EmptyStrConst: TStringConstNode;
  ClearPrimes: TSetVariableNode;
  InitLoop, OuterLoop, InnerLoop, CollectLoop: TForLoopNode;
  SetPrimeInit: TSetPrimeFlagNode;
  ReadPrimeOuter, ReadPrimeCollect: TIsPrimeFlagNode;
  OuterBranch, CollectBranch: TBranchNode;
  MulP2: TMulExecNode;
  SetComposite: TSetPrimeFlagNode;
  CollectPrime: TCollectPrimeNode;
  Comment: TCommentNode;
begin
  LogClear;
  FEditor.BeginUpdate;
  try
    FEditor.Clear;

    NConst := TIntConstNode.Create('N = 50', 80, 80);
    NConst.SetupPins;
    NConst.FindValue('value').IntegerValue := 50;
    FEditor.AddNode(NConst);

    TwoConst := TIntConstNode.Create('2', 80, 200);
    TwoConst.SetupPins;
    TwoConst.FindValue('value').IntegerValue := 2;
    FEditor.AddNode(TwoConst);

    BoolTrue := TBoolConstNode.Create('True', 80, 320);
    BoolTrue.SetupPins;
    BoolTrue.FindValue('value').BooleanValue := True;
    FEditor.AddNode(BoolTrue);

    BoolFalse := TBoolConstNode.Create('False', 80, 440);
    BoolFalse.SetupPins;
    BoolFalse.FindValue('value').BooleanValue := False;
    FEditor.AddNode(BoolFalse);

    PrimesNameConst := TStringConstNode.Create('"primes"', 80, 560);
    PrimesNameConst.SetupPins;
    PrimesNameConst.FindValue('value').StringValue := 'primes';
    FEditor.AddNode(PrimesNameConst);

    EmptyStrConst := TStringConstNode.Create('""', 80, 680);
    EmptyStrConst.SetupPins;
    EmptyStrConst.FindValue('value').StringValue := '';
    FEditor.AddNode(EmptyStrConst);

    Seq := TSequence3Node.Create('Start / Main Sequence', 320, 80);
    Seq.SetupPins;
    while Seq.StepCount < 3 do
      Seq.AddStep;
    FEditor.AddNode(Seq);

    ClearPrimes := TSetVariableNode.Create('Set primes = ""', 600, 80);
    ClearPrimes.SetupPins;
    FEditor.AddNode(ClearPrimes);

    InitLoop := TForLoopNode.Create('Init i = 2..N', 600, 260);
    InitLoop.SetupPins;
    FEditor.AddNode(InitLoop);

    SetPrimeInit := TSetPrimeFlagNode.Create('Set prime_i = True', 880, 260);
    SetPrimeInit.SetupPins;
    FEditor.AddNode(SetPrimeInit);

    OuterLoop := TForLoopNode.Create('For p = 2..N', 600, 480);
    OuterLoop.SetupPins;
    FEditor.AddNode(OuterLoop);

    ReadPrimeOuter := TIsPrimeFlagNode.Create('Read prime_p', 880, 480);
    ReadPrimeOuter.SetupPins;
    FEditor.AddNode(ReadPrimeOuter);

    OuterBranch := TBranchNode.Create('If prime_p', 1140, 480);
    OuterBranch.SetupPins;
    FEditor.AddNode(OuterBranch);

    MulP2 := TMulExecNode.Create('p * 2', 1400, 440);
    MulP2.SetupPins;
    FEditor.AddNode(MulP2);

    InnerLoop := TForLoopNode.Create('For m = p*2 .. N step p', 1680, 440);
    InnerLoop.SetupPins;
    FEditor.AddNode(InnerLoop);

    SetComposite := TSetPrimeFlagNode.Create('Set prime_m = False', 1960, 440);
    SetComposite.SetupPins;
    FEditor.AddNode(SetComposite);

    CollectLoop := TForLoopNode.Create('Collect p = 2..N', 600, 760);
    CollectLoop.SetupPins;
    FEditor.AddNode(CollectLoop);

    ReadPrimeCollect := TIsPrimeFlagNode.Create('Read prime_p', 880, 760);
    ReadPrimeCollect.SetupPins;
    FEditor.AddNode(ReadPrimeCollect);

    CollectBranch := TBranchNode.Create('If prime_p', 1140, 760);
    CollectBranch.SetupPins;
    FEditor.AddNode(CollectBranch);

    CollectPrime := TCollectPrimeNode.Create('Collect prime', 1400, 760);
    CollectPrime.SetupPins;
    FEditor.AddNode(CollectPrime);

    Comment := TCommentNode.Create('Runtime-compatible sieve demo', 20, 10);
    Comment.CommentText := '''
      Full exec-flow:
      1) Clearing the primes row
      2) Initialize prime_i=True for i=2..N
      3) External loop by p
      4) If prime_p=True, then mark multiples
      5) Collecting the result in the primes variable
      ''';
    Comment.Width := 520;
    Comment.Height := 170;
    FEditor.AddNode(Comment);

    // DATA
    FEditor.Graph.AddLink(TNodeLink.Create(PrimesNameConst.GetOutput(0), ClearPrimes.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(EmptyStrConst.GetOutput(0), ClearPrimes.GetInput(2)));

    FEditor.Graph.AddLink(TNodeLink.Create(TwoConst.GetOutput(0), InitLoop.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(NConst.GetOutput(0), InitLoop.GetInput(2)));
    FEditor.Graph.AddLink(TNodeLink.Create(InitLoop.GetOutput(2), SetPrimeInit.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(BoolTrue.GetOutput(0), SetPrimeInit.GetInput(2)));

    FEditor.Graph.AddLink(TNodeLink.Create(TwoConst.GetOutput(0), OuterLoop.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(NConst.GetOutput(0), OuterLoop.GetInput(2)));
    FEditor.Graph.AddLink(TNodeLink.Create(OuterLoop.GetOutput(2), ReadPrimeOuter.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(ReadPrimeOuter.GetOutput(1), OuterBranch.GetInput(1)));

    FEditor.Graph.AddLink(TNodeLink.Create(OuterLoop.GetOutput(2), MulP2.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(TwoConst.GetOutput(0), MulP2.GetInput(2)));

    FEditor.Graph.AddLink(TNodeLink.Create(MulP2.GetOutput(1), InnerLoop.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(NConst.GetOutput(0), InnerLoop.GetInput(2)));
    FEditor.Graph.AddLink(TNodeLink.Create(OuterLoop.GetOutput(2), InnerLoop.GetInput(3)));

    FEditor.Graph.AddLink(TNodeLink.Create(InnerLoop.GetOutput(2), SetComposite.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(BoolFalse.GetOutput(0), SetComposite.GetInput(2)));

    FEditor.Graph.AddLink(TNodeLink.Create(TwoConst.GetOutput(0), CollectLoop.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(NConst.GetOutput(0), CollectLoop.GetInput(2)));
    FEditor.Graph.AddLink(TNodeLink.Create(CollectLoop.GetOutput(2), ReadPrimeCollect.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(ReadPrimeCollect.GetOutput(1), CollectBranch.GetInput(1)));
    FEditor.Graph.AddLink(TNodeLink.Create(CollectLoop.GetOutput(2), CollectPrime.GetInput(1)));

    // EXEC
    FEditor.Graph.AddLink(TNodeLink.Create(Seq.GetOutput(0), ClearPrimes.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(Seq.GetOutput(1), InitLoop.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(Seq.GetOutput(2), OuterLoop.GetInput(0)));

    FEditor.Graph.AddLink(TNodeLink.Create(InitLoop.GetOutput(0), SetPrimeInit.GetInput(0)));

    FEditor.Graph.AddLink(TNodeLink.Create(OuterLoop.GetOutput(0), ReadPrimeOuter.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(ReadPrimeOuter.GetOutput(0), OuterBranch.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(OuterBranch.GetOutput(0), MulP2.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(MulP2.GetOutput(0), InnerLoop.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(InnerLoop.GetOutput(0), SetComposite.GetInput(0)));

    FEditor.Graph.AddLink(TNodeLink.Create(OuterLoop.GetOutput(1), CollectLoop.GetInput(0)));

    FEditor.Graph.AddLink(TNodeLink.Create(CollectLoop.GetOutput(0), ReadPrimeCollect.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(ReadPrimeCollect.GetOutput(0), CollectBranch.GetInput(0)));
    FEditor.Graph.AddLink(TNodeLink.Create(CollectBranch.GetOutput(0), CollectPrime.GetInput(0)));

    FEditor.SelectNode(Seq, False);
  finally
    FEditor.EndUpdate;
  end;

  FEditor.Fit;
  Log('The complete exec graph of the sieve is loaded.', TLogKind.Succ);
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

procedure TFormMain.Log(const Text: string; Kind: TLogKind);
begin
  var TimeStamp := FormatDateTime('hh:nn:ss', Now);
  LabelStat1.Text := Text;                    // старый вывод в статусбар

  var Item := TListBoxItem.Create(ListBoxMessages);
  Item.StyleLookup := 'listboxitemrightdetail';
  Item.Text := Text;
  Item.ItemData.Detail := TimeStamp;
  case Kind of
    TLogKind.None:
      begin
        //Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
        //Item.FontColor := TAlphaColors.White;
      end;
    TLogKind.Info:
      begin
        Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
        Item.FontColor := $FF008DEB;
      end;
    TLogKind.Warn:
      begin
        Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
        Item.FontColor := $FFDE7E00;
      end;
    TLogKind.Error:
      begin
        Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
        Item.FontColor := $FFFF4117;
      end;
    TLogKind.Succ:
      begin
        Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
        Item.FontColor := $FF00B20F;
      end;
  end;
  ListBoxMessages.AddObject(Item);
  ListBoxMessages.ItemIndex := ListBoxMessages.Count - 1;

  //MemoLog.Lines.Add(Format('[%s] %s', [TimeStamp, Text]));
  // Автоскролл вниз
  //MemoLog.ScrollBy(0, MemoLog.ViewportSize.Height, True);
end;

procedure TFormMain.LogClear;
begin
  MemoLog.Lines.Clear;
  ListBoxMessages.Clear;
end;

procedure TFormMain.MenuItemDemoExecClick(Sender: TObject);
begin
  InitDemoGraphExec;
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
  FEditor.SendNodeToBack(nil);
  LabelStat5.Text := 'Sent to back';
end;

procedure TFormMain.MenuItemEditToFrontClick(Sender: TObject);
begin
  if FEditor.SelectedNodeCount = 0 then
    Exit;
  FEditor.BringNodeToFront(nil);
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

procedure TFormMain.MenuItemGraphClearClick(Sender: TObject);
begin
  FEditor.Clear;
end;

procedure TFormMain.MenuItemGraphValidateClick(Sender: TObject);
begin
  var Msgs := TStringList.Create;
  try
    if FEditor.ValidateGraphToStrings(Msgs) then
      ShowUIMessage(Self, 'Graph Validate', Msgs.Text)
    else
      ShowUIMessage(Self, 'Graph Validate', Msgs.Text);
  finally
    Msgs.Free;
  end;
end;

procedure TFormMain.MenuItemJSONLoadClick(Sender: TObject);
begin
  if OpenDialogJSON.Execute then
  begin
    var FileName := OpenDialogJSON.FileName;
    FrameProgress := TFrameProgress.Create(Self);
    try
      var Proc: TProc<Integer> :=
        procedure(Res: Integer)
        begin
          if Res <> MR_AUTOCLOSE then
          begin
            FrameProgress.Free;
            FrameProgress := nil;
          end;
        end;
      TWinUIDialog.ShowInline(Self, Proc, 'Loading...', FrameProgress, [], -1, -1, False);
    except
      FrameProgress.Free;
      FrameProgress := nil;
    end;
    TimerLoading.Enabled := True;
    TTask.Run(
      procedure
      begin
        try
          FJsonNodeEditor.LoadFromFile(FileName);
        finally
          TThread.ForceQueue(nil,
            procedure
            begin
              TimerLoading.Enabled := False;
              FrameProgress.Free;
              FrameProgress := nil;
            end);
        end;
      end);
  end;
end;

procedure TFormMain.MenuItemJSONSaveClick(Sender: TObject);
begin
  if SaveDialogJSON.Execute then
    FJsonNodeEditor.SaveToFile(SaveDialogJSON.FileName);
end;

procedure TFormMain.ChangeToolsTab(Sender: TObject);
begin
  if RadioButtonToolsHistory.IsChecked then
    TabControlTools.ActiveTab := TabItemHistory
  else if RadioButtonToolsLegend.IsChecked then
    TabControlTools.ActiveTab := TabItemLegend
  else if RadioButtonToolsAlign.IsChecked then
    TabControlTools.ActiveTab := TabItemAlign
  else if RadioButtonToolsLibrary.IsChecked then
    TabControlTools.ActiveTab := TabItemToolsLibrary
  else if RadioButtonToolsSettings.IsChecked then
    TabControlTools.ActiveTab := TabItemSettings;
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
  FEditor.LinkGradient := CheckBoxLinkGradient.IsChecked;
  FEditor.LinksOverNodes := CheckBoxLinksOverNodes.IsChecked;
  FEditor.PanAnimation := CheckBoxPanAnimation.IsChecked;
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
    LabelNoData.Parent := nil;
    while VertScrollBoxProps.Content.ControlsCount > 0 do
      VertScrollBoxProps.Content.Controls[0].Free;
    LabelNoData.Parent := VertScrollBoxProps;
    LayoutNodeData.Height := VertScrollBoxProps.ContentBounds.Height + 50;
    LabelNodeType.Text := 'Node (no selection)';
    EditNodeTitle.Text := '';
    SpinBoxNodeX.Value := 0;
    SpinBoxNodeY.Value := 0;
    SpinBoxNodeWidth.Value := 0;
    SpinBoxNodeHeight.Value := 0;
    ComboColorBoxNodeHeadColor.Color := TAlphaColors.Null;
    CheckBoxNodeCollapsed.IsChecked := False;
    MemoNodeComment.Text := '';
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
begin
  UpdateStatus;
  if (FEditor = nil) or (FEditor.SelectedNodeCount <> 1) then
  begin
    ClearAllSections;
    if FEditor.SelectedNodeCount > 1 then
      LabelNodeType.Text := 'Node (multiple)';
    Exit;
  end;

  var N := FEditor.GetSelectedNode(0);
  if N = nil then
  begin
    ClearAllSections;
    Exit;
  end;

  FNodeUpdating := True;
  try
    ClearAllSections;
    LabelNoData.Parent := nil;

    // Info
    LabelNodeType.Text := Format('Node (%s)', [N.NodeType]);

    // Basic
    EditNodeTitle.Text := N.Title;
    SpinBoxNodeX.Value := N.X;
    SpinBoxNodeY.Value := N.Y;
    SpinBoxNodeWidth.Value := N.Width;
    SpinBoxNodeHeight.Value := N.Height;

    // Visual
    ComboColorBoxNodeHeadColor.Color := N.HeaderColor;
    CheckBoxNodeCollapsed.IsChecked := N.Collapsed;

    // Comment
    MemoNodeComment.Text := N.CommentText;

    // Values
    if N.ValueCount > 0 then
    begin
      for var i := 0 to N.ValueCount - 1 do
      begin
        var V := N.GetValue(i);
        if V = nil then
          Continue;

        case V.Kind of
          TNodeValueKind.Float:
            begin
              var Frame := TFrameInspectorItemFloat.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              Frame.Value := V.FloatValue;
              if V.IsHaveMinMax then
              begin
                Frame.Min := V.Min;
                Frame.Max := V.Max;
              end;
              VertScrollBoxProps.AddObject(Frame);
            end;
          TNodeValueKind.Integer:
            begin
              var Frame := TFrameInspectorItemInt.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              Frame.Value := V.IntegerValue;
              if V.IsHaveMinMax then
              begin
                Frame.Min := V.Min;
                Frame.Max := V.Max;
              end;
              VertScrollBoxProps.AddObject(Frame);
            end;
          TNodeValueKind.string:
            begin
              var Frame := TFrameInspectorItemText.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              Frame.Value := V.StringValue;
              VertScrollBoxProps.AddObject(Frame);
            end;
          TNodeValueKind.Color:
            begin
              var Frame := TFrameInspectorItemColor.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              Frame.Value := V.ColorValue;
              VertScrollBoxProps.AddObject(Frame);
            end;
          TNodeValueKind.Boolean:
            begin
              var Frame := TFrameInspectorItemBool.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              Frame.Value := V.BooleanValue;
              VertScrollBoxProps.AddObject(Frame);
            end;
          TNodeValueKind.JSON:
            begin
              var Frame := TFrameInspectorItemMemo.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              Frame.Value := V.JSONValue;
              VertScrollBoxProps.AddObject(Frame);
            end;
          TNodeValueKind.Bitmap:
            begin
              var Frame := TFrameInspectorItemBitmap.Create(VertScrollBoxProps);
              Frame.Position.Y := 100000;
              Frame.Align := TAlignLayout.Top;
              Frame.PropName := V.Name;
              if Assigned(V.BitmapValue) and not V.BitmapValue.GetIsEmpty then
                Frame.Value := TValue.From<TBitmap>(V.BitmapValue.GetBitmap)
              else
                Frame.Value := TValue.From<TBitmap>(nil);
              VertScrollBoxProps.AddObject(Frame);
            end;
        end;
      end;
    end;

    if VertScrollBoxProps.Content.ControlsCount <= 0 then
      LabelNoData.Parent := VertScrollBoxProps;
    LayoutNodeData.Height := VertScrollBoxProps.ContentBounds.Height + 50;
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

procedure TFormMain.OnEditorCompatibleNodeRequest(Sender: TObject; ASourcePin: TNodePin; const Position: TPointF);
begin
  FAppendSourcePinId := ASourcePin.Id;
  FAppendPosition := Position;
  var LPinTypeId := ASourcePin.PinType.TypeId;

  TThread.ForceQueue(nil,
    procedure
    begin
      FindNode(FAppendPosition, LPinTypeId);
    end);
end;

procedure TFormMain.FindNode(Position: TPointF; TargetPinType: TNodeValueKind);
begin
  var Form := TFormNodeEditorSearch.CreateSearch(Self, FEditor.Graph.Registry);
  try
    Form.Left := Screen.MousePos.Round.X;// Round(EnsureRange(Position.X - Form.Width / 2, 0, Screen.Width - Form.Width));
    Form.Top := Screen.MousePos.Round.Y;// Round(EnsureRange(Position.Y - Form.Height / 2, 0, Screen.Height - Form.Height));
    //Form.FilterValue(TPinDirection.Input, TargetPinType);

    if (Form.ShowModal = mrOk) and (Form.SelectedNodeType <> '') then
    begin
      FEditor.Controller.CreateNodeForLinkPin(Form.SelectedNodeType, FAppendSourcePinId, FAppendPosition);
    end;
  finally
    Form.Free;
  end;
end;

procedure TFormMain.OnEditorExecutionFinished(Sender: TObject; Success: boolean; const ErrorMessage: string);
begin
  UpdateStatus;

  if Success then
  begin
    var S := '';
    if Assigned(FEditor.Debugger) and Assigned(FEditor.ExecutionContext) then
      S := FEditor.ExecutionContext.GetVariableStr('primes', '');

    if S <> '' then
      Log('Execution finished. Collected: ' + S, TLogKind.None)
    else
      Log('Execution finished successfully', TLogKind.Succ);
  end
  else
    Log('Failed: ' + ErrorMessage, TLogKind.Error);
  Log('Elapsed time: ' + FEditor.ExecutionLastTimeElapsed.ToString, TLogKind.None);
end;

procedure TFormMain.OnEditorExecutionNodeChanged(Sender: TObject; ANode: TExecutableNode);
begin
  UpdateStatus;
  if ANode <> nil then
    Log('Info: ' + GetNodeRuntimeInfo(ANode), TLogKind.None);
end;

procedure TFormMain.OnEditorExecutionStateChanged(Sender: TObject);
begin
  UpdateStatus;
end;

procedure TFormMain.OnHistoryChanged(Sender: TObject);
begin
  //UpdateStatus;
  var SelectedId := '';
  if Assigned(ListBoxExecutedCommands.Selected) then
    SelectedId := ListBoxExecutedCommands.Selected.TagString;

  ButtonUndo.Enabled := FEditor.Controller.CanUndo;
  ButtonRedo.Enabled := FEditor.Controller.CanRedo;

  ListBoxExecutedCommands.BeginUpdate;
  try
    ListBoxExecutedCommands.Clear;
    for var Item in FEditor.Graph.UndoStack do
    begin
      var ListItem := TListBoxItem.Create(ListBoxExecutedCommands);
      ListItem.Text := Item.Description;
      ListItem.TagString := Item.Id;
      ListItem.ItemData.Detail := FormatDateTime('hh:nn:ss', Item.TimeStamp);
      ListBoxExecutedCommands.InsertObject(0, ListItem);
    end;
    if ListBoxExecutedCommands.Count > 0 then
      ListBoxExecutedCommands.ListItems[0].StylesData['current.Visible'] := True;
    for var i := FEditor.Graph.RedoStack.Count - 1 downto 0 do
    begin
      var Item := FEditor.Graph.RedoStack[i];
      var ListItem := TListBoxItem.Create(ListBoxExecutedCommands);
      ListItem.Text := Item.Description;
      ListItem.TagString := Item.Id;
      ListItem.ItemData.Detail := FormatDateTime('hh:nn:ss', Item.TimeStamp);
      ListItem.Opacity := 0.5;
      ListBoxExecutedCommands.InsertObject(0, ListItem);
    end;
  finally
    ListBoxExecutedCommands.EndUpdate;
  end;

  if not SelectedId.IsEmpty then
    for var i := 0 to ListBoxExecutedCommands.Count - 1 do
      if ListBoxExecutedCommands.ListItems[i].TagString = SelectedId then
      begin
        ListBoxExecutedCommands.ListItems[i].IsSelected := True;
        Break;
      end;
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
    FEditor.GridColor := $22E0E0E0;
    FEditor.HighlightColor := $FFFFD740;
  end
  else
  begin
    // Set accent color for stylebook
    ChangeStyleBookColor(StyleBookWinUI3Light, OverAccentColor);
    StyleBook := StyleBookWinUI3Light;
    FEditor.GridColor := $222C2C2C;
    FEditor.HighlightColor := $FF857021;
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

  var IsRunning := FEditor.IsExecutionRunning;
  var IsPaused := FEditor.IsExecutionPaused;
                          {
  actRun.Enabled := not IsRunning or IsPaused;
  actPause.Enabled := IsRunning and not IsPaused;
  actStop.Enabled := IsRunning or IsPaused;
  actStepInto.Enabled := IsPaused;
  actStepOver.Enabled := IsPaused;
  actContinue.Enabled := IsPaused;

  actToggleBreakpoint.Enabled := FEditor.SelectedNodeCount > 0;
  actClearBreakpoints.Enabled := True; }
  LabelStat1.Text := if IsRunning then 'RUNNING' else if IsPaused then 'PAUSED' else 'STOPPED';

  LabelStat1.Text := SelStr;
  LabelStat2.Text := Format('Nodes: %d | Links: %d', [FEditor.Graph.Nodes.Count, FEditor.Graph.Links.Count]);
  LabelStat3.Text := Format('Zoom: %.0f%%', [FEditor.Zoom * 100]);
  ButtonZoom.Text := Format('%.0f%%', [FEditor.Zoom * 100]);
  LabelStat4.Text :=
    'Snap: ' + (if FEditor.SnapToGrid then 'ON' else 'OFF') +
    '  Grid: ' + IntToStr(FEditor.GridSize);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.

