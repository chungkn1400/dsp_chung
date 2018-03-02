    '  #################
    ' # waveout_DEVICE #
    '#################

    type waveout_DEVICE
      Declare Sub wstart(DeviceIndex as integer=-1) ' default = WAVE_MAPPER
      Declare Sub wclose()
      as short ptr pSamples
      as integer   nSamples,nplayedBuffers

      'private:
      declare static sub waveoutProc(hDevice   as Hwaveout, _
                                    DriverMsg as uinteger, _
                                    pDevice   as waveout_DEVICE ptr, _
                                    pBuffer   as PWAVEHDR, _
                                    Param2    as DWORD)
      declare sub unPrepareBuffer(pBuffer as PWAVEHDR)
      as WAVEFORMATEX     wfex
      as waveoutCAPS       Caps
      as Hwaveout          hDevice
      as MMRESULT         LastResult
      as PWAVEHDR ptr     Buffers
      as integer          IsOpen,IsRunning
      as integer          nBuffers,nSamplesPerbuffer,ibuffer
      As Integer          bufferbusy(nbuffer)
    end type

Dim Shared As waveoutcaps mywaveoutcaps
Dim Shared As Integer numdevout,idevout,mydevout=-1
numdevout=waveoutGetNumDevs()

dim Shared As String mynameout(30)
Dim Shared As Integer mychannelouts(30)
If numdevout>30 Then numdevout=30
for idevout=-1 to numdevout-1
  waveoutGetDevCaps(idevout,@mywaveoutcaps,sizeof(waveoutCAPS))
  mynameout(idevout+1)=mywaveoutcaps.szPname
  mychannelouts(idevout+1)=mywaveoutcaps.wChannels
next idevout

    ' setup 44100 16 bit 2 channels
    Sub waveout_DEVICE.wstart(DeviceIndex as Integer=-1)
      errtext=("waveout_DEVICE()")
      nBuffers=nbuffer
      nSamplesPerBuffer = 2048
      LastResult = waveoutGetDevCaps(DeviceIndex, _
                                    @Caps, _
                                    sizeof(waveoutCAPS))
      if (LastResult=MMSYSERR_NOERROR) then

        with wfex
        .wFormatTag      = WAVE_FORMAT_PCM
        .nSamplesPerSec  = samplerate
        .nChannels       = nchannel
        .wBitsPerSample  = 16
        .nBlockAlign     = (.wBitsPerSample shr 3) * .nChannels
        .nAvgBytesPerSec = .nBlockAlign * .nSamplesPerSec
        .cbSize          = 0 ' no extra bytes
        end with
        LastResult = waveoutOpen(@hDevice, _
                                DeviceIndex, _
                                cptr(LPCWAVEFORMATEX,@wfex), _
                                cast(uinteger,@waveoutProc), _
                                cast(uinteger,@this), _
                                CALLBACK_FUNCTION)
     
        ' prepare buffers
        if IsOpen then
          dim as integer size = wfex.nBlockAlign
          size*=nSamplesPerBuffer
          pSamples=new short[size]
          nSamples=0
          Buffers=callocate(nBuffers*sizeof(PWAVEHDR))
          for i as integer =0 to nBuffers-1
            Buffers[i] = callocate(sizeof(WAVEHDR))
            with *Buffers[i]
              .lpData         = callocate(size)
              .dwBufferLength = size
              .dwUser         = i
              .dwFlags        = 0
            end With
            bufferbusy(i)=0
            LastResult = waveoutPrepareHeader(hDevice   , _
                                             Buffers[i], _
                                             sizeof(WAVEHDR))
         
          next
          IsRunning=(LastResult=MMSYSERR_NOERROR)
        end if
      end if
    end Sub 

    ' stop the device and free all resources
    Sub waveout_DEVICE.wclose()
      if (hDevice<>NULL) then
        if (IsOpen<>0) then
          isrunning=0
          guiscan
          Sleep 500
          LastResult = waveoutReset(hDevice) ' mark all buffer as done
          errtext=("waveoutReset()=" & LastResult)
          guiscan
          Sleep 100
          if (Buffers<>NULL) then
            if (nBuffers>0) then
              for i as integer = 0 to nBuffers-1
                if (Buffers[i]<>NULL) then
                  'if (Buffers[i]->dwFlags and WHDR_PREPARED) then
                    LastResult = waveoutUnprepareHeader(hDevice,Buffers[i],sizeof(WAVEHDR))
                    errtext=("waveoutUnprepareHeader(" & i & ")=" & LastResult)
                  'end if
                  if Buffers[i]->lpData then deallocate Buffers[i]->lpData
                  deallocate Buffers[i]
                end if
              next
            end if
            deallocate Buffers
          end if
          errtext=("waveout_DEVICE~ waveoutClose")
          dim as integer count=100
          LastResult = waveoutClose(hDevice)
          errtext=("waveoutClose()=" & LastResult)
          while (LastResult = WAVERR_STILLPLAYING) andalso (count>0)
            sleep 50:count-=1
            LastResult = waveoutClose(hDevice)
          wend
        end if
      end if
      if pSamples<>NULL then delete pSamples
      errtext=("waveout_DEVICE~")
    end Sub 

    ' the audio in callback
    sub waveout_DEVICE.waveoutProc(hDevice   as Hwaveout          , _
                                 DriverMsg as uinteger         , _
                                 pDevice   as waveout_DEVICE ptr, _
                                 pBuffer   as PWAVEHDR         , _
                                 Param2    as DWORD)
      if (pDevice=NULL) then return
     
      select case as const DriverMsg
      	case WoM_Done
          pDevice->unPrepareBuffer(pBuffer)
          pDevice->nplayedBuffers+=1

      	case WoM_OPEN : errtext=("WoM_OPEN")
        pDevice->IsOpen = 1
      	case WoM_CLOSE : errtext=("WoM_CLOSE")
        pDevice->IsOpen = 0
      end select
    end sub

    ' new buffer are active
    sub waveout_DEVICE.unPrepareBuffer(pBuffer as PWAVEHDR)
    	Dim As Integer i
      lastResult=waveoutUnprepareHeader(hDevice,pBuffer,sizeof(WAVEHDR))

      if (LastResult<>MMSYSERR_NOERROR) then
        IsRunning=0
        'errtext=("waveoutStop()=" & str(waveoutStop(hDevice)))
        'errtext=("waveoutReset()=" & str(waveoutReset(hDevice)))
        dim as string sError=space(256)
        waveoutGetErrorText(LastResult,strptr(sError),256)
        errtext=("error: " & sError)
      end If
      
      For i=0 To nbuffers-1
      	If buffers[i]=pbuffer Then
      		bufferbusy(i)=0
      		Exit For 
      	EndIf
      Next
    end sub



