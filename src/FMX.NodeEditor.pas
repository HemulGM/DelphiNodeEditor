unit FMX.NodeEditor;

interface

uses
  System.Classes, System.SysUtils, FMX.Graphics, FMX.Controls, System.Math,
  System.Types, FMX.Menus, FMX.Clipboard, System.JSON, System.Diagnostics,
  FMX.Forms, FMX.Dialogs, System.UITypes, FMX.Types, FMX.Objects,
  System.Generics.Collections, FMX.NodeEditor.Node, FMX.NodeEditor.Node.Defaults,
  FMX.NodeEditor.Node.Graph, FMX.NodeEditor.Types, FMX.NodeEditor.Controller;

{$SCOPEDENUMS ON}

type
  TNodeSelectionChangedEvent = procedure(Sender: TObject) of object;

  TNodeChangedEvent = procedure(Sender: TObject; ANode: TCustomNode) of object;

  { Custom Draw Events }

  TNodeEditorDrawNodeEvent = procedure(Sender: TObject; Canvas: TCanvas; ANode: TCustomNode; const ARect: TRectF; Zoom: Double; OffsetX, OffsetY: Double; var AHandled: Boolean) of object;

  TNodeEditorDrawPinEvent = procedure(Sender: TObject; Canvas: TCanvas; APin: TNodePin; const ACenter: TPoint; ARadius: Integer; ASelected, AHovered, AHighlighted: Boolean; var AHandled: Boolean) of object;

  TNodeEditorDrawLinkEvent = procedure(Sender: TObject; Canvas: TCanvas; ALink: TNodeLink; ASelected, AHovered: Boolean; var AHandled: Boolean) of object;

  TNodeEditorDrawGridEvent = procedure(Sender: TObject; Canvas: TCanvas; const VisibleWorldRect: TRectF; Zoom, OffsetX, OffsetY: Double; var AHandled: Boolean) of object;

  TNodeEditorDrawSnapGuidesEvent = procedure(Sender: TObject; Canvas: TCanvas; GuideSnapXActive, GuideSnapYActive: Boolean; GuideSnapX, GuideSnapY: single; Zoom, OffsetX, OffsetY: Double; var AHandled: boolean) of object;

  { Interaction Events }

  TNodePinEvent = procedure(Sender: TObject; APin: TNodePin) of object;

  TNodeLinkEvent = procedure(Sender: TObject; ALink: TNodeLink) of object;

  TEditorConnectPinsEvent = procedure(Sender: TObject; AFromPin, AToPin: TNodePin; var AAllow: Boolean) of object;

  TEditorPinsConnectedEvent = procedure(Sender: TObject; AFromPin, AToPin: TNodePin) of object;

  TNodeEditor = class(TControl)
    const
      ZoomMin = 0.25;
      ZoomMax = 6.00;
  private
    FGraph: TNodeGraph;
    FController: TNodeEditorController;
    FOnNodeChanged: TNodeChangedEvent;
    FOnSelectionChanged: TNodeSelectionChangedEvent;

    FZoom: Double;
    FOffsetX, FOffsetY: Double;
    FScreenRect: TRectF;

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
    FRightButtonDown: Boolean;

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
    FGridType: TGridType;
    FGridColor: TAlphaColor;
    FZoomStep: Double;
    FSnapToNodes: boolean;
    FNodeSnapDistance: single;

    FShowSnapGuides: boolean;
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
    FPaintNodesDirty: Boolean;
    FLastHoverMouseX: integer;
    FLastHoverMouseY: integer;
    FLastMouseMoveTick: UInt64;
    FLastPaintTick: UInt64;
    FFrameTimeWatch: TStopWatch;

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
    FPinCompatibleColor: TAlphaColor;
    FPinIncompatibleColor: TAlphaColor;

    // Custom Draw Events
    FOnDrawNode: TNodeEditorDrawNodeEvent;
    FOnDrawPin: TNodeEditorDrawPinEvent;
    FOnDrawLink: TNodeEditorDrawLinkEvent;
    FOnDrawGrid: TNodeEditorDrawGridEvent;
    FOnDrawSnapGuides: TNodeEditorDrawSnapGuidesEvent;

    // Interaction Events
    FOnUpdatedStatus: TNotifyEvent;
    FOnPinSelectionChanged: TNotifyEvent;
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

    // Internal Logic
    procedure ClearPinSelection;
    procedure SelectPinInternal(APin: TNodePin; AAppend: Boolean);
    procedure TogglePinSelection(APin: TNodePin);
    procedure ConnectSelectedPins;
    procedure DoPinSelectionChanged(Sender: TObject);
    function GetPrimarySelectedNode: TCustomNode;
    function GetPrimarySelectedLink: TNodeLink;

    // Render Helpers
    procedure DrawNode(ANode: TCustomNode; const NodeBounds: TRectF);

    procedure NotifySelectionChanged;
    procedure ControllerSelectionChanged(Sender: TObject);
    procedure SyncControllerSelectionToView;

    // Geometry
    function GetNodeResizeUnderMouse(SX, SY: Integer): TCustomNode;
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
    procedure ShowNodeSearchPopup(AScreenX, AScreenY: Integer; const WorldPosition: TPointF);
    procedure ResetStateAfterGraphReload;
    procedure ClearHoverStates;
    procedure UpdateHoverStates(SX, SY: Integer; HitLinks: Boolean = True);
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
    procedure InternalMouseDown(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
    procedure InternalMouseMove(Shift: TShiftState; AX, AY: Single);
    procedure InternalMouseUp(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
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
  protected
    function SelectedPinCount: integer;
    function GetSelectedPin(Index: integer): TNodePin;
    function CanConnectSelectedPins: boolean;

    function IsNodeInDragSelection(ANode: TCustomNode): Boolean;
    function GetDraggedSelectionBoundsAtOffset(const AOffsetX, AOffsetY: Single): TRectF;
    procedure ApplyNodeSnap(var AOffsetX, AOffsetY: Single; out ASnappedX, ASnappedY: Boolean);

    procedure InvalidateSortedNodes;
    procedure EnsureSortedNodes;
    procedure NodeGraphChanged(Sender: TObject);
    function CanPinAcceptMoreConnections(APin: TNodePin): Boolean;

    // Hit Testing
    function WorldToScreen(WX, WY: Single): TPoint;
    function ScreenToWorld(const Value: TPointF): TPointF; overload;
    function ScreenToWorld(SX, SY: Double): TPointF; overload;
    function ScreenToWorld(SX, SY: Double; AZoom: Double): TPointF; overload;
    function SnapWorldValue(Value: Single): Single; overload;
    function SnapWorldPoint(const P: TPointF): TPointF; overload;

    function GetNodeUnderMouse(SX, SY: Integer): TCustomNode;
    function GetPinUnderMouse(SX, SY: Integer; out Node: TCustomNode; out Pin: TNodePin): Boolean;
    function GetLinkUnderMouse(SX, SY: Integer; out Link: TNodeLink): Boolean;

    // Selection Logic
    procedure ClearSelectionInternal;
    procedure SelectNodeInternal(ANode: TCustomNode; AAppend: Boolean);
    procedure SelectLinkInternal(ALink: TNodeLink; AKeepNodes: Boolean = False);
    procedure ToggleNodeSelection(ANode: TCustomNode);
    procedure RemoveNodeFromSelection(ANode: TCustomNode);
    procedure ToggleLinkSelection(ALink: TNodeLink);
    procedure SyncNodeSelectedFlags;
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

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddNode(ANode: TCustomNode);
    procedure RemoveNode(ANode: TCustomNode);
    procedure RemoveLink(ALink: TNodeLink);
    procedure Clear;

    procedure ClearSelection;
    procedure DeleteSelection;
    procedure SelectAll;
    function SelectedNodeCount: Integer;
    function SelectedLinkCount: Integer;
    function GetSelectedNode(Index: Integer): TCustomNode;
    procedure SelectNode(ANode: TCustomNode; AAppend: Boolean);
    procedure ExecuteNodePropertyChange(ANode: TCustomNode; const AOldJSON, ANewJSON: string);
    procedure SelectLink(ALink: TNodeLink);
    procedure RenderNavigator(Bitmap: TBitmap);

    procedure FitToSelection;
    procedure FrameAll;
    procedure ResetView;
    procedure SetZoom(Value: Double; const TargetPos: TPoint); overload;

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
    property GuideLineColor: TAlphaColor read FGuideLineColor write FGuideLineColor default $FFFFD740;
    property GuideLineStyle: TStrokeDash read FGuideLineStyle write FGuideLineStyle default TStrokeDash.Dash;
    property GuideLineWidth: Single read FGuideLineWidth write FGuideLineWidth;
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
    property AxesColor: TAlphaColor read FAxesColor write FAxesColor default $50FFFFFF;
    property AxesThickness: integer read FAxesThickness write FAxesThickness default 2;
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
    property ZoomStep: Double read FZoomStep write SetZoomStep;
    property GridType: TGridType read FGridType write SetGridType;
    property GridColor: TAlphaColor read FGridColor write SetGridColor default $22E0E0E0;
    property LinkVisualType: TLinkVisualType read FLinkVisualType write SetLinkVisualType default TLinkVisualType.Bezier;
    property LinkGradient: Boolean read FLinkGradient write SetLinkGradient;

    // Events
    property OnSelectionChanged: TNodeSelectionChangedEvent read FOnSelectionChanged write FOnSelectionChanged;
    property OnNodeChanged: TNodeChangedEvent read FOnNodeChanged write FOnNodeChanged;
    property OnUpdatedStatus: TNotifyEvent read FOnUpdatedStatus write SetOnUpdatedStatus;
    property OnDrawNode: TNodeEditorDrawNodeEvent read FOnDrawNode write FOnDrawNode;
    property OnDrawPin: TNodeEditorDrawPinEvent read FOnDrawPin write FOnDrawPin;
    property OnDrawLink: TNodeEditorDrawLinkEvent read FOnDrawLink write FOnDrawLink;
    property OnDrawGrid: TNodeEditorDrawGridEvent read FOnDrawGrid write FOnDrawGrid;
    property OnDrawSnapGuides: TNodeEditorDrawSnapGuidesEvent read FOnDrawSnapGuides write FOnDrawSnapGuides;
    property OnPinSelectionChanged: TNotifyEvent read FOnPinSelectionChanged write FOnPinSelectionChanged;
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
  System.IOUtils, FMX.ListBox, FMX.NodeEditor.Form.Search, FMX.Types3D,
  FMX.NodeEditor.Node.Command, System.Generics.Defaults, FMX.Platform,
  System.Math.Vectors;

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
  CanFocus := True;
  TabStop := True;
  Touch.InteractiveGestures := [
      TInteractiveGesture.Zoom,
      TInteractiveGesture.Pan,
      TInteractiveGesture.LongTap,
      TInteractiveGesture.DoubleTap];
  OnGesture := FOnGesture;

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

  FLinkVisualType := TLinkVisualType.Bezier;
  TNodeLink.VisualType := TLinkVisualType.Bezier;
  FLinkGradient := True;
  TNodeLink.UseGradient := True;

  FZoom := 1.0;
  FZoomStep := 1.15;
  FSnapToGrid := False;
  FGridSize := 40;
  FGridColor := $22E0E0E0;
  FSnapToNodes := True;
  FNodeSnapDistance := 10.0;
  FOffsetX := 0;
  FOffsetY := 0;

  FShowGrid := True;
  FShowSnapGuides := True;
  FGuideSnapXActive := False;
  FGuideSnapYActive := False;
  FGuideSnapX := 0;
  FGuideSnapY := 0;
  FGuideLineColor := $FFFFD740;
  FGuideLineStyle := TStrokeDash.Dash;
  FGuideLineWidth := 1;

  // Axes defaults
  FShowAxes := False;
  FAxesColor := $50FFFFFF;
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

procedure TNodeEditor.FOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if Data.Source is TListBoxItem then
    Operation := TDragOperation.Link
  else
    Operation := TDragOperation.None;
end;

procedure TNodeEditor.FOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
begin
  if Data.Source is TListBoxItem then
  begin
    var NodeType := TListBoxItem(Data.Source).TagString;

    var SPoint := ScreenToWorld(Point.X, Point.Y);
    var N := FGraph.Registry.CreateNode(NodeType, SnapWorldPoint(SPoint));
    AddNode(N);
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

  if FGraph = nil then
    Exit;

  for var i := 0 to FGraph.Nodes.Count - 1 do
    FPaintNodesSorted.Add(FGraph.Nodes[i]);

  FPaintNodesSorted.Sort(TComparer<TCustomNode>.Construct(NodePaintCompare));
  FPaintNodesDirty := False;
end;

procedure TNodeEditor.NodeGraphChanged(Sender: TObject);
begin
  UpdatePinsConnectedState;
  InvalidateSortedNodes;
  Repaint;
end;

function TNodeEditor.CanPinAcceptMoreConnections(APin: TNodePin): boolean;
begin
  Result := (APin <> nil) and ((not APin.Connected) or APin.AllowMultipleConnections);
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
  N: TCustomNode;
  BestGuideX, BestGuideY: single;
begin
  ClearSnapGuides;
  ASnappedX := False;
  ASnappedY := False;

  if not FSnapToNodes then
    Exit;
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

  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    N := FGraph.Nodes[i];
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
  //Canvas.Stroke.SetCustomDash([9], 9);
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

    var SX := Round(FGuideSnapX * FZoom + FOffsetX);
    Canvas.DrawLine(PointF(SX, 0), PointF(SX, Height), 1);
  end;

  if FGuideSnapYActive then
  begin
    Canvas.Stroke.Gradient.StartPosition.Point := PointF(0, 0.5);
    Canvas.Stroke.Gradient.StopPosition.Point := PointF(1, 0.5);

    var SY := Round(FGuideSnapY * FZoom + FOffsetY);
    Canvas.DrawLine(PointF(0, SY), PointF(Width, SY), 1);
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

procedure TNodeEditor.AddNode(ANode: TCustomNode);
begin
  FController.AddNode(ANode);
  Repaint;
end;

procedure TNodeEditor.RemoveNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  FController.RemoveNode(ANode);

  UpdatePinsConnectedState;
  SyncControllerSelectionToView;
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.RemoveLink(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  FController.RemoveLink(ALink);

  UpdatePinsConnectedState;
  SyncControllerSelectionToView;
  NotifySelectionChanged;
  Repaint;
end;

procedure TNodeEditor.Clear;
begin
  FController.Clear;
  UpdatePinsConnectedState;
  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.Undo;
begin
  FController.Undo;
  UpdatePinsConnectedState;
  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.Redo;
begin
  FController.Redo;
  UpdatePinsConnectedState;
  ResetStateAfterGraphReload;
  Repaint;
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
  InternalWorldChanged;

  UpdatePinsConnectedState;
  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.SaveToFile(const AFileName: string);
begin
  FController.SaveToFile(AFileName, FZoom, FOffsetX, FOffsetY);
end;

procedure TNodeEditor.LoadFromFile(const AFileName: string);
var
  Z: Double;
  OX, OY: Double;
begin
  FController.LoadFromFile(AFileName, Z, OX, OY);
  FZoom := Z;
  FOffsetX := OX;
  FOffsetY := OY;
  InternalWorldChanged;

  UpdatePinsConnectedState;
  ResetStateAfterGraphReload;
  Repaint;
end;

procedure TNodeEditor.ClearPinSelection;
begin
  FController.PinSelection.Clear;
end;

procedure TNodeEditor.SelectPinInternal(APin: TNodePin; AAppend: boolean);
begin
  FController.PinSelection.SelectPin(APin, AAppend);
end;

procedure TNodeEditor.TogglePinSelection(APin: TNodePin);
begin
  FController.PinSelection.TogglePin(APin);
end;

procedure TNodeEditor.DoPinSelectionChanged(Sender: TObject);
begin
  if Assigned(FOnPinSelectionChanged) then
    FOnPinSelectionChanged(Self);
end;

function TNodeEditor.GetPrimarySelectedNode: TCustomNode;
begin
  if FController.Selection.NodeCount > 0 then
    Result := GetSelectedNode(0)
  else
    Result := nil;
end;

function TNodeEditor.SelectedPinCount: integer;
begin
  Result := FController.PinSelection.Count;
end;

function TNodeEditor.GetSelectedPin(Index: integer): TNodePin;
begin
  Result := FController.PinSelection.GetPin(Index);
end;

function TNodeEditor.CanConnectSelectedPins: Boolean;
begin
  Result := False;
  if FController.PinSelection.Count <> 2 then
    Exit;

  var P1 := FController.PinSelection.GetPin(0);
  var P2 := FController.PinSelection.GetPin(1);

  if (P1 = nil) or (P2 = nil) then
    Exit;

  if not CanPinAcceptMoreConnections(P1) then
    Exit;

  if not CanPinAcceptMoreConnections(P2) then
    Exit;

  Result := (FGraph <> nil) and FGraph.CanConnect(P1, P2);
end;

procedure TNodeEditor.ConnectSelectedPins;
begin
  if (FGraph = nil) or (FController.PinSelection.Count <> 2) then
    Exit;

  var P1 := FController.PinSelection.GetPin(0);
  var P2 := FController.PinSelection.GetPin(1);

  var Allow := True;
  if Assigned(FOnBeforeConnectPins) then
    FOnBeforeConnectPins(Self, P1, P2, Allow);

  if not Allow then
    Exit;

  if (P1 = nil) or (P2 = nil) then
    Exit;

  var FromPin, ToPin: TNodePin;
  if P1.Direction = TPinDirection.Output then
  begin
    FromPin := P1;
    ToPin := P2;
  end
  else
  begin
    FromPin := P2;
    ToPin := P1;
  end;

  if not CanPinAcceptMoreConnections(FromPin) then
    Exit;

  if not CanPinAcceptMoreConnections(ToPin) then
    Exit;

  Allow := True;
  if Assigned(FOnBeforeConnectPins) then
    FOnBeforeConnectPins(Self, FromPin, ToPin, Allow);

  if not Allow then
    Exit;

  if not FGraph.CanConnect(FromPin, ToPin) then
    Exit;

  if not FGraph.LinkExists(FromPin, ToPin) then
    FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, FromPin, ToPin));

  if Assigned(FOnAfterConnectPins) then
    FOnAfterConnectPins(Self, FromPin, ToPin);

  ClearPinSelection;
  Repaint;
end;

procedure TNodeEditor.ClearSelectionInternal;
begin
  ClearPinSelection;

  if ((FController.Selection.NodeCount > 0) or (FController.Selection.LinkCount > 0)) then
    FController.Selection.Clear;
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

  FController.Selection.SelectNode(ANode, AAppend);
end;

procedure TNodeEditor.SelectLinkInternal(ALink: TNodeLink; AKeepNodes: Boolean);
begin
  if ALink = nil then
    Exit;

  if not AKeepNodes then
  begin
    FController.Selection.Clear;
    ClearPinSelection;
  end;
  FController.Selection.SelectLink(ALink, True);
end;

procedure TNodeEditor.ToggleNodeSelection(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;

  if FController.Selection.ContainsNode(ANode) then
    FController.Selection.RemoveNode(ANode)
  else
    FController.Selection.SelectNode(ANode, True);

  ClearPinSelection;
  NotifySelectionChanged;
  Repaint;
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
    FController.Selection.AddLinkToSelection(ALink);
    ClearPinSelection;
  end;
end;

procedure TNodeEditor.SyncNodeSelectedFlags;
begin
  if FGraph = nil then
    Exit;

  for var i := 0 to FGraph.Nodes.Count - 1 do
  begin
    var N := FGraph.Nodes[i];
    if N <> nil then
      N.Selected := FController.Selection.ContainsNode(N);
  end;
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
begin
  SyncNodeSelectedFlags;
  InvalidateSortedNodes;
  NotifySelectionChanged;
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
    var L := TNodeLink(FGraph.Links[i]);
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

function TNodeEditor.WorldToScreen(WX, WY: Single): TPoint;
begin
  Result.X := Round(WX * FZoom + FOffsetX);
  Result.Y := Round(WY * FZoom + FOffsetY);
end;

function TNodeEditor.GetVisibleWorldRect: TRectF;
begin
  Result := TRectF.Create(ScreenToWorld(0, 0), ScreenToWorld(Width, Height), True);
end;

procedure TNodeEditor.InternalWorldChanged;
begin
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
  ANode.OnScreen := True;

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

function TNodeEditor.GetNodeUnderMouse(SX, SY: Integer): TCustomNode;
begin
  Result := nil;
  var W := ScreenToWorld(SX, SY);
  EnsureSortedNodes;

  for var i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    var N := FPaintNodesSorted[i];
    if not N.OnScreen then
      Continue;
    if (N.VisualKind <> TNodeVisualKind.Comment) and N.HitTest(W.X, W.Y) then
      Exit(N);
  end;

  for var i := FPaintNodesSorted.Count - 1 downto 0 do
  begin
    var N := FPaintNodesSorted[i];
    if not N.OnScreen then
      Continue;
    if (N.VisualKind = TNodeVisualKind.Comment) and N.HitTest(W.X, W.Y) then
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
    N := FPaintNodesSorted[i];
    if N.VisualKind = TNodeVisualKind.Comment then
      Continue;
    if N.VisualKind = TNodeVisualKind.Reroute then
      HitRadiusWorld := FPinRadius
    else
      HitRadiusWorld := FPinRadius + 2;

    var SkipInput := False;
    if N.VisualKind = TNodeVisualKind.Reroute then
    begin
      if N.OutputsIsBusy and N.InputsIsBusy then
        Continue;
      SkipInput := not N.OutputsIsBusy;
      if FReconnectFixedPin <> nil then
        SkipInput := FReconnectFixedPin.Direction = TPinDirection.Input
      else if FTempFromPin <> nil then
        SkipInput := FTempFromPin.Direction = TPinDirection.Input;
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

function TNodeEditor.GetLinkUnderMouse(SX, SY: Integer; out Link: TNodeLink): Boolean;
begin
  Result := False;
  Link := nil;

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
    var P1 := MiniScreenToWorld(Round(ARect.Width), Round(ARect.Height));
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
    var P1 := PointF(SX, 0).Truncate;
    var P2 := PointF(SX, ARect.Height).Truncate;
    ACanvas.DrawLine(P1, P2, AbsoluteOpacity);
    X := X + SmallStep;
  end;

  var Y := Floor(VR.Top / SmallStep) * SmallStep;
  while Y <= VR.Bottom do
  begin
    var SY := Trunc(Y * 1 + AOffsetY);
    var P1 := PointF(0, SY).Truncate;
    var P2 := PointF(ARect.Width, SY).Truncate;
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
  for var Link in FGraph.Links do
  begin
    if (Link.FromPin = nil) or (Link.ToPin = nil) then
      Continue;

    if not FScreenRect.IntersectsWith(Link.BoundsRect(FZoom, FOffsetX, FOffsetY)) then
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
  P0, P1, P2, P3: TPoint;
  W0, W1, W2, W3: TPointF;
  StartPin: TNodePin;
  FixedPosW: TPointF;
  DX, DY, Dist, D: Single;
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

  DX := W3.X - W0.X;
  DY := W3.Y - W0.Y;
  Dist := Hypot(DX, DY);
  D := EnsureRange(Dist * 0.35, 30 / FZoom, 150 / FZoom);

  W1 := W0;
  W2 := W3;

  if (StartPin <> nil) and (StartPin.Direction = TPinDirection.Input) then
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

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := $FFFFD740;
  Canvas.Stroke.Thickness := 3;
  Canvas.Stroke.Dash := TStrokeDash.Dot;

  DrawCubicBezier(Canvas, P0, P1, P2, P3, 1);

  Canvas.Stroke.Thickness := 1;
  Canvas.Stroke.Dash := TStrokeDash.Solid;
  Canvas.Stroke.Kind := TBrushKind.Solid;
end;

procedure TNodeEditor.DrawBoxSelect;
begin
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
  Pos.Offset(Round(GetPrimarySelectedNode.Width * Zoom / 2), 0);

  // Bounds position
  Pos.SetLocation(PointF(
      EnsureRange(Pos.X, TextW / 2, Width - TextW / 2),
      EnsureRange(Pos.Y, TextH + ArrowSize, Height)).Round);

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
  var Arrow: TPolygon;
  SetLength(Arrow, 3);
  Arrow[0] := PointF(Pos.X - ArrowSize, R.Bottom - 1);
  Arrow[1] := PointF(Pos.X + ArrowSize, R.Bottom - 1);
  Arrow[2] := PointF(Pos.X, R.Bottom + ArrowSize);
  Canvas.Fill.Color := $EE2B2D30;
  Canvas.FillPolygon(Arrow, 1);
  Canvas.Stroke.Color := $30FFFFFF;
  Canvas.DrawPolygon(Arrow, 1);

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
        if FScreenRect.IntersectsWith(R) then
          DrawNode(N, R);
      end;
    end;

    for var N in FPaintNodesSorted do
    begin
      if (N.VisualKind = TNodeVisualKind.Comment) and N.Selected then
      begin
        var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
        if FScreenRect.IntersectsWith(R) then
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
        if FScreenRect.IntersectsWith(R) then
          DrawNode(N, R);
      end;
    end;

    for var N in FPaintNodesSorted do
    begin
      if (N.VisualKind <> TNodeVisualKind.Comment) and N.Selected then
      begin
        var R := N.GetScreenBounds(FZoom, FOffsetX, FOffsetY);
        if FScreenRect.IntersectsWith(R) then
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
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Clear(TAlphaColors.Null);
  Canvas.Fill.Color := $FF222222;
  Canvas.FillRect(LocalRect, 7, 7, AllCorners, 1);
  EnsureSortedNodes;
  for var i := 0 to FGraph.Nodes.Count - 1 do
    FGraph.Nodes[i].OnScreen := False;
  for var i := 0 to FGraph.Links.Count - 1 do
    FGraph.Links[i].OnScreen := False;
end;

procedure TNodeEditor.EndPaint;
begin
  FFrameTimeWatch.Stop;
end;

procedure TNodeEditor.DrawFrameTime;
begin
  Canvas.Font.Size := 12;
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.FillText(
    RectF(20, 20, 500, 500),
    FFrameTimeWatch.ElapsedMilliseconds.ToString + 'ms'#13#10 +
    'Canvas: ' + Canvas.ClassName + #13#10 +
    'Context: ' + TContextManager.DefaultContextClass.ClassName,
    False, 1, [], TTextAlign.Leading, TTextAlign.Leading);
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
  if FDraggingNode and FShowSnapGuides then
    DrawSnapGuides;

  // Link connector
  if FTempFromPin <> nil then
    DrawTempLink;

  // Box selectiing
  if FBoxSelecting then
    DrawBoxSelect;

  // Node hint
  if FDraggingNode and FShowDragCoordinates and (GetPrimarySelectedNode <> nil) then
    DrawMoveHint;

  EndPaint;

  // Draw frame time
  if FShowFrameTime then
    DrawFrameTime;
end;

function TNodeEditor.GetNodeResizeUnderMouse(SX, SY: Integer): TCustomNode;
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
  var P := Screen.MousePos.Round;
  ShowNodeSearchPopup(P.X, P.Y, FContextWorldPos);
end;

procedure TNodeEditor.OnContextInsertReroute(Sender: TObject);
begin
  if GetPrimarySelectedLink = nil then
    Exit;

  FController.InsertRerouteOnLink(GetPrimarySelectedLink, SnapWorldPoint(FContextWorldPos));
end;

procedure TNodeEditor.OnContextAddComment(Sender: TObject);
begin
  FController.AddCommentNode(SnapWorldPoint(FContextWorldPos));
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
  SyncControllerSelectionToView;
end;

procedure TNodeEditor.DuplicateSelection;
begin
  var W := ScreenToWorld(FLastMousePos);
  W.Offset(25, 25);
  FController.DuplicateSelection(SnapWorldPoint(W));
  SyncControllerSelectionToView;
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
  ACanvas.FillRect(ARect, 4, 4, AllCorners, 1);

  var CameraCenter := ScreenToWorld(Width * 0.5, Height * 0.5);
  var WorldRect := TRectF.Create(ScreenToWorld(0, 0), ScreenToWorld(Width, Height));
  var ViewRect: TRectF;
  var MiniOffsetX: Single;
  var MiniOffsetY: Single;

  // Optimal mini zoom
  var MiniZoom := 0.045;
  repeat
    MiniZoom := MiniZoom - 0.001;
    MiniOffsetX := ARect.CenterPoint.X - CameraCenter.X * MiniZoom;
    MiniOffsetY := ARect.CenterPoint.Y - CameraCenter.Y * MiniZoom;

    ViewRect := WorldToMini(WorldRect, MiniZoom, MiniOffsetX, MiniOffsetY);
  until ARect.Contains(ViewRect);

  // Center dot
  ACanvas.Fill.Color := TAlphaColors.Cornflowerblue;
  ACanvas.FillEllipse(TRectF.Create(PointF(MiniOffsetX, MiniOffsetY), 4, 4), 0.8);
  DrawMiniGrid(ACanvas, ARect, MiniOffsetX, MiniOffsetY, MiniZoom);

  // Draw nodes
  EnsureSortedNodes;

  for var i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    var N := FPaintNodesSorted[i];
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

  for var i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    var N := FPaintNodesSorted[i];
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

  for var i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    var N := FPaintNodesSorted[i];
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

  for var i := 0 to FPaintNodesSorted.Count - 1 do
  begin
    var N := FPaintNodesSorted[i];
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

  // Viewport frame
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Color := TAlphaColors.White;
  ACanvas.Stroke.Thickness := 1;
  ViewRect := ViewRect.Truncate;
  ViewRect := ACanvas.AlignToPixel(ViewRect);
  ACanvas.DrawRect(ViewRect, 0, 0, [], 1);

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

procedure TNodeEditor.ShowNodeSearchPopup(AScreenX, AScreenY: Integer; const WorldPosition: TPointF);
begin
  var Form := TFormNodeEditorSearch.CreateSearch(Self, FGraph.Registry);
  try
    Form.Left := EnsureRange(AScreenX - Form.Width div 2, 0, Round(Screen.Width) - Form.Width);
    Form.Top := EnsureRange(AScreenY - Form.Height div 2, 0, Round(Screen.Height) - Form.Height);

    if Form.ShowModal = mrOk then
    begin
      if Form.SelectedNodeType <> '' then
      begin
        var N := FGraph.Registry.CreateNode(Form.SelectedNodeType, SnapWorldPoint(WorldPosition));
        AddNode(N);
        SelectNodeInternal(N, False);
      end;
    end;
  finally
    Form.Free;
  end;
end;

procedure TNodeEditor.ResetStateAfterGraphReload;
begin
  var OldHandler := FController.Selection.OnChanged;
  FController.Selection.OnChanged := nil;
  try
    FController.Selection.Clear;
    ClearPinSelection;
  finally
    FController.Selection.OnChanged := OldHandler;
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

  SyncControllerSelectionToView;
end;

procedure TNodeEditor.Resize;
begin
  inherited;
  FScreenRect := LocalRect;
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

procedure TNodeEditor.UpdateHoverStates(SX, SY: Integer; HitLinks: Boolean);
var
  N: TCustomNode;
  P: TNodePin;
  L: TNodeLink;
begin

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
      if TestPin <> P then
        if ((CanPinAcceptMoreConnections(TestPin) or FReconnectingLink) and
          CanPinAcceptMoreConnections(P)) and
          FGraph.CanConnect(TestPin, P) then
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
    end
    else if HitLinks and GetLinkUnderMouse(SX, SY, L) then
      FHoveredLink := L;
  end;
end;

procedure TNodeEditor.FitToSelection;
begin
  if FController.Selection.NodeCount = 0 then
    Exit;

  var First := True;
  var R: TRect;
  for var i := 0 to FController.Selection.NodeCount - 1 do
  begin
    var N := FController.Selection.GetNode(i);
    var NR := Rect(Round(N.X), Round(N.Y), Round(N.X + N.Width), Round(N.Y + N.Height));

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

  FOffsetX := Margin - Round(R.Left * FZoom);
  FOffsetY := Margin - Round(R.Top * FZoom);
  InternalWorldChanged;

  Repaint;
end;

procedure TNodeEditor.ResetView;
begin
  var Center := PointF(Width / 2, Height / 2);
  FOffsetX := Center.X;
  FOffsetY := Center.Y;
  FZoom := 1;
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
  FZoom := EnsureRange(FZoom, ZoomMin, ZoomMax);

  Cx := (MinX + MaxX) * 0.5;
  Cy := (MinY + MaxY) * 0.5;

  FOffsetX := Round(Width * 0.5 - Cx * FZoom);
  FOffsetY := Round(Height * 0.5 - Cy * FZoom);
  InternalWorldChanged;

  Repaint;
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

procedure TNodeEditor.InternalMouseDown(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
var
  Node: TCustomNode;
  Pin: TNodePin;
  Link: TNodeLink;
  X, Y: Integer;

  function ClickLink: Boolean;
  begin
    Result := False;

    if FLockedAll then
      Exit;

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
        FController.Selection.SelectLink(Link, False);
      end;
      FDraggingNode := False;

      if (Button = TMouseButton.mbLeft) then
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

        FTempMousePos := Point(X, Y);
        FTempStartMousePos := Point(X, Y);
        FDraggingLink := False;
      end;

      NotifySelectionChanged;
      Repaint;
      Exit(True);
    end;
  end;

begin
  X := Round(AX);
  Y := Round(AY);
  SetFocus;
  if (Button = TMouseButton.mbLeft) or (Button = TMouseButton.mbRight) then
  begin
    ClearSnapGuides;

    // Click resize
    if (not FLockedAll) and (Button = TMouseButton.mbLeft) then
    begin
      Node := GetNodeResizeUnderMouse(X, Y);
      if Node <> nil then
      begin
        if not FController.Selection.ContainsNode(Node) then
        begin
          SelectNodeInternal(Node, False);
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
    end;

    var ZNode := GetNodeUnderMouse(X, Y);

    // Click pins
    if (not FLockedAll) and (Button = TMouseButton.mbLeft) then
    begin
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

          if not CanPinAcceptMoreConnections(Pin) then
          begin
            ClearPinSelection;
            //SelectPinInternal(Pin, False);
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
    end;

    Node := ZNode;
    // Click nodes
    if Node <> nil then
    begin
      if Node.VisualKind = TNodeVisualKind.Comment then
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

      if (not FLockedAll) and (Button = TMouseButton.mbLeft) then
      begin
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
      end;

      NotifySelectionChanged;
      Repaint;
      Exit;
    end;

    if ClickLink then
      Exit;

    if Button = TMouseButton.mbLeft then
    begin
      if not (ssShift in Shift) then
        ClearSelectionInternal;
      FBoxSelecting := True;
      FBoxStart := Point(X, Y);
      FBoxCurrent := Point(X, Y);
      FBoxStartWorld := ScreenToWorld(X, Y);
      FBoxCurrentWorld := FBoxStartWorld;
      NotifySelectionChanged;
    end;
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

procedure TNodeEditor.InternalMouseMove(Shift: TShiftState; AX, AY: Single);
var
  Dx, Dy: Single;
  X, Y: Integer;
  BaseX, BaseY: single;
  SnappedX, SnappedY: boolean;
  RawDx, RawDy: single;
  ResizeNode: TCustomNode;
begin
  X := Round(AX);
  Y := Round(AY);
  FLastMousePos := Point(X, Y);

  if FPanning then
  begin
    if (Abs(X - FPanStartX) > 2) or (Abs(Y - FPanStartY) > 2) then
      FRightMouseMoved := True;
    FOffsetX := FOffsetX + (X - FPanStartX);
    FOffsetY := FOffsetY + (Y - FPanStartY);
    FPanStartX := X;
    FPanStartY := Y;
    InternalWorldChanged;
  end
  else if FResizingNode and (FResizeNode <> nil) then
  begin
    FResizeNode.Width := Max(FResizeNode.MinWidth, FResizeStartWidth + Round((X - FResizeStartMouseX) / FZoom));
    FResizeNode.Height := Max(FResizeNode.MinHeight, FResizeStartHeight + Round((Y - FResizeStartMouseY) / FZoom));

    if FResizeNode.VisualKind = TNodeVisualKind.Reroute then
    begin
      FResizeNode.Width := Max(12, FResizeNode.Width);
      FResizeNode.Height := FResizeNode.Width;
    end;
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
  end
  else if FTempFromPin <> nil then
  begin
    FTempMousePos := Point(X, Y);

    if (Abs(X - FTempStartMousePos.X) > 4) or (Abs(Y - FTempStartMousePos.Y) > 4) then
      FDraggingLink := True;

    if (X <> FLastHoverMouseX) or (Y <> FLastHoverMouseY) then
    begin
      FLastHoverMouseX := X;
      FLastHoverMouseY := Y;
      UpdateHoverStates(X, Y, False);
    end;
  end
  else if FBoxSelecting then
  begin
    FBoxCurrent := Point(X, Y);
    FBoxCurrentWorld := ScreenToWorld(X, Y);
  end
  else
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
      UpdateHoverStates(X, Y, False);
    end;
  end;
  Repaint;
end;

procedure TNodeEditor.InternalMouseUp(Button: TMouseButton; Shift: TShiftState; AX, AY: Single);
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
  X := Round(AX);
  Y := Round(AY);

  if Button = TMouseButton.mbLeft then
  begin
    // Insert reroute on Double click on link
    if (ssDouble in Shift) and (GetPrimarySelectedLink <> nil) then
    begin
      var Reroute := FController.InsertRerouteOnLink(GetPrimarySelectedLink, SnapWorldPoint(ScreenToWorld(X, Y)));

      FTempFromPin := nil;
      FDraggingLink := False;
      FReconnectingLink := False;
      FReconnectLink := nil;
      FReconnectFixedPin := nil;
      ClearSnapGuides;
      SyncControllerSelectionToView;
      ClearSelectionInternal;
      FController.Selection.SelectNode(Reroute, False);
      ClearPinSelection;
      NotifySelectionChanged;
      Exit;
    end;

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
          if FReconnectMovingFromSide then
          begin
            if CanPinAcceptMoreConnections(TargetPin) and
              //CanPinAcceptMoreConnections(FReconnectFixedPin) and
            FGraph.CanConnect(TargetPin, FReconnectFixedPin) then
            begin
              AllowConnect := True;
              if Assigned(FOnBeforeConnectPins) then
                FOnBeforeConnectPins(Self, TargetPin, FReconnectFixedPin, AllowConnect);

              if AllowConnect then
              begin                                                                                                      {
                FGraph.RemoveLink(FReconnectLink);
                FGraph.AddLink(TNodeLink.Create(TargetPin, FReconnectFixedPin));                                        }
                FController.ExecuteCommand(TReconnectLinkCommand.Create(FGraph, FReconnectLink, FReconnectLink.FromPin, TargetPin));
                UpdatePinsConnectedState;
                if Assigned(FOnAfterConnectPins) then
                  FOnAfterConnectPins(Self, TargetPin, FReconnectFixedPin);
              end;
            end;
          end
          else
          begin
            if //CanPinAcceptMoreConnections(FReconnectFixedPin) and
              CanPinAcceptMoreConnections(TargetPin) and
              FGraph.CanConnect(FReconnectFixedPin, TargetPin) then
            begin
              AllowConnect := True;
              if Assigned(FOnBeforeConnectPins) then
                FOnBeforeConnectPins(Self, FReconnectFixedPin, TargetPin, AllowConnect);

              if AllowConnect then
              begin                {
                FGraph.RemoveLink(FReconnectLink);
                FGraph.AddLink(TNodeLink.Create(FReconnectFixedPin, TargetPin)); }
                FController.ExecuteCommand(TReconnectLinkCommand.Create(FGraph, FReconnectLink, FReconnectLink.ToPin, TargetPin));
                UpdatePinsConnectedState;
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

      if GetPinUnderMouse(X, Y, TargetNode, TargetPin) then
      begin
        if CanPinAcceptMoreConnections(FTempFromPin) and
          CanPinAcceptMoreConnections(TargetPin) and
          FGraph.CanConnect(FTempFromPin, TargetPin) then
        begin
          if FTempFromPin.Direction = TPinDirection.Output then
          begin
            AllowConnect := True;
            if Assigned(FOnBeforeConnectPins) then
              FOnBeforeConnectPins(Self, FTempFromPin, TargetPin, AllowConnect);

            if AllowConnect and not FGraph.LinkExists(FTempFromPin, TargetPin) then
            begin
              FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, FTempFromPin, TargetPin));
              if Assigned(FOnAfterConnectPins) then
                FOnAfterConnectPins(Self, FTempFromPin, TargetPin);
            end;
          end
          else
          begin
            AllowConnect := True;
            if Assigned(FOnBeforeConnectPins) then
              FOnBeforeConnectPins(Self, TargetPin, FTempFromPin, AllowConnect);

            if AllowConnect and not FGraph.LinkExists(TargetPin, FTempFromPin) then
            begin
              FGraph.ExecuteCommand(TAddLinkCommand.Create(FGraph, TargetPin, FTempFromPin));
              if Assigned(FOnAfterConnectPins) then
                FOnAfterConnectPins(Self, TargetPin, FTempFromPin);
            end;
          end;
        end;
      end
      else if FDraggingLink then
      begin
        TargetNode := FController.CreateCompatibleNodeForPin(FTempFromPin, SnapWorldPoint(ScreenToWorld(X, Y)));

        if TargetNode <> nil then
        begin
          FGraph.ExecuteCommand(TAddNodeCommand.Create(FGraph, TargetNode));

          if FTempFromPin.Direction = TPinDirection.Output then
          begin
            for i := 0 to TargetNode.InputCount - 1 do
            begin
              TargetPin := TargetNode.GetInput(i);
              if CanPinAcceptMoreConnections(FTempFromPin) and
                CanPinAcceptMoreConnections(TargetPin) and
                FGraph.CanConnect(FTempFromPin, TargetPin) then
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
        end
        else
        begin
          var MPos := Screen.MousePos.Round;
          ShowNodeSearchPopup(MPos.X, MPos.Y, ScreenToWorld(X, Y));
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

        FGraph.ExecuteCommand(TMoveNodesCommand.Create(FGraph, FDragCommandNodes, FDragOldPositions, NewPositions));

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
        FController.Selection.BeginUpdate;
        for i := 0 to FGraph.Nodes.Count - 1 do
        begin
          N := FGraph.Nodes[i];
          if not N.OnScreen then
            Continue;
          if R.IntersectsWith(RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height)) then
            FController.Selection.SelectNode(N, True);
        end;
        ClearPinSelection;
        FController.Selection.EndUpdate;
      end
      else if ssCtrl in Shift then
      begin
        // Ctrl + box: only links
        FController.Selection.BeginUpdate;
        for i := 0 to FGraph.Links.Count - 1 do
        begin
          var L := FGraph.Links[i];
          if not L.OnScreen then
            Continue;
          if L.IsInsideWorldRect(R) then
            FController.Selection.AddLinkToSelection(L);
        end;
        ClearPinSelection;
        FController.Selection.EndUpdate;
      end
      else
      begin
        FController.Selection.BeginUpdate;
        for i := 0 to FGraph.Nodes.Count - 1 do
        begin
          N := FGraph.Nodes[i];
          if not N.OnScreen then
            Continue;
          if R.IntersectsWith(RectF(N.X, N.Y, N.X + N.Width, N.Y + N.Height)) then
            FController.Selection.SelectNode(N, True);
        end;
        ClearPinSelection;
        FController.Selection.EndUpdate;

        for i := 0 to FGraph.Links.Count - 1 do
        begin
          var L := FGraph.Links[i];
          if not L.OnScreen then
            Continue;
          if L.IsInsideWorldRect(R) then
            FController.Selection.AddLinkToSelection(L);
        end;
        ClearPinSelection;
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

procedure TNodeEditor.DoMouseLeave;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;

  CancelMouseOperations(False);

  if not (FDraggingNode or FBoxSelecting or FResizingNode or FPanning or (FTempFromPin <> nil) or FReconnectingLink) then
  begin
    ClearHoverStates;
    Repaint;
  end;
end;

procedure TNodeEditor.UpdatedStatus;
begin
  if Assigned(FOnUpdatedStatus) then
    FOnUpdatedStatus(Self);
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

procedure TNodeEditor.SetLinkGradient(const Value: Boolean);
begin
  FLinkGradient := Value;
  TNodeLink.UseGradient := FLinkGradient;
  Repaint;
end;

procedure TNodeEditor.SetLinkVisualType(const Value: TLinkVisualType);
begin
  FLinkVisualType := Value;
  TNodeLink.VisualType := FLinkVisualType;
  Repaint;
end;

procedure TNodeEditor.SetLockedAll(const Value: Boolean);
begin
  FLockedAll := Value;
end;

procedure TNodeEditor.SetOnUpdatedStatus(const Value: TNotifyEvent);
begin
  FOnUpdatedStatus := Value;
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

procedure TNodeEditor.SetZoom(Value: Double; const TargetPos: TPoint);
begin
  var NewZoom := EnsureRange(Value, ZoomMin, ZoomMax);

  if Abs(FZoom - NewZoom) > 0.0001 then
  begin
    FOffsetX := TargetPos.X - Round((TargetPos.X - FOffsetX) * (NewZoom / FZoom));
    FOffsetY := TargetPos.Y - Round((TargetPos.Y - FOffsetY) * (NewZoom / FZoom));
    InternalWorldChanged;
  end;
  FZoom := NewZoom;

  UpdatedStatus;
  Repaint;
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

procedure TNodeEditor.SelectAll;
begin
  ClearSelectionInternal;

  FController.Selection.BeginUpdate;
  for var i := 0 to FGraph.Nodes.Count - 1 do
    FController.Selection.SelectNode(FGraph.Nodes[i], True);

  for var i := 0 to FGraph.Links.Count - 1 do
    FController.Selection.AddLinkToSelection(FGraph.Links[i]);
  FController.Selection.EndUpdate;

  ClearPinSelection;
  NotifySelectionChanged;
end;

procedure TNodeEditor.SelectAllNodes;
begin
  ClearSelectionInternal;

  FController.Selection.BeginUpdate;
  for var i := 0 to FGraph.Nodes.Count - 1 do
    FController.Selection.SelectNode(FGraph.Nodes[i], True);
  FController.Selection.EndUpdate;

  ClearPinSelection;
  NotifySelectionChanged;
end;

procedure TNodeEditor.SelectAllLinks;
begin
  ClearSelectionInternal;
  FController.Selection.BeginUpdate;
  for var i := 0 to FGraph.Links.Count - 1 do
    FController.Selection.AddLinkToSelection(FGraph.Links[i]);
  FController.Selection.EndUpdate;

  ClearPinSelection;
  NotifySelectionChanged;
end;

procedure TNodeEditor.KeyDown(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  case Key of
    vkDelete:
      begin
        DeleteSelection;
      end;
    vkZ:
      if Shift = [ssCtrl] then
      begin
        Undo;
      end
      else if Shift = [ssCtrl] then
      begin
        Undo;
      end
      else if Shift = [ssCtrl, ssShift] then
      begin
        Redo;
      end;
    vkY:
      if Shift = [ssCtrl] then
      begin
        Redo;
      end;
    vkC:
      if Shift = [ssCtrl] then
      begin
        CopySelectionToClipboard;
      end;
    vkX:
      if Shift = [ssCtrl] then
      begin
        CutSelectionToClipboard;
      end;
    vkV:
      if Shift = [ssCtrl] then
      begin
        PasteFromClipboard;
      end;
    vkD:
      if Shift = [ssCtrl] then
      begin
        DuplicateSelection;
      end;
    vkF:
      begin
        if FController.Selection.NodeCount > 0 then
          FitToSelection
        else
          FrameAll;
      end;
    vkL:
      if Shift = [ssCtrl] then
      begin
        ConnectSelectedPins;
      end;
    vkA:
      if Shift = [ssCtrl] then
      begin
        // Ctrl + A -> nodes + links
        SelectAll;
      end
      else if Shift = [ssCtrl, ssShift] then
      begin
        // Ctrl + Shift + A -> only nodes
        SelectAllNodes;
      end
      else if Shift = [ssShift] then
      begin
        // Shift + A -> only links
        SelectAllLinks;
      end;
    vkEscape:
      begin
        if FTempFromPin <> nil then
        begin
          CancelMouseOperations(False);
        end
        else if FDraggingNode or FBoxSelecting or FResizingNode or FPanning or FReconnectingLink then
        begin
          CancelMouseOperations(False);
        end
        else
        begin
          ClearSelection;
        end;
      end;
  end;
  Repaint;
  Key := 0;
end;

procedure TNodeEditor.KeyUp(var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
end;

end.

