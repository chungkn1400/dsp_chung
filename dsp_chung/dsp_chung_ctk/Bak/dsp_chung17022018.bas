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
Dim Shared As Single automod=0.5,lowmod=1,krevmod=1,treverba,treverbb,kreverba,kreverbb
Dim Shared As Integer autovol=2,reverb=1
Dim Shared As String resp

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
autovol=2
If Not Eof(file) Then Line Input #file,ficin:autovol=Val(ficin)
reverb=1
If Not Eof(file) Then Line Input #file,ficin:reverb=Val(ficin)
treverba=200
If Not Eof(file) Then Line Input #file,ficin:treverba=Val(ficin)
kreverba=0.1
If Not Eof(file) Then Line Input #file,ficin:kreverba=Val(ficin)
treverbb=250
If Not Eof(file) Then Line Input #file,ficin:treverbb=Val(ficin)
kreverbb=0.1
If Not Eof(file) Then Line Input #file,ficin:kreverbb=Val(ficin)
automod=0.5
If Not Eof(file) Then Line Input #file,ficin:automod=Val(ficin)
lowmod=1
If Not Eof(file) Then Line Input #file,ficin:lowmod=Val(ficin)
krevmod=1
If Not Eof(file) Then Line Input #file,ficin:krevmod=Val(ficin)
Close #file

Dim Shared As Integer quit,restart,play,ttestloop
Sub subquit
	quit=1
End Sub
Sub submsg()
End Sub
Sub subedittext()
End Sub
Sub subplay()
If ttestloop<>0 Then Exit Sub 
If play=0 Then
	play=1:printgui("win.play","stop")
	ttestloop=1
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
Sub subautovol()
Dim As Integer i
getcomboindex("win.autovol",i)
autovol=i-1
Sleep 200
End Sub
Declare Sub setreverb()
Sub subreverb0()
Dim As Integer i
getcomboindex("win.reverb",i)
reverb=i-1
setreverb()
Sleep 200
End Sub
Sub subtreverba()
Dim As Integer i
getcomboindex("win.treverba",i)
treverba=i*25
setreverb()
Sleep 200
End Sub
Sub subkreverba()
Dim As Integer i
getcomboindex("win.kreverba",i)
kreverba=(i-1)*0.05
setreverb()
Sleep 200
End Sub
Sub subtreverbb()
Dim As Integer i
getcomboindex("win.treverbb",i)
treverbb=i*25
setreverb()
Sleep 200
End Sub
Sub subautomod()
Dim As Integer i
getcomboindex("win.automod",i)
automod=(i-1)*0.05
Sleep 200
End Sub
Sub sublowmod()
Dim As Integer i
getcomboindex("win.lowmod",i)
lowmod=(i)*0.05
Sleep 200
End Sub
Sub subkrevmod()
Dim As Integer i
getcomboindex("win.krevmod",i)
krevmod=(i)*0.05
Sleep 200
End Sub
Sub subkreverbb()
Dim As Integer i
getcomboindex("win.kreverbb",i)
kreverbb=(i-1)*0.05
setreverb()
Sleep 200
End Sub
Declare Sub testloop()
setreverb()
Dim Shared As Double timemsg
Dim Shared As Integer okout,freeout
Dim Shared As Single mypeek

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
combobox("win.waveout",@subwaveout,90,195,256,200)
combobox("win.gain",@subgain,356,195,70,500)
edittext("win.msg","",@submsg,10,40,473,35,es_multiline+WS_VSCROLL)
'edittext("win.edittext","",@subedittext,10,240,400,20,ES_LEFT+es_multiline+WS_VSCROLL)
combobox("win.autovol",@subautovol,10,95,135,500)
combobox("win.reverb",@subreverb0,10,125,87,500)
combobox("win.treverba",@subtreverba,160,95,90,500)
combobox("win.kreverba",@subkreverba,160,125,90,500)
combobox("win.treverbb",@subtreverbb,265,95,90,500)
combobox("win.kreverbb",@subkreverbb,265,125,90,500)
combobox("win.automod",@subautomod,370,95,105,500)
combobox("win.lowmod",@sublowmod,370,125,105,500)
combobox("win.krevmod",@subkrevmod,370,155,105,500)
button("win.play","play",@subplay,10,195,60,24)
openwindow("win","waveinout_chung",winx,winy,500,303) 

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

For i=1 To 31
	addcombo("win.buffersize","buf"+Str(150+(i-1)*50))
Next
i=Int(1+(buffersize-150)/50+0.01)
selectcomboindex("win.buffersize",i)

addcombo("win.autovol","noautovol")
addcombo("win.autovol","autovol")
addcombo("win.autovol","autovolcomp")
addcombo("win.autovol","autovolcomp2")
addcombo("win.autovol","autovolcomp3")
addcombo("win.autovol","autovolcomp4")
addcombo("win.autovol","noautovolcomp")
addcombo("win.autovol","noautovolcomp2")
addcombo("win.autovol","noautovolcomp3")
addcombo("win.autovol","noautovolcomp4")
i=autovol+1
selectcomboindex("win.autovol",i)

addcombo("win.reverb","noreverb")
addcombo("win.reverb","reverb1")
addcombo("win.reverb","reverbAB")
i=reverb+1
selectcomboindex("win.reverb",i)

For i=1 To 50
	addcombo("win.treverba","trevA"+Str(i*25))
Next
i=Int(treverba/25+0.01)
selectcomboindex("win.treverba",i)

For i=1 To 19
	addcombo("win.kreverba","krevA"+Left(Str((i-1)*0.05)+"00",4))
Next
i=Int(kreverba/0.05+1.01)
selectcomboindex("win.kreverba",i)

For i=1 To 50
	addcombo("win.treverbb","trevB"+Str(i*25))
Next
i=Int(treverbb/25+0.01)
selectcomboindex("win.treverbb",i)

For i=1 To 19
	addcombo("win.kreverbb","krevB"+Left(Str((i-1)*0.05)+"00",4))
Next
i=Int(kreverbb/0.05+1.01)
selectcomboindex("win.kreverbb",i)

For i=1 To 41
	addcombo("win.automod","automod"+Str((i-1)*5))
Next
i=Int(automod*100/5+1.01)
selectcomboindex("win.automod",i)

For i=1 To 40
	addcombo("win.lowmod","lowmod"+Str((i)*5))
Next
i=Int(lowmod*100/5+0.01)
selectcomboindex("win.lowmod",i)

For i=1 To 40
	addcombo("win.krevmod","revmod"+Str((i)*5))
Next
i=Int(krevmod*100/5+0.01)
selectcomboindex("win.krevmod",i)

Dim Shared As hwnd winmsgh
winmsgh=getguih("win.msg")

Dim Shared As WAVEIN_DEVICE mywavein
Dim Shared As WAVEout_DEVICE mywaveout

play=1:printgui("win.play","stop")

lrestart:
restart=0:quit=0
ttestloop=1
mywaveout.wstart(mydevout)
mywavein.wstart(mydev)
'guinotice "now    volume:" & mixer.WaveinVolume

While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 90
	If guitestkey(vk_space) Then
		If getfocus()=winmsgh Then quit=1
	EndIf
   If Timer>timemsg+0.2 Then
    timemsg=Timer 
    msg="freeout="+Str(freeout)+"/"+Str(mynsamples)+"/"+Str(mypsamples[0])
    If play=1 Then msg+=crlf+"out="+Str(okout)
    msg+="/"+errtext
    printguih(winmsgh,msg)
   EndIf
   If ttestloop=1 Then 
   	ttestloop=2
   	testloop()
   	ttestloop=0
   EndIf

Wend

Sleep 1000
mywavein.wclose()
mywaveout.wclose()
Sleep 1000

If restart=1 Then restart=0:quit=0:Sleep 1000:GoTo lrestart

guigetwindowpos("win",winx,winy,windx,windy)
file=freefile
Open ficini For Output As #file
Print #file,winx
Print #file,winy
Print #file,mydev
Print #file,mydevout
Print #file,gain
Print #file,buffersize
Print #file,autovol
Print #file,reverb
Print #file,treverba
Print #file,kreverba
Print #file,treverbb
Print #file,kreverbb
Print #file,automod
Print #file,lowmod
Print #file,krevmod
Close #file

guiclose()
guiquit()

End

Dim Shared As Double timetest
Sub testloop()
timetest=Timer
Var play0=play
Var gain0=gain
Var avgpeek=0.0
gain=1
play=1
While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 20
	avgpeek+=(mypeek-avgpeek)*0.3
	If avgpeek>20000 Then Exit While
	If Timer>timetest+1 Then Exit While
Wend
gain=gain0
play=play0
If avgpeek<20000 Then Exit Sub 
'guinotice "testloop"
timetest=Timer 
avgpeek=0
gain=0
play=1
While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 20
	avgpeek+=(mypeek-avgpeek)*0.3
	If avgpeek<10000 Then Exit While
	If Timer>timetest+1 Then Exit While
Wend
If avgpeek<10000 Then
	guinotice "warning , there may be a feedback loop"
	guiconfirm("continue ?","confirm",resp)
	If resp<>"yes" Then
	  play=0
	  printgui("win.play","play")
	Else
	  play=play0	
	EndIf   
Else
	play=play0
EndIf
'guinotice "ok"
gain=gain0
End Sub
Declare Sub Myprocback()
Declare Sub setautovol()
Dim Shared As Single xback
Sub mysubsample()
If quit=1 Then Exit Sub
Dim As Integer i,j,k
Dim As Single mypeek2
If ttestloop<>0 then
  For i=0 To mynsamples-1
	 mypeek2=max(mypeek2,Abs(mypsamples[i]))
  Next
EndIf 
mypeek=mypeek2
okout=0	
With mywaveout 
j=0
For i=1 To nbuffer
 If .bufferbusy(i-1)=0 Then j+=1
Next i
freeout=j
If play=1 Then
 For i=1 To nbuffer
  .ibuffer=(.ibuffer+1)Mod .nbuffers
  If .bufferbusy(.ibuffer)=0 Then 
    .bufferbusy(.ibuffer)=1
    'memcpy(.Buffers[.ibuffer]->lpData,mypsamples,mynsamples)
    Dim As Short Ptr pbuffer=cptr(short ptr,.Buffers[.ibuffer]->lpData)
    For k=0 To mynsamples-1
    	xback=mypsamples[k]
    	If ttestloop=0 Then Myprocback()
    	pbuffer[k]=CShort(Int(max(-32700.0,min(32700.0,xback*gain))))
    Next k
    If ttestloop=0 Then setautovol()
    waveOutPrepareHeader(.hDevice,.Buffers[.ibuffer],sizeof(WAVEHDR))
    waveOutWrite(.hDevice,.Buffers[.ibuffer],sizeof(WAVEHDR))
    okout=1:Exit For 
  EndIf 
 Next i
EndIf 
End With 
End Sub
dim shared as single volout0=1.7,volout=1.7,volout2,kvolout2,klevel2=1'1.80
Dim Shared As Single level,level2=0.8,tlevel=400,klevel=1,level3=0.8,npeek,kframe=1
Dim Shared As Integer nsamples,ndata,peekx,peekx2
Dim Shared As Double timelevel,timelevel2
Dim Shared As Single volcanal=127,volcanal0=127
peekx=1:peekx2=1
timelevel=Timer+1.2
timelevel2=Timer
nsamples=99999
Sub setlevel()
  If timelevel<timelevel2 Then timelevel=timelevel2
  If timelevel>(Timer+99) Then timelevel=Timer 'if midnight
  timelevel2=Timer
  If timelevel2>(0.001+timelevel) Then 
  	tlevel=max(10.0,60.0/(timelevel2-timelevel)) '60s autovol
  	'tlevel=max(10.0,40.0/(timelevel2-timelevel)) '40s autovol
  Else
  	tlevel=7
  EndIf
  kframe=1024/max2(64,min2(4096,buffersize))
  tlevel*=kframe
  level=peekx/(256*128) '0 .. 1.0
  If level>0.01 Then 
    If level>0.05 Then
    	level2=(level2*tlevel+level)/(tlevel+1)
    Else 
    	level2=(level2*tlevel*8+level)/(tlevel*8+1)
    EndIf
    If level>0.998 Then 'saturation
    'If (peekx2/(256*128))>1.2 Then 'saturation
    	npeek+=1
    	If npeek>=2 Then
    		npeek=2
    		If volcanal<3*volcanal0 Then volcanal*=1.03'1.01
    	EndIf
    Else
    	If npeek>0 Then npeek-=1.4'2
    	If level2<0.9 Then volcanal+=(volcanal0-volcanal)*0.01
    EndIf
  Else
  	 timelevel=timelevel2+1.2
  EndIf 
  If level2<level Then level2=level
  If level2<0.01 Then level2=0.01
  If level3<level2 Then level3=level2
  If level3>1.12*level2 Then level3=1.12*level2
  'volout=1.8
  klevel=volout*0.5/level3 'target level=volout*0.5
  If klevel>5 Then klevel=5
  peekx=1:peekx2=1
  If autovol=2 Then 
    volout2=volout*64*256*0.83 'for compressor
    kvolout2=0.44
  Else
  	 If autovol=3 Then 
  	   volout2=volout*64*256*0.77'0.83
  	   kvolout2=0.59'0.54
  	 Else
  	 	If autovol=4 Then 
  	     volout2=volout*64*256*0.73
  	     kvolout2=0.72
  	 	Else
  	 	  volout2=volout*64*256*0.70
  	 	  kvolout2=0.80
  	 	EndIf   	
  	 EndIf 	
  EndIf 
  klevel2=volout/(volout-(volout-volout2/(64*256))*kvolout2)
End Sub
Sub setlevel2()
  If timelevel<timelevel2 Then timelevel=timelevel2
  If timelevel>(Timer+99) Then timelevel=Timer 'if midnight
  timelevel2=Timer
  If timelevel2>(0.001+timelevel) Then 
  	tlevel=max(4.0,4.0/(timelevel2-timelevel)) '4s autovol $$?
  	'tlevel=max(10.0,40.0/(timelevel2-timelevel)) '40s autovol
  Else
  	tlevel=7
  EndIf
  tlevel*=kframe
  level=peekx/(256*128) '0 .. 1.0
  If level>0.01 Then 
    If level>0.05 Then
    	level2=(level2*tlevel+level)/(tlevel+1)
    Else 
    	level2=(level2*tlevel*8+level)/(tlevel*8+1)
    EndIf
    If level>0.998 Then 'saturation
    'If (peekx2/(256*128))>1.2 Then 'saturation
    	npeek+=1
    	If npeek>=2 Then
    		npeek=2
    		If volcanal<3*volcanal0 Then volcanal*=1.03'1.01
    	EndIf
    Else
    	If npeek>0 Then npeek-=1.4'2
    	If level2<0.9 Then volcanal+=(volcanal0-volcanal)*0.01
    EndIf
  Else
  	 timelevel=timelevel2+1.2
  EndIf 
  If level2<level Then level2=level
  If level2<0.01 Then level2=0.01
  If level3<level2 Then level3=level2
  If level3>1.12*level2 Then level3=1.12*level2
  'volout=1.8
  'klevel=volout*0.5/level3 'target level=volout*0.5
  'If klevel>5 Then klevel=5
  klevel=1
  peekx=1:peekx2=1
  If autovol=2+4 Then 
    volout2=volout*64*256*0.83 'for compressor
    kvolout2=0.44
  Else
  	 If autovol=3+4 Then 
  	   volout2=volout*64*256*0.77'0.83
  	   kvolout2=0.59'0.54
  	 Else
  	 	If autovol=4+4 Then 
  	     volout2=volout*64*256*0.73
  	     kvolout2=0.72
  	 	Else
  	 	  volout2=volout*64*256*0.70
  	 	  kvolout2=0.80
  	 	EndIf   	
  	 EndIf 	
  EndIf 
  klevel2=volout/(volout-(volout-volout2/(64*256))*kvolout2)
End Sub
Dim Shared As Integer iback,nback
'Dim Shared As fbs_sample xback  'equ short           	
'Dim Shared As Integer xback '32bits 
Dim Shared As Single xrev,revdata(48000*2*2) 'max rev 2seconds 48khz stereo
Dim Shared As Integer ireverb=0,nreverb=48000*2*2
Dim Shared As Single treverb1,treverb2,kreverb1=0.22,kreverb2=0.2,kkreverb1,kkreverb2
Dim Shared As Integer ireverb1,ireverb2,jreverb1,jreverb2
Dim Shared As Single kreverb31,kreverb32,treverb31,treverb32
Dim Shared As Single kreverb21,kreverb22,treverb21,treverb22
Dim Shared As Single kreverb41,kreverb42,treverb41,treverb42
Dim Shared As Single panreverb3,panreverb2,panreverb4
kreverb31=max(0.0,min(0.7,kreverb31))
kreverb32=max(0.0,min(0.7,kreverb32))
treverb31=max2(10,min2(1000,treverb31))
treverb32=max2(10,min2(1000,treverb32))
kreverb21=max(0.0,min(0.7,kreverb21))
kreverb22=max(0.0,min(0.7,kreverb22))
treverb21=max2(10,min2(1000,treverb21))
treverb22=max2(10,min2(1000,treverb22))
kreverb41=max(0.0,min(0.7,kreverb41))
kreverb42=max(0.0,min(0.7,kreverb42))
treverb41=max2(10,min2(1000,treverb41))
treverb42=max2(10,min2(1000,treverb42))
Sub setreverb()
treverb21=treverba
kreverb21=kreverba
treverb22=treverbb
kreverb22=kreverbb
If reverb=0 Then Erase revdata
If reverb=1 Then kreverb1=0.23:kreverb2=0.2
If reverb=2 Then kreverb1=0.45:kreverb2=0.3
If reverb=3 Then kreverb1=0.55:kreverb2=0.34
treverb1=150*1.5
treverb2=200*1.5
kkreverb1=kreverb1
kkreverb2=kreverb2
If reverb=3 Then
	kreverb1=kreverb31:kreverb2=kreverb32
	treverb1=treverb31:treverb2=treverb32
   kkreverb1=max(0.0,min(0.9,kreverb1+(panreverb3/10)))
   kkreverb2=max(0.0,min(0.9,kreverb2+(panreverb3/10)))
EndIf
If reverb=2 Then
	kreverb1=kreverb21:kreverb2=kreverb22
	treverb1=treverb21:treverb2=treverb22
   kkreverb1=max(0.0,min(0.9,kreverb1+(panreverb2/10)))
   kkreverb2=max(0.0,min(0.9,kreverb2+(panreverb2/10)))
EndIf
kreverb2*=(1-kreverb1)
kkreverb2*=(1-kkreverb1)
ireverb1=max2(2,min2(nreverb-4,int(treverb1*samplerate/1000)*nchannel))          	
ireverb2=max2(2,min2(nreverb-4,Int(treverb2*samplerate/1000)*nchannel))          	
End Sub
Sub subreverb()
If nchannel>=1 Then
   jreverb1=ireverb-ireverb1-1
   If jreverb1<0 Then jreverb1+=nreverb
   jreverb2=ireverb-ireverb2-1
   If jreverb2<0 Then jreverb2+=nreverb
   If (ireverb And 1) Then
   	xrev=xback+kkreverb1*revdata(jreverb1)+kkreverb2*revdata(jreverb2)+1e-9
   Else
   	xrev=xback+kreverb1*revdata(jreverb1)+kreverb2*revdata(jreverb2)+1e-9
   EndIf
   revdata(ireverb)=xrev
   ireverb+=1
   If ireverb>=nreverb Then ireverb=0
   xback=xrev   		
EndIf
End Sub
/'Sub subequal()
If iback And 1 Then
	xback=equcalcul_2(xback)
Else
	xback=equcalcul(xback)
EndIf	
End Sub
Sub subequal_old()
if nchannels=1 Then
   Select Case equaltype
   	Case 1
   		xback=equcalcul1(xback)
   	Case 2
   		xback=equcalcul2(xback)
   	Case 3
   		xback=equcalcul3(xback)
   	Case 4
   		xback=equcalcul4(xback)
   End Select
Else
  If (iback And 1)=0 Then
   Select Case equaltype
   	Case 1
   		xback=equcalcul1(xback)
   	Case 2
   		xback=equcalcul2(xback)
   	Case 3
   		xback=equcalcul3(xback)
   	Case 4
   		xback=equcalcul4(xback)
   End Select
  Else	
   Select Case equaltype
   	Case 1
   		xback=equcalcul1_2(xback)
   	Case 2
   		xback=equcalcul2_2(xback)
   	Case 3
   		xback=equcalcul3_2(xback)
   	Case 4
   		xback=equcalcul4_2(xback)
   End Select
  EndIf
EndIf
End Sub
lowf=max2(20,min(20000,lowf))
highf=max2(20,min(20000,highf))
lowg=max(0.0,min(10.0,lowg))
midg=max(0.0,min(10.0,midg))
highg=max(0.0,min(10.0,highg))
equaltype=max2(1,min2(4,equaltype))
resetequalizer()
'/
Dim Shared As Integer irevmod,nrevmod=40000
Dim Shared As Single xrevmod(40000),xbacklowrev
Function revmod(x As Single)As Single
	irevmod+=1:If irevmod>nrevmod Then irevmod=1
	Var irevmod0=irevmod-2000
	If irevmod0<1 Then irevmod0+=nrevmod
	'Var irevmod2=irevmod-2100
	'If irevmod2<1 Then irevmod2+=nrevmod
	'xrevmod(irevmod)=x-(xrevmod(irevmod0)+xrevmod(irevmod2))*0.235
	xrevmod(irevmod)=x-(xrevmod(irevmod0))*0.45*krevmod
	Return xrevmod(irevmod)
End Function
Dim Shared As Integer towave=0,towavesizemax,towavesize
ReDim Shared As Short towavedata(10)
ReDim Shared As Single towavedata32(10)
Dim Shared As Single xbacklow
Sub Myprocback()
		'xback=CInt(*(samples+iback))
		'If autovol>=1 Then 
		  If Abs(xback)>peekx Then peekx=Abs(xback)
		  xbacklow+=(xback-xbacklow)*0.004*lowmod
		  xbacklowrev=revmod(xbacklow)
		  xback*=klevel*((1.0-automod)+automod*(xbacklowrev)/(32700*max(0.1,level)))
		  'xback*=klevel*((1.0-automod)+automod*Abs(xback)/(32700*max(0.1,level)))
		  If autovol>=2 Then
          'volout2=volout*64*256*0.8
          'kvolout2=0.45 	
			 If xback>volout2 Then xback-=(xback-volout2)*kvolout2
			 If xback<-volout2 Then xback-=(xback+volout2)*kvolout2
			 xback*=klevel2'volout/(volout-(volout-volout2/(64*256))*kvolout2)
		  EndIf
		'EndIf
		If reverb>=1 Then subreverb()
		/'If equal=1 Then subequal()
		xback*=volout3
		If pluginproc<>0 Then xback=pluginproc(xback)
		If plugin2proc<>0 Then xback=plugin2proc(xback)
		If plugin3proc<>0 Then xback=plugin3proc(xback)
		If plugin4proc<>0 Then xback=plugin4proc(xback)
		'/
		If Abs(xback)>peekx2 Then peekx2=Abs(xback)
		If xback>32767 Then xback=32767
		If xback<-32767 Then xback=-32767
End Sub
Dim Shared As Integer nsample
Sub setautovol()
	nsample=mynsamples
   If autovol>=1 And autovol<=5 Then 
     nsamples+=nsample
 	  If nsamples>4400 Then '0.1 seconds at 44.1Kz
		 nsamples=0
		 setlevel()
	  EndIf 
	Else 
     nsamples+=nsample
 	  If nsamples>4400 Then '0.1 seconds at 44.1Kz
		 nsamples=0
		 setlevel2()
	  EndIf 
   EndIf
End Sub