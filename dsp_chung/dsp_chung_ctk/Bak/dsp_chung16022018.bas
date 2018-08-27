'waveinout a waveinout example
'
#Include once "windows.bi"
#Include Once "gui_chung.bi"
#Include once "win/mmsystem.bi"
#Include once "crt/string.bi"
#Include "wavein.bi"
#Include "waveout.bi"
'#Include Once "mixer.bi"
    
Sub notice(ByRef msg As string,ByRef title As String ="notice")
	guinotice(msg,title)
End Sub
Sub confirm(ByRef msg As string,ByRef title As string,ByRef resp As String)
   guiconfirm(msg,title,resp)
End Sub 
Var hprocess=GetCurrentProcess()
'SetpriorityClass (hprocess, ABOVE_NORMAL_PRIORITY_CLASS)
Var retc=SetpriorityClass (hprocess, HIGH_PRIORITY_CLASS)

Dim Shared As Integer winx,winy,windx,windy,file,i,j,k,n,p
Dim Shared As Single gain

Dim As String ficin
Dim As String ficini="dsp_chung.ini"
file=FreeFile
Open ficini For Input As #file
winx=10:winy=10
If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
mydev=-1
If Not Eof(file) Then Line Input #file,ficin:mydev=Val(ficin)
mydevout=-1
If Not Eof(file) Then Line Input #file,ficin:mydevout=Val(ficin)
gain=1
If Not Eof(file) Then Line Input #file,ficin:gain=Val(ficin)
buffersize=400
If Not Eof(file) Then Line Input #file,ficin:buffersize=Val(ficin)
Close #file

Dim Shared As Integer quit,restart,play
Sub subquit
	quit=1
End Sub
Sub submsg()
End Sub
Sub subedittext()
End Sub
Sub subplay()
If play=0 Then
	play=1:printgui("win.play","stop")
Else
	play=0:printgui("win.play","play")
EndIf
End Sub
Sub subwavein()
Dim As Integer i
getcomboindex("win.wavein",i)
mydev=i-2 '-1=mapper
quit=1:restart=1
End Sub
Sub subwaveout()
Dim As Integer i
getcomboindex("win.waveout",i)
mydevout=i-2 '-1=mapper
quit=1:restart=1
End Sub
Sub subgain()
Dim As Integer i
getcomboindex("win.gain",i)
gain=max(0.0,min(1.0,(i-1)/20))
Sleep 200
End Sub
Sub subbuffersize()
Dim As Integer i
getcomboindex("win.buffersize",i)
buffersize=max2(150,min2(4000,150+(i-1)*50))
guisetfocus("win.msg")
Sleep 500
quit=1:restart=1
End Sub

' Program start
Dim Shared As Integer wx,wy
ScreenInfo wx,wy
winx=max2(0,min2(wx-500,winx))
winy=max2(0,min2(wy-350,winy)) 
guibackgroundcolor(50,255,50)
guiedittextbackcolor(220,170,255)
guiedittextinkcolor(0,0,100)
button("win.button1","quit",@subquit,10,10,60,24)
combobox("win.wavein",@subwavein,90,10,256,200)
combobox("win.buffersize",@subbuffersize,356,10,80,500)
combobox("win.waveout",@subwaveout,90,170,256,200)
combobox("win.gain",@subgain,356,170,70,500)
edittext("win.msg","",@submsg,10,40,473,120,es_multiline+WS_VSCROLL)
'edittext("win.edittext","",@subedittext,10,240,400,20,ES_LEFT+es_multiline+WS_VSCROLL)
button("win.play","play",@subplay,10,170,60,24)
openwindow("win","waveinout_chung",winx,winy,500,330) 

trapclose("win",@subquit)
guisetfocus("win")
guisetfocus("win.edittext")
reloadcombo("win.wavein",myname())
selectcomboindex("win.wavein",mydev+2)
reloadcombo("win.waveout",mynameout())
selectcomboindex("win.waveout",mydevout+2)
addmenu("win.menu","menu")  'the same thing, with guimenu

For i=1 To 21
	addcombo("win.gain","vol"+Str((i-1)*5))
Next
i=Int(1+gain*20+0.01)
selectcomboindex("win.gain",i)

For i=1 To 21
	addcombo("win.buffersize","buf"+Str(150+(i-1)*50))
Next
i=Int(1+(buffersize-150)/50+0.01)
selectcomboindex("win.buffersize",i)

Dim Shared As hwnd winmsgh
winmsgh=getguih("win.msg")

Dim Shared As WAVEIN_DEVICE mywavein
Dim Shared As WAVEout_DEVICE mywaveout

lrestart:
restart=0:quit=0
mywavein.wstart(mydev)
mywaveout.wstart(mydevout)
'guinotice "now    volume:" & mixer.WaveinVolume

While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 50
	If guitestkey(vk_space) Then
		If getfocus()=winmsgh Then quit=1
	EndIf
Wend

mywavein.wclose()
mywaveout.wclose()
Sleep 1000

If restart=1 Then restart=0:quit=0:Sleep 100:GoTo lrestart

guigetwindowpos("win",winx,winy,windx,windy)
file=freefile
Open ficini For Output As #file
Print #file,winx
Print #file,winy
Print #file,mydev
Print #file,mydevout
Print #file,gain
Print #file,buffersize
Close #file

guiclose()
guiquit()

End

Dim Shared As Double timemsg
Sub mysubsample()
Dim As Integer i,j,k
For i=0 To mynsamples-1
	isample+=1
	If isample>=nsample Then isample=0
	mysamples(isample)=mypsamples[i]
Next
Var okout=0	
With mywaveout 
j=0
For i=1 To nbuffer
 If .bufferbusy(i-1)=0 Then j+=1
Next i
If play=1 Then
 For i=1 To nbuffer
  .ibuffer=(.ibuffer+1)Mod .nbuffers
  If .bufferbusy(.ibuffer)=0 Then 
    .bufferbusy(.ibuffer)=1
    'memcpy(.Buffers[.ibuffer]->lpData,mypsamples,mynsamples)
    Dim As Short Ptr pbuffer=cptr(short ptr,.Buffers[.ibuffer]->lpData)
    For k=0 To mynsamples-1
    	pbuffer[k]=CShort(Int(max(-32700.0,min(32700.0,mypsamples[k]*gain))))
    Next k
    waveOutPrepareHeader(.hDevice,.Buffers[.ibuffer],sizeof(WAVEHDR))
    waveOutWrite(.hDevice,.Buffers[.ibuffer],sizeof(WAVEHDR))
    okout=1:Exit For 
  EndIf 
 Next i
EndIf 
End With 
If Timer>timemsg+0.2 Then
 timemsg=Timer 
 msg="freeout="+Str(j)+"/"+Str(mynsamples)+"/"+Str(mypsamples[0])
 If play=1 Then msg+=crlf+"out="+Str(okout)
 msg+=crlf+errtext
 printguih(winmsgh,msg)
EndIf  
End Sub
Sub setmixer()
End Sub
