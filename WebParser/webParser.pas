unit webParser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdURI, System.NetEncoding,
  System.IOUtils;

type
  TForm2 = class(TForm)
    SearchMemo: TMemo;
    ResoultMemo: TMemo;
    SearchButton: TButton;
    SaveButton: TButton;
    procedure SearchButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses
  IdHTTP, IdSSLOpenSSL, System.RegularExpressions;

const
  cUSER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

function NormalizeString(const inputStr: string): string;
var
  words: TArray<string>;
  i: Integer;
  outputList: TStringList;
  numRegex: TRegEx;
begin
  outputList := TStringList.Create;
  try
    words := inputStr.Split([',']);
    numRegex := TRegEx.Create('^\s*\d+\s*$');

    i := 0;
    while i < Length(words) do
    begin
      words[i] := Trim(words[i]);
      outputList.Add(words[i]);

    //�e naslednji in trenutni nista numeric dodaj 1

    //var isNotNum1 := not numRegex.IsMatch(words[i + 1]); sme�n delphi :(
    var isNotNum2 := not numRegex.IsMatch(words[i]);
    if (i + 1 >= Length(words)) or ((not numRegex.IsMatch(words[i + 1])) and (isNotNum2)) then
      outputList.Add('1');

      Inc(i);
    end;

    outputList.Delimiter := ',';
    outputList.StrictDelimiter := True;
    Result := outputList.DelimitedText;


  finally
    outputList.Free;
  end;
end;

function GetFilteredLinks(const buffer: string): TStringList;
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  request, response, domain: string;
  strList1, strList2: TStringList;
  urlRegex, w3Regex, bingRegex, filterRegex: TRegEx;
  Match: TMatch;
  i: Integer;
  validUrl: Boolean;
  bingMatch, w3Match: Boolean;
  domainExists: Boolean;
begin
  Result := TStringList.Create;
  strList1 := TStringList.Create;
  strList2 := TStringList.Create;

  try
    // HTTP SSL init
    HTTP := TIdHTTP.Create(nil);
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    HTTP.Request.UserAgent := cUSER_AGENT;
    HTTP.IOHandler := SSLHandler;
    HTTP.HandleRedirects := True;
    SSLHandler.SSLOptions.Method := sslvTLSv1_2;

    request := 'https://www.bing.com/search?q=' + TNetEncoding.URL.Encode(buffer);
    response := HTTP.Get(request);

    // Regex definicije
    urlRegex := TRegEx.Create('https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    w3Regex := TRegEx.Create('\bhttps?:\/\/www\.w3\.org\b');
    bingRegex := TRegEx.Create('\bbing\.com\b');
    filterRegex := TRegEx.Create('^(https?:\/\/[^\/]+)');

    //Korak 1: poi��emo url-je
    for Match in urlRegex.Matches(response) do
      strList1.Add(Match.Value);

    //Korak 2: pofiltriramo "sistemske" url od binga
    //2.1: presko�imo useless linke
    i := 4;
    validUrl := False;
    while (i < strList1.Count) and (not validUrl) do
    begin
      bingMatch := bingRegex.IsMatch(strList1[i]);
      w3Match := w3Regex.IsMatch(strList1[i]);
      if not (bingMatch or w3Match) then
      begin
        validUrl := True;
        Break;
      end;
      Inc(i);
    end;

    // 2.2: poberemo vredu linke
    while (i < strList1.Count) and not (bingRegex.IsMatch(strList1[i])) do
    begin
      strList2.Add(strList1[i]);
      Inc(i);
    end;

    // 3: filtriramo url-je z isto domeno
    strList1.Clear;
    if strList2.Count = 0 then
    begin
      Result.Add('No valid links found.');
      Exit;
    end;

    strList1.Add(filterRegex.Match(strList2[0]).Value);
    for i := 0 to strList2.Count - 1 do
    begin
      domain := filterRegex.Match(strList2[i]).Value;
      domainExists := False;

      for var j := 0 to strList1.Count - 1 do
      begin
        if strList1[j] = domain then
        begin
          domainExists := True;
          Break;
        end;
      end;
      if not domainExists then
        strList1.Add(domain);
    end;

    Result.Assign(strList1);
  finally
    HTTP.Free;
    SSLHandler.Free;
    strList1.Free;
    strList2.Free;
  end;
end;

{$R *.dfm}


procedure TForm2.SaveButtonClick(Sender: TObject);
var
  FileStream: TFileStream;
  SaveDialog: TSaveDialog;
  text: string;
  len: Integer;
begin
  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.Filter := 'Text Files|*.txt';
    SaveDialog.DefaultExt := 'txt';
    SaveDialog.Options := [ofOverwritePrompt, ofHideReadOnly];

    if SaveDialog.Execute then
    begin
      FileStream := TFileStream.Create(SaveDialog.FileName, fmCreate);
      try
        ResoultMemo.Lines.Delimiter := ',';
        text := ResoultMemo.Lines.DelimitedText;
        len := Length(text) * SizeOf(char);

        FileStream.Write(Pointer(text)^, len);
      finally
        FileStream.Free;
      end;
    end;
  finally
    SaveDialog.Free;
  end;
end;


procedure TForm2.SearchButtonClick(Sender: TObject);
var
  inputText: string;
  filteredLinks: TStringList;
  numberRegex : TRegEx;
  wordRegex : TRegEx;
  wordList : TStringList;
  numberList : TStringList;
  match: TMatch;
  i : Integer;

  linkBuffer : TStringList;

begin
  numberRegex := TRegEx.Create('\d+');
  wordRegex := TRegEx.Create('\b[A-Za-z蚞Ȋ�]+(?=,)');

  wordList := TStringList.Create;
  numberList := TStringList.Create;
  filteredLinks := TStringList.Create;
  inputText := NormalizeString(SearchMemo.Text);
  try
    for match in wordRegex.Matches(inputText) do
    begin
      wordList.Add(match.Value);
    end;

    for match in numberRegex.Matches(inputText) do
    begin
      numberList.Add(match.Value);
    end;


    for i := 0 to wordList.Count - 1 do
    begin
      var index := StrToInt(numberList[i]);
      var word := wordList[i];
      linkBuffer := GetFilteredLinks(word);
      filteredLinks.Add(linkBuffer[index]);
    end;


    ResoultMemo.Lines := filteredLinks;

  finally

    filteredLinks.Free;
    wordList.Free;
    numberList.Free;
  end;

end;

end.

