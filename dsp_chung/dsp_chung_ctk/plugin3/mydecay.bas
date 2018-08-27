' mydecay.bas  by NGUYEN.Chung (2012)
' compile with: fbc -dll myplugin.bas
'
' plugin example for midipiano_chung
'
#Include Once "windows.bi"
#Define  noguijpeg  'if you use it add jpeg.dll in the main host exe dir
#Include "gui_chung.bi"
#Include "fbthread.bi" 


Dim Shared As Integer quit=0,i,j,k,tdecayon=1
Dim Shared As Single gain=1,decay=1,tdecay=100,kkdecay=0.77,krate=1
Sub subquit()
	quit=1
End Sub
Sub subgain()
Dim As Integer i
getcomboindex("win.gain",i)
'gain=10^((21-i)/20.0)
gain=100-(i-1)*5
Sleep 100
End Sub
Sub subrate()
Dim As Integer i
getcomboindex("win.rate",i)
krate=(21-i)*0.05
Sleep 100
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
Sleep 100
End Sub
Sub subtdecay()
Dim As Integer i
getcomboindex("win.tdecay",i)
tdecay=(i)*5
Sleep 100
End Sub
Sub subkdecay()
Dim As Integer i
getcomboindex("win.kdecay",i)
kkdecay=(i-1)*0.01+0.50
Sleep 100
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
krate=1
If Not Eof(file) Then Line Input #file,ficin:krate=Val(ficin)
Close #file
Return 0
End Function 
Dim Shared As Integer okclose=0
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
   'button("win.quit","quit",@subquit,20,80,50,20)
   'statictext("win.tgain","gain(db)",20,4,60,16)
   combobox("win.gain",@subgain,20,23,60,500)
   combobox("win.kdecay",@subkdecay,90,23,83,500)
   combobox("win.tdecay",@subtdecay,183,23,92,500)
   combobox("win.decay",@subdecay,183,65,92,500)
   combobox("win.rate",@subrate,90,65,83,500)
   checkbox("win.tdecayon","decay",@subtdecayon,20,68,60,20)   
   openwindow("win",windowname,winx,winy,300,135)
   
   trapclose("win",@subquit)
   If tdecayon=1 Then setcheckbox("win.tdecayon")
   guisetfocus("win.gain")
   
   /'For i=1 To 41
   	addcombo("win.gain",Str(21-i))
   Next
   i=Int(21.1-20*(Log(gain)/Log(10)))
   selectcomboindex("win.gain",i)
   '/
   For i=1 To 20
   	If i=1 Then
      	addcombo("win.gain","vol"+Str(99))
   	Else 
      	addcombo("win.gain","vol"+Str(100-(i-1)*5))
      EndIf 
   Next
   i=Int(21.1-gain/5)
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

For i=1 To 100
	addcombo("win.tdecay","tdecay"+Str((i)*5))
Next
i=Int(tdecay/5+0.01)
selectcomboindex("win.tdecay",i)

For i=1 To 50
	addcombo("win.kdecay","kdec"+Left(Str((i-1)*0.01+0.5001),4))
Next
i=Int((kkdecay-0.5)/0.01+1.01)
selectcomboindex("win.kdecay",i)

For i=1 To 21
	addcombo("win.rate","rate"+Str((21-i)*5)+"%")
Next
i=Int(21.1-krate/0.05)
selectcomboindex("win.rate",i)

   quit=0
   okclose=0
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
   Print #file,krate
   Close #file
   
   'guinotice "plugin"
   guiclose()
   okclose=1
	Return 0
End Function
Function pluginclose Cdecl Alias "pluginclose" () As Integer Export
	quit=1
	Return 0
End Function 
Declare Sub subprocdecay()
Const As Integer nbuffer=4000*2
Dim Shared As Single xback,buffer(nbuffer)
Dim Shared As Double timexback,testgain=0.12,avggaindecay,gain2
Dim Shared As Integer iback,ibuffer
Dim Shared As Single xlow(9),xxlow(9),yxlow(9),yxxlow(9)
Sub removelow()
Dim As Integer i
Var i2=4,kx=0.0033
If iback And 1 Then
	For i=i2 To 1 Step -1
		xlow(i)+=(xxlow(i-1)-xlow(i))*kx'0.002'88hz
		xxlow(i)=xxlow(i-1)-xlow(i)
	Next
	xlow(0)+=(xback-xlow(0))*kx'*0.5'0.002'88hz
	xxlow(0)=xback-xlow(0)
	xback=xxlow(i2)
Else
	For i=i2 To 1 Step -1
		yxlow(i)+=(yxxlow(i-1)-yxlow(i))*kx'0.002'88hz
		yxxlow(i)=yxxlow(i-1)-yxlow(i)
	Next
	yxlow(0)+=(xback-yxlow(0))*kx'*0.5'0.002'88hz
	yxxlow(0)=xback-yxlow(0)
	xback=yxxlow(i2)
EndIf
End Sub
Function pluginproc Cdecl Alias "pluginproc" (ByVal sample As single) As Single Export
   xback=(sample+buffer(ibuffer)*0.8*krate)/(testgain)
   Var xback00=xback
   iback+=1:If iback>1 Then iback=0
   if tdecayon=1 Then
      removelow()
   	subprocdecay()
      Var gaindecay=min(1.0,gain*0.01)
    	Var tgain=gaindecay*testgain
    	tgain*=min(1.0,avggaindecay)
    	Var x30000=30000.0*tgain*tgain
    	If Abs(xback*tgain)>x30000 Then
    		Var gainx=x30000/Abs(xback)
    		gain2+=(gainx-gain2)*0.01
    		gain2=min(gainx*1.07,gain2)
    	Else 
    		gain2+=(tgain-gain2)*0.0003
    	EndIf
    	xback=max(-32700.0,min(32700.0,xback*gain2))
      buffer(ibuffer)=xback
      ibuffer+=1:If ibuffer>=nbuffer Then ibuffer=0
      Var ibuffer1=ibuffer+1
      If ibuffer1>=nbuffer Then ibuffer1=0
      xback=sample+buffer(ibuffer1)*0.8*krate
      'Var krate0=0.9
      'xback=sample*(1-krate)+krate*xback
   Else
   	xback=sample
   EndIf    
   Var xout=(xback)'*gain
   Return xout
End Function 


Dim Shared As Any Ptr hsubplugin
Sub subplugin(ByVal userdata As Any Ptr)
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
Const As Integer ndecay=800000
Dim Shared As Integer idecay,didecay,jdecay,irevdecay,irevdecay2,irevdecay0
Dim Shared As double xdecay(ndecay),xxdecay,xydecay,peekdecay,gaindecay,gainrevdecay=0.5,xrevdecay(ndecay),xdecayback
Dim Shared As Double timedecay,xxdecay0,k1000=1000,kdecay=1,xxdecay1,kdecay1=1,gaindecay1
/'Sub subprocdecay_new()
Dim As Integer i,j,k
idecay+=1:If idecay>ndecay Then idecay=1
If (idecay And 1)=0 Then
	timexback+=1/44100'samplerate
EndIf
Var xback00=xback
'gainrevdecay=0.4
Var t9300=0
irevdecay0=idecay-t9300:If irevdecay0<1 Then irevdecay0+=ndecay
irevdecay=idecay-t9300-(20000-5000)*0.01*tdecay:If irevdecay<1 Then irevdecay+=ndecay
irevdecay2=idecay-t9300-(28000-7000)*0.01*tdecay:If irevdecay2<1 Then irevdecay2+=ndecay
'xrevdecay(idecay)=xback-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)
xrevdecay(idecay)=xback
'xrevdecay(irevdecay0)=xrevdecay(irevdecay0)-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)*kkdecay/0.77
xrevdecay(irevdecay0)=xrevdecay(irevdecay0)-(xrevdecay(irevdecay)*0.4-xrevdecay(irevdecay2)*0.37)*kkdecay/0.77
'xydecay+=(xdecayback-xydecay)*0.5
xydecay+=(xback-xydecay)*0.5
xxdecay0+=(Abs(xydecay)-xxdecay0)*0.001
kdecay1+=(kdecay-kdecay1)*0.008
xxdecay1+=(max(kdecay1*Abs(xrevdecay(irevdecay0)),Abs(xydecay))-xxdecay1)*0.001
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
Var kgain4=min(1.0,1.6*xxdecay/max(4000.0,peekdecay))'*0.00006)
Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.8/testgain)),k400=100.0
'Var gain4=max(1.0,3.0*kgain4*kgain4)
'Var gain4=3.0'min(3.0,0.8/testgain)
'Var k400=100.0
If didecay>100 Then
	'jdecay=idecay-didecay/decay
	jdecay=idecay-didecay*(decay-1)/decay
	If jdecay<1 Then jdecay+=ndecay
	Var gaindecay2=min(gain4,max(k400,peekdecay-xxdecay)/max(k400,peekdecay-xdecay(jdecay)))
	gaindecay2=max(1.0,gaindecay2)
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
gaindecay1+=(gaindecay-gaindecay1)*0.01
Var g75=0.0'.75
Var g13=0.9'1.3
If gaindecay1>g13 Then'1.3
	'xback=xback*0.75+(gaindecay-0.75)*xrevdecay(idecay)
	xback=xback*g75+(gaindecay1-g75)*xrevdecay(irevdecay0)
Else
	Var k75=(gaindecay1-1)/(g13-1)
	'xback=xback*gaindecay*(1-k75)+k75*(xback*0.75+(gaindecay-0.75)*xrevdecay(idecay))
	xback=xback*gaindecay1*(1-k75)+k75*(xback*g75+(gaindecay1-g75)*xrevdecay(irevdecay0))
EndIf
xback=xback00*(1-krate)+krate*xback
'xdecayback=xback
'xback*=gaindecay
End Sub
Sub subprocdecay_old()
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
kdecay1+=(kdecay-kdecay1)*0.008
xxdecay1+=(max(kdecay1*Abs(xrevdecay(irevdecay0)),Abs(xydecay))-xxdecay1)*0.001
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
Var kgain4=min(1.0,2.0*xxdecay/max(4000.0,peekdecay))'*0.00006)
Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.8/testgain))
'Var gain4=max(1.0,3.0*kgain4*kgain4)
Var k400=100.0
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
gaindecay1+=(gaindecay-gaindecay1)*0.01
Var g75=0.75
Var g13=1.3
If gaindecay1>g13 Then'1.3
	'xback=xback*0.75+(gaindecay-0.75)*xrevdecay(idecay)
	xback=xback*g75+(gaindecay1-g75)*xrevdecay(irevdecay0)
Else
	Var k75=(gaindecay1-1)/(g13-1)
	'xback=xback*gaindecay*(1-k75)+k75*(xback*0.75+(gaindecay-0.75)*xrevdecay(idecay))
	xback=xback*gaindecay1*(1-k75)+k75*(xback*g75+(gaindecay1-g75)*xrevdecay(irevdecay0))
EndIf
xback=xback00*(1-krate)+krate*xback
'xdecayback=xback
'xback*=gaindecay
End Sub
'/
Const As Integer ndecaZ=ndecay
Dim Shared As Integer idecaZ,didecaZ,jdecaZ,irevdecaZ,irevdecaZ2,irevdecaZ0
Dim Shared As double xdecaZ(ndecaZ),xxdecaZ,xydecaZ,peekdecaZ,gaindecaZ,gainrevdecaZ=0.5,xrevdecaZ(ndecaZ),xdecaZback
Dim Shared As Double timedecaZ,xxdecaZ0,kdecaZ=1,xxdecaZ1,kdecaZ1=1,gaindecaZ1
Dim Shared As Double avgxdecay,avgxdecay2,avgxdecay1,avggaindecay2,avgx100=100
Dim Shared As Double kkdecay100=10,kxback,ky1000=1000,kz1000=1000
Sub setavggaindecay()
avgxdecay2+=(avgxdecay1*0.985-avgxdecay2)*0.001*max(1.0,3-avggaindecay2)
avgxdecay+=(avgxdecay1+50-25-avgxdecay)*0.002*2
avgxdecay1+=(Abs(xback)-avgxdecay1)*0.003
avgx100+=(max(100.0,avgxdecay*0.05+80)-avgx100)*0.1
If avgxdecay2<avgxdecay Then
	avggaindecay+=(avgx100/(avgx100+avgxdecay-avgxdecay2)-avggaindecay)*0.02
	avggaindecay=max(avggaindecay,0.85)
Else 	
	avggaindecay+=((avgx100+avgxdecay2-avgxdecay)/avgx100-avggaindecay)*0.01
	avggaindecay=min(avggaindecay,1.99)
EndIf	
kxback=max(0.05,min(3.0,avgxdecay*0.001))
'kkdecay100=19*0.07/(1.06-kkdecay)
avggaindecay2=min(3.0,avggaindecay*2)
'If avggaindecay<1 Then xback*=avggaindecay*avggaindecay
'auxvar4=avggaindecay
'auxvar2=Int(avgxdecay)
'auxvar3=avgx100
End Sub
Sub subprocdecaZ()
Dim As Integer i,j,k
idecaZ+=1:If idecaZ>ndecaZ Then idecaZ=1
Var xback00=xback
'gainrevdecaZ=0.4
Var tdecaZ=tdecay
Var kkdecaZ=kkdecay
Var i9300=19300
Var kkdecaZ2=kkdecay'*(kkdecay100+avggaindecay)/(kkdecay100+1)
irevdecaZ0=idecaZ-i9300:If irevdecaZ0<1 Then irevdecaZ0+=ndecaZ
irevdecaZ=idecaZ-i9300-(20000-5000)*0.01*tdecaZ:If irevdecaZ<1 Then irevdecaZ+=ndecaZ
irevdecaZ2=idecaZ-i9300-(28000-7000)*0.01*tdecaZ:If irevdecaZ2<1 Then irevdecaZ2+=ndecaZ
'xrevdecaZ(idecaZ)=xback-(xrevdecaZ(irevdecaZ)*0.4+xrevdecaZ(irevdecaZ2)*0.37)
xrevdecaZ(idecaZ)=xback*avggaindecay2
xrevdecaZ(irevdecaZ0)=xrevdecaZ(irevdecaZ0)-(xrevdecaZ(irevdecaZ)*0.4+xrevdecaZ(irevdecaZ2)*0.37)*kkdecaZ2/0.77
'xydecaZ+=(xdecaZback-xydecaZ)*0.5
xydecaZ+=(xback-xydecaZ)*0.5
xxdecaZ0+=(Abs(xydecaZ)-xxdecaZ0)*0.001
kdecaZ1+=(kdecaZ-kdecaZ1)*0.008
xxdecaZ1+=(max(kdecaZ1*Abs(xrevdecaZ(irevdecaZ0)),Abs(xydecaZ))-xxdecaZ1)*0.001
xxdecaZ+=(xxdecaZ1-xxdecaZ)*0.003
'xxdecaZ+=(Abs(xydecaZ)-xxdecaZ)*0.001
'Var k100=100.0'max(100.0,Abs(xback)*0.01)
If Abs(xback)>xxdecaZ+200*kxback Then
	xxdecaZ1=Abs(xback)'+100*kxback
	xxdecaZ=xxdecaZ1
	timedecaZ=Timexback
	kdecaZ=1
EndIf
xdecaZ(idecaZ)=xxdecaZ	
Var decaZ=decay
If decaZ<1 Then
	decaZ=1
	decay=1
EndIf
If peekdecaZ<xxdecaZ-150*kxback Or Timexback>timedecaZ+7 Then
	peekdecaZ=xxdecaZ
	didecaZ=0
Else
	peekdecaZ-=0.03*(peekdecaZ*0.0001/decaZ)
	didecaZ+=1
	If didecaZ>ndecaZ-2 Then didecaZ=ndecaZ-2
EndIf
Var kgain4=min(1.0,2.0*xxdecaZ/max(4000.0,peekdecaZ))'*0.00006)
Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.85/testgain)),k400=100.0
'Var gain4=max(1.0,3.0*kgain4*kgain4)
'Var k400=100.0
If didecaZ>150 Then'100
	'jdecaZ=idecaZ-didecaZ/decaZ
	jdecaZ=idecaZ-didecaZ*(decaZ-1)/decaZ
	If jdecaZ<1 Then jdecaZ+=ndecaZ
	Var gaindecaZ2=max(1.0,min(gain4,max(k400,peekdecaZ-xxdecaZ)/max(k400,peekdecaZ-xdecaZ(jdecaZ))))
	'Var gaindecaZ1=max(0.1,min(4.0,max(400.0,xdecaZ(jdecaZ))/max(400.0,xxdecaZ)))
	'gaindecaZ2=max(gaindecaZ1,gaindecaZ2)
	If xxdecaZ0<kz1000 Then
		kz1000=2000
      gaindecaZ2=1
      kdecaZ=max(0.01,kdecaZ-0.0001)
      'kdecaZ=max(0.0,kdecaZ-0.001)
	Else
		kz1000=1000
 	EndIf
	If gaindecaZ<gaindecaZ2 Then
		gaindecaZ+=(gaindecaZ2-gaindecaZ)*0.004
	Else 	
		gaindecaZ+=(gaindecaZ2-gaindecaZ)*0.003
	EndIf
Else
	gaindecaZ+=(1-gaindecaZ)*0.003
EndIf
'If gaindecaZ>1.2 Then
'	gainrevdecaZ=min(0.7,gainrevdecaZ+0.000001)
'ElseIf gaindecaZ<1.1 Then 	
'	gainrevdecaZ=max(0.0,gainrevdecaZ-0.000001)
'EndIf
gaindecaZ1+=(gaindecaZ-gaindecaZ1)*0.01
Var g75=0.75
Var g13=1.3
If gaindecaZ1>g13 Then'1.3
	'xback=xback*0.75+(gaindecaZ-0.75)*xrevdecaZ(idecaZ)
	xback=xback*g75+(gaindecaZ1-g75)*xrevdecaZ(irevdecaZ0)
Else
	Var k75=(gaindecaZ1-1)/(g13-1)
	'xback=xback*gaindecaZ*(1-k75)+k75*(xback*0.75+(gaindecaZ-0.75)*xrevdecaZ(idecaZ))
	xback=xback*gaindecaZ1*(1-k75)+k75*(xback*g75+(gaindecaZ1-g75)*xrevdecaZ(irevdecaZ0))
EndIf
'xdecaZback=xback
'xback*=min(1.0,avggaindecay)
End Sub
Sub subprocdecay()
setavggaindecay()
If iback And 1 Then
	subprocdecaZ()
	Exit Sub  
EndIf
Dim As Integer i,j,k
idecay+=1:If idecay>ndecay Then idecay=1
Var xback00=xback
'gainrevdecay=0.4
Var i9300=19300
Var kkdecay2=kkdecay*(kkdecay100+avggaindecay)/(kkdecay100+1)
irevdecay0=idecay-i9300:If irevdecay0<1 Then irevdecay0+=ndecay
irevdecay=idecay-i9300-(20000-5000)*0.01*tdecay:If irevdecay<1 Then irevdecay+=ndecay
irevdecay2=idecay-i9300-(28000-7000)*0.01*tdecay:If irevdecay2<1 Then irevdecay2+=ndecay
'xrevdecay(idecay)=xback-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)
xrevdecay(idecay)=xback*avggaindecay2
xrevdecay(irevdecay0)=xrevdecay(irevdecay0)-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)*kkdecay2/0.77
'xydecay+=(xdecayback-xydecay)*0.5
xydecay+=(xback-xydecay)*0.5
xxdecay0+=(Abs(xydecay)-xxdecay0)*0.001
kdecay1+=(kdecay-kdecay1)*0.008
xxdecay1+=(max(kdecay1*Abs(xrevdecay(irevdecay0)),Abs(xydecay))-xxdecay1)*0.001
xxdecay+=(xxdecay1-xxdecay)*0.003
'xxdecay+=(Abs(xydecay)-xxdecay)*0.001
'Var k100=100.0'max(100.0,Abs(xback)*0.01)
If Abs(xback)>xxdecay+200*kxback Then
	xxdecay1=Abs(xback)'+100*kxback
	xxdecay=xxdecay1
	timedecay=Timexback
	kdecay=1
EndIf
xdecay(idecay)=xxdecay	
If decay<1 Then decay=1
If peekdecay<xxdecay-150*kxback Or Timexback>timedecay+7 Then
	peekdecay=xxdecay
	didecay=0
Else
	peekdecay-=0.03*(peekdecay*0.0001/decay)
	didecay+=1
	If didecay>ndecay-2 Then didecay=ndecay-2
EndIf
Var kgain4=min(1.0,2.0*xxdecay/max(4000.0,peekdecay))'*0.00006)
Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.85/testgain)),k400=100.0
'Var gain4=max(1.0,3.0*kgain4*kgain4)
'Var k400=100.0
If didecay>150 Then'100
	'jdecay=idecay-didecay/decay
	jdecay=idecay-didecay*(decay-1)/decay
	If jdecay<1 Then jdecay+=ndecay
	Var gaindecay2=max(1.0,min(gain4,max(k400,peekdecay-xxdecay)/max(k400,peekdecay-xdecay(jdecay))))
	'Var gaindecay1=max(0.1,min(4.0,max(400.0,xdecay(jdecay))/max(400.0,xxdecay)))
	'gaindecay2=max(gaindecay1,gaindecay2)
	If xxdecay0<ky1000 Then
		ky1000=2000
      gaindecay2=1
      kdecay=max(0.01,kdecay-0.0001)
      'kdecay=max(0.0,kdecay-0.0001)
	Else
		ky1000=1000
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
gaindecay1+=(gaindecay-gaindecay1)*0.01
Var g75=0.75
Var g13=1.3
If gaindecay1>g13 Then'1.3
	'xback=xback*0.75+(gaindecay-0.75)*xrevdecay(idecay)
	xback=xback*g75+(gaindecay1-g75)*xrevdecay(irevdecay0)
Else
	Var k75=(gaindecay1-1)/(g13-1)
	'xback=xback*gaindecay*(1-k75)+k75*(xback*0.75+(gaindecay-0.75)*xrevdecay(idecay))
	xback=xback*gaindecay1*(1-k75)+k75*(xback*g75+(gaindecay1-g75)*xrevdecay(irevdecay0))
EndIf
'xdecayback=xback
'xback*=min(1.0,avggaindecay)
End Sub











