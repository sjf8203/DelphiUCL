unit UCL.CaptionBar;

interface

uses
  Classes, Windows, Messages, Controls, ExtCtrls, Forms, Graphics,
  UCL.Classes, UCL.ThemeManager, UCL.Utils, UCL.Colors, UCL.Form;

type
  TUCaptionBar = class(TPanel, IUControl)
    private
      FCustomBackColor: TUThemeColorSet;

      FDragToMove: Boolean;
      FSystemMenuEnabled: Boolean;

      //  Child events
      procedure CustomBackColor_OnChange(Sender: TObject);

      //  Messages
      procedure WM_LButtonDblClk(var Msg: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
      procedure WM_LButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
      procedure WM_RButtonUp(var Msg: TMessage); message WM_RBUTTONUP;
      procedure WM_NCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      //  Interface
      function IsContainer: Boolean;
      procedure UpdateTheme(const UpdateChildren: Boolean = true);

    published
      property CustomBackColor: TUThemeColorSet read FCustomBackColor write FCustomBackColor;

      property DragToMove: Boolean read FDragToMove write FDragToMove default true;
      property SystemMenuEnabled: Boolean read FSystemMenuEnabled write FSystemMenuEnabled default true;

      //  Modify default value
      property Align default alTop;
      property Alignment default taLeftJustify;
      property BevelOuter default bvNone;
      property Height default 32;
  end;

implementation

{ TUCaptionBar }

//  INTERFACE

function TUCaptionBar.IsContainer: Boolean;
begin
  Result := true;
end;

procedure TUCaptionBar.UpdateTheme(const UpdateChildren: Boolean);
var
  ParentForm: TCustomForm;
  TM: TUThemeManager;
  _BackColor: TUThemeColorSet;
begin
  //  Select style
  ParentForm := GetParentForm(Self, true);
  if ParentForm is TUForm then
    TM := (ParentForm as TUForm).ThemeManager
  else
    TM := nil;

  if (TM = nil) or (CustomBackColor.Enabled) then
    _BackColor := CustomBackColor
  else
    _BackColor := CAPTIONBAR_BACK;

  Color := _BackColor.GetColor(TM);
  Font.Color := GetTextColorFromBackground(Color);
end;

//  CHILD EVENTS

procedure TUCaptionBar.CustomBackColor_OnChange(Sender: TObject);
begin
  UpdateTheme(true);
end;

//  MAIN CLASS

constructor TUCaptionBar.Create(aOwner: TComponent);
begin
  inherited;
  FDragToMove := true;
  FSystemMenuEnabled := true;

  FCustomBackColor := TUThemeColorSet.Create;
  FCustomBackColor.OnChange := CustomBackColor_OnChange;
  FCustomBackColor.Assign(CAPTIONBAR_BACK);

  //  Default props
  Align := alTop;
  Alignment := taLeftJustify;
  Caption := '   Caption bar';
  BevelOuter := bvNone;
  Height := 32;
end;

destructor TUCaptionBar.Destroy;
begin
  FCustomBackColor.Free;
  inherited;
end;

//  MESSAGE

procedure TUCaptionBar.WM_LButtonDblClk(var Msg: TWMLButtonDblClk);
var
  ParentForm: TCustomForm;
begin
  inherited;

  ParentForm := GetParentForm(Self, true);
  if ParentForm is TForm then
    if biMaximize in (ParentForm as TForm).BorderIcons then
      begin
        if ParentForm.WindowState = wsMaximized then
          ParentForm.WindowState := wsNormal
        else if ParentForm.WindowState = wsNormal then
          ParentForm.WindowState := wsMaximized;
      end;
end;

procedure TUCaptionBar.WM_LButtonDown(var Msg: TWMLButtonDown);
begin
  inherited;
  if DragToMove then
    begin
      ReleaseCapture;
      Parent.Perform(WM_SYSCOMMAND, $F012, 0);
    end;
end;

procedure TUCaptionBar.WM_RButtonUp(var Msg: TMessage);
const
  WM_SYSMENU = 787;
var
  P: TPoint;
begin
  inherited;
  if SystemMenuEnabled then
    begin
      P.X := Msg.LParamLo;
      P.Y := Msg.LParamHi;
      P := ClientToScreen(P);
      Msg.LParamLo := P.X;
      Msg.LParamHi := P.Y;
      PostMessage(Parent.Handle, WM_SYSMENU, 0, Msg.LParam);
    end;
end;

procedure TUCaptionBar.WM_NCHitTest(var Msg: TWMNCHitTest);
var
  P: TPoint;
  ParentForm: TCustomForm;
begin
  inherited;

  ParentForm := GetParentForm(Self, true);
  if (ParentForm.WindowState = wsNormal) and (Align = alTop) then
    begin
      P := Point(Msg.Pos.x, Msg.Pos.y);
      P := ScreenToClient(P);
      if P.Y < 5 then
        Msg.Result := HTTRANSPARENT;  //  Send event to parent
    end;
end;

end.