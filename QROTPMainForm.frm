object frmQROTPMain: TfrmQROTPMain
  Left = 373
  Height = 554
  Top = 185
  Width = 535
  Caption = 'QR OTP'
  ClientHeight = 554
  ClientWidth = 535
  LCLVersion = '8.4'
  OnCreate = FormCreate
  object pnlImg: TPanel
    Left = 8
    Height = 433
    Top = 152
    Width = 432
    Caption = 'Right-click to load QR'
    ClientHeight = 433
    ClientWidth = 432
    Color = clYellow
    ParentBackground = False
    ParentColor = False
    TabOrder = 0
    object imgQR: TImage
      Left = 8
      Height = 416
      Top = 8
      Width = 416
      PopupMenu = pmQR
    end
  end
  object memLog: TMemo
    Left = 16
    Height = 96
    Top = 48
    Width = 176
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object lbeSecretKeyword: TLabeledEdit
    Left = 16
    Height = 23
    Hint = 'Used for decoding'
    Top = 17
    Width = 80
    EditLabel.Height = 15
    EditLabel.Width = 80
    EditLabel.Caption = 'Secret keyword'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    Text = 'secret'
  end
  object lbeDecoded: TLabeledEdit
    Left = 104
    Height = 23
    Top = 17
    Width = 88
    EditLabel.Height = 15
    EditLabel.Width = 88
    EditLabel.Caption = 'Decoded'
    TabOrder = 3
    Text = 'Decoded'
  end
  object pnlKeyboard: TPanel
    Left = 200
    Height = 136
    Top = 8
    Width = 328
    TabOrder = 4
  end
  object cmbDigits: TComboBox
    Left = 448
    Height = 21
    Top = 176
    Width = 52
    ItemHeight = 15
    ItemIndex = 1
    Items.Strings = (
      '5'
      '6'
    )
    Style = csOwnerDrawFixed
    TabOrder = 5
    Text = '6'
    OnChange = cmbDigitsChange
  end
  object lblDigits: TLabel
    Left = 448
    Height = 15
    Top = 152
    Width = 33
    Caption = 'Digits:'
  end
  object lbeResult: TLabeledEdit
    Left = 448
    Height = 23
    Top = 272
    Width = 80
    EditLabel.Height = 15
    EditLabel.Width = 80
    EditLabel.Caption = 'Result'
    ReadOnly = True
    TabOrder = 6
  end
  object btnCompute: TButton
    Left = 448
    Height = 25
    Top = 224
    Width = 78
    Caption = 'Compute'
    TabOrder = 7
    OnClick = btnComputeClick
  end
  object lblFive: TLabel
    Left = 504
    Height = 20
    Hint = 'Yahoo may use 5 digits.'
    Top = 176
    Width = 16
    Caption = '5?'
    Font.Color = clRed
    Font.Height = -15
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    Visible = False
  end
  object lblCharCount: TLabel
    Left = 174
    Height = 15
    Top = 0
    Width = 12
    Caption = '00'
    ParentShowHint = False
    ShowHint = True
  end
  object pmQR: TPopupMenu
    Left = 230
    Top = 198
    object MenuItem_ClearQR: TMenuItem
      Caption = 'Clear QR'
      OnClick = MenuItem_ClearQRClick
    end
    object MenuItem_Separator1: TMenuItem
      Caption = '-'
    end
    object MenuItem_LoadFromFile: TMenuItem
      Caption = 'Load from file...'
      OnClick = MenuItem_LoadFromFileClick
    end
    object MenuItem_SaveToFile: TMenuItem
      Caption = 'Save to file...'
      OnClick = MenuItem_SaveToFileClick
    end
    object MenuItem_Separator2: TMenuItem
      Caption = '-'
    end
    object MenuItem_LoadFromClipboard: TMenuItem
      Caption = 'Load from clipboard'
      OnClick = btnLoadFromClipboardClick
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 328
    Top = 200
  end
  object SavePictureDialog1: TSavePictureDialog
    Left = 328
    Top = 264
  end
end
