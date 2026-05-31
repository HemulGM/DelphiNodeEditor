unit FMX.NodeEditor.Selection;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Types,
  FMX.NodeEditor.Node;

type
  TNodeSelectionModel = class
  private
    FNodes: TObjectList<TCustomNode>;
    FSelectedLinks: TObjectList<TNodeLink>;
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

    function NodeCount: integer;
    function GetNode(Index: integer): TCustomNode;
    function LinkCount: integer;
    function GetLink(Index: integer): TNodeLink;
    function HasLink: boolean;
    function SelectedLink: TNodeLink; // returns first selected link

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property Nodes: TObjectList<TCustomNode> read FNodes;
    property Links: TObjectList<TNodeLink> read FSelectedLinks;
  end;

  TPinSelectionModel = class
  private
    FSelectedPins: TList<TNodePin>;
    FSelectedPin: TNodePin;
    FOnChanged: TNotifyEvent;
    procedure NotifyChanged;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear(Notify: Boolean = True);
    procedure SelectPin(APin: TNodePin; AAppend: boolean);
    procedure TogglePin(APin: TNodePin);
    function Count: integer;
    function GetPin(Index: integer): TNodePin;
    function Contains(APin: TNodePin): boolean;

    property SelectedPin: TNodePin read FSelectedPin;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

{ TNodeSelectionModel }

constructor TNodeSelectionModel.Create;
begin
  inherited Create;
  FNodes := TObjectList<TCustomNode>.Create(False);
  FSelectedLinks := TObjectList<TNodeLink>.Create(False);
end;

destructor TNodeSelectionModel.Destroy;
begin
  FSelectedLinks.Free;
  FNodes.Free;
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

procedure TNodeSelectionModel.Clear;
begin
  FNodes.Clear;
  FSelectedLinks.Clear;

  NotifyChanged;
end;

procedure TNodeSelectionModel.SelectNode(ANode: TCustomNode; AAppend: boolean);
begin
  if ANode = nil then
    Exit;

  if not AAppend then
  begin
    FNodes.Clear;
    FSelectedLinks.Clear;
  end;

  if FNodes.IndexOf(ANode) < 0 then
  begin
    FNodes.Add(ANode);
    NotifyChanged;
  end
  else if not AAppend then
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
    FNodes.Clear;
    FSelectedLinks.Clear;
  end;

  if FSelectedLinks.IndexOf(ALink) < 0 then
    FSelectedLinks.Add(ALink);

  NotifyChanged;
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

procedure TNodeSelectionModel.AddLinkToSelection(ALink: TNodeLink);
begin
  if (ALink = nil) or (FSelectedLinks.IndexOf(ALink) >= 0) then
    Exit;
  FSelectedLinks.Add(ALink);
  NotifyChanged;
end;

function TNodeSelectionModel.ContainsNode(ANode: TCustomNode): boolean;
begin
  Result := FNodes.IndexOf(ANode) >= 0;
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
  FNodes.Remove(ANode);

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
  Result := FNodes.Count;
end;

function TNodeSelectionModel.GetNode(Index: integer): TCustomNode;
begin
  if (Index >= 0) and (Index < FNodes.Count) then
    Result := FNodes[Index]
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

{ TPinSelectionModel }

constructor TPinSelectionModel.Create;
begin
  inherited Create;
  FSelectedPins := TList<TNodePin>.Create;
  FSelectedPin := nil;
end;

destructor TPinSelectionModel.Destroy;
begin
  FSelectedPins.Free;
  inherited Destroy;
end;

procedure TPinSelectionModel.NotifyChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TPinSelectionModel.Clear(Notify: Boolean);
begin
  if FSelectedPins.Count > 0 then
  begin
    for var Pin in FSelectedPins do
      Pin.Selected := False;
    FSelectedPins.Clear;
    FSelectedPin := nil;
    if Notify then
      NotifyChanged;
  end;
end;

procedure TPinSelectionModel.SelectPin(APin: TNodePin; AAppend: boolean);
begin
  if APin = nil then
    Exit;

  if not AAppend then
  begin
    if (FSelectedPins.Count = 1) and (FSelectedPins[0] = APin) then
      Exit;
    Clear(False);
  end;

  if FSelectedPins.IndexOf(APin) < 0 then
  begin
    FSelectedPins.Add(APin);
    APin.Selected := True;
  end;

  FSelectedPin := APin;
  NotifyChanged;
end;

procedure TPinSelectionModel.TogglePin(APin: TNodePin);
begin
  if APin = nil then
    Exit;

  var Idx := FSelectedPins.IndexOf(APin);
  if Idx >= 0 then
  begin
    FSelectedPins.Delete(Idx);
    APin.Selected := False;
    if FSelectedPin = APin then
    begin
      if FSelectedPins.Count > 0 then
        FSelectedPin := FSelectedPins[FSelectedPins.Count - 1]
      else
        FSelectedPin := nil;
    end;
  end
  else
  begin
    FSelectedPins.Add(APin);
    APin.Selected := True;
    FSelectedPin := APin;
  end;

  NotifyChanged;
end;

function TPinSelectionModel.Count: integer;
begin
  Result := FSelectedPins.Count;
end;

function TPinSelectionModel.GetPin(Index: integer): TNodePin;
begin
  if (Index >= 0) and (Index < FSelectedPins.Count) then
    Result := FSelectedPins[Index]
  else
    Result := nil;
end;

function TPinSelectionModel.Contains(APin: TNodePin): boolean;
begin
  Result := FSelectedPins.IndexOf(APin) >= 0;
end;

end.

