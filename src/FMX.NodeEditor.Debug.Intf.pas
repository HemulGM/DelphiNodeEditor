unit FMX.NodeEditor.Debug.Intf;

interface

uses
  System.Classes, System.SysUtils, System.Rtti, FMX.NodeEditor.Types,
  FMX.NodeEditor.Node;

type
  INodeExecutionContext = interface
    ['{D1F0D7A1-8D62-4D8A-8D74-2B2C537D0A11}']
    function GetStepCounter: Integer;
    function GetVariableValue(const AName: string): TValue;
    property StepCounter: Integer read GetStepCounter;
  end;

  IDebugBreakpoint = interface
    ['{00D5E5A1-BD49-4D05-AB2B-26D7475F7B12}']
    function GetNode: TCustomNode;
    function GetPin: TNodePin;
    function GetEnabled: Boolean;
    function GetHitCount: Integer;
    function GetCondition: string;
    procedure SetEnabled(AValue: Boolean);
    procedure SetHitCount(AValue: Integer);
    procedure SetCondition(const AValue: string);
    property Node: TCustomNode read GetNode;
    property Pin: TNodePin read GetPin;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property HitCount: Integer read GetHitCount write SetHitCount;
    property Condition: string read GetCondition write SetCondition;
  end;

  TDebuggerPauseEvent = procedure(ANode: TCustomNode; APin: TNodePin; const AContext: INodeExecutionContext) of object;

  IGraphDebugger = interface
    ['{A4386D75-84E4-43D5-8D1D-13A4CB2F5E13}']
    procedure ResetSession;
    procedure AddTraceEntry(const AEventKind: string; ANode: TCustomNode; APin: TNodePin = nil; const AContext: INodeExecutionContext = nil);
    procedure PushNode(ANode: TCustomNode);
    procedure PopNode(ANode: TCustomNode = nil);
    procedure ClearExecutionStack;
    procedure Pause;
    procedure &Continue;
    procedure StepOver;
    procedure StepInto;
    function CheckPause(ANode: TCustomNode; APin: TNodePin = nil; const AContext: INodeExecutionContext = nil): Boolean;
  end;

implementation

end.

