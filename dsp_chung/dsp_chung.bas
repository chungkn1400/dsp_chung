'dsp_chung a program by NGUYEN.Chung (freeware 2018)
'
Dim Shared As Double auxvar,auxvar2,auxvar3,auxvar4,auxtest 
#Include Once "windows.bi"
#Include Once "gui_chung.bi"
#Include Once "win/mmsystem.bi"
#Include Once "crt/string.bi"
#Include Once "wavein.bi"
#Include Once "waveout.bi"
#Include Once "plugin.bi"



Sub notice(ByRef msg As string,ByRef title As String ="notice")
	guinotice(msg,title)
End Sub
Sub confirm(ByRef msg As string,ByRef title As string,ByRef resp As String)
   guiconfirm(msg,title,resp)
End Sub 
Var hprocess=GetCurrentProcess()
'SetpriorityClass (hprocess, ABOVE_NORMAL_PRIORITY_CLASS)
Var retc=SetpriorityClass (hprocess, HIGH_PRIORITY_CLASS)

Dim As Hdc myhdc=getdc(0)
Dim As size mysize   
GetTextExtentPoint32A(myhdc,@"H",1,@mysize)
Var hf=mysize.cy
'guinotice Str(hf)
deletedc(myhdc)
If hf<>16 Then
	guifontweight=600'bold
   Var ifont=guifont4,fontsize=14,italic=0
   setedittextfont(ifont,fontsize,italic)
   setstatictextfont(ifont,fontsize,italic)
   setlistboxfont(ifont,fontsize,italic)
   setbuttonfont(ifont,fontsize,italic)
EndIf 

Dim Shared As Integer winx,winy,windx,windy,file,i,j,k,n,p
Dim Shared As Single gain,testgain=1
Dim Shared As Single automod=0.5,lowmod=1,krevmod=1,treverba,treverbb,kreverba,kreverbb,decay,tdecay,kkdecay
Dim Shared As Integer autovol=2,reverb=1,noisered=0,bypass=0,mono=0,remove50,antilarsen=1,icolor
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
decay=1
If Not Eof(file) Then Line Input #file,ficin:decay=max(1.0,min(4.0,Val(ficin)))
mono=0
If Not Eof(file) Then Line Input #file,ficin:mono=Val(ficin)
noisered=0
If Not Eof(file) Then Line Input #file,ficin:noisered=Val(ficin)
remove50=0
If Not Eof(file) Then Line Input #file,ficin:remove50=Val(ficin)
antilarsen=0
If Not Eof(file) Then Line Input #file,ficin:antilarsen=Val(ficin)
testgain=1
If Not Eof(file) Then Line Input #file,ficin:testgain=max(0.001,min(1.0,Val(ficin)))
icolor=0
If Not Eof(file) Then Line Input #file,ficin:icolor=Val(ficin)
tdecay=100
If Not Eof(file) Then Line Input #file,ficin:tdecay=Val(ficin)
kkdecay=0.77
If Not Eof(file) Then Line Input #file,ficin:kkdecay=Val(ficin)
Close #file

Sub load(fic As String)
Dim As Integer file
Dim As String ficin
Var testgain0=testgain
file=FreeFile
Open fic For Input As #file
'winx=10:winy=10
'If Not Eof(file) Then Line Input #file,ficin:winx=Val(ficin)
'If Not Eof(file) Then Line Input #file,ficin:winy=Val(ficin)
'mydev=-1
'If Not Eof(file) Then Line Input #file,ficin:mydev=Val(ficin)
'mydevout=-1
'If Not Eof(file) Then Line Input #file,ficin:mydevout=Val(ficin)
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
decay=1
If Not Eof(file) Then Line Input #file,ficin:decay=max(1.0,min(4.0,Val(ficin)))
mono=0
If Not Eof(file) Then Line Input #file,ficin:mono=Val(ficin)
noisered=0
If Not Eof(file) Then Line Input #file,ficin:noisered=Val(ficin)
remove50=0
If Not Eof(file) Then Line Input #file,ficin:remove50=Val(ficin)
antilarsen=0
If Not Eof(file) Then Line Input #file,ficin:antilarsen=Val(ficin)
testgain=1
If Not Eof(file) Then Line Input #file,ficin:testgain=max(0.001,min(1.0,Val(ficin)))
icolor=0
If Not Eof(file) Then Line Input #file,ficin:icolor=Val(ficin)
tdecay=100
If Not Eof(file) Then Line Input #file,ficin:tdecay=Val(ficin)
kkdecay=0.77
If Not Eof(file) Then Line Input #file,ficin:kkdecay=Val(ficin)
Close #file	
testgain=testgain0
End Sub
Sub save(fic As String)
Dim As Integer file	
file=freefile
Open fic For Output As #file
'Print #file,winx
'Print #file,winy
'Print #file,mydev
'Print #file,mydevout
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
Print #file,decay
Print #file,mono
Print #file,noisered
Print #file,remove50
Print #file,antilarsen
Print #file,testgain
Print #file,icolor
Print #file,tdecay
Print #file,kkdecay
Close #file	
End Sub
Dim Shared As Integer quit,restart,play,ttestloop
Sub subsave
Dim As String fic,dir0
Dim As Integer ret 
dir0=CurDir  
ChDir(ExePath+"\save\")  
fic=filedialog("save",ExePath+"\save\*.dspchung")
fic=Trim(fic)
ChDir(dir0)
If InStr(fic,".")=0 And fic<>"" Then fic=fic+".dspchung"
If Right(fic,9)=".dspchung" Then 
	confirm("save in "+fic+" ?","confirm",resp)
	If resp="yes" Then
		save(fic)
	EndIf
EndIf
ret=ChDir(dir0)
guisetfocus("win.msg")
End Sub
Sub subload
Dim As String fic,dir0
Dim As Integer ret 
dir0=CurDir
ChDir(ExePath+"\save\")  
fic=filedialog("load",ExePath+"\save\*.dspchung")
fic=Trim(fic)
ret=ChDir(dir0)
If Right(fic,9)=".dspchung" Then 
	If FileExists(fic) Then
		load(fic)
		quit=1:restart=2
		guinotice "ok"
	EndIf
EndIf
ret=ChDir(dir0)
guisetfocus("win.msg")
End Sub
Sub subquit
	quit=1
End Sub
Sub submsg()
End Sub
Sub subedittext()
End Sub
Sub subcolor2()
If icolor=0 Then guibackgroundcolor(50,255,50)
If icolor=1 Then guibackgroundcolor(255,255,50)
If icolor=2 Then guibackgroundcolor(255,49,52)
If icolor=3 Then guibackgroundcolor(50,60,255)	
End Sub
Sub subcolor()
icolor=(icolor+1)Mod 4
quit=1:restart=2
End Sub
Sub subplay()
If ttestloop<>0 Then Exit Sub 
If play=0 Then
	play=1:printgui("win.play","stop")
	'ttestloop=1
Else
	play=0:printgui("win.play","play")
EndIf
End Sub
Sub subtestloop()
	ttestloop=199
	Sleep 200
End Sub
Sub subwavein()
Dim As Integer i
getcomboindex("win.wavein",i)
mydev=i-2 '-1=mapper
quit=1:restart=1
ttestloop=1999
End Sub
Sub subwaveout()
Dim As Integer i
getcomboindex("win.waveout",i)
mydevout=i-2 '-1=mapper
quit=1:restart=1
ttestloop=1999
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
If i<=18 Then
	buffersize=2*max2(150,min2(9800,150+(i-1)*50))
Else 
	buffersize=2*max2(150,min2(9800,1000+(i-18)*200))
EndIf
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
If i<10 Then
	treverba=i*10
Else	
	treverba=100+(i-10)*25
EndIf
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
If i<10 Then
	treverbb=i*10
Else	
	treverbb=100+(i-10)*25
EndIf
setreverb()
Sleep 200
End Sub
Sub subautomod()
Dim As Integer i
getcomboindex("win.automod",i)
automod=(i-1)*0.01
Sleep 100
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
Sub subbypass()
If bypass=0 Then
	bypass=1
	setcheckbox("win.bypass")
Else
	bypass=0
	unsetcheckbox("win.bypass")
EndIf
End Sub
Sub subnoise()
If noisered=0 Then
	noisered=1
	setcheckbox("win.noise")
Else
	noisered=0
	unsetcheckbox("win.noise")
EndIf
End Sub
Sub subantilarsen()
If antilarsen=0 Then
	antilarsen=1
	setcheckbox("win.antilarsen")
Else
	antilarsen=0
	unsetcheckbox("win.antilarsen")
EndIf
End Sub
Sub submono()
If mono=0 Then
	mono=1
	setcheckbox("win.mono")
Else
	mono=0
	unsetcheckbox("win.mono")
EndIf
End Sub
Sub subdecay()
Dim As Integer i
getcomboindex("win.decay",i)
decay=1+(i-1)*0.05
Sleep 200
End Sub
Sub subplugins
displayplugins()
End Sub
Declare Sub setnoise()
Sub subsetnoise()
guiconfirm("take noise sample ?","confirm",resp)
If resp="yes" Then
   If noisered<>1 Then
   	guinotice "noisered if off !":Exit sub
   EndIf
	'Sleep 2000
	setnoise()
	guinotice "ok"
EndIf
End Sub
Dim Shared As Single f50hz=50
Sub subremove50()
If remove50=0 Then
	remove50=1
	setcheckbox("win.remove50")
	printgui("win.remove50","remove50hz")
	f50hz=50
ElseIf remove50=1 Then 	
	remove50=2
	setcheckbox("win.remove50")
	printgui("win.remove50","remove60hz")
	f50hz=60
Else
	remove50=0
	unsetcheckbox("win.remove50")
	printgui("win.remove50","remove50hz")
	f50hz=50
EndIf
End Sub
Declare Sub testloop()
setreverb()
Const As Single pi=2*ASin(1)
Dim Shared As Double timemsg,timeinit,timexback,dtxback
Dim Shared As Integer okout,freeout,tinput,toutput
Dim Shared As Single mypeek,mypeekin,level,xback0,xback1,xback2,xbackout,levelout,levelout0
'Dim Shared As Double mypeekcos,mypeeksin,mypeekcos0,mypeeksin0,mycos,mysin
'Dim Shared As Double mypeekcos2,mypeeksin2,mypeekcos20,mypeeksin20

loadplugins()

' Program start
lrestart2:
If restart=2 Then restart=22
Dim Shared As Integer wx,wy
ScreenInfo wx,wy
winx=max2(0,min2(wx-500,winx))
winy=max2(0,min2(wy-350,winy)) 
guibackgroundcolor(50,255,50)
guiedittextbackcolor(220,170,255)
guiedittextinkcolor(0,0,100)
guistatictextinkcolor(50,50,100)
subcolor2()
button("win.button1","quit",@subquit,10,10,60,24)
combobox("win.wavein",@subwavein,90,10,256,200)
combobox("win.buffersize",@subbuffersize,356,10,80,500)
statictext("win.textdelay","delay",440,13,60,20)
combobox("win.waveout",@subwaveout,90,195,256,200)
combobox("win.gain",@subgain,356,195,70,500)
graphicbox("win.vuout",433,200,55,15)
edittext("win.msg","",@submsg,10,40,473,35,es_multiline+WS_VSCROLL)
'edittext("win.edittext","",@subedittext,10,240,400,20,ES_LEFT+es_multiline+WS_VSCROLL)
combobox("win.autovol",@subautovol,10,95,135,500)
combobox("win.reverb",@subreverb0,10,125,87,500)
button("win.plugins","plugins",@subplugins,10,155,57,22)
checkbox("win.bypass","bypass",@subbypass,356,232,85,20)
checkbox("win.mono","mono",@submono,356,251,85,20)
checkbox("win.noise","noisered",@subnoise,10,230,85,20)
checkbox("win.remove50","remove50hz",@subremove50,10,251,100,20)
checkbox("win.antilarsen","antilarsen",@subantilarsen,120,230,85,20)
button("win.testloop","testloop",@subtestloop,120,251,67,20)
statictext("win.textloop","(adjust gain)",190,254,90,20)
button("win.color","color",@subcolor,287,253,42,18)
combobox("win.treverba",@subtreverba,160,95,90,500)
combobox("win.kreverba",@subkreverba,160,125,90,500)
combobox("win.treverbb",@subtreverbb,265,95,90,500)
combobox("win.kreverbb",@subkreverbb,265,125,90,500)
combobox("win.kdecay",@subkdecay,72,155,81,500)
combobox("win.tdecay",@subtdecay,160,155,90,500)
combobox("win.decay",@subdecay,265,155,90,500)
combobox("win.automod",@subautomod,370,95,105,500)
combobox("win.lowmod",@sublowmod,370,125,105,500)
combobox("win.krevmod",@subkrevmod,370,155,105,500)
button("win.play","play",@subplay,10,195,60,24)
button("win.save","save",@subsave,448,234,38,17)
button("win.load","load",@subload,448,253,38,17)
openwindow("win","dsp_chung",winx,winy,500,310) 

trapclose("win",@subquit)
guisetfocus("win")
guisetfocus("win.edittext")
reloadcombo("win.wavein",myname())
selectcomboindex("win.wavein",mydev+2)
reloadcombo("win.waveout",mynameout())
selectcomboindex("win.waveout",mydevout+2)
'addmenu("win.menu","menu")  'the same thing, with guimenu
'addmenuitem("win.menu.menu","noisered",@subnoise)
If noisered=1 Then setcheckbox("win.noise")
If antilarsen=1 Then setcheckbox("win.antilarsen")

If mono=1 Then setcheckbox("win.mono")

remove50-=1:subremove50()

For i=1 To 21
	addcombo("win.gain","vol"+Str((i-1)*5))
Next
i=Int(1+gain*20+0.01)
selectcomboindex("win.gain",i)

For i=1 To 18+44
	If i<=18 Then
		addcombo("win.buffersize","buf"+Str(150+(i-1)*50))
	Else 	
		addcombo("win.buffersize","buf"+Str(1000+(i-18)*200))
	EndIf
Next
i=Int(1+(buffersize/2-150)/50+0.01)
If i>18 Then i=Int(18+(buffersize/2-1000)/200+0.01)
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
	If i<10 Then
		addcombo("win.treverba","trevA"+Str(i*10))
   Else
   	addcombo("win.treverba","trevA"+Str(100+(i-10)*25))
   EndIf 	
Next
If treverba<100 Then
	i=Int(treverba/10+0.01)
Else
   i=Int((treverba-100)/25+10.01)
EndIf    
selectcomboindex("win.treverba",i)

For i=1 To 19
	addcombo("win.kreverba","krevA"+Left(Str((i-1)*0.05)+"00",4))
Next
i=Int(kreverba/0.05+1.01)
selectcomboindex("win.kreverba",i)

For i=1 To 50
	If i<10 Then
		addcombo("win.treverbb","trevB"+Str(i*10))
   Else
   	addcombo("win.treverbb","trevB"+Str(100+(i-10)*25))
   EndIf 	
Next
If treverbb<100 Then
	i=Int(treverbb/10+0.01)
Else
   i=Int((treverbb-100)/25+10.01)
EndIf    
selectcomboindex("win.treverbb",i)

For i=1 To 19
	addcombo("win.kreverbb","krevB"+Left(Str((i-1)*0.05)+"00",4))
Next
i=Int(kreverbb/0.05+1.01)
selectcomboindex("win.kreverbb",i)

For i=1 To 41
  If i=1 then	
	addcombo("win.decay","decayoff")
  Else 
	addcombo("win.decay","decay"+Left(Str((i-1)*0.05+1.0001),4))
  EndIf 
Next
i=Int((decay-1.0)*20+1.01)
selectcomboindex("win.decay",i)

For i=1 To 91
	addcombo("win.automod","automod"+Str((i-1)))
Next
i=Int(automod*100+1.01)
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

Dim Shared As hwnd winmsgh,winh
winmsgh=getguih("win.msg")
winh=getguih("win")

Dim Shared As Any Ptr vuoutbuffer
vuoutbuffer=getguigfxbuffer("win.vuout")

Dim Shared As WAVEIN_DEVICE mywavein
Dim Shared As WAVEout_DEVICE mywaveout

play=1:printgui("win.play","stop")

lrestart:
restart=0:quit=0
If ttestloop=1999 Then ttestloop=199
If auxtest<0.1 And ttestloop=-1 Then ttestloop=1
If mydevout>=numdevout Then mydevout=-1
If mydev>=numdev Then mydev=-1
'guinotice Str(numdev)+" "+Str(numdevout)
'guinotice Str(mydev)+" "+Str(mydevout)
mywaveout.wstart(mydevout)
Var gain0=gain
gain=0.01
mywavein.wstart(mydev)
Sleep 1000
gain=gain0
'guinotice "now    volume:" & mixer.WaveinVolume

mainloop:
timeinit=Timer
tinput=1
toutput=1

While quit=0 
	guiscan
	Sleep 90
   If guitestkey(vk_escape) Then
   	If winh=getactivewindow() Then
   		quit=1
   	EndIf
   EndIf
	If guitestkey(vk_space) Then
		If getfocus()=winmsgh Then quit=1
	EndIf
   If Timer>timemsg+0.24 Then
    timemsg=Timer 
    msg="freeout="+Str(freeout)+"/"+Str(mynsamples)+"/"+Str(Abs(mypsamples[0]))+crlf
    If play=1 And Abs(auxvar)<0.00001 Then
    	msg+="out="+Str(okout)
      msg+="/"+errtext
    EndIf
    If Abs(auxvar)>0.000001 Then msg+="/aux="+Left(Str(auxvar),6)
    If Abs(auxvar2)>0.000001 Then msg+="/aux2="+Left(Str(auxvar2),6)
    If Abs(auxvar3)>0.000001 Then msg+="/aux3="+Left(Str(auxvar3),6)
    If Abs(auxvar4)>0.000001 Then msg+="/aux4="+Left(Str(auxvar4),6)
    printguih(winmsgh,msg)
    var vux=Int(55*level)
    Var vux2=Int(55*Abs((levelout0/testgain)/32700))
    If vux2>65 Then vux2=0
    If play=0 Then vux=1:vux2=0
    If Abs(xback0)<0.001 Then
    	Line vuoutbuffer,(vux,0)-(55,15),RGB(250,250,250),bf
    Else 
    	Line vuoutbuffer,(vux,0)-(55,7),RGB(195,195,195),bf
    	Line vuoutbuffer,(vux2,8)-(55,15),RGB(195,195,195),bf
    EndIf
    Line vuoutbuffer,(0,0)-(vux,7),RGB(0,155,0),bf
    Line vuoutbuffer,(0,8)-(vux2,15),RGB(0,155,0),bf
	 guirefreshwindow("win")
   EndIf
   If ttestloop=199 Then 
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
If restart=2 Then
	restart=22:quit=0
	guiclosewindow("win")
	guireset()
	Sleep 1000:GoTo lrestart2
EndIf

closeplugins()

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
Print #file,decay
Print #file,mono
Print #file,noisered
Print #file,remove50
Print #file,antilarsen
Print #file,testgain
Print #file,icolor
Print #file,tdecay
Print #file,kkdecay
Close #file

guiclose()
guiquit()

End

Dim Shared As Double timetest,timepeek
Sub testloop0()
guiconfirm("test loop ?","confirm",resp)
If resp<>"yes" Then
	Exit Sub 
EndIf
Var play0=play
Var gain0=gain
mypeekin=0
gain=0
play=1
timetest=Timer 
While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 20
	If Timer>timetest+0.5 Then Exit While
Wend
Var mypeekin0=mypeekin
Var x28000=max(2000.0,min(32700.0-1,mypeekin*1.9))
'auxvar=mypeekin
mypeek=0
gain=1
play=1
timetest=Timer
While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 20
	If mypeek>x28000 Then Exit While
	If Timer>timetest+1 Then Exit While
Wend
gain=gain0
play=play0
If mypeek<x28000 Then
   guinotice "ok"
	Exit Sub 
EndIf
'guinotice "testloop"
If mypeek>x28000 Then
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
guinotice "ok"
gain=gain0
End Sub
/'Function mypeekinf0()As Double
  Return Sqr(mypeekcos0*mypeekcos0+mypeeksin0*mypeeksin0)
End Function
Function mypeekinf()As Double
  Return Sqr(mypeekcos*mypeekcos+mypeeksin*mypeeksin)
End Function '/
Sub testloop()
tinput=0:toutput=0	
guiconfirm("test loop ?","confirm",resp)
tinput=1:toutput=1	
If resp<>"yes" Then Exit Sub 
Var play0=play
Var gain0=gain
tinput=0:toutput=0:Sleep 1000
mypeekin=0
gain=0
play=1
tinput=0
toutput=0
mypeekin=0
timetest=Timer 
While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 20
	If mypeekin>2000 Then'26000 Then'2000 Then
		guiconfirm "stop input before ! "+Str(Int(mypeekin)),"confirm",resp
		If resp="yes" Then 
		 gain=gain0:play=play0:tinput=1:toutput=1
		 Exit Sub
		EndIf
		Exit While  
	EndIf
	If Timer>timetest+0.5 Then Exit While
Wend 
gain=1
tinput=99
toutput=99
mypeekin=0
timetest=Timer 
While quit=0 And guitestkey(vk_escape)=0
	guiscan
	Sleep 20
	If mypeekin>2000 Then
		Sleep 500
		Var mypeekin0=mypeekin
		'Var mypeekin2=mypeekinf0()/max(0.01,mypeekinf())'mypeekcos
		tinput=0:toutput=0
		'guinotice Str(mypeekinf())
		Var testgain0=testgain
		testgain=max(0.001,min(1.0,2000*1.3/(0.1+mypeekin0)))
		'Var testgain2=max(0.001,min(1.0,(2000*1.3/8000)*mypeekin2))
		'guinotice "gaincos="+Str(testgain2/testgain)+" / "+Str(testgain2)
		guinotice "warning loop ! "+Str(Int(mypeekin0))+"/"+Left(Str(testgain),5)
		tinput=0:toutput=0:Sleep 200
		If Abs(testgain0-testgain)>0.02*testgain0 Then
			guiconfirm("continue ?(changed)","confirm",resp)
		Else 	
			guiconfirm("continue ?","confirm",resp)
		EndIf
		If resp<>"yes" Then
			toutput=0
		Else
			toutput=1
		EndIf
		gain=gain0:play=play0:tinput=1':toutput=1
		Exit Sub 
	EndIf
	If Timer>timetest+1 Then Exit While
Wend
tinput=0:toutput=0
guinotice "ok "+Str(Int(mypeekin))+"/"+Left(Str(testgain),5)
tinput=0:toutput=0:Sleep 1000
testgain=1
gain=gain0:play=play0:tinput=1:toutput=1
End Sub 
Declare Sub Myprocback()
Declare Sub setautovol()
declare sub procspeed()
Declare Sub removelow2()
Dim Shared As Single xback,xbackold,xbackold0,speed=1,gain2=1,avggain=1,avgxback=1,avgxback0=1
Dim Shared As Single xback00,xback01,dxback00,dxback01
Dim Shared As Double avggaindecay
Dim Shared As Integer iback,ipeekcos
Sub mysubsample()
If quit=1 Then Exit Sub
Dim As Integer i,j,k
Dim As Single mypeek2
If ttestloop<>0 then
  For i=0 To mynsamples-1
	 mypeek2=max(mypeek2,Abs(mypsamples[i]))
  Next
EndIf 
mypeek=max(mypeek,mypeek2)
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
    dtxback=1/samplerate
    For k=0 To mynsamples-1
    	xback=mypsamples[k]
    	Var xback0=xback
    	iback=k
    	If (iback And 1)=0 Then timexback+=dtxback
    	If ttestloop<>0 Then mypeekin=max(mypeekin,Abs(xback))
    	If tinput=0 Then xback=0
    	If tinput=99 Then
         /'ipeekcos+=1
         If ipeekcos>8000 Then
           ipeekcos=1
           Var kx=1/8000
		     mypeekcos=mypeekcos2*kx
		     mypeeksin=mypeeksin2*kx
		     mypeekcos0=mypeekcos20*kx
		     mypeeksin0=mypeeksin20*kx
           mypeekcos20=0:mypeeksin20=0
           mypeekcos2=0:mypeeksin2=0
         EndIf '/ 
    		Var mycos=Cos(2*pi*timexback*500)'500hz
    		/'mysin=Sin(2*pi*timexback*500)'500hz 
   		mypeekcos2+=mycos*xback
    		mypeeksin2+=mysin*xback
    		'/
    		'xback=(8000-max(0.0,mypeekin-8000)*0.1)*mycos
    		xback=8000*mycos
    		'mypeekcos20+=mycos*xback
    		'mypeeksin20+=mysin*xback
    	EndIf
    	If ttestloop=0 Then
    		Myprocback()
    	EndIf
      If antilarsen=1 Then
    	   /'If (Int(timexback*1.5)And 1) Then
    	   	speed=1.0025
    	   Else 
    	   	speed=1/1.0025
    	   EndIf '/
    	   speed=1+0.003*Cos(timer*1.5*3.1416*2)
    		procspeed()
      EndIf
    	xbackold0=xbackold
    	xbackold=xback
    	If mono=1 Then xback=(xbackold+xbackold0)*0.5
    	Var tgain=gain*testgain
    	If toutput=1 Then tgain*=min(1.0,avggaindecay)
    	Var x30000=30000.0*tgain*tgain
    	If Abs(xback*tgain)>x30000 Then
    		Var gainx=x30000/Abs(xback)
    		gain2+=(gainx-gain2)*0.01
    		gain2=min(gainx*1.07,gain2)
    	Else 
    		gain2+=(tgain-gain2)*0.0003
    	EndIf
    	If toutput=99 Then gain2=gain
    	levelout0+=(min(32700.0,Abs(xback))-levelout0)*0.001
    	xback=max(-32700.0,min(32700.0,xback*gain2))
		'removelow2()
    	If toutput=0 Then xback=0
    	xbackout=max(-32700.0,min(32700.0,xback))
    	'xbackout=xback
    	levelout+=(Abs(xbackout)-levelout)*0.001
    	auxvar=Int(levelout*1000)/1000
    	'auxvar2=int(gain2*1000)/1000
    	pbuffer[k]=CShort(Int(xbackout))
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
Dim Shared As Single level2=0.8,tlevel=400,klevel=1,level3=0.8,npeek,kframe=1
Dim Shared As Integer nsamples,ndata
Dim shared As Single peekx,peekx2
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
  'If klevel>5 Then klevel=5
  var gain5=min(5.0,0.8*gain2/testgain)
  If klevel>gain5 Then klevel=gain5
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
  'If klevel2>5 Then klevel2=5
  If klevel2>gain5 Then klevel2=gain5
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
  var gain5=min(5.0,0.8*gain2/testgain)
  If klevel>gain5 Then klevel=gain5
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
  'If klevel2>5 Then klevel2=5
  If klevel2>gain5 Then klevel2=gain5
End Sub
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
Dim Shared As Single xnoise,xnoise0,xnoise1
Dim Shared As Double timenoise
Sub noisereduce()
If timenoise<1 Then timenoise=Timer
xnoise1+=(xnoise0-xnoise1)*0.0073
xnoise0+=(xback-xnoise0)*0.0073
Var xbacknoise=xback-xnoise1
xnoise+=(Abs(xbacknoise)-xnoise)*0.0002
If xnoise<1200 And Abs(xbacknoise)<2400 Then
'If xnoise<800 And Abs(xback)<2000 Then
''If xnoise<xnoise0 And Abs(xback)<2000 Then
	'If Timer>timenoise+3 Then xback=0
	If Timer>timenoise+2 Then xback=0
Else 	
	timenoise=Timer 
EndIf
'If xnoise>xnoise0 Then
'	xnoise0=800
'else
'	xnoise0=1200
'EndIf
End Sub
Const As Integer ndecay=880000'1400000
Dim Shared As Integer idecay,didecay,jdecay,irevdecay,irevdecay2,irevdecay0
Dim Shared As double xdecay(ndecay),xxdecay,xydecay,peekdecay,gaindecay,gainrevdecay=0.5,xrevdecay(ndecay),xdecayback
Dim Shared As Double timedecay,xxdecay0,ky1000=1000,kz1000=1000,kdecay=1,xxdecay1,kdecay1=1,gaindecay1
Sub subprocdecay_new()
Dim As Integer i,j,k
idecay+=1:If idecay>ndecay Then idecay=1
Var xback00=xback
'gainrevdecay=0.4
var t9300=0
irevdecay0=idecay-t9300:If irevdecay0<1 Then irevdecay0+=ndecay
irevdecay=idecay-t9300-(20000-5000)*0.01*tdecay:If irevdecay<1 Then irevdecay+=ndecay
irevdecay2=idecay-t9300-(28000-7000)*0.01*tdecay:If irevdecay2<1 Then irevdecay2+=ndecay
'xrevdecay(idecay)=xback-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)
xrevdecay(idecay)=xback
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
If didecay>100 Then
	'jdecay=idecay-didecay/decay
	jdecay=idecay-didecay*(decay-1)/decay
	If jdecay<1 Then jdecay+=ndecay
	Var gaindecay2=max(1.0,min(gain4,max(k400,peekdecay-xxdecay)/max(k400,peekdecay-xdecay(jdecay))))
	'Var gaindecay1=max(0.1,min(4.0,max(400.0,xdecay(jdecay))/max(400.0,xxdecay)))
	'gaindecay2=max(gaindecay1,gaindecay2)
	If xxdecay0<ky1000 Then
		ky1000=2000
      gaindecay2=1
      kdecay=max(0.0,kdecay-0.001)
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
'xdecayback=xback
'xback*=gaindecay
End Sub
Const As Integer ndecaZ=ndecay
Dim Shared As Integer idecaZ,didecaZ,jdecaZ,irevdecaZ,irevdecaZ2,irevdecaZ0
Dim Shared As double xdecaZ(ndecaZ),xxdecaZ,xydecaZ,peekdecaZ,gaindecaZ,gainrevdecaZ=0.5,xrevdecaZ(ndecaZ),xdecaZback
Dim Shared As Double timedecaZ,xxdecaZ0,kdecaZ=1,xxdecaZ1,kdecaZ1=1,gaindecaZ1
Dim Shared As Double avgxdecay,avgxdecay2,avgxdecay1,avggaindecay2,avggaindecay0,avgx100=100,kkdecay100=10,kxback
Sub setavggaindecay()
avgxdecay2+=(avgxdecay1*0.985-avgxdecay2)*0.001*max(1.0,3-avggaindecay2)
avgxdecay+=(avgxdecay1+50-25-avgxdecay)*0.002*2
avgxdecay1+=(Abs(xback)-avgxdecay1)*0.003
avgx100+=(max(100.0,avgxdecay*0.05+80)-avgx100)*0.03'0.1
If testgain<0.141 Then 
 If avgxdecay2<avgxdecay Then
	avggaindecay0+=(avgx100/(avgx100+avgxdecay-avgxdecay2)-avggaindecay0)*0.02
	avggaindecay0=max(avggaindecay0,0.8)'0.85)
 Else 	
	avggaindecay0+=((avgx100+avgxdecay2-avgxdecay)/avgx100-avggaindecay0)*0.01
	avggaindecay0=min(avggaindecay0,1.96)
 EndIf
ElseIf testgain<0.282 Then 
 If avgxdecay2<avgxdecay Then
	avggaindecay0+=(avgx100/(avgx100+avgxdecay-avgxdecay2)-avggaindecay0)*0.02
	avggaindecay0=max(avggaindecay0,0.85)
 Else 	
	avggaindecay0+=((avgx100+avgxdecay2-avgxdecay)/avgx100-avggaindecay0)*0.01
	avggaindecay0=min(avggaindecay0,1.99)
 EndIf
Else
 If avgxdecay2<avgxdecay Then
	avggaindecay0+=(avgx100/(avgx100+avgxdecay-avgxdecay2)-avggaindecay0)*0.02
	avggaindecay0=max(avggaindecay0,0.90)
 Else 	
	avggaindecay0+=((avgx100+avgxdecay2-avgxdecay)/avgx100-avggaindecay0)*0.01
	avggaindecay0=min(avggaindecay0,2.04)
 EndIf
EndIf 
kxback=max(0.05,min(1.0,avgxdecay*0.001))
'kkdecay100=19*0.07/(1.06-kkdecay)
'If avggaindecay0>1 Then
'	avggaindecay=1+(avggaindecay0-1)*0.07/(1.06-kkdecay)
'Else
	avggaindecay=avggaindecay0
'EndIf
'If avgxdecay<1000 Then
'	avggaindecay2+=(min(2.0,avggaindecay*0.6)-avggaindecay2)*0.02
'Else 
	avggaindecay2+=(min(2.0,avggaindecay*0.6)-avggaindecay2)*0.1
'EndIf
'If avggaindecay<1 Then xback*=avggaindecay*avggaindecay
auxvar4=avggaindecay0
auxvar2=Int(avgxdecay)
auxvar3=Int(avgx100)'kxback*100)
End Sub
Sub subprocdecaZ()
Dim As Integer i,j,k
idecaZ+=1:If idecaZ>ndecaZ Then idecaZ=1
Var xback00=xback
'gainrevdecaZ=0.4
Var tdecaZ=tdecay
Var kkdecaZ2=kkdecay'*(kkdecay100+avggaindecay)/(kkdecay100+1)
Var i9300=19300
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
If peekdecaZ<xxdecaZ-100*kxback Or Timexback>timedecaZ+7 Then'-150*
	peekdecaZ=xxdecaZ
	didecaZ=0
Else
	peekdecaZ-=0.03*(peekdecaZ*0.0001/decaZ)
	didecaZ+=1
	If didecaZ>ndecaZ-2 Then didecaZ=ndecaZ-2
EndIf
Var kgain4=min(1.0,2.0*xxdecaZ/max(4000.0,peekdecaZ))'*0.00006)
'Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.8/testgain)),k400=100.0
Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.9/testgain)),k400=100.0
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
'xback*=gaindecaZ
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
Var kkdecay2=kkdecay'*(kkdecay100+avggaindecay)/(kkdecay100+1)
Var i9300=19300
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
If peekdecay<xxdecay-100*kxback Or Timexback>timedecay+7 Then'-150*
	peekdecay=xxdecay
	didecay=0
Else
	peekdecay-=0.03*(peekdecay*0.0001/decay)
	didecay+=1
	If didecay>ndecay-2 Then didecay=ndecay-2
EndIf
Var kgain4=min(1.0,2.0*xxdecay/max(4000.0,peekdecay))'*0.00006)
'Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.8/testgain)),k400=100.0
Var gain4=max(1.0,min(3.0*kgain4*kgain4,0.9/testgain)),k400=100.0
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
'xback*=gaindecay
End Sub
/'Sub subprocdecay0()
Dim As Integer i,j,k
idecay+=1:If idecay>ndecay Then idecay=1
Var xback00=xback
'gainrevdecay=0.4
irevdecay0=idecay-5000:If irevdecay0<1 Then irevdecay0+=ndecay
irevdecay=idecay-5000-20000:If irevdecay<1 Then irevdecay+=ndecay
irevdecay2=idecay-5000-28000:If irevdecay2<1 Then irevdecay2+=ndecay
'xrevdecay(idecay)=xback-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)
xrevdecay(idecay)=xback
xrevdecay(irevdecay0)=xrevdecay(irevdecay0)-(xrevdecay(irevdecay)*0.4+xrevdecay(irevdecay2)*0.37)
'xydecay+=(xdecayback-xydecay)*0.5
xydecay+=(xback-xydecay)*0.5
xxdecay0+=(Abs(xydecay)-xxdecay0)*0.001
xxdecay+=(max(kdecay*Abs(xrevdecay(irevdecay0)),Abs(xydecay))-xxdecay)*0.001
'xxdecay+=(Abs(xydecay)-xxdecay)*0.001
'Var k100=100.0'max(100.0,Abs(xback)*0.01)
If Abs(xback)>xxdecay+200 Then
	xxdecay=Abs(xback)+100
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
      kdecay=max(0.0,kdecay-0.004)
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
End Sub '/ 
/'Sub subprocdecay_old()
Dim As Integer i,j,k
idecay+=1:If idecay>ndecay Then idecay=1
xxdecay+=(Abs(xback)-xxdecay)*0.001
If Abs(xback)>xxdecay Then
	xxdecay=Abs(xback)+100
	timedecay=Timer 
EndIf
xdecay(idecay)=xxdecay	
If decay<1 Then decay=1
If peekdecay<xxdecay-200 Or Timer>timedecay+2 Then
	peekdecay=xxdecay
	didecay=0
Else
	peekdecay-=0.03*(peekdecay*0.0001/decay)
	didecay+=1
	If didecay>=ndecay-1 Then didecay=ndecay-1
EndIf
If didecay>1 Then
	jdecay=idecay-didecay/decay
	If jdecay<1 Then jdecay=ndecay
	Var gain4=min(4.0,0.8*gain2/testgain)
	Var gaindecay2=max(1.0,min(gain4,max(400.0,peekdecay-xxdecay)/max(400.0,peekdecay-xdecay(jdecay))))
	'Var gaindecay1=max(0.1,min(4.0,max(400.0,xdecay(jdecay))/max(400.0,xxdecay)))
	'gaindecay2=max(gaindecay1,gaindecay2)
	If gaindecay<gaindecay2 Then
		gaindecay+=(gaindecay2-gaindecay)*0.004
	Else 	
		gaindecay+=(gaindecay2-gaindecay)*0.003
	EndIf
Else
	gaindecay+=(1-gaindecay)*0.002
EndIf
xback*=gaindecay
End Sub '/
Const As Integer nf=20000,n2=40
Dim Shared As Single L,C,R,Z,f000,dt,w,t,v(n2,nf),dv(n2,nf),u(n2,nf),du(n2,nf)',du2(n2,nf),avgu(nf),avguu
'Dim Shared As Single ii(n2,nf),dii(n2,nf),dii2(n2,nf),ri(n2,nf),dri(n2,nf),dri2(n2,nf)
'Dim Shared As Integer testnoise(nf),noisedj(nf),navgu(nf)
'Dim Shared As Integer tsetnoise,tsetnoise0,navguu
Dim Shared As Single RC(nf),RL(nf),dt1
Sub resetnoise()
Dim As Integer i,j,k,fi
For i=0 To n2
	For j=0 To nf
		v(i,j)=0
		dv(i,j)=0
		u(i,j)=0
		du(i,j)=0
		/'avgu(j)=0
		testnoise(j)=0
		noisedj(j)=0
		avguu=0
		navguu=1
		navgu(j)=1
		'/
	Next
Next
dim as single f0
For f0=1 To nf
	'Var f0=50.0
	'f0=f00'+0.51
	w=2*pi*f0
	fi=max2(0,min2(nf,Int((f0-45)+0.01)))'(45...20045hz)
	dt=dtxback'1/samplerate
	'If Abs(f000-f0)>0.0001 Then
	 'f000=f0
	 Z=1
	 Var kr=Sqr(50/f0)
	 'R=2000*kr
	 R=800*kr
	 C=0.0001*kr
	 L=1/(C*w*w)
	 RC(fi)=1/(R*C)
	 RL(fi)=R/L
	 dt1=1/dt
Next
End Sub
Sub remove50hz(f00 As Single,i0 As integer)
	Dim As Integer fi,ch
	/'
	cu=q =< cdu/dt=i1
	u=Ldi2/dt
	v=Ri+u i=i1+i2
	dv/dt=R(di1+di2)/dt+i1/C
	dv/dt=R(Cdu2/dt2+u/L)+du/dt
	=> du2=((1/RC)*(dv-du-Ru/L))=((1/RC)*(dRi-Ru/L))
	=> du+=du2*dt
	=> u+=du*dt
	Ri=(v-u)
	Ldi/dt+uu=v-u
	Cduu/dt=i
	L(d(di)/dt2+(i)/C=dv/dt-du/dt
	'/
	'ddi=dt*i/LC
	'Var f0=50.0
	Var f0=50.0
	f0=f00'+0.51
	'w=2*pi*f0
	fi=max2(0,min2(nf,Int((f0-45)+0.01)))'(45...20045hz)
	dt=dtxback'1/samplerate
	/'If Abs(RC(fi))<0.0001 Then 
	'If Abs(f000-f0)>0.0001 Then
	 'f000=f0
	 Z=1
	 Var kr=Sqr(50/f0)
	 R=2000*kr
	 C=0.0001*kr
	 L=1/(C*w*w)
	 RC(fi)=1/(R*C)
	 RL(fi)=R/L
	EndIf '/  
	ch=Int(iback And 1)
	If i0>0 And i0<10 Then ch+=i0+i0
	Var vv=xback,dvv=(vv-v(ch,fi))*dt1'/dt
	Var uu=u(ch,fi),duu=du(ch,fi)',duu2=0.0'du2(ch,fi)
	'Var iii=ii(ch,fi),diii=dii(ch,fi),diii2=dii2(ch,fi)=	'Var rii0=ri(ch,fi),drii=dri(ch,fi),drii2=dri2(ch,fi)
	'duu2=((1/(R*C))*(dvv-duu-R*uu/L))
	'duu2=((RC(fi))*(dvv-duu-RL(fi)*uu))
	'duu2=((1/(R*C))*(drii-R*uu/L))
	duu+=((RC(fi))*(dvv-duu-RL(fi)*uu))*dt
	'duu+=duu2*dt'*w
	uu+=duu*dt'*w
	Var Rii=vv-uu
	'diii2=(dvv-duu-iii/C-0.5*R*diii)/L
	'diii+=diii2*dt
	'iii+=diii*dt
	'Var rii=(vv-uu)-R*2*iii
	'drii=rii-rii0
   /'If tsetnoise=1 And i0=5 Then
   	Var uuu=Abs(uu)/(0.1+Abs(vv))
   	avguu+=uuu
   	navguu+=1
  	   avgu(fi)+=uuu
   	navgu(fi)+=1
   EndIf '/
	v(ch,fi)=vv':dv(ch,fi)=dvv
	u(ch,fi)=uu:du(ch,fi)=duu':du2(ch,fi)=duu2
'	ii(ch,fi)=iii:dii(ch,fi)=diiidii2q(ch,fi)diii2q
	'ri(ch,fi)=rii:dri(ch,fi)=drii:dri2(ch,fi)=drii2
	'auxvar=Int(Abs(Rii))
	'auxvar=uu
	'auxvar=level*32700
	xback=(Rii)
End Sub
Sub remove50hzold(f00 As Single,i0 As integer)
	Dim As Integer fi,ch
	/'
	cu=q =< cdu/dt=i1
	u=Ldi2/dt
	v=Ri+u i=i1+i2
	dv/dt=R(di1+di2)/dt+i1/C
	dv/dt=R(Cdu2/dt2+u/L)+du/dt
	=> du2=((1/RC)*(dv-du-Ru/L))=((1/RC)*(dRi-Ru/L))
	=> du+=du2*dt
	=> u+=du*dt
	Ri=(v-u)
	Ldi/dt+uu=v-u
	Cduu/dt=i
	L(d(di)/dt2+(i)/C=dv/dt-du/dt
	'/
	'ddi=dt*i/LC
	Var f0=50.0
	f0=f00'+0.51
	w=2*pi*f0
	fi=max2(0,min2(nf,Int((f0-45)+0.01)))'(45...20045hz)
	dt=dtxback'1/samplerate
	/'If Abs(RC(fi))<0.0001 Then 
	'If Abs(f000-f0)>0.0001 Then
	 'f000=f0
	 Z=1
	 Var kr=Sqr(50/f0)
	 R=2000*kr
	 C=0.0001*kr
	 L=1/(C*w*w)
	 RC(fi)=1/(R*C)
	 RL(fi)=R/L
	EndIf '/  
	ch=Int(iback And 1)
	If i0>0 And i0<10 Then ch+=i0+i0
	Var vv=xback,dvv=(vv-v(ch,fi))*dt1'/dt
	Var uu=u(ch,fi),duu=du(ch,fi),duu2=0.0'du2(ch,fi)
	'Var iii=ii(ch,fi),diii=dii(ch,fi),diii2=dii2(ch,fi)=	'Var rii0=ri(ch,fi),drii=dri(ch,fi),drii2=dri2(ch,fi)
	'duu2=((1/(R*C))*(dvv-duu-R*uu/L))
	duu2=((RC(fi))*(dvv-duu-RL(fi)*uu))
	'duu2=((1/(R*C))*(drii-R*uu/L))
	duu+=duu2*dt'*w
	uu+=duu*dt'*w
	Var Rii=vv-uu
	'diii2=(dvv-duu-iii/C-0.5*R*diii)/L
	'diii+=diii2*dt
	'iii+=diii*dt
	'Var rii=(vv-uu)-R*2*iii
	'drii=rii-rii0

	v(ch,fi)=vv:dv(ch,fi)=dvv:u(ch,fi)=uu:du(ch,fi)=duu':du2(ch,fi)=duu2
'	ii(ch,fi)=iii:dii(ch,fi)=diiidii2q(ch,fi)diii2q
	'ri(ch,fi)=rii:dri(ch,fi)=drii:dri2(ch,fi)=drii2
	'auxvar=Int(Abs(Rii)+0.001)
	'auxvar=level*32700
	xback=(Rii)
End Sub
Dim Shared As Integer noisej
Sub setnoise()
/'Dim As Integer i,j
Sleep 200
tsetnoise=1
For j=0 To 200 Step 5
	noisej=j
	Sleep 200
Next
tsetnoise=0
'/	
End Sub
Const As Integer nspeed=9000'0.1s
Const As Integer nspeed2=nspeed/3,nspeed4=samplerate/30
Dim Shared As Integer ispeed,ispeed21
Dim Shared As Single ispeed2
Dim Shared As Single speedx(-10 To nspeed+10)
Sub procspeed()
ispeed+=1:If ispeed>=nspeed Then ispeed=0
ispeed2+=speed
If iback=1 Then ispeed2+=0.03*buffersize/300
If ispeed2>nspeed Then ispeed2-=nspeed
If ispeed2>(ispeed Or 1)-3 Then
	If ispeed2<(ispeed+nspeed2) Then
		ispeed2=(ispeed Or 1)-5
		If ispeed2<=0 Then ispeed2+=nspeed
	ElseIf (ispeed2-nspeed)<((ispeed Or 1)-3-nspeed4) Then
		ispeed2=(ispeed Or 1)-1-nspeed4
		If ispeed2<=0 Then ispeed2+=nspeed	
	EndIf
ElseIf ispeed2<(ispeed Or 1)-3-nspeed4 Then
		ispeed2=(ispeed Or 1)-1-nspeed4
		If ispeed2<=0 Then ispeed2+=nspeed	
EndIf
speedx(ispeed)=xback
If (iback And 1) Then
	xback=speedx(Int(ispeed2)Or 1)
Else
	ispeed21=(Int(ispeed2)or 1)+1
	If ispeed21<=0 Then ispeed21+=nspeed
	If ispeed21>nspeed Then ispeed21-=nspeed
	xback=speedx(ispeed21)
EndIf
End Sub
Dim Shared As Single xlow(9),xxlow(9),yxlow(9),yxxlow(9)
Sub removelow()
Dim As Integer i
Var i2=4,kx=0.0033'*1.2
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
Dim Shared As Single xlow2(9),xxlow2(9),yxlow2(9),yxxlow2(9)
Sub removelow2()
Dim As Integer i
Var i2=1,kx=0.0033'*1.2
If iback And 1 Then
	For i=i2 To 1 Step -1
		xlow2(i)+=(xxlow2(i-1)-xlow2(i))*kx'0.002'88hz
		xxlow2(i)=xxlow2(i-1)-xlow2(i)
	Next
	xlow2(0)+=(xback-xlow2(0))*kx'*0.5'0.002'88hz
	xxlow2(0)=xback-xlow2(0)
	xback=xxlow2(i2)
Else
	For i=i2 To 1 Step -1
		yxlow2(i)+=(yxxlow2(i-1)-yxlow2(i))*kx'0.002'88hz
		yxxlow2(i)=yxxlow2(i-1)-yxlow2(i)
	Next
	yxlow2(0)+=(xback-yxlow2(0))*kx'*0.5'0.002'88hz
	yxxlow2(0)=xback-yxlow2(0)
	xback=yxxlow2(i2)
EndIf
End Sub
Dim Shared As Single xbacklow,f50hzold
Dim Shared As Double timeaux
Sub Myprocback()
Dim As Integer i,j,k
	   If bypass=1 Then Exit Sub
	   removelow()
	   Var f0=500.0
	   f0=f50hz
	   /'auxvar2=11.1
	   Var f1=f0+2
	   If Int(Timer/8)And 1 Then
	   	f1=f0
	   	auxvar2=0.1
	   EndIf
	   xback=20000*Cos(2*pi*f1*timexback)
	   '/
	   /'If tsetnoise<>tsetnoise0 Then
	   	tsetnoise0=tsetnoise
	   	If tsetnoise=1 Then
	   		resetnoise()
	   	Else 
	   		auxvar3=0.1
            auxvar2=avguu+0.001
	   		avguu*=2.1/navguu
	   		Var j0=0
	   		For j=0 To 200
	   			Var fi=Int(f0+j*(1+j*0.05)+0.0001)
	   			i=5 
	   				 Var ch=0
	   			  	 If i>0 And i<10 Then ch+=i+i
                   If (avgu(fi)/navgu(fi))>avguu Then
	   				   testnoise(fi)=1
	   				   noisedj(j0)=j-j0
	   				   j0=j+1
	   				   auxvar3+=1
	   				   If auxvar3>8 Then Exit For 
	   			    EndIf
	   			  
	   		Next j
	   		auxvar4=j0
	   		If j0<200 Then noisedj(j0)=200-j0
	   	EndIf
	   EndIf '/
		If Abs(f50hz-f50hzold)>0.1 Then
		 	f50hzold=f50hz
		 	resetnoise()
		EndIf

		If remove50>=1 Then
		 For j=1 To 2''200
		  'If tsetnoise=0 Then
		  	'j+=noisedj(j)
		  'ElseIf Abs(j-noisej)>2 Then
		  	'Continue For
		  'EndIf
		  'Var fi=Int(f0+j*(1+j*0.05)+0.0001)
		  'If testnoise(fi)=1 Or tsetnoise=1 then	
		   For i=1 To 3
			  remove50hz(f0*j,i)
		   Next i
		  'EndIf  
		 Next j
		EndIf '/  
		'If Abs(xback)>1000 Then
		'	If Timer>timeaux+0.1 Then auxvar2+=1
		'	timeaux=timer
		'EndIf
		If noisered=1 Then noisereduce()
		If noisered=0 or 1 Then
			xback2=xback1
			xback1=xback0
			xback0=xback
		Else
			If iback And 1 Then
				xback1+=(xback-xback1)*0.2
				xback0=xback
				xback=xback1
			Else
				xback2+=(xback-xback2)*0.2
				xback0=xback
				xback=xback2				
			EndIf
		EndIf
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
		'If equal=1 Then subequal()
		'xback*=volout3
		If pluginproc<>0 Then xback=pluginproc(xback)
		If plugin2proc<>0 Then xback=plugin2proc(xback)
		If plugin3proc<>0 Then xback=plugin3proc(xback)
		If plugin4proc<>0 Then xback=plugin4proc(xback)
		
		If decay>1.0 Then
			subprocdecay()
		EndIf
		If Abs(xback)>peekx2 Then peekx2=Abs(xback)
		If xback>32767 Then xback=32767
		If xback<-32767 Then xback=-32767
		If Timer<timeinit+3 Then
			xback=xback0
		ElseIf Timer<timeinit+3+3 Then
			xback*=max(0.0,min(1.0,(Timer-timeinit-3)/3))
		EndIf
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