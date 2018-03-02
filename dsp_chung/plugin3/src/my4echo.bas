' my4echo.bas  by NGUYEN.Chung (2012)
'
' plugin example for midipiano_chung
'
#Include Once "windows.bi"
#Define  noguijpeg  'if you use it add jpeg.dll in the main host exe dir
#Define  guinogfx   'nogfx
#Include "gui_chung.bi"
#Include "echo4.bi"


Dim Shared As Integer quit=0,ipreset=1
Declare Sub reloadcombos(byval reload as integer=0)
Sub subquit()
	quit=1
End Sub
Dim Shared As String textvol(200),texvol(4),textdelay(200),texdelay(4)
Dim Shared As String textfeedback(100),texfeedback(4),textvol2(200)
Dim Shared As String texpan,textpan(20)
For i=0 To 200
	textvol(i)=Str(200-i)
Next
For i=0 To 199
	textdelay(i)=Str(1000-i*5)
Next
For i=1 To 100
	textfeedback(i)=Str(100-i)
Next
For i=0 To 60
	textvol2(i)=Str(300-i*5)
Next
For i=0 To 18
	textpan(i)="pan"+Str(9-i)
Next
Sub subpan()
texpan=getcombotext("win.pan",textpan())
pan=Val(Right(texpan,Len(texpan)-3))
setreverb()
End Sub
Sub subvolume()
var i=0
	texvol(i)=getcombotext("win.volume",textvol2())
	volume=Val(texvol(i))/100.0
'setreverb()
End Sub
Sub subvol(ByVal i As Integer)
	texvol(i)=getcombotext("win.vol"+Str(i),textvol())
	vol(i)=Val(texvol(i))/100.0
setreverb()
End Sub
Sub subdelay(ByVal i As Integer)
	texdelay(i)=getcombotext("win.delay"+Str(i),textdelay())
	delay(i)=Val(texdelay(i))
setreverb()
End Sub
Sub subfeedback(ByVal i As Integer)
	texfeedback(i)=getcombotext("win.feedback"+Str(i),textfeedback())
	feedback(i)=Val(texfeedback(i))/100.0
setreverb()
End Sub
Sub subecho(ByVal i As Integer)
	If echo(i)=1 Then 
		echo(i)=0:unsetcheckbox("win.echo"+Str(i))
	Else 
		echo(i)=1:setcheckbox("win.echo"+Str(i))
	EndIf
setreverb()
End Sub
Sub subvol1
	subvol(1)
End Sub
Sub subdelay1
	subdelay(1)
End Sub
Sub subfeedback1
	subfeedback(1)
End Sub
Sub subecho1
	subecho(1)
End Sub
Sub subvol2
	subvol(2)
End Sub
Sub subdelay2
	subdelay(2)
End Sub
Sub subfeedback2
	subfeedback(2)
End Sub
Sub subecho2
	subecho(2)
End Sub
Sub subvol3
	subvol(3)
End Sub
Sub subdelay3
	subdelay(3)
End Sub
Sub subfeedback3
	subfeedback(3)
End Sub
Sub subecho3
	subecho(3)
End Sub
Sub subvol4
	subvol(4)
End Sub
Sub subdelay4
	subdelay(4)
End Sub
Sub subfeedback4
	subfeedback(4)
End Sub
Sub subecho4
	subecho(4)
End Sub
Dim Shared As Single pvol(4,4),pdelay(4,4),pfeedback(4,4),pecho(4,4),pvolume(4)
Dim Shared As Integer pechotype(4),ppan(4)
Sub subpreset()
Dim As Integer i
ipreset=max2(1,min2(4,ipreset))
For i=1 To 4
   pvol(i,ipreset)=vol(i):pdelay(i,ipreset)=delay(i)
   pfeedback(i,ipreset)=feedback(i):pecho(i,ipreset)=echo(i)
Next i
pechotype(ipreset)=echotype
pvolume(ipreset)=volume
ppan(ipreset)=pan
ipreset+=1:If ipreset>4 Then ipreset=1
printgui("win.preset","preset"+Str(ipreset))
For i=1 To 4
   vol(i)=pvol(i,ipreset):delay(i)=pdelay(i,ipreset)
   feedback(i)=pfeedback(i,ipreset):echo(i)=pecho(i,ipreset)
   'texvol(i)=Str(Int(vol(i)*100.001))
   'selectcombotext("win.vol"+Str(i),texvol(i),textvol())
   'texdelay(i)=Str(Int(delay(i)+0.001))
   'selectcombotext("win.delay"+Str(i),texdelay(i),textdelay())
   'texfeedback(i)=Str(Int(feedback(i)*100.001))
   'selectcombotext("win.feedback"+Str(i),texfeedback(i),textfeedback())
   'If echo(i)=1 Then
   '   setcheckbox("win.echo"+Str(i))
   'Else
   '	unsetcheckbox("win.echo"+Str(i))
   'EndIf
Next i 
echotype=max2(1,min2(3,pechotype(ipreset)))
volume=pvolume(ipreset)
pan=ppan(ipreset)
reloadcombos()
setreverb()	
End Sub
Sub subechoall()
If echotype=1 Then
	echotype=2
	setcheckbox("win.echo") 
Else 
	echotype=1
	unsetcheckbox("win.echo")
EndIf
End Sub
Dim Shared As String ficin,curdir1,windowname
dim Shared As String ficini:ficini="my4echo.ini"
Dim Shared As Integer File,winx,winy,wx,wy,depth,windx,windy
Sub subsave()
Dim As String fic,resp,dir0
Dim As Integer ret,file,i
dir0=CurDir  
ret=ChDir(curdir1+"\save")  
fic=filedialog("save 4echo","*.4echo")
ret=ChDir(dir0)
fic=Trim(fic)
If fic="" Then Exit Sub 
If InStr(fic,".")<1 Then fic+=".4echo"
If LCase(Right(fic,6))<>".4echo" Then guinotice "bad name "+fic:Exit Sub 
guiconfirm("save in "+fic+" ?","save 4echo",resp)
If resp="yes" Then
   file=freefile
   Open fic For Output As #file
   For i=1 To 4
    Print #file,vol(i)
    Print #file,delay(i)
    Print #file,feedback(i)
    Print #file,echo(i)
   Next i
   Print #file,echotype
   Print #file,volume
   Print #file,pan
   Close #file
	guinotice "4echo saved as "+fic
EndIf
End Sub
Sub subload()
Dim As String fic,resp,ficin,dir0
Dim As Integer ret,file,i
dir0=CurDir
ret=ChDir(curdir1+"\save")  
fic=filedialog("load 4echo","*.4echo")
ret=ChDir(dir0)
fic=Trim(fic)
If fic="" Then Exit Sub 
If InStr(fic,".")<1 Then fic+=".4echo"
If LCase(Right(fic,6))<>".4echo" Then guinotice "bad name "+fic:Exit Sub 
If FileExists(fic)=0 Then guinotice "not found :"+fic:Exit Sub 
guiconfirm("load "+fic+" ?","load 4echo",resp)
If resp="yes" Then
   file=FreeFile
   Open fic For Input As #file
For i=1 To 4
 vol(i)=1
 If Not Eof(file) Then Line Input #file,ficin:vol(i)=Val(ficin)
 delay(i)=100
 If Not Eof(file) Then Line Input #file,ficin:delay(i)=Val(ficin)
 feedback(i)=0.50
 If Not Eof(file) Then Line Input #file,ficin:feedback(i)=Val(ficin)
 echo(i)=1
 If Not Eof(file) Then Line Input #file,ficin:echo(i)=Val(ficin)
Next i 
echotype=1
If Not Eof(file) Then Line Input #file,ficin:echotype=Val(ficin)
volume=1
If Not Eof(file) Then Line Input #file,ficin:volume=Val(ficin)
pan=0
If Not Eof(file) Then Line Input #file,ficin:pan=Val(ficin)
Close #file
reloadcombos()
setreverb()
EndIf 
End Sub
Function plugininit Cdecl Alias "plugininit" () As Integer Export
Dim As ZString*255 dllname
GetModuleFileName(guihinstance, dllname, 250)
curdir1=Left(dllname,InStrRev(dllname,"\")-1)
ficini=CurDir1+"/my4echo.ini" 
If FileExists(ficini)=0 Then Return 1
file=FreeFile
Open ficini For Input As #file
winx=200:winy=100
If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
For i=1 To 4
 vol(i)=1
 If Not Eof(file) Then Line Input #file,ficin:vol(i)=Val(ficin)
 delay(i)=100
 If Not Eof(file) Then Line Input #file,ficin:delay(i)=Val(ficin)
 feedback(i)=0.50
 If Not Eof(file) Then Line Input #file,ficin:feedback(i)=Val(ficin)
 echo(i)=1
 If Not Eof(file) Then Line Input #file,ficin:echo(i)=Val(ficin)
Next i 
For i=1 To 4
 For j=1 To 4
	pvol(i,j)=1
   If Not Eof(file) Then Line Input #file,ficin:pvol(i,j)=Val(ficin)
	pdelay(i,j)=100
   If Not Eof(file) Then Line Input #file,ficin:pdelay(i,j)=Val(ficin)
	pfeedback(i,j)=0.50
   If Not Eof(file) Then Line Input #file,ficin:pfeedback(i,j)=Val(ficin)
   pecho(i,j)=0
   If Not Eof(file) Then Line Input #file,ficin:pecho(i,j)=Val(ficin)
 Next j
Next i
ipreset=1
If Not Eof(file) Then Line Input #file,ficin:ipreset=Val(ficin)
echotype=2
If Not Eof(file) Then Line Input #file,ficin:echotype=Val(ficin)
For i=1 To 4
   pechotype(i)=1
   If Not Eof(file) Then Line Input #file,ficin:pechotype(i)=Val(ficin)	
Next
volume=1
If Not Eof(file) Then Line Input #file,ficin:volume=Val(ficin)
For i=1 To 4
   pvolume(i)=1
   If Not Eof(file) Then Line Input #file,ficin:pvolume(i)=Val(ficin)	
Next
For i=1 To 4
   ppan(i)=0
   If Not Eof(file) Then Line Input #file,ficin:ppan(i)=Val(ficin)	
Next
pan=0
If Not Eof(file) Then Line Input #file,ficin:pan=Val(ficin)
Close #file
setreverb()
Return 0
End Function
Sub reloadcombos(ByVal reload As Integer=0)
Dim As Integer i
   For i=1 To 4
    If reload=1 Then reloadcombo("win.vol"+Str(i),textvol())
    texvol(i)=Str(Int(vol(i)*100.001))
    selectcombotext("win.vol"+Str(i),texvol(i),textvol())
    If reload=1 Then reloadcombo("win.delay"+Str(i),textdelay())
    texdelay(i)=Str(Int(delay(i)+0.001))
    selectcombotext("win.delay"+Str(i),texdelay(i),textdelay())
    If reload=1 Then reloadcombo("win.feedback"+Str(i),textfeedback())
    texfeedback(i)=Str(Int(feedback(i)*100.001))
    selectcombotext("win.feedback"+Str(i),texfeedback(i),textfeedback())
    If echo(i)=1 Then
    	setcheckbox("win.echo"+Str(i))
    Else
    	unsetcheckbox("win.echo"+Str(i))
    EndIf
   Next i
   'selectcomboindex("win.type",echotype)
   If echotype=2 Then
   	setcheckbox("win.echo")
   Else
   	unsetcheckbox("win.echo")
   EndIf
   If reload=1 Then reloadcombo("win.volume",textvol2())
   texvol(0)=Str(Int(volume*100.001))
   selectcombotext("win.volume",texvol(0),textvol2())
   If reload=1 Then reloadcombo("win.pan",textpan())
   texpan="pan"+Str(pan)
   selectcombotext("win.pan",texpan,textpan())
End Sub 
Function pluginmain Cdecl Alias "pluginmain" () As Integer Export
	windowname=Mid(curdir1,InStrRev(curdir1,"\")+1)+"/my4echo.dll"
	'guinotice curdir1
	guireset()
	guibackgroundcolor(250,200,0)
   ScreenInfo wx,wy,depth
	If winx<0 Then winx=0
	If winx>(wx-300) Then winx=wx-300
	If winy<0 Then winy=0
	If winy>(wy-150) Then winy=wy-150
   statictext("win.tvol","volume",20,4,60,16)
   statictext("win.tdelay","delay ms",90,4,60,16)
   statictext("win.tfeedback","feedback",160,4,60,16)
   checkbox("win.echo","echo",@subechoall,230,4,60,20)
   combobox("win.vol1",@subvol1,20,23,60,300)
   combobox("win.delay1",@subdelay1,90,23,60,300)
   combobox("win.feedback1",@subfeedback1,160,23,60,300)
   checkbox("win.echo1","echo1",@subecho1,230,23+5,60,20)
   i=23+30
   combobox("win.vol2",@subvol2,20,i,60,300)
   combobox("win.delay2",@subdelay2,90,i,60,300)
   combobox("win.feedback2",@subfeedback2,160,i,60,300)
   checkbox("win.echo2","echo2",@subecho2,230,i+3,60,20)
   i+=30
   combobox("win.vol3",@subvol3,20,i,60,300)
   combobox("win.delay3",@subdelay3,90,i,60,300)
   combobox("win.feedback3",@subfeedback3,160,i,60,300)
   checkbox("win.echo3","echo3",@subecho3,230,i+2,60,20)
   i+=30
   combobox("win.vol4",@subvol4,20,i,60,300)
   combobox("win.delay4",@subdelay4,90,i,60,300)
   combobox("win.feedback4",@subfeedback4,160,i,60,300)
   checkbox("win.echo4","echo4",@subecho4,230,i+1,60,20)
   i+=30
   statictext("win.tvolume","%",18-12,153,12,16)
   combobox("win.volume",@subvolume,19,148,60,300)
   'button("win.quit","quit",@subquit,20,148,50,25)
   button("win.preset","preset",@subpreset,89,148,60,25)   
   button("win.save","save",@subsave,160,155,38,18)
   button("win.load","load",@subload,202,155,38,18)   
   combobox("win.pan",@subpan,246,148,63,300)
   openwindow("win",windowname,winx,winy,320,210)
   
   trapclose("win",@subquit)
   reloadcombos(1)
   printgui("win.preset","preset"+Str(ipreset))
   guisetfocus("win.vol")
   
   quit=0
   While guitestkey(vk_escape)=0 And quit=0
   	guiscan
   	Sleep 100
   Wend
   
   guigetwindowpos("win",winx,winy,windx,windy)
   file=freefile
   Open ficini For Output As #file
   Print #file,winx
   Print #file,winy
   For i=1 To 4
    Print #file,vol(i)
    Print #file,delay(i)
    Print #file,feedback(i)
    Print #file,echo(i)
   Next i
   For i=1 To 4
    For j=1 To 4	
   	Print #file,pvol(i,j)
      Print #file,pdelay(i,j)
      Print #file,pfeedback(i,j)
      Print #file,pecho(i,j)
    Next j  
   Next i
   Print #file,ipreset
   Print #file,echotype
   For i=1 To 4
   	Print #file,pechotype(i)
   Next i
   Print #file,volume
   For i=1 To 4
   	Print #file,pvolume(i)
   Next i
   For i=1 To 4
   	Print #file,ppan(i)
   Next i
   Print #file,pan
   Close #file
   
   'guinotice "plugin"
   guiclose()
	Return 0
End Function
Function pluginclose Cdecl Alias "pluginclose" () As Integer Export
	quit=1
	Return 0
End Function 
Function pluginproc Cdecl Alias "pluginproc" (ByVal sample As single) As Single Export
Dim As Single x
Dim As Integer i
If echotype=1 Then Return sample
If echotype=3 Then
	echotype=2
   x=sample
	'If echo(1)=1 Then x=x+volume*vol(1)*functionreverb(x,1)
	'If echo(2)=1 Then x=x+volume*vol(2)*functionreverb(x,2)
	'If echo(3)=1 Then x=x+volume*vol(3)*functionreverb(x,3)
	'If echo(4)=1 Then x=x+volume*vol(4)*functionreverb(x,4)
	Return x
EndIf
If echotype=2 Then
	If necho=0 Then Return sample
	'Return sample+volmax*functionreverbcombi(sample)
	Return sample+volume*volcombi*functionreverbcombi(sample)
EndIf
Return 0
	'xecho=vol*sample*1.2
	'Return sample*(1.0-vol)+vol*functionreverb(xecho)
   'Return sample+vol*functionreverb(sample)
End Function 


Dim Shared As Any Ptr hsubplugin
Sub subplugin()
pluginmain()
hsubplugin=0
End Sub
Dim Shared As Double tfocus
Function startpluginmain Cdecl Alias "startpluginmain" () As Integer Export 
If hsubplugin=0 Then
	hsubplugin=ThreadCreate(Cast(Any ptr,@subplugin))
  'guinotice "hsubplugin="+Str(hsubplugin)
  tfocus=Timer 
Else 	
  'Dim As HWND hwin
  'ScreenControl(2, Cast(Integer,hwin)) 'get screen handle
  If tfocus>(Timer+99) Then tfocus=Timer
  If Timer>(tfocus+7) Then
  	setforegroundwindow(getguih("win"))'hwin)
  	Sleep 1500
  	tfocus=Timer 
  EndIf
EndIf 
Return 0
End Function 
Function closepluginmain Cdecl Alias "closepluginmain" () As Integer Export 
'guinotice "closepluginmain"
pluginclose()
If hsubplugin<>0 Then
	ThreadWait(hsubplugin)
EndIf
guiclose()
Return 0
End Function 
Function mypluginproc Cdecl Alias "mypluginproc" (ByVal sample As Single Ptr) As Single Export 
Return pluginproc(*sample)
Return 0
End Function 
