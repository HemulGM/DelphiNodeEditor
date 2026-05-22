unit FMX.NodeEditor;

interface

uses
  System.Classes, System.SysUtils, FMX.Graphics, FMX.Controls, System.Math,
  System.Types, FMX.Menus, FMX.Clipboard, System.JSON, FMX.Forms, FMX.Dialogs,
  System.UITypes, FMX.Types, FMX.Objects, System.Generics.Collections,
  FMX.NodeEditor.Node, FMX.NodeEditor.Node.Defaults, FMX.NodeEditor.Node.Graph,
  FMX.NodeEditor.Types, FMX.NodeEditor.Controller;

{$SCOPEDENUMS ON}

type
  TNodeSelectionChangedEvent = procedure(Sender: TObject) of object;

  TNodeChangedEvent = procedure(Sender: TObject; ANode: TCustomNode) of object;

  { Custom Draw Events }
  TNodeEditorDrawNodeEvent = procedure(Sender: TObject; Canvas: TCanvas; ANode: TCustomNode; const ARect: TRect; Zoom: double; OffsetX, OffsetY: integer; var AHandled: boolean) of object;

  TNodeEditorDrawPinEvent = procedure(Sender: TObject; Canvas: TCanvas; APin: TNodePin; const ACenter: TPoint; ARadius: integer; ASelected, AHovered, AHighlighted: boolean; var AHandled: boolean) of object;

  TNodeEditorDrawLinkEvent = procedure(Sender: TObject; Canvas: TCanvas; ALink: TNodeLink; const P0, P1, P2, P3: TPoint; ASelected, AHovered: boolean; var AHandled: boolean) of object;

  { Interaction Events }
  TNodePinEvent = procedure(Sender: TObject; APin: TNodePin) of object;

  TNodeLinkEvent = procedure(Sender: TObject; ALink: TNodeLink) of object;

  TEditorConnectPinsEvent = procedure(Sender: TObject; AFromPin, AToPin: TNodePin; var AAllow: boolean) of object;

  TEditorPinsConnectedEvent = procedure(Sender: TObject; AFromPin, AToPin: TNodePin) of object;

  TNodeEditor = class(TControl)
  private
    FGraph: TNodeGraph;
    FController: TNodeEditorController;
    FOnNodeChanged: TNodeChangedEvent;
    FOnSelectionChanged: TNodeSelectionChangedEvent;

    FZoom: Double;
    FOffsetX, FOffsetY: Integer;

    FDraggingNode: Boolean;
    FDragStartX, FDragStartY: Integer;
    FDragAnchorX, FDragAnchorY: integer;
    FDragUndoPushed: Boolean;

    FDragCommandNodes: TList<TCustomNode>;
    FDragOldPositions: array of TPointF;

    FDragStartWorldPos: TPointF;
    FShowDragCoordinates: boolean;

    FPanning: Boolean;
    FPanStartX, FPanStartY: Integer;
    FRightMouseMoved: Boolean;
    FRightButtonDown: boolean;

    FTempFromPin: TNodePin;
    FTempMousePos: TPoint;
    FLastMousePos: TPoint;
    FDraggingLink: boolean;
    FTempStartMousePos: TPoint;

    FBoxSelecting: Boolean;
    FBoxStart: TPoint;
    FBoxCurrent: TPoint;
    FBoxStartWorld: TPointF;
    FBoxCurrentWorld: TPointF;

    FPopupMenu: TPopupMenu;
    FContextWorldPos: TPointF;

    FHoveredNode: TCustomNode;
    FHoveredPin: TNodePin;
    FHoveredLink: TNodeLink;

    FReconnectingLink: Boolean;
    FReconnectLink: TNodeLink;
    FReconnectFixedPin: TNodePin;
    FReconnectMovingFromSide: Boolean;

    FResizingNode: Boolean;
    FResizeNode: TCustomNode;
    FResizeStartMouseX, FResizeStartMouseY: Integer;
    FResizeStartWidth, FResizeStartHeight: Integer;
    FResizeStartX, FResizeStartY: Single;
    FResizeEdgeSize: Integer;
    FResizeOldWidth, FResizeOldHeight: Integer;

    FSnapToGrid: Boolean;
    FGridSize: Integer;

    FSnapToNodes: boolean;
    FNodeSnapDistance: single;

    FShowSnapGuides: boolean;
    FGuideSnapXActive: boolean;
    FGuideSnapYActive: boolean;
    FGuideSnapX: single;
    FGuideSnapY: single;

    // Axes properties
    FShowAxes: boolean;
    FAxesColor: TAlphaColor;
    FAxesThickness: integer;

    // Optimization fields
    FPaintNodesSorted: TList<TCustomNode>;
    FPaintNodesDirty: boolean;
    FLastHoverMouseX: integer;
    FLastHoverMouseY: integer;
    FLastMouseMoveTick: UInt64;
    FLastPaintTick: UInt64;

    FOnUpdatedStatus: TNotifyEvent;
    FGridType: TGridType;


    // Styling Properties
    FPinRadius: integer;
    FPinBorderWidth: integer;
    FPinBorderColor: TAlphaColor;
    FPinDefaultColor: TAlphaColor;
    FPinExecColor: TAlphaColor;
    FPinSelectedColor: TAlphaColor;
    FPinHoverColor: TAlphaColor;
    FLinkColor: TAlphaColor;
    FLinkSelectedColor: TAlphaColor;
    FLinkHoverColor: TAlphaColor;
    FLinkThickness: integer;
    FLinkSelectedThickness: integer;
    FHoveredPinCompatible: boolean;
    FPinCompatibleColor: TAlphaColor;
    FPinIncompatibleColor: TAlphaColor;

    // Custom Draw Events
    FOnDrawNode: TNodeEditorDrawNodeEvent;
    FOnDrawPin: TNodeEditorDrawPinEvent;
    FOnDrawLink: TNodeEditorDrawLinkEvent;

    // Interaction Events
    FOnPinSelectionChanged: TNotifyEvent;
    FOnPinClick: TNodePinEvent;
    FOnLinkClick: TNodeLinkEvent;
    FOnBeforeConnectPins: TEditorConnectPinsEvent;
    FOnAfterConnectPins: TEditorPinsConnectedEvent;

    // Internal Logic
    procedure ClearPinSelection;
    procedure SelectPinInternal(APin: TNodePin; AAppend: boolean);
    procedure TogglePinSelection(APin: TNodePin);
    procedure ConnectSelectedPins;
    procedure DoPinSelectionChanged(Sender: TObject);
    function GetPrimarySelectedNode: TCustomNode;
    function GetPrimarySelectedLink: TNodeLink;

    // Render Helpers
    procedure DefaultDrawNode(ANode: TCustomNode; const ARect: TRect);
    procedure DrawSingleNode(ANode: TCustomNode);
    procedure DrawNodePins(ANode: TCustomNode);
    procedure DefaultDrawPin(APin: TNodePin; const Center: TPoint; Radius: integer; ASelected, AHovered, AHighlighted: boolean);
    procedure DefaultDrawLink(ALink: TNodeLink; const P0, P1, P2, P3: TPoint; ASelected, AHovered: boolean);

    procedure NotifySelectionChanged;
    procedure ControllerSelectionChanged(Sender: TObject);
    procedure SyncControllerSelectionToView;

    // Geometry
    function GetResizeHandleRect(ANode: TCustomNode): TRect;
    function GetNodeResizeUnderMouse(SX, SY: Integer): TCustomNode;
    function GetVisibleWorldRect: TRectF;
    function GetPinWorldPosition(APin: TNodePin): TPointF;
    procedure GetLinkBezierWorldPoints(ALink: TNodeLink; out P0, P1, P2, P3: TPointF);

    // Render Layers
    procedure DrawGrid;
    procedure DrawAxes;
    procedure DrawLinks(WorldRect: TRectF);
    procedure DrawTempLink;
    procedure DrawBoxSelect;
    procedure DrawGrip(const R: TRectF; const AOpacity: Single = 1.0);
    procedure DrawSnapGuides;
    procedure ClearSnapGuides;

    // Misc
    procedure BuildContextMenu;
    procedure OnAddRegisteredNodeClick(Sender: TObject);
    procedure OnContextCopy(Sender: TObject);
    procedure OnContextPaste(Sender: TObject);
    procedure OnContextDuplicate(Sender: TObject);
    procedure OnContextDelete(Sender: TObject);
    procedure OnContextSearchNode(Sender: TObject);
    procedure OnContextInsertReroute(Sender: TObject);
    procedure OnContextAddComment(Sender: TObject);
    procedure ShowNodeSearchPopup(AScreenX, AScreenY: Integer; AWorldX, AWorldY: Single);
    procedure ResetStateAfterGraphReload;
    procedure ClearHoverStates;
    procedure UpdateHoverStates(SX, SY: Integer);
    procedure SetZoom(Value: Double); overload;
    procedure UpdatedStatus;
    procedure SetOnUpdatedStatus(const Value: TNotifyEvent);
    procedure SetGridSize(const Value: Integer);
    procedure SetGridType(const Value: TGridType);
    procedure CancelMouseOperations(const KeepSelectionRect: boolean);
    function NodeIsAbove(const Current, Target: TCustomNode): Boolean;
  protected
    function SelectedPinCount: integer;
    function GetSelectedPin(Index: integer): TNodePin;
    function CanConnectSelectedPins: boolean;

    function SnapWorldValue(V: Single): Single;
    function SnapWorldPoint(const P: TPointF): TPointF;

    function IsNodeInDragSelection(ANode: TCustomNode): boolean;
    function GetDraggedSelectionBoundsAtOffset(const AOffsetX, AOffsetY: single): TRectF;
    procedure ApplyNodeSnap(var AOffsetX, AOffsetY: single; out ASnappedX, ASnappedY: boolean);

    procedure InvalidateSortedNodes;
    procedure EnsureSortedNodes;
    procedure RequestRepaint(const AForce: boolean = False);
    procedure NodeGraphChanged(Sender: TObject);

    // Hit Testing
    function WorldToScreen(WX, WY: Single): TPoint;
    function ScreenToWorld(SX, SY: Integer): TPointF;

    function GetNodeUnderMouse(SX, SY: Integer): TCustomNode;
    function IsLinkInsideWorldRect(ALink: TNodeLink; const R: TRectF): boolean;
    function GetPinUnderMouse(SX, SY: Integer; out Node: TCustomNode; out Pin: TNodePin): Boolean;
    function GetLinkUnderMouse(SX, SY: Integer; out Link: TNodeLink): Boolean;

    // Selection Logic
    procedure ClearSelectionInternal;
    procedure SelectNodeInternal(ANode: TCustomNode; AAppend: Boolean);
    procedure SelectLinkInternal(ALink: TNodeLink; AKeepNodes: boolean = False);
    procedure ToggleNodeSelection(ANode: TCustomNode);
    procedure AddNodeToSelection(ANode: TCustomNode);
    procedure RemoveNodeFromSelection(ANode: TCustomNode);
    procedure ToggleLinkSelection(ALink: TNodeLink);
    procedure AddLinkToSelection(ALink: TNodeLink);
    procedure RemoveLinkFromSelection(ALink: TNodeLink);
    function IsMouseNearLinkStart(ALink: TNodeLink; SX, SY: Integer): Boolean;
    procedure SyncNodeSelectedFlags;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; AX, AY: Single); override;
    procedure MouseMove(Shift: TShiftState; AX, AY: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; AX, AY: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
    procedure KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddNode(ANode: TCustomNode);
    procedure RemoveNode(ANode: TCustomNode);
    procedure RemoveLink(ALink: TNodeLink);
    procedure Clear;

    procedure ClearSelection;
    procedure DeleteSelection;
    function SelectedNodeCount: Integer;
    function SelectedLinkCount: Integer;
    function GetSelectedNode(Index: Integer): TCustomNode;
    procedure SelectNode(ANode: TCustomNode; AAppend: Boolean);
    procedure ExecuteNodePropertyChange(ANode: TCustomNode; const AOldJSON, ANewJSON: string);
    procedure SelectLink(ALink: TNodeLink);

    procedure FitToSelection;
    procedure FrameAll;
    procedure SetZoom(Value: Double; TargetPos: TPoint); overload;

    function SaveToJSONText: string;
    procedure LoadFromJSONText(const S: string);
    procedure SaveToFile(const AFileName: string);
    procedure LoadFromFile(const AFileName: string);

    procedure Undo;
    procedure Redo;
    procedure CopySelectionToClipboard;
    procedure PasteFromClipboard;
    procedure DuplicateSelection;

    function AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = pkData): TNodePin;
    function AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind = pkData): TNodePin;
    function RemovePinFromNode(APin: TNodePin): boolean;

    function ValidateGraphToStrings(AStrings: TStrings): Boolean;

    property Graph: TNodeGraph read FGraph;
    property Zoom: Double read FZoom write SetZoom;
    property Controller: TNodeEditorController read FController;

    property ShowSnapGuides: boolean read FShowSnapGuides write FShowSnapGuides default True;
    property SnapToNodes: boolean read FSnapToNodes write FSnapToNodes default True;
    property NodeSnapDistance: single read FNodeSnapDistance write FNodeSnapDistance;

    // New Axes Properties
    property ShowAxes: boolean read FShowAxes write FShowAxes default False;
    property AxesColor: TAlphaColor read FAxesColor write FAxesColor default TAlphaColors.Silver;
    property AxesThickness: integer read FAxesThickness write FAxesThickness default 2;
  published
    property Align;
    property Anchors;
    property TabStop default True;
    property PopupMenu;
    property SnapToGrid: Boolean read FSnapToGrid write FSnapToGrid default False;
    property GridSize: Integer read FGridSize write SetGridSize default 40;

    // Styling
    property PinRadius: integer read FPinRadius write FPinRadius default 8;
    property PinBorderWidth: integer read FPinBorderWidth write FPinBorderWidth default 1;
    property PinBorderColor: TAlphaColor read FPinBorderColor write FPinBorderColor default TAlphaColors.Black;
    property PinDefaultColor: TAlphaColor read FPinDefaultColor write FPinDefaultColor default TAlphaColors.Lime;
    property PinExecColor: TAlphaColor read FPinExecColor write FPinExecColor default TAlphaColors.White;
    property PinSelectedColor: TAlphaColor read FPinSelectedColor write FPinSelectedColor default TAlphaColors.Lime;
    property PinHoverColor: TAlphaColor read FPinHoverColor write FPinHoverColor default TAlphaColors.Aqua;

    property LinkColor: TAlphaColor read FLinkColor write FLinkColor default TAlphaColors.Yellow;
    property LinkSelectedColor: TAlphaColor read FLinkSelectedColor write FLinkSelectedColor default TAlphaColors.Red;
    property LinkHoverColor: TAlphaColor read FLinkHoverColor write FLinkHoverColor default TAlphaColors.Aqua;
    property LinkThickness: integer read FLinkThickness write FLinkThickness default 4;
    property LinkSelectedThickness: integer read FLinkSelectedThickness write FLinkSelectedThickness default 5;

    property PinCompatibleColor: TAlphaColor read FPinCompatibleColor write FPinCompatibleColor default TAlphaColors.Aqua;
    property PinIncompatibleColor: TAlphaColor read FPinIncompatibleColor write FPinIncompatibleColor default TAlphaColors.Red;

    // Events
    property OnSelectionChanged: TNodeSelectionChangedEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnNodeChanged: TNodeChangedEvent read FOnNodeChanged write FOnNodeChanged;
    property OnUpdatedStatus: TNotifyEvent read FOnUpdatedStatus write SetOnUpdatedStatus;
    property GridType: TGridType read FGridType write SetGridType;
  end;

implementation

uses
  System.IOUtils, FMX.NodeEditor.Form.Search, FMX.NodeEditor.Node.Command,
  System.Generics.Defaults, FMX.Platform, System.Math.Vectors,
  System.Diagnostics;

function PtInRectF(const Pt: TPointF; const R: TRectF): Boolean; inline;
begin
  Result := (Pt.X >= R.Left) and (Pt.X <= R.Right) and
    (Pt.Y >= R.Top) and (Pt.Y <= R.Bottom);
end;

function RectFIntersects(const R1, R2: TRectF): Boolean;
begin
  Result := not ((R1.Right < R2.Left) or (R1.Left > R2.Right) or
    (R1.Bottom < R2.Top) or (R1.Top > R2.Bottom));
end;

function CubicBezierPointF(const P0, P1, P2, P3: TPointF; T: single): TPointF;
var
  U, TT, UU, UUU, TTT: single;
begin
  U := 1 - T;
  TT := T * T;
  UU := U * U;
  UUU := UU * U;
  TTT := TT * T;

  Result.X := UUU * P0.X +
    3 * UU * T * P1.X +
    3 * U * TT * P2.X +
    TTT * P3.X;

  Result.Y := UUU * P0.Y +
    3 * UU * T * P1.Y +
    3 * U * TT * P2.Y +
    TTT * P3.Y;
end;

function LineIntersectsRectF(P1, P2: TPointF; const R: TRectF): Boolean;
var
  N: TRectF;
  Dx, Dy: Single;
  T0, T1: Single;

  function ClipTest(P, Q: Single; var T0, T1: Single): Boolean;
  var
    Rr: Single;
  begin
    if Abs(P) < 1e-6 then
      Exit(Q >= 0);

    Rr := Q / P;
    if P < 0 then
    begin
      if Rr > T1 then
        Exit(False);
      if Rr > T0 then
        T0 := Rr;
    end
    else
    begin
      if Rr < T0 then
        Exit(False);
      if Rr < T1 then
        T1 := Rr;
    end;
    Result := True;
  end;

begin
  N := R;
  N.NormalizeRect;

  if PtInRectF(P1, N) or PtInRectF(P2, N) then
    Exit(True);

  Dx := P2.X - P1.X;
  Dy := P2.Y - P1.Y;
  T0 := 0.0;
  T1 := 1.0;

  Result :=
    ClipTest(-Dx, P1.X - N.Left, T0, T1) and
    ClipTest(Dx, N.Right - P1.X, T0, T1) and
    ClipTest(-Dy, P1.Y - N.Top, T0, T1) and
    ClipTest(Dy, N.Bottom - P1.Y, T0, T1);
end;

function NodePaintCompare(const Item1, Item2: TCustomNode): Integer;
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

procedure BuildSortedNodeList(AGraph: TNodeGraph; AList: TList<TCustomNode>);
begin
  AList.Clear;

  if AGraph = nil then
    Exit;

  for var i := 0 to AGraph.Nodes.Count - 1 do
    AList.Add(AGraph.Nodes[i]);

  AList.Sort(TComparer<TCustomNode>.Construct(NodePaintCompare));
end;

{ TNodeEditor }

constructor TNodeEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoCapture := True;
  CanFocus := True;
  TabStop := True;

  FGraph := TNodeGraph.Create;
  FGraph.OnGraphChanged := NodeGraphChanged;

  FController := TNodeEditorController.Create(FGraph);
  FController.Selection.OnChanged := ControllerSelectionChanged;
  FController.PinSelection.OnChanged := DoPinSelectionChanged;

  FDragCommandNodes := TList<TCustomNode>.Create;

  FPaintNodesSorted := TList<TCustomNode>.Create;
  FPaintNodesDirty := True;
  FLastHoverMouseX := Low(integer);
  FLastHoverMouseY := Low(integer);
  FLastMouseMoveTick := 0;
  FLastPaintTick := 0;

  FZoom := 1.0;
  FSnapToGrid := False;
  FGridSize := 40;
  FSnapToNodes := True;
  FNodeSnapDistance := 10.0;
  FOffsetX := 0;
  FOffsetY := 0;

  FShowSnapGuides := True;
  FGuideSnapXActive := False;
  FGuideSnapYActive := False;
  FGuideSnapX := 0;
  FGuideSnapY := 0;

  // Axes defaults
  FShowAxes := False;
  FAxesColor := TAlphaColors.Silver;
  FAxesThickness := 2;

  // Styling Defaults
  FPinRadius := 8;
  FPinBorderWidth := 1;
  FPinBorderColor := TAlphaColors.Black;
  FPinDefaultColor := TAlphaColors.Lime;
  FPinExecColor := TAlphaColors.White;
  FPinSelectedColor := TAlphaColors.Lime;
  FPinHoverColor := TAlphaColors.Aqua;

  FLinkColor := TAlphaColors.Yellow;
  FLinkSelectedColor := TAlphaColors.Red;
  FLinkHoverColor := TAlphaColors.Aqua;
  FLinkThickness := 4;
  FLinkSelectedThickness := 5;

  FHoveredPinCompatible := False;
  FPinCompatibleColor := TAlphaColors.Aqua;
  FPinIncompatibleColor := TAlphaColors.Red;

  FResizingNode := False;
  FResizeNode := nil;
  FResizeEdgeSize := 6;

  FReconnectingLink := False;
  FReconnectLink := nil;
  FReconnectFixedPin := nil;
  FReconnectMovingFromSide := False;

  FDraggingLink := False;
  FTempStartMousePos := Point(0, 0);

  FPanning := False;
  FRightMouseMoved := False;
  FRightButtonDown := False;

  FPopupMenu := TPopupMenu.Create(Self);
  BuildContextMenu;
  //PopupMenu := FPopupMenu;
end;

destructor TNodeEditor.Destroy;
begin
  FPaintNodesSorted.Free;
  FController.Free;
  FDragCommandNodes.Free;
  FGraph.Free;
  FPopupMenu.Free;
  inherited Destroy;
end;

procedure TNodeEditor.ExecuteNodePropertyChange(ANode: TCustomNode; const AOldJSON, ANewJSON: string);
begin
  if ANode = nil then
    Exit;

  if AOldJSON = ANewJSON then
    Exit;

  if Controller <> nil then
    Controller.ExecuteCommand(
      TChangeNodePropertyCommand.Create(Graph, ANode, AOldJSON, ANewJSON))
  else if Graph <> nil then
    Graph.ExecuteCommand(
      TChangeNodePropertyCommand.Create(Graph, ANode, AOldJSON, ANewJSON));
end;

procedure TNodeEditor.InvalidateSortedNodes;
begin
  FPaintNodesDirty := True;
end;

procedure TNodeEditor.EnsureSortedNodes;
var
  i: integer;
begin
  if not FPaintNodesDirty then
    Exit;

  FPaintNodesSorted.Clear;

  if FGraph = nil then
    Exit;

  for i := 0 to FGraph.Nodes.Count - 1 do
    FPaintNodesSorted.Add(FGraph.Nodes[i]);

  FPaintNodesSorted.Sort(TComparer<TCustomNode>.Construct(NodePaintCompare));
  FPaintNodesDirty := False;
end;

procedure TNodeEditor.RequestRepaint(const AForce: boolean);
var
  T: UInt64;
begin
  if AForce then
  begin
    Repaint;
    Exit;
  end;

  T := TThread.GetTickCount64;
  if (T - FLastPaintTick) >= 16 then
  begin
    FLastPaintTick := T;
    Repaint;
  end;
end;

procedure TNodeEditor.NodeGraphChanged(Sender: TObject);
begin
  InvalidateSortedNodes;
  RequestRepaint(True);
end;

function TNodeEditor.IsNodeInDragSelection(ANode: TCustomNode): boolean;
begin
  Result := (ANode <> nil) and (FDragCommandNodes.IndexOf(ANode) >= 0);
end;

function TNodeEditor.GetDraggedSelectionBoundsAtOffset(const AOffsetX, AOffsetY: single): TRectF;
var
  i: integer;
  N: TCustomNode;
  L, T, R, B: single;
  First: boolean;
begin
  Result := RectF(0, 0, 0, 0);
  First := True;

  for i := 0 to FDragCommandNodes.Count - 1 do
  begin
    N := TCustomNode(FDragCommandNodes[i]);
    if N = nil then
      Continue;

    L := FDragOldPositions[i].X + AOffsetX;
    T := FDragOldPositions[i].Y + AOffsetY;
    R := L + N.Width;
    B := T + N.Height;

    if First then
    begin
      Result := RectF(L, T, R, B);
      First := False;
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
  end;
end;

procedure TNodeEditor.ApplyNodeSnap(var AOffsetX, AOffsetY: single; out ASnappedX, ASnappedY: boolean);
var
  DragBounds: TRectF;
  OtherBounds: TRectF;
  DragLeft, DragRight, DragTop, DragBottom: single;
  DragCenterX, DragCenterY: single;
  OtherLeft, OtherRight, OtherTop, OtherBottom: single;
  OtherCenterX, OtherCenterY: single;
  BestDX, BestDY: single;
  CandDX, CandDY: single;
  BestAbsDX, BestAbsDY: single;
  D: single;
  i: integer;
  N: TCustomNode;
  BestGuideX, BestGuideY: single;
begin
  ClearSnapGuides;
  ASnappedX := False;
  ASnappedY := False;

  if not FSnapToNodes then
    Exit;   // ??
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

  for i := 0 to FGraph.Nodes.Count - 1 do
  begin
    N := TCustomNode(FGraph.Nodes[i]);
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
var
  SX, SY: integer;
begin
  if not FShowSnapGuides then
    Exit;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Dash := TStrokeDash.Dash;
  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Color := $FFFFD740;

  if FGuideSnapXActive then
  begin
    SX := Round(FGuideSnapX * FZoom) + FOffsetX;
    Canvas.DrawLine(TPointF.Create(SX, 0), TPointF.Create(SX, Height), 1);
  end;

  if FGuideSnapYActive then
  begin
    SY := Round(FGuideSnapY * FZoom) + FOffsetY;
    Canvas.DrawLine(TPointF.Create(0, SY), TPointF.Create(Width, SY), 1);
  end;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1;
end;

procedure TNodeEditor.AddNode(ANode: TCustomNode);
begin
  if FController <> nil then
    FController.AddNode(ANode)
  else if (FGraph <> nil) and (ANode <> nil) then
    FGraph.ExecuteCommand(TAddNodeCommand.Create(FGraph, ANode));
  Repaint;
end;

procedure TNodeEditor.RemoveNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  if FController <> nil then
    FController.RemoveNode(ANode)
  else
    FGraph.RemoveNode(ANode);

  SyncControllerSelectionToView;
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.RemoveLink(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  if FController <> nil then
    FController.RemoveLink(ALink)
  else
    FGraph.ExecuteCommand(TRemoveLinkCommand.Create(FGraph, ALink));

  SyncControllerSelectionToView;
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.Clear;
begin
  if FController <> nil then
    FController.Clear
  else
    FGraph.Clear;

  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.Undo;
begin
  if FController <> nil then
    FController.Undo
  else
    FGraph.Undo;
  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.Redo;
begin
  if FController <> nil then
    FController.Redo
  else
    FGraph.Redo;
  ResetStateAfterGraphReload;
  Repaint;
end;

function TNodeEditor.SaveToJSONText: string;
begin
  if FController <> nil then
    Result := FController.SaveToJSONText(FZoom, FOffsetX, FOffsetY)
  else
    Result := '';
end;

procedure TNodeEditor.LoadFromJSONText(const S: string);
var
  Z: double;
  OX, OY: integer;
begin
  if Trim(S) = '' then
    Exit;

  if FController <> nil then
  begin
    FController.LoadFromJSONText(S, Z, OX, OY);
    FZoom := Z;
    FOffsetX := OX;
    FOffsetY := OY;
  end;

  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.SaveToFile(const AFileName: string);
begin
  if FController <> nil then
    FController.SaveToFile(AFileName, FZoom, FOffsetX, FOffsetY);
end;

procedure TNodeEditor.LoadFromFile(const AFileName: string);
var
  Z: double;
  OX, OY: integer;
begin
  if FController <> nil then
  begin
    FController.LoadFromFile(AFileName, Z, OX, OY);
    FZoom := Z;
    FOffsetX := OX;
    FOffsetY := OY;
  end;

  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.ClearPinSelection;
begin
  if FController.PinSelection <> nil then
    FController.PinSelection.Clear;
end;

procedure TNodeEditor.SelectPinInternal(APin: TNodePin; AAppend: boolean);
begin
  if FController.PinSelection <> nil then
    FController.PinSelection.SelectPin(APin, AAppend);
end;

procedure TNodeEditor.TogglePinSelection(APin: TNodePin);
begin
  if FController.PinSelection <> nil then
    FController.PinSelection.TogglePin(APin);
end;

procedure TNodeEditor.DoPinSelectionChanged(Sender: TObject);
begin
  if Assigned(FOnPinSelectionChanged) then
    FOnPinSelectionChanged(Self);
end;

function TNodeEditor.GetPrimarySelectedNode: TCustomNode;
begin
  if (FController.Selection <> nil) and (FController.Selection.NodeCount > 0) then
    Result := GetSelectedNode(0)
  else
    Result := nil;
end;

function TNodeEditor.SelectedPinCount: integer;
begin
  if FController.PinSelection <> nil then
    Result := FController.PinSelection.Count
  else
    Result := 0;
end;

function TNodeEditor.GetSelectedPin(Index: integer): TNodePin;
begin
  if FController.PinSelection <> nil then
    Result := FController.PinSelection.GetPin(Index)
  else
    Result := nil;
end;

function TNodeEditor.CanConnectSelectedPins: boolean;
var
  P1, P2: TNodePin;
begin
  Result := False;
  if FController.PinSelection.Count <> 2 then
    Exit;

  P1 := FController.PinSelection.GetPin(0);
  P2 := FController.PinSelection.GetPin(1);

  Result := (FGraph <> nil) and FGraph.CanConnect(P1, P2);
end;

procedure TNodeEditor.ConnectSelectedPins;
var
  P1, P2: TNodePin;
  Allow: boolean;
begin
  if (FGraph = nil) or (FController.PinSelection.Count <> 2) then
    Exit;

  P1 := FController.PinSelection.GetPin(0);
  P2 := FController.PinSelection.GetPin(1);

  Allow := True;
  if Assigned(FOnBeforeConnectPins) then
    FOnBeforeConnectPins(Self, P1, P2, Allow);

  if not Allow then
    Exit;

  if not FGraph.CanConnect(P1, P2) then
    Exit;

  if P1.Direction = pdOutput then
  begin
    if not FGraph.LinkExists(P1, P2) then
      FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, P1, P2));
  end
  else
  begin
    if not FGraph.LinkExists(P2, P1) then
      FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, P2, P1));
  end;

  if Assigned(FOnAfterConnectPins) then
    FOnAfterConnectPins(Self, P1, P2);

  ClearPinSelection;
  Repaint;
end;

procedure TNodeEditor.ClearSelectionInternal;
begin
  if FController.Selection <> nil then
    FController.Selection.Clear;

  ClearPinSelection;

  if (FController <> nil) and ((FController.Selection.NodeCount > 0) or
    (FController.Selection.LinkCount > 0)) then
    FController.Selection.Clear;

  SyncNodeSelectedFlags;
end;

function TNodeEditor.GetPrimarySelectedLink: TNodeLink;
begin
  if (FController.Selection <> nil) and (FController.Selection.LinkCount > 0) then
    Result := FController.Selection.GetLink(0)
  else
    Result := nil;
end;

procedure TNodeEditor.DeleteSelection;
begin
  if FController = nil then
    Exit;

  FController.DeleteSelection;
  SyncControllerSelectionToView;
  Repaint;
end;

procedure TNodeEditor.ClearSelection;
begin
  ClearSelectionInternal;
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.SelectNodeInternal(ANode: TCustomNode; AAppend: Boolean);
begin
  if ANode = nil then
    Exit;

  if not AAppend then
    ClearPinSelection
  else if FController.Selection.LinkCount > 0 then
    FController.Selection.Links.Clear;

  if FController.Selection <> nil then
    FController.Selection.SelectNode(ANode, AAppend);

  if FController <> nil then
    FController.Selection.SelectNode(ANode, AAppend);

  SyncNodeSelectedFlags;
  InvalidateSortedNodes;
end;

procedure TNodeEditor.SelectLinkInternal(ALink: TNodeLink; AKeepNodes: Boolean);
begin
  if (ALink = nil) or (FController.Selection = nil) then
    Exit;
  if not AKeepNodes then
  begin
    FController.Selection.Clear;
    ClearPinSelection;
  end;
  FController.Selection.SelectLink(ALink, True);

  if FController <> nil then
  begin
    if not AKeepNodes then
      FController.Selection.Clear;
    FController.Selection.SelectLink(ALink, True);
  end;

  SyncNodeSelectedFlags;
end;

procedure TNodeEditor.ToggleNodeSelection(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  if FController.Selection.ContainsNode(ANode) then
  begin
    RemoveNodeFromSelection(ANode);
  end
  else
  begin
    AddNodeToSelection(ANode);
  end;

  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.AddNodeToSelection(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  if FController.Selection <> nil then
    FController.Selection.AddNodeToSelection(ANode);

  ClearPinSelection;

  if FController <> nil then
    FController.Selection.SelectNode(ANode, True);

  SyncNodeSelectedFlags;
  InvalidateSortedNodes;
end;

procedure TNodeEditor.RemoveNodeFromSelection(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  if FController.Selection <> nil then
    FController.Selection.RemoveNode(ANode);

  if FController <> nil then
    FController.Selection.RemoveNode(ANode);

  SyncNodeSelectedFlags;
  InvalidateSortedNodes;
end;

procedure TNodeEditor.ToggleLinkSelection(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  if FController.Selection.ContainsLink(ALink) then
    RemoveLinkFromSelection(ALink)
  else
    AddLinkToSelection(ALink);

  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.AddLinkToSelection(ALink: TNodeLink);
begin
  if (ALink = nil) or (FController.Selection = nil) then
    Exit;

  FController.Selection.AddLinkToSelection(ALink);
  ClearPinSelection;

  if FController <> nil then
    FController.Selection.AddLinkToSelection(ALink);
end;

procedure TNodeEditor.RemoveLinkFromSelection(ALink: TNodeLink);
begin
  if (ALink = nil) or (FController.Selection = nil) then
    Exit;

  FController.Selection.RemoveLinkFromSelection(ALink);

  if FController <> nil then
    FController.Selection.RemoveLinkFromSelection(ALink);
end;

procedure TNodeEditor.SyncNodeSelectedFlags;
var
  i: integer;
  N: TCustomNode;
begin
  if FGraph = nil then
    Exit;

  for i := 0 to FGraph.Nodes.Count - 1 do
  begin
    N := TCustomNode(FGraph.Nodes[i]);
    if N <> nil then
      N.Selected := (FController.Selection <> nil) and FController.Selection.ContainsNode(N);
  end;
end;

function TNodeEditor.IsMouseNearLinkStart(ALink: TNodeLink; SX, SY: Integer): Boolean;
var
  P0, P1: TPointF; // Using World points now
  D0, D1: Double;
  MouseW: TPointF;
begin
  Result := False;

  if (ALink = nil) or (ALink.FromPin = nil) or (ALink.ToPin = nil) then
    Exit;

  MouseW := ScreenToWorld(SX, SY);
  P0 := GetPinWorldPosition(ALink.FromPin);
  P1 := GetPinWorldPosition(ALink.ToPin);

  D0 := Hypot(MouseW.X - P0.X, MouseW.Y - P0.Y);
  D1 := Hypot(MouseW.X - P1.X, MouseW.Y - P1.Y);

  Result := D0 <= D1;
end;

function TNodeEditor.GetVisibleWorldRect: TRectF;
var
  P0, P1: TPointF;
begin
  P0 := ScreenToWorld(0, 0);
  P1 := ScreenToWorld(Round(Width), Round(Height));

  Result.Left := Min(P0.X, P1.X);
  Result.Top := Min(P0.Y, P1.Y);
  Result.Right := Max(P0.X, P1.X);
  Result.Bottom := Max(P0.Y, P1.Y);
end;

function TNodeEditor.GetPinWorldPosition(APin: TNodePin): TPointF;
begin
  if (APin = nil) or (APin.OwnerNode = nil) then
    Exit(PointF(0, 0));
  Result := TCustomNode(APin.OwnerNode).GetPinWorldPosition(APin);
end;

procedure TNodeEditor.GetLinkBezierWorldPoints(ALink: TNodeLink; out P0, P1, P2, P3: TPointF);
var
  DX, DY: single;
  Dist: single;
  D: single;
begin
  P0 := GetPinWorldPosition(ALink.FromPin);
  P3 := GetPinWorldPosition(ALink.ToPin);

  DX := P3.X - P0.X;
  DY := P3.Y - P0.Y;
  Dist := Hypot(DX, DY);

  // Divide by FZoom to keep the visual curve consistent
  D := Dist * 0.35;
  D := EnsureRange(D, 30 / FZoom, 150 / FZoom);

  P1 := P0;
  P1.X := P1.X + D;

  P2 := P3;
  P2.X := P2.X - D;
end;

procedure TNodeEditor.NotifySelectionChanged;
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self);
end;

procedure TNodeEditor.ControllerSelectionChanged(Sender: TObject);
begin
  SyncControllerSelectionToView;
end;

procedure TNodeEditor.SyncControllerSelectionToView;
{var
  i: integer;
  N: TCustomNode;
  L: TNodeLink;   }
begin
  if FController = nil then
    Exit;

  {if FController.Selection <> nil then
    FController.Selection.Clear;

  ClearPinSelection;

  for i := 0 to FController.Selection.NodeCount - 1 do
  begin
    N := FController.Selection.GetNode(i);
    if (N <> nil) and (FController.Selection <> nil) then
      FController.Selection.AddNodeToSelection(N);
  end;

  for i := 0 to FController.Selection.LinkCount - 1 do
  begin
    L := FController.Selection.GetLink(i);
    if (L <> nil) and (FController.Selection <> nil) then
      FController.Selection.AddLinkToSelection(L);
  end;

  SyncNodeSelectedFlags;}
  InvalidateSortedNodes;
  NotifySelectionChanged;
  Repaint;
end;

function TNodeEditor.SelectedNodeCount: Integer;
begin
  if FController.Selection <> nil then
    Result := FController.Selection.NodeCount
  else
    Result := 0;
end;

function TNodeEditor.SelectedLinkCount: Integer;
begin
  if FController.Selection <> nil then
    Result := FController.Selection.LinkCount
  else
    Result := 0;
end;

function TNodeEditor.IsLinkInsideWorldRect(ALink: TNodeLink; const R: TRectF): boolean;
var
  P0, P1, P2, P3: TPointF;
  Prev, Cur: TPointF;
  k: integer;
  BR: TRectF;
begin
  Result := False;

  if (ALink = nil) or (ALink.FromPin = nil) or (ALink.ToPin = nil) then
    Exit;

  if (ALink.FromPin.OwnerNode = nil) or (ALink.ToPin.OwnerNode = nil) then
    Exit;

  GetLinkBezierWorldPoints(ALink, P0, P1, P2, P3);

  BR := RectF(
    Min(Min(P0.X, P1.X), Min(P2.X, P3.X)),
    Min(Min(P0.Y, P1.Y), Min(P2.Y, P3.Y)),
    Max(Max(P0.X, P1.X), Max(P2.X, P3.X)),
    Max(Max(P0.Y, P1.Y), Max(P2.Y, P3.Y)));

  if not RectFIntersects(BR, R) then
    Exit(False);

  if PtInRectF(P0, R) or PtInRectF(P3, R) then
    Exit(True);

  Prev := P0;
  for k := 1 to 20 do
  begin
    Cur := CubicBezierPointF(P0, P1, P2, P3, k / 20);

    if PtInRectF(Cur, R) then
      Exit(True);

    if LineIntersectsRectF(Prev, Cur, R) then
      Exit(True);

    Prev := Cur;
  end;
end;

function TNodeEditor.GetSelectedNode(Index: Integer): TCustomNode;
begin
  if FController.Selection <> nil then
    Result := FController.Selection.GetNode(Index)
  else
    Result := nil;
end;

procedure TNodeEditor.SelectNode(ANode: TCustomNode; AAppend: Boolean);
begin
  SelectNodeInternal(ANode, AAppend);
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.SelectLink(ALink: TNodeLink);
begin
  SelectLinkInternal(ALink);
  NotifySelectionChanged;
  Repaint;
end;

function TNodeEditor.WorldToScreen(WX, WY: Single): TPoint;
begin
  Result.X := Round(WX * FZoom) + FOffsetX;
  Result.Y := Round(WY * FZoom) + FOffsetY;
end;

function TNodeEditor.ScreenToWorld(SX, SY: Integer): TPointF;
begin
  Result.X := (SX - FOffsetX) / FZoom;
  Result.Y := (SY - FOffsetY) / FZoom;
end;

function TNodeEditor.SnapWorldValue(V: Single): Single;
begin
  if FSnapToGrid and (FGridSize > 1) then
    Result := Round(V / FGridSize) * FGridSize
  else
    Result := V;
end;

procedure TNodeEditor.DrawSingleNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  var R := ANode.GetScreenBounds(FZoom, FOffsetX, FOffsetY);

  var Handled := False;
  if Assigned(FOnDrawNode) then
    FOnDrawNode(Self, Canvas, ANode, R, FZoom, FOffsetX, FOffsetY, Handled);

  if not Handled then
    DefaultDrawNode(ANode, R);

  DrawNodePins(ANode);
  if ANode.Selected and (ANode.VisualKind <> TNodeVisualKind.nvReroute) then
  begin
    var HR := GetResizeHandleRect(ANode);
    DrawGrip(HR);
  end;
end;

procedure TNodeEditor.DefaultDrawNode(ANode: TCustomNode; const ARect: TRect);
var
  R, HeaderR, BodyR: TRectF;
  HeaderH: Single;
  PinRadius: Single;
  CornerRadius: Single;
begin
  if ANode = nil then
    Exit;

  R := ARect;

  HeaderH := 28 * Zoom;
  PinRadius := 8 * Zoom;
  CornerRadius := 10 * Zoom;

  if ANode.Collapsed and (ANode.VisualKind = nvNormal) then
  begin
    R.Bottom := R.Top + HeaderH;
  end;

  case ANode.VisualKind of
    nvComment:
      begin
        // Fill
        Canvas.Fill.Kind := TBrushKind.Solid;
        Canvas.Fill.Color := $FF1E2125; //BodyColor;
        Canvas.FillRect(R, CornerRadius, CornerRadius, AllCorners, 1);

        // Head
        HeaderR := RectF(R.Left, R.Top, R.Right, R.Top + (24 * Zoom));
        Canvas.Fill.Kind := TBrushKind.Solid;
        Canvas.Fill.Color := ANode.HeaderColor;
        Canvas.FillRect(HeaderR, CornerRadius, CornerRadius, [TCorner.TopLeft, TCorner.TopRight], 1);

        // Frame
        if ANode.Selected then
        begin
          Canvas.Stroke.Color := $FFFFD740;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end
        else if ANode.Highlighted then
        begin
          Canvas.Stroke.Color := TAlphaColors.Red;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end
        else if ANode.Hovered then
        begin
          Canvas.Stroke.Color := ANode.HeaderColor;//TAlphaColors.Blue;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end
        else
        begin
          Canvas.Stroke.Color := ANode.HeaderColor;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end;
        Canvas.DrawRect(R, CornerRadius, CornerRadius, AllCorners, 1);

        // Text Head
        Canvas.Fill.Color := TAlphaColors.White;
        Canvas.Font.Size := (10 * Zoom);
        Canvas.Fill.Kind := TBrushKind.Solid;

        var RF := TRectF.Create(R.Left + (8 * Zoom), R.Top + (5 * Zoom), R.Left + 1000, R.Top + 1000);
        Canvas.FillText(RF, ANode.Title, False, 1, [], TTextAlign.Leading, TTextAlign.Leading);

        // Text Body
        if ANode.CommentText <> '' then
          Canvas.FillText(
            TRectF.Create(R.Left + (8 * Zoom), HeaderR.Bottom + (8 * Zoom), R.Left + 1000, HeaderR.Bottom + 1000),
            ANode.CommentText,
            False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
      end;
    nvReroute:
      begin
        Canvas.Stroke.Kind := TBrushKind.Solid;
        if ANode.Selected then
        begin
          Canvas.Fill.Kind := TBrushKind.Solid;
          Canvas.Fill.Color := TAlphaColors.White;
          Canvas.FillEllipse(TRectF.Create(R.Left - 5, R.Top - 5, R.Right + 5, R.Bottom + 5), 0.3);
        end;

        if ANode.Highlighted then
        begin
          Canvas.Stroke.Thickness := (3 * Zoom);
        end
        else if ANode.Hovered then
        begin
          Canvas.Fill.Color := TAlphaColors.Yellow;
          Canvas.Stroke.Thickness := (2 * Zoom);
        end
        else
        begin
          Canvas.Fill.Color := TAlphaColors.White;
          Canvas.Stroke.Thickness := (2 * Zoom);
        end;
                                 {
        Canvas.Stroke.Color := TAlphaColors.Black;
        Canvas.FillEllipse(TRectF.Create(R.Left, R.Top, R.Right, R.Bottom), 1);
        Canvas.DrawEllipse(TRectF.Create(R.Left, R.Top, R.Right, R.Bottom), 1);    }

        var Radius: Single := PinRadius;
        if ANode.Hovered or ANode.Highlighted then
        begin
          Canvas.Stroke.Kind := TBrushKind.Solid;
          if ANode.Highlighted then
            Canvas.Fill.Color := ANode.GetInput(0).PinType.Color
          else
            Canvas.Fill.Color := $FFFFD740;
          Canvas.Stroke.Color := $FFFFD740;
          Canvas.Stroke.Thickness := 2 * Zoom;
        end
        else
        begin
          Canvas.Fill.Color := ANode.GetInput(0).PinType.Color;
          Canvas.Stroke.Kind := TBrushKind.Solid;
          Canvas.Stroke.Color := ANode.HeaderColor;
          Canvas.Stroke.Thickness := 2 * Zoom;
          Radius := Radius * 0.8;
        end;

        var PR := TRectF.Create(R.Left, R.Top, R.Right, R.Bottom).CenterPoint;

        // Highlight frame
        Canvas.Fill.Kind := TBrushKind.Solid;
        var RE := TRectF.Create(PR.X - Radius, PR.Y - Radius, PR.X + Radius, PR.Y + Radius);
        Canvas.DrawEllipse(RE, 1);

        // Body
        RE.Inflate(-Radius * 0.4, -Radius * 0.4);
        Canvas.FillEllipse(RE, 1);
      end;
    nvNormal:
      begin
        BodyR := R;

        // Shadow
        DrawShadowedRect(Canvas, BodyR, CornerRadius, Zoom);

        // Fill Body
        Canvas.Fill.Kind := TBrushKind.Solid;
        Canvas.Fill.Color := $FF1E2125;  //BodyColor
        Canvas.Stroke.Kind := TBrushKind.None;
        Canvas.FillRect(BodyR, CornerRadius, CornerRadius, AllCorners, 1);

        // Fill Head
        HeaderR := RectF(R.Left, R.Top, R.Right, R.Top + HeaderH);
        Canvas.Fill.Kind := TBrushKind.Solid;
        Canvas.Fill.Color := ANode.HeaderColor;
        Canvas.Stroke.Kind := TBrushKind.None;
        Canvas.FillRect(HeaderR, CornerRadius, CornerRadius, [TCorner.TopLeft, TCorner.TopRight], 1);

        // Frame
        Canvas.Fill.Kind := TBrushKind.None;
        Canvas.Stroke.Kind := TBrushKind.Solid;

        if ANode.Selected then
        begin
          Canvas.Stroke.Color := $FFFFD740;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end
        else if ANode.Highlighted then
        begin
          Canvas.Stroke.Color := ANode.HeaderColor;//TAlphaColors.Blue;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end
        else if ANode.Hovered then
        begin
          Canvas.Stroke.Color := ANode.HeaderColor;//TAlphaColors.Blue;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end
        else
        begin
          Canvas.Stroke.Color := ANode.HeaderColor;
          Canvas.Stroke.Thickness := 1 * Zoom;
        end;

        Canvas.DrawRect(R, CornerRadius, CornerRadius, AllCorners, 1);

        // Head Text
        Canvas.Fill.Kind := TBrushKind.Solid;
        Canvas.Fill.Color := TAlphaColors.White;
        Canvas.Font.Size := 10 * Zoom;
        var RF := TRectF.Create(
          R.Left + (8 * Zoom),
          R.Top + (6 * Zoom),
          R.Left + (8 * Zoom) + 1000,
          R.Top + (8 * Zoom) + 1000);
        Canvas.FillText(RF, ANode.Title, False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
      end;
  else
    // Do nothing
  end;
end;

procedure TNodeEditor.DefaultDrawPin(APin: TNodePin; const Center: TPoint; Radius: integer; ASelected, AHovered, AHighlighted: boolean);
begin
  if APin = nil then
    Exit;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := TAlphaColors.Black;
  Canvas.Stroke.Thickness := 1 * Zoom;

  //PX := R.Left;
  //PY := R.Top + Round(P.LocalY * Zoom);

  if APin.Kind = pkExec then
    Canvas.Fill.Color := TAlphaColors.White
  else if APin.PinType <> nil then
    Canvas.Fill.Color := APin.PinType.Color
  else
    Canvas.Fill.Color := TAlphaColors.Green;

  var SRadius: Single := Radius;
  if (APin.Id = APin.OwnerNode.HoveredPinId) or ASelected then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := $FFFFD740;
    Canvas.Stroke.Thickness := 2 * Zoom;
  end
  else
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := APin.OwnerNode.HeaderColor;
    Canvas.Stroke.Thickness := 2 * Zoom;
    SRadius := SRadius * 0.8;
  end;

      // Highlight frame
  Canvas.Fill.Kind := TBrushKind.Solid;
  var RE := TRectF.Create(Center.X - SRadius, Center.Y - SRadius, Center.X + SRadius, Center.Y + SRadius);
  Canvas.DrawEllipse(RE, 1);

      // Body
  RE.Inflate(-SRadius * 0.4, -SRadius * 0.4);
  Canvas.FillEllipse(RE, 1);
end;

procedure TNodeEditor.DrawNodePins(ANode: TCustomNode);
var
  i: integer;
  P: TNodePin;
  PX, PY: integer;
  PinRadiusScaled: integer;
  Handled: boolean;
  Center: TPoint;
  IsSelected: boolean;
  IsHovered: boolean;
begin
  if ANode = nil then
    Exit;
  if ANode.VisualKind in [nvComment] then
    Exit;

  PinRadiusScaled := Round(FPinRadius * FZoom);

  if ANode.VisualKind <> TNodeVisualKind.nvReroute then
  begin
    for i := 0 to ANode.InputCount - 1 do
    begin
      P := ANode.GetInput(i);
      if (P = nil) or P.Hidden then
        Continue;

      PX := Round(ANode.X * FZoom) + FOffsetX;
      PY := Round((ANode.Y + P.LocalY) * FZoom) + FOffsetY;
      Center := Point(PX, PY);

      IsSelected := FController.PinSelection.Contains(P);
      IsHovered := (FHoveredPin = P) and (FTempFromPin = nil);

      Handled := False;
      if Assigned(FOnDrawPin) then
        FOnDrawPin(Self, Canvas, P, Center, PinRadiusScaled,
          IsSelected, IsHovered, ANode.Highlighted, Handled);

      if not Handled then
        DefaultDrawPin(P, Center, PinRadiusScaled, IsSelected, IsHovered,
          ANode.Highlighted);

      // Text
      var TextSize := TSize.Create(Round(Canvas.TextWidth(P.Name)), Round(Canvas.TextHeight(P.Name)));
      Canvas.Fill.Kind := TBrushKind.Solid;
      Canvas.Fill.Color := TAlphaColors.White;
      Canvas.FillText(
        TRectF.Create(
          Center.X + (PinRadius + 6) * FZoom,
          Center.Y - TextSize.Height div 2,
          Center.X + (PinRadius + 6) * FZoom + TextSize.Width,
          Center.Y + TextSize.Height div 2),
        P.Name, False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
    end;

    for i := 0 to ANode.OutputCount - 1 do
    begin
      P := ANode.GetOutput(i);
      if (P = nil) or P.Hidden then
        Continue;

      PX := Round((ANode.X + ANode.Width) * FZoom) + FOffsetX;
      PY := Round((ANode.Y + P.LocalY) * FZoom) + FOffsetY;
      Center := Point(PX, PY);

      IsSelected := FController.PinSelection.Contains(P);
      IsHovered := (FHoveredPin = P) and (FTempFromPin = nil);

      Handled := False;
      if Assigned(FOnDrawPin) then
        FOnDrawPin(Self, Canvas, P, Center, PinRadiusScaled,
          IsSelected, IsHovered, ANode.Highlighted, Handled);

      if not Handled then
        DefaultDrawPin(P, Center, PinRadiusScaled, IsSelected, IsHovered,
          ANode.Highlighted);

      // Text
      Canvas.Fill.Kind := TBrushKind.Solid;
      Canvas.Fill.Color := TAlphaColors.White;
      var TextSize := TSize.Create(Round(Canvas.TextWidth(P.Name)), Round(Canvas.TextHeight(P.Name)));
      Canvas.FillText(TRectF.Create(
          Center.X - TextSize.Width - (PinRadius + 6) * FZoom,
          Center.Y - TextSize.Height div 2,
          Center.X - (PinRadius + 6) * FZoom,
          Center.Y + TextSize.Height div 2),
        P.Name, False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
    end;
  end;
end;

procedure TNodeEditor.DefaultDrawLink(ALink: TNodeLink; const P0, P1, P2, P3: TPoint; ASelected, AHovered: boolean);
begin
  if ASelected then
  begin
    //Canvas.Pen.Color := FLinkSelectedColor;
    //Canvas.Pen.Width := FLinkSelectedThickness;
  end
  else if AHovered then
  begin
    //Canvas.Pen.Color := FLinkHoverColor;
    //Canvas.Pen.Width := FLinkSelectedThickness;
  end
  else
  begin
    //Canvas.Pen.Color := FLinkColor;
    //Canvas.Pen.Width := FLinkThickness;
  end;

  //Canvas.Pen.Style := psSolid;
  //DrawCubicBezier(Canvas, P0, P1, P2, P3);
  //Canvas.Pen.Width := 1;


  Canvas.Stroke.Kind := TBrushKind.Solid;
  if ASelected then
  begin
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := $AAC97200;
    Canvas.Stroke.Thickness := 12 * Zoom;
    DrawCubicBezier(Canvas, P0, P1, P2, P3);
  end;
  begin
    Canvas.Stroke.Kind := TBrushKind.Gradient; //ALink.ToPin.OwnerNode.HeaderColor
    Canvas.Stroke.Gradient.Color := ALink.FromPin.OwnerNode.HeaderColor;
    Canvas.Stroke.Gradient.Color1 := ALink.ToPin.OwnerNode.HeaderColor;
    var S0 := ALink.FromPin.OwnerNode.GetPinScreenPosition(ALink.FromPin, FZoom, FOffsetX, FOffsetY);
    var S1 := ALink.ToPin.OwnerNode.GetPinScreenPosition(ALink.ToPin, FZoom, FOffsetX, FOffsetY);
    var Start: TPointF;
    var Stop: TPointF;
    GetGradientPoints(S0, S1, Start, Stop);
    Canvas.Stroke.Gradient.StartPosition.Point := Start;
    Canvas.Stroke.Gradient.StopPosition.Point := Stop;
      //Canvas.Stroke.Color := TAlphaColors.Yellow;
    Canvas.Stroke.Thickness := 3 * Zoom;
  end;
end;

function TNodeEditor.SnapWorldPoint(const P: TPointF): TPointF;
begin
  Result.X := SnapWorldValue(P.X);
  Result.Y := SnapWorldValue(P.Y);
end;

function TNodeEditor.GetNodeUnderMouse(SX, SY: Integer): TCustomNode;
var
  i: Integer;
  W: TPointF;
  N: TCustomNode;
begin
  Result := nil;
  W := ScreenToWorld(SX, SY);

  EnsureSortedNodes;

  for i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if (N.VisualKind <> nvComment) and N.HitTest(W.X, W.Y) then
      Exit(N);
  end;

  for i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if (N.VisualKind = nvComment) and N.HitTest(W.X, W.Y) then
      Exit(N);
  end;
end;

function TNodeEditor.GetPinUnderMouse(SX, SY: Integer; out Node: TCustomNode; out Pin: TNodePin): Boolean;
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

  W := ScreenToWorld(SX, SY);
  EnsureSortedNodes;

  for i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if N.VisualKind = nvComment then
      Continue;
    if N.VisualKind = nvReroute then
      HitRadiusWorld := 9 / FZoom
    else
      HitRadiusWorld := 10 / FZoom;

    var SkipInput := False;
    if N.VisualKind = nvReroute then
    begin
      SkipInput := True;
      if FReconnectFixedPin <> nil then
        SkipInput := FReconnectFixedPin.Direction = TPinDirection.pdInput
      else if FTempFromPin <> nil then
        SkipInput := FTempFromPin.Direction = TPinDirection.pdInput;
    end;

    if not SkipInput then
      for j := 0 to N.InputCount - 1 do
      begin
        P := N.GetInput(j);
        if P.Hidden then
          Continue;

        PW := GetPinWorldPosition(P);
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

      PW := GetPinWorldPosition(P);
      if Hypot(W.X - PW.X, W.Y - PW.Y) <= HitRadiusWorld then
      begin
        Node := N;
        Pin := P;
        Exit(True);
      end;
    end;
  end;
end;

function TNodeEditor.GetLinkUnderMouse(SX, SY: Integer; out Link: TNodeLink): Boolean;
var
  L: TNodeLink;
  P0, P1, P2, P3: TPointF;
  M: TPointF;
  TolWorld: Single;
  MinX, MinY, MaxX, MaxY: Single;
begin
  Result := False;
  Link := nil;

  M := ScreenToWorld(SX, SY);
  TolWorld := Max(4 / FZoom, 8 / FZoom);

  for var i := FGraph.Links.Count - 1 downto 0 do
  begin
    L := FGraph.Links[i];
    if (L = nil) or (L.FromPin = nil) or (L.ToPin = nil) then
      Continue;
    if (L.FromPin.OwnerNode = nil) or (L.ToPin.OwnerNode = nil) then
      Continue;
    GetLinkBezierWorldPoints(L, P0, P1, P2, P3);

    MinX := Min(Min(P0.X, P1.X), Min(P2.X, P3.X)) - TolWorld;
    MaxX := Max(Max(P0.X, P1.X), Max(P2.X, P3.X)) + TolWorld;
    MinY := Min(Min(P0.Y, P1.Y), Min(P2.Y, P3.Y)) - TolWorld;
    MaxY := Max(Max(P0.Y, P1.Y), Max(P2.Y, P3.Y)) + TolWorld;

    if (M.X < MinX) or (M.X > MaxX) or (M.Y < MinY) or (M.Y > MaxY) then
      Continue;
    if PointNearPath(M, P0, P1, P2, P3, TolWorld) then   //10 * Zoom
    begin
      Link := L;
      Exit(True);
    end;
  end;
end;

procedure TNodeEditor.DrawGrid;
var
  VR: TRectF;
  GX, GY: single;
  SX, SY: integer;
  StartX, StartY: single;
begin
  if FGridSize <= 0 then
    Exit;

  VR := GetVisibleWorldRect;

  Canvas.Stroke.Color := $55E0E0E0;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Thickness := 1 * FZoom;

  StartX := Floor(VR.Left / FGridSize) * FGridSize;
  GX := StartX;
  while GX <= VR.Right do
  begin
    {
    if FGridType = TGridType.Dots then
    begin
      y := FOffsetY mod Step;
      if y < 0 then
        y := y + Step;
      while y < Height do
      begin
        Canvas.DrawRect(TRectF.Create(TPointF.Create(SX, SY), 2, 2), 1);
        Inc(y, Step);
      end;
    end
    else
    }
    SX := WorldToScreen(GX, 0).X;
    Canvas.DrawLine(TPointF.Create(SX, 0), TPointF.Create(SX, Height), 1);
    GX := GX + FGridSize;
  end;

  if FGridType = TGridType.Lines then
  begin
    StartY := Floor(VR.Top / FGridSize) * FGridSize;
    GY := StartY;
    while GY <= VR.Bottom do
    begin
      SY := WorldToScreen(0, GY).Y;
      Canvas.DrawLine(TPointF.Create(0, SY), TPointF.Create(Width, SY), 1);
      GY := GY + FGridSize;
    end;
  end;
end;

procedure TNodeEditor.DrawAxes;
var
  VR: TRectF;
  SX, SY: integer;
begin
  if not FShowAxes then
    Exit;

  VR := GetVisibleWorldRect;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FAxesColor;
  Canvas.Stroke.Thickness := FAxesThickness;

  if (VR.Left <= 0) and (VR.Right >= 0) then
  begin
    SX := WorldToScreen(0, 0).X;
    Canvas.DrawLine(TPointF.Create(SX, 0), TPointF.Create(SX, Height), 1);
  end;
  if (VR.Top <= 0) and (VR.Bottom >= 0) then
  begin
    SY := WorldToScreen(0, 0).Y;
    Canvas.DrawLine(TPointF.Create(0, SY), TPointF.Create(Width, SY), 1);
  end;

  Canvas.Stroke.Thickness := 1;
end;

procedure TNodeEditor.DrawLinks(WorldRect: TRectF);
var
  i: Integer;
  Link: TNodeLink;
  W0, W1, W2, W3: TPointF;
  P0, P1, P2, P3: TPoint;
  Handled: boolean;
  IsSelected: boolean;
  IsHovered: boolean;
begin
  for i := 0 to FGraph.Links.Count - 1 do
  begin
    Link := FGraph.Links[i];
    if (Link.FromPin = nil) or (Link.ToPin = nil) then
      Continue;

    GetLinkBezierWorldPoints(Link, W0, W1, W2, W3);

    P0 := WorldToScreen(W0.X, W0.Y);
    P1 := WorldToScreen(W1.X, W1.Y);
    P2 := WorldToScreen(W2.X, W2.Y);
    P3 := WorldToScreen(W3.X, W3.Y);

    var R := TRect.Create(P0, P3);
    R.NormalizeRect;
    if not WorldRect.IntersectsWith(R) then
      Continue;

    IsSelected := FController.Selection.ContainsLink(Link);
    IsHovered := Link = FHoveredLink;

    Handled := False;
    if Assigned(FOnDrawLink) then
      FOnDrawLink(Self, Canvas, Link, P0, P1, P2, P3, IsSelected, IsHovered, Handled);

    if not Handled then
      DefaultDrawLink(Link, P0, P1, P2, P3, IsSelected, IsHovered);
    DrawCubicBezier(Canvas, P0, P1, P2, P3);
  end;
  Canvas.Stroke.Thickness := 1;
end;

procedure TNodeEditor.DrawTempLink;
var
  P0, P1, P2, P3: TPoint;
  W0, W1, W2, W3: TPointF;
  StartPin: TNodePin;
  FixedPosW: TPointF;
  DX, DY, Dist, D: Single;
begin
  if FTempFromPin = nil then
    Exit;

  Canvas.Stroke.Color := TAlphaColors.Yellow;
  Canvas.Stroke.Thickness := 3;
  Canvas.Stroke.Dash := TStrokeDash.Dot;

  StartPin := FTempFromPin;

  if FReconnectingLink and (FReconnectFixedPin <> nil) then
  begin
    FixedPosW := GetPinWorldPosition(FReconnectFixedPin);

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
    W0 := GetPinWorldPosition(FTempFromPin);
    W3 := ScreenToWorld(FTempMousePos.X, FTempMousePos.Y);
  end;

  DX := W3.X - W0.X;
  DY := W3.Y - W0.Y;
  Dist := Hypot(DX, DY);
  D := EnsureRange(Dist * 0.35, 30 / FZoom, 150 / FZoom);

  W1 := W0;
  W2 := W3;

  if (StartPin <> nil) and (StartPin.Direction = pdInput) then
  begin
    W1.X := W0.X - D;
    W2.X := W3.X + D;
  end
  else
  begin
    W1.X := W0.X + D;
    W2.X := W3.X - D;
  end;

  W1.Y := W0.Y;
  W2.Y := W3.Y;

  P0 := WorldToScreen(W0.X, W0.Y);
  P1 := WorldToScreen(W1.X, W1.Y);
  P2 := WorldToScreen(W2.X, W2.Y);
  P3 := WorldToScreen(W3.X, W3.Y);

  DrawCubicBezier(Canvas, P0, P1, P2, P3);

  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Kind := TBrushKind.Solid;
end;

procedure TNodeEditor.DrawBoxSelect;
begin
  if not FBoxSelecting then
    Exit;
  var R := Rect(FBoxStart.X, FBoxStart.Y, FBoxCurrent.X, FBoxCurrent.Y);
  R.NormalizeRect;
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := TAlphaColorF.Create(1, 1, 1, 0.05).ToAlphaColor;
  Canvas.Stroke.Color := $FFFFD740;
  Canvas.Stroke.Dash := TStrokeDash.Dash;
  Canvas.Stroke.Thickness := 1;
  Canvas.FillRect(R, 1);
  Canvas.DrawRect(R, 1);
  Canvas.Stroke.Kind := TBrushKind.Solid;
end;

procedure DrawMoveHint(Canvas: TCanvas; const Pos: TPointF; const Text: string);
var
  R: TRectF;
  TextW: Single;
  H: Single;
  Arrow: TPolygon;
begin
  Canvas.Font.Size := 12;

  TextW := Canvas.TextWidth(Text);

  H := 34;
  Pos.Offset(0, -44);
  R := RectF(
    Pos.X - TextW * 0.5 - 14,
    Pos.Y,
    Pos.X + TextW * 0.5 + 14,
    Pos.Y + H
  );

  Canvas.Fill.Kind := TBrushKind.Solid;

  { shadow }
  Canvas.Fill.Color := $20000000;
  Canvas.FillRect(
    RectF(R.Left, R.Top + 3, R.Right, R.Bottom + 3),
    10,
    10,
    AllCorners,
    1
  );

  { background }
  Canvas.Fill.Color := $EE2B2D30;
  Canvas.FillRect(R, 10, 10, AllCorners, 1);

  { border }
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Color := $30FFFFFF;

  Canvas.DrawRect(R, 10, 10, AllCorners, 1);

  { top inner highlight }
  Canvas.Stroke.Color := $18FFFFFF;

  Canvas.DrawLine(
    PointF(R.Left + 10, R.Top + 1),
    PointF(R.Right - 10, R.Top + 1),
    1
  );

  { arrow }
  SetLength(Arrow, 3);
  Arrow[0] := PointF(Pos.X - 8, R.Bottom - 1);
  Arrow[1] := PointF(Pos.X + 8, R.Bottom - 1);
  Arrow[2] := PointF(Pos.X, R.Bottom + 8);

  Canvas.Fill.Color := $EE2B2D30;
  Canvas.FillPolygon(Arrow, 1);

  Canvas.Stroke.Color := $30FFFFFF;
  Canvas.DrawPolygon(Arrow, 1);

  { text }
  Canvas.Fill.Color := $FFF2F2F2;

  Canvas.FillText(
    R,
    Text,
    False,
    1,
    [],
    TTextAlign.Center,
    TTextAlign.Center
  );
end;

procedure TNodeEditor.DrawGrip(const R: TRectF; const AOpacity: Single = 1.0);
var
  Size: Single;
  Step: Single;
  Margin: Single;
  I: Integer;
  X1, Y1: Single;
  X2, Y2: Single;
begin
  Size := Min(R.Width, R.Height);
  R.Offset(-Size, -Size);

  Margin := Size * 0.18;
  Step := Size * 0.28;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Cap := TStrokeCap.Round;
  Canvas.Stroke.Thickness := Max(1.5, Size * 0.08);

  for I := 0 to 2 do
  begin
    X1 := R.Left + Margin + I * Step;
    Y1 := R.Bottom - Margin;

    X2 := R.Right - Margin;
    Y2 := R.Top + Margin + I * Step;

    { dark shadow }
    Canvas.Stroke.Color :=
      TAlphaColorF.Create(0, 0, 0, 0.55 * AOpacity).ToAlphaColor;

    Canvas.DrawLine(
      PointF(X1 + 1, Y1 + 1),
      PointF(X2 + 1, Y2 + 1),
      1
    );

    { bright line }
    Canvas.Stroke.Color :=
      TAlphaColorF.Create(1, 1, 1, 0.85 * AOpacity).ToAlphaColor;

    Canvas.DrawLine(
      PointF(X1, Y1),
      PointF(X2, Y2),
      1
    );
  end;
end;

procedure TNodeEditor.Paint;
var
  i: Integer;
  N: TCustomNode;
  CX, CY, DX, DY: single;
  Txt: string;
  ScreenPos: TPoint;
  WorldRect: TRectF;
begin
  var TS := TStopWatch.StartNew;
  DrawGrid;
  DrawAxes;

  WorldRect := TRectF.Create(
    ScreenToWorld(FOffsetX, FOffsetY),
    TPointF.Create(Width, Height));

  EnsureSortedNodes;

  for i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if (N.VisualKind = nvComment) and not N.Selected then
    begin
      var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
      if WorldRect.IntersectsWith(R) then
        DrawSingleNode(N);
    end;
  end;
  for i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if (N.VisualKind = nvComment) and N.Selected then
    begin
      var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
      if WorldRect.IntersectsWith(R) then
        DrawSingleNode(N);
    end;
  end;

  DrawLinks(WorldRect);

  for i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if (N.VisualKind <> nvComment) and not N.Selected then
    begin
      var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
      if WorldRect.IntersectsWith(R) then
        DrawSingleNode(N);
    end;
  end;

  for i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    N := TCustomNode(FPaintNodesSorted[i]);
    if (N.VisualKind <> nvComment) and N.Selected then
    begin
      var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
      if WorldRect.IntersectsWith(R) then
        DrawSingleNode(N);
    end;
  end;

  if FDraggingNode then
    DrawSnapGuides;

  DrawTempLink;
  DrawBoxSelect;

  if FDraggingNode and FShowDragCoordinates and (GetPrimarySelectedNode <> nil)
    //and ((GetKeyState(VK_MENU) and $8000) <> 0)
  then
  begin
    CX := GetPrimarySelectedNode.X;
    CY := GetPrimarySelectedNode.Y;
    DX := CX - FDragStartWorldPos.X;
    DY := CY - FDragStartWorldPos.Y;

    Txt := Format('X: %.1f   Y: %.1f   (Δ %.1f, %.1f)',
      [CX, CY, DX, DY]);

    ScreenPos := WorldToScreen(CX, CY);
    ScreenPos.Offset(Round(GetPrimarySelectedNode.Width * Zoom / 2), 0);

    DrawMoveHint(Canvas, ScreenPos, Txt);

    Canvas.Fill.Kind := TBrushKind.Solid;
  end;

  TS.Stop;
  Canvas.Font.Size := 12;
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.FillText(TRectF.Create(20, 20, 100, 100), TS.ElapsedMilliseconds.ToString + 'ms', False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
end;

function TNodeEditor.GetResizeHandleRect(ANode: TCustomNode): TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if ANode.VisualKind = TNodeVisualKind.nvReroute then
    Exit;
  if ANode = nil then
    Exit;

  var R := ANode.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
  var S := Round(FResizeEdgeSize * FZoom);
  Result := Rect(R.Right - S, R.Bottom - S, R.Right + 1, R.Bottom + 1);
end;

function TNodeEditor.GetNodeResizeUnderMouse(SX, SY: Integer): TCustomNode;
begin
  Result := nil;

  var NodeUnderMouse := GetNodeUnderMouse(SX, SY);
  if Assigned(NodeUnderMouse) then
  begin
    if GetResizeHandleRect(NodeUnderMouse).Contains(Point(SX, SY)) then
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

  var AddRoot := TMenuItem.Create(FPopupMenu);
  AddRoot.Text := Translate('Add Node');
  FPopupMenu.AddObject(AddRoot);
  for var i := 0 to FGraph.Registry.Count - 1 do
  begin
    var RegItem := FGraph.Registry.Item(i);
    Item := TMenuItem.Create(FPopupMenu);
    Item.Text := RegItem.Caption;
    Item.Tag := i;
    Item.OnClick := OnAddRegisteredNodeClick;
    AddRoot.AddObject(Item);
  end;

  Sep := TMenuItem.Create(FPopupMenu);
  Sep.Text := '-';
  FPopupMenu.AddObject(Sep);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Copy');
  Item.ShortCut := TextToShortCut('Ctrl + C');
  Item.OnClick := OnContextCopy;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Paste');
  Item.ShortCut := TextToShortCut('Ctrl + V');
  Item.OnClick := OnContextPaste;
  FPopupMenu.AddObject(Item);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Duplicate');
  Item.ShortCut := TextToShortCut('Ctrl + D');
  Item.OnClick := OnContextDuplicate;
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

  Sep := TMenuItem.Create(FPopupMenu);
  Sep.Text := '-';
  FPopupMenu.AddObject(Sep);

  Item := TMenuItem.Create(FPopupMenu);
  Item.Text := Translate('Delete');
  Item.OnClick := OnContextDelete;
  FPopupMenu.AddObject(Item);
end;

procedure TNodeEditor.OnAddRegisteredNodeClick(Sender: TObject);
begin
  var It := FGraph.Registry.Item(TMenuItem(Sender).Tag);
  if It = nil then
    Exit;
  var N := FGraph.Registry.CreateNode(
    It.NodeType,
    SnapWorldValue(FContextWorldPos.X),
    SnapWorldValue(FContextWorldPos.Y));
  AddNode(N);
  SelectNodeInternal(N, False);
  NotifySelectionChanged;
  Repaint;
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
  var P := Screen.MousePos.Round;
  ShowNodeSearchPopup(P.X, P.Y, FContextWorldPos.X, FContextWorldPos.Y);
end;

procedure TNodeEditor.OnContextInsertReroute(Sender: TObject);
begin
  if (FController = nil) or (GetPrimarySelectedLink = nil) then
    Exit;

  FController.InsertRerouteOnLink(GetPrimarySelectedLink,
    SnapWorldValue(FContextWorldPos.X),
    SnapWorldValue(FContextWorldPos.Y));

  SyncControllerSelectionToView;

  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.OnContextAddComment(Sender: TObject);
begin
  if FController = nil then
    Exit;
  FController.AddCommentNode(
    SnapWorldValue(FContextWorldPos.X),
    SnapWorldValue(FContextWorldPos.Y));
  SyncControllerSelectionToView;
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.CopySelectionToClipboard;
begin
  if FController <> nil then
    FController.CopySelectionToClipboard;
end;

procedure TNodeEditor.PasteFromClipboard;
begin
  if FController <> nil then
  begin
    FController.PasteFromClipboard(
      SnapWorldValue(FContextWorldPos.X),
      SnapWorldValue(FContextWorldPos.Y)
    );
    SyncControllerSelectionToView;
    Repaint;
  end;
end;

procedure TNodeEditor.DuplicateSelection;
var
  W: TPointF;
begin
  if FController = nil then
    Exit;

  W := ScreenToWorld(Round(Width) div 2, Round(Height) div 2);

  FController.DuplicateSelection(
    SnapWorldValue(W.X + 25),
    SnapWorldValue(W.Y + 25)
  );

  SyncControllerSelectionToView;
  Repaint;
end;

function TNodeEditor.AddInputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if FController <> nil then
    Result := FController.AddInputPinToNode(ANode, AName, ADataType, AKind);

  if (Result <> nil) and Assigned(FOnNodeChanged) then
    FOnNodeChanged(Self, ANode);

  Repaint;
end;

function TNodeEditor.AddOutputPinToNode(ANode: TCustomNode; const AName, ADataType: string; AKind: TPinKind): TNodePin;
begin
  Result := nil;

  if FController <> nil then
    Result := FController.AddOutputPinToNode(ANode, AName, ADataType, AKind);

  if (Result <> nil) and Assigned(FOnNodeChanged) then
    FOnNodeChanged(Self, ANode);

  Repaint;
end;

function TNodeEditor.RemovePinFromNode(APin: TNodePin): boolean;
var
  N: TCustomNode;
begin
  Result := False;
  N := nil;

  if APin <> nil then
    N := TCustomNode(APin.OwnerNode);

  if FController <> nil then
    Result := FController.RemovePinFromNode(APin);

  if Result and Assigned(FOnNodeChanged) and (N <> nil) then
    FOnNodeChanged(Self, N);

  Repaint;
end;

procedure TNodeEditor.ShowNodeSearchPopup(AScreenX, AScreenY: Integer; AWorldX, AWorldY: Single);
begin
  var F := TFormNodeEditorSearch.CreateSearch(Self, FGraph.Registry);
  try
    F.Left := AScreenX;
    F.Top := AScreenY;

    if F.ShowModal = mrOk then
    begin
      if F.SelectedNodeType <> '' then
      begin
        var N := FGraph.Registry.CreateNode(F.SelectedNodeType,
          SnapWorldValue(AWorldX), SnapWorldValue(AWorldY));
        AddNode(N);
        SelectNodeInternal(N, False);
        NotifySelectionChanged;
        Repaint;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TNodeEditor.ResetStateAfterGraphReload;
var
  OldHandler: TNotifyEvent;
begin
  if FController.Selection <> nil then
    FController.Selection.Clear;
  ClearPinSelection;

  if FController <> nil then
  begin
    OldHandler := FController.Selection.OnChanged;
    FController.Selection.OnChanged := nil;
    try
      FController.Selection.Clear;
    finally
      FController.Selection.OnChanged := OldHandler;
    end;
  end;

  FHoveredNode := nil;
  FHoveredPin := nil;
  FHoveredLink := nil;

  FTempFromPin := nil;
  FDraggingLink := False;
  FDraggingNode := False;
  FShowDragCoordinates := False;
  FBoxSelecting := False;
  FResizingNode := False;
  FResizeNode := nil;

  FReconnectingLink := False;
  FReconnectLink := nil;
  FReconnectFixedPin := nil;

  FPanning := False;
  FRightMouseMoved := False;
  FRightButtonDown := False;
  ReleaseCapture;
  Cursor := crDefault;

  ClearSnapGuides;
  ClearHoverStates;
  NotifySelectionChanged;
  InvalidateSortedNodes;
  SyncNodeSelectedFlags;
end;

procedure TNodeEditor.ClearHoverStates;
var
  i: Integer;
begin
  for i := 0 to FGraph.Nodes.Count - 1 do
  begin
    FGraph.Nodes[i].Hovered := False;
    FGraph.Nodes[i].Highlighted := False;
    FGraph.Nodes[i].HoveredPinId := '';
  end;

  FHoveredNode := nil;
  FHoveredPin := nil;
  FHoveredLink := nil;
  FHoveredPinCompatible := False;
end;

procedure TNodeEditor.UpdateHoverStates(SX, SY: Integer);
var
  N: TCustomNode;
  P: TNodePin;
  L: TNodeLink;
  OldHoveredNode: TCustomNode;
  OldHoveredPin: TNodePin;
  OldHoveredLink: TNodeLink;
  NeedRepaint: boolean;
begin
  OldHoveredNode := FHoveredNode;
  OldHoveredPin := FHoveredPin;
  OldHoveredLink := FHoveredLink;

  if FHoveredNode <> nil then
  begin
    FHoveredNode.Hovered := False;
    FHoveredNode.HoveredPinId := '';
    FHoveredNode.Highlighted := False;
  end;

  FHoveredNode := nil;
  FHoveredPin := nil;
  FHoveredLink := nil;
  FHoveredPinCompatible := False;

  if GetPinUnderMouse(SX, SY, N, P) then
  begin
    FHoveredNode := N;
    FHoveredPin := P;
    N.Highlighted := True;
    N.HoveredPinId := P.Id;

    var TestPin := if FReconnectingLink then FReconnectFixedPin else FTempFromPin;
    if TestPin <> nil then
    begin
      N.Highlighted := FGraph.CanConnect(TestPin, P);
      FHoveredPinCompatible := N.Highlighted;
    end
    else
      N.Hovered := True;

    if not N.Highlighted then
      N.HoveredPinId := '';
  end
  else
  begin
    N := GetNodeUnderMouse(SX, SY);
    if N <> nil then
    begin
      if (N.VisualKind = nvComment) and GetLinkUnderMouse(SX, SY, L) then
      begin
        FHoveredLink := L;
      end
      else
      begin
        FHoveredNode := N;
        N.Hovered := True;
      end;
    end
    else if GetLinkUnderMouse(SX, SY, L) then
    begin
      FHoveredLink := L;
    end;
  end;

  NeedRepaint :=
    (OldHoveredNode <> FHoveredNode) or (OldHoveredPin <> FHoveredPin) or
    (OldHoveredLink <> FHoveredLink);

  if NeedRepaint then
    RequestRepaint;
end;

procedure TNodeEditor.FitToSelection;
var
  i: Integer;
  N: TCustomNode;
  R, NR: TRect;
  First: Boolean;
  W, H: Double;
  Margin: Integer;
begin
  if FController.Selection.NodeCount = 0 then
    Exit;

  First := True;

  for i := 0 to FController.Selection.NodeCount - 1 do
  begin
    N := FController.Selection.GetNode(i);
    NR := Rect(Round(N.X), Round(N.Y), Round(N.X + N.Width), Round(N.Y + N.Height));

    if First then
    begin
      R := NR;
      First := False;
    end
    else
      R.Union(NR);
  end;

  W := Max(1, R.Right - R.Left);
  H := Max(1, R.Bottom - R.Top);

  Margin := 60;

  FZoom := Min((Width - Margin * 2) / W, (Height - Margin * 2) / H);
  FZoom := EnsureRange(FZoom, 0.25, 3.0);

  FOffsetX := Margin - Round(R.Left * FZoom);
  FOffsetY := Margin - Round(R.Top * FZoom);

  Repaint;
end;

procedure TNodeEditor.FrameAll;
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
  FZoom := EnsureRange(FZoom, 0.25, 3.0);

  Cx := (MinX + MaxX) * 0.5;
  Cy := (MinY + MaxY) * 0.5;

  FOffsetX := Round(Width * 0.5 - Cx * FZoom);
  FOffsetY := Round(Height * 0.5 - Cy * FZoom);

  Repaint;
end;

function TNodeEditor.ValidateGraphToStrings(AStrings: TStrings): Boolean;
begin
  if FController <> nil then
    Result := FController.ValidateGraphToStrings(AStrings)
  else
    Result := False;
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

  Result := Current.ZOrder > Target.ZOrder;
end;

procedure TNodeEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
var
  Node: TCustomNode;
  Pin: TNodePin;
  Link: TNodeLink;
  X, Y: Integer;

  function ClickLink: Boolean;
  begin
    Result := False;
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
        ClearSelectionInternal;
        if FController.Selection <> nil then
          FController.Selection.SelectLink(Link, False);
        if FController <> nil then
          FController.Selection.SelectLink(Link, False);
      end;
      FDraggingNode := False;

      FReconnectingLink := True;
      FReconnectLink := Link;
      FReconnectMovingFromSide := IsMouseNearLinkStart(Link, X, Y);

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

      FTempMousePos := Point(X, Y);
      FTempStartMousePos := Point(X, Y);
      FDraggingLink := False;

      NotifySelectionChanged;
      Repaint;
      Exit(True);
    end;
  end;

begin
  inherited MouseDown(Button, Shift, AX, AY);
  X := Round(AX);
  Y := Round(AY);
  SetFocus;
  if Button = TMouseButton.mbLeft then
  begin
    ClearSnapGuides;
    Node := GetNodeResizeUnderMouse(X, Y);
    if Node <> nil then
    begin
      if not FController.Selection.ContainsNode(Node) then
      begin
        SelectNodeInternal(Node, False);
        NotifySelectionChanged;
      end;

      FResizingNode := True;
      FResizeNode := Node;
      FResizeStartMouseX := X;
      FResizeStartMouseY := Y;
      FResizeStartWidth := Node.Width;
      FResizeStartHeight := Node.Height;
      FResizeStartX := Node.X;
      FResizeStartY := Node.Y;
      FResizeOldWidth := Node.Width;
      FResizeOldHeight := Node.Height;
      FDragUndoPushed := False;
      Repaint;
      Exit;
    end;

    var ZNode := GetNodeUnderMouse(X, Y);

    if GetPinUnderMouse(X, Y, Node, Pin) then
      if NodeIsAbove(Node, ZNode) then
      begin
        if Assigned(FOnPinClick) then
          FOnPinClick(Self, Pin);

        if ssCtrl in Shift then
        begin
          TogglePinSelection(Pin);
          NotifySelectionChanged;
          Repaint;
          Exit;
        end
        else if ssShift in Shift then
        begin
          SelectPinInternal(Pin, True);
          NotifySelectionChanged;
          Repaint;
          Exit;
        end;

        ClearPinSelection;
        FTempFromPin := Pin;
        FTempMousePos := Point(X, Y);
        FTempStartMousePos := Point(X, Y);
        FDraggingLink := False;
        Repaint;
        Exit;
      end;

    Node := ZNode;
    if Node <> nil then
    begin
      if Node.VisualKind = nvComment then
      begin
        if ClickLink then
          Exit;
      end;

      if (ssCtrl in Shift) or (ssShift in Shift) then
      begin
        ToggleNodeSelection(Node);
      end
      else
      begin
        if not FController.Selection.ContainsNode(Node) then
          SelectNodeInternal(Node, False);
      end;
      FDraggingNode := True;
      FDragUndoPushed := False;
      FDragStartX := X;
      FDragStartY := Y;
      FDragAnchorX := X;
      FDragAnchorY := Y;

      FShowDragCoordinates := True;

      if GetPrimarySelectedNode <> nil then
        FDragStartWorldPos := PointF(GetPrimarySelectedNode.X, GetPrimarySelectedNode.Y)
      else if FController.Selection.NodeCount > 0 then
        FDragStartWorldPos := PointF(FController.Selection.GetNode(0).X,
          FController.Selection.GetNode(0).Y);

      FDragCommandNodes.Clear;
      SetLength(FDragOldPositions, FController.Selection.NodeCount);

      for var i := 0 to FController.Selection.NodeCount - 1 do
      begin
        FDragCommandNodes.Add(FController.Selection.GetNode(i));
        FDragOldPositions[i] := PointF(FController.Selection.GetNode(i).X, FController.Selection.GetNode(i).Y);
      end;

      NotifySelectionChanged;
      Repaint;
      Exit;
    end;

    if ClickLink then
      Exit;

    if not (ssShift in Shift) then
      ClearSelectionInternal;
    FBoxSelecting := True;
    FBoxStart := Point(X, Y);
    FBoxCurrent := Point(X, Y);
    FBoxStartWorld := ScreenToWorld(X, Y);
    FBoxCurrentWorld := FBoxStartWorld;
    NotifySelectionChanged;
    Repaint;
  end
  else if Button = TMouseButton.mbMiddle then
  begin
    FPanning := True;
    FRightMouseMoved := False;
    FPanStartX := X;
    FPanStartY := Y;
  end;
end;

procedure TNodeEditor.MouseMove(Shift: TShiftState; AX, AY: Single);
var
  Dx, Dy: Single;
  X, Y: Integer;
  BaseX, BaseY: single;
  SnappedX, SnappedY: boolean;
  RawDx, RawDy: single;
  ResizeNode: TCustomNode;
begin
  inherited MouseMove(Shift, AX, AY);

  X := Round(AX);
  Y := Round(AY);
  FLastMousePos := Point(X, Y);
  if (not FResizingNode) and (not FPanning) then
    UpdateHoverStates(X, Y);

  if (not FPanning) and (not FDraggingNode) and (not FBoxSelecting) and
    (not FResizingNode) and (FTempFromPin = nil) then
  begin
    ResizeNode := GetNodeResizeUnderMouse(X, Y);
    if ResizeNode <> nil then
      Cursor := crSizeNWSE
    else
      Cursor := crDefault;

    if (X <> FLastHoverMouseX) or (Y <> FLastHoverMouseY) then
    begin
      FLastHoverMouseX := X;
      FLastHoverMouseY := Y;
      UpdateHoverStates(X, Y);
    end;
  end;

  if FPanning then
  begin
    if (Abs(X - FPanStartX) > 2) or (Abs(Y - FPanStartY) > 2) then
      FRightMouseMoved := True;
    FOffsetX := FOffsetX + (X - FPanStartX);
    FOffsetY := FOffsetY + (Y - FPanStartY);
    FPanStartX := X;
    FPanStartY := Y;
    RequestRepaint;
  end
  else if FResizingNode and (FResizeNode <> nil) then
  begin                                   //40, 28
    FResizeNode.Width := Max(FResizeNode.MinWidth, FResizeStartWidth + Round((X - FResizeStartMouseX) / FZoom));
    FResizeNode.Height := Max(FResizeNode.MinHeight, FResizeStartHeight + Round((Y - FResizeStartMouseY) / FZoom));

    if FResizeNode.VisualKind = nvReroute then
    begin
      FResizeNode.Width := Max(12, FResizeNode.Width);
      FResizeNode.Height := FResizeNode.Width;
    end;

    RequestRepaint;
  end
  else if FDraggingNode and (FController.Selection.NodeCount > 0) then
  begin
    RawDx := (X - FDragAnchorX) / FZoom;
    RawDy := (Y - FDragAnchorY) / FZoom;

    Dx := RawDx;
    Dy := RawDy;
    SnappedX := False;
    SnappedY := False;

    ApplyNodeSnap(Dx, Dy, SnappedX, SnappedY);

    if FSnapToGrid and not (ssAlt in Shift) and (FDragCommandNodes.Count > 0) then
    begin
      BaseX := FDragOldPositions[0].X;
      BaseY := FDragOldPositions[0].Y;

      if not SnappedX then
        Dx := SnapWorldValue(BaseX + RawDx) - BaseX;

      if not SnappedY then
        Dy := SnapWorldValue(BaseY + RawDy) - BaseY;
    end
    else if not FSnapToNodes then
      ClearSnapGuides;

    for var i := 0 to FDragCommandNodes.Count - 1 do
    begin
      var N := TCustomNode(FDragCommandNodes[i]);
      BaseX := FDragOldPositions[i].X;
      BaseY := FDragOldPositions[i].Y;

      N.X := BaseX + Dx;
      N.Y := BaseY + Dy;
    end;

    RequestRepaint;
  end
  else if FTempFromPin <> nil then
  begin
    FTempMousePos := Point(X, Y);

    if (Abs(X - FTempStartMousePos.X) > 4) or (Abs(Y - FTempStartMousePos.Y) > 4) then
      FDraggingLink := True;

    RequestRepaint;
  end
  else if FBoxSelecting then
  begin
    FBoxCurrent := Point(X, Y);
    FBoxCurrentWorld := ScreenToWorld(X, Y);

    RequestRepaint;
  end;
  Repaint;
end;

procedure TNodeEditor.CancelMouseOperations(const KeepSelectionRect: boolean);
begin
  FPanning := False;
  FRightButtonDown := False;
  FRightMouseMoved := False;

  FDraggingNode := False;
  FDragUndoPushed := False;
  FDragCommandNodes.Clear;
  SetLength(FDragOldPositions, 0);

  FTempFromPin := nil;
  FDraggingLink := False;
  FReconnectingLink := False;
  FReconnectLink := nil;
  FReconnectFixedPin := nil;
  FReconnectMovingFromSide := False;

  FResizingNode := False;
  FResizeNode := nil;

  if not KeepSelectionRect then
    FBoxSelecting := False;

  ClearSnapGuides;
  ClearHoverStates;
  ReleaseCapture;
  Cursor := crDefault;
  Repaint;
end;

procedure TNodeEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
var
  TargetNode: TCustomNode;
  TargetPin: TNodePin;
  R: TRectF;
  i: Integer;
  N: TCustomNode;
  NewPositions: array of TPointF;
  Moved: Boolean;
  K: Integer;
  DN: TCustomNode;
  X, Y: Integer;
  AllowConnect: boolean;
begin
  inherited MouseUp(Button, Shift, AX, AY);
  X := Round(AX);
  Y := Round(AY);

  if Button = TMouseButton.mbLeft then
  begin
    if FResizingNode then
    begin
      if (FResizeNode <> nil) and ((FResizeNode.Width <> FResizeOldWidth) or
        (FResizeNode.Height <> FResizeOldHeight)) then
      begin
        K := FResizeNode.Width;
        i := FResizeNode.Height;

        FResizeNode.Width := FResizeOldWidth;
        FResizeNode.Height := FResizeOldHeight;

        FGraph.ExecuteCommand(TResizeNodeCommand.Create(FGraph,
            FResizeNode, FResizeOldWidth, FResizeOldHeight, K, i));

        if Assigned(FOnNodeChanged) then
          FOnNodeChanged(Self, FResizeNode);
      end;

      FResizingNode := False;
      FResizeNode := nil;
      FDragUndoPushed := False;
      ClearSnapGuides;
      Repaint;
      Exit;
    end;

    if FTempFromPin <> nil then
    begin
      if FReconnectingLink then
      begin
        if GetPinUnderMouse(X, Y, TargetNode, TargetPin) and
          (TargetPin <> nil) and (FReconnectFixedPin <> nil) then
        begin
          AllowConnect := True;
          if Assigned(FOnBeforeConnectPins) then
            FOnBeforeConnectPins(Self, TargetPin, FReconnectFixedPin, AllowConnect);

          if AllowConnect then
          begin
            if FReconnectMovingFromSide then
            begin
              if FGraph.CanConnect(TargetPin, FReconnectFixedPin) then
              begin
                FGraph.RemoveLink(FReconnectLink);
                FGraph.AddLink(TNodeLink.Create(TargetPin, FReconnectFixedPin));
                if Assigned(FOnAfterConnectPins) then
                  FOnAfterConnectPins(Self, TargetPin, FReconnectFixedPin);
              end;
            end
            else
            begin
              if FGraph.CanConnect(FReconnectFixedPin, TargetPin) then
              begin
                FGraph.RemoveLink(FReconnectLink);
                FGraph.AddLink(TNodeLink.Create(FReconnectFixedPin, TargetPin));
                if Assigned(FOnAfterConnectPins) then
                  FOnAfterConnectPins(Self, FReconnectFixedPin, TargetPin);
              end;
            end;
          end;
        end;

        FTempFromPin := nil;
        FDraggingLink := False;
        FReconnectingLink := False;
        FReconnectLink := nil;
        FReconnectFixedPin := nil;
        ClearSnapGuides;

        Repaint;
        Exit;
      end;

      if GetPinUnderMouse(X, Y, TargetNode, TargetPin) and
        FGraph.CanConnect(FTempFromPin, TargetPin) then
      begin

        AllowConnect := True;
        if Assigned(FOnBeforeConnectPins) then
          FOnBeforeConnectPins(Self, FTempFromPin, TargetPin, AllowConnect);

        if AllowConnect then
        begin
          if FTempFromPin.Direction = pdOutput then
          begin
            if not FGraph.LinkExists(FTempFromPin, TargetPin) then
              FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph,
                  FTempFromPin, TargetPin));
          end
          else
          begin
            if not FGraph.LinkExists(TargetPin, FTempFromPin) then
              FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph,
                  TargetPin, FTempFromPin));
          end;
          if Assigned(FOnAfterConnectPins) then
            FOnAfterConnectPins(Self, FTempFromPin, TargetPin);
        end;
      end
      else if FDraggingLink then
      begin
        if FController <> nil then
          TargetNode := FController.CreateCompatibleNodeForPin(FTempFromPin,
            SnapWorldValue(ScreenToWorld(X, Y).X),
            SnapWorldValue(ScreenToWorld(X, Y).Y))
        else
          TargetNode := nil;

        if TargetNode <> nil then
        begin
          FGraph.ExecuteCommand(TAddNodeCommand.Create(FGraph, TargetNode));

          if FTempFromPin.Direction = pdOutput then
          begin
            for i := 0 to TargetNode.InputCount - 1 do
            begin
              TargetPin := TargetNode.GetInput(i);
              if FGraph.CanConnect(FTempFromPin, TargetPin) then
              begin
                AllowConnect := True;
                if Assigned(FOnBeforeConnectPins) then
                  FOnBeforeConnectPins(Self, FTempFromPin, TargetPin, AllowConnect);
                if AllowConnect then
                begin
                  FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, FTempFromPin, TargetPin));
                  if Assigned(FOnAfterConnectPins) then
                    FOnAfterConnectPins(Self, FTempFromPin, TargetPin);
                end;
                Break;
              end;
            end;
          end
          else
          begin
            for i := 0 to TargetNode.OutputCount - 1 do
            begin
              TargetPin := TargetNode.GetOutput(i);
              if FGraph.CanConnect(TargetPin, FTempFromPin) then
              begin
                AllowConnect := True;
                if Assigned(FOnBeforeConnectPins) then
                  FOnBeforeConnectPins(Self, TargetPin, FTempFromPin, AllowConnect);
                if AllowConnect then
                begin
                  FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, TargetPin, FTempFromPin));
                  if Assigned(FOnAfterConnectPins) then
                    FOnAfterConnectPins(Self, TargetPin, FTempFromPin);
                end;
                Break;
              end;
            end;
          end;

          SelectNodeInternal(TargetNode, False);
          NotifySelectionChanged;
        end
        else
        begin
          var MPos := Screen.MousePos.Round;
          ShowNodeSearchPopup(MPos.X, MPos.Y,
            ScreenToWorld(X, Y).X, ScreenToWorld(X, Y).Y);
        end;
      end;

      FTempFromPin := nil;
      FDraggingLink := False;
      FReconnectingLink := False;
      FReconnectLink := nil;
      FReconnectFixedPin := nil;
      FReconnectMovingFromSide := False;
      ClearSnapGuides;
      Repaint;
      Exit;
    end;

    if FDraggingNode and (FDragCommandNodes.Count > 0) then
    begin
      SetLength(NewPositions, FDragCommandNodes.Count);
      Moved := False;

      for K := 0 to FDragCommandNodes.Count - 1 do
      begin
        DN := FDragCommandNodes[K];
        NewPositions[K] := PointF(DN.X, DN.Y);

        if (Abs(NewPositions[K].X - FDragOldPositions[K].X) > 0.01) or
          (Abs(NewPositions[K].Y - FDragOldPositions[K].Y) > 0.01) then
          Moved := True;
      end;

      if Moved then
      begin
        for K := 0 to FDragCommandNodes.Count - 1 do
        begin
          DN := FDragCommandNodes[K];
          DN.X := FDragOldPositions[K].X;
          DN.Y := FDragOldPositions[K].Y;
        end;

        FGraph.ExecuteCommand(
          TMoveNodesCommand.Create(FGraph, FDragCommandNodes, FDragOldPositions, NewPositions));

        for K := 0 to FDragCommandNodes.Count - 1 do
        begin
          DN := FDragCommandNodes[K];
          if Assigned(FOnNodeChanged) then
            FOnNodeChanged(Self, DN);
        end;
      end;
    end;

    FDraggingNode := False;
    FDragUndoPushed := False;
    FShowDragCoordinates := False;
    FDragCommandNodes.Clear;
    SetLength(FDragOldPositions, 0);

    if FBoxSelecting then
    begin
      R := RectF(FBoxStartWorld.X, FBoxStartWorld.Y, FBoxCurrentWorld.X, FBoxCurrentWorld.Y);
      R.NormalizeRect;
      if not (ssCtrl in Shift) and not (ssShift in Shift) then
        ClearSelectionInternal;

      if ssShift in Shift then
      begin
        // Shift + box: only nodes
        for i := 0 to FGraph.Nodes.Count - 1 do
        begin
          N := TCustomNode(FGraph.Nodes[i]);
          if RectFIntersects(R, RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height)) then
            AddNodeToSelection(N);
        end;
      end
      else if ssCtrl in Shift then
      begin
        // Ctrl + box: only links
        for i := 0 to FGraph.Links.Count - 1 do
        begin
          var L := TNodeLink(FGraph.Links[i]);
          if IsLinkInsideWorldRect(L, R) then
            AddLinkToSelection(L);
        end;
      end
      else
      begin
        for i := 0 to FGraph.Nodes.Count - 1 do
        begin
          N := TCustomNode(FGraph.Nodes[i]);
          if RectFIntersects(R, RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height)) then
            AddNodeToSelection(N);
        end;

        for i := 0 to FGraph.Links.Count - 1 do
        begin
          var L := TNodeLink(FGraph.Links[i]);
          if IsLinkInsideWorldRect(L, R) then
            AddLinkToSelection(L);
        end;
      end;
      FBoxSelecting := False;
      NotifySelectionChanged;
    end;

    ClearSnapGuides;
    Repaint;
  end
  else if Button = TMouseButton.mbMiddle then
  begin
    FPanning := False;
  end
  else if Button = TMouseButton.mbRight then
  begin
    if (FTempFromPin <> nil) or FReconnectingLink then
    begin
      CancelMouseOperations(True);
      Exit;
    end;
    CancelMouseOperations(True);
    FContextWorldPos := ScreenToWorld(X, Y);
    var MPos := Screen.MousePos.Round;
    FPopupMenu.PopupComponent := Self;
    FPopupMenu.Popup(MPos.X, MPos.Y);
  end;
end;

procedure TNodeEditor.UpdatedStatus;
begin
  if Assigned(FOnUpdatedStatus) then
    FOnUpdatedStatus(Self);
end;

procedure TNodeEditor.SetGridSize(const Value: Integer);
begin
  FGridSize := Value;
  Repaint;
end;

procedure TNodeEditor.SetGridType(const Value: TGridType);
begin
  FGridType := Value;
end;

procedure TNodeEditor.SetOnUpdatedStatus(const Value: TNotifyEvent);
begin
  FOnUpdatedStatus := Value;
end;

procedure TNodeEditor.SetZoom(Value: Double; TargetPos: TPoint);
begin
  var OldZoom := FZoom;
  FZoom := EnsureRange(Value, 0.25, 3.0);
  FOffsetX := TargetPos.X - Round((TargetPos.X - FOffsetX) * (FZoom / OldZoom));
  FOffsetY := TargetPos.Y - Round((TargetPos.Y - FOffsetY) * (FZoom / OldZoom));
  UpdatedStatus;
  Repaint;
end;

procedure TNodeEditor.SetZoom(Value: Double);
begin
  SetZoom(Value, FLastMousePos);
end;

procedure TNodeEditor.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  inherited MouseWheel(Shift, WheelDelta, Handled);
  Handled := True;
  var NewZoom: Double;
  if WheelDelta > 0 then
    NewZoom := FZoom * 1.15
  else
    NewZoom := FZoom / 1.15;
  SetZoom(NewZoom, FLastMousePos);
end;

procedure TNodeEditor.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited KeyUp(Key, KeyChar, Shift);
  if (Key = vkDelete) then
  begin
    DeleteSelection;
    Key := 0;
    Exit;
  end;
  if (Key = vkZ) and (Shift = [ssCtrl]) then
  begin
    Undo;
    Key := 0;
    Exit;
  end;
  if ((Key = vkY) and (ssCtrl in Shift)) or ((Key = vkZ) and (Shift = [ssCtrl, ssShift])) then
  begin
    Redo;
    Key := 0;
    Exit;
  end;
  if (Key = vkC) and (ssCtrl in Shift) then
  begin
    CopySelectionToClipboard;
    Key := 0;
    Exit;
  end;
  if (Key = vkV) and (ssCtrl in Shift) then
  begin
    FContextWorldPos := ScreenToWorld(Round(Width) div 2, Round(Height) div 2);
    PasteFromClipboard;
    Key := 0;
    Exit;
  end;
  if (Key = vkD) and (ssCtrl in Shift) then
  begin
    DuplicateSelection;
    Key := 0;
    Exit;
  end;
  if (Key = vkF) then
  begin
    if FController.Selection.NodeCount > 0 then
      FitToSelection
    else
      FrameAll;

    Key := 0;
    Exit;
  end;
  if (Key = vkL) and (ssCtrl in Shift) then
  begin
    ConnectSelectedPins;
    Key := 0;
    Exit;
  end;
  //
  if (Key = vkA) and (ssCtrl in Shift) and (ssShift in Shift) then
  begin
    // Ctrl + Shift + A -> only nodes
    ClearSelectionInternal;

    for var i := 0 to FGraph.Nodes.Count - 1 do
      AddNodeToSelection(TCustomNode(FGraph.Nodes[i]));

    NotifySelectionChanged;
    Repaint;
    Key := 0;
    Exit;
  end;

  if (Key = vkA) and (ssCtrl in Shift) then
  begin
    // Ctrl + A -> nodes + links
    ClearSelectionInternal;

    for var i := 0 to FGraph.Nodes.Count - 1 do
      AddNodeToSelection(TCustomNode(FGraph.Nodes[i]));

    for var i := 0 to FGraph.Links.Count - 1 do
      AddLinkToSelection(TNodeLink(FGraph.Links[i]));

    NotifySelectionChanged;
    Repaint;
    Key := 0;
    Exit;
  end;

  if (Key = vkA) and (ssShift in Shift) then
  begin
    // Shift + A -> only links
    ClearSelectionInternal;

    for var i := 0 to FGraph.Links.Count - 1 do
      AddLinkToSelection(TNodeLink(FGraph.Links[i]));

    NotifySelectionChanged;
    Repaint;
    Key := 0;
    Exit;
  end;

  if Key = vkEscape then
  begin
    if FTempFromPin <> nil then
    begin
      CancelMouseOperations(False);
      Key := 0;
      Exit;
    end;

    if FDraggingNode or FBoxSelecting or FResizingNode or FPanning or FReconnectingLink then
    begin
      CancelMouseOperations(False);
      Key := 0;
      Exit;
    end;

    ClearSelection;
    Key := 0;
    Exit;
  end;
end;

end.

