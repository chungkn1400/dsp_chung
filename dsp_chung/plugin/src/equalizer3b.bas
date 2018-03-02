Dim Shared As String curdir1  
Dim Shared As Integer xmax,ymax 
Sub setcombos()
   'reloadcombo("win.low",textgain())
   selectcombotext("win.low",texlow,textgain())
   lowgz=10^(Val(texlow)/20.0)
   'reloadcombo("win.high",textgain())
   selectcombotext("win.high",texhigh,textgain())
   highgz=10^(Val(texhigh)/20.0)
   'reloadcombo("win.midfreq",textmidfreq())
   selectcombotext("win.midfreq",texmidfreq,textmidfreq())
   midfreq=Val(texmidfreq)
   selectcombotext("win.gain",texgain,textgain())
   gain=10^(Val(texgain)/20.0)
guisetfocus("win.gain")
End Sub
Sub subsave()
Dim As String fic,resp,dir0
Dim As Integer ret,file
dir0=CurDir  
ret=ChDir(curdir1+"\save")  
fic=filedialog("save baxandall","*.baxandall")
ret=ChDir(dir0)
fic=Trim(fic)
If fic="" Then Exit Sub 
If InStr(fic,".")=0 Then fic+=".baxandall"
If LCase(Right(fic,10))<>".baxandall" Then guinotice "bad name "+fic:Exit Sub 
guiconfirm("save in "+fic+" ?","save baxandall",resp)
If resp="yes" Then
   file=freefile
   Open fic For Output As #file
   Print #file,texlow
   Print #file,texhigh
   Print #file,texmidfreq
   Close #file
	guinotice "baxandall saved as "+fic
EndIf
End Sub
Sub subload()
Dim As String fic,resp,ficin,dir0
Dim As Integer ret,file
dir0=CurDir
ret=ChDir(curdir1+"\save")  
fic=filedialog("load baxandall","*.baxandall")
ret=ChDir(dir0)
fic=Trim(fic)
If fic="" Then Exit Sub 
If InStr(fic,".")=0 Then fic+=".baxandall"
If LCase(Right(fic,10))<>".baxandall" Then guinotice "bad name "+fic:Exit Sub 
If FileExists(fic)=0 Then guinotice "not found :"+fic:Exit Sub 
guiconfirm("load "+fic+" ?","load baxandall",resp)
If resp="yes" Then
   file=FreeFile
   Open fic For Input As #file
texlow="0":texhigh="0"
If Not Eof(file) Then Line Input #file,ficin:texlow=Trim(ficin)
If Not Eof(file) Then Line Input #file,ficin:texhigh=Trim(ficin)
texmidfreq="800"
If Not Eof(file) Then Line Input #file,ficin:texmidfreq=Trim(ficin)
Close #file
lowgz=10^(Val(texlow)/20.0)
highgz=10^(Val(texhigh)/20.0)
midfreq=Val(texmidfreq)
lowdb=Val(texlow)
highdb=Val(texhigh)
zresetequalizer()
setcombos()
EndIf 
End Sub
Sub drawkeytone()
Dim As Integer i,j,k,jmid,imid,y0,y1,dy
Dim As Single x,y,ky,lowdb,middb,highdb
Dim As UInteger c=RGB(255,225,0)
Cls
Locate 2,1:? "+20";
Locate 7,1:? "+0";
Locate 11,1:? "-20";
Locate 8,1:?"0.1f0";
Locate 8,9:?"0.3f0";
Locate 8,21:?"f0";
Locate 8,31:?"3f0";
Locate 8,40:?"10f0";
y0=ymax/2+8:y1=ymax-2
dy=y1-y0
Line (0,y0)-(xmax,y0)
Line (0,y0-dy)-(xmax,y0-dy)
Line (0,y0+dy)-(xmax,y0+dy)
ky=dy
y=midgz
jmid=y0-ky*Log(max(0.1,y))/Log(10)
x=lowfz:y=lowgz
i=(xmax/2.1)*Log(x/100)/Log(10)
j=y0-ky*Log(max(0.1,y))/Log(10)
k=(Abs(j-jmid)/(zequaltype))*4.5
Line (0,j)-(i,j),c
Line (i,j)-(i+k,jmid),c
imid=i+k

x=highfz:y=highgz
i=(xmax/2.1)*Log(x/100)/Log(10)
j=y0-ky*Log(max(0.1,y))/Log(10)
k=(Abs(j-jmid)/(zequaltype))*4.5
Line (i,j)-(xmax,j),c
Line (i,j)-(i-k,jmid),c
Line (imid,jmid)-(i-k,jmid),c
Locate 1,1
?"[O]order"+Str(zequaltype)'+"   lowfz="+Str(lowfz)+"    highfz="+Str(highfz);
Locate 2,12
?"lowf="+Str(lowfz/1000)+"    highf="+Str(highfz/1000);
Locate 1,10
lowdb=20*Log(max(0.1,lowgz))/Log(10)
middb=20*Log(max(0.1,midgz))/Log(10)
highdb=20*Log(max(0.1,highgz))/Log(10)
?" lowg="+Left(Str(Int(lowdb*100)/100),5);
?" midg="+Left(Str(Int(middb*100)/100),5);
?" highg="+Left(Str(Int(highdb*100)/100),5); 
Locate 11,35
?"[A]apply"; 
End Sub
Function funczequal(ByRef zback As Single,ByVal jback As Integer,ByVal zchannels As Integer=2)As Single
if zchannels=1 Then
   		Return zequcalcul1(zback)
Else
  If (jback And 1)=0 Then
   		return zequcalcul1(zback)
  Else	
   		return zequcalcul2(zback)
  EndIf
EndIf
End Function 
