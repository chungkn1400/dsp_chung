Dim Shared As Any Ptr hplugin
Dim Shared plugininit As Function() As Integer 
Dim Shared pluginmain As Function() As Integer 
Dim Shared pluginproc As Function(ByVal sample As single) As Single  
Dim Shared pluginclose As Function() As Integer 
Dim Shared As Any Ptr hplugin2
Dim Shared plugin2init As Function() As Integer  
Dim Shared plugin2main As Function() As Integer 
Dim Shared plugin2proc As Function(ByVal sample As single) As Single  
Dim Shared plugin2close As Function() As Integer
Dim Shared As Any Ptr hplugin3
Dim Shared plugin3init As Function() As Integer 
Dim Shared plugin3main As Function() As Integer 
Dim Shared plugin3proc As Function(ByVal sample As single) As Single  
Dim Shared plugin3close As Function() As Integer
Dim Shared As Any Ptr hplugin4
Dim Shared plugin4init As Function() As Integer 
Dim Shared plugin4main As Function() As Integer 
Dim Shared plugin4proc As Function(ByVal sample As single) As Single  
Dim Shared plugin4close As Function() As Integer
Dim Shared As Integer tplugin=0 
Sub loadplugin()
Dim As String fic,curdir0
fic=Dir("plugin\*.dll")
If fic="" Then Exit Sub
If hplugin=0 Then 
 	hplugin=DyLibLoad(ExePath+"/plugin/"+fic)
EndIf
plugininit=0:pluginmain=0:pluginproc=0:pluginclose=0
If hplugin<>0 Then 
	plugininit=DylibSymbol(hplugin,"plugininit")
EndIf
If plugininit<>0 Then 
	pluginmain=DylibSymbol(hplugin,"pluginmain")
EndIf
If pluginmain<>0 Then 
	pluginproc=DylibSymbol(hplugin,"pluginproc")
EndIf
If pluginproc<>0 Then 
	pluginclose=DylibSymbol(hplugin,"pluginclose")
EndIf
If pluginclose=0 Or pluginproc=0 Or plugininit=0 Then
   plugininit=0:pluginmain=0:pluginproc=0:pluginclose=0
EndIf
If plugininit<>0 Then
	curdir0=CurDir
	ChDir(ExePath+"/plugin")
	plugininit()
	ChDir(curdir0)
EndIf
End Sub
Dim Shared As Any Ptr hsubplugin
Sub subplugin(ByVal userdata As Any Ptr=0)
If pluginmain<>0 Then pluginmain()
hsubplugin=0
End Sub
Sub loadplugin2()
Dim As String fic,curdir0
fic=Dir("plugin2\*.dll")
If fic="" Then Exit Sub
If hplugin2=0 Then 
 	hplugin2=DyLibLoad(ExePath+"/plugin2/"+fic)
EndIf
plugin2init=0:plugin2main=0:plugin2proc=0:plugin2close=0
If hplugin2<>0 Then 
	plugin2init=DylibSymbol(hplugin2,"plugininit")
EndIf
If plugin2init<>0 Then 
	plugin2main=DylibSymbol(hplugin2,"pluginmain")
EndIf
If plugin2main<>0 Then 
	plugin2proc=DylibSymbol(hplugin2,"pluginproc")
EndIf
If plugin2proc<>0 Then 
	plugin2close=DylibSymbol(hplugin2,"pluginclose")
EndIf
If plugin2close=0 Or plugin2proc=0 Or plugin2init=0 Then
   plugin2init=0:plugin2main=0:plugin2proc=0:plugin2close=0
EndIf
If plugin2init<>0 Then
	curdir0=CurDir
	ChDir(ExePath+"/plugin2")
	plugin2init()
	ChDir(curdir0)
EndIf
End Sub
Dim Shared As Any Ptr hsubplugin2
Sub subplugin2(ByVal userdata As Any Ptr=0)
If plugin2main<>0 Then plugin2main()
hsubplugin2=0
End Sub
Sub loadplugin3()
Dim As String fic,curdir0
fic=Dir("plugin3\*.dll")
If fic="" Then Exit Sub
If hplugin3=0 Then 
 	hplugin3=DyLibLoad(ExePath+"/plugin3/"+fic)
EndIf
plugin3init=0:plugin3main=0:plugin3proc=0:plugin3close=0
If hplugin3<>0 Then 
	plugin3init=DylibSymbol(hplugin3,"plugininit")
EndIf
If plugin3init<>0 Then 
	plugin3main=DylibSymbol(hplugin3,"pluginmain")
EndIf
If plugin3main<>0 Then 
	plugin3proc=DylibSymbol(hplugin3,"pluginproc")
EndIf
If plugin3proc<>0 Then 
	plugin3close=DylibSymbol(hplugin3,"pluginclose")
EndIf
If plugin3close=0 Or plugin3proc=0 Or plugin3init=0 Then
   plugin3init=0:plugin3main=0:plugin3proc=0:plugin3close=0
EndIf
If plugin3init<>0 Then
	curdir0=CurDir
	ChDir(ExePath+"/plugin3")
	plugin3init()
	ChDir(curdir0)
EndIf
End Sub
Dim Shared As Any Ptr hsubplugin3
Sub subplugin3(ByVal userdata As Any Ptr=0)
If plugin3main<>0 Then plugin3main()
hsubplugin3=0
End Sub
Sub loadplugin4()
Dim As String fic,curdir0
fic=Dir("plugin4\*.dll")
If fic="" Then Exit Sub
If hplugin4=0 Then 
 	hplugin4=DyLibLoad(ExePath+"/plugin4/"+fic)
EndIf
plugin4init=0:plugin4main=0:plugin4proc=0:plugin4close=0
If hplugin4<>0 Then 
	plugin4init=DylibSymbol(hplugin4,"plugininit")
EndIf
If plugin4init<>0 Then 
	plugin4main=DylibSymbol(hplugin4,"pluginmain")
EndIf
If plugin4main<>0 Then 
	plugin4proc=DylibSymbol(hplugin4,"pluginproc")
EndIf
If plugin4proc<>0 Then 
	plugin4close=DylibSymbol(hplugin4,"pluginclose")
EndIf
If plugin4close=0 Or plugin4proc=0 Or plugin4init=0 Then
   plugin4init=0:plugin4main=0:plugin4proc=0:plugin4close=0
EndIf
If plugin4init<>0 Then
	curdir0=CurDir
	ChDir(ExePath+"/plugin4")
	plugin4init()
	ChDir(curdir0)
EndIf
End Sub
Dim Shared As Any Ptr hsubplugin4
Sub subplugin4(ByVal userdata As Any Ptr=0)
If plugin4main<>0 Then plugin4main()
hsubplugin4=0
End Sub
Sub displayplugins()
      If hsubplugin=0 And pluginmain<>0 Then
        	hsubplugin=ThreadCreate(Cast(Any ptr,@subplugin))
        	Sleep 500
      EndIf
      If hsubplugin2=0 And plugin2main<>0 Then
       	hsubplugin2=ThreadCreate(Cast(Any ptr,@subplugin2))
        	Sleep 500
      EndIf	
      If hsubplugin3=0 And plugin3main<>0 Then
       	hsubplugin3=ThreadCreate(Cast(Any ptr,@subplugin3))
        	Sleep 500
      EndIf	
      If hsubplugin4=0 And plugin4main<>0 Then
       	hsubplugin4=ThreadCreate(Cast(Any ptr,@subplugin4))
        	Sleep 500
      EndIf		
End Sub
Sub closeplugins()
If hsubplugin<>0 Then
	If pluginclose<>0 Then pluginclose()
	ThreadWait(hsubplugin)
EndIf
If hsubplugin2<>0 Then
	If plugin2close<>0 Then plugin2close()
	ThreadWait(hsubplugin2)
EndIf
If hsubplugin3<>0 Then
	If plugin3close<>0 Then plugin3close()
	ThreadWait(hsubplugin3)
EndIf
If hsubplugin4<>0 Then
	If plugin4close<>0 Then plugin4close()
	ThreadWait(hsubplugin4)
EndIf
Sleep 700'guinotice "ok"
If hplugin<>0 Then DylibFree(hplugin)
If hplugin2<>0 Then DylibFree(hplugin2)
If hplugin3<>0 Then DylibFree(hplugin3)
If hplugin4<>0 Then DylibFree(hplugin4)
Sleep 300	
End Sub
Sub loadplugins()
If hplugin=0 Then loadplugin()
If hplugin2=0 Then loadplugin2()
If hplugin3=0 Then loadplugin3()
If hplugin4=0 Then loadplugin4()
End Sub 
