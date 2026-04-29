
			section	code,code



			;------------------------------------------------------------
			; _NewMP3
			;------------------------------------------------------------
			;
			; Input:
			;	a0 = Filename
			; Result:
			;	d0 = FALSE if failed

_NewMP3			movem.l	d0-d1/a0-a1/a6,-(sp)
			movea.l	vmp_MPEGABase(a5),a6
			lea     MP3_Ctrl,a1
			LVO	MPEGA_Open
			tst.l   d0
			bne.s	.mp3Opened
			moveq	#VMP_STATUS_OPENERROR,d0
			bsr	_SetStatus
			bra.s	.done

.mp3Opened		move.l	d0,vmp_MP3_Stream(a5)

			; Stop any playing audio
			moveq	#VMP_AUDIOCHANNEL,d0
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
			
			; Start Paula playing Buffer A
			move.l	#0,vmp_PCM_ActiveBuffer(a5)
			bsr	_PlayMP3
			
			; 2. Decode Buffer B (4)
			; Active=0, so _DecodeFrames automatically fills and queues 4!
			move.l	#28,vmp_FramesToDecode(a5)
			lea	vmp_PCM_PlayBufferArray,a0
			move.l	4(a0),vmp_PCM_DecodePointer(a5)
.initLoop2		bsr	_DecodeFrames
			tst.l	vmp_FramesToDecode(a5)
			bne.s	.initLoop2
			
			; Enabling DMA instantly fires an interrupt.
			; Clear this signal so our event loop doesn't instantly double-queue!
			movea.l	4.w,a6
			moveq	#0,d0
			move.l	vmp_InterruptMask(a5),d1
			LVO	SetSignal
			
			moveq	#VMP_STATUS_PLAYING,d0
			bsr	_SetStatus
			move.l	#1,vmp_Playing(a5)
			

.done			movem.l	(sp)+,d0-d1/a0-a1/a6
			rts



			;------------------------------------------------------------
			; _CloseMP3
			;------------------------------------------------------------
			;

_CloseMP3		move.l	#0,vmp_Playing(a5)
			moveq	#VMP_AUDIOCHANNEL,d0
			bsr	_StopAudio
			
			movea.l	vmp_MPEGABase(a5),a6
			movea.l	vmp_MP3_Stream(a5),a0
			LVO	MPEGA_Close
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

			moveq	#VMP_AUDIOCHANNEL,d1
			move.l	#$ffff,d2
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
			bset	#VMP_AUDIOCHANNEL,d0
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
			bset	#VMP_AUDIOCHANNEL,d0
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
			cmp.l	#2,d2
			ble.s	.setCount
			move.l	#2,d2
.setCount
			sub.l	d2,vmp_FramesToDecode(a5)				; Decrement master counter
			subq.l	#1,d2							; DBF counter

.decodeLoop		movea.l	vmp_MPEGABase(a5),a6
			move.l	vmp_MP3_Stream(a5),a0
			move.l	#vmp_DecodeStreamArray,a1
			LVO	MPEGA_Decode
			tst.l	d0
			bgt	.decoded
			
			; EOF or Error!
			move.l	#0,vmp_Playing(a5)
			move.l	#0,vmp_FramesToDecode(a5)
			move.l	#VMP_STATUS_IDLE,d0
			bsr	_SetStatus
			moveq	#VMP_AUDIOCHANNEL,d0
			bsr	_StopAudio
			bra.s	.exit
    
.decoded		lea	vmp_DecodeStream1,a0
			lea	vmp_DecodeStream2,a1
			move.l	vmp_PCM_DecodePointer(a5),a2

			subq.l	#1,d0
.copyLoop		move.w	(a0)+,(a2)+						; Copying channel 1
			move.w	(a1)+,(a2)+						; Copying channel 2 
    			dbf	d0,.copyLoop
			
			move.l	a2,vmp_PCM_DecodePointer(a5)				; Save pointer

			dbf	d2,.decodeLoop
			
			; Check if buffer is completely full!
			tst.l	vmp_FramesToDecode(a5)
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
			moveq	#VMP_AUDIOCHANNEL,d1
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



			section data,Data


			; MP3 Stuff - *** Thanks Nihirash ***

MP3_Ctrl:
			; Hook
			dc.l 0
			; Layer 1/2:
			; - Force mono?	
			dc.w 0
			; - Mono output params(high quality) 
			dc.w 1, 2
			dc.l 44100
			; - Stereo output params(high quality)	
			dc.w 1, 2
			dc.l 44100
			; Layer 3:
			; - Force mono:
			dc.w 0
			; - Mono output params(high quality)
			dc.w 1, 2
			dc.l 44100
			; - Stereo output params(high quality)	
			dc.w 1, 2
			dc.l 44100
			; Check mpeg?	
			dc.w 1
			; Buffer size(samples)
			dc.l VMP_MP3BUFFERSIZE

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

