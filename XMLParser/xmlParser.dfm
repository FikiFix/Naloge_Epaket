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
    Left = 48
    Top = 215
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
    OnClick = LoadButtonClick
  end
  object DisplayMemo: TMemo
    Left = 48
    Top = 40
    Width = 568
    Height = 169
    Lines.Strings = (
      'DisplayMemo')
    TabOrder = 1
  end
end
