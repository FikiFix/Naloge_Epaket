object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object LoadButton: TButton
    Left = 24
    Top = 215
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
    OnClick = LoadButtonClick
  end
  object DisplayMemo: TMemo
    Left = 24
    Top = 32
    Width = 569
    Height = 177
    Lines.Strings = (
      'DisplayMemo')
    TabOrder = 1
  end
end
