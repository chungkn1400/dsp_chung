    '  #################
    ' # WAVEIN_DEVICE #
    '#################
    Dim Shared As Integer samplerate=44100
    Const As Integer nbuffer=12,nchannel=2
    Dim Shared As Integer buffersize=200*nchannel
    Dim Shared As String errtext,msg
    Const As String crlf=Chr(13)+Chr(10)
    
    type WAVEIN_DEVICE
      Declare Sub wstart(DeviceIndex as integer=-1) ' default = WAVE_MAPPER
      Declare Sub wclose()
      as short ptr pSamples
      as integer   nSamples,nRecordedBuffers

      private:
      declare static sub WaveInProc(hDevice   as HWAVEIN, _
                                    DriverMsg as uinteger, _
                                    pDevice   as WAVEIN_DEVICE ptr, _
                                    pBuffer   as PWAVEHDR, _
                                    Param2    as DWORD)
      declare sub PrepareBuffer(pBuffer as PWAVEHDR)
      as WAVEFORMATEX     wfex
      as WAVEINCAPS       Caps
      as HWAVEIN          hDevice
      as MMRESULT         LastResult
      as PWAVEHDR ptr     Buffers
      as integer          IsOpen,IsRunning
      as integer          nBuffers,nSamplesPerbuffer
    end type

Dim Shared As waveincaps mywaveincaps
Dim Shared As Integer numdev,idev,mydev=-1
numdev=waveInGetNumDevs()

dim Shared As String myname(30)
Dim Shared As Integer mychannels(30)
If numdev>30 Then numdev=30
for idev=-1 to numdev-1
  waveInGetDevCaps(idev,@mywaveincaps,sizeof(WAVEINCAPS))
  myname(idev+1)=mywaveincaps.szPname
  mychannels(idev+1)=mywaveincaps.wChannels
next idev

    ' setup 44100 16 bit 2 channels
    Sub WAVEIN_DEVICE.wstart(DeviceIndex as Integer=-1)
      errtext=("WAVEIN_DEVICE()")
      nBuffers=nbuffer
      nSamplesPerBuffer = buffersize
      LastResult = waveInGetDevCaps(DeviceIndex, _
                                    @Caps, _
                                    sizeof(WAVEINCAPS))
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
        LastResult = waveInOpen(@hDevice, _
                                DeviceIndex, _
                                cptr(LPCWAVEFORMATEX,@wfex), _
                                cast(uinteger,@WaveInProc), _
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
            end with
            LastResult = waveInPrepareHeader(hDevice   , _
                                             Buffers[i], _
                                             sizeof(WAVEHDR))
         
          next
          for i as integer=0 to nBuffers-1
            LastResult = waveInAddBuffer(hDevice,Buffers[i],sizeof(WAVEHDR))
          next
          LastResult = waveInStart(hDevice)
          IsRunning=(LastResult=MMSYSERR_NOERROR)
        end if
      end if
    end Sub 

    ' stop the device and free all resources
    Sub WAVEIN_DEVICE.wclose()
      if (hDevice<>NULL) then
        if (IsOpen<>0) then
          isrunning=0
          guiscan
          Sleep 500
          LastResult = waveInReset(hDevice) ' mark all buffer as done
          errtext=("waveInReset()=" & LastResult)
          LastResult = waveInStop(hDevice)
          errtext=("waveInStop()=" & LastResult)
          guiscan
          Sleep 100
          if (Buffers<>NULL) then
            if (nBuffers>0) then
              for i as integer = 0 to nBuffers-1
                if (Buffers[i]<>NULL) then
                  'if (Buffers[i]->dwFlags and WHDR_PREPARED) then
                    LastResult = waveInUnprepareHeader(hDevice,Buffers[i],sizeof(WAVEHDR))
                    errtext=("waveInUnprepareHeader(" & i & ")=" & LastResult)
                  'end if
                  if Buffers[i]->lpData then deallocate Buffers[i]->lpData
                  deallocate Buffers[i]
                end if
              next
            end if
            deallocate Buffers
          end if
          errtext=("WAVEIN_DEVICE~ waveInClose")
          dim as integer count=100
          LastResult = waveInClose(hDevice)
          errtext=("waveInClose()=" & LastResult)
          while (LastResult = WAVERR_STILLPLAYING) andalso (count>0)
            sleep 50:count-=1
            LastResult = waveInClose(hDevice)
          wend
        end if
      end if
      if pSamples<>NULL then delete pSamples
      errtext=("WAVEIN_DEVICE~")
    end Sub 

    ' the audio in callback
    sub WAVEIN_DEVICE.WaveInProc(hDevice   as HWAVEIN          , _
                                 DriverMsg as uinteger         , _
                                 pDevice   as WAVEIN_DEVICE ptr, _
                                 pBuffer   as PWAVEHDR         , _
                                 Param2    as DWORD)
      if (pDevice=NULL) then return
     
      select case as const DriverMsg
      case WIM_DATA
        if (pDevice->IsRunning<>0) then
          pDevice->PrepareBuffer(pBuffer)
          pDevice->nRecordedBuffers+=1
        else
          errtext=("WIM_DATA")
        end if
      	case WIM_OPEN : errtext=("WIM_OPEN")
        pDevice->IsOpen = 1
      	case WIM_CLOSE : errtext=("WIM_CLOSE")
        pDevice->IsOpen = 0
      end select
    end sub

'Dim Shared As Integer isample,nsample=200000 '3sec
'Dim Shared As Short   mysamples(nsample)
Dim Shared As Short Ptr mypsamples
Dim Shared As Integer mynsamples
Declare Sub mysubsample()
    ' new buffer are recorded
    sub WAVEIN_DEVICE.PrepareBuffer(pBuffer as PWAVEHDR)
      lastResult=waveInUnprepareHeader(hDevice,pBuffer,sizeof(WAVEHDR))
      ' new samples aviable ?
      if pBuffer->dwBytesRecorded>0 then
        ' pointer to the 16 bit stereo samples
        dim as short ptr pNewSamples  = cptr(short ptr,pBuffer->lpData)
        nSamples = pBuffer->dwBytesRecorded\wfex.nBlockAlign
        RtlCopyMemory(pSamples,pNewSamples,pBuffer->dwBytesRecorded)
        errtext="wavein ok"'("new samples available")
        ' !!! now pSamples points to your fresh recorded audio data !!!
        mynsamples=nsamples*nchannel
        mypsamples=psamples
        mysubsample()
        ' !!! save it to the disc or plot it as bar or what ever    !!!
      end if
      ' prepare and add the last buffer
      if (IsRunning<>0) then
        pBuffer->dwFlags = 0
        pBuffer->dwBytesRecorded = 0
        lastResult=waveInPrepareHeader(hDevice,pBuffer,sizeof(WAVEHDR))
        if (LastResult=MMSYSERR_NOERROR) then
           lastResult = waveInAddBuffer(hDevice,pBuffer,sizeof(WAVEHDR))
           'errtext=("waveInAddBuffer()=" & str(lastResult))
        end if
      end if

      if (LastResult<>MMSYSERR_NOERROR) then
        IsRunning=0
        'errtext=("waveInStop()=" & str(waveInStop(hDevice)))
        'errtext=("waveInReset()=" & str(waveInReset(hDevice)))
        dim as string sError=space(256)
        waveInGetErrorText(LastResult,strptr(sError),256)
        errtext=("error: " & sError)
      end if
    end sub

