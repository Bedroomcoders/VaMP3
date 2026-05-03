


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
			CREATEMUIBUTTON	vmp_MainWdwPlaylistTitle
			move.l	d0,vmp_MUI_MainWdwButtonPlaylist(a5)			; Create Playlist Button
			beq.w	.error

			CREATEMUIBUTTON	vmp_MainWdwOpenTitle
			move.l	d0,vmp_MUI_MainWdwButtonOpen(a5)			; Create Open Button
			beq.w	.error

			CREATEMUICUSTOMBUTTON	img_Stop_Raw
			move.l	d0,vmp_MUI_MainWdwButtonStop(a5)			; Create Stop Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Pause_Raw
			move.l	d0,vmp_MUI_MainWdwButtonPause(a5)			; Create Pause Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Play_Raw
			move.l	d0,vmp_MUI_MainWdwButtonPlay(a5)			; Create Play Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Next_Raw
			move.l	d0,vmp_MUI_MainWdwButtonNext(a5)			; Create Next Button
			beq	.error

			CREATEMUICUSTOMBUTTON	img_Previous_Raw
			move.l	d0,vmp_MUI_MainWdwButtonPrevious(a5)			; Create Previous Button
			beq	.error

			CREATEMUITEXT	vmp_StatusIdleTxt
			move.l	d0,vmp_MUI_MainWdwStatusText(a5)			; Create Status field
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwButtonPlaylist(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonOpen(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwHGroup1(a5)				; Create MUI Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwButtonNext(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonStop(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonPause(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonPlay(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonPrevious(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwHGroup2(a5)				; Create MUI Horizontal Group 2
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwStatusText(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwHGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwHGroup2(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_MAINWINDOWID,MUIA_Window_ID
			STACKADRTAG	vmp_MainWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_MAINWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_MAINWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_MainWindow(a5)
			beq	.error
			

			; *** Dirlist Window ***
			
			CREATEMUIBUTTON	vmp_DirlistAddFileTitle
			move.l	d0,vmp_MUI_DirlistButtonAddFile(a5)			; Create Add File Button
			beq.w	.error

			CREATEMUIBUTTON	vmp_DirlistAddDirTitle
			move.l	d0,vmp_MUI_DirlistButtonAddDir(a5)			; Create Add Dir Button
			beq.w	.error

			lea	MUIC_Dirlist,a0
			INITSTACKTAG
			STACKADRTAG	vmp_StartDirectory,MUIA_Dirlist_Directory
		;	STACKADRTAG	vmp_FilePattern,MUIA_Dirlist_AcceptPattern
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistDirlist(a5)				; Create MUI Dirlist
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_DirlistButtonAddDir(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_DirlistButtonAddFile(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistHGroup1(a5)				; Create Playlist Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_DirlistHGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_DirlistDirlist(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_DIRLISTWINDOWID,MUIA_Window_ID
			STACKADRTAG	vmp_DirlistWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_DIRLISTWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_DIRLISTWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_DirlistWindow(a5)
			beq	.error



			; *** Playlist Window ***
			
			CREATEMUIBUTTON	vmp_PlaylistAddFileTitle
			move.l	d0,vmp_MUI_PlaylistButtonAddFile(a5)			; Create Add File Button
			beq.w	.error

			CREATEMUIBUTTON	vmp_PlaylistAddDirTitle
			move.l	d0,vmp_MUI_PlaylistButtonAddDir(a5)			; Create Add Dir Button
			beq.w	.error

			lea	MUIC_List,a0
			INITSTACKTAG
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistList(a5)				; Create MUI List
			beq	.error

			lea	MUIC_List,a0
			INITSTACKTAG
			STACKREGTAG	d0, MUIA_Listview_List
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistListview(a5)				; Create MUI Listview
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_PlaylistButtonAddDir(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistButtonAddFile(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistHGroup1(a5)				; Create Playlist Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_PlaylistHGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistListview(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_PLAYLISTWINDOWID,MUIA_Window_ID
			STACKADRTAG	vmp_PlaylistWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_PLAYLISTWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_PLAYLISTWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_PlaylistWindow(a5)
			beq	.error



			; *** Build application ***
			lea	MUIC_Application,a0
			INITSTACKTAG
			move.l	vmp_MUI_MainWindow(a5),d0
			STACKREGTAG	d0,MUIA_Application_Window
			move.l	vmp_MUI_DirlistWindow(a5),d0
			STACKREGTAG	d0,MUIA_Application_Window
			move.l	vmp_MUI_PlaylistWindow(a5),d0
			STACKREGTAG	d0,MUIA_Application_Window
			STACKADRTAG	vmp_ApplicationTitle, MUIA_Application_Title
			STACKADRTAG	vmp_AppBase, MUIA_Application_Base
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Application
			move.l	d0,vmp_MUI_Application(a5)
			beq.s	.error

			; *** Open Main window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1


			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _CreateHooks
			;------------------------------------------------------------

_CreateHooks		movem.l	a0-a2/a6,-(sp)

			; Main window hooks
			movea.l	vmp_MUI_MainWindow(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_MainWdwWindowSetup,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movea.l	vmp_MUI_MainWdwButtonPause(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_MainWdwButtonPause,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movea.l	vmp_MUI_MainWdwButtonPlay(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_MainWdwButtonPlay,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movea.l	vmp_MUI_MainWdwButtonPlaylist(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_MainWdwButtonPlaylist,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movea.l	vmp_MUI_MainWdwButtonOpen(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_MainWdwButtonOpen,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			; Dirlist window hooks
			movea.l	vmp_MUI_DirlistWindow(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_DirlistButtonClose,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movea.l	vmp_MUI_DirlistDirlist(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_DirlistDirlist,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			; Playlist window hooks
			movea.l	vmp_MUI_PlaylistWindow(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_PlaylistButtonClose,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movea.l	vmp_MUI_PlaylistButtonAddFile(a5),a2
			movea.l	-4(a2),a0
			lea	vmp_Method_PlaylistButtonAddFile,a1
			movea.l	vmp_UtilityBase(a5),a6
			LVO	CallHookPkt

			movem.l	(sp)+,a0-a2/a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedOpen
			;------------------------------------------------------------

_MainWdwButtonPressedOpen	movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.

			; *** Open Dirlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1


		;	bsr	_PauseMP3
		;	lea	vmp_FilenameBuffer,a0
		;	bsr	_AskFile
		;	bsr	_ResumeMP3
		;	tst.l	d0
		;	beq.s	.done
						
		;	lea	vmp_FilenameBuffer,a0
		;	bsr	_NewMP3

.done			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPlay
			;------------------------------------------------------------

_MainWdwButtonPressedPlay	movem.l	a5,-(sp)

			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Strruct in a5.
			bsr	_ResumeMP3

			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPause
			;------------------------------------------------------------

_MainWdwButtonPressedPause	movem.l	a5,-(sp)

			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.
			bsr	_PauseMP3

			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPlaylist
			;------------------------------------------------------------

_MainWdwButtonPressedPlaylist	movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our |¾uct in a5.


			; *** Open Playlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _DirlistButtonPressedClose
			;------------------------------------------------------------

_DirlistButtonPressedClose
			movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.

			; *** Close Dirlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _DirlistPressedDirlist
			;------------------------------------------------------------

_DirlistPressedDirlist	movem.l	a0/a5-a6,-(sp)

			; Get item path
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistDirlist(a5),a0
			move.l	#MUIA_Dirlist_Path,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			tst.l	d0
			beq.s	.done

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwStatusText(a5),a0
			INITSTACKTAG
			movea.l		vmp_MUI_TempFilePointer(a5),a1
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1



			; Get FileInfoBlock
			DOMETHOD1	vmp_MUI_DirlistDirlist(a5), #MUIM_List_GetEntry, #MUIV_List_GetEntry_Active
			movea.l	d0,a0
			move.l	fib_DirEntryType(a0),d0
			blt.s	.isFile
			bgt.s	.isDirectory
			bra.s	.done

.isFile
			bsr	_PauseMP3
			movea.l		vmp_MUI_TempFilePointer(a5),a0
			bsr	_NewMP3
			bsr	_ResumeMP3
			bra.s	.done

.isDirectory		movea.l		vmp_MUI_TempFilePointer(a5),a0
			DOMETHOD2	vmp_MUI_DirlistDirlist(a5), #MUIM_Set, #MUIA_Dirlist_Directory, a0

.done			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonPressedClose
			;------------------------------------------------------------

_PlaylistButtonPressedClose
			movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; a5 is not preserved in a hook. Reload our Struct in a5.

			; *** Close Playlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonPressedAddFile
			;------------------------------------------------------------

_PlaylistButtonPressedAddFile
			movem.l	a0/a5-a6,-(sp)
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
			movea.l	vmp_MUI_MainWdwStatusText(a5),a0
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

				; Main window
vmp_MainWindowTitle		dc.b	"VaMP3 v0.11",0
vmp_MainWdwPlaylistTitle	dc.b	"Playlist",0
vmp_MainWdwOpenTitle		dc.b	"Open",0

				; Dirlist window
vmp_DirlistWindowTitle		dc.b	"Directory listing",0
vmp_DirlistAddFileTitle		dc.b	"Add file",0
vmp_DirlistAddDirTitle		dc.b	"Add dirctory",0

vmp_StartDirectory		dc.b	"personal:audio/mp3",0
vmp_FilePattern			dc.b	"#?.mp3",0

				; Playlist window
vmp_PlaylistWindowTitle		dc.b	"Playlist",0
vmp_PlaylistAddFileTitle	dc.b	"Add file",0
vmp_PlaylistAddDirTitle		dc.b	"Add dirctory",0

				; Application
vmp_ApplicationTitle		dc.b	"VaMP3",0
vmp_AppBase			dc.b	"VAMP3",0
vmp_MUIButtonSpace		dc.b	"MMM",0

MUIC_Application		dc.b	"Application.mui",0
MUIC_Window			dc.b	"Window.mui",0
MUIC_Group			dc.b	"Group.mui",0
MUIC_Text			dc.b	"Text.mui",0
MUIC_List			dc.b	"List.mui",0
MUIC_Listview			dc.b	"Listview.mui",0
MUIC_Dirlist			dc.b	"Dirlist.mui",0
MUIC_Area			dc.b	"Area.mui",0
vmp_CustomButton_Name		dc.b	"VaMP3CustomButton.mui",0
				even

vmp_Method_Input		dc.l	MUIM_Application_NewInput,vmp_Signals
				dc.l	0

vmp_Signals			ds.l	1							; Referenced from vmp_Method_Input structure

				; Main window methods
vmp_Method_MainWdwWindowSetup	dc.l	MUIM_Notify,MUIA_Window_CloseRequest,TRUE
				dc.l	MUIV_Notify_Application,2
				dc.l	MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit

vmp_Method_MainWdwButtonOpen	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
				dc.l	MUIV_Notify_Window,2
				dc.l	MUIM_CallHook,vmp_Hook_MainWdwButtonOpen

vmp_Method_MainWdwButtonPlay	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
				dc.l	MUIV_Notify_Window,2
				dc.l	MUIM_CallHook,vmp_Hook_MainWdwButtonPlay

vmp_Method_MainWdwButtonPause	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
				dc.l	MUIV_Notify_Window,2
				dc.l	MUIM_CallHook,vmp_Hook_MainWdwButtonPause

vmp_Method_MainWdwButtonPlaylist	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
				dc.l	MUIV_Notify_Window,2
				dc.l	MUIM_CallHook,vmp_Hook_MainWdwButtonPlaylist

				; Main windows hooks
vmp_Hook_MainWdwButtonOpen	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedOpen				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPlay	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPlay				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPause	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPause				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPlaylist	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPlaylist				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

				; Dirlist window methods
vmp_Method_DirlistButtonClose	dc.l	MUIM_Notify,MUIA_Window_CloseRequest,TRUE
				dc.l	MUIV_Notify_Application,2
				dc.l	MUIM_CallHook,vmp_Hook_DirlistButtonClose

vmp_Method_DirlistDirlist	dc.l	MUIM_Notify,MUIA_Listview_DoubleClick,TRUE
				dc.l	MUIV_Notify_Window,2
				dc.l	MUIM_CallHook,vmp_Hook_DirlistDirlist

				; Dirlist window hooks
vmp_Hook_DirlistButtonClose	ds.b	MLN_SIZE
				dc.l	_DirlistButtonPressedClose
				dc.l	0,0

vmp_Hook_DirlistDirlist		ds.b	MLN_SIZE
				dc.l	_DirlistPressedDirlist
				dc.l	0,0


				; Playlist window methods
vmp_Method_PlaylistButtonClose	dc.l	MUIM_Notify,MUIA_Window_CloseRequest,TRUE
				dc.l	MUIV_Notify_Application,2
				dc.l	MUIM_CallHook,vmp_Hook_PlaylistButtonClose

vmp_Method_PlaylistButtonAddFile	dc.l	MUIM_Notify,MUIA_Pressed,FALSE
				dc.l	MUIV_Notify_Window,2
				dc.l	MUIM_CallHook,vmp_Hook_PlaylistButtonAddFile

				; Playlist window hooks
vmp_Hook_PlaylistButtonClose	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonPressedClose
				dc.l	0,0
				
vmp_Hook_PlaylistButtonAddFile	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonPressedAddFile
				dc.l	0,0


vmp_FilenameBuffer		ds.b	256


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

