
			section	code,code



			;------------------------------------------------------------
			; _NewMP3
			;------------------------------------------------------------
			;
			; Input:
			;	a0 = Filename
			; Result:
			;	d0 = FALSE if failed

_NewMP3			movem.l	d0-d1/d3/a0-a2/a6,-(sp)
			movea.l	a0,a2							; a2 = filename
			
			; Avoid self-copy if already in vmp_CurrentSongPath
			cmpa.l	#vmp_CurrentSongPath,a0
			beq.s	.skipCopy

			; Copy filename to vmp_CurrentSongPath so _SeekMP3 can safely reopen it (max 511 chars)
			lea	vmp_CurrentSongPath(a5),a1
			move.w	#511,d1
.copyPath	move.b	(a0)+,d0
			beq.s	.nullPath
			move.b	d0,(a1)+
			subq.w	#1,d1
			bne.s	.copyPath
.nullPath	clr.b	(a1)
			
.skipCopy	bsr	_CloseMP3
			movea.l	vmp_MPEGABase(a5),a6
			lea	vmp_CurrentSongPath(a5),a0			; Filename pointer in a0 for MPEGA_Open
			lea     MP3_Ctrl,a1
			LVO	MPEGA_Open
			tst.l   d0
			bne.s	.mp3Opened
			moveq	#VMP_STATUS_OPENERROR,d0
			bsr	_SetStatus
			moveq	#0,d0								; return FALSE
			bra.w	.done

.mp3Opened		move.l	d0,vmp_MP3_Stream(a5)
			movea.l	d0,a0							; a0 = stream pointer
			
			; 1. Reset decoded samples, slider grabbed, UI update state, and EOF pending
			move.l	#0,vmp_DecodedSamples(a5)
			move.l	#0,vmp_SliderGrabbed(a5)
			move.l	#0,vmp_EOF_Pending(a5)
			move.l	#-1,vmp_LastTimeSecs(a5)
			move.l	#-1,vmp_LastSliderVal(a5)
			
			; 2. Read and store duration
			move.l	mp3_ms_duration(a0),d0
			move.l	d0,vmp_SongDuration(a5)
			
			; 3. Read and store sample rate
			move.l	mp3_dec_frequency(a0),d1
			move.l	d1,vmp_SongSampleRate(a5)
			

			
			; 5. Extract and display centered Song Name
			lea	vmp_NameBuffer,a1

			movea.l	a2,a0
			bsr	_GetFileNamePart					; a0 = clean filename
.copyName		move.b	(a0)+,(a1)+
			bne.s	.copyName
			
			; Remove null terminator copied by .copyName
			subq.l	#1,a1
			move.b	#0,(a1)								; Null-terminate
			
			; Update Song Name UI Text
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwTextSongName(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_NameBuffer, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Update song name in Compact window
			movea.l	vmp_MUI_CompactWdwLabel(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_NameBuffer, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Stop any playing audio
			moveq	#VMP_AUDIO_CHANNEL,d0
			bsr	_StopAudio
    
			; Resulting audio buffer size calculation
			movea.l	vmp_MP3_Stream(a5),a0
			move.l	mp3_ms_duration(a0),d0
    
			divu.l	#10,d0
			mulu.l	#1764,d0
			move.l	d0,vmp_PCM_AudioSize(a5)

			; Clear both buffers (256KB total) to prevent old audio from playing
			lea	vmp_PCM_PlayBuffer1,a0
			load	#0,d1
			move.l	#32768-1,d0
.clearBufs		store	d1,(a0)+
			dbf.l	d0,.clearBufs

			; 1. Decode Buffer A (0)
			move.l	#4,vmp_PCM_ActiveBuffer(a5)				; Fake Active=4 so _DecodeFrames fills 0
			move.l	#28,vmp_FramesToDecode(a5)
			lea	vmp_PCM_PlayBufferArray,a0
			move.l	(a0),vmp_PCM_DecodePointer(a5)
.initLoop1		bsr	_DecodeFrames
			tst.l	vmp_FramesToDecode(a5)
			bne.s	.initLoop1
			
			; 2. Decode Buffer B (4)
			move.l	#0,vmp_PCM_ActiveBuffer(a5)				; Active=0 so _DecodeFrames fills 4
			move.l	#28,vmp_FramesToDecode(a5)
			lea	vmp_PCM_PlayBufferArray,a0
			move.l	4(a0),vmp_PCM_DecodePointer(a5)
.initLoop2		bsr	_DecodeFrames
			tst.l	vmp_FramesToDecode(a5)
			bne.s	.initLoop2
			
			; Always program Paula hardware registers with Buffer A
			move.l	#0,vmp_PCM_ActiveBuffer(a5)
			bsr	_PlayMP3

			; Immediately queue Buffer B into hardware registers
			moveq	#4,d2
			bsr	_QueueBuffer

			; Clear any interrupt signal generated when DMA was enabled
			move.w	#$0400,INTREQ
			tst.w	INTREQR
			movea.l	4.w,a6
			moveq	#0,d0
			move.l	vmp_InterruptMask(a5),d1
			LVO	SetSignal
			
			move.l	vmp_InterruptMask(a5),d0
			not.l	d0
			and.l	d0,vmp_Signals
			
			tst.l	vmp_Autoloading(a5)
			bne.s	.setPausedState
			
			clr.l	vmp_Paused(a5)
			moveq	#VMP_STATUS_PLAYING,d0
			bsr	_SetStatus
			move.l	#1,vmp_Playing(a5)
			bra.s	.doneLoad
			
.setPausedState
			; For autoloading, stop DMA immediately so it stays silent
			moveq	#VMP_AUDIO_CHANNEL,d0
			bsr	_StopAudio

			moveq	#VMP_STATUS_PAUSED,d0
			bsr	_SetStatus
			move.l	#1,vmp_Playing(a5)
			move.l	#1,vmp_Paused(a5)
			move.l	#0,vmp_Autoloading(a5)			; Reset autoloading flag
			
.doneLoad
			

.done			move.l	d0,(sp)								; Overwrite d0 slot on stack with return value
			movem.l	(sp)+,d0-d1/d3/a0-a2/a6
			rts



			;------------------------------------------------------------
			; _CloseMP3
			;------------------------------------------------------------
			;

_CloseMP3		movem.l	a0/a6,-(sp)
			move.l	#0,vmp_Playing(a5)
			move.l	#0,vmp_EOF_Pending(a5)
			moveq	#VMP_AUDIO_CHANNEL,d0
			bsr	_StopAudio
			
			movea.l	vmp_MP3_Stream(a5),a0
			cmpa.l	#0,a0
			beq.s	.done
			
			movea.l	vmp_MPEGABase(a5),a6
			LVO	MPEGA_Close
			move.l	#0,vmp_MP3_Stream(a5)
			
.done			movem.l	(sp)+,a0/a6
			rts



			;------------------------------------------------------------
			; _PlayMP3
			;------------------------------------------------------------
			;

_PlayMP3		movem.l	d0-d2/a0-a1,-(sp)

			move.l	vmp_PCM_ActiveBuffer(a5),d2
			lea	vmp_PCM_PlayBufferArray,a0
			movea.l	(a0,d2.w),a0
			lea	vmp_PCM_LengthArray,a1
			move.l	(a1,d2.w),d0

			; Scale vmp_Volume(a5) from 0-100 to 0-255 for both channels
			move.l	vmp_Volume(a5),d2
			mulu	#255,d2
			divu	#100,d2
			move.b	d2,d1
			lsl	#8,d1
			move.b	d2,d1
			move.l	d1,d2					; d2 = left/right volume word

			moveq	#VMP_AUDIO_CHANNEL,d1	; Restore channel in d1
			bsr	_PlayAudio
			
			movem.l	(sp)+,d0-d2/a0-a1
			rts



			;------------------------------------------------------------
			; _PauseMP3
			;------------------------------------------------------------
			;

_PauseMP3		movem.l	d0,-(sp)
			tst.l	vmp_Playing(a5)
			beq.s	.exit							; ignore if audio is stopped

			move.l	#1,vmp_Paused(a5)
			moveq	#0,d0
			bset	#VMP_AUDIO_CHANNEL,d0
			move.w	d0,DMACON						; Stop audio on channel

.exit			movem.l	(sp)+,d0
			rts



			;------------------------------------------------------------
			; _ResumeMP3
			;------------------------------------------------------------
			;

_ResumeMP3		movem.l	d0,-(sp)
			tst.l	vmp_Playing(a5)
			beq.s	.exit							; ignore if audio is stopped

			move.l	#0,vmp_Paused(a5)
			move.l	#$8200,d0
			bset	#VMP_AUDIO_CHANNEL,d0
			move.w	d0,DMACON						; Stop audio on channel

.exit			movem.l	(sp)+,d0
			rts



			;------------------------------------------------------------
			; _DecodeMP3
			;------------------------------------------------------------
			;

_DecodeFrames		movem.l	d0-d3/a0-a3/a6,-(sp)

			move.l	vmp_FramesToDecode(a5),d2
			beq.w	.exit
			cmp.l	#VMP_FRAMESPERTICK,d2
			ble.s	.setCount
			move.l	#VMP_FRAMESPERTICK,d2
.setCount
			sub.l	d2,vmp_FramesToDecode(a5)				; Decrement master counter
			subq.l	#1,d2							; DBF counter

.decodeLoop		movea.l	vmp_MPEGABase(a5),a6
			move.l	vmp_MP3_Stream(a5),a0
			move.l	#vmp_DecodeStreamArray,a1
			LVO	MPEGA_Decode
			tst.l	d0
			bgt.s	.decoded
			
			; Decode failed (d0 <= 0)!
			; Check if this is at the start of the song (sync error from ID3v2 tags / embedded JPEG)
			tst.l	vmp_DecodedSamples(a5)
			bne.s	.notAtStart
			
			; We are at track start and MPEGA_Decode failed!
			; Perform 100ms seek-based resynchronization loop
			move.l	#100,d3							; Start seek at 100 ms
.syncLoop
			movea.l	vmp_MPEGABase(a5),a6
			movea.l	vmp_MP3_Stream(a5),a0
			move.l	d3,d0							; Target time in ms
			moveq	#0,d1							; Absolute seek (0)
			LVO	MPEGA_Seek
			tst.l	d0
			bmi.s	.syncNext						; Seek failed, try next offset
			
			movea.l	vmp_MPEGABase(a5),a6
			move.l	vmp_MP3_Stream(a5),a0
			move.l	#vmp_DecodeStreamArray,a1
			LVO	MPEGA_Decode
			tst.l	d0
			bgt.s	.syncFound						; Success! Synchronized with audio stream!

.syncNext
			add.l	#100,d3							; Increment by 100 ms
			
			; Check search limit: 3000 ms or song duration (if known)
			move.l	vmp_SongDuration(a5),d0
			tst.l	d0
			beq.s	.useDefaultLimit
			cmp.l	#3000,d0
			bls.s	.checkLimit
.useDefaultLimit
			move.l	#3000,d0
.checkLimit
			cmp.l	d0,d3
			bls.s	.syncLoop
			bra.w	.eof							; Exhausted search; abort

.syncFound
			; Sync found! Update DecodedSamples to match seek position
			move.l	d3,d0
			divu.l	#1000,d0						; d0 = elapsed seconds
			move.l	vmp_SongSampleRate(a5),d1
			mulu.l	d1,d0							; d0 = elapsed samples
			move.l	d0,vmp_DecodedSamples(a5)

			; Update duration if mpega.library has now computed it
			movea.l	vmp_MP3_Stream(a5),a0
			move.l	mp3_ms_duration(a0),d0
			tst.l	d0
			beq.s	.decoded
			move.l	d0,vmp_SongDuration(a5)
			bra.s	.decoded

.notAtStart
			; Check if genuine EOF error code (-1)
			cmp.l	#MPEGA_ERR_EOF,d0
			beq.s	.eof

			; Check if we are close to the end of the song
			move.l	vmp_DecodedSamples(a5),d0
			divu.l	vmp_SongSampleRate(a5),d0			; d0 = ElapsedSeconds
			mulu.l	#1000,d0							; d0 = ElapsedMS
			
			move.l	vmp_SongDuration(a5),d1
			beq.s	.transientError						; If duration unknown (0), don't assume EOF
			cmp.l	#3000,d1
			bls.s	.eof								; If song is under 3 seconds, treat as EOF!
			sub.l	#2000,d1
			cmp.l	d1,d0
			bhs.s	.eof								; If within 2 seconds of the end, treat as EOF!

.transientError
			; Transient decode error (e.g. sync lost mid-stream). Write silence for 1152 samples.
			movea.l	vmp_PCM_DecodePointer(a5),a2
			move.l	#1152-1,d1
.clearLoop	move.l	#0,(a2)+
			dbf	d1,.clearLoop
			move.l	a2,vmp_PCM_DecodePointer(a5)
			add.l	#1152,vmp_DecodedSamples(a5)
			dbf	d2,.decodeLoop
			bra.s	.checkFull
			
.eof
			; Genuine EOF! Drain remaining audio buffers smoothly without cutting off music
			clr.l	vmp_FramesToDecode(a5)

			; Check if any samples were decoded into the current inactive buffer
			move.l	vmp_PCM_ActiveBuffer(a5),d2
			eor.l	#4,d2							; Decoding buffer is the other buffer
			lea	vmp_PCM_PlayBufferArray,a0
			movea.l	(a0,d2.w),a3						; Base of decoding buffer
			move.l	vmp_PCM_DecodePointer(a5),a2
			suba.l	a3,a2							; Bytes decoded in this buffer
			tst.l	a2
			beq.s	.onlyActiveBuffer

			; Save length and queue the final partial buffer
			lea	vmp_PCM_LengthArray,a0
			move.l	a2,(a0,d2.w)
			bsr	_QueueBuffer

			; 2 interrupts needed: 1 when active buffer finishes, 1 when queued partial finishes
			move.l	#2,vmp_EOF_Pending(a5)
			bra.s	.exit

.onlyActiveBuffer
			; No partial buffer; current active buffer is the last one (1 interrupt to finish)
			move.l	#1,vmp_EOF_Pending(a5)
			bra.s	.exit
    
.decoded	add.l	d0,vmp_DecodedSamples(a5)
			lea	vmp_DecodeStream1,a0
			lea	vmp_DecodeStream2,a1
			move.l	vmp_PCM_DecodePointer(a5),a2

			subq.l	#1,d0
.copyLoop	move.w	(a0)+,(a2)+						; Copying channel 1
			move.w	(a1)+,(a2)+						; Copying channel 2 
    		dbf	d0,.copyLoop
			
			move.l	a2,vmp_PCM_DecodePointer(a5)				; Save pointer

			dbf	d2,.decodeLoop
			
.checkFull	tst.l	vmp_FramesToDecode(a5)
			bne.s	.exit
			
			; Buffer is full! Save length and QUEUE!
			move.l	vmp_PCM_ActiveBuffer(a5),d2
			eor.l	#4,d2							; Decoding buffer is ALWAYS the OTHER buffer!
			
			lea	vmp_PCM_PlayBufferArray,a0
			movea.l	(a0,d2.w),a3						; a3 = Base of decoding buffer
			move.l	vmp_PCM_DecodePointer(a5),a2
			suba.l	a3,a2							; a2 = Total bytes decoded
			lea	vmp_PCM_LengthArray,a0
			move.l	a2,(a0,d2.w)
			
			; Queue the newly decoded buffer IMMEDIATELY!
			; d2 already contains the decoding buffer index (0 or 4)
			bsr	_QueueBuffer
			
.exit			movem.l	(sp)+,d0-d3/a0-a3/a6
			rts
			


			;------------------------------------------------------------
			; _SongFinished
			;------------------------------------------------------------
_SongFinished
			movem.l	d0-d3/a0-a3/a6,-(sp)

			move.l	#0,vmp_Playing(a5)
			move.l	#0,vmp_FramesToDecode(a5)
			move.l	#0,vmp_EOF_Pending(a5)
			moveq	#VMP_STATUS_IDLE,d0
			bsr	_SetStatus
			moveq	#VMP_AUDIO_CHANNEL,d0
			bsr	_StopAudio

			; Check Loop Mode: 1 = Loop Track
			cmp.l	#1,vmp_PlaylistLoop(a5)
			bne.s	.nextSong

			; Loop Track active! Restart current song depending on PlayingFrom
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			beq.s	.repeatPlaylist
			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			beq.s	.repeatDirlist
			bra.s	.nextSong

.repeatPlaylist
			bsr	_PlaylistClicked
			bra.s	.songDone

.repeatDirlist
			bsr	_DirlistClicked
			bra.s	.songDone

.nextSong	bsr	_MainWdwButtonNext					; Play next song

.songDone	movem.l	(sp)+,d0-d3/a0-a3/a6
			rts
			


			;------------------------------------------------------------
			; _QueueBuffer
			;------------------------------------------------------------
			;

_QueueBuffer		movem.l	d0-d2/a0-a1,-(sp)

			; d2 contains target buffer offset (0 or 4)
			lea	vmp_PCM_PlayBufferArray,a0
			movea.l	(a0,d2.w),a0						; a0 = Buffer pointer
			lea	vmp_PCM_LengthArray,a1
			move.l	(a1,d2.w),d0
			lsr.l	#3,d0
			
			movea.l	#AUD0L,a1
			moveq	#VMP_AUDIO_CHANNEL,d1
			lsl.l	#4,d1
			add.l	d1,a1							; a1 = channel base
			
			move.l	a0,(a1)							; Queue AUDxL
			move.l	d0,4(a1)						; Queue AUDxLEN
			
			movem.l	(sp)+,d0-d2/a0-a1
			rts



			; _PlayAudio
			;--------------------------------------------------------------
			; INPUT:
			;	a0 = Sample/Audio to play (16-bit, 44.1Khz, RAW bigendian format)
			;	d0 = Sample size in bytes
			;	d1 = Channel - Number between 0 and 15
			;	d2 = Volume - Word with left and right volume in each byte. d2=$80ff would pan volume slightly to the right
			
_PlayAudio		movem.l	d0-d4/a0-a2,-(sp)

			move.l	d1,d3							; Save channel in d3

			movea.l	#AUD0L,a1						; Base address of channel 0
			lsl.l	#4,d1							; Muliply channel by 16 to find byte offset
			add.l	d1,a1							; a1 = base of selected channel

			lsr.l	#3,d0							; Divide by 8 to get lenght in pairs of 16 bit samples
			
			move.l	a0,(a1)							; AUDxL 	- Set audio sample
			move.l	d0,$4(a1)						; AUDxLEN 	- Length
			move.w	d2,$8(a1)						; AUDxVOL 	- Volume
			
			; Dynamic Frequency Calculation (3546895 / StreamFreq)
			movea.l	vmp_MP3_Stream(a5),a2
			move.l	mp3_dec_frequency(a2),d0
			move.l	#3546895,d4
			divu.l	d0,d4
			move.w	d4,$c(a1)						; AUDxPER 	- Dynamic sample rate
			
			move.w	#5,$a(a1)						; AUDxCTRL	- Set 16 bit stereo - Play sample in loop
			
			cmp.l	#3,d3
			bgt.s	.highChannel
			move.w	#$8200,d0						; Prepare to set bit 15 and enable DMA
			bset	d3,d0							; Set 0,1,2, or 3 depending on selected channel
			move.w	d0,DMACON						; Start playing
			
			bra.s	.done
			
.highChannel		subq.w	#4,d3							; Channel 4 starts at bit 0
			move.w	#$8000,d0						; Set bit 15
			bset	d3,d0						
			move.w	d0,DMACON2
			move.w	#$8200,DMACON						; DMACON is used to start sound even for higher channels
			
.done			movem.l	(sp)+,d0-d4/a0-a2
			rts



			; _StopAudio
			;--------------------------------------------------------------
			; INPUT:
			;	d0 = Channel - Number between 0 and 15
			
_StopAudio		movem.l	d0-d3/a0-a1,-(sp)

			move.l	d0,d3							; Save channel in d3

			cmp.l	#3,d3
			bgt.s	.highChannel
			moveq	#0,d0							; Clear bit 15
			bset	d3,d0							; Set 0,1,2, or 3 depending on selected channel
			move.w	d0,DMACON						; Stop audio on channel
			
			bra.s	.done
			
.highChannel		subq.w	#4,d3							; Channel 4 starts at bit 0
			moveq	#0,d0							; Clear bit 15
			bset	d3,d0
			move.w	d0,DMACON2						; Stop any audio on this channel
			move.w	#$8200,DMACON						; Do it!

.done			moveq	#50,d1
.waitLoop		tst.b	CIAAPRA
			dbf	d1,.waitLoop						; System needs to wait a bit before new sound can be set on this channel

			movem.l	(sp)+,d0-d3/a0-a1
			rts



			; _SetVolume
			;--------------------------------------------------------------
			; INPUT:
			;	d0 = Channel - Number between 0 and 15
			;	d1 = Volume - Number between 0 and 100
			
_SetVolume		movem.l	d0-d1/a0,-(sp)

			movea.l	#AUD0L,a0						; Base address of channel 0
			lsl.l	#4,d0							; Muliply channel by 16 to find byte offset
			add.l	d0,a0							; a0 = base of selected channel

			mulu	#255,d1
			divu	#100,d1
			move.b	d1,d0
			lsl	#8,d0
			move.b	d1,d0
			move.w	d0,$8(a0)						; AUDxVOL 	- Volume
			
.done			movem.l	(sp)+,d0-d1/a0
			rts

			;------------------------------------------------------------
			; _SeekMP3
			;
			; Input: d0 = Target Per-mil value (0 to 1000)
			;------------------------------------------------------------
_SeekMP3		movem.l	d0-d7/a0-a4/a6,-(sp)
			move.l	d0,d2								; d2 = TargetPerMil (0-1000)
			
			tst.l	vmp_Playing(a5)
			beq.w	.exit
			
			; 1. Pause Player & Stop Audio DMA
			bsr	_PausePlayer
			
			; 2. Calculate target milliseconds (TargetMS) safely
			move.l	vmp_SongDuration(a5),d0				; d0 = SongDuration (ms)
			move.l	d0,d1
			divu.l	#1000,d1							; d1 = SongDuration / 1000 (seconds)
			cmp.l	#4000000,d0							; check if duration is under 4 million ms (~66 mins)
			bcs.s	.safePrecision
			
			; Safe calculation for very long streams (avoid 32-bit overflow)
			move.l	d1,d0								; d0 = SongDuration in seconds
			mulu.l	d2,d0								; d0 = DurationSeconds * TargetPerMil
			divu.l	#1000,d0							; d0 = TargetSeconds
			mulu.l	#1000,d0							; d0 = TargetMS
			bra.s	.calcSamples
			
.safePrecision
			mulu.l	d2,d0								; d0 = SongDuration * TargetPerMil
			divu.l	#1000,d0							; d0 = TargetMS
			
.calcSamples
			move.l	d0,d5								; d5 = TargetMS
			
			; 3. Invoke native seek function in mpega.library
			movea.l	vmp_MPEGABase(a5),a6
			movea.l	vmp_MP3_Stream(a5),a0
			move.l	d5,d0								; d0 = target time in ms
			moveq	#0,d1								; d1 = absolute seek mode (0)
			LVO	MPEGA_Seek
			
			tst.l	d0									; Check for seek failure (negative return value)
			bmi.w	.fallback							; If failed, branch to safe fallback loop!
			
			; Success! Update decoded samples count to keep elapsed time in sync
			move.l	d5,d0								; d0 = TargetMS
			divu.l	#1000,d0							; d0 = TargetSeconds
			move.l	vmp_SongSampleRate(a5),d1
			mulu.l	d1,d0								; d0 = TargetSamples
			move.l	d0,vmp_DecodedSamples(a5)
			bra.s	.fillBuffers
			
.fallback
			; Fallback: Close and Reopen stream, then perform sequential frame skip
			movea.l	vmp_MPEGABase(a5),a6
			movea.l	vmp_MP3_Stream(a5),a0
			LVO	MPEGA_Close
			move.l	#0,vmp_MP3_Stream(a5)
			
			; Reopen stream using dedicated current song path
			lea	vmp_CurrentSongPath(a5),a0
			lea	MP3_Ctrl,a1
			LVO	MPEGA_Open
			tst.l	d0
			beq.w	.exit								; If open failed, fail
			move.l	d0,vmp_MP3_Stream(a5)
			
			; Reset sample counter and EOF state
			move.l	#0,vmp_DecodedSamples(a5)
			move.l	#0,vmp_EOF_Pending(a5)
			
			; Calculate TargetSamples
			move.l	d5,d0								; d0 = TargetMS
			divu.l	#1000,d0							; d0 = TargetSeconds
			move.l	vmp_SongSampleRate(a5),d1
			mulu.l	d1,d0								; d0 = TargetSamples
			move.l	d0,d4								; d4 = TargetSamples (cache in d4)
			
			; Skip loop
			movea.l	vmp_MPEGABase(a5),a6
			move.l	vmp_MP3_Stream(a5),d6				; cache in d6
			
.skipLoop
			cmp.l	vmp_DecodedSamples(a5),d4
			bls.s	.skipDone
			
			movea.l	d6,a0
			move.l	#vmp_DecodeStreamArray,a1
			LVO	MPEGA_Decode
			tst.l	d0
			ble.s	.skipDone
			
			add.l	d0,vmp_DecodedSamples(a5)
			bra.s	.skipLoop
			
.skipDone

.fillBuffers
			; 5. Re-fill double buffers (Buffer A & B)
			; 1. Decode Buffer A (0)
			move.l	#4,vmp_PCM_ActiveBuffer(a5)
			move.l	#28,vmp_FramesToDecode(a5)
			lea	vmp_PCM_PlayBufferArray,a0
			move.l	(a0),vmp_PCM_DecodePointer(a5)
.initLoop1	bsr	_DecodeFrames
			tst.l	vmp_FramesToDecode(a5)
			bne.s	.initLoop1
			
			; 2. Decode Buffer B (4)
			move.l	#0,vmp_PCM_ActiveBuffer(a5)
			move.l	#28,vmp_FramesToDecode(a5)
			lea	vmp_PCM_PlayBufferArray,a0
			move.l	4(a0),vmp_PCM_DecodePointer(a5)
.initLoop2	bsr	_DecodeFrames
			tst.l	vmp_FramesToDecode(a5)
			bne.s	.initLoop2
			
			; Start playing Buffer A
			move.l	#0,vmp_PCM_ActiveBuffer(a5)
			clr.l	vmp_Paused(a5)
			bsr	_PlayMP3

			; Immediately queue Buffer B into hardware registers
			moveq	#4,d2
			bsr	_QueueBuffer

			; Clear dynamic signals in OS and vmp_Signals
			move.w	#$0400,INTREQ
			tst.w	INTREQR
			movea.l	4.w,a6
			moveq	#0,d0
			move.l	vmp_InterruptMask(a5),d1
			LVO	SetSignal
			
			move.l	vmp_InterruptMask(a5),d0
			not.l	d0
			and.l	d0,vmp_Signals
			
			moveq	#VMP_STATUS_PLAYING,d0
			bsr	_SetStatus
			move.l	#1,vmp_Playing(a5)
			
.exit		movem.l	(sp)+,d0-d7/a0-a4/a6
			rts



			;------------------------------------------------------------
			; _InitBitStreamHook
			;------------------------------------------------------------
			; Prepares the Hook structure pointing to _BitStreamHook
			;------------------------------------------------------------

_InitBitStreamHook	lea	vmp_BitStreamHook,a0
			clr.l	MLN_SUCC(a0)
			clr.l	MLN_PRED(a0)
			move.l	#_BitStreamHook,h_Entry(a0)
			move.l	#_BitStreamHook,h_SubEntry(a0)
			clr.l	h_Data(a0)
			rts




			;------------------------------------------------------------
			; _BitStreamHook
			;------------------------------------------------------------
			; Custom BitStream Access Hook for mpega.library
			;
			; Standard Amiga Hook registers:
			;	a0 = pointer to Hook structure
			;	a2 = stream handle / object (unused)
			;	a1 = pointer to MPAACC packet structure
			;
			; Returns result in d0
			;------------------------------------------------------------

_BitStreamHook		movem.l	d1-d7/a0-a6,-(sp)
			movea.l	vmp_StructPointer,a5			; Always establish a5
			movea.l	vmp_DosBase(a5),a6

			move.l	MPAACC_FUNC(a1),d0
			cmp.l	#MPEGA_BSFUNC_OPEN,d0
			beq.s	.bsOpen
			cmp.l	#MPEGA_BSFUNC_CLOSE,d0
			beq.s	.bsClose
			cmp.l	#MPEGA_BSFUNC_READ,d0
			beq.s	.bsRead
			cmp.l	#MPEGA_BSFUNC_SEEK,d0
			beq.s	.bsSeek

			moveq	#0,d0
			bra.w	.bsExit

			;--- BSFUNC_OPEN ---
.bsOpen			; Close any previous handle that may linger
			tst.l	vmp_BSFileHandle(a5)
			beq.s	.doOpen
			move.l	vmp_BSFileHandle(a5),d1
			LVO	Close
			clr.l	vmp_BSFileHandle(a5)

.doOpen			clr.l	vmp_BSOffset(a5)
			move.l	MPAACC_OPEN_STREAM_NAME(a1),d1
			move.l	#MODE_OLDFILE,d2
			LVO	Open
			move.l	d0,vmp_BSFileHandle(a5)
			bne.s	.openedOk
			moveq	#0,d0							; Return 0 on failure
			bra.w	.bsExit

.openedOk		; Determine total file size: Seek to end
			move.l	vmp_BSFileHandle(a5),d1
			moveq	#0,d2
			moveq	#OFFSET_END,d3
			LVO	Seek
			; Seek back to beginning and get total file length
			move.l	vmp_BSFileHandle(a5),d1
			moveq	#0,d2
			moveq	#OFFSET_BEGINNING,d3
			LVO	Seek
			move.l	d0,d7							; d7 = total file size

			; Read first 10 bytes to inspect for ID3v2 header
			lea	-12(sp),sp						; Allocate 12 bytes on stack
			move.l	vmp_BSFileHandle(a5),d1
			move.l	sp,d2
			moveq	#10,d3
			LVO	Read
			cmp.l	#10,d0
			bne.s	.noID3

			; Check for "ID3" ($49, $44, $33)
			cmp.b	#'I',(sp)
			bne.s	.noID3
			cmp.b	#'D',1(sp)
			bne.s	.noID3
			cmp.b	#'3',2(sp)
			bne.s	.noID3

			; ID3v2 detected! Parse 28-bit synchsafe tag length from bytes 6-9:
			; tagSize = (b[6]<<21) | (b[7]<<14) | (b[8]<<7) | b[9]
			moveq	#0,d0
			move.b	6(sp),d0
			and.w	#$7f,d0
			lsl.l	#7,d0
			move.b	7(sp),d1
			and.w	#$7f,d1
			or.l	d1,d0
			lsl.l	#7,d0
			move.b	8(sp),d1
			and.w	#$7f,d1
			or.l	d1,d0
			lsl.l	#7,d0
			move.b	9(sp),d1
			and.w	#$7f,d1
			or.l	d1,d0

			; Total tag size = tagSize + 10 (header)
			add.l	#10,d0

			; Check if ID3v2.4 footer flag (bit 4 of byte 5) is set
			btst	#4,5(sp)
			beq.s	.saveID3
			add.l	#10,d0							; Add 10 bytes for footer

.saveID3		; Verify that the ID3 size is smaller than the total file size
			cmp.l	d7,d0
			bhs.s	.noID3
			move.l	d0,vmp_BSOffset(a5)

.noID3			lea	12(sp),sp						; Restore stack

			; Seek to vmp_BSOffset
			move.l	vmp_BSFileHandle(a5),d1
			move.l	vmp_BSOffset(a5),d2
			moveq	#OFFSET_BEGINNING,d3
			LVO	Seek

			; Read up to 2048 bytes into temporary buffer to find MPEG frame sync
			move.l	vmp_BSFileHandle(a5),d1
			lea	vmp_PCM_PlayBuffer1,a0
			move.l	a0,d2
			move.l	#2048,d3
			LVO	Read
			move.l	d0,d6
			subq.l	#2,d6
			ble.s	.seekAudioStart

			lea	vmp_PCM_PlayBuffer1,a0
			moveq	#0,d2
.syncLoop		cmp.b	#$ff,(a0)
			bne.s	.nextSync
			move.b	1(a0),d0
			and.b	#$e0,d0
			cmp.b	#$e0,d0
			bne.s	.nextSync
			move.b	1(a0),d0
			and.b	#$06,d0
			bne.s	.syncFound
.nextSync		addq.l	#1,a0
			addq.l	#1,d2
			subq.l	#1,d6
			bgt.s	.syncLoop
			bra.s	.seekAudioStart

.syncFound		add.l	d2,vmp_BSOffset(a5)

.seekAudioStart		; Seek file handle to the actual audio start offset
			move.l	vmp_BSFileHandle(a5),d1
			move.l	vmp_BSOffset(a5),d2
			moveq	#OFFSET_BEGINNING,d3
			LVO	Seek

			; Stream size exposed to mpega.library is (totalSize - vmp_BSOffset)
			move.l	d7,d0
			sub.l	vmp_BSOffset(a5),d0
			move.l	d0,MPAACC_OPEN_STREAM_SIZE(a1)
			moveq	#1,d0							; Return TRUE (success)
			bra.s	.bsExit

			;--- BSFUNC_CLOSE ---
.bsClose		tst.l	vmp_BSFileHandle(a5)
			beq.s	.bsCloseDone
			move.l	vmp_BSFileHandle(a5),d1
			LVO	Close
			clr.l	vmp_BSFileHandle(a5)
			clr.l	vmp_BSOffset(a5)
.bsCloseDone		moveq	#1,d0
			bra.s	.bsExit

			;--- BSFUNC_READ ---
.bsRead			tst.l	vmp_BSFileHandle(a5)
			beq.s	.readFail
			move.l	vmp_BSFileHandle(a5),d1
			move.l	MPAACC_READ_BUFFER(a1),d2
			move.l	MPAACC_READ_NUM_BYTES(a1),d3
			LVO	Read
			bra.s	.bsExit
.readFail		moveq	#0,d0
			bra.s	.bsExit

			;--- BSFUNC_SEEK ---
.bsSeek			tst.l	vmp_BSFileHandle(a5)
			beq.s	.seekFail
			move.l	MPAACC_SEEK_ABS_BYTE_SEEK_POS(a1),d2
			add.l	vmp_BSOffset(a5),d2				; Translate to physical file offset
			move.l	vmp_BSFileHandle(a5),d1
			moveq	#OFFSET_BEGINNING,d3
			LVO	Seek
			cmp.l	#-1,d0
			beq.s	.seekFail
			moveq	#0,d0							; 0 = success
			bra.s	.bsExit
.seekFail		moveq	#-1,d0

.bsExit			movem.l	(sp)+,d1-d7/a0-a6
			rts



			section data,Data


			; MP3 Stuff - *** Thanks Nihirash ***

MP3_Ctrl:
			; Hook
			dc.l vmp_BitStreamHook
			; Layer 1/2:
			; - Force mono?	
			dc.w 0
			; - Mono output params(high quality) 
			dc.w 1, 2
			dc.l 48000
			; - Stereo output params(high quality)	
			dc.w 1, 2
			dc.l 48000
			; Layer 3:
			; - Force mono:
			dc.w 0
			; - Mono output params(high quality)
			dc.w 1, 2
			dc.l 48000
			; - Stereo output params(high quality)	
			dc.w 1, 2
			dc.l 48000
			; Check mpeg?	
			dc.w 0
			; Buffer size(samples)
			dc.l VMP_MP3BUFFERSIZE

			even
vmp_BitStreamHook	ds.b	h_SIZEOF

			even
vmp_DecodeStreamArray	dc.l	vmp_DecodeStream1
			dc.l	vmp_DecodeStream2
			
vmp_PCM_PlayBufferArray	dc.l	vmp_PCM_PlayBuffer1
			dc.l	vmp_PCM_PlayBuffer2

vmp_PCM_LengthArray	dc.l	0,0



			; Buffers
			
			section	bss,bss

			cnop	0,8
vmp_DecodeStream1	ds.b    4096							; 2304 bytes + some for good measure
vmp_DecodeStream2	ds.b    4096

			cnop	0,8
vmp_PCM_PlayBuffer1	ds.b	VMP_MP3BUFFERSIZE
vmp_PCM_PlayBuffer2	ds.b	VMP_MP3BUFFERSIZE

