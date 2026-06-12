unit FMX.NodeEditor.Selection;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Types,
  FMX.NodeEditor.Node;

type
  TNodeSelectionModel = class
  private
    FSelectedPins: TList<TNodePin>;
    FSelectedNodes: TList<TCustomNode>;
    FSelectedLinks: TList<TNodeLink>;
    FOnChanged: TNotifyEvent;
    FUpdateCount: Integer;
    procedure NotifyChanged; inline;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure SelectNode(ANode: TCustomNode; AAppend: boolean);
    procedure SelectLink(ALink: TNodeLink; AAppend: boolean = False);
    procedure ToggleLink(ALink: TNodeLink);
    function ContainsNode(ANode: TCustomNode): boolean;
    function ContainsLink(ALink: TNodeLink): boolean;
    procedure AddLinkToSelection(ALink: TNodeLink);
    procedure RemoveLinkFromSelection(ALink: TNodeLink);
    procedure RemoveNode(ANode: TCustomNode);

    procedure SelectPin(APin: TNodePin; AAppend: boolean);
    procedure TogglePin(APin: TNodePin);

    function NodeCount: integer;
    function GetNode(Index: integer): TCustomNode;

    function LinkCount: integer;
    function GetLink(Index: integer): TNodeLink;
    function HasLink: boolean;

    procedure ClearPins(Notify: Boolean = True);
    function PinCount: integer;
    function GetPin(Index: integer): TNodePin;
    function Contains(APin: TNodePin): boolean; overload;
    function SelectedCount: Integer;

    function SelectedLink: TNodeLink; // returns first selected link
    function SelectedPin: TNodePin; // returns first selected pin

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property Nodes: TList<TCustomNode> read FSelectedNodes;
    property Links: TList<TNodeLink> read FSelectedLinks;
    property Pins: TList<TNodePin> read FSelectedPins;
  end;

implementation

{ TNodeSelectionModel }

constructor TNodeSelectionModel.Create;
begin
  inherited Create;
  FSelectedNodes := TList<TCustomNode>.Create;
  FSelectedLinks := TList<TNodeLink>.Create;
  FSelectedPins := TList<TNodePin>.Create;
end;

destructor TNodeSelectionModel.Destroy;
begin
  FSelectedLinks.Free;
  FSelectedNodes.Free;
  FSelectedPins.Free;
  inherited Destroy;
end;

procedure TNodeSelectionModel.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    NotifyChanged;
end;

procedure TNodeSelectionModel.NotifyChanged;
begin
  if FUpdateCount > 0 then
    Exit;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

function TNodeSelectionModel.PinCount: integer;
begin
  Result := FSelectedPins.Count;
end;

procedure TNodeSelectionModel.Clear;
begin
  FSelectedNodes.Clear;
  FSelectedLinks.Clear;
  ClearPins(False);

  NotifyChanged;
end;

function TNodeSelectionModel.SelectedCount: Integer;
begin
  Result := FSelectedNodes.Count + FSelectedLinks.Count + FSelectedPins.Count;
end;

procedure TNodeSelectionModel.ClearPins(Notify: Boolean);
begin
  if FSelectedPins.Count > 0 then
  begin
    for var Pin in FSelectedPins do
      Pin.Selected := False;
    FSelectedPins.Clear;
    if Notify then
      NotifyChanged;
  end;
end;

procedure TNodeSelectionModel.SelectNode(ANode: TCustomNode; AAppend: boolean);
begin
  if ANode = nil then
    Exit;

  if not AAppend then
    Clear;

  if FSelectedNodes.IndexOf(ANode) < 0 then
  begin
    FSelectedNodes.Add(ANode);
    NotifyChanged;
  end
  else if not AAppend then
    NotifyChanged;
end;

procedure TNodeSelectionModel.SelectPin(APin: TNodePin; AAppend: boolean);
begin
  if APin = nil then
    Exit;

  if not AAppend then
  begin
    if (FSelectedPins.Count = 1) and (FSelectedPins[0] = APin) then
      Exit;
    ClearPins(False);
  end;

  if FSelectedPins.IndexOf(APin) < 0 then
  begin
    FSelectedPins.Add(APin);
    APin.Selected := True;
  end;

  NotifyChanged;
end;

procedure TNodeSelectionModel.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TNodeSelectionModel.SelectLink(ALink: TNodeLink; AAppend: boolean = False);
begin
  if ALink = nil then
    Exit;

  if not AAppend then
  begin
    FSelectedNodes.Clear;
    FSelectedLinks.Clear;
    ClearPins(False);
  end;

  AddLinkToSelection(ALink);
end;

procedure TNodeSelectionModel.ToggleLink(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;

  if FSelectedLinks.IndexOf(ALink) >= 0 then
    RemoveLinkFromSelection(ALink)
  else
    AddLinkToSelection(ALink);
end;

procedure TNodeSelectionModel.TogglePin(APin: TNodePin);
begin
  if APin = nil then
    Exit;

  var Idx := FSelectedPins.IndexOf(APin);
  if Idx >= 0 then
  begin
    FSelectedPins.Delete(Idx);
    APin.Selected := False;
  end
  else
  begin
    FSelectedPins.Add(APin);
    APin.Selected := True;
  end;

  NotifyChanged;
end;

procedure TNodeSelectionModel.AddLinkToSelection(ALink: TNodeLink);
begin
  if (ALink = nil) or (FSelectedLinks.IndexOf(ALink) >= 0) then
    Exit;
  FSelectedLinks.Add(ALink);
  NotifyChanged;
end;

function TNodeSelectionModel.ContainsNode(ANode: TCustomNode): boolean;
begin
  Result := FSelectedNodes.IndexOf(ANode) >= 0;
end;

function TNodeSelectionModel.Contains(APin: TNodePin): boolean;
begin
  Result := FSelectedPins.IndexOf(APin) >= 0;
end;

function TNodeSelectionModel.ContainsLink(ALink: TNodeLink): boolean;
begin
  Result := FSelectedLinks.IndexOf(ALink) >= 0;
end;

procedure TNodeSelectionModel.RemoveLinkFromSelection(ALink: TNodeLink);
begin
  if ALink = nil then
    Exit;
  FSelectedLinks.Remove(ALink);
  NotifyChanged;
end;

procedure TNodeSelectionModel.RemoveNode(ANode: TCustomNode);
begin
  if ANode = nil then
    Exit;
  FSelectedNodes.Remove(ANode);

  for var i := FSelectedLinks.Count - 1 downto 0 do
  begin
    if ((FSelectedLinks[i].FromPin <> nil) and
      (FSelectedLinks[i].FromPin.OwnerNode = ANode)) or
      ((FSelectedLinks[i].ToPin <> nil) and
      (FSelectedLinks[i].ToPin.OwnerNode = ANode))
      then
      FSelectedLinks.Delete(i);
  end;

  NotifyChanged;
end;

function TNodeSelectionModel.NodeCount: integer;
begin
  Result := FSelectedNodes.Count;
end;

function TNodeSelectionModel.GetNode(Index: integer): TCustomNode;
begin
  if (Index >= 0) and (Index < FSelectedNodes.Count) then
    Result := FSelectedNodes[Index]
  else
    Result := nil;
end;

function TNodeSelectionModel.GetPin(Index: integer): TNodePin;
begin
  if (Index >= 0) and (Index < FSelectedPins.Count) then
    Result := FSelectedPins[Index]
  else
    Result := nil;
end;

function TNodeSelectionModel.LinkCount: integer;
begin
  Result := FSelectedLinks.Count;
end;

function TNodeSelectionModel.GetLink(Index: integer): TNodeLink;
begin
  if (Index >= 0) and (Index < FSelectedLinks.Count) then
    Result := FSelectedLinks[Index]
  else
    Result := nil;
end;

function TNodeSelectionModel.HasLink: boolean;
begin
  Result := FSelectedLinks.Count > 0;
end;

function TNodeSelectionModel.SelectedLink: TNodeLink;
begin
  if FSelectedLinks.Count > 0 then
    Result := FSelectedLinks[0]
  else
    Result := nil;
end;

function TNodeSelectionModel.SelectedPin: TNodePin;
begin
  if FSelectedPins.Count > 0 then
    Result := FSelectedPins[0]
  else
    Result := nil;
end;

end.

