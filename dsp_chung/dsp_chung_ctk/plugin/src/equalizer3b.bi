Dim Shared As Integer lowfz,highfz,zequaltype=1,midfreq=800,onoff=1
Dim Shared As double lowgz,midgz,highgz,l,m,h,g,kf0,lowdb,highdb,k1db,k2db
Dim Shared As Integer lowfz0,highfz0,zequaltype0=1
Dim Shared As Double lowgz0,midgz0,highgz0
Dim Shared As Double gain=1
Dim Shared As String textgain(100)
Dim Shared As String textmidfreq(100)
Dim Shared As String texgain,texlow,texmid,texhigh,texmidfreq
lowfz=200
highfz=8000
lowgz=2.0
midgz=1.0
highgz=1.2
kf0=1

Dim Shared As Double sample1,sample2,sample1_2,sample2_2

  ' Filter #1 (Low band)
Dim Shared ez_lf   As Double        ' Frequency/100000.0
Dim Shared ez_lf00   As Double        ' Frequency/100000.0
Dim Shared ez_f1p0 As Double        ' Poles ...
Dim Shared ez_f1p00 As Double        ' Poles ...

  ' Filter #2 (High band)
Dim Shared ez_hf   As Double        ' Frequency/100000.0
Dim Shared ez_f2p0 As Double        ' Poles ...

  ' Sample history buffer
Dim Shared ez_s1 As Double       ' Sample data minus 1
Dim Shared ez_s2 As Double       '                   2
Dim Shared ez_s3 As Double       '                   3
Dim Shared ez_s4 As Double       '                   3

  ' Gain Controls
Dim Shared ez_lowgz As Double        ' low  gain
Dim Shared ez_midgz As Double        ' mid  gain
Dim Shared ez_highgz As Double       ' high gain
 

  ' Filter #1 (Low band)
Dim Shared ez2_lf   As Double        ' Frequency/100000.0
Dim Shared ez2_lf00   As Double        ' Frequency/100000.0
Dim Shared ez2_f1p0 As Double        ' Poles ...
Dim Shared ez2_f1p00 As Double       

  ' Filter #2 (High band)
Dim Shared ez2_hf   As Double        ' Frequency/100000.0
Dim Shared ez2_f2p0 As Double        ' Poles ...

  ' Sample history buffer
Dim Shared ez2_s1 As Double       ' Sample data minus 1
Dim Shared ez2_s2 As Double       '                   2
Dim Shared ez2_s3 As Double       '                   3
Dim Shared ez2_s4 As Double       '                   3

  ' Gain Controls
Dim Shared ez2_lowgz As Double        ' low  gain
Dim Shared ez2_midgz As Double        ' mid  gain
Dim Shared ez2_highgz As Double       ' high gain

function zequcalcul1_low (byval sample as double) as Double
  ' Filter #1 (lowpass)
  'g=(ez_lf)
  ez_f1p0  += ((sample - ez_f1p0+1e-9)*(ez_lf))'g)

  l = (ez_f1p0)

  ez_f1p00  += ((sample - ez_f1p00+1e-9)*(ez_lf00))'g)

  ' Calculate midrange (signal - (low) - low00)
  m = (sample) - (l) -ez_f1p00

  ' Scale, Combine and store
  'l         *= ((ez_lowgz))
  'm         *= ((ez_midgz))
  'h         *= ((ez_highgz))

  'return (l+m+h) 
  return (l*ez_lowgz+m) 
end function 
Function zequcalcul1_high (byval sample as double) as Double
  ' Filter #2 (highpass)
  'g=(ez_hf)
  ez_f2p0  += ((sample - ez_f2p0+1e-9)*(ez_hf))'g)

  h = (sample - ez_f2p0)

  ' Calculate midrange (signal - (low + high))
  m = (sample) - (h)

  ' Scale, Combine and store
  'l         *= ((ez_lowgz))
  'm         *= ((ez_midgz))
  'h         *= ((ez_highgz))

  'return (l+m+h) 
  return (m+h*ez_highgz) 
end function 
function zequcalcul1 (byval sample as double) as Double
'Var k1=abs(lowdb)/20.0
'Var k2=Abs(highdb)/20.0
'sample1=(1.0-k1db)*sample+k1db*zequcalcul1_low(sample)
'sample2=(1.0-k2db)*sample1+k2db*zequcalcul1_high(sample1)	
sample1=(1.0-k2db)*sample+k2db*zequcalcul1_high(sample)
sample2=(1.0-k1db)*sample1+k1db*zequcalcul1_low(sample1)	
Return sample2
End Function

function zequcalcul2_low (byval sample as double) as Double
  ' Filter #1 (lowpass)
  'g=(ez_lf)
  ez2_f1p0  += ((sample - ez2_f1p0+1e-9)*(ez2_lf))'g)

  l = (ez2_f1p0)

  ez2_f1p00  += ((sample - ez2_f1p00+1e-9)*(ez2_lf00))'g)

  ' Calculate midrange (signal - (low) -low00)
  m = (sample) - (l) -ez2_f1p00

  ' Scale, Combine and store
  'l         *= ((ez_lowgz))
  'm         *= ((ez_midgz))
  'h         *= ((ez_highgz))

  'return (l+m+h) 
  return (l*ez2_lowgz+m) 
end function 
Function zequcalcul2_high (byval sample as double) as Double
  ' Filter #2 (highpass)
  'g=(ez_hf)
  ez2_f2p0  += ((sample - ez2_f2p0+1e-9)*(ez2_hf))'g)

  h = (sample - ez2_f2p0)

  ' Calculate midrange (signal - (low + high))
  m = (sample) - (h)

  ' Scale, Combine and store
  'l         *= ((ez_lowgz))
  'm         *= ((ez_midgz))
  'h         *= ((ez_highgz))

  'return (l+m+h) 
  return (m+h*ez2_highgz) 
end function 
function zequcalcul2 (byval sample as double) as Double
'sample1_2=(1.0-k1db)*sample+k1db*zequcalcul2_low(sample)
'sample2_2=(1.0-k2db)*sample1_2+k2db*zequcalcul2_high(sample1_2)	
sample1_2=(1.0-k2db)*sample+k2db*zequcalcul2_high(sample)
sample2_2=(1.0-k1db)*sample1_2+k1db*zequcalcul2_low(sample1_2)	
Return sample2_2
End Function

Sub zresetequalizer()'ByVal kf0 As double)
Dim As Integer mixfreq,maxfreq
lowfz=midfreq/10'*(1+0.05*Abs(lowgz-midgz))/(1.5+Abs(lowgz-midgz))
highfz=midfreq*10'*(1.5+Abs(highgz-midgz))/(1+0.05*Abs(highgz-midgz))
kf0=1.0'midfreq/1000.0
mixfreq=44100'fbs_get_plugrate()
If mixfreq<4000 Then mixfreq=4000
If mixfreq>100000 Then mixfreq=100000
'mixfreq=44100
ez_lf =  2 * sin(3.1416 * (lowfz *kf0/ mixfreq))
ez_hf =  2 * sin(3.1416 * (highfz*kf0 / mixfreq))
ez2_lf = 2 * sin(3.1416 * (lowfz *kf0/ mixfreq))
ez2_hf = 2 * sin(3.1416 * (highfz*kf0 / mixfreq))
ez_lf00 =  2 * sin(3.1416 * (50 *kf0/ mixfreq))
ez2_lf00 =  2 * sin(3.1416 * (50 *kf0/ mixfreq))
midgz=1.0
ez_lowgz=10^(Sgn(lowdb))
ez_midgz=midgz
ez_highgz=10^(Sgn(highdb))	
ez2_lowgz=10^(Sgn(lowdb))
ez2_midgz=midgz
ez2_highgz=10^(Sgn(highdb))
k1db=(10^Abs(lowdb/20)-1)/9
k2db=(10^Abs(highdb/20)-1)/9

maxfreq=mixfreq/2.2'3.4'3
If lowfz*kf0>=(maxfreq) Then
	ez_lf=  2 * sin(3.1416 * (maxfreq/mixfreq))
	ez2_lf=  2 * sin(3.1416 * (maxfreq/mixfreq))
	ez_lowgz=midgz
	ez2_lowgz=midgz
EndIf
If highfz*kf0>=(maxfreq) Then
	ez_hf=  2 * sin(3.1416 * (maxfreq/mixfreq))
	ez2_hf=  2 * sin(3.1416 * (maxfreq/mixfreq))
	ez_highgz=midgz
	ez2_highgz=midgz
EndIf
  /'
  sample1=1e-9
  sample2=1e-9
  sample1_2=1e-9
  sample2_2=1e-9
  
  ez_f1p0 =1e-9
  ez_f2p0 =1e-9
  ez_s1 =1e-9
  ez_s2 =1e-9
  ez_s3 =1e-9
  ez_s4 =1e-9

  ez2_f1p0 =1e-9
  ez2_f2p0 =1e-9
  ez2_s1 =1e-9
  ez2_s2 =1e-9
  ez2_s3 =1e-9
  ez2_s4 =1e-9
  '/
end sub 
/'Sub resetkeytone(ByVal i As Integer)
Dim As double kf0
If i<0 Or i>8 Then Exit Sub
kf0=0.900*2^(i-5)
zresetequalizer(kf0)
End Sub '/
