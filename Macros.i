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
			move.l	#txt_AlertTitle,es_Title(a1)
			move.l	#\1,es_TextFormat(a1)
			move.l	#txt_AlertOK,es_GadgetFormat(a1)
			sub.l	a2,a2
			sub.l	a3,a3
			jsr	_LVOEasyRequestArgs(a6)
			movem.l	(sp)+,d0-d1/a0-a3/a6
			ENDM			
			


			; MUI Macros

CREATEMUIBUTTON		MACRO		; \1 = Text	\2 = shortcut (optional)
			lea	MUIC_Text,a0
			INITSTACKTAG
			STACKADRTAG	\1, MUIA_Text_Contents
			STACKVALTAG	MUIV_InputMode_RelVerify, MUIA_InputMode
			STACKVALTAG	MUII_ButtonBack, MUIA_Background
			STACKVALTAG	MUIV_Frame_Button, MUIA_Frame
			IFNC	"\2",""
			STACKVALTAG	\2,MUIA_ControlChar
			ENDC
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			ENDM


CREATEMUIIMAGEBUTTON	MACRO
			lea	MUIC_Image,a0
			INITSTACKTAG
			STACKVALTAG	\1, MUIA_Image_Spec
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

CREATEMUILABEL		MACRO
			lea	MUIC_Text,a0
			INITSTACKTAG
			STACKADRTAG	\1, MUIA_Text_Contents
			STACKVALTAG	0, MUIA_Weight
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			ENDM
			
			
CREATEMUICUSTOMBUTTON	MACRO  ; \1=ImagePtrReg, \2=WidthReg, \3=HeightReg, \4=Shortcut (optional)
			movem.l a6,-(sp)
			INITSTACKTAG
			IFNC	"\4",""
			STACKVALTAG	\4,MUIA_ControlChar
			ENDC

			STACKREGTAG \3, CUSTOMBTN_Height
			STACKREGTAG \2, CUSTOMBTN_Width
			STACKREGTAG \1, CUSTOMBTN_Image
			STACKVALTAG MUIV_InputMode_RelVerify, MUIA_InputMode
			STACKVALTAG MUIV_Frame_Button, MUIA_Frame
			movea.l vmp_CustomButtonClass(a5),a0
			movea.l 24(a0),a0
			suba.l  a1,a1
			movea.l vmp_IntuitionBase(a5),a6
			CALLSTACKTAG _LVONewObjectA,a2
			movem.l (sp)+,a6
			ENDM
			

			
DOMETHOD		MACRO		; \1=Object, \2=MethodID, \3-\9=Args (up to 7 args)
			movem.l	a0-a2/a6,-(sp)
DMCOUNT			SET	4

			IFNC	"\9",""
			move.l	\9,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC
			IFNC	"\8",""
			move.l	\8,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC
			IFNC	"\7",""
			move.l	\7,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC
			IFNC	"\6",""
			move.l	\6,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC
			IFNC	"\5",""
			move.l	\5,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC
			IFNC	"\4",""
			move.l	\4,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC
			IFNC	"\3",""
			move.l	\3,-(sp)
DMCOUNT			SET	DMCOUNT+4
			ENDC

			move.l	\2,-(sp)

			move.l	sp,a1
			movea.l	\1,a2
			movea.l	-4(a2),a0
			movea.l	h_Entry(a0),a6
			jsr	(a6)

			lea	DMCOUNT(sp),sp
			movem.l	(sp)+,a0-a2/a6
			ENDM


	ENDC

