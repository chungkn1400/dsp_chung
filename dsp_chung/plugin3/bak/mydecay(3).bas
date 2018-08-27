' myecho.bas  by NGUYEN.Chung (2012)
' compile with: fbc -dll myplugin.bas
'
' plugin example for midipiano_chung
'
#Include Once "windows.bi"
#Define  noguijpeg  'if you use it add jpeg.dll in the main host exe dir
#Include "gui_chung.bi"


Dim Shared As Integer quit=0,i,j,k,tdecayon=1
Dim Shared As Single gain=1,decay=1,tdecay=100,kkdecay=0.77
Sub subquit()
	quit=1
End Sub
Sub subgain()
Dim As Integer i
getcomboindex("win.gain",i)
gain=max(0.0,min(3.0,(i-1)*0.05+0.5))
Sleep 200
End Sub
Sub subtdecayon()
	If tdecayon=1 Then
		tdecayon=0
		unsetcheckbox("win.tdecayon")
	Else
		tdecayon=1
		setcheckbox("win.tdecayon")
	EndIf
Sleep 300	
End Sub
Sub subdecay()
Dim As Integer i
getcomboindex("win.decay",i)
decay=1+(i-1)*0.05
Sleep 200
End Sub
Sub subtdecay()
Dim As Integer i
getcomboindex("win.tdecay",i)
tdecay=(i)*5
Sleep 200
End Sub
Sub subkdecay()
Dim As Integer i
getcomboindex("win.kdecay",i)
kkdecay=(i-1)*0.01+0.50
Sleep 200
End Sub
Dim Shared As String ficin,curdir1,windowname
dim Shared As String ficini:ficini="mydecay.ini"
Dim Shared As Integer File,winx,winy,wx,wy,depth,windx,windy
Function plugininit Cdecl Alias "plugininit" () As Integer Export
Dim As ZString*255 dllname
GetModuleFileName(guihinstance, dllname, 250)
curdir1=Left(dllname,InStrRev(dllname,"\")-1)
ficini=CurDir1+"/mydecay.ini" 
gain=1
If FileExists(ficini)=0 Then Return 1
file=FreeFile
Open ficini For Input As #file
gain=1
If Not Eof(file) Then Line Input #file,ficin:gain=Val(ficin)
winx=200:winy=100
If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
tdecayon=1
If Not Eof(file) Then Line Input #file,ficin:tdecayon=Val(ficin)
decay=1
If Not Eof(file) Then Line Input #file,ficin:decay=max(1.0,min(4.0,Val(ficin)))
tdecay=100
If Not Eof(file) Then Line Input #file,ficin:tdecay=Val(ficin)
kkdecay=0.77
If Not Eof(file) Then Line Input #file,ficin:kkdecay=Val(ficin)
Close #file
Return 0
End Function 
Function pluginmain Cdecl Alias "pluginmain" () As Integer Export
	windowname=Mid(curdir1,InStrRev(curdir1,"\")+1)+"/mydecay.dll"
	'guinotice curdir1
	guireset()
	guibackgroundcolor(250,200,0)
   ScreenInfo wx,wy,depth
	If winx<0 Then winx=0
	If winx>(wx-300) Then winx=wx-300
	If winy<0 Then winy=0
	If winy>(wy-150) Then winy=wy-150
   button("win.quit","quit",@subquit,20,65,50,25)
   statictext("win.tgain","gain",20,4,60,16)
   combobox("win.gain",@subgain,20,23,60,500)
   combobox("win.kdecay",@subkdecay,90,23,83,500)
   combobox("win.tdecay",@subtdecay,183,23,92,500)
   combobox("win.decay",@subdecay,183,65,92,500)
   checkbox("win.tdecayon","decay",@subtdecayon,90,70,60,20)   
   openwindow("win",windowname,winx,winy,300,135)
   
   trapclose("win",@subquit)
   If tdecayon=1 Then setcheckbox("win.tdecayon")
   guisetfocus("win.gain")
   
   For i=1 To 41
   	addcombo("win.gain",Left(Str((i-1)*0.05+0.5001),4))
   Next
   i=Int((gain-0.5)/0.05+1.001)
   selectcomboindex("win.gain",i)
   
For i=1 To 41
  If i=1 then	
	addcombo("win.decay","decayoff")
  Else 
	addcombo("win.decay","decay"+Left(Str((i-1)*0.05+1.0001),4))
  EndIf 
Next
i=Int((decay-1.0)*20+1.01)
selectcomboindex("win.decay",i)

For i=1 To 40
	addcombo("win.tdecay","tdecay"+Str((i)*5))
Next
i=Int(tdecay/5+0.01)
selectcomboindex("win.tdecay",i)

For i=1 To 49
	addcombo("win.kdecay","kdec"+Left(Str((i-1)*0.01+0.5001),4))
Next
i=Int((kkdecay-0.5)/0.01+1.01)
selectcomboindex("win.kdecay",i)


   quit=0
   While guitestkey(vk_escape)=0 And quit=0
   	guiscan
   	Sleep 100
   Wend
   
   guigetwindowpos("win",winx,winy,windx,windy)
   file=freefile
   Open ficini For Output As #file
   Print #file,gain
   Print #file,winx
   Print #file,winy
   Print #file,tdecayon
   Print #file,decay
   Print #file,tdecay
   Print #file,kkdecay
   Close #file
   
   'guinotice "plugin"
   guiclose()
	Return 0
End Function
Function pluginclose Cdecl Alias "pluginclose" () As Integer Export
	quit=1
	Return 0
End Function 
Declare Sub subprocdecay()
Dim Shared As Single xback
Function pluginproc Cdecl Alias "pluginproc" (ByVal sample As single) As Single Export
	If tdecayon=0 Then Return sample
   xback=sample
   subprocdecay() 
   Return xback*gain
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
Const As Integer ndecay=1400000
Dim Shared As Integer idecay,didecay,jdecay,irevdecay,irevdecay2,irevdecay0
Dim Shared As double xdecay(ndecay),xxdecay,xydecay,peekdecay,gaindecay,gainrevdecay=0.5,xrevdecay(ndecay),xdecayback
Dim Shared As Double timedecay,xxdecay0,k1000=1000,kdecay=1,xxdecay1
Sub subprocdecay()
Dim As Integer i,j,k
idecay+=1:If idecay>ndecay Then idecay=1
Var xback00=xback
'gainrevdecay=0.4
irevdecay0=idecay-9300:If irevdecay0<1 Then irevdecay0+=ndecay
irevdecay=idecay-9300-(20000-5000)*0.01*tdecay:If irevdecay<1 Then irevdecay+=ndecay
irevdecay2=idecay-9300-(28000-7000)*0.01*tdecay:If irevdecay2<1 Then irevdecay2+=ndecay
'xrevdecay(idecay)=xback-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)
xrevdecay(idecay)=xback
xrevdecay(irevdecay0)=xrevdecay(irevdecay0)-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)*kkdecay/0.77
'xydecay+=(xdecayback-xydecay)*0.5
xydecay+=(xback-xydecay)*0.5
xxdecay0+=(Abs(xydecay)-xxdecay0)*0.001
xxdecay1+=(max(kdecay*Abs(xrevdecay(irevdecay0)),Abs(xydecay))-xxdecay1)*0.001
xxdecay+=(xxdecay1-xxdecay)*0.003
'xxdecay+=(Abs(xydecay)-xxdecay)*0.001
'Var k100=100.0'max(100.0,Abs(xback)*0.01)
If Abs(xback)>xxdecay+200 Then
	xxdecay1=Abs(xback)+100
	xxdecay=xxdecay1
	timedecay=Timexback
	kdecay=1
EndIf
xdecay(idecay)=xxdecay	
If decay<1 Then decay=1
If peekdecay<xxdecay-150 Or Timexback>timedecay+7 Then
	peekdecay=xxdecay
	didecay=0
Else
	peekdecay-=0.03*(peekdecay*0.0001/decay)
	didecay+=1
	If didecay>ndecay-2 Then didecay=ndecay-2
EndIf
Var gain4=min(3.0,0.8/testgain),k400=100.0
If didecay>100 Then
	'jdecay=idecay-didecay/decay
	jdecay=idecay-didecay*(decay-1)/decay
	If jdecay<1 Then jdecay+=ndecay
	Var gaindecay2=max(1.0,min(gain4,max(k400,peekdecay-xxdecay)/max(k400,peekdecay-xdecay(jdecay))))
	'Var gaindecay1=max(0.1,min(4.0,max(400.0,xdecay(jdecay))/max(400.0,xxdecay)))
	'gaindecay2=max(gaindecay1,gaindecay2)
	If xxdecay0<k1000 Then
		k1000=2000
      gaindecay2=1
      kdecay=max(0.0,kdecay-0.001)
	Else
		k1000=1000
 	EndIf
	If gaindecay<gaindecay2 Then
		gaindecay+=(gaindecay2-gaindecay)*0.004
	Else 	
		gaindecay+=(gaindecay2-gaindecay)*0.003
	EndIf
Else
	gaindecay+=(1-gaindecay)*0.003
EndIf
'If gaindecay>1.2 Then
'	gainrevdecay=min(0.7,gainrevdecay+0.000001)
'ElseIf gaindecay<1.1 Then 	
'	gainrevdecay=max(0.0,gainrevdecay-0.000001)
'EndIf
If gaindecay>1.3 Then
	'xback=xback*0.75+(gaindecay-0.75)*xrevdecay(idecay)
	xback=xback*0.75+(gaindecay-0.75)*xrevdecay(irevdecay0)
Else
	Var k75=(gaindecay-1)/(1.3-1)
	'xback=xback*gaindecay*(1-k75)+k75*(xback*0.75+(gaindecay-0.75)*xrevdecay(idecay))
	xback=xback*gaindecay*(1-k75)+k75*(xback*0.75+(gaindecay-0.75)*xrevdecay(irevdecay0))
EndIf
'xdecayback=xback
'xback*=gaindecay
End Sub

