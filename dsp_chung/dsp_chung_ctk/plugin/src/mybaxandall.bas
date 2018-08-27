' mybaxandall.bas by NGUYEN.Chung (2013)
' compile with: fbc -dll mybaxandall.bas
'
' plugin example for midipiano_chung / FB_chungVST
'
#Include Once "windows.bi"
#Define  noguijpeg 'if you use it add jpeg.dll in the main host exe dir 
#Include "gui_chung.bi"
#Include "equalizer3b.bi"
#Include "equalizer3b.bas"

'guinotice "load dll"
Dim Shared As Integer quit=0,i
Sub subquit()
	quit=1
End Sub
For i=1 To 41
	textgain(i)=Str(21-i)
Next
For i=0 To 60
	textmidfreq(i)=Str(2000-i*25)
	'textmidfreq(i+21)=Str(1000-i*25)
Next
Sub sublow()
	texlow=getcombotext("win.low",textgain())
	lowgz=10^(Val(texlow)/20.0)
	lowdb=Val(texlow)
zresetequalizer()
End Sub 
Sub subhigh()
	texhigh=getcombotext("win.high",textgain())
	highgz=10^(Val(texhigh)/20.0)
	highdb=Val(texhigh)
zresetequalizer()
End Sub
Sub submidfreq()
	texmidfreq=getcombotext("win.midfreq",textmidfreq())
	midfreq=Val(texmidfreq)
zresetequalizer()
End Sub
Sub subgain()
	texgain=getcombotext("win.gain",textgain())
	gain=10^(Val(texgain)/20.0)
zresetequalizer()
End Sub
Sub subon()
If onoff=0 Then
	onoff=1:setcheckbox("win.on")
Else
	onoff=0:unsetcheckbox("win.on")
EndIf
End Sub
Dim Shared As String ficin
dim Shared As String ficini:ficini="mybaxandall.ini"
Dim Shared As Integer File,winx,winy,wx,wy,depth,windx,windy
Function plugininit Cdecl Alias "plugininit" () As Integer Export
Dim As ZString*255 dllname
GetModuleFileName(guihinstance, dllname, 250)
curdir1=Left(dllname,InStrRev(dllname,"\")-1)
ficini=curdir1+"/mybaxandall.ini"
'curdir1=CurDir 
gain=1
If FileExists(ficini)=0 Then Return 1
file=FreeFile
Open ficini For Input As #file
winx=200:winy=100
If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
texlow="0":texhigh="0"
If Not Eof(file) Then Line Input #file,ficin:texlow=Trim(ficin)
If Not Eof(file) Then Line Input #file,ficin:texhigh=Trim(ficin)
texmidfreq="800"
If Not Eof(file) Then Line Input #file,ficin:texmidfreq=Trim(ficin)
onoff=1
If Not Eof(file) Then Line Input #file,ficin:onoff=Val(ficin)
texgain="0"
If Not Eof(file) Then Line Input #file,ficin:texgain=Trim(ficin)
Close #file
lowgz=10^(Val(texlow)/20.0)
highgz=10^(Val(texhigh)/20.0)
midfreq=Val(texmidfreq)
lowdb=Val(texlow)
highdb=Val(texhigh)
gain=10^(Val(texgain)/20.0)
zresetequalizer()
Return 0
End Function 
Function pluginmain Alias "pluginmain" () As Integer Export
Dim As String windowname  
   windowname=Mid(curdir1,InStrRev(curdir1,"\")+1)+"/baxandall.dll"
	guireset()
   guibackgroundcolor(50,250,50)
   ScreenInfo wx,wy,depth
	If winx<0 Then winx=0
	If winx>(wx-300) Then winx=wx-300
	If winy<0 Then winy=0
	If winy>(wy-150) Then winy=wy-150
   button("win.quit","quit",@subquit,20,70,50,30)
   statictext("win.tlow","low",20,4,50,16)
   statictext("win.thigh","high",80,4,50,16)
   combobox("win.low",@sublow,20,23,50,300)
   combobox("win.high",@subhigh,80,23,50,300)
   statictext("win.tmidfreq","midfreq",140,4,50,16)
   combobox("win.midfreq",@submidfreq,140,23,60,300)
   statictext("win.tgain","gain(db)",220,4,60,16)
   combobox("win.gain",@subgain,220,23,55,300)
   checkbox("win.on","baxandall",@subon,150,78,90,16)
   button("win.load","load",@subload,80,72,38,18)   
   button("win.save","save",@subsave,80,92,38,18)
   openwindow("win",windowname,winx,winy,300,150)
   
   trapclose("win",@subquit)
   If onoff=1 Then setcheckbox("win.on")
   reloadcombo("win.low",textgain())
   selectcombotext("win.low",texlow,textgain())
   lowgz=10^(Val(texlow)/20.0)
   reloadcombo("win.high",textgain())
   selectcombotext("win.high",texhigh,textgain())
   highgz=10^(Val(texhigh)/20.0)
   reloadcombo("win.midfreq",textmidfreq())
   selectcombotext("win.midfreq",texmidfreq,textmidfreq())
   midfreq=Val(texmidfreq)
   reloadcombo("win.gain",textgain())
   selectcombotext("win.gain",texgain,textgain())
   gain=10^(Val(texgain)/20.0)
   lowdb=Val(texlow)
   highdb=Val(texhigh)
   zresetequalizer()
   guisetfocus("win.gain")
   
   quit=0
   While guitestkey(vk_escape)=0 And quit=0
   	guiscan
   	Sleep 100
   	If guitestkey(vk_l)<>0 Then
   		If GetactiveWindow()=getguih("win") Then subload():setcombos()
   	EndIf
   	If guitestkey(vk_s)<>0 Then 
   		If GetactiveWindow()=getguih("win") Then subsave():setcombos()
   	EndIf
   Wend
   
   guigetwindowpos("win",winx,winy,windx,windy)
   file=freefile
   Open ficini For Output As #file
   Print #file,winx
   Print #file,winy
   Print #file,texlow
   Print #file,texhigh
   Print #file,texmidfreq
   Print #file,onoff
   Print #file,texgain
   Close #file
   
   'guinotice "plugin"
   guiclose()
	Return 0
End Function
Function pluginclose Alias "pluginclose" () As Integer Export
	quit=1
	Return 0
End Function
Dim Shared As Integer channel=0
Function pluginproc Alias "pluginproc" (ByVal sample As single) As Single Export
	If onoff=0 Then Return gain*sample
	channel=channel+1:If channel>1 Then channel=0
	Return gain*funczequal(sample,channel)'gain*sample
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
