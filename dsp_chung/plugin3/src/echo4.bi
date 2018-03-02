Dim Shared As Single xrev(4),xrevtot,revdata(4,48000*2*2) 'max rev 2seconds 48khz stereo
Dim Shared As Integer ireverb(4),nreverb=48000*2*2,echo(4)
Dim Shared As Integer nchannels=2,nrate=44100
Dim Shared As Single  vol(4),delay(4),feedback(4),volmax,voltot,volcombi,volume
Dim Shared As Integer ireverb1(4),jreverb1,i,j,k,echotype,necho,pan
Dim Shared As Single  ffeedback(4)
For i=0 To 4 
 vol(i)=1
 delay(i)=100
 feedback(i)=0.5	
 vol(i)=max(0.0,min(2.0,vol(i)))
 delay(i)=max(10.0,min(2000.0,delay(i)))
 feedback(i)=max(0.0,min(0.99,feedback(i)))
 echo(i)=0
Next i
Sub setreverb()
Dim As Integer i 
Erase revdata 'static
volmax=0.001
voltot=0.001
volcombi=0.001
necho=0
For i=1 To 4
 ireverb(i)=1
 ffeedback(i)=max(0.0,min(0.95,feedback(i)+pan/10))	
 ireverb1(i)=max2(2,min2(nreverb-4,int(delay(i)*nrate/1000)*nchannels))          	          	
 If echo(i)=1 Then
   volmax=max(vol(i),volmax)
   volcombi+=vol(i)*vol(i)
   voltot+=vol(i)
   necho+=1
 EndIf   
Next i
volcombi=volcombi/voltot
End Sub
setreverb()
Function functionreverb(ByVal xback As Single,ByVal i As Integer=1)As Single
If nchannels>=1 Then
   jreverb1=ireverb(i)-ireverb1(i)-1
   If jreverb1<0 Then jreverb1+=nreverb
   If (ireverb(i) And 1) Then
   	xrev(i)=ffeedback(i)*revdata(i,jreverb1)+1e-7
   Else 
   	xrev(i)=feedback(i)*revdata(i,jreverb1)+1e-7
   EndIf
   revdata(i,ireverb(i))=xrev(i)+xback
   ireverb(i)+=1
   If ireverb(i)>=nreverb Then ireverb(i)=0
   return xrev(i)   		
EndIf
Return xback
End function
Function functionreverbcombi(ByVal xback As Single)As Single
Dim As Integer i
If nchannels>=1 And necho>=1 Then
 xrevtot=0
 For i=1 To 4
 	If echo(i)=1 Then
     jreverb1=ireverb(1)-ireverb1(i)-1
     If jreverb1<0 Then jreverb1+=nreverb
     If (ireverb(1) And 1) Then
     	 xrevtot+=vol(i)*ffeedback(i)*revdata(1,jreverb1)+1e-7
     Else 
     	 xrevtot+=vol(i)*feedback(i)*revdata(1,jreverb1)+1e-7
     EndIf
   EndIf   
 Next i
 xrevtot/=(voltot)
 revdata(1,ireverb(1))=xrevtot+xback
 ireverb(1)+=1
 If ireverb(1)>=nreverb Then ireverb(1)=0
 Return xrevtot   		
EndIf
Return 0
End function
