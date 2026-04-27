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
			APTR	vmp_MUI_Window
			APTR	vmp_MUI_Group
			APTR	vmp_MUI_ButtonQuit
			APTR	vmp_MUI_ButtonOpen
			APTR	vmp_MUI_Button2
			APTR	vmp_MUI_Button3
			APTR	vmp_MUI_StatusText
			APTR	vmp_MUI_HGroup1
			APTR	vmp_MUI_HGroup2
			APTR	vmp_MUI_VGroup
			APTR	vmp_MP3_Stream
			LONG	vmp_PCM_ActiveBuffer
			LONG	vmp_PCM_AudioSize
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
			movea.l	d0,a5					; Internal VMP Struct in a5 at all times
			move.l	d0,vmp_StructPointer
			move.l	d0,vmp_GlobalPointer
			
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
			movea.l	vmp_MUI_Window(a5),a0
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
			beq.s	.exit
    
			movea.l	4.w,a6
			move.l	vmp_Signals,d0
			or.l	vmp_InterruptMask(a5),d0				; Re-add audio mask because MUI overwrites vmp_Signals!
			beq.s	.loop
			LVO	Wait
			move.l	d0,vmp_Signals						; Feed received signals back to MUI
			move.l	d0,d1
			and.l	vmp_InterruptMask(a5),d1
			beq.s	.loop
			
			; We got an audio interrupt. Let's swap buffers
			tst.l	vmp_Playing(a5)
			beq.s	.loop							; ignore if audio is stopped
			tst.l	vmp_Paused(a5)
			bne.s	.loop							; ignore if audio is paused

			
			move.l	vmp_PCM_ActiveBuffer(a5),d2
			eor.l	#4,d2
			move.l	d2,vmp_PCM_ActiveBuffer(a5)
			
			bsr	_DecodeMP3
			bsr	_QueueBuffer
			
			bra.s	.loop

.exit			movem.l	(sp)+,d0-d2/a0-a2/a6
			rts



			;------------------------------------------------------------
			; _InterruptHandler
			;------------------------------------------------------------

_InterruptHandler	; Registers are save/restored by the OS in an SetIntVector hook
			movea.l	a1,a5							; vmp Struct in a5

			move.w	#$0400,INTREQ
			tst.w	INTREQR							; Dummy read to flush bus

			;Wake up the main task
			movea.l	4.w,a6
			movea.l	vmp_MainTask(a5),a1
			move.l	vmp_InterruptMask(a5),d0
			LVO	Signal
			
			moveq	#0,d0							; Clear Z-flag
			rts



			;------------------------------------------------------------
			; _CreateHooks
			;------------------------------------------------------------

_CreateHooks		movem.l	a0-a2/a6,-(sp)

			movea.l	vmp_MUI_Window(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_WindowSetup,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set notify on close button)

			movea.l	vmp_MUI_ButtonQuit(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_QuitButton,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set notify on quit button)

			movea.l	vmp_MUI_ButtonOpen(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_ButtonOpen,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set hook to run _ButtonOpenPressed)

			movem.l	(sp)+,a0-a2/a6
			rts



			;------------------------------------------------------------
			; _ButtonOpenPressed
			;------------------------------------------------------------

_ButtonOpenPressed	movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our struct in a5.

			bsr	_PauseMP3
			lea	vmp_FilenameBuffer,a0
			bsr	_AskFile
			bsr	_ResumeMP3
			tst.l	d0
			beq.s	.done
						
			lea	vmp_FilenameBuffer,a0
			bsr	_NewMP3

.done			movem.l	(sp)+,a0/a5-a6
			rts
			


			;------------------------------------------------------------
			; _SetStatus
			;------------------------------------------------------------
			; Input:
			;	d0 = Status

_SetStatus		movem.l	d0-d1/a0-a1/a6,-(sp)
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_StatusText(a5),a0
			lea	vmp_StatusTable,a1
			lsl.l	#2,d0
			adda.l	d0,a1
			movea.l	(a1),a1
			INITSTACKTAG
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1
			movem.l	(sp)+,d0-d1/a0-a1/a6
			rts

			

			;------------------------------------------------------------
			; _BuildGUI
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 1
			;	Error 	d0 = 1

_BuildGui		movem.l	d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
			CREATEMUIBUTTON	vmp_QuitButtonTitle
			move.l	d0,vmp_MUI_ButtonQuit(a5)				; Create Quit Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Pause_Raw
			move.l	d0,vmp_MUI_ButtonOpen(a5)				; Create Open Button
			bne.s	.btn1ok
			SHOWALERT	vmp_BtnAlert
			bra	.error
.btn1ok

			CREATEMUICUSTOMBUTTON	img_Stop_Raw
			move.l	d0,vmp_MUI_Button2(a5)					; Create Button2
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Play_Raw
			move.l	d0,vmp_MUI_Button3(a5)					; Create Button3
			beq	.error

			CREATEMUITEXT	vmp_StatusIdleTxt
			move.l	d0,vmp_MUI_StatusText(a5)				; Create Status field
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_ButtonQuit(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_HGroup1(a5)					; Create MUI Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_Button2(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_Button3(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_ButtonOpen(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_HGroup2(a5)					; Create MUI Horizontal Group 2
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_StatusText(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_HGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_HGroup2(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_VGroup(a5)					; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	1,MUIA_Window_ID
			STACKADRTAG	vmp_WindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_WINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_WINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_Window(a5)
			beq	.error
			
			lea	MUIC_Application,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Application_Window
			STACKADRTAG	vmp_ApplicationTitle, MUIA_Application_Title
			STACKADRTAG	vmp_AppBase, MUIA_Application_Base
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Application
			move.l	d0,vmp_MUI_Application(a5)
			beq.s	.error

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_Window(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1				; Open our window and draw gadgets

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d5/a0-a2/a6
			tst.l	d0
			rts


			;------------------------------------------------------------
			; _NewMP3
			;------------------------------------------------------------
			; INPUT:
			;	a0 = Filename
			; RESULT:
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

			; Stop any playing audio and free previous buffer if allocated
			moveq	#VMP_AUDIOCHANNEL,d0
			bsr	_StopAudio
    
			; Resulting audio buffer size calculation
			movea.l	vmp_MP3_Stream(a5),a0
			move.l	mp3_ms_duration(a0),d0
    
			divu.l	#10,d0
			mulu.l	#1764,d0
			move.l	d0,vmp_PCM_AudioSize(a5)

			move.l	#1,vmp_Playing(a5)
			
			move.l	#0,vmp_PCM_ActiveBuffer(a5)
			bsr	_DecodeMP3			; Decode first buffer
			bsr	_PlayMP3
			move.l	#4,vmp_PCM_ActiveBuffer(a5)
			bsr	_DecodeMP3			; Decode second buffer
			bsr	_QueueBuffer
			
			; CRITICAL FIX: Enabling DMA instantly fires an interrupt. We must clear this 
			; spurious startup signal so our event loop doesn't instantly double-queue!
			movea.l	4.w,a6
			moveq	#0,d0
			move.l	vmp_InterruptMask(a5),d1
			LVO	SetSignal
			
			moveq	#VMP_STATUS_PLAYING,d0
			bsr	_SetStatus

.done			movem.l	(sp)+,d0-d1/a0-a1/a6
			rts



			;------------------------------------------------------------------------------
			; _InitCustomClass
			;------------------------------------------------------------------------------

_InitCustomClass
			movem.l	d0-d7/a0-a6,-(sp)
			
			suba.l	a0,a0								; a0 = NULL (Library base)
			lea	vmp_AreaClass_Name,a1						; a1 = supername ("Area.mui")
			suba.l	a2,a2								; a2 = NULL (no supermcc)
			moveq	#4,d0								; d0 = InstSize (4 bytes for image pointer)
			lea	_CustomButton_Dispatcher,a3					; a3 = dispatcher
			movea.l	vmp_MUIBase(a5),a6
			jsr	-108(a6)							; _LVOMUI_CreateCustomClass
			move.l	d0,vmp_CustomButtonClass(a5)
			bne.s	.muiOk
			SHOWALERT	vmp_MUIAlert
			bra.w	.cleanup
.muiOk
			lea	vmp_UtilityName,a1
			moveq	#37,d0
			movea.l	4.w,a6
			LVO	OpenLibrary
			move.l	d0,vmp_UtilityBase(a5)
			bne.s	.utilOk
			SHOWALERT	vmp_UtilAlert
			bra.w	.cleanup
.utilOk
			movea.l	vmp_CustomButtonClass(a5),a0
			movea.l	24(a0),a0							; a0 = IClass* (mcc_Class is at offset 24)
			move.l	a5,36(a0)							; Save our vmp struct to cl_UserData (offset 36)!
.cleanup		movem.l	(sp)+,d0-d7/a0-a6
			rts



			;------------------------------------------------------------------------------
			; _CustomButton_Dispatcher
			;------------------------------------------------------------------------------

_CustomButton_Dispatcher
			movem.l	d2-d7/a2-a6,-(sp)					; BOOPSI MUST preserve these!
			
			move.l	vmp_StructPointer,a5					; Get vmp safely, ignoring A0!
			
			move.l	(a1),d0							; a1 = Msg, so (a1) = MethodID
			cmp.l	#$80426f3f,d0						; MUIM_Draw
			beq.w	.draw
			cmp.l	#$80423874,d0						; MUIM_AskMinMax
			beq.w	.askMinMax
			cmp.l	#$00000101,d0						; OM_NEW (0x00000101)
			beq.w	.new
			
			bsr.w	.super							; Pass unhandled methods to superclass and WAIT for return
			bra.w	.exit							; Pop our registers to fix stack corruption!

.new			

			movem.l	a0-a2/a6,-(sp)
			bsr.w	.super
			move.l	d0,d7							; Save object pointer
			movem.l	(sp)+,a0-a2/a6
			
			tst.l	d7
			bne.s	.superOk
			bra.w	.exit							; Failed to create
.superOk
			move.l	a0,-(sp)						; Save Class pointer
			movea.l	d7,a2							; a2 = Object (returned from super)
			movea.l	4(a1),a0						; a0 = Taglist (from Msg in a1)
			
.tagLoop		move.l	(a0)+,d0
			beq.s	.newDone						; TAG_DONE = 0
			cmp.l	#$80010001,d0
			beq.s	.foundTag
			addq.l	#4,a0							; skip ti_Data
			bra.s	.tagLoop
			
.foundTag		move.l	(a0),d0							; Get ti_Data (The image pointer)
			move.l	(sp),a0							; Restore Class pointer
			
			; FIX: Properly fetch cl_InstOffset into D1 before using it!
			moveq	#0,d1
			move.w	32(a0),d1						; cl_InstOffset is a UWORD at offset 32!
			
			lea	(a2,d1.l),a0						; a0 = Instance data pointer (a2 is Object!)
			move.l	d0,(a0)							; Store image pointer

.newDone		addq.l	#4,sp							; Pop saved Class pointer
			move.l	d7,d0							; Return object
			bra.w	.exit

.askMinMax		movem.l	a0-a2/a6,-(sp)
			move.l	a1,-(sp)						; SAVE A1!
			bsr.w	.super							; Let Area.mui fill the struct first!
			move.l	(sp)+,a1						; RESTORE A1!
			movem.l	(sp)+,a0-a2/a6
			
			movea.l	4(a1),a0						; a0 = struct MUI_MinMax *
			
			; Add 32 to all fields to make room for our image
			add.w	#32,0(a0)						; MinWidth
			move.w	0(a0),4(a0)						; MaxWidth = MinWidth
			move.w	0(a0),8(a0)						; DefWidth = MinWidth
			
			add.w	#32,2(a0)						; MinHeight
			move.w	2(a0),6(a0)						; MaxHeight = MinHeight
			move.w	2(a0),10(a0)						; DefHeight = MinHeight
			
			moveq	#0,d0							; Return 0
			bra.w	.exit

.draw			movem.l	a0-a2/a4-a5,-(sp)					; SAVE A4 and A5!
			bsr.w	.super							; Let superclass draw the button frame FIRST
			
			; Get instance data (obj + cl_InstOffset)
			movea.l	vmp_CustomButtonClass(a5),a3			; a3 = MUI_CustomClass*
			movea.l	24(a3),a3					; a3 = mcc_Class (IClass*)
			moveq	#0,d1
			move.w	32(a3),d1					; cl_InstOffset
			lea	(a2,d1.l),a3					; a3 = Instance data (a2 is Object!)
			move.l	(a3),d7						; d7 = Raw Image Pointer
			beq.w	.drawDone					; No image? Don't draw
			
			; Get muiAreaData
			lea	28(a2),a4					; a4 = muiAreaData
			
			; Get _rp(obj) -> muiRenderInfo->mri_RastPort
			movea.l	0(a4),a1					; a1 = mri_RenderInfo
			movea.l	20(a1),a1					; a1 = mri_RastPort (Destination RastPort)
			
			; Get _mleft(obj) -> mad_Box.Left + mad_addleft
			move.w	24(a4),d3					; d3 = mad_Box.Left
			ext.l	d3
			move.b	32(a4),d0					; d0 = mad_addleft
			ext.w	d0
			ext.l	d0
			add.l	d0,d3						; d3 = DestX
			
			; Get _mtop(obj) -> mad_Box.Top + mad_addtop
			move.w	26(a4),d4					; d4 = mad_Box.Top
			ext.l	d4
			move.b	33(a4),d0					; d0 = mad_addtop
			ext.w	d0
			ext.l	d0
			add.l	d0,d4						; d4 = DestY
			
			; Setup WritePixelArray arguments
			movea.l	d7,a0							; Source Image Pointer
			moveq	#0,d0							; SrcX = 0
			moveq	#0,d1							; SrcY = 0
			move.l	#128,d2							; SrcMod = Bytes per row
			moveq	#32,d5							; Width = 32
			moveq	#32,d6							; Height = 32
			moveq	#2,d7							; Format = RECTFMT_ARGB (2)
  
			movem.l	a0-a1/d0-d2,-(sp)
			movea.l	vmp_CyberGfxBase(a5),a6
			jsr	-126(a6)						; _LVOWritePixelArray
			movem.l	(sp)+,a0-a1/d0-d2
			
.drawDone		movem.l	(sp)+,a0-a2/a4-a5
			moveq	#0,d0							; Return 0
			bra.w	.exit

.super			movea.l	vmp_CustomButtonClass(a5),a0				; a0 = MUI_CustomClass*
			movea.l	20(a0),a0						; a0 = mcc_Super (Area.mui IClass*)
			movea.l	vmp_UtilityBase(a5),a6					; a6 = utility.library
			jmp	-102(a6)						; Tail-call _LVOCallHookPkt (-102)!

.exit			movem.l	(sp)+,d2-d7/a2-a6
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
			; _DecodeMP3
			;------------------------------------------------------------
			;

_DecodeMP3		movem.l	d0-d2/a0-a3/a6,-(sp)

			move.l	vmp_PCM_ActiveBuffer(a5),d2
			lea	vmp_PCM_BufferArray,a0
			movea.l	(a0,d2.w),a2				; a2 = Current buffer

			movea.l	a2,a3
			moveq	#7-1,d2					; Decode 7 frames
			
.decodeLoop		movea.l	vmp_MPEGABase(a5),a6
			move.l	vmp_MP3_Stream(a5),a0
			move.l	#vmp_PCM_StreamArray,a1
			LVO	MPEGA_Decode
			tst.l	d0
			bgt	.decoded
			move.l	#0,vmp_Playing(a5)
			move.l	#VMP_STATUS_IDLE,d0
			bsr	_SetStatus
			moveq	#VMP_AUDIOCHANNEL,d0
			bsr	_StopAudio
			bra.s	.exit
    
.decoded		lea	vmp_PCM_Stream1,a0
			lea	vmp_PCM_Stream2,a1

			subq.l	#1,d0
.copyLoop		move.w	(a0)+,(a2)+				; Copying channel 1
			move.w	(a1)+,(a2)+				; Copying channel 2 
    			dbf	d0,.copyLoop
			dbf	d2,.decodeLoop

			suba.l	a3,a2
			lea	vmp_PCM_LengthArray,a0
			move.l	vmp_PCM_ActiveBuffer(a5),d2
			move.l	a2,(a0,d2.w)
			
.exit			movem.l	(sp)+,d0-d2/a0-a3/a6
			rts
			


			;------------------------------------------------------------
			; _PlayMP3
			;------------------------------------------------------------
			;

_PlayMP3		movem.l	d0-d2/a0-a1,-(sp)

			move.l	vmp_PCM_ActiveBuffer(a5),d2
			lea	vmp_PCM_BufferArray,a0
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

			move.l	#1,vmp_Paused
			moveq	#0,d0
			bset	#VMP_AUDIOCHANNEL,d0
			move.w	d0,DMACON					; Stop audio on channel

.exit			movem.l	(sp)+,d0
			rts



			;------------------------------------------------------------
			; _ResumeMP3
			;------------------------------------------------------------
			;

_ResumeMP3		movem.l	d0,-(sp)
			tst.l	vmp_Playing(a5)
			beq.s	.exit							; ignore if audio is stopped

			move.l	#0,vmp_Paused
			move.l	#$8200,d0
			bset	#VMP_AUDIOCHANNEL,d0
			move.w	d0,DMACON					; Stop audio on channel

.exit			movem.l	(sp)+,d0
			rts



			;------------------------------------------------------------
			; _QueueBuffer
			;------------------------------------------------------------
			;

_QueueBuffer		movem.l	d0-d2/a0-a1,-(sp)

			move.l	vmp_PCM_ActiveBuffer(a5),d2
			lea	vmp_PCM_BufferArray,a0
			movea.l	(a0,d2.w),a0				; a0 = Buffer pointer
			lea	vmp_PCM_LengthArray,a1
			move.l	(a1,d2.w),d0
			lsr.l	#3,d0
			
			movea.l	#AUD0L,a1
			moveq	#VMP_AUDIOCHANNEL,d1
			lsl.l	#4,d1
			add.l	d1,a1					; a1 = channel base
			
			move.l	a0,(a1)					; Queue AUDxL
			move.l	d0,4(a1)				; Queue AUDxLEN
			
			movem.l	(sp)+,d0-d2/a0-a1
			rts



			; _PlayAudio
			;--------------------------------------------------------------
			; INPUT:
			;	a0 = Sample/Audio to play (16-bit, 44.1Khz, RAW bigendian format)
			;	d0 = Sample size in bytes
			;	d1 = Channel - Number between 0 and 15
			;	d2 = Volume - Word with left and right volume in each byte. d2=$80ff would pan volume slightly to the right
			
_PlayAudio		movem.l	d0-d3/a0-a1,-(sp)

			move.l	d1,d3						; Save channel in d3

			movea.l	#AUD0L,a1					; Base address of channel 0
			lsl.l	#4,d1						; Muliply channel by 16 to find byte offset
			add.l	d1,a1						; a1 = base of selected channel

			lsr.l	#3,d0						; Divide by 8 to get lenght in pairs of 16 bit samples
			
			move.l	a0,(a1)						; AUDxL 	- Set audio sample
			move.l	d0,$4(a1)					; AUDxLEN 	- Length
			move.w	d2,$8(a1)					; AUDxVOL 	- Volume
			move.w	#80,$c(a1)					; AUDxPER 	- Set 44.1Khz sample rate\
			move.w	#5,$a(a1)					; AUDxCTRL	- Set 16 bit stereo - Play sample in loop
			
			cmp.l	#3,d3
			bgt.s	.highChannel
			move.w	#$8200,d0					; Prepare to set bit 15 and enable DMA
			bset	d3,d0						; Set 0,1,2, or 3 depending on selected channel
			move.w	d0,DMACON					; Start playing
			
			bra.s	.done
			
.highChannel		subq.w	#4,d3						; Channel 4 starts at bit 0
			move.w	#$8000,d0					; Set bit 15
			bset	d3,d0						
			move.w	d0,DMACON2
			move.w	#$8200,DMACON					; DMACON is used to start sound even for higher channels
			
.done			movem.l	(sp)+,d0-d3/a0-a1
			rts



			; _StopAudio
			;--------------------------------------------------------------
			; INPUT:
			;	d0 = Channel - Number between 0 and 15
			
_StopAudio		movem.l	d0-d3/a0-a1,-(sp)

			move.l	d0,d3						; Save channel in d3

			cmp.l	#3,d3
			bgt.s	.highChannel
			moveq	#0,d0						; Clear bit 15
			bset	d3,d0						; Set 0,1,2, or 3 depending on selected channel
			move.w	d0,DMACON					; Stop audio on channel
			
			bra.s	.done
			
.highChannel		subq.w	#4,d3						; Channel 4 starts at bit 0
			moveq	#0,d0						; Clear bit 15
			bset	d3,d0
			move.w	d0,DMACON2					; Stop any audio on this channel
			move.w	#$8200,DMACON					; Do it!

.done			moveq	#50,d1
.waitLoop		tst.b	CIAAPRA
			dbf	d1,.waitLoop					; System needs to wait a bit before new sound can be set on this channel

			movem.l	(sp)+,d0-d3/a0-a1
			rts



			;------------------------------------------------------------
			; _AskFile
			;
			; Input:
			;	a0 = pointer to filename buffer
			; Result:
			;	d0 = FALSE if no file is picked
			;------------------------------------------------------------

_AskFile		movem.l	d1/d5/a0-a3/a6,-(sp)

			moveq	#0,d5
			movea.l	a0,a3						; a3 = buffer

			movea.l	vmp_ASLBase(a5),a6
			move.l	#ASL_FileRequest,d0
			suba.l	a0,a0
			LVO	AllocAslRequest
			movea.l	d0,a2						; a2 = requester
			beq.s	.error
	
			movea.l	a2,a0
			suba.l	a1,a1
			LVO	AslRequest
			move.l	d0,d5
			beq.s	.canceled
			
			; Copy path to buffer
			movea.l	fr_Drawer(a2),a0
			cmp.b	#0,(a0)
			beq.s	.pathDone

.pathLoop		move.b	(a0)+,d0
			move.b	d0,(a3)+
			cmp.b	#0,d0
			bne.s	.pathLoop
			
			; add "/" if applicable
			suba.l	#1,a3
			cmp.b	#":",-1(a3)
			beq.s	.pathDone
			move.b	#"/",(a3)+	

.pathDone		; Copy filename to buffer
			movea.l	fr_File(a2),a0
.fileLoop		move.b	(a0)+,d0
			move.b	d0,(a3)+
			cmp.b	#0,d0
			bne.s	.fileLoop

.canceled		movea.l	a2,a0
			LVO	FreeAslRequest


.error			move.l	d5,d0
			movem.l	(sp)+,d1/d5/a0-a3/a6
			rts




			section data,Data

vmp_MUIName		dc.b	"muimaster.library",0
vmp_UtilityName		dc.b	"utility.library",0
vmp_CyberGfxName	dc.b	"cybergraphics.library",0
vmp_IntuitionName	dc.b	'intuition.library',0
vmp_GraphicsName	dc.b	'graphics.library',0
vmp_ASLName		dc.b	"asl.library",0
vmp_MPEGAName		dc.b	"mpega.library",0
vmp_WindowTitle		dc.b	"VaMP3 v0.1 - Bedroomcoders.com",0
vmp_QuitButtonTitle	dc.b	"Quit",0
vmp_ApplicationTitle	dc.b	"VaMP3",0
vmp_AppBase		dc.b	"VAMP3",0
vmp_MUIButtonSpace	dc.b	"MMM",0

MUIC_Application	dc.b	"Application.mui",0
MUIC_Window		dc.b	"Window.mui",0
MUIC_Group		dc.b	"Group.mui",0
MUIC_Text		dc.b	"Text.mui",0
MUIC_Rectangle		dc.b	"Rectangle.mui",0
MUIC_Image		dc.b	"Image.mui",0
			even

vmp_StructPointer	dc.l	0

vmp_GlobalPointer	dc.l	0						; Global pointer to vmp struct

vmp_Method_Input	dc.l	MUIM_Application_NewInput,vmp_Signals
			dc.l	0

vmp_Signals		ds.l	1							; Referenced from vmp_Method_Input structure


vmp_Method_WindowSetup	dc.l	MUIM_Notify,MUIA_Window_CloseRequest,TRUE
			dc.l	MUIV_Notify_Application,2
			dc.l	MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit

vmp_Method_QuitButton	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
			dc.l	MUIV_Notify_Application,2
			dc.l	MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit

vmp_Method_ButtonOpen	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
			dc.l	MUIV_Notify_Window,2
			dc.l	MUIM_CallHook,vmp_Hook_ButtonOpen

vmp_Hook_ButtonOpen	ds.b	MLN_SIZE
			dc.l	_ButtonOpenPressed					; h_entry - Pointing to routine to be executed
			dc.l	0,0							; h_SubEntry, h_data

vmp_FilenameBuffer	ds.b	256



			; Status messages
			
			even
vmp_StatusTable		dc.l	vmp_StatusIdleTxt,vmp_StatusPlayingTxt,vmp_StatusOpenErrorTxt,vmp_StatusDecodingTxt,0
vmp_StatusIdleTxt	dc.b	"Idle",0
vmp_StatusPlayingTxt	dc.b	"Playing",0
vmp_StatusOpenErrorTxt	dc.b	"Error opening file.",0
vmp_StatusDecodingTxt	dc.b	"Decoding mp3.",0



			; Alert messages

			even			
vmp_MUIAlert		dc.b	"Could not open muimaster.library",0
vmp_UtilAlert		dc.b	"Could not open utility.library",0
vmp_CGXAlert		dc.b	"Could not open cybergraphics.library",0
vmp_ASLAlert		dc.b	"Could not open asl.library",0
vmp_MPEGAAlert		dc.b	"Could not open mpega.library",0
vmp_GUIAlert		dc.b	"Error building GUI",0
vmp_ClassAlert		dc.b	"Failed to create Custom Class!",0
vmp_BtnAlert		dc.b	"Failed to create Button Object!",0
vmp_DispAlert		dc.b	"Dispatcher called!",0
vmp_SuperFailAlert	dc.b	"DoSuperMethodA returned 0!",0
vmp_WDWAlert		dc.b	"Could not extract WindowBase",0
vmp_MEMAlert		dc.b	"Could not allocate memory",0
vmp_AlertTitle		dc.b	"Alert!",0
vmp_AlertOK		dc.b	"OK",0
vmp_EasyStruct		ds.b	es_SIZEOF						; EasyStruct for Requesters



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
vmp_PCM_StreamArray	dc.l	vmp_PCM_Stream1
			dc.l	vmp_PCM_Stream2
			
vmp_PCM_BufferArray	dc.l	vmp_PCM_PlayBuffer1
			dc.l	vmp_PCM_PlayBuffer2

vmp_PCM_LengthArray	dc.l	0,0

vmp_CustomButton_Name	dc.b	"VaMP3CustomButton.mui",0
vmp_AreaClass_Name	dc.b	"Area.mui",0
			cnop	0,4							; SAGA/CyberGfx REQUIRES 32-bit aligned source data!

img_Play_Raw		incbin	"images/Play_32x32.raw"
img_Stop_Raw		incbin	"images/Stop_32x32.raw"
img_Pause_Raw		incbin	"images/Pause_32x32.raw"
img_Next_Raw		incbin	"images/Next_32x32.raw"

			section	bss,bss

vmp_PCM_Stream1		ds.w    VMP_MP3BUFFERSIZE/2
vmp_PCM_Stream2		ds.w    VMP_MP3BUFFERSIZE/2

			cnop	0,4							; 32-bit alignement
vmp_PCM_PlayBuffer1	ds.w	VMP_MP3BUFFERSIZE
vmp_PCM_PlayBuffer2	ds.w	VMP_MP3BUFFERSIZE








