    '  #################
    ' # waveout_DEVICE #
    '#################
    type waveout_DEVICE
      Declare Sub wstart(DeviceIndex as integer=-1) ' default = WAVE_MAPPER
      Declare Sub wclose()
      as short ptr pSamples
      as integer   nSamples,nRecordedBuffers

      private:
      declare static sub waveoutProc(hDevice   as Hwaveout, _
                                    DriverMsg as uinteger, _
                                    pDevice   as waveout_DEVICE ptr, _
                                    pBuffer   as PWAVEHDR, _
                                    Param2    as DWORD)
      declare sub PrepareBuffer(pBuffer as PWAVEHDR)
      as WAVEFORMATEX     wfex
      as waveoutCAPS       Caps
      as Hwaveout          hDevice
      as MMRESULT         LastResult
      as PWAVEHDR ptr     Buffers
      as integer          IsOpen,IsRunning
      as integer          nBuffers,nSamplesPerbuffer
    end type

Dim Shared As waveoutcaps mywaveoutcaps
Dim Shared As Integer numdev,idev,mydev=-1
numdev=waveoutGetNumDevs()

dim Shared As String myname(30)
Dim Shared As Integer mychannels(30)
If numdev>30 Then numdev=30
for idev=-1 to numdev-1
  waveoutGetDevCaps(idev,@mywaveoutcaps,sizeof(waveoutCAPS))
  myname(idev+1)=mywaveoutcaps.szPname
  mychannels(idev+1)=mywaveoutcaps.wChannels
next idev

    ' setup 44100 16 bit 2 channels
    Sub waveout_DEVICE.wstart(DeviceIndex as Integer=-1)
      dprint("waveout_DEVICE()")
      nBuffers=8
      nSamplesPerBuffer = 1024
      LastResult = waveoutGetDevCaps(DeviceIndex, _
                                    @Caps, _
                                    sizeof(waveoutCAPS))
      if (LastResult=MMSYSERR_NOERROR) then

        with wfex
        .wFormatTag      = WAVE_FORMAT_PCM
        .nSamplesPerSec  = 44100
        .nChannels       = 2
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
            end with
            LastResult = waveoutPrepareHeader(hDevice   , _
                                             Buffers[i], _
                                             sizeof(WAVEHDR))
         
          next
          for i as integer=0 to nBuffers-1
            LastResult = waveoutAddBuffer(hDevice,Buffers[i],sizeof(WAVEHDR))
          next
          LastResult = waveoutStart(hDevice)
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
          dprint("waveoutReset()=" & LastResult)
          LastResult = waveoutStop(hDevice)
          dprint("waveoutStop()=" & LastResult)
          guiscan
          Sleep 100
          if (Buffers<>NULL) then
            if (nBuffers>0) then
              for i as integer = 0 to nBuffers-1
                if (Buffers[i]<>NULL) then
                  'if (Buffers[i]->dwFlags and WHDR_PREPARED) then
                    LastResult = waveoutUnprepareHeader(hDevice,Buffers[i],sizeof(WAVEHDR))
                    dprint("waveoutUnprepareHeader(" & i & ")=" & LastResult)
                  'end if
                  if Buffers[i]->lpData then deallocate Buffers[i]->lpData
                  deallocate Buffers[i]
                end if
              next
            end if
            deallocate Buffers
          end if
          dprint("waveout_DEVICE~ waveoutClose")
          dim as integer count=100
          LastResult = waveoutClose(hDevice)
          dprint("waveoutClose()=" & LastResult)
          while (LastResult = WAVERR_STILLPLAYING) andalso (count>0)
            sleep 50:count-=1
            LastResult = waveoutClose(hDevice)
          wend
        end if
      end if
      if pSamples<>NULL then delete pSamples
      dprint("waveout_DEVICE~")
    end Sub 

    ' the audio in callback
    sub waveout_DEVICE.waveoutProc(hDevice   as Hwaveout          , _
                                 DriverMsg as uinteger         , _
                                 pDevice   as waveout_DEVICE ptr, _
                                 pBuffer   as PWAVEHDR         , _
                                 Param2    as DWORD)
      if (pDevice=NULL) then return
     
      select case as const DriverMsg
      case WIM_DATA
        if (pDevice->IsRunning<>0) then
          pDevice->PrepareBuffer(pBuffer)
          pDevice->nRecordedBuffers+=1
        else
          DPRINT("WIM_DATA")
        end if
      case WIM_OPEN : dprint("WIM_OPEN")
        pDevice->IsOpen = 1
      case WIM_CLOSE : dprint("WIM_CLOSE")
        pDevice->IsOpen = 0
      end select
    end sub

Dim Shared As Integer isampleout,nsampleout=200000 '10sec
Dim Shared As Short   mysampleouts(nsampleout)
Dim Shared As Short Ptr mypsampleouts
Dim Shared As Integer mynsampleouts
Declare Sub mysubsampleout()
    ' new buffer are recorded
    sub waveout_DEVICE.PrepareBuffer(pBuffer as PWAVEHDR)
      lastResult=waveoutUnprepareHeader(hDevice,pBuffer,sizeof(WAVEHDR))
      ' new samples aviable ?
      if pBuffer->dwBytesRecorded>0 then
        ' pointer to the 16 bit stereo samples
        dim as short ptr pNewSamples  = cptr(short ptr,pBuffer->lpData)
        nSamples = pBuffer->dwBytesRecorded\wfex.nBlockAlign
        RtlCopyMemory(pSamples,pNewSamples,pBuffer->dwBytesRecorded)
        dprint("new samples available")
        ' !!! now psampleouts points to your fresh recorded audio data !!!
        mynsampleouts=nsamples
        mypsampleouts=psamples
        mysubsampleout()
        ' !!! save it to the disc or plot it as bar or what ever    !!!
      end if
      ' prepare and add the last buffer
      if (IsRunning<>0) then
        pBuffer->dwFlags = 0
        pBuffer->dwBytesRecorded = 0
        lastResult=waveoutPrepareHeader(hDevice,pBuffer,sizeof(WAVEHDR))
        if (LastResult=MMSYSERR_NOERROR) then
           lastResult = waveoutAddBuffer(hDevice,pBuffer,sizeof(WAVEHDR))
           'dprint("waveoutAddBuffer()=" & str(lastResult))
        end if
      end if

      if (LastResult<>MMSYSERR_NOERROR) then
        IsRunning=0
        'dprint("waveoutStop()=" & str(waveoutStop(hDevice)))
        'dprint("waveoutReset()=" & str(waveoutReset(hDevice)))
        dim as string sError=space(256)
        waveoutGetErrorText(LastResult,strptr(sError),256)
        dprint("error: " & sError)
      end if
    end sub


