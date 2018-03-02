/'Const MMSYSERR_NOERROR = 0
Const MAXPNAMELEN = 32

Const MIXER_LONG_NAME_CHARS = 64
Const MIXER_SHORT_NAME_CHARS = 16
Const MIXER_GETLINEINFOF_LINEID = &H2
Const MIXER_GETLINEINFOF_COMPONENTTYPE = &H3&
Const MIXER_GETCONTROLDETAILSF_VALUE = &H0&
Const MIXER_GETCONTROLDETAILSF_LISTTEXT = &H1&
Const MIXER_GETLINECONTROLSF_ONEBYID = &H1
Const MIXER_GETLINECONTROLSF_ONEBYTYPE = &H2&
Const MIXER_OBJECTF_WAVEOUT = &H10000000
Const MIXER_SETCONTROLDETAILSF_VALUE = &H0&

Const MIXERCONTROL_CT_CLASS_FADER = &H50000000
Const MIXERCONTROL_CT_CLASS_SWITCH = &H20000000
Const MIXERCONTROL_CT_UNITS_BOOLEAN = &H10000
Const MIXERCONTROL_CT_UNITS_UNSIGNED = &H30000
Const MIXERCONTROL_CONTROLTYPE_FADER = (MIXERCONTROL_CT_CLASS_FADER Or MIXERCONTROL_CT_UNITS_UNSIGNED)
Const MIXERCONTROL_CONTROLTYPE_VOLUME = (MIXERCONTROL_CONTROLTYPE_FADER + 1)
Const MIXERCONTROL_CONTROLTYPE_BASS = (MIXERCONTROL_CONTROLTYPE_FADER + 2)
Const MIXERCONTROL_CONTROLTYPE_TREBLE = (MIXERCONTROL_CONTROLTYPE_FADER + 3)
Const MIXERCONTROL_CONTROLTYPE_EQUALIZER = (MIXERCONTROL_CONTROLTYPE_FADER + 4)
Const MIXERCONTROL_CONTROLTYPE_BOOLEAN = (MIXERCONTROL_CT_CLASS_SWITCH Or MIXERCONTROL_CT_UNITS_BOOLEAN)
Const MIXERCONTROL_CONTROLTYPE_MUTE = (MIXERCONTROL_CONTROLTYPE_BOOLEAN + 2)
Const MIXERLINE_COMPONENTTYPE_SRC_FIRST = &H1000&
Const MIXERLINE_COMPONENTTYPE_SRC_UNDEFINED = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 0)
Const MIXERLINE_COMPONENTTYPE_SRC_DIGITAL = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 1)
Const MIXERLINE_COMPONENTTYPE_SRC_LINE = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 2)
Const MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 3)
Const MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 4)
Const MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 5)
Const MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 6)
Const MIXERLINE_COMPONENTTYPE_SRC_PCSPEAKER = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 7)
Const MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 8)
Const MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 9)
Const MIXERLINE_COMPONENTTYPE_SRC_ANALOG = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 10)
Const MIXERLINE_COMPONENTTYPE_SRC_LAST = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 10)
Const MIXERLINE_COMPONENTTYPE_DST_FIRST = &H0&
Const MIXERLINE_COMPONENTTYPE_DST_UNDEFINED = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 0)
Const MIXERLINE_COMPONENTTYPE_DST_DIGITAL = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 1)
Const MIXERLINE_COMPONENTTYPE_DST_LINE = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 2)
Const MIXERLINE_COMPONENTTYPE_DST_MONITOR = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 3)
Const MIXERLINE_COMPONENTTYPE_DST_SPEAKERS = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 4)
Const MIXERLINE_COMPONENTTYPE_DST_HEADPHONES = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 5)
Const MIXERLINE_COMPONENTTYPE_DST_TELEPHONE = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 6)
Const MIXERLINE_COMPONENTTYPE_DST_WAVEIN = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 7)
Const MIXERLINE_COMPONENTTYPE_DST_VOICEIN = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 8)
Const MIXERLINE_COMPONENTTYPE_DST_LAST = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 8)
'/
#Undef mixercaps
Type MIXERCAPS field=1
  wMid           As short
  wPid           As short
  vDriverVersion as integer
  szPname        As zString * MAXPNAMELEN
  fdwSupport     as integer
  cDestinations  as integer
End Type

#Undef mixercontrol
Type MIXERCONTROL field=1
  cbStruct       as integer
  dwControlID    as integer
  dwControlType  as integer
  fdwControl     as integer
  cMultipleItems as integer
  szShortName    As zString * MIXER_SHORT_NAME_CHARS
  szName         As zString * MIXER_LONG_NAME_CHARS
  union
    type
     lMinimum as integer
     lMaximum as integer
    end type
    type
     dwMinimum as uinteger
     dwMaximum as uinteger
    end type
    dwReserved1(6-1) as integer
  end union
  union
    cSteps as integer
    cbCustomData as integer
    dwReserved2(6-1) as integer
  end union
End Type

#Undef mixercontroldetails
Type MIXERCONTROLDETAILS
  cbStruct    as integer
  dwControlID as integer
  cChannels   as integer
  item        as integer
  cbDetails   as integer
  paDetails   As any ptr
End Type

#Undef mixercontroldetails_unsigned
Type MIXERCONTROLDETAILS_UNSIGNED
  dwValue as integer
End Type
/'
Type MIXERLINE field=1
  cbStruct        as integer
  dwDestination   as integer
  dwSource        as integer
  dwLineID        as integer
  fdwLine         as integer
  dwUser          as integer
  dwComponentType as integer
  cChannels       as integer
  cConnections    as integer
  cControls       as integer
  szShortName     As zString * MIXER_SHORT_NAME_CHARS
  szName          As zString * MIXER_LONG_NAME_CHARS
  dwType          as integer
  dwDeviceID      as integer
  wMid            As short
  wPid            As short
  vDriverVersion  as integer
  szPname         As zString * MAXPNAMELEN
End Type
'/
#Undef mixerlinecontrols
Type MIXERLINECONTROLS
  cbStruct  as integer
  dwLineID  as integer
  dwControl as integer
  cControls as integer
  cbmxctrl  as integer
  pamxctrl  As MIXERCONTROL ptr
End Type
/'
extern "windows"
Declare Function mixerClose Lib "winmm.dll" (ByVal hmx as integer) as integer
Declare Function mixerGetControlDetails Lib "winmm.dll" Alias "mixerGetControlDetailsA" ( _
  ByVal hmxobj     as integer, _
  byref pmxcd      As MIXERCONTROLDETAILS, _
  ByVal fdwDetails as integer) as integer
Declare Function mixerGetDevCaps Lib "winmm.dll" Alias "mixerGetDevCapsA" ( _
  ByVal uMxId    as integer, _
  Byval pmxcaps  As MIXERCAPS ptr, _
  ByVal cbmxcaps as integer) as integer
Declare Function mixerGetID Lib "winmm.dll" ( _
  ByVal hmxobj as integer, _
  byval pumxID as integer ptr,_
  ByVal fdwId  as integer) as integer
Declare Function mixerGetLineControls Lib "winmm.dll" Alias "mixerGetLineControlsA" ( _
  ByVal hmxobj      as integer, _
  byval pmxlc       As MIXERLINECONTROLS ptr, _
  ByVal fdwControls as integer) as integer
Declare Function mixerGetLineInfo Lib "winmm.dll" Alias "mixerGetLineInfoA" ( _
  ByVal hmxobj  as integer, _
  byval pmxl    As MIXERLINE ptr,_
  ByVal fdwInfo as integer) as integer
Declare Function mixerGetNumDevs Lib "winmm.dll" () as integer
Declare Function mixerMessage Lib "winmm.dll" ( _
  ByVal hmx      as integer, _
  ByVal uMsg     as integer, _
  ByVal dwParam1 as integer, _
  ByVal dwParam2 as integer) as integer
Declare Function mixerOpen Lib "winmm.dll" ( _
  byval phmx       as integer ptr, _
  ByVal uMxId      as integer, _
  ByVal dwCallback as any ptr, _
  ByVal dwInstance as integer, _
  ByVal fdwOpen    as integer) as integer
Declare Function mixerSetControlDetails Lib "winmm.dll" ( _
  ByVal hmxobj     as integer, _
  byref pmxcd      As MIXERCONTROLDETAILS, _
  ByVal fdwDetails as integer) as integer

end extern
'/ 
type MIXER_CLASS
  declare constructor
  declare destructor
  declare property MinWaveVolume   as integer
  declare property MaxWaveVolume   as integer
  declare property MinMicVolume    as integer
  declare property MaxMicVolume    as integer
  declare property MinWavInVolume  as integer
  declare property MaxWavInVolume  as integer
  declare property MinLineInVolume as integer
  declare property MaxLineInVolume as integer
  declare property MinCDVolume     as integer
  declare property MaxCDVolume     as integer
  declare property MinMidVolume    as integer
  declare property MaxMidVolume    as integer
  declare property WaveVolume      as integer
  declare property MicroVolume     as integer
  declare property WaveInVolume    as integer
  declare property LineInVolume    as integer
  declare property CD_Volume       as integer
  declare property MIDIVolume      as integer
  declare property WaveMute        as integer
  declare property MicroMute       as integer
  declare property WaveInMute      as integer
  declare property LineInMute      as integer
  declare property CD_Mute         as integer
  declare property MIDIMute        as integer
  declare property WaveVolume  (ByVal NewVolume as integer)
  declare property MicroVolume (ByVal NewVolume as integer)
  declare property WaveInVolume(ByVal NewVolume as integer)
  declare property LineInVolume(ByVal NewVolume as integer)
  declare property CD_Volume   (ByVal NewVolume as integer)
  declare property MIDIVolume  (ByVal NewVolume as integer)
  declare property WaveMute    (ByVal NewValue as integer)
  declare property MicroMute   (ByVal NewValue as integer)
  declare property WaveInMute  (ByVal NewValue as integer)
  declare property LineInMute  (ByVal NewValue as integer)
  declare property CD_Mute     (ByVal NewValue as integer)
  declare property MIDIMute    (ByVal NewValue as integer)

  private:
  declare Function IsCtrl(ByVal Index as integer) As integer
  declare Function IsMute(ByVal Index as integer) As integer
  declare sub Prepare_mxcd
  declare function GetMixerControl(ByVal hMixer as integer, _
                                   ByVal componentType as integer, _
                                   byref mxc   As MIXERCONTROL, _
                                   ByVal cType as integer) As integer
  declare function SetValue(byref mxctl  As MIXERCONTROL, _
                            ByVal volume as integer) As integer
  declare function GetValue(byref mxctl As MIXERCONTROL) as integer

  as Integer hMixer
  volCtrl As MIXERCONTROL
  micCtrl As MIXERCONTROL
  wavCtrl As MIXERCONTROL
  linCtrl As MIXERCONTROL
  cd_Ctrl As MIXERCONTROL
  midCtrl As MIXERCONTROL
  auxCtrl As MIXERCONTROL

  volMute As MIXERCONTROL
  micMute As MIXERCONTROL
  wavMute As MIXERCONTROL
  linMute As MIXERCONTROL
  cdrMute As MIXERCONTROL
  midMute As MIXERCONTROL
  auxMute As MIXERCONTROL

  as integer MinVolVol, MaxVolVol
  as integer MinMicVol, MaxMicVol
  as integer MinWavVol, MaxWavVol
  as integer MinLinVol, MaxLinVol
  as integer MinCD_Vol, MaxCD_Vol
  as integer MinMidVol, MaxMidVol
  as integer MinAuxVol, MaxAuxVol

  mLine             As MIXERLINE
  mLineControls     As MIXERLINECONTROLS
  mControldetails   As MIXERCONTROLDETAILS
  mControldetails_u As MIXERCONTROLDETAILS_UNSIGNED

  as integer bOK
  as integer rc
  as integer CtrlState
  as integer MuteState
end type

property MIXER_CLASS.MinWaveVolume as integer
  return MinVolVol
End Property

property MIXER_CLASS.MaxWaveVolume as integer
  return MaxVolVol
End Property

property MIXER_CLASS.MinMicVolume as integer
  return MinMicVol
End Property

property MIXER_CLASS.MaxMicVolume as integer
  return MaxMicVol
End Property

property MIXER_CLASS.MinWavInVolume as integer
  return MinWavVol
End Property

property MIXER_CLASS.MaxWavInVolume as integer
  return MaxWavVol
End Property

property MIXER_CLASS.MinLineInVolume as integer
  return MinLinVol
End Property

property MIXER_CLASS.MaxLineInVolume as integer
  return MaxLinVol
End Property

property MIXER_CLASS.MinCDVolume as integer
  return MinCD_Vol
End Property

property MIXER_CLASS.MaxCDVolume as integer
  return MaxCD_Vol
End Property

property MIXER_CLASS.MinMidVolume as integer
  return MinMidVol
End Property

property MIXER_CLASS.MaxMidVolume as integer
  return MaxMidVol
End Property

property MIXER_CLASS.WaveVolume as integer
  return GetValue(volCtrl)
End Property

property MIXER_CLASS.MicroVolume as integer
  return GetValue(micCtrl)
End Property

property MIXER_CLASS.WaveInVolume as integer
  return GetValue(wavCtrl)
End Property

property MIXER_CLASS.LineInVolume as integer
  return GetValue(linCtrl)
End Property

property MIXER_CLASS.CD_Volume as integer
  return GetValue(cd_Ctrl)
End Property

property MIXER_CLASS.MIDIVolume as integer
  return GetValue(midCtrl)
End Property

property MIXER_CLASS.WaveMute as integer
  return GetValue(volMute)
End Property

property MIXER_CLASS.MicroMute as integer
  return GetValue(micMute)
End Property

property MIXER_CLASS.WaveInMute as integer
  return GetValue(wavMute)
End Property

property MIXER_CLASS.LineInMute as integer
  return GetValue(linMute)
End Property

property MIXER_CLASS.CD_Mute as integer
  return GetValue(cdrMute)
End Property

property MIXER_CLASS.MIDIMute as integer
  return GetValue(midMute)
End Property

property MIXER_CLASS.WaveVolume(ByVal NewVolume as integer)
  If NewVolume < MinVolVol Then NewVolume = MinVolVol
  If NewVolume > MaxVolVol Then NewVolume = MaxVolVol
  SetValue(volCtrl, NewVolume)
End Property

property MIXER_CLASS.MicroVolume(ByVal NewVolume as integer)
  If NewVolume < MinMicVol Then NewVolume = MinMicVol
  If NewVolume > MaxMicVol Then NewVolume = MaxMicVol
  SetValue(micCtrl, NewVolume)
End Property

property MIXER_CLASS.WaveInVolume(ByVal NewVolume as integer)
  If NewVolume < MinWavVol Then NewVolume = MinWavVol
  If NewVolume > MaxWavVol Then NewVolume = MaxWavVol
  SetValue(wavCtrl, NewVolume)
End Property

property MIXER_CLASS.LineInVolume(ByVal NewVolume as integer)
  If NewVolume < MinLinVol Then NewVolume = MinLinVol
  If NewVolume > MaxLinVol Then NewVolume = MaxLinVol
  SetValue(linCtrl, NewVolume)
End Property

property MIXER_CLASS.CD_Volume(ByVal NewVolume as integer)
  If NewVolume < MinCD_Vol Then NewVolume = MinCD_Vol
  If NewVolume > MaxCD_Vol Then NewVolume = MaxCD_Vol
  SetValue(cd_Ctrl, NewVolume)
End Property

property MIXER_CLASS.MIDIVolume(ByVal NewVolume as integer)
  If NewVolume < MinMidVol Then NewVolume = MinMidVol
  If NewVolume > MaxMidVol Then NewVolume = MaxMidVol
  SetValue(midCtrl, NewVolume)
End Property

property MIXER_CLASS.WaveMute(ByVal NewValue as integer)
  SetValue(volMute, NewValue)
End Property

property MIXER_CLASS.MicroMute(ByVal NewValue as integer)
  SetValue(micMute, NewValue)
End Property

property MIXER_CLASS.WaveInMute(ByVal NewValue as integer)
  SetValue(wavMute, NewValue)
End Property

property MIXER_CLASS.LineInMute(ByVal NewValue as integer)
  SetValue(linMute, NewValue)
End Property

property MIXER_CLASS.CD_Mute(ByVal NewValue as integer)
  SetValue(cdrMute, NewValue)
End Property

property MIXER_CLASS.MIDIMute(ByVal NewValue as integer)
  SetValue(midMute, NewValue)
End Property

Function MIXER_CLASS.IsCtrl(ByVal Index as integer) As integer
  IsCtrl = CtrlState And Index
End Function

Function MIXER_CLASS.IsMute(ByVal Index as integer) As integer
  IsMute = MuteState And Index
End Function

constructor MIXER_CLASS
  rc = mixerOpen(@hMixer, 0, 0, 0, 0)
  If rc <> MMSYSERR_NOERROR Then
    guinotice "error: mixerOpen!"
    beep:sleep
    return
  End If

  bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_DST_SPEAKERS, volCtrl, 1)
  If bOK Then
    CtrlState = CtrlState Or 1
    With volCtrl
      MinVolVol = .lMinimum
      MaxVolVol = .lMaximum
    End With
    bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_DST_SPEAKERS, volMute, 2)
    If bOK Then MuteState = MuteState Or 1
  End If

  bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE, micCtrl, 1)
  If bOK Then
    CtrlState = CtrlState Or 2
    With micCtrl
      MinMicVol = .lMinimum
      MaxMicVol = .lMaximum
    End With

    If bOK Then MuteState = MuteState Or 2
  End If

  bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT, wavCtrl, 1)
  If bOK Then
    CtrlState = CtrlState Or 4
    With wavCtrl
      MinWavVol = .lMinimum
      MaxWavVol = .lMaximum
    End With
    bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT, wavMute, 2)
    If bOK Then MuteState = MuteState Or 4
  End If

  bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_LINE, linCtrl, 1)
  If bOK Then
    CtrlState = CtrlState Or 8
    With linCtrl
      MinLinVol = .lMinimum
      MaxLinVol = .lMaximum
    End With

    bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_LINE, linMute, 2)
    If bOK Then MuteState = MuteState Or 8
  Else
    bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY, linCtrl, 1)
    If bOK Then
      CtrlState = CtrlState Or 8
      With linCtrl
        MinLinVol = .lMinimum
        MaxLinVol = .lMaximum
      End With
     
      bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY, linMute, 2)
      If bOK Then MuteState = MuteState Or 8
    End If
  End If

  bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC, cd_Ctrl, 1)
  If bOK Then
    CtrlState = CtrlState Or 16
    With cd_Ctrl
      MinCD_Vol = .lMinimum
      MaxCD_Vol = .lMaximum
    End With
    bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC, cdrMute, 2)
    If bOK Then MuteState = MuteState Or 16
  End If

  bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER, midCtrl, 1)
  If bOK Then
    CtrlState = CtrlState Or 32
    With midCtrl
      MinMidVol = .lMinimum
      MaxMidVol = .lMaximum
    End With
    bOK = GetMixerControl(hMixer, MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER, midMute, 2)
    If bOK Then MuteState = MuteState Or 32
  End If
End constructor

Function MIXER_CLASS.GetMixerControl( _
  ByVal hMixer        as Integer, _
  ByVal componentType as integer, _
  byref mxc           As MIXERCONTROL, _
  ByVal cType         as integer) As integer
  Dim as integer ctrlType, infoType
 
  Select Case cType
    Case 1
      ctrlType = MIXERCONTROL_CONTROLTYPE_VOLUME
      infoType = MIXER_GETLINEINFOF_COMPONENTTYPE
    Case 2
      ctrlType = MIXERCONTROL_CONTROLTYPE_MUTE
      infoType = MIXER_GETLINEINFOF_LINEID
    Case Else
      return 0
  End Select

  mLine.cbStruct = sizeof(MIXERLINE)
  mLine.dwComponentType = componentType
  rc = mixerGetLineInfo(hMixer,@mLine,infoType)

  If (MMSYSERR_NOERROR = rc) Then
    With mLineControls
      .cbStruct    = sizeof(MIXERLINECONTROLS)
      .dwLineID    = mLine.dwLineID
      .dwControl   = ctrlType
      .cControls   = 1
      .cbmxctrl    = sizeof(MIXERCONTROL)
      .pamxctrl    = @mxc
    End With
    rc = mixerGetLineControls(hMixer,@mLineControls, MIXER_GETLINECONTROLSF_ONEBYTYPE)
    If (MMSYSERR_NOERROR = rc) Then
      GetMixerControl = -1
    end if
  else
    ? "error: GetLineInfo " & rc
  End If
End Function

Function MIXER_CLASS.SetValue(byref mxctl  As MIXERCONTROL, _
                              ByVal volume as integer) As integer
  With mControldetails
    .item = 0
    .dwControlID = mxctl.dwControlID
    .cbStruct    = sizeof(MIXERCONTROLDETAILS)
    .cbDetails   = sizeof(MIXERCONTROLDETAILS_UNSIGNED)
    .paDetails   = @mControldetails_u
    .cChannels   = 1
  End With
  mControldetails_u.dwValue = volume
'declare function mixerSetControlDetails(byval hmxobj as HMIXEROBJ, byval pmxcd as LPMIXERCONTROLDETAILS, byval fdwDetails as DWORD) as MMRESULT
  rc = mixerSetControlDetails(hMixer, @mControldetails, MIXER_SETCONTROLDETAILSF_VALUE)
  If (rc = MMSYSERR_NOERROR) Then return -1
End Function

Function MIXER_CLASS.GetValue(byref mxctl As MIXERCONTROL) as integer
  mControldetails_u.dwValue = 0
  With mControldetails
    .item = 0
    .dwControlID = mxctl.dwControlID
    .cbStruct    = sizeof(MIXERCONTROLDETAILS)
    .cbDetails   = sizeof(MIXERCONTROLDETAILS_UNSIGNED)
    .paDetails   = @mControldetails_u
    .cChannels   = 1
  End With
  rc = mixerGetControlDetails(hMixer, @mControldetails, MIXER_GETCONTROLDETAILSF_VALUE)
  If (rc = MMSYSERR_NOERROR) Then
    GetValue = mControldetails_u.dwValue '# Current value
  Else
    GetValue = 0
  End If
End Function


destructor MIXER_CLASS
  if hMixer then mixerClose hMixer
End destructor

'
' main
'
dim as MIXER_CLASS mixer
'guinotice "min:" & mixer.MinWaveVolume
'guinotice "max:" & mixer.MaxWaveVolume
'guinotice "curent volume:" & mixer.WaveVolume
'mixer.WaveVolume=mixer.MaxWaveVolume\2
'guinotice "now    volume:" & mixer.WaveVolume

guinotice "min:" & mixer.MinWavinVolume
guinotice "max:" & mixer.MaxWavinVolume
guinotice "curent volume:" & mixer.WaveinVolume
mixer.WaveinVolume=mixer.MaxWavinVolume\4
guinotice "now    volume:" & mixer.WaveinVolume
'/
'Sleep 10000


