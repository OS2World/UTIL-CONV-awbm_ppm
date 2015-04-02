program ambp_ppm;

// Veit Kannegieser 2004.07.06..08.25 (31!)

uses
  Dos,
  VpUtils,
  Objects;

var
  k                     :
    packed record
      sign              :array[0..3] of char;
      x,y               :smallword;
    end;

  rgb                   :
    packed record
      sign              :array[0..3] of char;
      palette           :array[0..255,1..3] of byte;
    end;

  f                     :file;
  l                     :longint;
  q                     :pByteArray;
  farbbit               :byte;
  zeilenlaenge          :longint;
  zx,zy                 :longint;
  f2                    :text;
  pi                    :longint;
  bi                    :byte;
  t                     :byte;
  z                     :string;
  Dir                   :DirStr;
  Name                  :NameStr;
  Ext                   :ExtStr;
  rc                    :integer;

function fa(b:byte):string;
  begin
    fa:=Int2Str(rgb.palette[b,1])+' '
       +Int2Str(rgb.palette[b,2])+' '
       +Int2Str(rgb.palette[b,3])+' ';
  end;

begin

  if (ParamCount<1) or (ParamCount>2) or (ParamStr(1)='/?') or (ParamStr(1)='-?') then
    begin
      WriteLn('Usage: AWBM_PPM <Input AWBM> [<Output PPM>]');
      Halt(1);
    end;

  Assign(f,ParamStr(1));
  {$I-}
  Reset(f,1);
  {$I+}
  rc:=IOResult;
  if rc<>0 then
    begin
      WriteLn('Can not open source file.');
      RunError(rc);
    end;
  l:=FileSize(f);
  BlockRead(f,k,SizeOf(k));
  if k.sign<>'AWBM' then RunError(1);
  l:=l-SizeOf(k);

  if l>=k.x*k.y then
    farbbit:=8
  else
  if l*2>=k.x*k.y then
    farbbit:=4
  else
    RunError(1);

  case farbbit of
    4:zeilenlaenge:=((k.x+7) shr 3) shl 2;
    8:zeilenlaenge:=k.x;
  end;

  GetMem(q,zeilenlaenge*k.y);
  BlockRead(f,q^,zeilenlaenge*k.y);

  l:=l-zeilenlaenge*k.y;
  BlockRead(f,rgb,4+(1 shl farbbit)*3);
  Close(f);

  if rgb.sign<>'RGB ' then RunError(1);

  if ParamStr(2)='' then
    begin
      FSplit(ParamStr(1),Dir,Name,Ext);
      Assign(f2,Dir+Name+'.ppm');
    end
  else
    Assign(f2,ParamStr(2));
  {$I-}
  Rewrite(f2);
  {$I+}
  rc:=IOResult;
  if rc<>0 then
    begin
      WriteLn('Can not create output file.');
      RunError(rc);
    end;

  WriteLn(f2,'P3');
  WriteLn(f2,k.x,' ',k.y);
  WriteLn(f2,63);
  z:='';

  for zy:=0 to k.y-1 do
    for zx:=0 to k.x-1 do
      begin

        case farbbit of
          4:
            begin
              pi:=zy*zeilenlaenge+(zx shr 3);
              bi:=7-(zx and 7);
              t:=0;
              if Odd(q^[pi+0*zeilenlaenge shr 2] shr bi) then t:=t or (1 shl 0);
              if Odd(q^[pi+1*zeilenlaenge shr 2] shr bi) then t:=t or (1 shl 1);
              if Odd(q^[pi+2*zeilenlaenge shr 2] shr bi) then t:=t or (1 shl 2);
              if Odd(q^[pi+3*zeilenlaenge shr 2] shr bi) then t:=t or (1 shl 3);
              z:=z+fa(t);
            end;
          8:z:=z+fa(q^[zy*zeilenlaenge+zx]);
        end;

        if Length(z)>240 then
          begin
            WriteLn(f2,z);
            z:='';
          end;
      end;

  if z<>'' then
    begin
      WriteLn(f2,z);
      z:='';
    end;
  Close(f2);
  Dispose(q);
end.

