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
  object SearchMemo: TMemo
    Left = 8
    Top = 120
    Width = 185
    Height = 89
    Lines.Strings = (
      'SearchMemo')
    TabOrder = 0
  end
  object ResoultMemo: TMemo
    Left = 224
    Top = 120
    Width = 185
    Height = 89
    Lines.Strings = (
      'ResoultMemo')
    TabOrder = 1
  end
  object SearchButton: TButton
    Left = 8
    Top = 232
    Width = 75
    Height = 25
    Caption = 'SearchButton'
    TabOrder = 2
    OnClick = SearchButtonClick
  end
  object SaveButton: TButton
    Left = 224
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    OnClick = SaveButtonClick
  end
end
