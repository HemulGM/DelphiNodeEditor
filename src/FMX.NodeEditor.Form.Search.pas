unit FMX.NodeEditor.Form.Search;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.NodeEditor, System.Actions, FMX.ActnList,
  FMX.Controls.Presentation, FMX.Edit, FMX.SearchBox, FMX.NodeEditor.Node.Graph,
  WinUI3.Form, FMX.StdCtrls;

type
  TFormNodeEditorSearch = class(TWinUIForm)
    ListBoxItems: TListBox;
    ActionList: TActionList;
    ActionEsc: TAction;
    SearchBoxFilter: TSearchBox;
    Layout28: TLayout;
    Layout9: TLayout;
    PathLabel20: TPathLabel;
    Label8: TLabel;
    Label10: TLabel;
    procedure ListBoxItemsDblClick(Sender: TObject);
    procedure ActionEscExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FRegistry: TNodeRegistry;
    procedure FillList;
  protected
    procedure DoOnSettingChange; override;
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

procedure TFormNodeEditorSearch.DoOnSettingChange;
begin
  inherited;
end;

procedure TFormNodeEditorSearch.FillList;
begin
  ListBoxItems.Items.BeginUpdate;
  try
    ListBoxItems.Items.Clear;

    for var Item in FRegistry do
    begin
      var ListItem := TListBoxItem.Create(ListBoxItems);
      ListItem.TagString := Item.NodeType;
      ListItem.Text := Item.Caption + ' [' + Item.NodeType + ']';
      ListItem.ItemData.Detail := Item.Description;
      ListBoxItems.AddObject(ListItem);
    end;

    if ListBoxItems.Items.Count > 0 then
      ListBoxItems.ItemIndex := 0;
  finally
    ListBoxItems.Items.EndUpdate;
  end;
end;

procedure TFormNodeEditorSearch.FormShow(Sender: TObject);
begin
  DoOnSettingChange;
  SearchBoxFilter.SetFocus;
end;

procedure TFormNodeEditorSearch.ListBoxItemsDblClick(Sender: TObject);
begin
  if ListBoxItems.Selected = nil then
    Exit;

  SelectedNodeType := ListBoxItems.Selected.TagString;
  ModalResult := mrOk;
end;

end.

