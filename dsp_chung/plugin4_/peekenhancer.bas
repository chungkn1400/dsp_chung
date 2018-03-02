' mypeekenhancer.bas  by NGUYEN.Chung (2012)
' compile with: fbc -dll myplugin.bas
'
' plugin example for midipiano_chung
'
#Include Once "windows.bi"
'#Define  noguijpeg  'if you use it add jpeg.dll in the main host exe dir
#Include "gui_chung.bi"


Dim Shared As Integer quit=0,i
Dim Shared As Single vol,gain,auxvar
Dim Shared As Integer mypeek=1,peekenhancer,rate,peekmaster
Sub subquit()
	quit=1
End Sub
Dim Shared As String textvol(100),texvol,textpeek(100),texpeek
Dim Shared As String textrate(100),texrate
For i=0 To 20
	textvol(i)=Str(10-i)
Next
For i=0 To 49
	textpeek(i)=Str(100000-i*2000)
Next
For i=1 To 5
	textpeek(i+49)=Str(2000-i*200)
Next
For i=1 To 9
	textpeek(i+54)=Str(1000-i*100)
Next
For i=0 To 38
	textrate(i)=Str(200-i*5)
Next
Dim Shared As Integer mousex,mousey,skin
Dim Shared As UInteger mycolor,mycolor0
Dim Shared As Any Ptr buffgraph,buffgraph2,buffgraph0,imgskin
Sub setpeek()
	mypeek=max2(mypeek,100)
	gain=10^(vol/20)
	rate=max2(10,min2(200,rate))
   texvol=Str(Int(vol))
   selectcombotext("win.vol",texvol,textvol())
   texpeek=Str(Int(mypeek))
   selectcombotext("win.peek",texpeek,textpeek())
   texrate=Str(Int(rate))
   selectcombotext("win.rate",texrate,textrate())
   Var r=(mycolor Shr 16)And 255
   Var g=(mycolor Shr 8)And 255
   Var b=mycolor And 255 
   guibackgroundcolor(r,g,b)'(250,200,0)
   If skin=0 Then 
   	If buffgraph0<>0 Then Line buffgraph0,(0,0)-(300,150),mycolor,bf
   Else
   	If imgskin<>0 Then Put buffgraph0,(0,0),imgskin,PSet 
   EndIf
   guirefreshwindow("win")
   Sleep 200   
End Sub
Sub subvol()
	texvol=getcombotext("win.vol",textvol())
	vol=Val(texvol)
	gain=10^(vol/20)
setpeek()
End Sub
Sub subpeek()
	texpeek=getcombotext("win.peek",textpeek())
	mypeek=Val(texpeek)
setpeek()
End Sub
Sub subrate()
	texrate=getcombotext("win.rate",textrate())
	rate=Val(texrate)
setpeek()
End Sub
Sub subpeekenhancer()
	If peekenhancer=1 Then 
		peekenhancer=0:unsetcheckbox("win.peekenhancer")
	Else 
		peekenhancer=1:setcheckbox("win.peekenhancer")
	EndIf
setpeek()
End Sub
Sub subpeekmaster()
	If peekmaster=1 Then 
		peekmaster=0:unsetcheckbox("win.peekmaster")
	Else 
		peekmaster=1:setcheckbox("win.peekmaster")
	EndIf
setpeek()
End Sub
Dim Shared As String curdir1
Sub subsave()
Dim As String fic,resp,dir0
Dim As Integer ret,file
dir0=CurDir  
ret=ChDir(curdir1+"\save")
fic=filedialog("save","*.peek")
ret=ChDir(dir0)
fic=Trim(fic)
If fic="" Then Exit Sub 
If InStr(fic,".")=0 Then fic+=".peek"
If LCase(Right(fic,5))<>".peek" Then guinotice "bad name "+fic:Exit Sub 
guiconfirm("save in "+fic+" ?","save",resp)
If resp="yes" Then
   file=freefile
   Open fic For Output As #file
   Print #file,mypeek
   Print #file,rate
   Close #file
 	guinotice "peek saved as "+fic
EndIf
End Sub
Sub subload()
Dim As String fic,resp,ficin,dir0
Dim As Integer ret,file
dir0=CurDir  
ret=ChDir(curdir1+"\save")
fic=filedialog("load","*.peek")
ret=ChDir(dir0)
fic=Trim(fic)
If fic="" Then Exit Sub 
If InStr(fic,".")=0 Then fic+=".peek"
If LCase(Right(fic,5))<>".peek" Then guinotice "bad name "+fic:Exit Sub 
If FileExists(fic)=0 Then guinotice "not found :"+fic:Exit Sub 
guiconfirm("load "+fic+" ?","load",resp)
If resp="yes" Then
   file=FreeFile
   Open fic For Input As #file
   If Not Eof(file) Then Line Input #file,ficin:mypeek=Val(ficin)
   If Not Eof(file) Then Line Input #file,ficin:rate=Val(ficin)
   Close #file
   setpeek() 
EndIf
End Sub
Dim Shared As Integer File,winx,winy,wx,wy,depth,windx,windy,quit2
Sub subdone()
quit2=2
End Sub
Sub subquit2
quit2=1
End Sub
Sub colormouse()
mousex=guimousex
mousey=guimousey
mycolor=Point(mousex,mousey,buffgraph)
Var r=(mycolor Shr 16)And 255
Var g=(mycolor Shr 8)And 255
Var b=mycolor And 255
guibackgroundcolor(r,g,b)'(250,200,0)
Line buffgraph2,(0,0)-(100,50),mycolor,bf
guirefreshwindow("win2")
Line buffgraph0,(0,0)-(300,150),mycolor,bf
guirefreshwindow("win")
End Sub
Sub subresetcolor()
mycolor=RGB(250,200,0)
Var r=(mycolor Shr 16)And 255
Var g=(mycolor Shr 8)And 255
Var b=mycolor And 255
guibackgroundcolor(r,g,b)'(250,200,0)
Line buffgraph2,(0,0)-(100,50),mycolor,bf
guirefreshwindow("win2")
Line buffgraph0,(0,0)-(300,150),mycolor,bf
guirefreshwindow("win")
End Sub
Sub subcolor()
Dim As Integer i,j,k,r,g,b
setpeek()
mycolor0=mycolor
graphicbox("win2.graph",1,1,300,240)
graphicbox("win2.graph2",170,245,50,25)
button("win2.done","done",@subdone,10,246,40,22)
button("win2.reset","reset",@subresetcolor,60,246,40,22)
button("win2.quit","quit",@subquit2,110,246,40,22)
openwindow("win2","chooze color (click mouse)", _  
            min2(wx-302,winx+300),min2(wy-302,winy+150),302,302,,WS_EX_TOPMOST)

trapclose("win2",@subquit2)
trapLeftmouse("win2.graph",@colormouse)
quit2=0
buffgraph=getguigfxbuffer("win2.graph")
buffgraph2=getguigfxbuffer("win2.graph2")
For i=0 To 300
	For j=0 To 240
		r=255*abs(150-i)/150
		g=255*(i/300)
		b=255*(j/240)^2
		PSet buffgraph,(i,j),RGB(r,g,b) 
	Next
Next
Line buffgraph2,(0,0)-(100,50),mycolor,bf
guirefreshwindow("win2")
While quit=0 And guitestkey(vk_escape)=0 And quit2=0
	guiscan
	Sleep 100
Wend
guiclosewindow("win2")
If quit2<>2 Then
	mycolor=mycolor0
Else
	skin=0
EndIf
setpeek()
Sleep 300
guiscan
End Sub
Sub nextskin()
Dim As Integer i
For i=1 To 20
 skin+=1:If skin>20 Then skin=0
 If skin=0 Then Exit For 
 If FileExists(curdir1+"/skin/skin"+Str(skin)+".jpg") Then
  	guibloadresize(imgskin,curdir1+"/skin/skin"+Str(skin)+".jpg")
	Exit For 
 EndIf
Next i
guirefreshwindow("win")
setpeek()
End Sub 
Sub prevskin()
Dim As Integer i
For i=1 To 20
 skin-=1:If skin<0 Then skin=20
 If skin=0 Then Exit For 
 If FileExists(curdir1+"/skin/skin"+Str(skin)+".jpg") Then
  	guiBloadresize(imgskin,curdir1+"/skin/skin"+Str(skin)+".jpg")
	Exit For 
 EndIf
Next i
guirefreshwindow("win")
setpeek()
End Sub
'If skin<>0 Then
' If FileExists(curdir1+"/skin/skin"+Str(skin)+".jpg") Then
'  	guiBLoadimg(curdir1+"/skin/skin"+Str(skin)+".jpg",imgskin) 
' EndIf	
'EndIf

Dim Shared As String ficin,windowname
dim Shared As String ficini:ficini="peekenhancer.ini"
Function plugininit Cdecl Alias "plugininit" () As Integer Export
Dim As ZString*255 dllname
GetModuleFileName(guihinstance, dllname, 250)
curdir1=Left(dllname,InStrRev(dllname,"\")-1)
ficini=CurDir1+"/peekenhancer.ini" 
vol=1
If FileExists(ficini)=0 Then Return 1
file=FreeFile
Open ficini For Input As #file
winx=200:winy=100
If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
vol=0
If Not Eof(file) Then Line Input #file,ficin:vol=Val(ficin)
mypeek=32000
If Not Eof(file) Then Line Input #file,ficin:mypeek=Val(ficin)
peekenhancer=0
If Not Eof(file) Then Line Input #file,ficin:peekenhancer=Val(ficin)
rate=100
If Not Eof(file) Then Line Input #file,ficin:rate=Val(ficin)
mycolor=RGB(250,200,0)
If Not Eof(file) Then Line Input #file,ficin:mycolor=Val(ficin)
skin=2
If Not Eof(file) Then Line Input #file,ficin:skin=Val(ficin)
peekmaster=0
If Not Eof(file) Then Line Input #file,ficin:peekmaster=Val(ficin)
Close #file
setpeek()
Return 0
End Function 
Dim Shared As Any ptr wingraphbuffer
Dim Shared As Single ypeek=1,log10=Log(10)
Sub drawpeek()
Var iy=(33)*Log((Abs(ypeek*9000)+0.01)/Sqr(mypeek+0.01))/log10
Var ix=Int(max(1.1,min(120.1,iy)))
Line wingraphbuffer,(0,0)-(ix,3),RGB(0,255,0),bf
Line wingraphbuffer,(ix,0)-(120,3),RGB(0,130,130),bf
guirefreshwindow("win")
'redrawwindow(hwin,0,0,RDW_INVALIDATE )
End Sub
Dim Shared As hwnd hwin 
Function pluginmain Cdecl Alias "pluginmain" () As Integer Export
	windowname=Mid(curdir1,InStrRev(curdir1,"\")+1)+"/peekenhancer.dll"
	'guinotice curdir1
	guireset() 
	'guibackgroundcolor(250,200,0)
	'mycolor=RGB(250,200,0)
   Var r=(mycolor Shr 16)And 255
   Var g=(mycolor Shr 8)And 255
   Var b=mycolor And 255
   guibackgroundcolor(r,g,b)'(250,200,0)
   ScreenInfo wx,wy,depth
	If winx<0 Then winx=0
	If winx>(wx-300) Then winx=wx-300
	If winy<0 Then winy=0
	If winy>(wy-150) Then winy=wy-150
   button("win.quit","quit",@subquit,20,70,50,30)
   statictext("win.tvol","gain(db)",20,4,60,16)
   combobox("win.vol",@subvol,20,23,60,300)
   statictext("win.tpeek","peek",100,4,60,16)
   combobox("win.peek",@subpeek,100,23,80,300)
   statictext("win.trate","rate%",200,4,60,16)
   combobox("win.rate",@subrate,200,23,60,300)
   checkbox("win.peekenhancer","peekenhancer",@subpeekenhancer,145,75,120,20)
   checkbox("win.peekmaster","peekmaster",@subpeekmaster,145,98,120,20)
   statictext("win.msg","",145,53,140,16)
   button("win.load","load",@subload,80,72,38,18)   
   button("win.save","save",@subsave,80,92,38,18)
	graphicbox("win.back",0,0,1,1)'1,1,300,150)
   'graphicbox("win.graph",120,105,115,4)
   openwindow("win",windowname,winx,winy,300,150)
   
   trapclose("win",@subquit)
   reloadcombo("win.vol",textvol())
   texvol=Str(Int(vol))
   selectcombotext("win.vol",texvol,textvol())
   reloadcombo("win.peek",textpeek())
   texpeek=Str(Int(mypeek))
   selectcombotext("win.peek",texpeek,textpeek())
   reloadcombo("win.rate",textrate())
   texrate=Str(Int(rate))
   selectcombotext("win.rate",texrate,textrate())
   If peekenhancer=1 Then setcheckbox("win.peekenhancer")
   If peekmaster=1 Then setcheckbox("win.peekmaster")
   guisetfocus("win.vol")
   'wingraphbuffer=getguigfxbuffer("win.graph")
   guimovecontrol("win.back",1,1,300,150)
   buffgraph0=getguigfxbuffer("win.back")
   imgskin=ImageCreate(300,150)

   If skin<>0 Then
    If FileExists(curdir1+"/skin/skin"+Str(skin)+".jpg") Then
  	   guiBLoadresize(imgskin,curdir1+"/skin/skin"+Str(skin)+".jpg") 
    EndIf
    guirefreshwindow("win")
   EndIf   
   setpeek()

   hwin=getguih("win")
   quit=0
   While guitestkey(vk_escape)=0 And quit=0
   	guiscan
   	Sleep 100
   	If Abs(auxvar)>1e-10 Then printgui("win.msg",Str(auxvar)+"   ")
   	If hwin=getactivewindow() Then 
      	If guitestkey(vk_c) Then
      		If guitestkey(vk_control) Then
      			subcolor()
      		Else
      			nextskin()
      		EndIf
      	EndIf
      	If guitestkey(vk_x) Then prevskin()
      	If guitestkey(vk_f1) Then
   	   	Var msg="peekenhancer",cr=Chr(13)+Chr(10)
   		   msg+=cr+"F1 => help"
   		   msg+=cr+"X/C     => prev/next skin"
   		   msg+=cr+"ctrl+C  => change color"
   		   guinotice msg,"help"
   	   EndIf    
      EndIf
   	'drawpeek()
	   'Var xpeek=Rnd*mypeek
	   'ypeek=(rate/100.0)*(Int(xpeek)-xpeek)
   Wend
   
   ImageDestroy(imgskin)
   
   guigetwindowpos("win",winx,winy,windx,windy)
   file=freefile
   Open ficini For Output As #file
   Print #file,winx
   Print #file,winy
   Print #file,vol
   Print #file,mypeek
   Print #file,peekenhancer
   Print #file,rate
   Print #file,mycolor
   Print #file,skin
   Print #file,peekmaster
   Close #file
   
   'guinotice "plugin"
   guiclose()
	Return 0
End Function
Function pluginclose Cdecl Alias "pluginclose" () As Integer Export
	quit=1
	Return 0
End Function
Dim Shared As Single kpeekmaster=1,xpeekmaster,ypeekmaster
Dim Shared As Double tpeekmaster
Dim Shared As Integer tsample2
Function peekmasterproc(ByVal sample As Single) As Single
ypeekmaster=sample*kpeekmaster
If Abs(ypeekmaster)>xpeekmaster Then xpeekmaster=Abs(ypeekmaster)
tsample2+=1
If tsample2>1000 Then
  tsample2=0
  If xpeekmaster>27000*mypeek/32760 Then
  	  kpeekmaster*=0.5
  	  If xpeekmaster>mypeek Then
  	  	  kpeekmaster*=0.6
  	  	  tpeekmaster=Timer 
  	  EndIf
  EndIf
  If xpeekmaster<20000*mypeek/32760 Then
  	  If Timer>tpeekmaster+7 Or Timer<tpeekmaster-99 Then 
  	  	  kpeekmaster*=1.2
  	  EndIf
  EndIf
  'If kpeekmaster<0.79 Then kpeekmaster=0.79
  'If kpeekmaster>12.0 Then kpeekmaster=12.0
  If kpeekmaster<0.1 Then kpeekmaster=0.1
  If kpeekmaster>1200000.0 Then kpeekmaster=1200000.0
  xpeekmaster=1
EndIf 
Return Int(ypeekmaster)/kpeekmaster
End Function
Dim Shared As Single kpeek=1,mypeek1=1,xpeek,xsample
Dim Shared As Integer tsample
Function pluginproc Cdecl Alias "pluginproc" (ByVal sample As single) As Single Export
	If peekmaster=1 Then
		xsample=peekmasterproc(sample) 
	Else
		xsample=sample
	EndIf
	If peekenhancer=0 Then Return gain*xsample
	If Abs(xsample)>mypeek1 Then
		mypeek1=Abs(xsample)
	EndIf
	tsample+=1
	If tsample>1000 Then
		tsample=0
   	kpeek=mypeek/mypeek1
		If mypeek1>0.00003 Then mypeek1*=0.9
	EndIf
	xpeek=kpeek*xsample
	ypeek=(rate/100.0)*(Int(xpeek)-xpeek)
   Return (gain/kpeek)*(xpeek+ypeek)
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
