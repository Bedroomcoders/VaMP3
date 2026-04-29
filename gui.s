


			section code,code



			;------------------------------------------------------------
			; _BuildGUI
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 1
			;	Error 	d0 = 1

_BuildGui		movem.l	d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			

			; *** Main Window ***
			CREATEMUIBUTTON	vmp_QuitButtonTitle
			move.l	d0,vmp_MUI_ButtonQuit(a5)				; Create Quit Button
			beq.w	.error

			CREATEMUIBUTTON	vmp_OpenButtonTitle
			move.l	d0,vmp_MUI_ButtonOpen(a5)				; Create Open Button
			beq.w	.error

			CREATEMUICUSTOMBUTTON	img_Stop_Raw
			move.l	d0,vmp_MUI_ButtonStop(a5)				; Create Stop Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Pause_Raw
			move.l	d0,vmp_MUI_ButtonPause(a5)				; Create Pause Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Play_Raw
			move.l	d0,vmp_MUI_ButtonPlay(a5)				; Create Play Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Next_Raw
			move.l	d0,vmp_MUI_ButtonNext(a5)				; Create Next Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Previous_Raw
			move.l	d0,vmp_MUI_ButtonPrevious(a5)				; Create Previous Button
			beq	.error

			CREATEMUITEXT	vmp_StatusIdleTxt
			move.l	d0,vmp_MUI_StatusText(a5)				; Create Status field
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_ButtonQuit(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_ButtonOpen(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_HGroup1(a5)					; Create MUI Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_ButtonNext(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_ButtonStop(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_ButtonPause(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_ButtonPlay(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_ButtonPrevious(a5), MUIA_Group_Child
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
			STACKADRTAG	vmp_MainWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_WINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_WINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_MainWindow(a5)
			beq	.error
			
			; *** Playlist Window ***
			
			


			; *** Build application ***
			lea	MUIC_Application,a0
			INITSTACKTAG
			move.l	vmp_MUI_MainWindow(a5),d0
			STACKREGTAG	d0,MUIA_Application_Window
			STACKADRTAG	vmp_ApplicationTitle, MUIA_Application_Title
			STACKADRTAG	vmp_AppBase, MUIA_Application_Base
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Application
			move.l	d0,vmp_MUI_Application(a5)
			beq.s	.error

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1				; Open our window and draw gadgets

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _CreateHooks
			;------------------------------------------------------------

_CreateHooks		movem.l	a0-a2/a6,-(sp)

			movea.l	vmp_MUI_MainWindow(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_WindowSetup,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set notify on Close button)

			movea.l	vmp_MUI_ButtonPause(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_ButtonPause,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set notify on Pause button)

			movea.l	vmp_MUI_ButtonPlay(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_ButtonPlay,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set notify on Play button)

			movea.l	vmp_MUI_ButtonQuit(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_ButtonQuit,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set notify on Quit button)

			movea.l	vmp_MUI_ButtonOpen(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_ButtonOpen,a1
			movea.l	vmp_UtilityBase(a5),a6
			jsr	-102(a6)						; CallHookPkt (Set hook to run _ButtonOpenPressed)

			movem.l	(sp)+,a0-a2/a6
			rts



			;------------------------------------------------------------
			; _ButtonPressedOpen
			;------------------------------------------------------------

_ButtonPressedOpen	movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.

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
			; _ButtonPressedPlay
			;------------------------------------------------------------

_ButtonPressedPlay	movem.l	a5,-(sp)

			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Strruct in a5.
			bsr	_ResumeMP3

			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _ButtonPressedPause
			;------------------------------------------------------------

_ButtonPressedPause	movem.l	a5,-(sp)

			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.
			bsr	_PauseMP3

			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------------------------
			; _InitCustomClass
			;------------------------------------------------------------------------------

_InitCustomClass
			movem.l	d0-d7/a0-a6,-(sp)
			
			suba.l	a0,a0							; a0 = NULL (Library base)
			lea	MUIC_Area,a1
			suba.l	a2,a2							; a2 = NULL (no supermcc)
			moveq	#4,d0							; d0 = InstSize (4 bytes for image pointer)
			lea	_CustomButton_Dispatcher,a3				; a3 = dispatcher
			movea.l	vmp_MUIBase(a5),a6
			jsr	-108(a6)						; _LVOMUI_CreateCustomClass
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
			movea.l	24(a0),a0						; a0 = IClass* (mcc_Class is at offset 24)
			move.l	a5,36(a0)						; Save our vmp struct to cl_UserData (offset 36)!
.cleanup		movem.l	(sp)+,d0-d7/a0-a6
			rts



			;------------------------------------------------------------------------------
			; _CustomButton_Dispatcher
			;------------------------------------------------------------------------------

_CustomButton_Dispatcher
			movem.l	d2-d7/a2-a6,-(sp)					; BOOPSI MUST preserve these!
			
			move.l	vmp_StructPointer,a5					; Fetch our Struct back into a5
			
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
			movea.l	vmp_CustomButtonClass(a5),a3				; a3 = MUI_CustomClass*
			movea.l	24(a3),a3						; a3 = mcc_Class (IClass*)
			moveq	#0,d1
			move.w	32(a3),d1						; cl_InstOffset
			lea	(a2,d1.l),a3						; a3 = Instance data (a2 is Object!)
			move.l	(a3),d7							; d7 = Raw Image Pointer
			beq.w	.drawDone						; No image? Don't draw
			
			; Get muiAreaData
			lea	28(a2),a4						; a4 = muiAreaData
			
			; Get _rp(obj) -> muiRenderInfo->mri_RastPort
			movea.l	0(a4),a1						; a1 = mri_RenderInfo
			movea.l	20(a1),a1						; a1 = mri_RastPort (Destination RastPort)
			
			; Get _mleft(obj) -> mad_Box.Left + mad_addleft
			move.w	24(a4),d3						; d3 = mad_Box.Left
			ext.l	d3
			move.b	32(a4),d0						; d0 = mad_addleft
			ext.w	d0
			ext.l	d0
			add.l	d0,d3							; d3 = DestX
			
			; Get _mtop(obj) -> mad_Box.Top + mad_addtop
			move.w	26(a4),d4						; d4 = mad_Box.Top
			ext.l	d4
			move.b	33(a4),d0						; d0 = mad_addtop
			ext.w	d0
			ext.l	d0
			add.l	d0,d4							; d4 = DestY
			
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
			; _AskFile
			;
			; Input:
			;	a0 = pointer to filename buffer
			; Result:
			;	d0 = FALSE if no file is picked
			;------------------------------------------------------------

_AskFile		movem.l	d1/d5/a0-a3/a6,-(sp)

			moveq	#0,d5
			movea.l	a0,a3							; a3 = buffer

			movea.l	vmp_ASLBase(a5),a6
			move.l	#ASL_FileRequest,d0
			suba.l	a0,a0
			LVO	AllocAslRequest
			movea.l	d0,a2							; a2 = requester
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


			section data,Data

vmp_MainWindowTitle	dc.b	"VaMP3 v0.11",0
vmp_QuitButtonTitle	dc.b	"Quit",0
vmp_OpenButtonTitle	dc.b	"Open",0
vmp_ApplicationTitle	dc.b	"VaMP3",0
vmp_AppBase		dc.b	"VAMP3",0
vmp_MUIButtonSpace	dc.b	"MMM",0

MUIC_Application	dc.b	"Application.mui",0
MUIC_Window		dc.b	"Window.mui",0
MUIC_Group		dc.b	"Group.mui",0
MUIC_Text		dc.b	"Text.mui",0
MUIC_Rectangle		dc.b	"Rectangle.mui",0
MUIC_Image		dc.b	"Image.mui",0
MUIC_Area		dc.b	"Area.mui",0
vmp_CustomButton_Name	dc.b	"VaMP3CustomButton.mui",0
			even

vmp_Method_Input	dc.l	MUIM_Application_NewInput,vmp_Signals
			dc.l	0

vmp_Signals		ds.l	1							; Referenced from vmp_Method_Input structure


vmp_Method_WindowSetup	dc.l	MUIM_Notify,MUIA_Window_CloseRequest,TRUE
			dc.l	MUIV_Notify_Application,2
			dc.l	MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit

vmp_Method_ButtonQuit	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
			dc.l	MUIV_Notify_Application,2
			dc.l	MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit

vmp_Method_ButtonOpen	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
			dc.l	MUIV_Notify_Window,2
			dc.l	MUIM_CallHook,vmp_Hook_ButtonOpen

vmp_Method_ButtonPlay	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
			dc.l	MUIV_Notify_Window,2
			dc.l	MUIM_CallHook,vmp_Hook_ButtonPlay

vmp_Method_ButtonPause	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
			dc.l	MUIV_Notify_Window,2
			dc.l	MUIM_CallHook,vmp_Hook_ButtonPause

vmp_Hook_ButtonOpen	ds.b	MLN_SIZE
			dc.l	_ButtonPressedOpen					; h_entry - Pointing to routine to be executed
			dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_ButtonPlay	ds.b	MLN_SIZE
			dc.l	_ButtonPressedPlay					; h_entry - Pointing to routine to be executed
			dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_ButtonPause	ds.b	MLN_SIZE
			dc.l	_ButtonPressedPause					; h_entry - Pointing to routine to be executed
			dc.l	0,0							; h_SubEntry, h_data

vmp_FilenameBuffer	ds.b	256



			; Status messages
			
			even
vmp_StatusTable		dc.l	vmp_StatusIdleTxt,vmp_StatusPlayingTxt,vmp_StatusOpenErrorTxt,vmp_StatusDecodingTxt,0
vmp_StatusIdleTxt	dc.b	"Idle",0
vmp_StatusPlayingTxt	dc.b	"Playing",0
vmp_StatusOpenErrorTxt	dc.b	"Error opening file.",0
vmp_StatusDecodingTxt	dc.b	"Decoding mp3.",0



			; Button images
			
			cnop	0,8
img_Play_Raw		incbin	"images/Play_32x32.raw"
img_Stop_Raw		incbin	"images/Stop_32x32.raw"
img_Pause_Raw		incbin	"images/Pause_32x32.raw"
img_Next_Raw		incbin	"images/Next_32x32.raw"
img_Previous_Raw	incbin	"images/Previous_32x32.raw"

