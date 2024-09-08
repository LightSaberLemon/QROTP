//License: MIT

unit QROTPMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus, ExtDlgs, Buttons;

type

  { TfrmQROTPMain }

  TfrmQROTPMain = class(TForm)
    btnCompute: TButton;
    cmbDigits: TComboBox;
    imgQR: TImage;
    lblCharCount: TLabel;
    lblFive: TLabel;
    lbeDecoded: TLabeledEdit;
    lbeResult: TLabeledEdit;
    lbeSecretKeyword: TLabeledEdit;
    lblDigits: TLabel;
    memLog: TMemo;
    MenuItem_LoadFromClipboard: TMenuItem;
    MenuItem_Separator2: TMenuItem;
    MenuItem_SaveToFile: TMenuItem;
    MenuItem_LoadFromFile: TMenuItem;
    MenuItem_Separator1: TMenuItem;
    MenuItem_ClearQR: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    pnlImg: TPanel;
    pmQR: TPopupMenu;
    pnlKeyboard: TPanel;
    SavePictureDialog1: TSavePictureDialog;
    procedure btnComputeClick(Sender: TObject);
    procedure btnLoadFromClipboardClick(Sender: TObject);
    procedure cmbDigitsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem_ClearQRClick(Sender: TObject);
    procedure MenuItem_LoadFromFileClick(Sender: TObject);
    procedure MenuItem_SaveToFileClick(Sender: TObject);
  private
    procedure WipeQRImg;
    procedure DisplayFiveWarning;
    procedure DecodeQRString;

    procedure KeyHandler(Sender: TObject);
    procedure CreateButton(x, y: Integer; ACaption: Char);
  public

  end;

var
  frmQROTPMain: TfrmQROTPMain;

implementation

{$R *.frm}

uses
  ZXing.ScanManager, ZXing.ReadResult, ZXing.BarCodeFormat,
  Clipbrd, GoogleOTP, StrUtils;

const
  CRow1: array[0..9] of Char = ('Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P');
  CRow2: array[0..8] of Char = ('A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L');
  CRow3: array[0..6] of Char = ('Z', 'X', 'C', 'V', 'B', 'N', 'M');

{ TfrmQROTPMain }


function QRBmpToString(ABmp: TBitmap): string;
var
  ScanMgr: TScanManager;
  ReadRes: TReadResult;
begin
  ScanMgr := TScanManager.Create(TBarcodeFormat.Auto, nil);
  try
    ReadRes := ScanMgr.Scan(ABmp);
    if ReadRes = nil then
      Result := 'Cannot decode QR'
    else
    begin
      Result := ReadRes.text;
      ReadRes.Free;
    end;
  finally
    ScanMgr.Free;
  end;
end;


procedure TfrmQROTPMain.WipeQRImg;
begin
  imgQR.Picture.Bitmap.PixelFormat := pf24bit;
  imgQR.Picture.Bitmap.Width := imgQR.Width;
  imgQR.Picture.Bitmap.Height := imgQR.Height;

  imgQR.Picture.Bitmap.Canvas.Pen.Color := clWhite;
  imgQR.Picture.Bitmap.Canvas.Brush.Color := clWhite;
  imgQR.Picture.Bitmap.Canvas.Rectangle(0, 0, imgQR.Width, imgQR.Height);
end;


procedure TfrmQROTPMain.DisplayFiveWarning;
var
  Content: TStringList;
  s: string;
  Idx: Integer;
begin
  Content := TStringList.Create;
  try
    s := memLog.Lines.Text;

    if Pos('?', s) = 0 then
      Exit;

    s := Copy(s, Pos('?', s) + 1, MaxInt);
    Content.Text := StringReplace(s, '&', #13#10, [rfReplaceAll]);

    Idx := cmbDigits.ItemIndex;
    lblFive.Visible := (Content.Values['issuer'] = 'Yahoo') and (cmbDigits.Items.Strings[Idx] = '6');
  finally
    Content.Free;
  end;
end;


procedure TfrmQROTPMain.DecodeQRString;
var
  Content: TStringList;
  s: string;
begin
  Content := TStringList.Create;
  try
    s := memLog.Lines.Text;

    if Pos('?', s) = 0 then
      lbeDecoded.Text := s
    else
    begin
      s := Copy(s, Pos('?', s) + 1, MaxInt);
      Content.Text := StringReplace(s, '&', #13#10, [rfReplaceAll]);
      lbeDecoded.Text := Content.Values[lbeSecretKeyword.Text];

      DisplayFiveWarning;
    end;
  finally
    Content.Free;
  end;

  lblCharCount.Caption := IntToStr(Length(lbeDecoded.Text));
  lblCharCount.Hint := lblCharCount.Caption + ' character(s).';
end;


procedure TfrmQROTPMain.btnLoadFromClipboardClick(Sender: TObject);
begin
  if Clipboard.HasPictureFormat then
  begin
    WipeQRImg;

    imgQR.Picture.LoadFromClipboardFormat(Clipboard.FindPictureFormatID);
    memLog.Lines.Text := QRBmpToString(imgQR.Picture.Bitmap);
    DecodeQRString;
  end
  else
  begin
    MessageBoxFunction('Unknown clipboard format.', PChar(Application.Title), 0);
    lbeDecoded.Text := '';
    memLog.Clear;
  end;
end;


procedure TfrmQROTPMain.cmbDigitsChange(Sender: TObject);
begin
  DisplayFiveWarning;
end;


procedure TfrmQROTPMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to 9 do
    CreateButton(i * 30 + 10, 10, Chr(48 + i));

  for i := 0 to 9 do
    CreateButton(i * 30 + 10 + 15, 40, CRow1[i]);

  for i := 0 to 8 do
    CreateButton(i * 30 + 10 + 15 + 5, 70, CRow2[i]);

  for i := 0 to 6 do
    CreateButton(i * 30 + 10 + 15 + 10, 100, CRow3[i]);
end;


procedure TfrmQROTPMain.MenuItem_ClearQRClick(Sender: TObject);
begin
  imgQR.Picture.Bitmap.Clear;
  lbeDecoded.Text := '';
  memLog.Clear;
end;


procedure TfrmQROTPMain.MenuItem_LoadFromFileClick(Sender: TObject);
var
  TempBmp: TBitmap;
  TempPng: TPNGImage;
  TempJpg: TJPEGImage;
  Fnm: string;
begin
  if not OpenPictureDialog1.Execute then
    Exit;

  Fnm := OpenPictureDialog1.FileName;

  TempBmp := TBitmap.Create;
  TempPng := TPNGImage.Create;
  TempJpg := TJPEGImage.Create;
  try
    WipeQRImg;
    if UpperCase(ExtractFileExt(Fnm)) = '.BMP' then
      imgQR.Picture.LoadFromFile(Fnm)
    else
      if UpperCase(ExtractFileExt(Fnm)) = '.PNG' then
      begin
        TempPng.LoadFromFile(Fnm);
        TempBmp.Assign(TempPng);
        imgQR.Picture.Assign(TempBmp);
      end
      else
        if (UpperCase(ExtractFileExt(Fnm)) = '.JPG') or (UpperCase(ExtractFileExt(Fnm)) = '.JPEG') then
        begin
          TempJpg.LoadFromFile(Fnm);
          TempBmp.Assign(TempJpg);
          imgQR.Picture.Assign(TempBmp);
        end
        else
        begin
          memLog.Lines.Text := 'Unsupported image format.';
          lbeDecoded.Text := '';
          memLog.Clear;
        end;

    memLog.Lines.Text := QRBmpToString(imgQR.Picture.Bitmap);
    DecodeQRString;
  finally
    TempBmp.Free;
    TempPng.Free;
    TempJpg.Free;
  end;
end;


procedure TfrmQROTPMain.MenuItem_SaveToFileClick(Sender: TObject);
begin
  if not SavePictureDialog1.Execute then
    Exit;

  imgQR.Picture.Bitmap.SaveToFile(SavePictureDialog1.FileName);
end;


procedure TfrmQROTPMain.KeyHandler(Sender: TObject);
begin
  lbeDecoded.Text := lbeDecoded.Text + (Sender as TSpeedButton).Caption;
end;


procedure TfrmQROTPMain.CreateButton(x, y: Integer; ACaption: Char);
var
  btn: TSpeedButton;
begin
  btn := TSpeedButton.Create(Self);
  btn.Parent := pnlKeyboard;
  btn.Left := x;
  btn.Top := y;
  btn.Width := 24;
  btn.Height := 24;
  btn.Caption := ACaption;
  btn.Visible := True;
  btn.OnClick := @KeyHandler;
end;


procedure TfrmQROTPMain.btnComputeClick(Sender: TObject);
var
  Digits: Integer;
begin
  Digits := StrToIntDef(cmbDigits.Items.Strings[cmbDigits.ItemIndex], 6);
  lbeResult.Text := AddChar('0', IntToStr(CalculateTOTP(lbeDecoded.Text, -1, Digits)), {6} Digits);
  DisplayFiveWarning;
end;

end.

