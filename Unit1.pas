unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPClient, IdSNTP, DateUtils, TZDB;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    IdSNTP1: TIdSNTP;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    GroupBox2: TGroupBox;
    Button4: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button6: TButton;
    Button8: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
    function IntToStrZero(const NumInteiro : Int64; Tamanho : Integer) : AnsiString;
    function StrLeft(T: string; Tamanho: Integer; C: string): AnsiString;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  s: string;
  d: dword;
  st: SYSTEMTIME;
  tz: TIME_ZONE_INFORMATION;
  GMTTime, DataHoraAtual: TDateTime;
  TimeZone: TTimeZone;
  wAno, wMes, wDia, wHor, wMin, wSeg, wMil: word;

implementation

{$R *.dfm}

function TForm1.StrLeft(T: string; Tamanho: Integer; C: string): AnsiString;
var i: Integer;
begin
  t := trim(t);
  Tamanho := Tamanho - Length(t);
  for i := 1 to Tamanho do
     t := c + t;
  Result := t;
end;

function TForm1.IntToStrZero(const NumInteiro: Int64; Tamanho: Integer): AnsiString ;
begin
  Result := '' ;
  try
     Result := AnsiString(IntToStr( NumInteiro )) ;
     Result := StrLeft(Result, Tamanho, '0') ;
  except
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   // returns current UTC (GMT) time.
   GetSystemTime(st);

   s := format('%2d/%2d/%4d %2d:%2d:%2d.%3d',
     [st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds]);

   DecodeDate(StrToDateTime(s), st.wYear, st.wMonth, st.wDay);
   DecodeTime(StrToDateTime(s), st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);

   s := IntToStrZero(st.wDay,    2) + '/' +
        IntToStrZero(st.wMonth,  2) + '/' +
        IntToStrZero(st.wYear,   4) + ' ' +
        IntToStrZero(st.wHour,   2) + ':' +
        IntToStrZero(st.wMinute, 2) + ':' +
        IntToStrZero(st.wSecond, 2) + '.' +
        IntToStrZero(st.wMilliseconds, 3);

   Memo1.Lines.Add('UTC Time: ' + s);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   // returns local time taking DST in account
   GetLocalTime(st);

   s := format('%2d/%2d/%4d %2d:%2d:%2d.%3d',
     [st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds]);

   DecodeDate(StrToDateTime(s), st.wYear, st.wMonth, st.wDay);
   DecodeTime(StrToDateTime(s), st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);

   s := IntToStrZero(st.wDay,    2) + '/' +
        IntToStrZero(st.wMonth,  2) + '/' +
        IntToStrZero(st.wYear,   4) + ' ' +
        IntToStrZero(st.wHour,   2) + ':' +
        IntToStrZero(st.wMinute, 2) + ':' +
        IntToStrZero(st.wSecond, 2) + '.' +
        IntToStrZero(st.wMilliseconds, 3);

   Memo1.Lines.Add('Local Time: ' + s);
end;

procedure TForm1.Button3Click(Sender: TObject);
var a: Integer;
begin
   // to get current timezone and DST
   case GetTimeZoneInformation(tz) of
      TIME_ZONE_ID_STANDARD: a := -(tz.StandardBias + tz.Bias) div 60;
      TIME_ZONE_ID_DAYLIGHT: a := -(tz.DaylightBias + tz.Bias) div 60;
   else
      a := -(tz.Bias div 60);
   end;

   s := format('UTC %d ', [a]);

   Memo1.Lines.Add(s);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
   d := GetTimeZoneInformation(tz);
   if d = 2 then
      Memo1.Lines.Add('Horário de verão ativo')
   else
      Memo1.Lines.Add('Horário de verão não está ativo')
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   // Horário GMT baseado no ntp.br
   IdSNTP1.Host := 'pool.ntp.br';
   IdSNTP1.Port := 123;
   GMTTime := TTimeZone.Local.ToUniversalTime(IdSNTP1.DateTime);

   // Converte a data UTC para a TimeZone definida
   TimeZone := TBundledTimeZone.GetTimeZone(ComboBox1.Text);
   DataHoraAtual := TimeZone.ToLocalTime(GMTTime);

   DecodeDate(DataHoraAtual, wAno, wMes, wDia);
   DecodeTime(DataHoraAtual, wHor, wMin, wSeg, wMil);

   s := IntToStrZero(wDia, 2) + '/' +
        IntToStrZero(wMes, 2) + '/' +
        IntToStrZero(wAno, 4) + ' ' +
        IntToStrZero(wHor, 2) + ':' +
        IntToStrZero(wMin, 2) + ':' +
        IntToStrZero(wSeg, 2) + '.' +
        IntToStrZero(wMil, 3);

   Memo1.Lines.Add(ComboBox1.Text + ': ' + s);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
   // faixa do fuso horário escolhido
   TimeZone := TBundledTimeZone.GetTimeZone(ComboBox1.Text);
   Memo1.Lines.Add(TimeZone.ID + ' ' + TimeZone.Abbreviation);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
   IdSNTP1.Host := 'pool.ntp.br';
   IdSNTP1.Port := 123;
   IdSNTP1.SyncTime;
end;

end.
