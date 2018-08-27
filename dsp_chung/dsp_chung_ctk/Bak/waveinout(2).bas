'waveinout a waveinout example
'
    #include once "windows.bi"
    #Include Once "gui_chung.bi"
    #include once "win/mmsystem.bi"
    #Include once "crt/string.bi"
    #Include "wavein.bi"
    #Include "waveout.bi"
    
Sub notice(ByRef msg As string,ByRef title As String ="notice")
	guinotice(msg,title)
End Sub
Sub confirm(ByRef msg As string,ByRef title As string,ByRef resp As String)
   guiconfirm(msg,title,resp)
End Sub 
Function max2(ByVal x As Single,ByVal y As Single)As Single
	If x>=y Then Return x Else Return y
End Function
Function min2(ByVal x As Single,ByVal y As Single)As Single
	If x<=y Then Return x Else Return y
End Function


Dim Shared As Integer winx,winy,windx,windy,file

Dim As String ficin
Dim As String ficini="wavein.ini"
file=FreeFile
Open ficini For Input As #file
winx=10:winy=10
If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
mydev=-1
If Not Eof(file) Then Line Input #file,ficin:mydev=Val(ficin)
mydevout=-1
If Not Eof(file) Then Line Input #file,ficin:mydevout=Val(ficin)
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
Sub subcombo()
Dim As Integer i
getcomboindex("win.combo",i)
mydev=i-2 '-1=mapper
quit=1:restart=1
End Sub
Sub subcombo2()
Dim As Integer i
getcomboindex("win.combo2",i)
mydevout=i-2 '-1=mapper
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
combobox("win.combo",@subcombo,100,10,256,200)
combobox("win.combo2",@subcombo2,100,170,256,200)
edittext("win.msg","",@submsg,10,40,473,120,es_multiline+WS_VSCROLL)
'edittext("win.edittext","",@subedittext,10,240,400,20,ES_LEFT+es_multiline+WS_VSCROLL)
button("win.play","play",@subplay,10,170,60,24)
openwindow("win","waveinout_chung",winx,winy,500,330) 

trapclose("win",@subquit)
guisetfocus("win")
guisetfocus("win.edittext")
reloadcombo("win.combo",myname())
selectcomboindex("win.combo",mydev+2)
reloadcombo("win.combo2",mynameout())
selectcomboindex("win.combo2",mydevout+2)
addmenu("win.menu","menu")  'the same thing, with guimenu

Dim Shared As WAVEIN_DEVICE mywavein
Dim Shared As WAVEout_DEVICE mywaveout

lrestart:
restart=0:quit=0
mywavein.wstart(mydev)
mywaveout.wstart(mydevout)

While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 50	
Wend

mywavein.wclose()
mywaveout.wclose()

If restart=1 Then restart=0:quit=0:Sleep 100:GoTo lrestart

guigetwindowpos("win",winx,winy,windx,windy)
file=freefile
Open ficini For Output As #file
Print #file,winx
Print #file,winy
Print #file,mydev
Print #file,mydevout
Close #file

guiclose()
guiquit()

End


Sub mysubsample()
Dim As Integer i,j,k
For i=0 To mynsamples-1
	isample+=1
	If isample>=nsample Then isample=0
	mysamples(i)=mypsamples[i]
Next
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
    memcpy(.Buffers[.ibuffer]->lpData,mypsamples,mynsamples) 
    waveOutPrepareHeader(.hDevice,.Buffers[.ibuffer],sizeof(WAVEHDR))
    waveOutWrite(.hDevice,.Buffers[.ibuffer],sizeof(WAVEHDR))
    Exit For 
  EndIf 
 Next i
EndIf 
End With 
msg=Str(j)+"/"+Str(mynsamples)+"/"+Str(mypsamples[0])
msg+=crlf+errtext
printgui("win.msg",msg)
End Sub
