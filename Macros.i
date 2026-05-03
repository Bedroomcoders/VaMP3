	IFND	MACROS_I
MACROS_I SET	1

	IFND	UTILITY_TAGITEM_I
	include	"utility/tagitem.i"
	ENDC


			;------------------------------------------------------------
			; Stack Macros
			; Usage:
			;	- Start with INITSTACKTAG
			;	- Any number of STACKVALTAG, STACKREGTAG, and STACKADRTAG
			;	- Call funtion with CALLSTACKTAG
			;------------------------------------------------------------


INITSTACKTAG		MACRO						; No input or offset
			IFC	"\1",""
			pea	FALSE.w
			pea	TAG_DONE.w
STACKCOUNT		SET	8
			ENDC
			IFNC	"\1",""
STACKCOUNT		SET	\1
			ENDC
			ENDM

CALLSTACKTAG		MACRO						; Function, adress register
			movea.l	sp,\2					; Example: CALLSTACKTAG _LVOOpenWindowTaglist,a1
			jsr	\1(a6)
			lea	STACKCOUNT(sp),sp
			ENDM

STACKVALTAG		MACRO						; Value, ti_tag
			pea	\1
STACKCOUNT		SET	STACKCOUNT+8
			pea	\2
			ENDM

STACKREGTAG		MACRO						; Register,ti_tag
			move.l	\1,-(sp)
STACKCOUNT		SET	STACKCOUNT+8
			pea	\2
			ENDM

STACKADRTAG		MACRO						; Address,ti_tag
			pea	\1
STACKCOUNT		SET	STACKCOUNT+8
			pea	\2
			ENDM


	
			; LVO Macro
LVO			MACRO
			jsr	_LVO\1(a6)
			ENDM

			; LIBRARY Macros
OPENLIB			MACRO
			movea.l	4.w,a6
			lea	vmp_\1Name,a1
			moveq	#\2,d0
			jsr	_LVOOpenLibrary(a6)
			move.l	d0,vmp_\1Base(a5)
			ENDM


CLOSELIB		MACRO
			movea.l	4.w,a6
			move.l	vmp_\1Base(a5),d0
			movea.l	d0,a1
			beq.s	.dontClose\1
			jsr	_LVOCloseLibrary(a6)
.dontClose\1

			ENDM



			; ALERT Macro
SHOWALERT		MACRO
			movem.l	d0-d1/a0-a3/a6,-(sp)
			movea.l	vmp_IntuitionBase(a5),a6
			suba.l	a0,a0
			lea	vmp_EasyStruct,a1
			move.l	#es_SIZEOF,es_StructSize(a1)
			clr.l	es_Flags(a1)
			move.l	#vmp_AlertTitle,es_Title(a1)
			move.l	#\1,es_TextFormat(a1)
			move.l	#vmp_AlertOK,es_GadgetFormat(a1)
			sub.l	a2,a2
			sub.l	a3,a3
			jsr	_LVOEasyRequestArgs(a6)
			movem.l	(sp)+,d0-d1/a0-a3/a6
			ENDM			
			



			; MUI Macros

CREATEMUIBUTTON		MACRO
			lea	MUIC_Text,a0
			INITSTACKTAG
			STACKADRTAG	\1, MUIA_Text_Contents
			STACKVALTAG	MUIV_InputMode_RelVerify, MUIA_InputMode
			STACKVALTAG	MUII_ButtonBack, MUIA_Background
			STACKVALTAG	MUIV_Frame_Button, MUIA_Frame
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			ENDM

CREATEMUITEXT		MACRO
			lea	MUIC_Text,a0
			INITSTACKTAG
			STACKADRTAG	\1, MUIA_Text_Contents
			STACKVALTAG	MUII_ButtonBack, MUIA_Background
			STACKVALTAG	MUIV_Frame_Text, MUIA_Frame
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			ENDM
			
			
		
			; ------------------------------------------------------------------------------
			; CREATEMUICUSTOMBUTTON
			;   Creates a 32x32 button using your new custom class!
			;   \1 : Raw Image Pointer (e.g. img_Play_Raw)
			; ------------------------------------------------------------------------------
CREATEMUICUSTOMBUTTON	MACRO
			movem.l	a6,-(sp)
			INITSTACKTAG
			STACKADRTAG	\1,$80010001
			STACKVALTAG	MUIV_InputMode_RelVerify,MUIA_InputMode
			STACKVALTAG	MUIV_Frame_Button,MUIA_Frame
			STACKVALTAG	32,MUIA_FixWidth
			STACKVALTAG	32,MUIA_FixHeight
			movea.l	vmp_CustomButtonClass(a5),a0
			movea.l	24(a0),a0					; a0 = IClass* (mcc_Class is at offset 24)
			suba.l	a1,a1						; a1 = NULL (No ClassID string)
			movea.l	vmp_IntuitionBase(a5),a6
			CALLSTACKTAG	_LVONewObjectA,a2			; _LVONewObjectA
			movem.l	(sp)+,a6
			ENDM
			
			
			;------------------------------------------------------------
			; DoMethod Macros
			; Usage: DOMETHODx Object, MethodID, Arg1, Arg2...
			; Example: 
			;    DOMETHOD2 vmp_MUI_PlaylistList(a5), #MUIM_List_InsertSingle, a0, #-1
			; Note: Use # for constants/addresses, or just the register name!
			;------------------------------------------------------------

DOMETHOD0		MACRO						; \1=Object, \2=MethodID
			movem.l	a0-a2/a6,-(sp)
			move.l	\2,-(sp)				; Push MethodID
			
			move.l	sp,a1					; a1 = Msg array
			movea.l	\1,a2					; a2 = Object
			movea.l	-4(a2),a0				; a0 = Hook
			movea.l	12(a0),a6				; a6 = Dispatcher
			jsr	(a6)					; Call Dispatcher
			
			addq.l	#4,sp					; Cleanup stack (1 long)
			movem.l	(sp)+,a0-a2/a6
			ENDM

DOMETHOD1		MACRO						; \1=Object, \2=MethodID, \3=Arg1
			movem.l	a0-a2/a6,-(sp)
			move.l	\3,-(sp)				; Push Arg1
			move.l	\2,-(sp)				; Push MethodID
			
			move.l	sp,a1					; a1 = Msg array
			movea.l	\1,a2					; a2 = Object
			movea.l	-4(a2),a0				; a0 = Hook
			movea.l	12(a0),a6				; a6 = Dispatcher
			jsr	(a6)					; Call Dispatcher
			
			addq.l	#8,sp					; Cleanup stack (2 longs)
			movem.l	(sp)+,a0-a2/a6
			ENDM

DOMETHOD2		MACRO						; \1=Object, \2=MethodID, \3=Arg1, \4=Arg2
			movem.l	a0-a2/a6,-(sp)
			move.l	\4,-(sp)				; Push Arg2
			move.l	\3,-(sp)				; Push Arg1
			move.l	\2,-(sp)				; Push MethodID
			
			move.l	sp,a1					; a1 = Msg array
			movea.l	\1,a2					; a2 = Object
			movea.l	-4(a2),a0				; a0 = Hook
			movea.l	12(a0),a6				; a6 = Dispatcher
			jsr	(a6)					; Call Dispatcher
			
			lea	12(sp),sp				; Cleanup stack (3 longs)
			movem.l	(sp)+,a0-a2/a6
			ENDM
			
	ENDC

