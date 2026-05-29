unit FMX.NodeEditor.Form.Search;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.NodeEditor, System.Actions, FMX.ActnList,
  FMX.Controls.Presentation, FMX.Edit, FMX.SearchBox, FMX.NodeEditor.Node.Graph;

type
  TFormNodeEditorSearch = class(TForm)
    ListBoxItems: TListBox;
    ActionList: TActionList;
    ActionEsc: TAction;
    SearchBoxFilter: TSearchBox;
    procedure ListBoxItemsDblClick(Sender: TObject);
    procedure ActionEscExecute(Sender: TObject);
  private
    FRegistry: TNodeRegistry;
    procedure FillList;
  public
    SelectedNodeType: string;
    constructor CreateSearch(AOwner: TComponent; ARegistry: TNodeRegistry); reintroduce;
  end;

var
  FormNodeEditorSearch: TFormNodeEditorSearch;

implementation

{$R *.fmx}

{ TFormNodeEditorSearch }

procedure TFormNodeEditorSearch.ActionEscExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

constructor TFormNodeEditorSearch.CreateSearch(AOwner: TComponent; ARegistry: TNodeRegistry);
begin
  inherited Create(AOwner);
  StyleBook := Application.MainForm.StyleBook;
  FRegistry := ARegistry;
  SelectedNodeType := '';
  FillList;
end;

procedure TFormNodeEditorSearch.FillList;
begin
  ListBoxItems.Items.BeginUpdate;
  try
    ListBoxItems.Items.Clear;

    for var Item in FRegistry do
      ListBoxItems.Items.AddObject(Item.Caption + ' [' + Item.NodeType + ']', Item);

    if ListBoxItems.Items.Count > 0 then
      ListBoxItems.ItemIndex := 0;
  finally
    ListBoxItems.Items.EndUpdate;
  end;
end;

procedure TFormNodeEditorSearch.ListBoxItemsDblClick(Sender: TObject);
var
  It: TNodeRegistryItem;
begin
  if ListBoxItems.ItemIndex < 0 then
    Exit;

  It := TNodeRegistryItem(ListBoxItems.Items.Objects[ListBoxItems.ItemIndex]);
  if It = nil then
    Exit;

  SelectedNodeType := It.NodeType;
  ModalResult := mrOk;
end;

end.

