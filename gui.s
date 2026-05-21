


			section code,code



			;------------------------------------------------------------
			; _BuildGUI
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildGui		movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
			bsr	_BuildMainWindow
			bne.w	.error

			bsr	_BuildDirlistWindow
			bne.w	.error

			bsr	_BuildPlaylistWindow
			bne.w	.error

			bsr	_BuildMenu
			bne.w	.error


			; *** Build application ***
			lea	MUIC_Application,a0
			INITSTACKTAG

			STACKREGTAG	vmp_MUI_MainWindow(a5),MUIA_Application_Window
			STACKREGTAG	vmp_MUI_DirlistWindow(a5),MUIA_Application_Window
			STACKREGTAG	vmp_MUI_PlaylistWindow(a5),MUIA_Application_Window
			STACKREGTAG	vmp_MUI_Menustrip(a5),MUIA_Application_Menustrip
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
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildMainWindow
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildMainWindow	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
			CREATEMUIBUTTON	vmp_MainWdwPlaylistTitle
			move.l	d0,vmp_MUI_MainWdwButtonPlaylist(a5)			; Create Playlist Button
			beq.w	.error

			CREATEMUIBUTTON	vmp_MainWdwDirlistTitle
			move.l	d0,vmp_MUI_MainWdwButtonDirlist(a5)			; Create Dirlist Button
			beq.w	.error

			move.l	vmp_ImgBuffer_Stop(a5),d0
			move.l	vmp_ImgWidth_Stop(a5),d1
			move.l	vmp_ImgHeight_Stop(a5),d2
			CREATEMUICUSTOMBUTTON_DYN	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonStop(a5)			; Create Stop Button
			beq	.error

			move.l	vmp_ImgBuffer_Pause(a5),d0
			move.l	vmp_ImgWidth_Pause(a5),d1
			move.l	vmp_ImgHeight_Pause(a5),d2
			CREATEMUICUSTOMBUTTON_DYN	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonPause(a5)			; Create Pause Button
			beq	.error

			move.l	vmp_ImgBuffer_Play(a5),d0
			move.l	vmp_ImgWidth_Play(a5),d1
			move.l	vmp_ImgHeight_Play(a5),d2
			CREATEMUICUSTOMBUTTON_DYN	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonPlay(a5)			; Create Play Button
			beq	.error


			move.l	vmp_ImgBuffer_Next(a5),d0
			move.l	vmp_ImgWidth_Next(a5),d1
			move.l	vmp_ImgHeight_Next(a5),d2
			CREATEMUICUSTOMBUTTON_DYN	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonNext(a5)			; Create Next Button
			beq	.error

			move.l	vmp_ImgBuffer_Prev(a5),d0
			move.l	vmp_ImgWidth_Prev(a5),d1
			move.l	vmp_ImgHeight_Prev(a5),d2
			CREATEMUICUSTOMBUTTON_DYN	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonPrevious(a5)			; Create Previous Button
			beq	.error

			CREATEMUITEXT	vmp_StatusIdleTxt
			move.l	d0,vmp_MUI_MainWdwStatusText(a5)			; Create Status field
			beq	.error

			lea	MUIC_Slider,a0
			INITSTACKTAG
			STACKVALTAG	VMP_AUDIO_VOLUME,MUIA_Numeric_Default
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwSliderVolume(a5)				; Create Volume slider
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwSliderVolume(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonPlaylist(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonDirlist(a5), MUIA_Group_Child
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
			STACKVALTAG	TRUE, MUIA_Window_AppWindow
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_MainWindow(a5)
			beq	.error

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildDirlistWindow
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildDirlistWindow	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
			CREATEMUIBUTTON	vmp_DirlistAddToPLTitle
			move.l	d0,vmp_MUI_DirlistButtonAddToPL(a5)			; Create Add to Playlist Button
			beq.w	.error

			movea.l	vmp_DosBase(a5),a6
			move.l	#vmp_FilePattern,d1
			move.l	#vmp_FilePatternToken,d2
			moveq	#32,d3
			LVO	ParsePatternNoCase
			
			movea.l	vmp_MUIBase(a5),a6
			lea	MUIC_Dirlist,a0
			INITSTACKTAG
		;	STACKADRTAG	vmp_StartDirectory,MUIA_Dirlist_Directory
			STACKADRTAG	vmp_FilePatternToken,MUIA_Dirlist_AcceptPattern
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistList(a5)				; Create MUI Dirlist
			beq	.error

			lea	MUIC_Listview,a0
			INITSTACKTAG
			STACKREGTAG	d0, MUIA_Listview_List
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistListview(a5)				; Create MUI Listview
			beq	.error

			lea	MUIC_String,a0
			INITSTACKTAG
			STACKVALTAG	13, MUIA_Frame
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistDirString(a5)				; Create MUI String
			beq	.error

			CREATEMUIIMAGEBUTTON MUII_PopDrawer				; Create Drawer button
			move.l	d0,vmp_MUI_DirlistPopDrawer(a5)
			beq.w	.error

			lea	MUIC_Popasl,a0
			INITSTACKTAG
			STACKVALTAG	ASL_FileRequest, MUIA_Popasl_Type
			STACKVALTAG	TRUE, ASLFR_DrawersOnly
			STACKREGTAG	vmp_MUI_DirlistDirString(a5), MUIA_Popstring_String
			STACKREGTAG	vmp_MUI_DirlistPopDrawer(a5), MUIA_Popstring_Button
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistPopasl(a5)				; Create MUI Popup ASL requester
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_DirlistButtonAddToPL(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_DirlistHGroup1(a5)				; Create Playlist Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_DirlistHGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_DirlistListview(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_DirlistPopasl(a5), MUIA_Group_Child
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

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildPlaylistWindow
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildPlaylistWindow	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
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

			lea	MUIC_Listview,a0
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

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildMenu
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildMenu		movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
			; File menu
			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_FileLoadPL, MUIA_Menuitem_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MenuFileLoadPL(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_FileSavePL, MUIA_Menuitem_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MenuFileSavePL(a5)
			beq	.error

			lea	MUIC_Menu,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuFileSavePL(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuFileLoadPL(a5),MUIA_Family_Child
			STACKADRTAG	txt_Menu_File, MUIA_Menu_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MenuFile(a5)
			beq	.error

			; Settings menu
			
			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_SettingsPrefs, MUIA_Menuitem_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MenuSettingsPrefs(a5)
			beq	.error

			lea	MUIC_Menu,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuSettingsPrefs(a5),MUIA_Family_Child
			STACKADRTAG	txt_Menu_Settings, MUIA_Menu_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MenuSettings(a5)
			beq	.error

			lea	MUIC_Menustrip,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuSettings(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuFile(a5),MUIA_Family_Child
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_Menustrip(a5)
			beq	.error



			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _CreateHooks
			;------------------------------------------------------------

_CreateHooks		movem.l	a0-a2/a6,-(sp)

			; Main window hooks
			DOMETHOD vmp_MUI_MainWindow(a5), #MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_Application_ReturnID, #MUIV_Application_ReturnID_Quit
			DOMETHOD vmp_MUI_MainWindow(a5), #MUIM_Notify, #MUIA_AppMessage, #MUIV_EveryTime, #MUIV_Notify_Self, #3, #MUIM_CallHook, #vmp_Hook_MainWdwAppMessage, #MUIV_TriggerValue
		 	DOMETHOD vmp_MUI_MainWdwButtonDirlist(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonDirlist
 			DOMETHOD vmp_MUI_MainWdwButtonPlaylist(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPlaylist
 			DOMETHOD vmp_MUI_MainWdwButtonPause(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPause
 			DOMETHOD vmp_MUI_MainWdwButtonPlay(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPlay
 			DOMETHOD vmp_MUI_MainWdwButtonNext(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonNext
 			DOMETHOD vmp_MUI_MainWdwButtonPrevious(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPrevious
			DOMETHOD vmp_MUI_MainWdwSliderVolume(a5), #MUIM_Notify, #MUIA_Numeric_Value, #MUIV_EveryTime, #MUIV_Notify_Window, #3, #MUIM_CallHook, #vmp_Hook_MainWdwSliderVolume, #MUIV_TriggerValue


			; Dirlist window methods
			DOMETHOD vmp_MUI_DirlistWindow(a5), #MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_CallHook, #vmp_Hook_DirlistButtonClose
			DOMETHOD vmp_MUI_DirlistListview(a5), #MUIM_Notify, #MUIA_Listview_DoubleClick, #TRUE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_DirlistListview
			DOMETHOD vmp_MUI_DirlistList(a5), #MUIM_Notify, #MUIA_Dirlist_Directory, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_DirlistDirChanged

			DOMETHOD7	vmp_MUI_DirlistDirString(a5), #MUIM_Notify, #MUIA_String_Acknowledge, #MUIV_EveryTime, vmp_MUI_DirlistListview(a5), #3, #MUIM_Set, #MUIA_Dirlist_Directory, #MUIV_TriggerValue

			; Playlist window methods
			DOMETHOD vmp_MUI_PlaylistWindow(a5),#MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonClose
			DOMETHOD vmp_MUI_PlaylistButtonAddFile(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonAddFile

			movem.l	(sp)+,a0-a2/a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedDirlist
			;------------------------------------------------------------

_MainWdwButtonPressedDirlist
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Open Dirlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1


.done			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPlay
			;------------------------------------------------------------

_MainWdwButtonPressedPlay
			movem.l	a5,-(sp)
			movea.l	vmp_StructPointer,a5

			bsr	_ResumeMP3

			moveq	#0,d0
			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPause
			;------------------------------------------------------------

_MainWdwButtonPressedPause
			movem.l	a5,-(sp)
			movea.l	vmp_StructPointer,a5

			bsr	_PauseMP3

			moveq	#0,d0
			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedNext
			;------------------------------------------------------------

_MainWdwButtonPressedNext
			movem.l	d2-d3/a3-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; Reload our Struct in a5

			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			beq.s	.dirlist
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			beq.s	.playlist
			bra.w	.done

.dirlist		movea.l	vmp_MUI_DirlistListview(a5),a4
			lea	_DirlistPressedDirlist,a3
			bra.s	.findNext

.playlist		movea.l	vmp_MUI_PlaylistList(a5),a4
			; lea	_PlaylistPressedPlaylist,a3				; TODO: Create this routine!
			bra.w	.done

.findNext		move.l	vmp_PlayingIndex(a5),d2

.loopNext		addq.l	#1,d2							; Check next index

			; Get entry at index d2
			lea	vmp_TempVariable(a5),a1
			DOMETHOD2 a4, #MUIM_List_GetEntry, d2, a1
			move.l	vmp_TempVariable(a5),a0
			tst.l	a0
			beq.w	.done							; End of list (GetEntry returns NULL)

			; If playing from Dirlist, we must skip directories!
			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			bne.s	.play

			move.l	fib_DirEntryType(a0),d0
			bgt.s	.loopNext						; It is a directory! Keep moving down!

.play			; We found the file (or we are in Playlist)! Set it as active!
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a4,a0
			INITSTACKTAG
			STACKREGTAG	d2, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1

			jsr	(a3)							; Call the right playback routine (in a3)

.done			moveq	#0,d0
			movem.l	(sp)+,d2-d3/a3-a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPrevious
			;------------------------------------------------------------

_MainWdwButtonPressedPrevious
			movem.l	d2-d3/a3-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; Reload our Struct in a5

			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			beq.s	.dirlist
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			beq.s	.playlist
			bra.w	.done

.dirlist		movea.l	vmp_MUI_DirlistListview(a5),a4
			lea	_DirlistPressedDirlist,a3
			bra.s	.findPrev

.playlist		movea.l	vmp_MUI_PlaylistList(a5),a4
			; lea	_PlaylistPressedPlaylist,a3				; TODO: Create this routine!
			bra.w	.done

.findPrev		move.l	vmp_PlayingIndex(a5),d2

.loopPrev		subq.l	#1,d2							; Check previous index
			bmi.w	.done							; We hit the top, just stop

			; Get entry at index d2
			lea	vmp_TempVariable(a5),a1
			DOMETHOD2 a4, #MUIM_List_GetEntry, d2, a1
			move.l	vmp_TempVariable(a5),a0
			tst.l	a0
			beq.w	.done							; Failsafe (GetEntry returns NULL)

			; If playing from Dirlist, we must skip directories!
			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			bne.s	.play

			movea.l	d0,a0
			move.l	fib_DirEntryType(a0),d0
			bgt.s	.loopPrev						; It is a directory! Keep moving up!

.play			; We found the file (or we are in Playlist)! Set it as active!
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a4,a0
			INITSTACKTAG
			STACKREGTAG	d2, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1

			jsr	(a3)							; Call the right playback routine (in a3)
.done			moveq	#0,d0
			movem.l	(sp)+,d2-d3/a3-a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPressedPlaylist
			;------------------------------------------------------------

_MainWdwButtonPressedPlaylist
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Open Playlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _MainSliderVolumeChanged
			;------------------------------------------------------------

_MainWdwSliderVolumeChanged
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			move.l	(a1),d1						; Volume slider value

			move.l	#VMP_AUDIO_CHANNEL,d0
			bsr	_SetVolume

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _MainWdwGotAppMessage
			;------------------------------------------------------------

_MainWdwGotAppMessage	movem.l	d1-d3/a0-a2/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			movea.l	(a1),a1						; a1 = AppMessage
			
			tst.l	a1
			beq.s	.done

			tst.l	am_NumArgs(a1)
			beq.s	.done
			
			movea.l	am_ArgList(a1),a2				; a2 = First WBArg

			movea.l	vmp_DosBase(a5),a6
			move.l	wa_Lock(a2),d1
			move.l	#vmp_FilenameBuffer,d2
			move.l	#255,d3
			LVO	NameFromLock
			tst.l	d0
			beq.s	.done
			
			move.l	#vmp_FilenameBuffer,d1
			move.l	wa_Name(a2),d2
			move.l	#255,d3
			LVO	AddPart
			tst.l	d0
			beq.s	.done
			
			bsr	_PauseMP3

			lea	vmp_FilenameBuffer,a0
			bsr	_NewMP3
			tst.l	d0
			beq.s	.done
			
			bsr	_ResumeMP3
			
.done			moveq	#0,d0
			movem.l	(sp)+,d1-d3/a0-a2/a5-a6
			rts



			;------------------------------------------------------------
			; _DirlistButtonPressedClose
			;------------------------------------------------------------

_DirlistButtonPressedClose
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Close Dirlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _DirlistPressedDirlist
			;------------------------------------------------------------

_DirlistPressedDirlist	movem.l	a0-a1/a5-a6,-(sp)

			; Get item path
			movea.l	vmp_StructPointer,a5
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistListview(a5),a0
			move.l	#MUIA_Dirlist_Path,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			tst.l	d0
			beq.s	.done

			movea.l	vmp_MUI_MainWdwStatusText(a5),a0
			INITSTACKTAG
			movea.l		vmp_MUI_TempFilePointer(a5),a1
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1



			; Get FileInfoBlock

			lea	vmp_TempVariable(a5),a1
			DOMETHOD2	vmp_MUI_DirlistListview(a5), #MUIM_List_GetEntry, #MUIV_List_GetEntry_Active, a1
			move.l	vmp_TempVariable(a5),a0
			
			move.l	fib_DirEntryType(a0),d0
			blt.s	.isFile
			bgt.s	.isDirectory
			bra.s	.done

.isFile			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistListview(a5),a0
			move.l	#MUIA_List_Active,d0
			lea	vmp_PlayingIndex(a5),a1
			LVO	GetAttr

			move.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			bsr	_PauseMP3
			movea.l		vmp_MUI_TempFilePointer(a5),a0
			bsr	_NewMP3
			bsr	_ResumeMP3
			bra.s	.done

.isDirectory		movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistListview(a5),a0
			INITSTACKTAG
			movea.l	vmp_MUI_TempFilePointer(a5),a1
			STACKREGTAG	a1, MUIA_Dirlist_Directory
			CALLSTACKTAG	_LVOSetAttrsA,a1

			movea.l	vmp_MUI_DirlistDirString(a5),a0
			INITSTACKTAG
			movea.l		vmp_MUI_TempFilePointer(a5),a1
			STACKREGTAG	a1, MUIA_String_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _DirlistDirChanged
			;------------------------------------------------------------

_DirlistDirChanged	movem.l	a5,-(sp)
			movea.l	vmp_StructPointer,a5

			move.l	#-1,vmp_PlayingIndex(a5)

			moveq	#0,d0
			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _PlaylistButtonPressedClose
			;------------------------------------------------------------

_PlaylistButtonPressedClose
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Close Playlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonPressedAddFile
			;------------------------------------------------------------

_PlaylistButtonPressedAddFile
			movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			bsr	_PauseMP3
			lea	vmp_FilenameBuffer,a0
			bsr	_AskFile
			bsr	_ResumeMP3
			tst.l	d0
			beq.s	.done
						
			lea	vmp_FilenameBuffer,a0
			bsr	_NewMP3

.done			moveq	#0,d0
			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _InitCustomClass
			;------------------------------------------------------------

_InitCustomClass	movem.l d0-d7/a0-a6,-(sp)

			suba.l	a0,a0
			lea	MUIC_Area,a1
			suba.l	a2,a2
			moveq	#12,d0						; InstSize = 12 bytes (ptr + w + h)
			lea	_CustomButton_Dispatcher,a3
			movea.l	vmp_MUIBase(a5),a6
			jsr	-108(a6)
			move.l	d0,vmp_CustomButtonClass(a5)
			bne.s	.muiOk
			SHOWALERT	vmp_ClassAlert
			bra.s	.cleanup
.muiOk
			movea.l	vmp_CustomButtonClass(a5),a0
			movea.l	24(a0),a0
			move.l	a5,36(a0)
.cleanup		movem.l	(sp)+,d0-d7/a0-a6
			rts


			;------------------------------------------------------------
			; _CustomButton_Dispatcher
			;------------------------------------------------------------

_CustomButton_Dispatcher
			movem.l	d2-d7/a2-a6,-(sp)
            
			move.l	vmp_StructPointer,a5

			move.l	(a1),d0
			cmp.l	#$80426f3f,d0					; MUIM_Draw
			beq.w	.draw
			cmp.l	#$80423874,d0					; MUIM_AskMinMax
			beq.w	.askMinMax
			cmp.l	#$00000101,d0					; OM_NEW
			beq.s	.new
            
			bsr.w	.super
			bra.w	.exit

.new			movem.l	a0-a2/a6,-(sp)
			bsr.w	.super
			move.l	d0,d7
			movem.l	(sp)+,a0-a2/a6

			tst.l	d7
			beq.w	.exit

			move.l	a0,-(sp)					; Save Class pointer
			movea.l	d7,a2						; a2 = Object

			; Get instance data pointer
			move.l	(sp),a0						; Class pointer
			moveq	#0,d1
			move.w	32(a0),d1					; cl_InstOffset
			lea	(a2,d1.l),a3					; a3 = Instance data

			; Set defaults
			move.l	#0,(a3)						; image ptr = NULL
			move.l	#32,4(a3)					; default width = 32
			move.l	#32,8(a3)					; default height = 32

			; Walk taglist
			movea.l	4(a1),a0					; a0 = Taglist
.tagLoop		move.l	(a0)+,d0
			beq.s	.newDone					; TAG_DONE

			cmp.l	#CUSTOMBTN_Image,d0
			beq.s	.storeImage
			cmp.l	#CUSTOMBTN_Width,d0
			beq.s	.storeWidth
			cmp.l	#CUSTOMBTN_Height,d0
			beq.s	.storeHeight
			addq.l	#4,a0
			bra.s	.tagLoop

.storeImage		move.l	(a0)+,d0
			move.l	d0,(a3)						; Save image ptr
			bra.s	.tagLoop
.storeWidth		move.l	(a0)+,d0
			move.l	d0,4(a3)					; Save width
			bra.s	.tagLoop
.storeHeight		move.l	(a0)+,d0
			move.l	d0,8(a3)					; Save height
			bra.s	.tagLoop

.newDone		addq.l	#4,sp
			move.l	d7,d0
			bra.w	.exit

.askMinMax		movem.l	a0-a2/a6,-(sp)
			move.l	a1,-(sp)
			bsr.w	.super
			move.l	(sp)+,a1
			movem.l	(sp)+,a0-a2/a6

			; Fetch instance data
			movea.l	vmp_CustomButtonClass(a5),a3
			movea.l	24(a3),a3
			moveq	#0,d1
			move.w	32(a3),d1
			lea	(a2,d1.l),a3					; a3 = instance data
			move.l	4(a3),d5					; d5 = width
			move.l	8(a3),d6					; d6 = height

			movea.l	4(a1),a0					; a0 = MUI_MinMax *

			add.w	d5,0(a0)					; MinWidth
			move.w	0(a0),4(a0)					; MaxWidth
			move.w	0(a0),8(a0)					; DefWidth

			add.w	d6,2(a0)					; MinHeight
			move.w	2(a0),6(a0)					; MaxHeight
			move.w	2(a0),10(a0)					; DefHeight

			moveq	#0,d0
			bra.w	.exit

.draw			movem.l	a0-a2/a4-a5,-(sp)
			bsr.w	.super

			; Fetch instance data
			movea.l	vmp_CustomButtonClass(a5),a3
			movea.l	24(a3),a3
			moveq	#0,d1
			move.w	32(a3),d1
			lea	(a2,d1.l),a3					; a3 = instance data
			move.l	(a3),d7						; d7 = image ptr
			beq.w	.drawDone
			move.l	4(a3),d5					; d5 = width
			move.l	8(a3),d6					; d6 = height

			; Get muiAreaData
			lea	28(a2),a4

			; Get RastPort
			movea.l	0(a4),a1
			movea.l	20(a1),a1

			; DestX
			move.w	24(a4),d3
			ext.l	d3
			move.b	32(a4),d0
			ext.w	d0
			ext.l	d0
			add.l	d0,d3

			; DestY
			move.w	26(a4),d4
			ext.l	d4
			move.b	33(a4),d0
			ext.w	d0
			ext.l	d0
			add.l	d0,d4

			; SrcMod = width * 4 (bytes per row for ARGB)
			move.l	d5,d2
			lsl.l	#2,d2                 ; d2 = SrcMod

			movea.l	d7,a0                 ; source
			moveq	#0,d0                 ; SrcX
			moveq	#0,d1                 ; SrcY
			; d2 = SrcMod, d3 = DestX, d4 = DestY
			; d5 = Width, d6 = Height
			moveq	#2,d7						; RECTFMT_ARGB

			movem.l	a0-a1/d0-d2,-(sp)
			movea.l	vmp_CyberGfxBase(a5),a6
			jsr	-126(a6)					; WritePixelArray
			movem.l	(sp)+,a0-a1/d0-d2

.drawDone		movem.l	(sp)+,a0-a2/a4-a5
			moveq	#0,d0
			bra.w	.exit

.super			movea.l	vmp_CustomButtonClass(a5),a0
			movea.l	20(a0),a0					; a0 = mcc_Super (IClass*)
			movea.l	8(a0),a6					; a6 = Dispatcher
			jmp	(a6)

.exit			movem.l (sp)+,d2-d7/a2-a6
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
vmp_MainWdwDirlistTitle		dc.b	"Dirlist",0

				; Dirlist window
vmp_DirlistWindowTitle		dc.b	"Directory listing",0
vmp_DirlistAddToPLTitle		dc.b	"Add to playlist",0

;vmp_StartDirectory		dc.b	"DH2:",0
vmp_FilePattern			dc.b	"#?.mp3",0
vmp_FilePatternToken		ds.b	32

				; Playlist window
vmp_PlaylistWindowTitle		dc.b	"Playlist",0
vmp_PlaylistAddFileTitle	dc.b	"Add file",0
vmp_PlaylistAddDirTitle		dc.b	"Add directory",0

				; Application
vmp_ApplicationTitle		dc.b	"VaMP3",0
vmp_AppBase			dc.b	"VAMP3",0
vmp_MUIButtonSpace		dc.b	"MMM",0

MUIC_Application		dc.b	"Application.mui",0
MUIC_Window			dc.b	"Window.mui",0
MUIC_Group			dc.b	"Group.mui",0
MUIC_Text			dc.b	"Text.mui",0
MUIC_Image			dc.b	"Image.mui",0
MUIC_List			dc.b	"List.mui",0
MUIC_Listview			dc.b	"Listview.mui",0
MUIC_Dirlist			dc.b	"Dirlist.mui",0
MUIC_Area			dc.b	"Area.mui",0
MUIC_Popasl			dc.b	"Popasl.mui",0
MUIC_String			dc.b	"String.mui",0
MUIC_Slider			dc.b	"Slider.mui",0
MUIC_Menu			dc.b	"Menu.mui",0
MUIC_Menuitem			dc.b	"Menuitem.mui",0
MUIC_Menustrip			dc.b	"Menustrip.mui",0

vmp_CustomButton_Name		dc.b	"VaMP3CustomButton.mui",0
				even

vmp_Method_Input		dc.l	MUIM_Application_NewInput,vmp_Signals
				dc.l	0

vmp_Signals			ds.l	1							; Referenced from vmp_Method_Input structure


				; Menu
txt_Menu_File			dc.b	"File",0
txt_Menu_FileLoadPL		dc.b	"Load playlist",0
txt_Menu_FileSavePL		dc.b	"Save playlist",0
txt_Menu_Settings		dc.b	"Settings",0
txt_Menu_SettingsPrefs		dc.b	"Preferences",0


				; Main windows hooks
vmp_Hook_MainWdwButtonDirlist	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedDirlist				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPlay	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPlay				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPause	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPause				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonNext	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedNext				; h_entry - Pointing to routine to be exeh^ed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPrevious	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPrevious				; h_entry - Pointing to routine to be exeh^ed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPlaylist	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPressedPlaylist				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwSliderVolume	ds.b	MLN_SIZE
				dc.l	_MainWdwSliderVolumeChanged
				dc.l	0,0

vmp_Hook_MainWdwAppMessage	ds.b	MLN_SIZE
				dc.l	_MainWdwGotAppMessage
				dc.l	0,0

				; Dirlist window hooks
vmp_Hook_DirlistButtonClose	ds.b	MLN_SIZE
				dc.l	_DirlistButtonPressedClose
				dc.l	0,0

vmp_Hook_DirlistListview		ds.b	MLN_SIZE
				dc.l	_DirlistPressedDirlist
				dc.l	0,0

vmp_Hook_DirlistDirChanged	ds.b	MLN_SIZE
				dc.l	_DirlistDirChanged
				dc.l	0,0

				; Playlist window hooks
vmp_Hook_PlaylistButtonClose	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonPressedClose
				dc.l	0,0
				
vmp_Hook_PlaylistButtonAddFile	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonPressedAddFile
				dc.l	0,0

				even
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
