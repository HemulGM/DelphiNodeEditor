unit FMX.NodeEditor;

interface

uses
  System.Classes, System.SysUtils, System.TimeSpan, FMX.Graphics, FMX.Controls,
  System.Math, System.Types, FMX.Menus, System.Diagnostics, FMX.Forms,
  System.UITypes, FMX.Types, System.Generics.Collections, FMX.NodeEditor.Node,
  FMX.StdCtrls, FMX.NodeEditor.Graph, FMX.NodeEditor.Types,
  FMX.NodeEditor.Controller, FMX.Ani, FMX.NodeEditor.VisualLink,
  FMX.InertialMovement, FMX.NodeEditor.Executor.Runtime,
  FMX.NodeEditor.Executor.Thread, FMX.NodeEditor.Debugger,
  FMX.NodeEditor.Debug.Intf;

type
  { Custom Draw Events }

  TNodeEditorDrawNodeEvent = procedure(Sender: TObject; Canvas: TCanvas; ANode: TCustomNode; const ARect: TRectF; Zoom: Double; OffsetX, OffsetY: Double; var AHandled: Boolean) of object;

  TNodeEditorDrawPinEvent = procedure(Sender: TObject; Canvas: TCanvas; APin: TNodePin; const ACenter: TPoint; ARadius: Integer; ASelected, AHovered, AHighlighted: Boolean; var AHandled: Boolean) of object;

  TNodeEditorDrawLinkEvent = procedure(Sender: TObject; Canvas: TCanvas; ALink: TNodeLink; ASelected, AHovered: Boolean; var AHandled: Boolean) of object;

  TNodeEditorDrawGridEvent = procedure(Sender: TObject; Canvas: TCanvas; const VisibleWorldRect: TRectF; Zoom, OffsetX, OffsetY: Double; var AHandled: Boolean) of object;

  TNodeEditorDrawSnapGuidesEvent = procedure(Sender: TObject; Canvas: TCanvas; GuideSnapXActive, GuideSnapYActive: Boolean; GuideSnapX, GuideSnapY: single; Zoom, OffsetX, OffsetY: Double; var AHandled: boolean) of object;

  { Interaction Events }

  TNodeChangedEvent = procedure(Sender: TObject; ANode: TCustomNode) of object;

  TNodePinEvent = procedure(Sender: TObject; APin: TNodePin) of object;

  TNodeLinkEvent = procedure(Sender: TObject; ALink: TNodeLink) of object;

  TEditorConnectPinsEvent = procedure(Sender: TObject; AFromPin, AToPin: TNodePin; var AAllow: Boolean) of object;

  TEditorPinsConnectedEvent = procedure(Sender: TObject; AFromPin, AToPin: TNodePin) of object;

  TNodeSelectionChangedEvent = procedure(Sender: TObject) of object;

  { Debugging }

  TEditorExecutionStateEvent = procedure(Sender: TObject) of object;

  TEditorExecutionNodeEvent = procedure(Sender: TObject; ANode: TExecutableNode) of object;

  TEditorExecutionFinishedEvent = procedure(Sender: TObject; Success: boolean; const ErrorMessage: string) of object;

  TNodeEditor = class(TControl)
    const
      ZoomMin = 0.01;
      ZoomMax = 6.00;
  private
    FGraph: TNodeGraph;
    FHorzScroll: TScrollBar;
    FVertScroll: TScrollBar;
    FController: TNodeEditorController;
    FOnNodeChanged: TNodeChangedEvent;
    FOnSelectionChanged: TNodeSelectionChangedEvent;

    // debug
    FCurrentDebugNode: TCustomNode;
    FDebugMode: boolean;
    FDebugViewMode: boolean;
    FOnExecutionFinished: TEditorExecutionFinishedEvent;
    FOnExecutionNodeChanged: TEditorExecutionNodeEvent;
    FOnExecutionStateChanged: TEditorExecutionStateEvent;
    FBreakpoints: TList;
    FDebugger: TGraphDebugger;
    FExecutionThread: TGraphExecutionThread;
    FLastRuntimeError: string;
    FRuntimeRunning: boolean;
    FRuntimePaused: boolean;
    FLastTimeElapsed: TTimeSpan;
    //

    FZoom: Double;
    FOffsetX, FOffsetY: Double;
    FScreenRect: TRectF;
    FScrollLastZoom: Double;
    FScrollLastContentSizeScaled: TRectF;
    FScrollLastContentSize: TRectF;

    FDraggingNode: Boolean;
    FDragNode: TCustomNode;
    FDragStartX, FDragStartY: Single;
    FDragAnchorX, FDragAnchorY: Single;

    FDragCommandNodes: TList<TCustomNode>;
    FDragOldPositions: array of TPointF;

    FDragStartWorldPos: TPointF;
    FShowDragCoordinates: boolean;

    FPanning: Boolean;
    FPanStartX, FPanStartY: Single;
    FRightButtonDown: Boolean;

    FTempFromPin: TNodePin;
    FTempMousePos: TPointF;
    FLastMousePos: TPointF;
    FLastMouseDownPos: TPointF;
    FDraggingLink: Boolean;
    FTempStartMousePos: TPointF;

    FBoxSelecting: Boolean;
    FBoxStart: TPointF;
    FBoxCurrent: TPointF;
    FBoxStartWorld: TPointF;
    FBoxCurrentWorld: TPointF;

    FPopupMenu: TPopupMenu;
    FLastWorldMousePos: TPointF;

    FHoveredNode: TCustomNode;
    FHoveredPin: TNodePin;
    FHoveredLink: TNodeLink;

    FReconnectingLink: Boolean;
    FReconnectLink: TNodeLink;
    FReconnectFixedPin: TNodePin;
    FReconnectMovingFromSide: Boolean;

    FResizingNode: Boolean;
    FResizeNode: TCustomNode;
    FResizeStartMouseX, FResizeStartMouseY: Single;
    FResizeStartWidth, FResizeStartHeight: Integer;
    FResizeStartX, FResizeStartY: Single;
    FResizeEdgeSize: Integer;
    FResizeOldWidth, FResizeOldHeight: Integer;

    FSnapToGrid: Boolean;
    FGridSize: Integer;
    FGridType: TGridType;
    FGridColor: TAlphaColor;
    FHighlightColor: TAlphaColor;
    FZoomStep: Double;
    FSnapToNodes: boolean;
    FNodeSnapDistance: single;

    FShowSnapGuides: boolean;
    FSnapAllSelectionGroup: Boolean;
    FGuideSnapXActive: boolean;
    FGuideSnapYActive: boolean;
    FGuideSnapX: single;
    FGuideSnapY: single;
    FGuideLineColor: TAlphaColor;
    FGuideLineStyle: TStrokeDash;
    FGuideLineWidth: Single;

    // Axes properties
    FShowAxes: Boolean;
    FAxesColor: TAlphaColor;
    FAxesThickness: integer;

    // Optimization fields
    FPaintNodesSorted: TList<TCustomNode>;
    FPaintNodesSortedNav: TList<TCustomNode>;
    FPaintNodesDirty: Boolean;
    FLastMouseMoveTick: UInt64;
    FLastPaintTick: UInt64;
    FFrameTimeWatch: TStopWatch;

    // Custom Draw Events
    FOnDrawNode: TNodeEditorDrawNodeEvent;
    FOnDrawLink: TNodeEditorDrawLinkEvent;
    FOnDrawGrid: TNodeEditorDrawGridEvent;
    FOnDrawSnapGuides: TNodeEditorDrawSnapGuidesEvent;

    // Interaction Events
    FOnUpdatedStatus: TNotifyEvent;
    FOnPinClick: TNodePinEvent;
    FOnLinkClick: TNodeLinkEvent;
    FOnBeforeConnectPins: TEditorConnectPinsEvent;
    FOnAfterConnectPins: TEditorPinsConnectedEvent;
    FShowGrid: Boolean;
    FShowFrameTime: Boolean;
    FLockedAll: Boolean;

    FLastZoomDistance: Single;
    FLinkVisualType: TLinkVisualType;
    FLinkGradient: Boolean;
  private // debug
    procedure ExecutionThreadStarted(Sender: TObject);
    procedure ExecutionThreadNodeExecuted(Sender: TObject; ANode: TExecutableNode);
    procedure ExecutionThreadFinished(Sender: TObject; Success: boolean; const ErrorMessage: string);
    procedure ExecutionThreadError(Sender: TObject; const ErrorInfo: TThreadErrorInfo);
    procedure ExecutionThreadDebuggerPaused(Sender: TObject; ANode: TCustomNode; APin: TNodePin; Context: INodeExecutionContext);
    function GetExecutionContext: TNodeExecutionContext;

    procedure SyncBreakpointsToDebugger;
    function FindDefaultStartExecNode: TExecutableNode;
    function IsExecEntryNode(ANode: TCustomNode): boolean;
    procedure ClearRuntimeVisualState;

    procedure SetCurrentDebugNode(AValue: TCustomNode);
    procedure SetDebugMode(AValue: boolean);
    procedure SetDebugViewMode(AValue: boolean);
  public
    procedure ToggleBreakpoint(ANode: TCustomNode);
    function HasBreakpoint(ANode: TCustomNode): boolean;
    procedure ClearAllBreakpoints;
    procedure HighlightNode(ANode: TCustomNode);

    function ExecuteGraph(AStartNode: TExecutableNode = nil): boolean;
    property ExecutionContext: TNodeExecutionContext read GetExecutionContext;
    procedure StopExecution;
    procedure PauseExecution;
    procedure ContinueExecution;
    procedure StepIntoExecution;
    procedure StepOverExecution;

    function IsExecutionRunning: boolean;
    function IsExecutionPaused: boolean;
    function GetLastRuntimeError: string;

    property Debugger: TGraphDebugger read FDebugger;
    property DebugMode: boolean read FDebugMode write SetDebugMode;
    property DebugViewMode: boolean read FDebugViewMode write SetDebugViewMode;
    property CurrentDebugNode: TCustomNode read FCurrentDebugNode write SetCurrentDebugNode;
    property OnExecutionStateChanged: TEditorExecutionStateEvent read FOnExecutionStateChanged write FOnExecutionStateChanged;
    property OnExecutionNodeChanged: TEditorExecutionNodeEvent read FOnExecutionNodeChanged write FOnExecutionNodeChanged;
    property OnExecutionFinished: TEditorExecutionFinishedEvent read FOnExecutionFinished write FOnExecutionFinished;
    property ExecutionLastTimeElapsed: TTimeSpan read FLastTimeElapsed;

  private // Auto scroll
    FAutoScrollTimer: TTimer;
    FAutoScroll: Boolean;
    FAutoScrollOrigin: TPointF;
    FCurrentMousePos: TPointF;
    FScrollSpeedX: Single;
    FScrollSpeedY: Single;
    FAni: TAniCalculations;
    procedure AniChanged(Sender: TObject);
    procedure TimerAutoScrollProc(Sender: TObject);
  private
    FLinkVisualClass: TLinkVisualObjectClass;
    FOnGraphChanged: TNotifyEvent;

    // Internal Logic
    function GetPrimarySelectedNode: TCustomNode;
    function GetPrimarySelectedLink: TNodeLink;

    // Render Helpers
    procedure DrawNode(ANode: TCustomNode; const NodeBounds: TRectF);

    procedure NotifySelectionChanged;
    procedure ControllerSelectionChanged(Sender: TObject);

    // Geometry
    function GetNodeResizeUnderMouse(SX, SY: Single): TCustomNode;
    function GetVisibleWorldRect: TRectF;

    // Render Layers
    procedure DrawGrid;
    procedure DrawAxes;
    procedure DrawLinks;
    procedure DrawMoveHint;
    procedure DrawTempLink;
    procedure DrawBoxSelect;
    procedure DrawSnapGuides;
    procedure ClearSnapGuides;

    // Misc
    procedure BuildContextMenu;
    procedure OnContextCopy(Sender: TObject);
    procedure OnContextPaste(Sender: TObject);
    procedure OnContextDuplicate(Sender: TObject);
    procedure OnContextDelete(Sender: TObject);
    procedure OnContextSearchNode(Sender: TObject);
    procedure OnContextInsertReroute(Sender: TObject);
    procedure OnContextAddComment(Sender: TObject);
    procedure ShowNodeSearchPopup(const Position: TPointF; const WorldPosition: TPointF);
    procedure ResetStateAfterGraphReload;
    procedure ClearHoverStates;
    procedure UpdateHoverStates(SX, SY: Single; HitLinks: Boolean = True);
    procedure SetZoom(Value: Double); overload;
    procedure SetZoomStep(AValue: Double);
    procedure UpdatedStatus;
    procedure SetOnUpdatedStatus(const Value: TNotifyEvent);
    procedure SetGridSize(const Value: Integer);
    procedure SetGridType(const Value: TGridType);
    procedure CancelMouseOperations(const KeepSelectionRect: Boolean);
    function NodeIsAbove(const Current, Target: TCustomNode): Boolean;
    procedure UpdatePinsConnectedState;
    procedure SetShowGrid(const Value: Boolean);
    procedure DrawNavigator(ACanvas: TCanvas; const ARect: TRectF);
    procedure DrawMiniGrid(ACanvas: TCanvas; const ARect: TRectF; AOffsetX, AOffsetY, AZoom: Double);
    procedure DrawNodes(FirstLevel: Boolean);
    procedure InternalWorldChanged;
    procedure BeginPaint;
    procedure DrawFrameTime;
    procedure EndPaint;
    procedure SetShowFrameTime(const Value: Boolean);
    procedure SetGridColor(const Value: TAlphaColor);
    procedure SetLockedAll(const Value: Boolean);
    procedure FOnGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure InternalMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalMouseMove(Shift: TShiftState; X, Y: Single);
    procedure InternalMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure FOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure FOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure OnContextCut(Sender: TObject);
    procedure CutSelectionToClipboard;
    procedure OnContextRedo(Sender: TObject);
    procedure OnContextUndo(Sender: TObject);
    procedure OnContextSelectAll(Sender: TObject);
    procedure SetLinkVisualType(const Value: TLinkVisualType);
    procedure SetLinkGradient(const Value: Boolean);
    procedure SelectAllLinks;
    procedure SelectAllNodes;
    function GetContentSize: TRectF;
    procedure HorzScrollChange(Sender: TObject);
    procedure VertScrollChange(Sender: TObject);
    procedure UpdateScrollBars(Recalc: Boolean);
    procedure SetDraggingNode(const Value: Boolean);
    procedure SetResizingNode(const Value: Boolean);
    procedure ApplyGridSnap(var AOffsetX, AOffsetY: Single; var ASnappedX, ASnappedY: Boolean);
    procedure InternalPanning(X, Y: Single);
    procedure InternalResizing(X, Y: Single);
    procedure InternalDragging(X, Y: Single; Shift: TShiftState);
    procedure InternalPanningBegin(X, Y: Single);
    procedure InternalPanningEnd(X, Y: Single);
    function InternalResizingBegin(X, Y: Single): Boolean;
    function InternalPinClick(X, Y: Single; Shift: TShiftState; NodeUnderMouse: TCustomNode): Boolean;
    function InternalLinkClick(X, Y: Single; Shift: TShiftState; SelectOnly: Boolean): Boolean;
    function InternalNodeClick(X, Y: Single; Shift: TShiftState; NodeUnderMouse: TCustomNode; SelectOnly: Boolean): Boolean;
    procedure InternalBoxSelectingBegin(X, Y: Single; Shift: TShiftState);
    procedure InternalBoxSelecting(X, Y: Single);
    procedure InternalPinConnecting(X, Y: Single);
    procedure InternalResizingEnd;
    procedure InternalAutoScrollBegin(X, Y: Single);
    function InternalPinConnectingTry(X, Y: Single): Boolean;
    procedure InternalDraggingEnd(X, Y: Single);
    procedure InternalBoxSelectingEnd(X, Y: Single; Shift: TShiftState);
    procedure InternalDraggingBegin(X, Y: Single; Node: TCustomNode);
    procedure InternalAutoScroll(X, Y: Single);
    procedure InternalAutoScrollEnd;
    procedure SetLinkVisualClass(const Value: TLinkVisualObjectClass);
    procedure SelectPin(Pin: TNodePin; Toggle: Boolean);
    procedure MoveScreen(Direction: TMoveDirection);
    procedure SetOnGraphChanged(const Value: TNotifyEvent);
    procedure ControllerChanged(Sender: TObject);
    function GetLinkColor: TAlphaColor;
    procedure SetLinkColor(const Value: TAlphaColor);
    function GetLinkThickness: Single;
    procedure SetLinkThickness(const Value: Single);
  protected
    function GetSelectedPin(Index: integer): TNodePin;

    function IsNodeInDragSelection(ANode: TCustomNode): Boolean;
    function GetDraggedSelectionBoundsAtOffset(const AOffsetX, AOffsetY: Single): TRectF;
    procedure ApplyNodeSnap(var AOffsetX, AOffsetY: Single; out ASnappedX, ASnappedY: Boolean);

    procedure InvalidateSortedNodes;
    procedure EnsureSortedNodes;
    procedure NodeGraphChanged(Sender: TObject);

    // Hit Testing
    function WorldToScreen(WX, WY: Single): TPointF;
    function ScreenToWorld(const Value: TPointF): TPointF; overload;
    function ScreenToWorld(SX, SY: Double): TPointF; overload;
    function ScreenToWorld(SX, SY: Double; AZoom: Double): TPointF; overload;
    function SnapWorldValue(Value: Single): Single; overload;
    function SnapWorldPoint(const P: TPointF): TPointF; overload;

    function GetNodeUnderMouse(SX, SY: Single): TCustomNode;
    function GetPinUnderMouse(SX, SY: Single; out Node: TCustomNode; out Pin: TNodePin): Boolean;
    function GetLinkUnderMouse(SX, SY: Single; out Link: TNodeLink): Boolean;

    // Selection Logic
    procedure SelectNodeInternal(ANode: TCustomNode; AAppend: Boolean);
    procedure SelectLinkInternal(ALink: TNodeLink; AKeepNodes: Boolean = False);
    procedure ToggleNodeSelection(ANode: TCustomNode);
    procedure RemoveNodeFromSelection(ANode: TCustomNode);
    procedure ToggleLinkSelection(ALink: TNodeLink);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure DoMouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; AX, AY: Single); override;
    procedure MouseMove(Shift: TShiftState; AX, AY: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; AX, AY: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;
    property DraggingNode: Boolean read FDraggingNode write SetDraggingNode;
    property ResizingNode: Boolean read FResizingNode write SetResizingNode;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddNode(ANode: TCustomNode);
    procedure RemoveNode(ANode: TCustomNode);
    procedure BringNodeToFront(ANode: TCustomNode = nil);
    procedure SendNodeToBack(ANode: TCustomNode = nil);
    //
    function AddLink(APinFrom, APinTo: TNodePin): Boolean;
    procedure RemoveLink(ALink: TNodeLink);
    //
    procedure Clear;
    procedure Cancel;

    procedure ClearSelection;
    procedure DeleteSelection;
    procedure SelectAll;
    function SelectedNodeCount: Integer;
    function SelectedLinkCount: Integer;
    function SelectedPinCount: Integer;
    function GetSelectedNode(Index: Integer): TCustomNode;
    procedure SelectNode(ANode: TCustomNode; AAppend: Boolean);
    procedure SelectLink(ALink: TNodeLink);
    //
    procedure ExecuteNodePropertyChange(ANode: TCustomNode; const AOldJSON, ANewJSON: string);
    procedure RenderNavigator(Bitmap: TBitmap);

    procedure FitSelection;
    procedure Fit;
    procedure FitSome;
    procedure ResetView;
    procedure SetZoom(Value: Double; const TargetPos: TPointF); overload;

    function SaveToJSONText: string;
    procedure LoadFromJSONText(const JSON: string);
    procedure SaveToFile(const AFileName: string);
    procedure LoadFromFile(const AFileName: string);

    procedure Undo;
    procedure Redo;
    procedure CopySelectionToClipboard;
    procedure PasteFromClipboard;
    procedure DuplicateSelection;

    function AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = TPinKind.Data): TNodePin;
    function RemovePinFromNode(APin: TNodePin): Boolean;

    function ValidateGraphToStrings(AStrings: TStrings): Boolean;

    property Graph: TNodeGraph read FGraph;
    property Zoom: Double read FZoom write SetZoom;
    property Controller: TNodeEditorController read FController;

    property ShowSnapGuides: Boolean read FShowSnapGuides write FShowSnapGuides default True;
    property SnapAllSelectionGroup: Boolean read FSnapAllSelectionGroup write FSnapAllSelectionGroup default False;
    property GuideLineColor: TAlphaColor read FGuideLineColor write FGuideLineColor default $FFFFD740;
    property GuideLineStyle: TStrokeDash read FGuideLineStyle write FGuideLineStyle default TStrokeDash.Dash;
    property GuideLineWidth: Single read FGuideLineWidth write FGuideLineWidth;
    property HighlightColor: TAlphaColor read FHighlightColor write FHighlightColor default $FFFFD740;
    property SnapToGrid: Boolean read FSnapToGrid write FSnapToGrid default False;
    property SnapToNodes: Boolean read FSnapToNodes write FSnapToNodes default True;
    property NodeSnapDistance: Single read FNodeSnapDistance write FNodeSnapDistance;

    // New Axes Properties
    property ShowAxes: Boolean read FShowAxes write FShowAxes default False;
    property GridSize: Integer read FGridSize write SetGridSize default 40;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
    property LockedAll: Boolean read FLockedAll write SetLockedAll;
    property ShowFrameTime: Boolean read FShowFrameTime write SetShowFrameTime;

    // Styling
    property AxesColor: TAlphaColor read FAxesColor write FAxesColor default $FFAAAAAA;
    property AxesThickness: integer read FAxesThickness write FAxesThickness default 2;

    property LinkColor: TAlphaColor read GetLinkColor write SetLinkColor;
    property LinkThickness: Single read GetLinkThickness write SetLinkThickness;

    property ZoomStep: Double read FZoomStep write SetZoomStep;
    property GridType: TGridType read FGridType write SetGridType;
    property GridColor: TAlphaColor read FGridColor write SetGridColor default $22E0E0E0;
    property LinkVisualType: TLinkVisualType read FLinkVisualType write SetLinkVisualType default TLinkVisualType.Bezier;
    property LinkVisualClass: TLinkVisualObjectClass read FLinkVisualClass write SetLinkVisualClass;
    property LinkGradient: Boolean read FLinkGradient write SetLinkGradient;

    // Events
    property OnDrawNode: TNodeEditorDrawNodeEvent read FOnDrawNode write FOnDrawNode;
    property OnDrawLink: TNodeEditorDrawLinkEvent read FOnDrawLink write FOnDrawLink;
    property OnDrawGrid: TNodeEditorDrawGridEvent read FOnDrawGrid write FOnDrawGrid;
    property OnDrawSnapGuides: TNodeEditorDrawSnapGuidesEvent read FOnDrawSnapGuides write FOnDrawSnapGuides;
    //
    property OnSelectionChanged: TNodeSelectionChangedEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnNodeChanged: TNodeChangedEvent read FOnNodeChanged write FOnNodeChanged;
    property OnGraphChanged: TNotifyEvent read FOnGraphChanged write SetOnGraphChanged;
    property OnUpdatedStatus: TNotifyEvent read FOnUpdatedStatus write SetOnUpdatedStatus;
    property OnPinClick: TNodePinEvent read FOnPinClick write FOnPinClick;
    property OnLinkClick: TNodeLinkEvent read FOnLinkClick write FOnLinkClick;
    property OnBeforeConnectPins: TEditorConnectPinsEvent read FOnBeforeConnectPins write FOnBeforeConnectPins;
    property OnAfterConnectPins: TEditorPinsConnectedEvent read FOnAfterConnectPins write FOnAfterConnectPins;

    { IRotatedControl }
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property DisabledOpacity;
    property ParentContent;
    property ParentContentObserver;
    /// <summary>If the control has ShowHint to false, this property is used to see if a hint can be displayed.</summary>
    property ParentShowHint;
  end;

implementation

uses
  System.IOUtils, FMX.NodeEditor.Form.Search, FMX.Types3D,
  FMX.NodeEditor.Graph.Command, System.Generics.Defaults, System.Math.Vectors;

function NodePaintCompare(const Item1, Item2: TCustomNode): Integer; inline;
begin
  if Item1.Selected and not Item2.Selected then
    Result := 1
  else if not Item1.Selected and Item2.Selected then
    Result := -1
  else if (Item1.ZOrder < Item2.ZOrder) then
    Result := -1
  else if Item1.ZOrder > Item2.ZOrder then
    Result := 1
  else
    Result := 0;
end;

{ TNodeEditor }

constructor TNodeEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnDragOver := FOnDragOver;
  OnDragDrop := FOnDragDrop;
  AutoCapture := True;
  ClipChildren := True;
  CanFocus := True;
  TabStop := True;
  Touch.InteractiveGestures := [
      TInteractiveGesture.Zoom,
      TInteractiveGesture.Pan,
      TInteractiveGesture.LongTap,
      TInteractiveGesture.DoubleTap];
  OnGesture := FOnGesture;

  FAutoScrollTimer := TTimer.Create(Self);
  FAutoScrollTimer.OnTimer := TimerAutoScrollProc;
  FAutoScrollTimer.Interval := 16;
  FAutoScrollTimer.Enabled := False;

  FAni := TAniCalculations.Create(Self);
  FAni.Animation := True;
  FAni.OnChanged := AniChanged;

  FHorzScroll := TScrollBar.Create(Self);
  FHorzScroll.Parent := Self;
  FHorzScroll.Orientation := TOrientation.Horizontal;
  FHorzScroll.Align := TAlignLayout.Bottom;
  FHorzScroll.Height := 16;
  FHorzScroll.OnChange := HorzScrollChange;

  FVertScroll := TScrollBar.Create(Self);
  FVertScroll.Parent := Self;
  FVertScroll.Orientation := TOrientation.Vertical;
  FVertScroll.Align := TAlignLayout.MostRight;
  FVertScroll.Width := 16;
  FVertScroll.Margins.Bottom := FHorzScroll.Height;
  FVertScroll.OnChange := VertScrollChange;

  FGraph := TNodeGraph.Create;
  FGraph.OnGraphChanged := NodeGraphChanged;

  FController := TNodeEditorController.Create(FGraph);
  FController.OnChanged := ControllerChanged;
  FController.OnSelectionChanged := ControllerSelectionChanged;

  FDragCommandNodes := TList<TCustomNode>.Create;
  FPaintNodesSorted := TList<TCustomNode>.Create;
  FPaintNodesSortedNav := TList<TCustomNode>.Create;

  FPaintNodesDirty := True;
  FLastMouseMoveTick := 0;
  FLastPaintTick := 0;

  FLinkVisualType := TLinkVisualType.Bezier;
  TNodeLink.VisualClass := TLinkVisualBezier;
  TCustomNode.DrawIcon := True;
  FLinkGradient := True;
  TNodeLink.UseGradient := True;

  FZoom := 1.0;
  FZoomStep := 1.15;
  FSnapToGrid := False;
  FGridSize := 40;
  FGridColor := $22E0E0E0;
  FHighlightColor := $FFFFD740;
  FSnapToNodes := True;
  FNodeSnapDistance := 10.0;
  FOffsetX := 0;
  FOffsetY := 0;

  FShowGrid := True;
  FShowSnapGuides := True;
  FSnapAllSelectionGroup := False;
  FGuideSnapXActive := False;
  FGuideSnapYActive := False;
  FGuideSnapX := 0;
  FGuideSnapY := 0;
  FGuideLineColor := $FFFFD740;
  FGuideLineStyle := TStrokeDash.Dash;
  FGuideLineWidth := 1;

  // Axes defaults
  FShowAxes := False;
  FAxesColor := $FFAAAAAA;
  FAxesThickness := 2;

  // Styling Defaults
  ResizingNode := False;
  FResizeNode := nil;
  FResizeEdgeSize := 6;

  FReconnectingLink := False;
  FReconnectLink := nil;
  FReconnectFixedPin := nil;
  FReconnectMovingFromSide := False;

  FDraggingLink := False;
  FTempStartMousePos := Point(0, 0);

  InternalPanningEnd(FLastMousePos.X, FLastMousePos.Y);
  FRightButtonDown := False;

  FPopupMenu := TPopupMenu.Create(Self);
  BuildContextMenu;

  // execution
  FDebugger := TGraphDebugger.Create(FGraph);
  FExecutionThread := nil;
  FLastRuntimeError := '';
  FLastTimeElapsed := TTimeSpan.Zero;
  FRuntimeRunning := False;
  FRuntimePaused := False;
end;

destructor TNodeEditor.Destroy;
begin
  StopExecution;
  FreeAndNil(FDebugger);
  FreeAndNil(FBreakpoints);

  FAni.Free;
  FPaintNodesSorted.Free;
  FPaintNodesSortedNav.Free;
  FController.Free;
  FDragCommandNodes.Free;
  FGraph.Free;
  FPopupMenu.Free;
  inherited Destroy;
end;

procedure TNodeEditor.FOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if Data.Source is TFMXObject then
    Operation := TDragOperation.Link
  else
    Operation := TDragOperation.None;
end;

procedure TNodeEditor.FOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
  if Data.Source is TFMXObject then
  begin
    var NodeType := TFMXObject(Data.Source).TagString;

    var SPoint := ScreenToWorld(Point.X, Point.Y);
    var N := FGraph.Registry.CreateNode(NodeType, SnapWorldPoint(SPoint));
    FController.AddNode(N);
    SelectNodeInternal(N, False);
  end;
end;

procedure TNodeEditor.FOnGesture(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  var Point := ScreenToLocal(EventInfo.Location);
  Handled := True;
  if TInteractiveGestureFlag.gfBegin in EventInfo.Flags then
  begin
    case EventInfo.GestureID of
      igiPan:
        InternalMouseDown(TMouseButton.mbMiddle, [], Point.X, Point.Y);
      igiLongTap:
        InternalMouseDown(TMouseButton.mbRight, [], Point.X, Point.Y);
      igiDoubleTap:
        InternalMouseDown(TMouseButton.mbLeft, [], Point.X, Point.Y);
      igiZoom:
        begin
          FLastZoomDistance := EventInfo.Distance;
        end;
    end;
  end
  else if TInteractiveGestureFlag.gfEnd in EventInfo.Flags then
  begin
    case EventInfo.GestureID of
      igiPan:
        InternalMouseUp(TMouseButton.mbMiddle, [], Point.X, Point.Y);
      igiLongTap:
        InternalMouseUp(TMouseButton.mbRight, [], Point.X, Point.Y);
      igiDoubleTap:
        InternalMouseUp(TMouseButton.mbLeft, [], Point.X, Point.Y);
    end;
  end
  else
  begin
    case EventInfo.GestureID of
      igiZoom:
        begin
          var WheelDelta: Integer;
          if EventInfo.Distance > FLastZoomDistance then
            WheelDelta := 120
          else
            WheelDelta := -120;

          MouseWheel([], WheelDelta, Handled);

          FLastZoomDistance := EventInfo.Distance;
        end;
      igiPan, igiLongTap, igiDoubleTap:
        InternalMouseMove([], Point.X, Point.Y);
    end;
  end;
end;

procedure TNodeEditor.SetDebugMode(AValue: boolean);
begin
  if FDebugMode = AValue then
    Exit;
  FDebugMode := AValue;
  if not FDebugMode then
  begin
    FDebugViewMode := False;
    FCurrentDebugNode := nil;
  end;
  Repaint;
end;

procedure TNodeEditor.SetDebugViewMode(AValue: boolean);
begin
  if FDebugViewMode = AValue then
    Exit;
  FDebugViewMode := AValue;
  Repaint;
end;

procedure TNodeEditor.SetCurrentDebugNode(AValue: TCustomNode);
begin
  if FCurrentDebugNode = AValue then
    Exit;
  FCurrentDebugNode := AValue;
  Repaint;
end;

procedure TNodeEditor.ToggleBreakpoint(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  if FBreakpoints = nil then
    FBreakpoints := TList.Create;

  if FBreakpoints.IndexOf(ANode) >= 0 then
  begin
    FBreakpoints.Remove(ANode);
    if FDebugger <> nil then
      FDebugger.RemoveBreakpoint(ANode);
  end
  else
  begin
    FBreakpoints.Add(ANode);
    if FDebugger <> nil then
      FDebugger.AddBreakpoint(ANode);
  end;

  Repaint;
end;

function TNodeEditor.HasBreakpoint(ANode: TCustomNode): boolean;
begin
  Result := (FBreakpoints <> nil) and (FBreakpoints.IndexOf(ANode) >= 0);
end;

procedure TNodeEditor.ClearAllBreakpoints;
begin
  if FBreakpoints <> nil then
    FBreakpoints.Clear;

  if FDebugger <> nil then
    FDebugger.ClearAllBreakpoints;

  Repaint;
end;

procedure TNodeEditor.HighlightNode(ANode: TCustomNode);
begin
  FCurrentDebugNode := ANode;
  Repaint;
end;

function TNodeEditor.IsExecEntryNode(ANode: TCustomNode): boolean;
var
  i, j: integer;
  Pin: TNodePin;
  Link: TNodeLink;
begin
  Result := False;
  if (ANode = nil) or not (ANode is TExecutableNode) then
    Exit;

  for i := 0 to ANode.OutputCount - 1 do
  begin
    Pin := ANode.GetOutput(i);
    if (Pin <> nil) and (Pin.Kind = TPinKind.Exec) then
    begin
      Result := True;
      Break;
    end;
  end;

  if not Result then
    Exit(False);

  for i := 0 to ANode.InputCount - 1 do
  begin
    Pin := ANode.GetInput(i);
    if (Pin = nil) or (Pin.Kind <> TPinKind.Exec) then
      Continue;

    for j := 0 to FGraph.Links.Count - 1 do
    begin
      Link := TNodeLink(FGraph.Links[j]);
      if (Link <> nil) and (Link.ToPin = Pin) then
        Exit(False);
    end;
  end;

  Result := True;
end;

function TNodeEditor.FindDefaultStartExecNode: TExecutableNode;
var
  i: integer;
  N: TCustomNode;
begin
  Result := nil;

  // Если пользователь что-то выделил — это явная точка старта
  if FController.Selection.NodeCount > 0 then
  begin
    N := FController.Selection.GetNode(0);
    if N is TExecutableNode then
      Exit(TExecutableNode(N));
  end;

  // Иначе ищем "входной" узел графа
  for i := 0 to FGraph.Nodes.Count - 1 do
  begin
    N := TCustomNode(FGraph.Nodes[i]);
    if (N is TExecutableNode) and IsExecEntryNode(N) then
      Exit(TExecutableNode(N));
  end;

  // Фоллбек — любой executable node
  for i := 0 to FGraph.Nodes.Count - 1 do
  begin
    N := TCustomNode(FGraph.Nodes[i]);
    if N is TExecutableNode then
      Exit(TExecutableNode(N));
  end;
end;

procedure TNodeEditor.SyncBreakpointsToDebugger;
var
  i: integer;
  N: TCustomNode;
begin
  if FDebugger = nil then
    Exit;

  FDebugger.ClearAllBreakpoints;

  if FBreakpoints = nil then
    Exit;

  for i := 0 to FBreakpoints.Count - 1 do
  begin
    N := TCustomNode(FBreakpoints[i]);
    if N <> nil then
      FDebugger.AddBreakpoint(N);
  end;
end;

procedure TNodeEditor.ClearRuntimeVisualState;
begin
  FRuntimeRunning := False;
  FRuntimePaused := False;
  FCurrentDebugNode := nil;
  FDebugViewMode := False;
  Repaint;
end;

procedure TNodeEditor.ExecutionThreadStarted(Sender: TObject);
begin
  FLastRuntimeError := '';
  FLastTimeElapsed := TTimeSpan.Zero;
  FRuntimeRunning := True;
  FRuntimePaused := False;
  FDebugMode := True;
  FDebugViewMode := True;
  Repaint;

  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

procedure TNodeEditor.ExecutionThreadNodeExecuted(Sender: TObject; ANode: TExecutableNode);
begin
  FCurrentDebugNode := ANode;
  FDebugMode := True;
  FDebugViewMode := True;
  //
  Repaint;

  if Assigned(FOnExecutionNodeChanged) then
    FOnExecutionNodeChanged(Self, ANode);

  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

procedure TNodeEditor.ExecutionThreadFinished(Sender: TObject; Success: boolean; const ErrorMessage: string);
begin
  if Success then
    FLastRuntimeError := ''
  else
    FLastRuntimeError := ErrorMessage;
  FLastTimeElapsed := FExecutionThread.LastTimeElapsed;

  FExecutionThread := nil;
  ClearRuntimeVisualState;

  if Assigned(FOnExecutionFinished) then
    FOnExecutionFinished(Self, Success, ErrorMessage);

  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

procedure TNodeEditor.ExecutionThreadError(Sender: TObject; const ErrorInfo: TThreadErrorInfo);
begin
  FLastRuntimeError := ErrorInfo.Message;
  FLastTimeElapsed := FExecutionThread.LastTimeElapsed;

  if ErrorInfo.Node <> nil then
  begin
    FCurrentDebugNode := ErrorInfo.Node;
    FDebugMode := True;
    FDebugViewMode := True;
  end;

  Repaint;

  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

procedure TNodeEditor.ExecutionThreadDebuggerPaused(Sender: TObject; ANode: TCustomNode; APin: TNodePin; Context: INodeExecutionContext);
begin
  FCurrentDebugNode := ANode;
  FDebugMode := True;
  FDebugViewMode := True;
  FRuntimeRunning := False;
  FRuntimePaused := True;
  Repaint;

  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

function TNodeEditor.GetExecutionContext: TNodeExecutionContext;
begin
  Result := nil;
  if (FExecutionThread <> nil) and (FExecutionThread.Executor <> nil) then
    Result := FExecutionThread.Executor.Context;
end;

function TNodeEditor.ExecuteGraph(AStartNode: TExecutableNode): boolean;
begin
  StopExecution;

  if AStartNode = nil then
    AStartNode := FindDefaultStartExecNode;

  if AStartNode = nil then
  begin
    FLastRuntimeError := Translate('Start execute node not found');
    Exit(False);
  end;

  if FDebugger = nil then
    FDebugger := TGraphDebugger.Create(FGraph);

  SyncBreakpointsToDebugger;
  FDebugger.ResetSession;

  FExecutionThread := TGraphExecutionThread.Create(FGraph, AStartNode, FDebugger);
  FExecutionThread.OnStarted := ExecutionThreadStarted;
  FExecutionThread.OnNodeExecuted := ExecutionThreadNodeExecuted;
  FExecutionThread.OnFinished := ExecutionThreadFinished;
  FExecutionThread.OnError := ExecutionThreadError;
  FExecutionThread.OnDebuggerPaused := ExecutionThreadDebuggerPaused;
  FExecutionThread.Start;

  Result := True;
end;

procedure TNodeEditor.StopExecution;
begin
  if FExecutionThread <> nil then
  begin
    FExecutionThread.Stop;
    FExecutionThread := nil;
  end;

  if FDebugger <> nil then
    FDebugger.Continue;

  ClearRuntimeVisualState;

  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

procedure TNodeEditor.PauseExecution;
begin
  if FExecutionThread <> nil then
  begin
    FExecutionThread.Pause;
    FRuntimePaused := True;
    FRuntimeRunning := False;
  end
  else if FDebugger <> nil then
  begin
    FDebugger.Pause;
    FRuntimePaused := True;
    FRuntimeRunning := False;
  end;
  Repaint;
  if Assigned(FOnExecutionStateChanged) then
    FOnExecutionStateChanged(Self);
end;

procedure TNodeEditor.ContinueExecution;
begin
  if FExecutionThread <> nil then
  begin
    FExecutionThread.Continue;
    FRuntimePaused := False;
    FRuntimeRunning := True;
    FDebugViewMode := True;
    Repaint;
    if Assigned(FOnExecutionStateChanged) then
      FOnExecutionStateChanged(Self);
  end;
end;

procedure TNodeEditor.StepIntoExecution;
begin
  if FExecutionThread <> nil then
  begin
    FExecutionThread.StepInto;
    FRuntimePaused := False;
    FRuntimeRunning := True;
    FDebugViewMode := True;
    Repaint;
    if Assigned(FOnExecutionStateChanged) then
      FOnExecutionStateChanged(Self);
  end;
end;

procedure TNodeEditor.StepOverExecution;
begin
  if FExecutionThread <> nil then
  begin
    FExecutionThread.StepOver;
    FRuntimePaused := False;
    FRuntimeRunning := True;
    FDebugViewMode := True;
    Repaint;
    if Assigned(FOnExecutionStateChanged) then
      FOnExecutionStateChanged(Self);
  end;
end;

function TNodeEditor.IsExecutionRunning: boolean;
begin
  Result := FRuntimeRunning and not FRuntimePaused and (FExecutionThread <> nil);
end;

function TNodeEditor.IsExecutionPaused: boolean;
begin
  Result := FRuntimePaused and (FExecutionThread <> nil);
end;

function TNodeEditor.GetLastRuntimeError: string;
begin
  Result := FLastRuntimeError;
end;

procedure TNodeEditor.ExecuteNodePropertyChange(ANode: TCustomNode; const AOldJSON, ANewJSON: string);
begin
  if ANode = nil then
    Exit;

  if AOldJSON = ANewJSON then
    Exit;

  FController.ExecuteCommand(TChangeNodePropertyCommand.Create(Graph, ANode, AOldJSON, ANewJSON));
end;

procedure TNodeEditor.InvalidateSortedNodes;
begin
  FPaintNodesDirty := True;
end;

procedure TNodeEditor.EnsureSortedNodes;
begin
  if not FPaintNodesDirty then
    Exit;

  FPaintNodesSorted.Capacity := FGraph.Nodes.Count;
  FPaintNodesSorted.Clear;
  FPaintNodesSortedNav.Capacity := FGraph.Nodes.Count;
  FPaintNodesSortedNav.Clear;

  if FGraph = nil then
    Exit;

  var R := FScreenRect;
  R.Inflate(10 * FZoom, 10 * FZoom); // scale bounds for paint outbounds parts

  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    var N := FGraph.Nodes[i];
    if R.IntersectsWith(N.GetScreenBounds(FZoom, FOffsetX, FOffsetY)) then
      FPaintNodesSorted.Add(N);
    FPaintNodesSortedNav.Add(N);
  end;

  FPaintNodesSorted.Sort(TComparer<TCustomNode>.Construct(NodePaintCompare));
  FPaintNodesSortedNav.Sort(TComparer<TCustomNode>.Construct(NodePaintCompare));
  FPaintNodesDirty := False;
end;

procedure TNodeEditor.NodeGraphChanged(Sender: TObject);
begin
  UpdateScrollBars(True);
  UpdatePinsConnectedState;
  InvalidateSortedNodes;
  Repaint;
end;

function TNodeEditor.IsNodeInDragSelection(ANode: TCustomNode): boolean;
begin
  Result := (ANode <> nil) and (FDragCommandNodes.IndexOf(ANode) >= 0);
end;

function TNodeEditor.GetDraggedSelectionBoundsAtOffset(const AOffsetX, AOffsetY: single): TRectF;
var
  N: TCustomNode;
  L, T, R, B: single;
  First: Boolean;
begin
  Result := RectF(0, 0, 0, 0);
  First := True;

  for var i := 0 to FDragCommandNodes.Count - 1 do
  begin
    N := FDragCommandNodes[i];
    if N = nil then
      Continue;

    if N <> FDragNode then
      Continue;

    L := FDragOldPositions[i].X + AOffsetX;
    T := FDragOldPositions[i].Y + AOffsetY;
    R := L + N.Width;
    B := T + N.Height;

    if First then
    begin
      Result := RectF(L, T, R, B);
      //First := False;
    end
    else
    begin
      if L < Result.Left then
        Result.Left := L;
      if T < Result.Top then
        Result.Top := T;
      if R > Result.Right then
        Result.Right := R;
      if B > Result.Bottom then
        Result.Bottom := B;
    end;

    Break;
  end;
end;

procedure TNodeEditor.ApplyGridSnap(var AOffsetX, AOffsetY: Single; var ASnappedX, ASnappedY: Boolean);
begin
  var BaseX := FDragOldPositions[0].X;
  var BaseY := FDragOldPositions[0].Y;

  for var i := 0 to FDragCommandNodes.Count - 1 do
  begin
    var N := FDragCommandNodes[i];
    if not FSnapAllSelectionGroup then
      if N <> FDragNode then
        Continue;
    BaseX := FDragOldPositions[i].X;
    BaseY := FDragOldPositions[i].Y;
    Break;
  end;

  if not ASnappedX then
    AOffsetX := SnapWorldValue(BaseX + AOffsetX) - BaseX;

  if not ASnappedY then
    AOffsetY := SnapWorldValue(BaseY + AOffsetY) - BaseY;
end;

procedure TNodeEditor.ApplyNodeSnap(var AOffsetX, AOffsetY: Single; out ASnappedX, ASnappedY: boolean);
var
  DragBounds: TRectF;
  OtherBounds: TRectF;
  DragLeft, DragRight, DragTop, DragBottom: Single;
  DragCenterX, DragCenterY: single;
  OtherLeft, OtherRight, OtherTop, OtherBottom: single;
  OtherCenterX, OtherCenterY: single;
  BestDX, BestDY: single;
  CandDX, CandDY: single;
  BestAbsDX, BestAbsDY: single;
  D: single;
  BestGuideX, BestGuideY: single;
begin
  ClearSnapGuides;
  ASnappedX := False;
  ASnappedY := False;

  if FNodeSnapDistance <= 0 then
    Exit;
  if FDragCommandNodes.Count = 0 then
    Exit;

  DragBounds := GetDraggedSelectionBoundsAtOffset(AOffsetX, AOffsetY);

  DragLeft := DragBounds.Left;
  DragRight := DragBounds.Right;
  DragTop := DragBounds.Top;
  DragBottom := DragBounds.Bottom;
  DragCenterX := (DragLeft + DragRight) * 0.5;
  DragCenterY := (DragTop + DragBottom) * 0.5;

  BestDX := 0;
  BestDY := 0;
  BestGuideX := 0;
  BestGuideY := 0;
  BestAbsDX := FNodeSnapDistance + 1;
  BestAbsDY := FNodeSnapDistance + 1;

  for var N in FPaintNodesSorted do
  begin
    if (N = nil) or IsNodeInDragSelection(N) then
      Continue;

    OtherBounds := RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height);

    OtherLeft := OtherBounds.Left;
    OtherRight := OtherBounds.Right;
    OtherTop := OtherBounds.Top;
    OtherBottom := OtherBounds.Bottom;
    OtherCenterX := (OtherLeft + OtherRight) * 0.5;
    OtherCenterY := (OtherTop + OtherBottom) * 0.5;

    // X-axis snapping
    CandDX := OtherLeft - DragLeft;
    D := Abs(CandDX);
    if D < BestAbsDX then
    begin
      BestAbsDX := D;
      BestDX := CandDX;
      BestGuideX := OtherLeft;
    end;

    CandDX := OtherRight - DragRight;
    D := Abs(CandDX);
    if D < BestAbsDX then
    begin
      BestAbsDX := D;
      BestDX := CandDX;
      BestGuideX := OtherRight;
    end;

    CandDX := OtherCenterX - DragCenterX;
    D := Abs(CandDX);
    if D < BestAbsDX then
    begin
      BestAbsDX := D;
      BestDX := CandDX;
      BestGuideX := OtherCenterX;
    end;

    // Y-axis snapping
    CandDY := OtherTop - DragTop;
    D := Abs(CandDY);
    if D < BestAbsDY then
    begin
      BestAbsDY := D;
      BestDY := CandDY;
      BestGuideY := OtherTop;
    end;

    CandDY := OtherBottom - DragBottom;
    D := Abs(CandDY);
    if D < BestAbsDY then
    begin
      BestAbsDY := D;
      BestDY := CandDY;
      BestGuideY := OtherBottom;
    end;

    CandDY := OtherCenterY - DragCenterY;
    D := Abs(CandDY);
    if D < BestAbsDY then
    begin
      BestAbsDY := D;
      BestDY := CandDY;
      BestGuideY := OtherCenterY;
    end;
  end;

  if BestAbsDX <= FNodeSnapDistance then
  begin
    AOffsetX := AOffsetX + BestDX;
    FGuideSnapXActive := True;
    FGuideSnapX := BestGuideX;
    ASnappedX := True;
  end;

  if BestAbsDY <= FNodeSnapDistance then
  begin
    AOffsetY := AOffsetY + BestDY;
    FGuideSnapYActive := True;
    FGuideSnapY := BestGuideY;
    ASnappedY := True;
  end;
end;

procedure TNodeEditor.ClearSnapGuides;
begin
  FGuideSnapXActive := False;
  FGuideSnapYActive := False;
  FGuideSnapX := 0;
  FGuideSnapY := 0;
end;

procedure TNodeEditor.DrawSnapGuides;
begin
  var Handled := False;
  if Assigned(FOnDrawSnapGuides) then
    FOnDrawSnapGuides(Self, Canvas,
      FGuideSnapXActive, FGuideSnapYActive, FGuideSnapX, FGuideSnapY,
      FZoom, FOffsetX, FOffsetY, Handled);

  if Handled then
    Exit;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Dash := FGuideLineStyle;
  Canvas.Stroke.Thickness := FGuideLineWidth;
  Canvas.Stroke.Color := FGuideLineColor;

  Canvas.Stroke.Kind := TBrushKind.Gradient;
  Canvas.Stroke.Gradient.Style := TGradientStyle.Linear;
  Canvas.Stroke.Gradient.Points.Clear;
  AddGradientPoint(Canvas.Stroke.Gradient, 0.0, MakeColor(FGuideLineColor, 0));
  AddGradientPoint(Canvas.Stroke.Gradient, 0.3, FGuideLineColor);
  AddGradientPoint(Canvas.Stroke.Gradient, 0.7, FGuideLineColor);
  AddGradientPoint(Canvas.Stroke.Gradient, 1.0, MakeColor(FGuideLineColor, 0));

  if FGuideSnapXActive then
  begin
    Canvas.Stroke.Gradient.StartPosition.Point := PointF(0.5, 0);
    Canvas.Stroke.Gradient.StopPosition.Point := PointF(0.5, 1);

    var SX := FGuideSnapX * FZoom + FOffsetX;
    Canvas.DrawLine(PointF(Round(SX) + 0.5, 0 + 0.5), PointF(Round(SX) + 0.5, Round(Height) + 0.5), 1);
  end;

  if FGuideSnapYActive then
  begin
    Canvas.Stroke.Gradient.StartPosition.Point := PointF(0, 0.5);
    Canvas.Stroke.Gradient.StopPosition.Point := PointF(1, 0.5);

    var SY := FGuideSnapY * FZoom + FOffsetY;
    Canvas.DrawLine(PointF(0 + 0.5, Round(SY) + 0.5), PointF(Round(Width) + 0.5, Round(SY) + 0.5), 1);
  end;

  // Reset
  Canvas.Stroke.Gradient.StartPosition.Point := PointF(0, 0);
  Canvas.Stroke.Gradient.StopPosition.Point := PointF(0, 1);
  Canvas.Stroke.Gradient.Points.Clear;
  TGradientPoint(Canvas.Stroke.Gradient.Points.Add).Offset := 0;
  TGradientPoint(Canvas.Stroke.Gradient.Points.Add).Offset := 1;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1;
end;

function TNodeEditor.AddLink(APinFrom, APinTo: TNodePin): Boolean;
begin
  var AllowConnect := True;
  if Assigned(FOnBeforeConnectPins) then
    FOnBeforeConnectPins(Self, APinFrom, APinTo, AllowConnect);

  if AllowConnect and not FController.LinkExists(APinFrom, APinTo) then
  begin
    FController.AddLink(APinFrom, APinTo);
    if Assigned(FOnAfterConnectPins) then
      FOnAfterConnectPins(Self, APinFrom, APinTo);
    Exit(True);
  end;
  Result := False;
end;

procedure TNodeEditor.AddNode(ANode: TCustomNode);
begin
  FController.AddNode(ANode);
end;

procedure TNodeEditor.RemoveNode(ANode: TCustomNode);
begin
  FController.RemoveNode(ANode);
end;

procedure TNodeEditor.RemoveLink(ALink: TNodeLink);
begin
  FController.RemoveLink(ALink);
end;

procedure TNodeEditor.Clear;
begin
  FController.Clear;
  ResetStateAfterGraphReload;
end;

procedure TNodeEditor.Undo;
begin
  FController.Undo;
  ResetStateAfterGraphReload;
end;

procedure TNodeEditor.Redo;
begin
  FController.Redo;
  ResetStateAfterGraphReload;
end;

function TNodeEditor.SaveToJSONText: string;
begin
  Result := FController.SaveToJSONText(FZoom, FOffsetX, FOffsetY);
end;

procedure TNodeEditor.LoadFromJSONText(const JSON: string);
var
  Z: Double;
  OX, OY: Double;
begin
  if JSON.Trim.IsEmpty then
    Exit;

  FController.LoadFromJSONText(JSON, Z, OX, OY);

  FZoom := Z;
  FOffsetX := OX;
  FOffsetY := OY;

  ResetStateAfterGraphReload;
  InternalWorldChanged;
end;

procedure TNodeEditor.SaveToFile(const AFileName: string);
begin
  FController.SaveToFile(AFileName, FZoom, FOffsetX, FOffsetY);
end;

procedure TNodeEditor.LoadFromFile(const AFileName: string);
begin
  FController.LoadFromFile(AFileName, FZoom, FOffsetX, FOffsetY);

  ResetStateAfterGraphReload;
  InternalWorldChanged;
end;

function TNodeEditor.GetPrimarySelectedNode: TCustomNode;
begin
  if FController.Selection.NodeCount > 0 then
    Result := GetSelectedNode(0)
  else
    Result := nil;
end;

function TNodeEditor.GetSelectedPin(Index: integer): TNodePin;
begin
  Result := FController.Selection.GetPin(Index);
end;

function TNodeEditor.GetPrimarySelectedLink: TNodeLink;
begin
  if FController.Selection.LinkCount > 0 then
    Result := FController.Selection.GetLink(0)
  else
    Result := nil;
end;

procedure TNodeEditor.DeleteSelection;
begin
  FController.DeleteSelection;
  ResetStateAfterGraphReload;
end;

procedure TNodeEditor.ClearSelection;
begin
  if FController.Selection.SelectedCount > 0 then
    FController.Selection.Clear;
end;

procedure TNodeEditor.SelectNodeInternal(ANode: TCustomNode; AAppend: Boolean);
begin
  if ANode = nil then
    Exit;

  if not AAppend then
    FController.Selection.ClearPins(False)
  else if FController.Selection.LinkCount > 0 then
    FController.Selection.Links.Clear;

  FController.Selection.SelectNode(ANode, AAppend);
end;

procedure TNodeEditor.SelectLinkInternal(ALink: TNodeLink; AKeepNodes: Boolean);
begin
  if ALink = nil then
    Exit;

  if not AKeepNodes then
    FController.Selection.Clear;
  FController.Selection.SelectLink(ALink, True);
end;

procedure TNodeEditor.ToggleNodeSelection(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  FController.Selection.ClearPins(False);
  if FController.Selection.ContainsNode(ANode) then
    FController.Selection.RemoveNode(ANode)
  else
    FController.Selection.SelectNode(ANode, True);
end;

procedure TNodeEditor.RemoveNodeFromSelection(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  FController.Selection.RemoveNode(ANode);
end;

procedure TNodeEditor.ToggleLinkSelection(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  if FController.Selection.ContainsLink(ALink) then
    FController.Selection.RemoveLinkFromSelection(ALink)
  else
  begin
    FController.Selection.ClearPins(False);
    FController.Selection.AddLinkToSelection(ALink);
  end;
end;

procedure TNodeEditor.NotifySelectionChanged;
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self);
end;

procedure TNodeEditor.ControllerChanged(Sender: TObject);
begin
  if Assigned(FOnGraphChanged) then
    FOnGraphChanged(Self);
end;

procedure TNodeEditor.ControllerSelectionChanged(Sender: TObject);
begin
  NotifySelectionChanged;
  InvalidateSortedNodes;
  Repaint;
end;

procedure TNodeEditor.UpdatePinsConnectedState;
begin
  if FGraph = nil then
    Exit;
  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    var N := FGraph.Nodes[i];
    if N = nil then
      Continue;
    for var j := 0 to N.InputCount - 1 do
    begin
      var P := N.GetInput(j);
      if P <> nil then
        P.Connected := False;
    end;
    for var j := 0 to N.OutputCount - 1 do
    begin
      var P := N.GetOutput(j);
      if P <> nil then
        P.Connected := False;
    end;
  end;
  for var i := 0 to FGraph.Links.Count - 1 do
  begin
    var L := FGraph.Links[i];
    if L = nil then
      Continue;
    if L.FromPin <> nil then
      L.FromPin.Connected := True;

    if L.ToPin <> nil then
      L.ToPin.Connected := True;
  end;
end;

function TNodeEditor.SelectedNodeCount: Integer;
begin
  Result := FController.Selection.NodeCount;
end;

function TNodeEditor.SelectedLinkCount: Integer;
begin
  Result := FController.Selection.LinkCount;
end;

function TNodeEditor.SelectedPinCount: Integer;
begin
  Result := FController.Selection.PinCount;
end;

function TNodeEditor.GetSelectedNode(Index: Integer): TCustomNode;
begin
  Result := FController.Selection.GetNode(Index);
end;

procedure TNodeEditor.SelectNode(ANode: TCustomNode; AAppend: Boolean);
begin
  SelectNodeInternal(ANode, AAppend);
end;

procedure TNodeEditor.SelectLink(ALink: TNodeLink);
begin
  SelectLinkInternal(ALink);
end;

function TNodeEditor.WorldToScreen(WX, WY: Single): TPointF;
begin
  Result.X := WX * FZoom + FOffsetX;
  Result.Y := WY * FZoom + FOffsetY;
end;

function TNodeEditor.GetVisibleWorldRect: TRectF;
begin
  Result := TRectF.Create(ScreenToWorld(0, 0), ScreenToWorld(Width, Height), True);
end;

procedure TNodeEditor.UpdateScrollBars(Recalc: Boolean);
var
  B: TRectF;
  MinX, MaxX: Single;
  MinY, MaxY: Single;
begin
  if Recalc or (FScrollLastZoom <> FZoom) then
  begin
    FScrollLastContentSize := GetContentSize;
    FScrollLastContentSizeScaled := FScrollLastContentSize;
    FScrollLastContentSizeScaled := RectF(FScrollLastContentSizeScaled.Left * FZoom, FScrollLastContentSizeScaled.Top * FZoom, FScrollLastContentSizeScaled.Right * FZoom, FScrollLastContentSizeScaled.Bottom * FZoom);
    FScrollLastContentSizeScaled.Inflate(100 * Zoom, 100 * Zoom);
  end;

  FScrollLastZoom := FZoom;
  B := FScrollLastContentSizeScaled;

  // горизонталь
  MinX := Min(B.Left, B.Right - Width);
  MaxX := Max(B.Left, B.Right - Width);

  FHorzScroll.BeginUpdate;
  try
    //FHorzScroll.ValueRange.ViewportSize := 1000;
    FHorzScroll.Min := MinX;
    FHorzScroll.Max := MaxX;
    FHorzScroll.Visible := (B.Left < -FOffsetX) or (B.Right > -FOffsetX + Width);

    FHorzScroll.Value := -FOffsetX;
  finally
    FHorzScroll.EndUpdate;
  end;

  // вертикаль
  MinY := Min(B.Top, B.Bottom - Height);
  MaxY := Max(B.Top, B.Bottom - Height);

  FVertScroll.BeginUpdate;
  try
    //FVertScroll.ValueRange.ViewportSize := 1000;
    FVertScroll.Min := MinY;
    FVertScroll.Max := MaxY;
    FVertScroll.Visible := (B.Top < -FOffsetY) or (B.Bottom > -FOffsetY + Height);

    FVertScroll.Value := -FOffsetY;
  finally
    FVertScroll.EndUpdate;
  end;
end;

procedure TNodeEditor.InternalWorldChanged;
begin
  FAni.ViewportPosition := PointF(-FOffsetX, -FOffsetY);
  InvalidateSortedNodes;
  UpdateScrollBars(False);
  UpdatedStatus;
  Repaint;
end;

procedure TNodeEditor.HorzScrollChange(Sender: TObject);
begin
  if FHorzScroll.IsUpdating then
    Exit;
  FOffsetX := -FHorzScroll.Value;
  InternalWorldChanged;
end;

procedure TNodeEditor.VertScrollChange(Sender: TObject);
begin
  if FVertScroll.IsUpdating then
    Exit;
  FOffsetY := -FVertScroll.Value;
  InternalWorldChanged;
end;

function TNodeEditor.ScreenToWorld(SX, SY: Double): TPointF;
begin
  Result.X := (SX - FOffsetX) / FZoom;
  Result.Y := (SY - FOffsetY) / FZoom;
end;

function TNodeEditor.ScreenToWorld(const Value: TPointF): TPointF;
begin
  Result.X := (Value.X - FOffsetX) / FZoom;
  Result.Y := (Value.Y - FOffsetY) / FZoom;
end;

function TNodeEditor.ScreenToWorld(SX, SY, AZoom: Double): TPointF;
begin
  Result.X := (SX - FOffsetX) / AZoom;
  Result.Y := (SY - FOffsetY) / AZoom;
end;

function TNodeEditor.SnapWorldValue(Value: Single): Single;
begin
  if FSnapToGrid and (FGridSize > 1) then
    Result := Round(Value / FGridSize) * FGridSize
  else
    Result := Value;
end;

procedure TNodeEditor.DrawNode(ANode: TCustomNode; const NodeBounds: TRectF);
begin
  // Override drawing
  var Handled := False;
  if Assigned(FOnDrawNode) then
    FOnDrawNode(Self, Canvas, ANode, NodeBounds, FZoom, FOffsetX, FOffsetY, Handled);

  // Draw node
  if not Handled then
    ANode.Paint(Canvas, NodeBounds, FZoom, FOffsetX, FOffsetY);
end;

function TNodeEditor.SnapWorldPoint(const P: TPointF): TPointF;
begin
  if FSnapToGrid and (FGridSize > 1) then
  begin
    Result.X := Round(P.X / FGridSize) * FGridSize;
    Result.Y := Round(P.Y / FGridSize) * FGridSize;
  end
  else
    Result := P;
end;

function TNodeEditor.GetNodeUnderMouse(SX, SY: Single): TCustomNode;
begin
  Result := nil;
  var W := ScreenToWorld(SX, SY);
  EnsureSortedNodes;

  for var i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    var N := FPaintNodesSorted[i];
    if (N.VisualKind <> TNodeVisualKind.Comment) and N.HitTest(W.X, W.Y) then
      Exit(N);
  end;

  for var i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    var N := FPaintNodesSorted[i];
    if (N.VisualKind = TNodeVisualKind.Comment) and N.HitTest(W.X, W.Y) then
      Exit(N);
  end;
end;

function TNodeEditor.GetPinUnderMouse(SX, SY: Single; out Node: TCustomNode; out Pin: TNodePin): Boolean;
var
  i, j: integer;
  N: TCustomNode;
  P: TNodePin;
  W, PW: TPointF;
  HitRadiusWorld: Single;
begin
  Result := False;
  Node := nil;
  Pin := nil;
  if FZoom < TCustomNode.ZoomDetailLimitExt then
    Exit;

  W := ScreenToWorld(SX, SY);
  var S := PointF(SX, SY);
  var MouseInNode := False;
  EnsureSortedNodes;

  for i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    if MouseInNode then
      Exit;
    N := FPaintNodesSorted[i];
    if N.VisualKind = TNodeVisualKind.Comment then
      Continue;
    if N.VisualKind = TNodeVisualKind.Reroute then
      HitRadiusWorld := TCustomNode.PinRadius
    else
      HitRadiusWorld := TCustomNode.PinRadius + 2;

    var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
    MouseInNode := R.Contains(S);
    R.Inflate(HitRadiusWorld * FZoom, HitRadiusWorld * FZoom);
    if not R.Contains(S) then
      Continue;

    var SkipInput := False;
    if N.VisualKind = TNodeVisualKind.Reroute then
    begin
      if N.OutputsIsBusy and N.InputsIsBusy then
        Continue;
      if FReconnectFixedPin <> nil then
        SkipInput := FReconnectFixedPin.Direction = TPinDirection.Input
      else if FTempFromPin <> nil then
        SkipInput := FTempFromPin.Direction = TPinDirection.Input
      else
        SkipInput := not N.OutputsIsBusy;
    end;

    if not SkipInput then
      for j := 0 to N.InputCount - 1 do
      begin
        P := N.GetInput(j);
        if P.Hidden then
          Continue;

        PW := P.GetPinWorldPosition;
        if Hypot(W.X - PW.X, W.Y - PW.Y) <= HitRadiusWorld then
        begin
          Node := N;
          Pin := P;
          Exit(True);
        end;
      end;

    for j := 0 to N.OutputCount - 1 do
    begin
      P := N.GetOutput(j);
      if P.Hidden then
        Continue;

      PW := P.GetPinWorldPosition;
      if Hypot(W.X - PW.X, W.Y - PW.Y) <= HitRadiusWorld then
      begin
        Node := N;
        Pin := P;
        Exit(True);
      end;
    end;
  end;
end;

function TNodeEditor.GetLinkColor: TAlphaColor;
begin
  Result := TNodeLink.DefaultColor;
end;

function TNodeEditor.GetLinkThickness: Single;
begin
  Result := TNodeLink.Thickness;
end;

function TNodeEditor.GetLinkUnderMouse(SX, SY: Single; out Link: TNodeLink): Boolean;
begin
  Result := False;
  Link := nil;
  if FZoom < TCustomNode.ZoomDetailLimitExt then
    Exit;

  for var i := FGraph.Links.Count - 1 downto 0 do
  begin
    var L := FGraph.Links[i];
    if (L = nil) or (L.FromPin = nil) or (L.ToPin = nil) then
      Continue;
    if (L.FromPin.OwnerNode = nil) or (L.ToPin.OwnerNode = nil) then
      Continue;
    if L.HitTest(SX, SY, FZoom, FOffsetX, FOffsetY) then
    begin
      Link := L;
      Exit(True);
    end;
  end;
end;

procedure TNodeEditor.DrawMiniGrid(ACanvas: TCanvas; const ARect: TRectF; AOffsetX, AOffsetY, AZoom: Double);

  function MiniScreenToWorld(SX, SY: Double): TPointF;
  begin
    Result.X := (SX - AOffsetX);
    Result.Y := (SY - AOffsetY);
  end;

  function MiniGetVisibleWorldRect: TRectF;
  begin
    var P0 := MiniScreenToWorld(0, 0);
    var P1 := MiniScreenToWorld(ARect.Width, ARect.Height);
    Result := TRectF.Create(P0, P1, True);
  end;

begin
  var VR := MiniGetVisibleWorldRect;

  ACanvas.Stroke.Color := $22E0E0E0;
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Thickness := 1;

  var SmallStep := 14;

  var X := Floor(VR.Left / SmallStep) * SmallStep;
  while X <= VR.Right do
  begin
    var SX := Trunc(X * 1 + AOffsetX);
    var P1 := PointF(SX, 0);
    var P2 := PointF(SX, ARect.Height);
    P1.Offset(0.5, 0.5);
    P2.Offset(0.5, 0.5);
    ACanvas.DrawLine(P1, P2, AbsoluteOpacity);
    X := X + SmallStep;
  end;

  var Y := Floor(VR.Top / SmallStep) * SmallStep;
  while Y <= VR.Bottom do
  begin
    var SY := Trunc(Y * 1 + AOffsetY);
    var P1 := PointF(0, SY);
    var P2 := PointF(ARect.Width, SY);
    P1.Offset(0.5, 0.5);
    P2.Offset(0.5, 0.5);
    ACanvas.DrawLine(P1, P2, AbsoluteOpacity);
    Y := Y + SmallStep;
  end;

  ACanvas.Stroke.Dash := TStrokeDash.Solid;
end;

procedure TNodeEditor.DrawGrid;
begin
  const LargeStep = 8;
  var WR := GetVisibleWorldRect;

  // Defaults
  Canvas.Stroke.Thickness := 1 * FZoom;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FGridColor;

  // Override draw
  var Handled := False;
  if Assigned(FOnDrawGrid) then
    FOnDrawGrid(Self, Canvas, WR, FZoom, FOffsetX, FOffsetY, Handled);
  if Handled then
    Exit;

  if FGridSize <= 0 then
    Exit;

  // Vert
  var WorldX := Floor(WR.Left / FGridSize) * FGridSize;
  while WorldX <= WR.Right do
  begin
    var ScreenX := WorldX * Zoom + FOffsetX;

    if (Round(WorldX / FGridSize) mod LargeStep) = 0 then
      Canvas.Stroke.Thickness := 2 * FZoom
    else
      Canvas.Stroke.Thickness := 1 * FZoom;

    if SameValue(Round(Canvas.Stroke.Thickness), Canvas.Stroke.Thickness, TEpsilon.Position) and (Round(Canvas.Stroke.Thickness) mod 2 <> 0) then
      Canvas.DrawLine(PointF(Round(ScreenX) + 0.5, 0 + 0.5), PointF(Round(ScreenX) + 0.5, Round(Height) + 0.5), AbsoluteOpacity)
    else
      Canvas.DrawLine(PointF(ScreenX, 0), PointF(ScreenX, Height), AbsoluteOpacity);

    WorldX := WorldX + FGridSize;
  end;

  // Horz
  var WorldY := Floor(WR.Top / FGridSize) * FGridSize;
  while WorldY <= WR.Bottom do
  begin
    var ScreenY := WorldY * Zoom + FOffsetY;

    if (Round(WorldY / FGridSize) mod LargeStep) = 0 then
      Canvas.Stroke.Thickness := 2 * FZoom
    else
      Canvas.Stroke.Thickness := 1 * FZoom;

    if SameValue(Round(Canvas.Stroke.Thickness), Canvas.Stroke.Thickness, TEpsilon.Position) and (Round(Canvas.Stroke.Thickness) mod 2 <> 0) then
      Canvas.DrawLine(PointF(0 + 0.5, Round(ScreenY) + 0.5), PointF(Round(Width) + 0.5, Round(ScreenY) + 0.5), AbsoluteOpacity)
    else
      Canvas.DrawLine(PointF(0, ScreenY), PointF(Width, ScreenY), AbsoluteOpacity);

    WorldY := WorldY + FGridSize;
  end;
end;

procedure TNodeEditor.DrawAxes;
begin
  var WR := GetVisibleWorldRect;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FAxesColor;
  Canvas.Stroke.Thickness := FAxesThickness;

  if (WR.Left <= 0) and (WR.Right >= 0) then
  begin
    var SX := WorldToScreen(0, 0).X;
    Canvas.DrawLine(Canvas.AlignToPixel(PointF(SX, 0)), Canvas.AlignToPixel(PointF(SX, Height)), 1);
  end;
  if (WR.Top <= 0) and (WR.Bottom >= 0) then
  begin
    var SY := WorldToScreen(0, 0).Y;
    Canvas.DrawLine(Canvas.AlignToPixel(PointF(0, SY)), Canvas.AlignToPixel(PointF(Width, SY)), 1);
  end;
end;

procedure TNodeEditor.DrawLinks;
begin
  var R := FScreenRect;
  //R.Inflate(20 * FZoom, 20 * FZoom);
  for var Link in FGraph.Links do
  begin
    if (Link.FromPin = nil) or (Link.ToPin = nil) then
      Continue;

    //Debug rect
    //Canvas.DrawRect(Link.GetScreenBounds(FZoom, FOffsetX, FOffsetY), 0, 0, [], 1);

    if not R.IntersectsWith(Link.GetScreenBounds(FZoom, FOffsetX, FOffsetY)) then
      Continue;

    var IsSelected := FController.Selection.ContainsLink(Link);
    var IsHovered := Link = FHoveredLink;
    Link.OnScreen := True;
    var Handled := False;
    if Assigned(FOnDrawLink) then
      FOnDrawLink(Self, Canvas, Link, IsSelected, IsHovered, Handled);

    if not Handled then
      Link.Paint(Canvas, FZoom, FOffsetX, FOffsetY, IsSelected, IsHovered, AbsoluteOpacity);
  end;
end;

procedure TNodeEditor.DrawTempLink;
var
  W0, W3: TPointF;
  StartPin: TNodePin;
  FixedPosW: TPointF;
begin
  StartPin := FTempFromPin;

  if FReconnectingLink and (FReconnectFixedPin <> nil) then
  begin
    FixedPosW := FReconnectFixedPin.GetPinWorldPosition;

    if FReconnectMovingFromSide then
    begin
      W0 := ScreenToWorld(FTempMousePos.X, FTempMousePos.Y);
      W3 := FixedPosW;
    end
    else
    begin
      W0 := FixedPosW;
      W3 := ScreenToWorld(FTempMousePos.X, FTempMousePos.Y);
      StartPin := FReconnectFixedPin;
    end;
  end
  else
  begin
    W0 := FTempFromPin.GetPinWorldPosition;
    W3 := ScreenToWorld(FTempMousePos.X, FTempMousePos.Y);
  end;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FHighlightColor;
  Canvas.Stroke.Thickness := TNodeLink.Thickness * FZoom;
  Canvas.Stroke.Dash := TStrokeDash.Dot;

  TNodeLink.VisualClass.DrawLink(Canvas, W0, W3, FZoom, FOffsetX, FOffsetY, 1, StartPin.Direction = TPinDirection.Input);
end;

procedure TNodeEditor.DrawBoxSelect;
begin
  var R := RectF(FBoxStart.X, FBoxStart.Y, FBoxCurrent.X, FBoxCurrent.Y);
  R.NormalizeRect;
  R.Offset(0.5, 0.5); //fix half pixel
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FHighlightColor;
  Canvas.Stroke.Dash := TStrokeDash.Dash;
  Canvas.Stroke.Thickness := Max(1, Round(1 * FZoom));
  Canvas.FillRect(R, 0.05);
  Canvas.DrawRect(R, 1);
end;

procedure TNodeEditor.DrawMoveHint;
begin
  var CX := GetPrimarySelectedNode.X;
  var CY := GetPrimarySelectedNode.Y;
  var Dx := CX - FDragStartWorldPos.X;
  var Dy := CY - FDragStartWorldPos.Y;

  var Text := Format('X: %.1f   Y: %.1f   (Δ %.1f, %.1f)', [CX, CY, Dx, Dy]);
  Canvas.Font.Size := 12;
  var TextW := Canvas.TextWidth(Text) + 20;
  var TextH := Canvas.TextHeight(Text) + 20;

  var ArrowSize := 8;
  var Pos := WorldToScreen(CX, CY);
  Pos.Offset(GetPrimarySelectedNode.Width * Zoom / 2, 0);

  // Bounds position
  var OldPos := Pos;
  Pos := PointF(
    EnsureRange(Pos.X, TextW / 2, Width - TextW / 2),
    EnsureRange(Pos.Y, TextH + ArrowSize, Height));

  // Bounds
  var R := RectF(Pos.X - TextW * 0.5, Pos.Y, Pos.X + TextW * 0.5, Pos.Y + TextH);
  R.Offset(0, -R.Height - ArrowSize);

  Canvas.Fill.Kind := TBrushKind.Solid;

  // Shadow
  Canvas.Fill.Color := $20000000;
  Canvas.FillRect(RectF(R.Left, R.Top + 3, R.Right, R.Bottom + 3), 10, 10, AllCorners, 1);

  // Background
  Canvas.Fill.Color := $CC2B2D30;
  Canvas.FillRect(R, 10, 10, AllCorners, 1);

  // Border
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Color := $30FFFFFF;
  Canvas.DrawRect(R, 10, 10, AllCorners, 1);

  // Top inner highlight
  Canvas.Stroke.Color := $18FFFFFF;
  Canvas.DrawLine(PointF(R.Left + 10, R.Top + 1), PointF(R.Right - 10, R.Top + 1), 1);

  // Arrow
  if Pos = OldPos then
  begin
    var Arrow: TPolygon;
    SetLength(Arrow, 3);
    Arrow[0] := PointF(Pos.X - ArrowSize, R.Bottom - 1);
    Arrow[1] := PointF(Pos.X + ArrowSize, R.Bottom - 1);
    Arrow[2] := PointF(Pos.X, R.Bottom + ArrowSize);
    Canvas.Fill.Color := $EE2B2D30;
    Canvas.FillPolygon(Arrow, 1);
    Canvas.Stroke.Color := $30FFFFFF;
    Canvas.DrawPolygon(Arrow, 1);
  end;

  // Text
  Canvas.Fill.Color := $FFF2F2F2;
  Canvas.FillText(R, Text, False, 1, [], TTextAlign.Center, TTextAlign.Center);
end;

procedure TNodeEditor.DrawNodes(FirstLevel: Boolean);
begin
  if FirstLevel then
  begin
    for var N in FPaintNodesSorted do
    begin
      if (N.VisualKind = TNodeVisualKind.Comment) and not N.Selected then
      begin
        var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
        DrawNode(N, R);
      end;
    end;

    for var N in FPaintNodesSorted do
    begin
      if (N.VisualKind = TNodeVisualKind.Comment) and N.Selected then
      begin
        var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
        DrawNode(N, R);
      end;
    end;
  end
  else
  begin
    for var N in FPaintNodesSorted do
    begin
      if (N.VisualKind <> TNodeVisualKind.Comment) and not N.Selected then
      begin
        var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
        DrawNode(N, R);
      end;
    end;

    for var N in FPaintNodesSorted do
    begin
      if (N.VisualKind <> TNodeVisualKind.Comment) and N.Selected then
      begin
        var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
        DrawNode(N, R);
      end;
    end;
  end;
end;

procedure TNodeEditor.BeginPaint;
begin
  FFrameTimeWatch := TStopWatch.StartNew;
  Canvas.Stroke.Cap := TStrokeCap.Round;
  Canvas.Stroke.Join := TStrokeJoin.Round;
  //Canvas.Fill.Kind := TBrushKind.Solid;
  //Canvas.Fill.Color := TAlphaColors.Null;
  //Canvas.FillRect(LocalRect, 7, 7, AllCorners, 1);
  EnsureSortedNodes;
  for var i := 0 to FGraph.Links.Count - 1 do
    FGraph.Links[i].OnScreen := False;
end;

procedure TNodeEditor.BringNodeToFront(ANode: TCustomNode);
begin
  FController.BringNodeToFront(ANode);
end;

procedure TNodeEditor.SendNodeToBack(ANode: TCustomNode);
begin
  FController.SendNodeToBack(ANode);
end;

procedure TNodeEditor.EndPaint;
begin
  FFrameTimeWatch.Stop;
end;

procedure TNodeEditor.DrawFrameTime;
begin
  var TimeMS := FFrameTimeWatch.ElapsedMilliseconds;
  Canvas.Font.Size := 12;
  Canvas.Font.Style := [TFontStyle.fsBold];
  Canvas.Fill.Color := TAlphaColors.White;

  var Text := TimeMS.ToString + 'ms, ' +
    '~fps ' + Trunc(1000 / Max(1, TimeMS)).ToString + #13#10 +
    'Canvas: ' + Canvas.ClassName + #13#10 +
    'Context: ' + TContextManager.DefaultContextClass.ClassName + #13#10 +
    Format('X: %f, Y: %f', [FOffsetX, FOffsetY]) + #13#10 +
    Format('Paint nodes: %d', [FPaintNodesSorted.Count]);
  var Path := TPathData.Create;
  try
    Canvas.TextToPath(Path, RectF(15, 15, 500, 500), Text, False, TTextAlign.Leading, TTextAlign.Leading);
    Path.Translate(15, 15);
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := TAlphaColors.White;
    Canvas.Stroke.Dash := TStrokeDash.Solid;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := TAlphaColors.Black;
    Canvas.Stroke.Thickness := 2;
    Canvas.DrawPath(Path, 1);
    Canvas.FillPath(Path, 1);
  finally
    Path.Free;
  end;
  Canvas.Font.Size := 12;
  Canvas.Font.Style := [];
  //Canvas.FillText(RectF(20, 20, 500, 500), Text, False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
end;

procedure TNodeEditor.Paint;
begin
  BeginPaint;

  // Grid
  if FShowGrid then
    DrawGrid;

  // Axes
  if FShowAxes then
    DrawAxes;

  // Nodes and links
  DrawNodes(True);
  DrawLinks;
  DrawNodes(False);

  // Snap guides
  if DraggingNode and FShowSnapGuides then
    DrawSnapGuides;

  // Link connector
  if FTempFromPin <> nil then
    DrawTempLink;

  // Box selectiing
  if FBoxSelecting then
    DrawBoxSelect;

  // Node hint
  if DraggingNode and FShowDragCoordinates and (GetPrimarySelectedNode <> nil) then
    DrawMoveHint;

  EndPaint;

  // Draw frame time
  if FShowFrameTime then
    DrawFrameTime;
end;

function TNodeEditor.GetNodeResizeUnderMouse(SX, SY: Single): TCustomNode;
begin
  Result := nil;

  var NodeUnderMouse := GetNodeUnderMouse(SX, SY);
  if Assigned(NodeUnderMouse) then
  begin
    if NodeUnderMouse.ResizeHandleHitTest(SX, SY, FZoom, FOffsetX, FOffsetY) then
      Exit(NodeUnderMouse);
  end;
end;

procedure TNodeEditor.BuildContextMenu;
begin
  FPopupMenu.Clear;

  var Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Search Node...');
  Item.OnClick := OnContextSearchNode;
  FPopupMenu.AddObject(Item);

  var Sep := TMenuItem.Create(FPopupMenu);
  Sep.Text := '-';
  FPopupMenu.AddObject(Sep);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Undo');
  Item.StyleLookup := 'menuitemstyle_undo';
  Item.ShortCut := TextToShortCut('Ctrl+Z');
  Item.OnClick := OnContextUndo;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Redo');
  Item.StyleLookup := 'menuitemstyle_redo';
  Item.ShortCut := TextToShortCut('Ctrl+Shift+Z');
  Item.OnClick := OnContextRedo;
  FPopupMenu.AddObject(Item);

  Sep := TMenuItem.Create(FPopupMenu);
  Sep.Text := '-';
  FPopupMenu.AddObject(Sep);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Cut');
  Item.StyleLookup := 'menuitemstyle_cut';
  Item.ShortCut := TextToShortCut('Ctrl+X');
  Item.OnClick := OnContextCut;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Copy');
  Item.StyleLookup := 'menuitemstyle_copy';
  Item.ShortCut := TextToShortCut('Ctrl+C');
  Item.OnClick := OnContextCopy;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Paste');
  Item.StyleLookup := 'menuitemstyle_paste';
  Item.ShortCut := TextToShortCut('Ctrl+V');
  Item.OnClick := OnContextPaste;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Duplicate');
  Item.StyleLookup := 'menuitemstyle_copy';
  Item.ShortCut := TextToShortCut('Ctrl+D');
  Item.OnClick := OnContextDuplicate;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Delete');
  Item.StyleLookup := 'menuitemstyle_delete';
  Item.ShortCut := TextToShortCut('Del');
  Item.OnClick := OnContextDelete;
  FPopupMenu.AddObject(Item);

  Sep := TMenuItem.Create(FPopupMenu);
  Sep.Text := '-';
  FPopupMenu.AddObject(Sep);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Select All');
  Item.StyleLookup := 'menuitemstyle_selectall';
  Item.ShortCut := TextToShortCut('Ctrl+A');
  Item.OnClick := OnContextSelectAll;
  FPopupMenu.AddObject(Item);

  Sep := TMenuItem.Create(FPopupMenu);
  Sep.Text := '-';
  FPopupMenu.AddObject(Sep);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Insert Reroute On Selected Link');
  Item.OnClick := OnContextInsertReroute;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Add Comment / Frame');
  Item.OnClick := OnContextAddComment;
  FPopupMenu.AddObject(Item);
end;

procedure TNodeEditor.OnContextSelectAll(Sender: TObject);
begin
  SelectAll;
end;

procedure TNodeEditor.OnContextUndo(Sender: TObject);
begin
  Undo;
end;

procedure TNodeEditor.OnContextRedo(Sender: TObject);
begin
  Redo;
end;

procedure TNodeEditor.OnContextCut(Sender: TObject);
begin
  CutSelectionToClipboard;
end;

procedure TNodeEditor.OnContextCopy(Sender: TObject);
begin
  CopySelectionToClipboard;
end;

procedure TNodeEditor.OnContextPaste(Sender: TObject);
begin
  PasteFromClipboard;
end;

procedure TNodeEditor.OnContextDuplicate(Sender: TObject);
begin
  DuplicateSelection;
end;

procedure TNodeEditor.OnContextDelete(Sender: TObject);
begin
  DeleteSelection;
end;

procedure TNodeEditor.OnContextSearchNode(Sender: TObject);
begin
  ShowNodeSearchPopup(Screen.MousePos, FLastWorldMousePos);
end;

procedure TNodeEditor.OnContextInsertReroute(Sender: TObject);
begin
  if GetPrimarySelectedLink = nil then
    Exit;

  FController.InsertRerouteOnLink(GetPrimarySelectedLink, SnapWorldPoint(FLastWorldMousePos));
end;

procedure TNodeEditor.OnContextAddComment(Sender: TObject);
begin
  FController.AddCommentNode(SnapWorldPoint(FLastWorldMousePos));
end;

procedure TNodeEditor.CopySelectionToClipboard;
begin
  FController.CopySelectionToClipboard;
end;

procedure TNodeEditor.CutSelectionToClipboard;
begin
  FController.CutSelectionToClipboard;
end;

procedure TNodeEditor.PasteFromClipboard;
begin
  FController.PasteFromClipboard(SnapWorldPoint(ScreenToWorld(FLastMousePos)));
end;

procedure TNodeEditor.DuplicateSelection;
begin
  var W := ScreenToWorld(FLastMousePos);
  W.Offset(25, 25);
  FController.DuplicateSelection(SnapWorldPoint(W));
end;

function TNodeEditor.AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := FController.AddInputPinToNode(ANode, AName, ADataType, AKind);

  if (Result <> nil) and Assigned(FOnNodeChanged) then
    FOnNodeChanged(Self, ANode);

  Repaint;
end;

function TNodeEditor.AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := FController.AddOutputPinToNode(ANode, AName, ADataType, AKind);

  if (Result <> nil) and Assigned(FOnNodeChanged) then
    FOnNodeChanged(Self, ANode);

  Repaint;
end;

function TNodeEditor.RemovePinFromNode(APin: TNodePin): Boolean;
begin
  var N: TCustomNode;
  if APin <> nil then
    N := APin.OwnerNode
  else
    N := nil;

  Result := FController.RemovePinFromNode(APin);

  if Result and Assigned(FOnNodeChanged) and (N <> nil) then
    FOnNodeChanged(Self, N);

  Repaint;
end;

procedure TNodeEditor.DrawNavigator(ACanvas: TCanvas; const ARect: TRectF);

  function WorldToMini(Rect: TRectF; AZoom, AOffsetX, AOffsetY: Double): TRectF;
  begin
    Result.Left := Rect.Left * AZoom + AOffsetX;
    Result.Top := Rect.Top * AZoom + AOffsetY;
    Result.Right := Result.Left + Rect.Width * AZoom;
    Result.Bottom := Result.Top + Rect.Height * AZoom;
  end;

  function ScreenToMini(Rect: TRectF; AZoom, AOffsetX, AOffsetY: Double): TRectF;
  begin
    Result := WorldToMini(
      TRectF.Create(
        ScreenToWorld(FBoxStart.X, FBoxStart.Y),
        ScreenToWorld(FBoxCurrent.X, FBoxCurrent.Y)),
      AZoom, AOffsetX, AOffsetY);
    Result.NormalizeRect;
  end;

begin
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Clear(TAlphaColors.Null);
  ACanvas.Fill.Color := $FF222222;
  ACanvas.FillRect(ARect, 0, 0, AllCorners, 1);

  var CameraCenter := ScreenToWorld(Width * 0.5, Height * 0.5);
  var WorldRect := TRectF.Create(ScreenToWorld(0, 0), ScreenToWorld(Width, Height));

  // Optimal mini zoom and view
  var DX := Max(Abs(WorldRect.Left - CameraCenter.X), Abs(WorldRect.Right - CameraCenter.X));
  var DY := Max(Abs(WorldRect.Top - CameraCenter.Y), Abs(WorldRect.Bottom - CameraCenter.Y));
  var MiniZoom := Min(0.045, Floor(Min(ARect.Width * 0.5 / DX, ARect.Height * 0.5 / DY) * 1000) / 1000);

  var MiniOffsetX := ARect.CenterPoint.X - CameraCenter.X * MiniZoom;
  var MiniOffsetY := ARect.CenterPoint.Y - CameraCenter.Y * MiniZoom;
  var ViewRect := WorldToMini(WorldRect, MiniZoom, MiniOffsetX, MiniOffsetY);

  // Center dot
  ACanvas.Fill.Color := TAlphaColors.White;
  ACanvas.FillEllipse(TRectF.Create(PointF(MiniOffsetX, MiniOffsetY), 4, 4), 0.8);
  DrawMiniGrid(ACanvas, ARect, MiniOffsetX, MiniOffsetY, MiniZoom);

  if FZoom > 0.05 then
  begin
    // Draw nodes
    EnsureSortedNodes;

    for var i := 0 to FPaintNodesSortedNav.Count - 1 do
    begin
      var N := FPaintNodesSortedNav[i];
      if (N.VisualKind = TNodeVisualKind.Comment) and not N.Selected then
      begin
        var R := N.GetScreenBounds(MiniZoom, MiniOffsetX, MiniOffsetY);
        if ARect.IntersectsWith(R) then
        begin
          ACanvas.Fill.Color := N.HeaderColor;
          ACanvas.FillRect(R, 1);
        end;
      end;
    end;

    for var i := 0 to FPaintNodesSortedNav.Count - 1 do
    begin
      var N := FPaintNodesSortedNav[i];
      if (N.VisualKind = TNodeVisualKind.Comment) and N.Selected then
      begin
        var R := N.GetScreenBounds(MiniZoom, MiniOffsetX, MiniOffsetY);
        if ARect.IntersectsWith(R) then
        begin
          ACanvas.Fill.Color := N.HeaderColor;
          ACanvas.FillRect(R, 1);
        end;
      end;
    end;

    for var i := 0 to FPaintNodesSortedNav.Count - 1 do
    begin
      var N := FPaintNodesSortedNav[i];
      if (N.VisualKind <> TNodeVisualKind.Comment) and not N.Selected then
      begin
        var R := N.GetScreenBounds(MiniZoom, MiniOffsetX, MiniOffsetY);
        if ARect.IntersectsWith(R) then
        begin
          ACanvas.Fill.Color := N.HeaderColor;
          ACanvas.FillRect(R, 1);
        end;
      end;
    end;

    for var i := 0 to FPaintNodesSortedNav.Count - 1 do
    begin
      var N := FPaintNodesSortedNav[i];
      if (N.VisualKind <> TNodeVisualKind.Comment) and N.Selected then
      begin
        var R := N.GetScreenBounds(MiniZoom, MiniOffsetX, MiniOffsetY);
        if ARect.IntersectsWith(R) then
        begin
          ACanvas.Fill.Color := N.HeaderColor;
          ACanvas.FillRect(R, 1);
        end;
      end;
    end;
  end
  else
  begin
    var R := FScrollLastContentSize;
    R := RectF(R.Left * MiniZoom, R.Top * MiniZoom, R.Right * MiniZoom, R.Bottom * MiniZoom);
    R.Offset(MiniOffsetX, MiniOffsetY);
    ACanvas.Fill.Color := TAlphaColors.White;
    ACanvas.FillRect(R, 0, 0, [], 0.2);
  end;

  // Viewport frame
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Color := TAlphaColors.White;
  ACanvas.Stroke.Thickness := 1;
  ViewRect := ViewRect.Truncate;
  ViewRect := ACanvas.AlignToPixel(ViewRect);
  ACanvas.DrawRect(ViewRect, 2, 2, AllCorners, 1);

  // Box selecting
  if FBoxSelecting then
  begin
    var R := ScreenToMini(RectF(FBoxStart.X, FBoxStart.Y, FBoxCurrent.X, FBoxCurrent.Y), MiniZoom, MiniOffsetX, MiniOffsetY);
    ACanvas.Fill.Color := TAlphaColors.White;
    ACanvas.FillRect(R, 0, 0, [], 0.2);
  end;
end;

procedure TNodeEditor.RenderNavigator(Bitmap: TBitmap);
begin
  Bitmap.Canvas.BeginScene;
  try
    DrawNavigator(Bitmap.Canvas, Bitmap.BoundsF);
  finally
    Bitmap.Canvas.EndScene;
  end;
end;

procedure TNodeEditor.ShowNodeSearchPopup(const Position: TPointF; const WorldPosition: TPointF);
begin
  var Form := TFormNodeEditorSearch.CreateSearch(Self, FGraph.Registry);
  try
    Form.Left := Round(EnsureRange(Position.X - Form.Width / 2, 0, Screen.Width - Form.Width));
    Form.Top := Round(EnsureRange(Position.Y - Form.Height / 2, 0, Screen.Height - Form.Height));

    if Form.ShowModal = mrOk then
    begin
      if Form.SelectedNodeType <> '' then
      begin
        var N := FGraph.Registry.CreateNode(Form.SelectedNodeType, SnapWorldPoint(WorldPosition));
        FController.AddNode(N);
        SelectNodeInternal(N, False);
      end;
    end;
  finally
    Form.Free;
  end;
end;

procedure TNodeEditor.ResetStateAfterGraphReload;
begin

  FHoveredNode := nil;
  FHoveredPin := nil;
  FHoveredLink := nil;

  FTempFromPin := nil;
  FDraggingLink := False;
  DraggingNode := False;
  FShowDragCoordinates := False;
  FBoxSelecting := False;
  ResizingNode := False;
  FResizeNode := nil;

  FReconnectingLink := False;
  FReconnectLink := nil;
  FReconnectFixedPin := nil;

  FPanning := False;
  FRightButtonDown := False;
  ReleaseCapture;
  Cursor := crDefault;

  ClearSnapGuides;
  ClearHoverStates;

  FController.Selection.Clear;
  Repaint;
end;

procedure TNodeEditor.Resize;
begin
  inherited;
  FScreenRect := LocalRect;
  InternalWorldChanged;
end;

procedure TNodeEditor.ClearHoverStates;
begin
  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    FGraph.Nodes[i].Hovered := False;
    FGraph.Nodes[i].Highlighted := False;
    FGraph.Nodes[i].HoveredPinId := '';
    FGraph.Nodes[i].HoveredPinCompatible := TPinCompatible.Undefined;
  end;

  FHoveredNode := nil;
  FHoveredPin := nil;
  FHoveredLink := nil;
end;

procedure TNodeEditor.UpdateHoverStates(SX, SY: Single; HitLinks: Boolean);
var
  N: TCustomNode;
  P: TNodePin;
  L: TNodeLink;
begin
  var CurUpdated := False;

  if FHoveredNode <> nil then
  begin
    FHoveredNode.Hovered := False;
    FHoveredNode.HoveredPinId := '';
    FHoveredNode.HoveredPinCompatible := TPinCompatible.Undefined;
    FHoveredNode.Highlighted := False;
  end;

  FHoveredNode := nil;
  FHoveredPin := nil;
  FHoveredLink := nil;

  if GetPinUnderMouse(SX, SY, N, P) then
  begin
    FHoveredNode := N;
    FHoveredPin := P;
    N.Highlighted := True;
    N.HoveredPinId := P.Id;
    N.HoveredPinCompatible := TPinCompatible.Undefined;

    var TestPin := if FReconnectingLink then FReconnectFixedPin else FTempFromPin;
    if TestPin <> nil then
    begin
      if (TestPin <> P) then
        if ((TestPin.CanAcceptMoreConnections or FReconnectingLink) and P.CanAcceptMoreConnections) and
          not (Assigned(FReconnectLink) and ((FReconnectLink.FromPin = P) or (FReconnectLink.ToPin = P))) and
          FController.CanConnect(TestPin, P)
          then
          N.HoveredPinCompatible := TPinCompatible.True
        else
          N.HoveredPinCompatible := TPinCompatible.False;
      N.Highlighted := True;
    end
    else
      N.Hovered := True;
  end
  else
  begin
    N := GetNodeUnderMouse(SX, SY);
    if N <> nil then
    begin
      if (N.VisualKind = TNodeVisualKind.Comment) and HitLinks and GetLinkUnderMouse(SX, SY, L) then
        FHoveredLink := L
      else
      begin
        FHoveredNode := N;
        N.Hovered := True;
      end;
      if N.ResizeHandleHitTest(SX, SY, FZoom, FOffsetX, FOffsetY) then
        Cursor := crSizeNWSE
      else
        Cursor := crDefault;
      CurUpdated := True;
    end
    else if HitLinks and GetLinkUnderMouse(SX, SY, L) then
      FHoveredLink := L;
  end;

  if not CurUpdated then
    Cursor := crDefault;
end;

procedure TNodeEditor.FitSelection;
begin
  if FController.Selection.NodeCount = 0 then
    Exit;

  var First := True;
  var R: TRectF;
  for var i := 0 to FController.Selection.NodeCount - 1 do
  begin
    var N := FController.Selection.GetNode(i);
    var NR := RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height);

    if First then
    begin
      R := NR;
      First := False;
    end
    else
      R.Union(NR);
  end;

  var W := Max(1, R.Right - R.Left);
  var H := Max(1, R.Bottom - R.Top);
  var Margin := 60;

  FZoom := Min((Width - Margin * 2) / W, (Height - Margin * 2) / H);
  FZoom := EnsureRange(FZoom, ZoomMin, ZoomMax);

  FOffsetX := Margin - (R.Left * FZoom);
  FOffsetY := Margin - (R.Top * FZoom);

  InternalWorldChanged;
end;

procedure TNodeEditor.ResetView;
begin
  var Center := PointF(Width / 2, Height / 2);
  FOffsetX := Center.X;
  FOffsetY := Center.Y;
  FZoom := 1;
  InternalWorldChanged;
end;

function TNodeEditor.GetContentSize: TRectF;
begin
  if FGraph.Nodes.Count = 0 then
    Exit;

  var First := True;
  var MinX: Single := 0;
  var MinY: Single := 0;
  var MaxX: Single := 0;
  var MaxY: Single := 0;
  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    var N := FGraph.Nodes[i];

    if First then
    begin
      MinX := N.X;
      MinY := N.Y;
      MaxX := N.X + N.Width;
      MaxY := N.Y + N.Height;
      First := False;
    end
    else
    begin
      MinX := Min(MinX, N.X);
      MinY := Min(MinY, N.Y);
      MaxX := Max(MaxX, N.X + N.Width);
      MaxY := Max(MaxY, N.Y + N.Height);
    end;
  end;
  Result := RectF(MinX, MinY, MaxX, MaxY);
end;

procedure TNodeEditor.Fit;
var
  i: Integer;
  N: TCustomNode;
  MinX, MinY, MaxX, MaxY: Double;
  W, H: Double;
  ViewW, ViewH: Double;
  Margin: Integer;
  Cx, Cy: Double;
  First: Boolean;
begin
  if FGraph.Nodes.Count = 0 then
    Exit;

  if (Width <= 0) or (Height <= 0) then
    Exit;

  First := True;
  MinX := 0;
  MinY := 0;
  MaxX := 0;
  MaxY := 0;
  for i := 0 to FGraph.Nodes.Count - 1 do
  begin
    N := FGraph.Nodes[i];

    if First then
    begin
      MinX := N.X;
      MinY := N.Y;
      MaxX := N.X + N.Width;
      MaxY := N.Y + N.Height;
      First := False;
    end
    else
    begin
      MinX := Min(MinX, N.X);
      MinY := Min(MinY, N.Y);
      MaxX := Max(MaxX, N.X + N.Width);
      MaxY := Max(MaxY, N.Y + N.Height);
    end;
  end;

  W := Max(1, MaxX - MinX);
  H := Max(1, MaxY - MinY);

  Margin := 60;
  ViewW := Max(1, Width - Margin * 2);
  ViewH := Max(1, Height - Margin * 2);

  FZoom := Min(ViewW / W, ViewH / H);
  FZoom := EnsureRange(FZoom, ZoomMin, ZoomMax);

  Cx := (MinX + MaxX) * 0.5;
  Cy := (MinY + MaxY) * 0.5;

  FOffsetX := Width * 0.5 - Cx * FZoom;
  FOffsetY := Height * 0.5 - Cy * FZoom;

  InternalWorldChanged;
end;

function TNodeEditor.ValidateGraphToStrings(AStrings: TStrings): Boolean;
begin
  Result := FController.ValidateGraphToStrings(AStrings);
end;

function TNodeEditor.NodeIsAbove(const Current, Target: TCustomNode): Boolean;
begin
  if not Assigned(Target) then
    Exit(True);
  if not Assigned(Current) then
    Exit(False);
  if Current = Target then
    Exit(True);

  if Current.Selected <> Target.Selected then
    Exit(Current.Selected);

  if Current.VisualKind <> Target.VisualKind then
    Exit(Current.VisualKind <> TNodeVisualKind.Comment);

  Result := Current.ZOrder > Target.ZOrder;
end;

procedure TNodeEditor.InternalMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FLastMouseDownPos := PointF(X, Y);
  SetFocus;
  try
    if (Button = TMouseButton.mbLeft) or ((Button = TMouseButton.mbRight) and (FTempFromPin = nil)) then
    begin
      // Check resize
      if (not FLockedAll) and (Button = TMouseButton.mbLeft) then
        if InternalResizingBegin(X, Y) then
          Exit;

      var NodeUnderMouse := GetNodeUnderMouse(X, Y);

      // Check pins
      if (not FLockedAll) and (Button = TMouseButton.mbLeft) then
        if InternalPinClick(X, Y, Shift, NodeUnderMouse) then
          Exit;

      // Check nodes and priority links
      if InternalNodeClick(X, Y, Shift, NodeUnderMouse, Button = TMouseButton.mbRight) then
        Exit;

      // Check links                   //Button = TMouseButton.mbRight
      if InternalLinkClick(X, Y, Shift, True) then
        Exit;

      if Button = TMouseButton.mbLeft then
        InternalBoxSelectingBegin(X, Y, Shift);
    end
    else if Button = TMouseButton.mbMiddle then
    begin
      if ssShift in Shift then
        InternalAutoScrollBegin(X, Y)
      else
        InternalPanningBegin(X, Y);
    end;
  finally
    Repaint;
  end;
end;

procedure TNodeEditor.InternalBoxSelectingBegin(X, Y: Single; Shift: TShiftState);
begin
  // Append selection
  if not (ssAlt in Shift) then
    ClearSelection;

  FBoxSelecting := True;
  FBoxStart := PointF(X, Y);
  FBoxCurrent := PointF(X, Y);
  FBoxStartWorld := ScreenToWorld(X, Y);
  FBoxCurrentWorld := FBoxStartWorld;
end;

procedure TNodeEditor.InternalBoxSelectingEnd(X, Y: Single; Shift: TShiftState);
begin
  var R := RectF(FBoxStartWorld.X, FBoxStartWorld.Y, FBoxCurrentWorld.X, FBoxCurrentWorld.Y);
  R.NormalizeRect;
  if not (ssCtrl in Shift) and not (ssShift in Shift) then
    ClearSelection;

  if ssShift in Shift then
  begin
    // Shift + box: only nodes
    FController.Selection.BeginUpdate;
    FController.Selection.ClearPins;
    for var N in FPaintNodesSorted do
    begin
      if R.IntersectsWith(RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height)) then
        FController.Selection.SelectNode(N, True);
    end;
    FController.Selection.EndUpdate;
  end
  else if ssCtrl in Shift then
  begin
    // Ctrl + box: only links
    FController.Selection.BeginUpdate;
    FController.Selection.ClearPins;
    for var i := 0 to FGraph.Links.Count - 1 do
    begin
      var L := FGraph.Links[i];
      if not L.OnScreen then
        Continue;
      if L.IsInsideWorldRect(R) then
        FController.Selection.AddLinkToSelection(L);
    end;
    FController.Selection.EndUpdate;
  end
  else
  begin
    FController.Selection.BeginUpdate;
    FController.Selection.ClearPins;
    for var N in FPaintNodesSorted do
    begin
      if R.IntersectsWith(RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height)) then
        FController.Selection.SelectNode(N, True);
    end;

    for var i := 0 to FGraph.Links.Count - 1 do
    begin
      var L := FGraph.Links[i];
      if not L.OnScreen then
        Continue;
      if L.IsInsideWorldRect(R) then
        FController.Selection.AddLinkToSelection(L);
    end;
    FController.Selection.EndUpdate;
  end;
  FBoxSelecting := False;
end;

procedure TNodeEditor.InternalAutoScrollBegin(X, Y: Single);
begin
  Cursor := crCross;
  FAutoScroll := True;
  FAutoScrollOrigin := PointF(X, Y);
  FCurrentMousePos := FAutoScrollOrigin;
  FScrollSpeedX := 0;
  FScrollSpeedY := 0;

  FAutoScrollTimer.Enabled := True;
end;

procedure TNodeEditor.AniChanged(Sender: TObject);
begin
  FOffsetX := -FAni.ViewportPositionF.X;
  FOffsetY := -FAni.ViewportPositionF.Y;

  InternalWorldChanged;
end;

procedure TNodeEditor.TimerAutoScrollProc(Sender: TObject);
begin
  if not FAutoScroll then
    Exit;

  FOffsetX := FOffsetX - FScrollSpeedX;
  FOffsetY := FOffsetY - FScrollSpeedY;

  InternalWorldChanged;
end;

procedure TNodeEditor.InternalAutoScroll(X, Y: Single);

  function CalcSpeed(D: Single): Single;
  begin
    if Abs(D) < 10 then
      Exit(0);

    Result := Sign(D) * Sqr(Abs(D) / 20);
  end;

const
  DeadZone = 10;
  SpeedFactor = 0.15;
begin
  if not FAutoScroll then
    Exit;
  FCurrentMousePos := PointF(X, Y);

  var DX := X - FAutoScrollOrigin.X;
  var DY := Y - FAutoScrollOrigin.Y;

  if Abs(DX) < DeadZone then
    DX := 0;

  if Abs(DY) < DeadZone then
    DY := 0;

  FScrollSpeedX := CalcSpeed(DX);
  FScrollSpeedY := CalcSpeed(DY);
end;

procedure TNodeEditor.InternalAutoScrollEnd;
begin
  Cursor := crDefault;
  FAutoScroll := False;
  FAutoScrollTimer.Enabled := False;
end;

procedure TNodeEditor.InternalBoxSelecting(X, Y: Single);
begin
  FBoxCurrent := PointF(X, Y);
  FBoxCurrentWorld := ScreenToWorld(X, Y);
end;

function TNodeEditor.InternalNodeClick(X, Y: Single; Shift: TShiftState; NodeUnderMouse: TCustomNode; SelectOnly: Boolean): Boolean;
begin
  Result := False;

  if NodeUnderMouse = nil then
    Exit;

  if NodeUnderMouse.VisualKind = TNodeVisualKind.Comment then
  begin
    if InternalLinkClick(X, Y, Shift, True) then
      Exit(True);
  end;

  if (ssCtrl in Shift) or (ssShift in Shift) then
  begin
    ToggleNodeSelection(NodeUnderMouse);
  end
  else
  begin
    if not FController.Selection.ContainsNode(NodeUnderMouse) then
      SelectNodeInternal(NodeUnderMouse, False);
  end;

  if (not FLockedAll) and (not SelectOnly) then
  begin
    InternalDraggingBegin(X, Y, NodeUnderMouse);
  end;
  Result := True;
end;

function TNodeEditor.InternalLinkClick(X, Y: Single; Shift: TShiftState; SelectOnly: Boolean): Boolean;
begin
  Result := False;

  if FLockedAll then
    Exit;

  var Link: TNodeLink;
  if GetLinkUnderMouse(X, Y, Link) then
  begin
    if Assigned(FOnLinkClick) then
      FOnLinkClick(Self, Link);

    if (ssCtrl in Shift) or (ssShift in Shift) then
    begin
      ToggleLinkSelection(Link);
    end
    else
    begin
      ClearSelection;
      FController.Selection.SelectLink(Link, False);
    end;
    DraggingNode := False;

    if not SelectOnly then
    begin
      FReconnectingLink := True;
      FReconnectLink := Link;
      FReconnectMovingFromSide := Link.IsMouseNearLinkStart(X, Y, FZoom, FOffsetX, FOffsetY);

      if FReconnectMovingFromSide then
      begin
        FTempFromPin := Link.FromPin;
        FReconnectFixedPin := Link.ToPin;
      end
      else
      begin
        FTempFromPin := Link.ToPin;
        FReconnectFixedPin := Link.FromPin;
      end;

      FTempMousePos := PointF(X, Y);
      FTempStartMousePos := PointF(X, Y);
      FDraggingLink := False;
    end;

    Exit(True);
  end;
end;

procedure TNodeEditor.SelectPin(Pin: TNodePin; Toggle: Boolean);
begin
  if Toggle then
    FController.Selection.TogglePin(Pin)
  else
    FController.Selection.SelectPin(Pin, True);
end;

function TNodeEditor.InternalPinClick(X, Y: Single; Shift: TShiftState; NodeUnderMouse: TCustomNode): Boolean;
begin
  Result := False;

  var PinNode: TCustomNode;
  var Pin: TNodePin;

  if not GetPinUnderMouse(X, Y, PinNode, Pin) then
    Exit;
  if not NodeIsAbove(PinNode, NodeUnderMouse) then
    Exit;

  if Assigned(FOnPinClick) then
    FOnPinClick(Self, Pin);

  if (ssCtrl in Shift) or (ssShift in Shift) then
    SelectPin(Pin, ssCtrl in Shift)
  else
  begin
    FController.Selection.ClearPins;
    if Pin.CanAcceptMoreConnections then
    begin
      FTempFromPin := Pin;
      FTempMousePos := PointF(X, Y);
      FTempStartMousePos := PointF(X, Y);
      FDraggingLink := False;
    end;
  end;
  Result := True;
end;

procedure TNodeEditor.InternalPinConnecting(X, Y: Single);
begin
  FTempMousePos := PointF(X, Y);

  if (Abs(X - FTempStartMousePos.X) > 4) or (Abs(Y - FTempStartMousePos.Y) > 4) then
    FDraggingLink := True;

  UpdateHoverStates(X, Y, False);
end;

function TNodeEditor.InternalPinConnectingTry(X, Y: Single): Boolean;
begin
  Result := False;
  var TargetNode: TCustomNode;
  var TargetPin: TNodePin;

  // Reconnect
  if FReconnectingLink then
  begin
    if GetPinUnderMouse(X, Y, TargetNode, TargetPin) and (TargetPin <> nil) and (FReconnectFixedPin <> nil) then
    begin
      if FReconnectMovingFromSide then
      begin
        if TargetPin.CanAcceptMoreConnections and FController.CanConnect(TargetPin, FReconnectFixedPin) then
        begin
          var AllowConnect := True;
          if Assigned(FOnBeforeConnectPins) then
            FOnBeforeConnectPins(Self, TargetPin, FReconnectFixedPin, AllowConnect);

          if AllowConnect then
          begin
            FController.ReconnectLink(FReconnectLink, FReconnectLink.FromPin, TargetPin);
            if Assigned(FOnAfterConnectPins) then
              FOnAfterConnectPins(Self, TargetPin, FReconnectFixedPin);
            SelectLinkInternal(FReconnectLink);
            Result := True;
          end;
        end;
      end
      else
      begin
        if TargetPin.CanAcceptMoreConnections and FController.CanConnect(FReconnectFixedPin, TargetPin) then
        begin
          var AllowConnect := True;
          if Assigned(FOnBeforeConnectPins) then
            FOnBeforeConnectPins(Self, FReconnectFixedPin, TargetPin, AllowConnect);

          if AllowConnect then
          begin
            FController.ReconnectLink(FReconnectLink, FReconnectLink.ToPin, TargetPin);
            if Assigned(FOnAfterConnectPins) then
              FOnAfterConnectPins(Self, FReconnectFixedPin, TargetPin);
            SelectLinkInternal(FReconnectLink);
            Result := True;
          end;
        end;
      end;
    end;
  end  // Connect to pin
  else if GetPinUnderMouse(X, Y, TargetNode, TargetPin) then
  begin
    if FTempFromPin.CanAcceptMoreConnections and
      TargetPin.CanAcceptMoreConnections and
      FController.CanConnect(FTempFromPin, TargetPin)
      then
    begin
      if FTempFromPin.Direction = TPinDirection.Output then
        Result := AddLink(FTempFromPin, TargetPin)
      else
        Result := AddLink(TargetPin, FTempFromPin);
    end;
  end  // Connect to void (create node from pin)
  else if FDraggingLink then
  begin
    TargetNode := FController.CreateCompatibleNodeForPin(FTempFromPin, SnapWorldPoint(ScreenToWorld(X, Y)));
    if TargetNode <> nil then
    begin
      FController.AddNode(TargetNode);

      if FTempFromPin.Direction = TPinDirection.Output then
      begin
        // Find compatible pin
        for var i := 0 to TargetNode.InputCount - 1 do
        begin
          TargetPin := TargetNode.GetInput(i);
          if FTempFromPin.CanAcceptMoreConnections and
            TargetPin.CanAcceptMoreConnections and
            FController.CanConnect(FTempFromPin, TargetPin)
            then
          begin
            Result := AddLink(FTempFromPin, TargetPin);
            // Fix node position reletive pin
            if Result then
            begin
              TargetNode.Y := TargetNode.Y - TargetPin.LocalY;
              Break;
            end;
          end;
        end;
      end
      else
      begin
        // Find compatible pin
        for var i := 0 to TargetNode.OutputCount - 1 do
        begin
          TargetPin := TargetNode.GetOutput(i);
          if FController.CanConnect(TargetPin, FTempFromPin) then
          begin
            Result := AddLink(TargetPin, FTempFromPin);
            // Fix node position reletive pin
            if Result then
            begin
              TargetNode.Y := TargetNode.Y - TargetPin.LocalY;
              TargetNode.X := TargetNode.X - TargetNode.Width;
              Break;
            end;
          end;
        end;
      end;

      SelectNodeInternal(TargetNode, False);
    end
    else
    begin
      ShowNodeSearchPopup(Screen.MousePos, FLastWorldMousePos);
    end;
  end;

  CancelMouseOperations(False);
end;

procedure TNodeEditor.InternalPanningBegin(X, Y: Single);
begin
  FPanning := True;
  FPanStartX := X;
  FPanStartY := Y;
  //
  FAni.MouseDown(X, Y);
end;

procedure TNodeEditor.InternalPanningEnd(X, Y: Single);
begin
  FPanning := False;
  //
  FAni.MouseUp(X, Y);
end;

procedure TNodeEditor.InternalPanning(X, Y: Single);
begin
  FAni.MouseMove(X, Y);
  Exit;
  //
  FOffsetX := FOffsetX + (X - FPanStartX);
  FOffsetY := FOffsetY + (Y - FPanStartY);
  FPanStartX := X;
  FPanStartY := Y;
  InternalWorldChanged;
end;

function TNodeEditor.InternalResizingBegin(X, Y: Single): Boolean;
begin
  var Node := GetNodeResizeUnderMouse(X, Y);
  if Node <> nil then
  begin
    if not FController.Selection.ContainsNode(Node) then
      SelectNodeInternal(Node, False);

    ResizingNode := True;
    FResizeNode := Node;
    FResizeStartMouseX := X;
    FResizeStartMouseY := Y;
    FResizeStartWidth := Node.Width;
    FResizeStartHeight := Node.Height;
    FResizeStartX := Node.X;
    FResizeStartY := Node.Y;
    FResizeOldWidth := Node.Width;
    FResizeOldHeight := Node.Height;
    Result := True;
  end
  else
    Result := False;
end;

procedure TNodeEditor.InternalResizing(X, Y: Single);
begin
  FResizeNode.Width := Round(Max(FResizeNode.MinWidth, FResizeStartWidth + (X - FResizeStartMouseX) / FZoom));
  FResizeNode.Height := Round(Max(FResizeNode.MinHeight, FResizeStartHeight + (Y - FResizeStartMouseY) / FZoom));
end;

procedure TNodeEditor.InternalResizingEnd;
begin
  if (FResizeNode <> nil) and ((FResizeNode.Width <> FResizeOldWidth) or (FResizeNode.Height <> FResizeOldHeight)) then
  begin
    var SaveWidth := FResizeNode.Width;
    var SaveHeight := FResizeNode.Height;

    FResizeNode.Width := FResizeOldWidth;
    FResizeNode.Height := FResizeOldHeight;

    FController.ResizeNode(FResizeNode, FResizeOldWidth, FResizeOldHeight, SaveWidth, SaveHeight);

    if Assigned(FOnNodeChanged) then
      FOnNodeChanged(Self, FResizeNode);
  end;
end;

procedure TNodeEditor.InternalDraggingBegin(X, Y: Single; Node: TCustomNode);
begin
  DraggingNode := True;
  FDragNode := Node;
  FDragStartX := X;
  FDragStartY := Y;
  FDragAnchorX := X;
  FDragAnchorY := Y;

  FShowDragCoordinates := True;

  if GetPrimarySelectedNode <> nil then
    FDragStartWorldPos := PointF(GetPrimarySelectedNode.X, GetPrimarySelectedNode.Y)
  else if FController.Selection.NodeCount > 0 then
    FDragStartWorldPos := PointF(FController.Selection.GetNode(0).X, FController.Selection.GetNode(0).Y);

  FDragCommandNodes.Clear;
  SetLength(FDragOldPositions, FController.Selection.NodeCount);

  for var i := 0 to FController.Selection.NodeCount - 1 do
  begin
    FDragCommandNodes.Add(FController.Selection.GetNode(i));
    FDragOldPositions[i] := PointF(FController.Selection.GetNode(i).X, FController.Selection.GetNode(i).Y);
  end;
end;

procedure TNodeEditor.InternalDragging(X, Y: Single; Shift: TShiftState);
begin
  var RawDx: Single := (X - FDragAnchorX) / FZoom;
  var RawDy: Single := (Y - FDragAnchorY) / FZoom;

  var DX: Single := RawDx;
  var DY: Single := RawDy;
  var SnappedX := False;
  var SnappedY := False;

  // Snapping
  if not (ssAlt in Shift) then
  begin
    if FSnapToNodes then
      ApplyNodeSnap(DX, DY, SnappedX, SnappedY)
    else
      ClearSnapGuides;

    if FSnapToGrid then
      ApplyGridSnap(DX, DY, SnappedX, SnappedY);
  end
  else
    ClearSnapGuides;

  for var i := 0 to FDragCommandNodes.Count - 1 do
  begin
    var N := FDragCommandNodes[i];
    N.X := FDragOldPositions[i].X + DX;
    N.Y := FDragOldPositions[i].Y + DY;
  end;
end;

procedure TNodeEditor.InternalDraggingEnd(X, Y: Single);
begin
  var NewPositions: TArray<TPointF>;
  SetLength(NewPositions, FDragCommandNodes.Count);
  var Moved := False;

  for var i := 0 to FDragCommandNodes.Count - 1 do
  begin
    var DN := FDragCommandNodes[i];
    NewPositions[i] := PointF(DN.X, DN.Y);

    if (Abs(NewPositions[i].X - FDragOldPositions[i].X) > 0.01) or (Abs(NewPositions[i].Y - FDragOldPositions[i].Y) > 0.01) then
      Moved := True;
  end;

  if Moved then
  begin
    for var i := 0 to FDragCommandNodes.Count - 1 do
    begin
      var DN := FDragCommandNodes[i];
      DN.X := FDragOldPositions[i].X;
      DN.Y := FDragOldPositions[i].Y;
    end;

    FController.MoveNodes(FDragCommandNodes, FDragOldPositions, NewPositions);

    for var i := 0 to FDragCommandNodes.Count - 1 do
    begin
      var DN := FDragCommandNodes[i];
      if Assigned(FOnNodeChanged) then
        FOnNodeChanged(Self, DN);
    end;
  end;

  CancelMouseOperations(False);
end;

procedure TNodeEditor.InternalMouseMove(Shift: TShiftState; X, Y: Single);
begin
  FLastMousePos := PointF(X, Y);
  FLastWorldMousePos := ScreenToWorld(FLastMousePos);

  if FAutoScroll then
  begin
    InternalAutoScroll(X, Y);
    Exit;
  end
  else if FPanning then
  begin
    InternalPanning(X, Y);
  end
  else if ResizingNode and (FResizeNode <> nil) then
  begin
    InternalResizing(X, Y);
  end
  else if DraggingNode and (FDragCommandNodes.Count > 0) then
  begin
    InternalDragging(X, Y, Shift);
  end
  else if FTempFromPin <> nil then
  begin
    InternalPinConnecting(X, Y);
  end
  else if FBoxSelecting then
  begin
    InternalBoxSelecting(X, Y);
  end
  else if (ssLeft in Shift) and (FLastMousePos.Distance(FLastMouseDownPos) > 5) and InternalLinkClick(X, Y, Shift, False) then
    Exit
  else
  begin
    UpdateHoverStates(X, Y, False);
  end;

  Repaint;
end;

procedure TNodeEditor.InternalMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    // Insert reroute on Double click on link
    if (ssDouble in Shift) and (GetPrimarySelectedLink <> nil) then
    begin
      FController.InsertRerouteOnLink(GetPrimarySelectedLink, SnapWorldPoint(ScreenToWorld(X, Y)));
    end
    else if ResizingNode then
    begin
      InternalResizingEnd;
    end
    else if FTempFromPin <> nil then
    begin
      InternalPinConnectingTry(X, Y);
    end
    else if DraggingNode and (FDragCommandNodes.Count > 0) then
    begin
      InternalDraggingEnd(X, Y);
    end
    else if FBoxSelecting then
    begin
      InternalBoxSelectingEnd(X, Y, Shift);
    end;
  end
  else if Button = TMouseButton.mbMiddle then
  begin
    //InternalAutoScrollEnd;
    InternalPanningEnd(X, Y);
  end
  else if Button = TMouseButton.mbRight then
  begin
    // If link dragging - exit to cancel link drugging
    if (FTempFromPin <> nil) or FReconnectingLink then
    begin
      CancelMouseOperations(True);
      Exit;
    end;

    var MPos := Screen.MousePos;
    FPopupMenu.PopupComponent := Self;
    FPopupMenu.Popup(MPos.X, MPos.Y);
  end;
  CancelMouseOperations(False);
end;

procedure TNodeEditor.CancelMouseOperations(const KeepSelectionRect: boolean);
begin
  InternalPanningEnd(FLastMousePos.X, FLastMousePos.Y);
  FRightButtonDown := False;
  ReleaseCapture;

  DraggingNode := False;
  FDragCommandNodes.Clear;
  SetLength(FDragOldPositions, 0);

  FTempFromPin := nil;
  FDraggingLink := False;
  FReconnectingLink := False;
  FReconnectLink := nil;
  FReconnectFixedPin := nil;
  FReconnectMovingFromSide := False;

  ResizingNode := False;
  FResizeNode := nil;

  InternalAutoScrollEnd;

  if not KeepSelectionRect then
    FBoxSelecting := False;

  ClearSnapGuides;
  ClearHoverStates;
  //ReleaseCapture;
  Cursor := crDefault;
  Repaint;
end;

procedure TNodeEditor.DoMouseLeave;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;

  CancelMouseOperations(False);
end;

procedure TNodeEditor.UpdatedStatus;
begin
  if Assigned(FOnUpdatedStatus) then
    FOnUpdatedStatus(Self);
end;

procedure TNodeEditor.SetDraggingNode(const Value: Boolean);
begin
  if FDraggingNode <> Value then
  begin
    FDraggingNode := Value;
    if not FDraggingNode then
    begin
      FDragNode := nil;
      UpdateScrollBars(True);
    end;
  end;
end;

procedure TNodeEditor.SetGridColor(const Value: TAlphaColor);
begin
  FGridColor := Value;
  Repaint;
end;

procedure TNodeEditor.SetGridSize(const Value: Integer);
begin
  FGridSize := Value;
  Repaint;
end;

procedure TNodeEditor.SetGridType(const Value: TGridType);
begin
  FGridType := Value;
  Repaint;
end;

procedure TNodeEditor.SetLinkColor(const Value: TAlphaColor);
begin
  TNodeLink.DefaultColor := Value;
end;

procedure TNodeEditor.SetLinkGradient(const Value: Boolean);
begin
  FLinkGradient := Value;
  TNodeLink.UseGradient := FLinkGradient;
  Repaint;
end;

procedure TNodeEditor.SetLinkThickness(const Value: Single);
begin
  TNodeLink.Thickness := Value;
end;

procedure TNodeEditor.SetLinkVisualClass(const Value: TLinkVisualObjectClass);
begin
  FLinkVisualClass := Value;
  TNodeLink.VisualClass := FLinkVisualClass;
  Repaint;
end;

procedure TNodeEditor.SetLinkVisualType(const Value: TLinkVisualType);
begin
  FLinkVisualType := Value;
  case Value of
    TLinkVisualType.Bezier:
      TNodeLink.VisualClass := TLinkVisualBezier;
    TLinkVisualType.Line:
      TNodeLink.VisualClass := TLinkVisualLine;
    TLinkVisualType.PolyLine:
      TNodeLink.VisualClass := TLinkVisualPolyLine;
    TLinkVisualType.Rect:
      TNodeLink.VisualClass := TLinkVisualRect;
  end;
  Repaint;
end;

procedure TNodeEditor.SetLockedAll(const Value: Boolean);
begin
  FLockedAll := Value;
end;

procedure TNodeEditor.SetOnGraphChanged(const Value: TNotifyEvent);
begin
  FOnGraphChanged := Value;
end;

procedure TNodeEditor.SetOnUpdatedStatus(const Value: TNotifyEvent);
begin
  FOnUpdatedStatus := Value;
end;

procedure TNodeEditor.SetResizingNode(const Value: Boolean);
begin
  if FResizingNode <> Value then
  begin
    FResizingNode := Value;
    if not FResizingNode then
      UpdateScrollBars(True);
  end;
end;

procedure TNodeEditor.SetShowFrameTime(const Value: Boolean);
begin
  FShowFrameTime := Value;
  Repaint;
end;

procedure TNodeEditor.SetShowGrid(const Value: Boolean);
begin
  FShowGrid := Value;
  Repaint;
end;

procedure TNodeEditor.SetZoom(Value: Double; const TargetPos: TPointF);
begin
  var NewZoom := EnsureRange(Value, ZoomMin, ZoomMax);

  if Abs(FZoom - NewZoom) > 0.0001 then
  begin
    FOffsetX := TargetPos.X - (TargetPos.X - FOffsetX) * (NewZoom / FZoom);
    FOffsetY := TargetPos.Y - (TargetPos.Y - FOffsetY) * (NewZoom / FZoom);
  end;
  FZoom := NewZoom;

  InternalWorldChanged;
end;

procedure TNodeEditor.SetZoom(Value: Double);
begin
  SetZoom(Value, FLastMousePos);
end;

procedure TNodeEditor.SetZoomStep(AValue: Double);
begin
  if FZoomStep = AValue then
    Exit;
  FZoomStep := AValue;
end;

procedure TNodeEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
begin
  inherited;
  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  Exit;
  {$ENDIF}
  InternalMouseDown(Button, Shift, AX, AY);
end;

procedure TNodeEditor.MouseMove(Shift: TShiftState; AX, AY: Single);
begin
  inherited;
  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  Exit;
  {$ENDIF}
  InternalMouseMove(Shift, AX, AY);
end;

procedure TNodeEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
begin
  inherited;
  {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  Exit;
  {$ENDIF}
  InternalMouseUp(Button, Shift, AX, AY);
end;

procedure TNodeEditor.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  inherited;
  Handled := True;
  if Shift = [ssCtrl] then
  begin
    FAni.MouseWheel(-WheelDelta, 0);
  end
  else if Shift = [ssShift] then
  begin
    FAni.MouseWheel(0, -WheelDelta);
  end
  else if Shift = [] then
  begin
    var NewZoom: Double;
    var OldZoom := FZoom;

    var Factor := Power(FZoomStep, WheelDelta / 120.0);

    if ssCtrl in Shift then
      Factor := Power(Factor, 1.7)
    else if ssShift in Shift then
      Factor := Power(Factor, 0.4);

    NewZoom := OldZoom * Factor;
    SetZoom(NewZoom, FLastMousePos);
  end;
end;

procedure TNodeEditor.SelectAll;
begin
  FController.Selection.BeginUpdate;
  FController.Selection.Clear;
  FController.Selection.ClearPins;
  for var i := 0 to FGraph.Nodes.Count - 1 do
    FController.Selection.SelectNode(FGraph.Nodes[i], True);

  for var i := 0 to FGraph.Links.Count - 1 do
    FController.Selection.AddLinkToSelection(FGraph.Links[i]);
  FController.Selection.EndUpdate;
end;

procedure TNodeEditor.SelectAllNodes;
begin
  FController.Selection.BeginUpdate;
  FController.Selection.Clear;
  FController.Selection.ClearPins;
  for var i := 0 to FGraph.Nodes.Count - 1 do
    FController.Selection.SelectNode(FGraph.Nodes[i], True);
  FController.Selection.EndUpdate;
end;

procedure TNodeEditor.SelectAllLinks;
begin
  FController.Selection.BeginUpdate;
  FController.Selection.Clear;
  FController.Selection.ClearPins;
  for var i := 0 to FGraph.Links.Count - 1 do
    FController.Selection.AddLinkToSelection(FGraph.Links[i]);
  FController.Selection.EndUpdate;
end;

procedure TNodeEditor.Cancel;
begin
  if FController.Selection.SelectedCount > 0 then
    ClearSelection
  else
    CancelMouseOperations(False);
end;

procedure TNodeEditor.FitSome;
begin
  if FController.Selection.NodeCount > 0 then
    FitSelection
  else
    Fit;
end;

procedure TNodeEditor.MoveScreen(Direction: TMoveDirection);
begin
  case Direction of
    TMoveDirection.Left:
      FOffsetX := FOffsetX + 40;
    TMoveDirection.Up:
      FOffsetY := FOffsetY + 40;
    TMoveDirection.Right:
      FOffsetX := FOffsetX - 40;
    TMoveDirection.Down:
      FOffsetY := FOffsetY - 40;
  end;
  InternalWorldChanged;
end;

procedure TNodeEditor.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  if (Key = vkLeft) and (Shift = []) then
    MoveScreen(TMoveDirection.Left);
  if (Key = vkUp) and (Shift = []) then
    MoveScreen(TMoveDirection.Up);
  if (Key = vkRight) and (Shift = []) then
    MoveScreen(TMoveDirection.Right);
  if (Key = vkDown) and (Shift = []) then
    MoveScreen(TMoveDirection.Down);
  if (Key = vkAdd) and (Shift = []) then
    SetZoom(FZoom * FZoomStep, LocalRect.CenterPoint);
  if (Key = vkSubtract) and (Shift = []) then
    SetZoom(FZoom / FZoomStep, LocalRect.CenterPoint);

  if (Key = vkA) and (Shift = [ssCtrl]) then
    SelectAll
  else if (Key = vkA) and (Shift = [ssCtrl, ssShift]) then
    SelectAllNodes
  else if (Key = vkA) and (Shift = [ssShift]) then
    SelectAllLinks
  else if (Key = vkC) and (Shift = [ssCtrl]) then
    CopySelectionToClipboard
  else if (Key = vkD) and (Shift = [ssCtrl]) then
    DuplicateSelection
  else if (Key = vkF) and (Shift = [ssShift]) then
    FitSome
  else if (Key = vkR) and (Shift = [ssShift]) then
    ResetView
  else if (Key = vkL) and (Shift = [ssCtrl]) then
    FController.ConnectSelectedPins
  else if (Key = vkV) and (Shift = [ssCtrl]) then
    PasteFromClipboard
  else if (Key = vkX) and (Shift = [ssCtrl]) then
    CutSelectionToClipboard
  else if (Key = vkY) and (Shift = [ssCtrl]) then
    Redo
  else if (Key = vkZ) and (Shift = [ssCtrl]) then
    Undo
  else if (Key = vkZ) and (Shift = [ssCtrl, ssShift]) then
    Redo
  else if (Key = vkDelete) and (Shift = []) then
    DeleteSelection
  else if (Key = vkEscape) and (Shift = []) then
    Cancel
  else if (Key = vkL) and (Shift = [ssCtrl, ssShift]) then
    Controller.AlignSelectedNodes(TAlignMode.Left)
  else if (Key = vkR) and (Shift = [ssCtrl, ssShift]) then
    Controller.AlignSelectedNodes(TAlignMode.Right)
  else if (Key = vkT) and (Shift = [ssCtrl, ssShift]) then
    Controller.AlignSelectedNodes(TAlignMode.Top)
  else if (Key = vkB) and (Shift = [ssCtrl, ssShift]) then
    Controller.AlignSelectedNodes(TAlignMode.Bottom)
  else if (Key = vkH) and (Shift = [ssCtrl, ssShift]) then
    Controller.AlignSelectedNodes(TAlignMode.CenterHorizontal)
  else if (Key = vkV) and (Shift = [ssCtrl, ssShift]) then
    Controller.AlignSelectedNodes(TAlignMode.CenterVertical)
  else if (Key = vkH) and (Shift = [ssCtrl, ssAlt]) then
    Controller.DistributeSelectedNodes(TDistributeMode.Horizontal)
  else if (Key = vkV) and (Shift = [ssCtrl, ssAlt]) then
    Controller.DistributeSelectedNodes(TDistributeMode.Vertical)
  else if (Key = vkW) and (Shift = [ssCtrl, ssShift]) then
    Controller.MakeSelectedNodesSameSize(TMatchSizeMode.Width)
  else if (Key = vkE) and (Shift = [ssCtrl, ssShift]) then
    Controller.MakeSelectedNodesSameSize(TMatchSizeMode.Height)
  else if (Key = vkS) and (Shift = [ssCtrl, ssShift]) then
    Controller.MakeSelectedNodesSameSize(TMatchSizeMode.Both)
  else if (Key = vkF) and (Shift = [ssCtrl, ssShift]) then
    FController.FrameSelected
  else if (Key = vkA) and (Shift = [ssCtrl, ssAlt]) then
    FController.AutoLayoutSelected;

  Key := 0;
  KeyChar := #0;
end;

procedure TNodeEditor.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
end;

end.

