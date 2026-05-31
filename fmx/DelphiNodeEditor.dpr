program DelphiNodeEditor;

uses
  System.StartUpCopy,
  FMX.Forms,
  {$IF DEFINED(ANDROID) or DEFINED(IOS)}
  FMX.Skia,
  {$ENDIF}
  FMX.Skia,
  FMX.Types,
  NodeEditor.Main in 'NodeEditor.Main.pas' {FormMain},
  FMX.NodeEditor in '..\src\FMX.NodeEditor.pas',
  FMX.NodeEditor.Form.Search in '..\src\FMX.NodeEditor.Form.Search.pas' {FormNodeEditorSearch},
  FMX.NodeEditor.Node in '..\src\FMX.NodeEditor.Node.pas',
  FMX.NodeEditor.Node.Defaults in '..\src\FMX.NodeEditor.Node.Defaults.pas',
  FMX.NodeEditor.Node.Command in '..\src\FMX.NodeEditor.Node.Command.pas',
  FMX.NodeEditor.Node.Graph in '..\src\FMX.NodeEditor.Node.Graph.pas',
  FMX.NodeEditor.JSON in '..\src\FMX.NodeEditor.JSON.pas',
  FMX.NodeEditor.Types in '..\src\FMX.NodeEditor.Types.pas',
  FMX.NodeEditor.Controller in '..\src\FMX.NodeEditor.Controller.pas',
  FMX.NodeEditor.DAG in '..\src\FMX.NodeEditor.DAG.pas',
  FMX.NodeEditor.Selection in '..\src\FMX.NodeEditor.Selection.pas',
  WinUI3.Frame.Dialog.Text in '..\DelphiWinUI3\Sources\WinUI3.Frame.Dialog.Text.pas',
  WinUI3.Frame.Inner.Dialog in '..\DelphiWinUI3\Sources\WinUI3.Frame.Inner.Dialog.pas',
  WinUI3.Frame.Inner.InfoBar in '..\DelphiWinUI3\Sources\WinUI3.Frame.Inner.InfoBar.pas',
  WinUI3.Style in '..\DelphiWinUI3\Sources\WinUI3.Style.pas',
  WinUI3.Utils in '..\DelphiWinUI3\Sources\WinUI3.Utils.pas',
  HGM.ColorUtils in '..\DelphiWinUI3\Sources\HGM.ColorUtils.pas',
  WinUI3.Dialogs.DataTransferManager in '..\DelphiWinUI3\Sources\WinUI3.Dialogs.DataTransferManager.pas',
  WinUI3.Dialogs in '..\DelphiWinUI3\Sources\WinUI3.Dialogs.pas',
  WinUI3.Form.Dialog in '..\DelphiWinUI3\Sources\WinUI3.Form.Dialog.pas',
  WinUI3.Form in '..\DelphiWinUI3\Sources\WinUI3.Form.pas',
  WinUI3.Frame.Dialog.ColorPicker in '..\DelphiWinUI3\Sources\WinUI3.Frame.Dialog.ColorPicker.pas',
  WinUI3.Frame.Dialog.Font in '..\DelphiWinUI3\Sources\WinUI3.Frame.Dialog.Font.pas',
  WinUI3.Frame.Dialog.Input in '..\DelphiWinUI3\Sources\WinUI3.Frame.Dialog.Input.pas',
  WinUI3.Frame.Dialog in '..\DelphiWinUI3\Sources\WinUI3.Frame.Dialog.pas',
  FMX.StyledContextMenu in '..\DelphiWinUI3\Fixes\D13\FMX.StyledContextMenu.pas',
  FMX.Menus in '..\DelphiWinUI3\Fixes\D13\FMX.Menus.pas',
  {$IFDEF MSWINDOWS}
  DelphiWindowStyle.Core.Win in '..\DelphiWinUI3\DelphiWindowStyle\DelphiWindowStyle.Core.Win.pas',
  FMX.Platform.Win in '..\DelphiWinUI3\Fixes\D13\FMX.Platform.Win.pas',
  FMX.Windows.Dispatch in '..\DelphiWinUI3\FMXWindowsDispatch\FMX.Windows.Dispatch.pas',
  {$ENDIF }
  DelphiWindowStyle.FMX in '..\DelphiWinUI3\DelphiWindowStyle\DelphiWindowStyle.FMX.pas',
  DelphiWindowStyle.Types in '..\DelphiWinUI3\DelphiWindowStyle\DelphiWindowStyle.Types.pas',
  FMX.Windows.Hints in '..\DelphiWinUI3\FMXWindowsHint\FMX.Windows.Hints.pas';

{$R *.res}

type
  TCanvasType = (GDI, DirectX11, DirectX9, Direct2D, SkiaOpenGL, SkiaVulkan);

var
  CanvasType: TCanvasType = TCanvasType.Direct2D;

begin
  {$IF DEFINED(ANDROID) or DEFINED(IOS)}
  GlobalUseSkia := True;
  {$ENDIF}

  case CanvasType of
    TCanvasType.GDI:
      begin
        GlobalUseGDIPlusClearType := True;

        GlobalUseDirect2D := False;
        GlobalUseGPUCanvas := False;
        GlobalUseDX := True;
      end;
    TCanvasType.DirectX11:
      begin
        GlobalUseDirect2D := False;
        GlobalUseGPUCanvas := True;
        GlobalUseDX := True;
      end;
    TCanvasType.DirectX9:
      begin
        GlobalUseDirect2D := False;
        GlobalUseGPUCanvas := True;
        GlobalUseDX := False;
      end;
    TCanvasType.Direct2D:
      begin
        GlobalUseDirect2D := True;
        GlobalUseGPUCanvas := False;
        GlobalUseDX := True;
      end;
    TCanvasType.SkiaOpenGL:
      begin
        GlobalUseSkia := True;
        GlobalUseVulkan := False;
        GlobalUseSkiaRasterWhenAvailable := False;
      end;
    TCanvasType.SkiaVulkan:
      begin
        GlobalUseSkia := True;
        GlobalUseVulkan := True;
        GlobalUseSkiaRasterWhenAvailable := False;
      end;
  end;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

