**	$VER: vaMP3.s v1.0 release (April 2026)
**	Platform: Apollo Vampire with MUI
**	Assemble command:
**				vasmm68k_mot vaMP3.s -Fhunkexe -no-opt
**	
**	Author: Tomas Jacobsen - Bedroomcoders.com
**	Description: 
**
			machine 68080
			output ram:vaMP3

			incdir	"include:"
			include	"exec/exec.i"
			include	"exec/exec_lib.i"
			include	"hardware/intbits.i"
			include	"intuition/intuition.i"
			include	"intuition/intuition_lib.i"
			include	"libraries/mui.i"
			include	"lvo/mui_lib.i"
			include	"lvo/asl_lib.i"
			include	"libraries/asl.i"
			include	"cybergraphics/cybergraphics_lib.i"

			include	"vaMP3.i"
			
			IFND	MACROS_I
				include	"Macros.i"
			ENDC


		STRUCTURE	vmp,0
			APTR	vmp_MUIBase
			APTR	vmp_IntuitionBase
			APTR	vmp_GraphicsBase
			APTR	vmp_CyberGfxBase
			APTR	vmp_ASLBase
			APTR	vmp_UtilityBase
			APTR	vmp_MPEGABase
			APTR	vmp_CustomButtonClass
			LONG	vmp_Quit
			LONG	vmp_Playing
			LONG	vmp_Paused
			APTR	vmp_Intui_Window
			APTR	vmp_Intui_UserPort
			LONG	vmp_InterruptSignal
			STRUCT	vmp_InterruptStruct,IS_SIZE
			APTR	vmp_OldInterrupt
			APTR	vmp_MainTask
			LONG	vmp_InterruptMask
			APTR	vmp_MUI_Application
			APTR	vmp_MUI_MainWindow
			APTR	vmp_MUI_Group
			APTR	vmp_MUI_ButtonQuit
			APTR	vmp_MUI_ButtonOpen
			APTR	vmp_MUI_ButtonStop
			APTR	vmp_MUI_ButtonPause
			APTR	vmp_MUI_ButtonPlay
			APTR	vmp_MUI_ButtonNext
			APTR	vmp_MUI_ButtonPrevious
			APTR	vmp_MUI_StatusText
			APTR	vmp_MUI_HGroup1
			APTR	vmp_MUI_HGroup2
			APTR	vmp_MUI_VGroup
			APTR	vmp_MP3_Stream
			LONG	vmp_PCM_ActiveBuffer
			LONG	vmp_PCM_AudioSize
			LONG	vmp_FramesToDecode
			APTR	vmp_PCM_DecodePointer
			APTR	vmp_TimerDeviceBase
			LONG	vmp_TimerSignal
			LONG	vmp_TimerMask
			STRUCT	vmp_TimerPort,34
			STRUCT	vmp_Padding,2
			STRUCT	vmp_TimerReq,40
		LABEL	vmp_SIZEOF



			section code,Code


			;------------------------------------------------------------
			; _Init
			;------------------------------------------------------------

_Init			move.l	4.w,a6
			move.l	#vmp_SIZEOF,d0
			move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
			LVO	AllocMem
			tst.l	d0
			beq	.allocError
			movea.l	d0,a5							; Internal VMP Struct in a5 at all times
			move.l	d0,vmp_StructPointer
			
			moveq	#-1,d0
			LVO	AllocSignal
			cmp.b	#-1,d0
			beq.w	.allocsignalError
			and.l	#$000000ff,d0						; Extend byte to long
			move.l	d0,vmp_InterruptSignal(a5)

			; Create mask and find task
			moveq	#1,d1
			lsl.l	d0,d1
			move.l	d1,vmp_InterruptMask(a5)
			suba.l	a1,a1
			LVO	FindTask
			move.l	d0,vmp_MainTask(a5)

			; Allocate Timer Signal
			movea.l	4.w,a6
			moveq	#-1,d0
			LVO	AllocSignal
			cmp.b	#-1,d0
			beq.w	.allocsignalError
			and.l	#$000000ff,d0
			move.l	d0,vmp_TimerSignal(a5)
			moveq	#1,d1
			lsl.l	d0,d1
			move.l	d1,vmp_TimerMask(a5)

			; Initialize Timer Port
			lea	vmp_TimerPort(a5),a0
			move.b	#NT_MSGPORT,8(a0)		; NT_MSGPORT
			move.b	vmp_TimerSignal+3(a5),MP_SIGBIT(a0)
			move.l	vmp_MainTask(a5),MP_SIGTASK(a0)
			lea	MP_MSGLIST(a0),a1
			NEWLIST	a1

			; Initialize Timer Request
			lea	vmp_TimerReq(a5),a0
			move.b	#5,8(a0)		; NT_REPLYMSG
			lea	vmp_TimerPort(a5),a1
			move.l	a1,14(a0) 		; mn_ReplyPort
			move.w	#40,18(a0)		; mn_Length

			; Open Timer Device
			lea	vmp_TimerReq(a5),a1
			moveq	#0,d0							; UNIT_MICROHZ
			moveq	#0,d1
			lea	vmp_TimerDeviceName,a0
			LVO	OpenDevice
			tst.l	d0
			bne.s	.skipTimer
			move.l	#1,vmp_TimerDeviceBase(a5)				; Just set non-zero flag
.skipTimer

			; Open Libs
			OPENLIB	Intuition,0
			beq	.cleanup

			OPENLIB	CyberGfx, 41
			
			bne.s	.cgxOpened
			SHOWALERT	vmp_CGXAlert
			bra	.cleanup

.cgxOpened		OPENLIB	MUI,0
			bne.s	.muiOpened
			SHOWALERT	vmp_MUIAlert
			bra	.cleanup

.muiOpened		OPENLIB	ASL,0
			bne.s	.aslOpened
			SHOWALERT	vmp_ASLAlert
			bra	.cleanup

.aslOpened		OPENLIB	MPEGA,0
			bne.s	.mpegaOpened
			SHOWALERT	vmp_MPEGAAlert
			bra.w	.cleanup

			; Create MUI - Application, Window, buttons, etc
.mpegaOpened		bsr	_InitCustomClass
			bsr	_BuildGui
			beq.s	.guiBuilt
			SHOWALERT	vmp_GUIAlert
			bra.w	.cleanup

			; Create Notifications and Hooks
.guiBuilt		bsr	_CreateHooks

			; Extract Intuition WindowBase from MUI Window
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWindow(a5),a0
			move.l	#MUIA_Window_Window,d0
			lea	vmp_Intui_Window(a5),a1
			LVO	GetAttr
			tst.l	d0	
			bne.s	.wdwExtracted
			SHOWALERT	vmp_WDWAlert
			bra.s	.cleanup
.wdwExtracted		movea.l	vmp_Intui_Window(a5),a0
			move.l	wd_UserPort(a0),vmp_Intui_UserPort(a5)			; Get UserPort the regular way

			; Combine interrupt signal with MUI signal
			move.l	vmp_Signals,d0
			move.l	vmp_InterruptSignal(a5),d1
			bset	d1,d0
			move.l	d0,vmp_Signals

			; Set up interrupt handler for processing audio
			movea.l	4.w,a6
			moveq	#INTB_AUD3,d0

			lea	vmp_InterruptStruct(a5),a1
			move.b	#NT_INTERRUPT,LN_TYPE(a1)
			move.b	#10,LN_PRI(a1)
			move.l	#vmp_ApplicationTitle,LN_NAME(a1)
			move.l	#_InterruptHandler,IS_CODE(a1)
			move.l	a5,IS_DATA(a1)
			move.w	#$0400,INTREQ
			tst.w	INTREQR							; Dummy read to flush bus
			LVO	SetIntVector
			move.l	d0,vmp_OldInterrupt(a5)
			
			move.w	#$8400,$dff09a

			tst.l	vmp_TimerDeviceBase(a5)
			beq.s	.noStartTimer
			lea	vmp_TimerReq(a5),a1
			move.w	#9,28(a1)						; io_Command = TR_ADDREQUEST
			move.l	#0,32(a1)						; tv_secs = 0
			move.l	#20000,36(a1)						; tv_micro = 20000 (20ms)
			movea.l	4.w,a6
			LVO	SendIO
.noStartTimer

			; EventHandler is the mainloop
			bsr	_EventHandler



			; Remove interrupt handler for processing audio
			move.w	#$0400,$dff09a
			movea.l	4.w,a6
			moveq	#INTB_AUD3,d0
			lea	vmp_OldInterrupt(a5),a1
			LVO	SetIntVector

			; Stop playing audio
			moveq	#VMP_AUDIOCHANNEL,d0
			bsr	_StopAudio

			movea.l	vmp_UtilityBase(a5),a1
			movea.l	4.w,a6
			LVO	CloseLibrary

			movea.l	vmp_MUIBase(a5),a6
			movea.l	vmp_MUI_Application(a5),a0
			LVO	MUI_DisposeObject		

.cleanup		CLOSELIB	MPEGA
			CLOSELIB	ASL
			CLOSELIB	MUI
			CLOSELIB	CyberGfx
			CLOSELIB	Intuition

			movea.l	4.w,a6
			
			; Safe Timer Cleanup!
			tst.l	vmp_TimerDeviceBase(a5)
			beq.s	.noTimer
			lea	vmp_TimerReq(a5),a1
			LVO	AbortIO
			lea	vmp_TimerReq(a5),a1
			LVO	WaitIO
			lea	vmp_TimerReq(a5),a1
			LVO	CloseDevice
.noTimer
			move.l	vmp_TimerSignal(a5),d0
			LVO	FreeSignal

			move.l	vmp_InterruptSignal(a5),d0
			LVO	FreeSignal

.allocsignalError	movea.l	4.w,a6
			movea.l	a5,a1
			move.l	#vmp_SIZEOF,d0
			LVO	FreeMem

.allocError		rts



			;------------------------------------------------------------
			; _EventHandler
			;------------------------------------------------------------

_EventHandler		movem.l	d0-d2/a0-a2/a6,-(sp)

.loop			movea.l	vmp_MUI_Application(a5),a2				; MUI Objects are of ICLASS Type
			movea.l	-4(a2),a0						; Offset to Hook Struct (Is this undocumented?)
			movea.l	h_Entry(a0),a6						; Find entry to execute method
			lea	vmp_Method_Input,a1
			jsr	(a6)							; DoMethod();

			cmp.l	#MUIV_Application_ReturnID_Quit,d0
			beq.w	.exit
    
			movea.l	4.w,a6
			move.l	vmp_Signals,d0
			or.l	vmp_InterruptMask(a5),d0				; Re-add audio mask
			or.l	vmp_TimerMask(a5),d0					; Re-add timer mask
			beq.s	.loop
			LVO	Wait
			move.l	d0,vmp_Signals						; Feed received signals back to MUI
			
			; Handle Timer Signal
			move.l	d0,d2
			and.l	vmp_TimerMask(a5),d2
			beq.s	.checkAudio
			
			; Timer fired - get the message.
			movea.l	4.w,a6
			lea	vmp_TimerPort(a5),a0
			LVO	GetMsg
			tst.l	d0
			beq.s	.checkAudio						; No message!
			
			; Got timer message. 
			; Re-issue it immediately so it ticks again!
			lea	vmp_TimerReq(a5),a1
			move.w	#9,28(a1)						; io_Command = TR_ADDREQUEST
			move.l	#0,32(a1)						; tv_secs = 0
			move.l	#20000,36(a1)						; tv_micro = 20000 (20ms)
			movea.l	4.w,a6
			LVO	SendIO
			
			; Decode up to 2 frames if needed!
			tst.l	vmp_Playing(a5)
			beq.s	.checkAudio
			tst.l	vmp_Paused(a5)
			bne.s	.checkAudio
			
			bsr	_DecodeFrames
			
.checkAudio		; Check audio interrupt
			move.l	vmp_Signals,d0
			and.l	vmp_InterruptMask(a5),d0
			beq.w	.loop
			
			; Audio interrupt. Hardware swapped buffers.
			; Clear the audio signal flag from vmp_Signals
			move.l	vmp_InterruptMask(a5),d1
			not.l	d1
			and.l	d1,vmp_Signals

			; Setup Decoding Pointers sequentially in Main Task
			move.l	#28,vmp_FramesToDecode(a5)
			
			; Decoding buffer is the NEW ActiveBuffer (which Paula is NOT playing)
			move.l	vmp_PCM_ActiveBuffer(a5),d1
			eor.l	#4,d1
			lea	vmp_PCM_PlayBufferArray,a0
			move.l	(a0,d1.w),vmp_PCM_DecodePointer(a5)
			
			bra.w	.loop

.exit			movem.l	(sp)+,d0-d2/a0-a2/a6
			rts



			;------------------------------------------------------------
			; _InterruptHandler
			;------------------------------------------------------------

_InterruptHandler	; Registers are save/restored by the OS in an SetIntVector hook
			movea.l	a1,a5							; vmp Struct in a5

			move.w	#$0400,INTREQ
			tst.w	INTREQR							; Dummy read to flush bus

			tst.l	vmp_Playing(a5)
			beq.s	.exit
			tst.l	vmp_Paused(a5)
			bne.s	.exit

			; Rotate Buffer (The one Paula just automatically switched to)
			move.l	vmp_PCM_ActiveBuffer(a5),d1
			eor.l	#4,d1
			move.l	d1,vmp_PCM_ActiveBuffer(a5)

			; Wake up the main task
			movea.l	4.w,a6
			movea.l	vmp_MainTask(a5),a1
			move.l	vmp_InterruptMask(a5),d0
			LVO	Signal
			
.exit			moveq	#0,d0							; Clear Z-flag
			rts



			section data,Data

vmp_MUIName		dc.b	"muimaster.library",0
vmp_UtilityName		dc.b	"utility.library",0
vmp_CyberGfxName	dc.b	"cybergraphics.library",0
vmp_IntuitionName	dc.b	'intuition.library',0
vmp_GraphicsName	dc.b	'graphics.library',0
vmp_ASLName		dc.b	"asl.library",0
vmp_MPEGAName		dc.b	"mpega.library",0
vmp_TimerDeviceName	dc.b	"timer.device",0
			even

vmp_StructPointer	dc.l	0


			; Alert messages

			even			
vmp_MUIAlert		dc.b	"Could not open muimaster.library",0
vmp_UtilAlert		dc.b	"Could not open utility.library",0
vmp_CGXAlert		dc.b	"Could not open cybergraphics.library",0
vmp_ASLAlert		dc.b	"Could not open asl.library",0
vmp_MPEGAAlert		dc.b	"Could not open mpega.library",0
vmp_GUIAlert		dc.b	"Error building GUI",0
vmp_ClassAlert		dc.b	"Failed to create Custom Class!",0
vmp_DispAlert		dc.b	"Dispatcher called!",0
vmp_SuperFailAlert	dc.b	"DoSuperMethodA returned 0!",0
vmp_WDWAlert		dc.b	"Could not extract WindowBase",0
vmp_MEMAlert		dc.b	"Could not allocate memory",0
vmp_AlertTitle		dc.b	"Alert!",0
vmp_AlertOK		dc.b	"OK",0
vmp_EasyStruct		ds.b	es_SIZEOF						; EasyStruct for Requesters



			; Include other source files

			include	"gui.s"
			include	"mp3.s"




