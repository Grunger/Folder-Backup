unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, Menus, Buttons, ExtCtrls, Unix, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    RadioGroup1: TRadioGroup;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SelectDirectoryDialog2: TSelectDirectoryDialog;
    Timer1: TTimer;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
   s:string;
   i:integer;
implementation

{$R *.lfm}
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
   AProcess: TProcess;
   f,f1,included,excluded: textfile;
begin
  assignfile(f,'backup.sh');
  assignfile(f1,'backup_first.sh');
  assignfile(included,'include.txt');
  assignfile(excluded,'exclude.txt');
  rewrite(f);
  rewrite(f1);
  rewrite(included);
  rewrite(excluded);

    if memo2.Lines.Count<>0 then
   for i:=0 to memo2.Lines.Count-1 do
       writeln(excluded,memo2.Lines[i]);
    closefile(excluded);
  if memo1.Lines.Count<>0 then
  for i:=0 to memo1.Lines.Count-1 do
        writeln(included,memo1.Lines[i]);
        closefile(included);

  writeln(f,'#! /bin/bash');
  writeln(f,'SAVEDIR="'+edit1.text+'"');
  writeln(f,'LAST="${SAVEDIR}/lasttimebackup.log"');
  writeln(f,'INTAR="./include.txt"');
  writeln(f,'EXTAR="./exclude.txt"');
  writeln(f,'FDATE=$(date +%F_%H-%M)');

  writeln(f1,'#! /bin/bash');
  writeln(f1,'SAVEDIR="'+edit1.text+'"');
  writeln(f1,'LAST="${SAVEDIR}/lasttimebackup.log"');
  writeln(f1,'INTAR="./include.txt"');
  writeln(f1,'EXTAR="./exclude.txt"');
  writeln(f1,'FDATE=$(date +%F_%H-%M)');

  if RadioGroup1.ItemIndex=0 then
  begin
  writeln(f,'WDAY=$(date +%u)');
  writeln(f,'if [ "$WDAY" -ne 7 ];');
  writeln(f,'     then');
  writeln(f,'         SAVENAME="${SAVEDIR}/backup_${FDATE}.small"');
  writeln(f,'         TARPAR="-N$LAST -X$EXTAR -T$INTAR"');
  writeln(f,'         echo $(date +%Y%m%d%H%M.%S) > "$LAST"');
  writeln(f,'     else');
  writeln(f,'         SAVENAME="${SAVEDIR}/backup_${FDATE}.full"');
  writeln(f,'         TARPAR="-X$EXTAR -T$INTAR"');
  writeln(f,'         echo $(date +%Y%m%d%H%M.%S) > "$LAST"');
  writeln(f,'fi');
  end else
  begin
  writeln(f,'WDAY=$(date+%W)');
  writeln(f,'if [ "$WDAY" % 4 -ne 0 ];');
  writeln(f,'     then');
  writeln(f,'         SAVENAME="${SAVEDIR}/backup_${FDATE}.small"');
  writeln(f,'         TARPAR="-N$LAST -X$EXTAR -T$INTAR"');
  writeln(f,'     else');
  writeln(f,'         SAVENAME="${SAVEDIR}/backup_${FDATE}.full"');
  writeln(f,'         TARPAR="-X$EXTAR -T$INTAR"');
  writeln(f,'         echo $(date +%Y%m%d%H%M.%S) > "$LAST"');
  writeln(f,'fi');
  end;

  writeln(f,'tar czvf "${SAVENAME}.tar.gz" $TARPAR');
  writeln(f,'exit 0');
  closefile(f);

  writeln(f1,'         SAVENAME="${SAVEDIR}/backup_${FDATE}.full"');
  writeln(f1,'         TARPAR="-X$EXTAR -T$INTAR"');
  writeln(f1,'         echo $(date +%Y%m%d%H%M.%S) > "$LAST"');
  writeln(f1,'tar czvf "${SAVENAME}.tar.gz" $TARPAR');
  writeln(f1,'exit 0');
  closefile(f1);


  executeprocess('/bin/chmod','777 ./backup.sh');
  executeprocess('/bin/chmod','777 ./backup_first.sh');

AProcess := TProcess.Create(nil);
   AProcess.Executable := '/bin/bash';
   Aprocess.Parameters.Add('-c');
   Aprocess.Parameters.add('./backup_first.sh');
   AProcess.Execute;
   AProcess.Free;
   form2.Memo1.Lines.Add('crontab -e -u root');
   form2.Memo1.Lines.Add('В появившемся документе добавьте в конец файла строку');
   form2.Memo1.Lines.Add('0 12 * * 1-7 sh '+Application.Location+'backup.sh');
   form2.Memo1.Lines.Add('Где 12 - час выполнения бэкапа, 0 - минуты.   ');
   if RadioGroup1.ItemIndex=0 then
   begin
   form2.Memo1.Lines.Add('Полная резервная копия будет выполняться раз в неделю, в воскресенье');
   form2.Memo1.Lines.Add('Инкрементный архив будет выполняться каждый день в указанное время');
   end else
   begin
   form2.Memo1.Lines.Add('Полная резервная копия будет выполняться раз в месяц, в первую неделю');
   form2.Memo1.Lines.Add('Инкрементный архив будет выполняться каждый день в указанное время');
   end;

   form2.Show;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if edit1.text<>'' then begin
      Button1.Enabled:=true;
      Timer1.Enabled:=false;
  end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
 if SelectDirectoryDialog1.Execute then
  begin
   s:=SelectDirectoryDialog1.FileName;
   i:=0;
     while i<> length(s)-1 do
       begin
         if s[i]=' ' then begin insert('\',s,i); i:=i+2; end;
         i:=i+1;
        end;
end;
 //Edit1.Text:=s;
  Edit1.Text:= SelectDirectoryDialog1.FileName;
 end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  if SelectDirectoryDialog2.Execute then
   begin
     s:=SelectDirectoryDialog2.FileName;
     i:=0;
       while i<> length(s)-1 do
          begin
          if s[i]=' ' then begin insert('\',s,i); i:=i+2; end;
          i:=i+1;
          end;
   end;
 // memo1.Lines.Add(S);
  memo1.Lines.Add(SelectDirectoryDialog2.FileName);
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  if SelectDirectoryDialog2.Execute then
 begin
  s:=SelectDirectoryDialog2.FileName;
  i:=0;
  while i<> length(s)-1 do
    begin
    if s[i]=' ' then begin insert('\',s,i); i:=i+2; end;
    i:=i+1;
    end;
 end;
//memo2.Lines.Add(S);
   memo2.Lines.Add(SelectDirectoryDialog2.FileName);
end;

end.
