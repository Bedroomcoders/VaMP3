
			section code,code



			;------------------------------------------------------------
			; _InitApplication
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_InitApplication	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5
			
			; Create menustrip
			bsr	_BuildMenu
			bne.w	.error

			; Create settings window
			bsr	_BuildSettingsWindow
			bne.w	.error

			; Create Application Object
			lea	MUIC_Application,a0
			INITSTACKTAG
			STACKADRTAG	txt_ApplicationTitle, MUIA_Application_Title
			STACKADRTAG	txt_AppBase, MUIA_Application_Base
			STACKREGTAG	vmp_MUI_Menustrip(a5),MUIA_Application_Menustrip
			STACKREGTAG	vmp_MUI_SettingsWindow(a5),MUIA_Application_Window
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Application
			move.l	d0,vmp_MUI_Application(a5)
			beq.s	.error

			; Load any saved preferences
			DOMETHOD	vmp_MUI_Application(a5),#MUIM_Application_Load, #MUIV_Application_Load_ENVARC

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



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

			bsr	_BuildAboutWindow
			bne.w	.error

			bsr	_BuildCompactWindow
			bne.w	.error


			; *** Attach to applications ***
			DOMETHOD vmp_MUI_Application(a5), #OM_ADDMEMBER, vmp_MUI_MainWindow(a5)
			DOMETHOD vmp_MUI_Application(a5), #OM_ADDMEMBER, vmp_MUI_DirlistWindow(a5)
			DOMETHOD vmp_MUI_Application(a5), #OM_ADDMEMBER, vmp_MUI_PlaylistWindow(a5)
			DOMETHOD vmp_MUI_Application(a5), #OM_ADDMEMBER, vmp_MUI_AboutWindow(a5)
			DOMETHOD vmp_MUI_Application(a5), #OM_ADDMEMBER, vmp_MUI_CompactWindow(a5)

			; *** Copy default MP3 folder from Prefs to Dirlist ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsDefaultMP3Path(a5),a0
			move.l	#MUIA_String_Contents,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			tst.l	d0
			beq.s	.noDefaultPath
			
			movea.l	vmp_MUI_TempFilePointer(a5),a2
			tst.b	(a2)
			beq.s	.noDefaultPath
			
			; Set path to Dirlist string gadget
			movea.l	vmp_MUI_DirlistDirString(a5),a0
			INITSTACKTAG
			STACKREGTAG	a2, MUIA_String_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Set path to Dirlist object to trigger reading the directory
			movea.l	vmp_MUI_DirlistListview(a5),a0
			INITSTACKTAG
			STACKREGTAG	a2, MUIA_Dirlist_Directory
			CALLSTACKTAG	_LVOSetAttrsA,a1

.noDefaultPath
			; *** Open Main window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Auto-load playlist from PROGDIR:vaMP3.playlist
			lea	txt_DefaultPlaylistPath,a0
			bsr	_LoadPlaylistFromFile
			bsr	_RestoreStateOnStartup


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
			
			move.l	vmp_ImgBuffer_Play(a5),d0
			move.l	vmp_ImgWidth_Play(a5),d1
			move.l	vmp_ImgHeight_Play(a5),d2
			CREATEMUICUSTOMBUTTON	d0,d1,d2,32				; Shortcut Spacebar
			move.l	d0,vmp_MUI_MainWdwButtonPlay(a5)			; Create Play Button
			beq	.error


			move.l	vmp_ImgBuffer_Next(a5),d0
			move.l	vmp_ImgWidth_Next(a5),d1
			move.l	vmp_ImgHeight_Next(a5),d2
			CREATEMUICUSTOMBUTTON	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonNext(a5)			; Create Next Button
			beq	.error

			move.l	vmp_ImgBuffer_Prev(a5),d0
			move.l	vmp_ImgWidth_Prev(a5),d1
			move.l	vmp_ImgHeight_Prev(a5),d2
			CREATEMUICUSTOMBUTTON	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonPrevious(a5)			; Create Previous Button
			beq	.error

			move.l	vmp_ImgBuffer_Playlist(a5),d0
			move.l	vmp_ImgWidth_Playlist(a5),d1
			move.l	vmp_ImgHeight_Playlist(a5),d2
			CREATEMUICUSTOMBUTTON	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonPlaylist(a5)			; Create Playlist Button
			beq	.error

			move.l	vmp_ImgBuffer_Dirlist(a5),d0
			move.l	vmp_ImgWidth_Dirlist(a5),d1
			move.l	vmp_ImgHeight_Dirlist(a5),d2
			CREATEMUICUSTOMBUTTON	d0,d1,d2
			move.l	d0,vmp_MUI_MainWdwButtonDirlist(a5)			; Create Dirlist Button
			beq	.error

			CREATEMUILABEL	vmp_StatusIdleTxt
			move.l	d0,vmp_MUI_MainWdwStatusText(a5)			; Create Status field
			beq.w	.error

			; Create Song Name Text (Centered)
			CREATEMUITEXT	vmp_EmptyTxt
			move.l	d0,vmp_MUI_MainWdwTextSongName(a5)
			beq.w	.error

			; Create Position Slider
			lea	MUIC_Slider,a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Numeric_Min
			STACKVALTAG	1000,MUIA_Numeric_Max
			STACKVALTAG	0,MUIA_Numeric_Value
			STACKVALTAG	VMP_MAIN_POSITIONID, MUIA_ObjectID
			STACKVALTAG	TRUE,MUIA_Slider_Quiet
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwSliderPosition(a5)
			beq.w	.error

			; Create Time Text (Centered)
			CREATEMUILABEL	vmp_DefaultTimeTxt
			move.l	d0,vmp_MUI_MainWdwTextTime(a5)
			beq.w	.error

			; Create Volume Slider
			lea	MUIC_Slider,a0
			INITSTACKTAG
			STACKVALTAG	VMP_AUDIO_VOLUME,MUIA_Numeric_Default
			STACKVALTAG	VMP_MAIN_VOLUMEID, MUIA_ObjectID
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwSliderVolume(a5)				; Create Volume slider
			beq.w	.error

			; Create ButtonHGroup (Next, Stop, Play, Prev buttons)
			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwButtonPlaylist(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonDirlist(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonNext(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonPlay(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonPrevious(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwButtonHGroup(a5)
			beq.w	.error

			; Create Info Panel Group (Framed, Vertical)
			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwTextTime(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwStatusText(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwTextSongName(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			STACKVALTAG	MUIV_Frame_Text, MUIA_Frame
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,d3								; Keep InfoGroup handle in d3
			beq.w	.error

			; Create Main Vertical Group
			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MainWdwSliderVolume(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwButtonHGroup(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_MainWdwSliderPosition(a5), MUIA_Group_Child
			STACKREGTAG	d3, MUIA_Group_Child				; Framed Info Group containing Status, Song Name, Timers
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_MainWdwVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_MAINWINDOWID,MUIA_Window_ID
			STACKADRTAG	txt_MainWindowTitle,MUIA_Window_Title
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
			
			CREATEMUIBUTTON	txt_DirlistParent
			move.l	d0,vmp_MUI_DirlistParentButton(a5)			; Create Parent Button
			beq.w	.error

			movea.l	vmp_DosBase(a5),a6
			move.l	#vmp_FilePattern,d1
			move.l	#vmp_FilePatternToken,d2
			moveq	#32,d3
			LVO	ParsePatternNoCase
			
			movea.l	vmp_MUIBase(a5),a6
			lea	MUIC_Dirlist,a0
			INITSTACKTAG
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
			STACKVALTAG	MUIV_Frame_String, MUIA_Frame
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
			STACKREGTAG	vmp_MUI_DirlistParentButton(a5), MUIA_Group_Child
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
			STACKADRTAG	txt_DirlistWindowTitle,MUIA_Window_Title
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
			
			CREATEMUIBUTTON	txt_PlaylistAddFile
			move.l	d0,vmp_MUI_PlaylistButtonAddFile(a5)			; Create Add File Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistAddDir
			move.l	d0,vmp_MUI_PlaylistButtonAddDir(a5)			; Create Add Dir Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistRemove
			move.l	d0,vmp_MUI_PlaylistButtonRemove(a5)			; Create Remove Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistClear
			move.l	d0,vmp_MUI_PlaylistButtonClear(a5)			; Create Clear Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistUp
			move.l	d0,vmp_MUI_PlaylistButtonUp(a5)				; Create Move Up Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistDown
			move.l	d0,vmp_MUI_PlaylistButtonDown(a5)			; Create Move Down Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistShuffleOff
			move.l	d0,vmp_MUI_PlaylistShuffle(a5)				; Create Shuffle Button
			beq.w	.error

			CREATEMUIBUTTON	txt_PlaylistLoopOff
			move.l	d0,vmp_MUI_PlaylistLoop(a5)				; Create Loop Button
			beq.w	.error

			CREATEMUILABEL	txt_PlaylistStatusEmpty
			move.l	d0,vmp_MUI_PlaylistStatusText(a5)			; Create Status text
			beq.w	.error

			lea	MUIC_List,a0
			INITSTACKTAG
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistList(a5)				; Create MUI List
			beq.w	.error

			lea	MUIC_Listview,a0
			INITSTACKTAG
			STACKREGTAG	d0, MUIA_Listview_List
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistListview(a5)				; Create MUI Listview
			beq.w	.error

			; Row 1: Add File, Add Dir, Remove, Clear (stacked in reverse)
			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_PlaylistButtonClear(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistButtonRemove(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistButtonAddDir(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistButtonAddFile(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistHGroup1(a5)				; Create Playlist Horizontal Group 1
			beq.w	.error

			; Row 2: Move Up, Move Down, Shuffle, Loop (stacked in reverse)
			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_PlaylistLoop(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistShuffle(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistButtonDown(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistButtonUp(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistHGroup2(a5)				; Create Playlist Horizontal Group 2
			beq.w	.error

			; Vertical Layout Assembly (stacked in reverse)
			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_PlaylistStatusText(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistListview(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistHGroup2(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_PlaylistHGroup1(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_PlaylistVGroup(a5)				; Create MUI Vertical Group
			beq.w	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_PLAYLISTWINDOWID,MUIA_Window_ID
			STACKADRTAG	txt_PlaylistWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_PLAYLISTWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_PLAYLISTWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			STACKVALTAG	TRUE, MUIA_Window_AppWindow			; Accept Drag & Drop
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_PlaylistWindow(a5)
			beq.w	.error

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildSettingsWindow
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildSettingsWindow	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			movea.l	vmp_MUIBase(a5),a6
			moveq	#1,d5

			; Custom buttons settings
			CREATEMUILABEL	txt_SettingsImagePath
			move.l	d0,vmp_MUI_SettingsImagePathLabel(a5)
			beq.w	.error
			
			lea	MUIC_String,a0
			INITSTACKTAG
			STACKVALTAG	MUIV_Frame_String, MUIA_Frame
			STACKVALTAG	VMP_SETTINGS_IMAGEPATHID, MUIA_ObjectID
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsImagePath(a5)
			beq.w	.error
			
			CREATEMUIIMAGEBUTTON MUII_PopDrawer
			move.l	d0,vmp_MUI_SettingsImagePathPopdrawer(a5)
			beq.w	.error

			lea	MUIC_Popasl,a0
			INITSTACKTAG
			STACKVALTAG	ASL_FileRequest, MUIA_Popasl_Type
			STACKVALTAG	TRUE, ASLFR_DrawersOnly
			STACKREGTAG	vmp_MUI_SettingsImagePath(a5), MUIA_Popstring_String
			STACKREGTAG	vmp_MUI_SettingsImagePathPopdrawer(a5), MUIA_Popstring_Button
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsImagePathPopasl(a5)
			beq	.error


			; Default MP3 folder prefs
			CREATEMUILABEL	txt_SettingsDefaultMP3Folder
			move.l	d0,vmp_MUI_SettingsDefaultMP3Label(a5)
			beq.w	.error
			
			lea	MUIC_String,a0
			INITSTACKTAG
			STACKVALTAG	MUIV_Frame_String, MUIA_Frame
			STACKVALTAG	VMP_SETTINGS_DEFAULTMP3FOLDERID, MUIA_ObjectID
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsDefaultMP3Path(a5)
			beq.w	.error

			CREATEMUIIMAGEBUTTON MUII_PopDrawer
			move.l	d0,vmp_MUI_SettingsDefaultMP3Popdrawer(a5)
			beq.w	.error

			lea	MUIC_Popasl,a0
			INITSTACKTAG
			STACKVALTAG	ASL_FileRequest, MUIA_Popasl_Type
			STACKVALTAG	TRUE, ASLFR_DrawersOnly
			STACKREGTAG	vmp_MUI_SettingsDefaultMP3Path(a5), MUIA_Popstring_String
			STACKREGTAG	vmp_MUI_SettingsDefaultMP3Popdrawer(a5), MUIA_Popstring_Button
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsDefaultMP3Popasl(a5)
			beq	.error


			; Save button
			CREATEMUIBUTTON	txt_SettingsSave
			move.l	d0,vmp_MUI_SettingsSaveButton(a5)			; Create Save Button
			beq.w	.error


			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_SettingsImagePathPopasl(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_SettingsImagePathLabel(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsHGroup1(a5)				; Create Prefs Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_SettingsDefaultMP3Popasl(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_SettingsDefaultMP3Label(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsHGroup2(a5)				; Create Prefs Horizontal Group 2
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_SettingsSaveButton(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_SettingsHGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_SettingsHGroup2(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_SettingsVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_SETTINGSWINDOWID,MUIA_Window_ID
			STACKADRTAG	txt_SettingsWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_SETTINGSWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_SETTINGSWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_SettingsWindow(a5)
			beq	.error

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildAboutWindow
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildAboutWindow	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			moveq	#1,d5
			movea.l	vmp_MUIBase(a5),a6

			CREATEMUILABEL	txt_AboutLabel					; Copyright label
			move.l	d0,vmp_MUI_AboutLabel(a5)
			beq.w	.error

			INITSTACKTAG
			STACKVALTAG 85, CUSTOMBTN_Height
			STACKVALTAG 206, CUSTOMBTN_Width
			STACKADRTAG vmp_Logo, CUSTOMBTN_Image
			STACKVALTAG MUIV_Frame_None, MUIA_Frame
			movea.l vmp_CustomButtonClass(a5),a0
			movea.l 24(a0),a0
			suba.l  a1,a1
			movea.l vmp_IntuitionBase(a5),a6
			CALLSTACKTAG _LVONewObjectA,a2
			move.l	d0,vmp_MUI_AboutLogo(a5)				; Logo
			beq	.error

			movea.l	vmp_MUIBase(a5),a6

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_AboutLabel(a5), MUIA_Group_Child
			STACKVALTAG	TRUE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_AboutHGroup1(a5)				; Create Prefs Horizontal Group 1
			beq	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_AboutHGroup1(a5), MUIA_Group_Child
			STACKREGTAG	vmp_MUI_AboutLogo(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_AboutVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_ABOUTWINDOWID,MUIA_Window_ID
			STACKADRTAG	txt_AboutWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_ABOUTWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_ABOUTWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	TRUE, MUIA_Window_CloseGadget
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_AboutWindow(a5)
			beq	.error

			moveq	#0,d5

.error			move.l	d5,d0
			movem.l	(sp)+,d2-d3/d5/a0-a2/a6
			tst.l	d0
			rts



			;------------------------------------------------------------
			; _BuildCompactWindow
			;------------------------------------------------------------
			; Result:
			; 	OK	d0 = 0
			;	Error 	d0 = 1

_BuildCompactWindow	movem.l	d2-d3/d5/a0-a2/a6,-(sp)

			moveq	#1,d5
			movea.l	vmp_MUIBase(a5),a6

			CREATEMUILABEL	txt_CompactLabel					; Copyright label
			move.l	d0,vmp_MUI_CompactWdwLabel(a5)
			beq.w	.error

			lea	MUIC_Group,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_CompactWdwLabel(a5), MUIA_Group_Child
			STACKVALTAG	FALSE, MUIA_Group_Horiz
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1
			move.l	d0,vmp_MUI_CompactWdwVGroup(a5)				; Create MUI Vertical Group
			beq	.error

			lea	MUIC_Window,a0
			INITSTACKTAG
			STACKREGTAG	d0,MUIA_Window_RootObject
			STACKVALTAG	VMP_COMPACTWINDOWID,MUIA_Window_ID
			STACKADRTAG	txt_CompactWindowTitle,MUIA_Window_Title
			STACKVALTAG	VMP_COMPACTWINDOWWIDTH, MUIA_Window_Width
			STACKVALTAG	VMP_COMPACTWINDOWHEIGHT, MUIA_Window_Height
			STACKVALTAG	FALSE, MUIA_Window_CloseGadget
			STACKVALTAG	TRUE, MUIA_Window_AppWindow
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1				; Create MUI Window
			move.l	d0,vmp_MUI_CompactWindow(a5)
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
			STACKADRTAG	txt_Shortcut_LoadPL,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Load playlist
			move.l	d0,vmp_MUI_MenuFileLoadPL(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_FileSavePL, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_SavePL,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Save Playlist
			move.l	d0,vmp_MUI_MenuFileSavePL(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_FileAbout, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_About,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; About
			move.l	d0,vmp_MUI_MenuFileAbout(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_FileQuit, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Quit,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Quit
			move.l	d0,vmp_MUI_MenuFileQuit(a5)
			beq	.error

			lea	MUIC_Menu,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuFileQuit(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuFileAbout(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuFileSavePL(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuFileLoadPL(a5),MUIA_Family_Child
			STACKADRTAG	txt_Menu_File, MUIA_Menu_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; File menu
			move.l	d0,vmp_MUI_MenuFile(a5)
			beq	.error

			; Settings menu
			
			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PrefsSettings, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Settings,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Settings
			move.l	d0,vmp_MUI_MenuPrefsSettings(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PrefsMUISettings, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_MUISettings,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; MUI Settings
			move.l	d0,vmp_MUI_MenuPrefsMUISettings(a5)
			beq	.error

			lea	MUIC_Menu,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuPrefsMUISettings(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPrefsSettings(a5),MUIA_Family_Child
			STACKADRTAG	txt_Menu_Preferences, MUIA_Menu_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Preferences menu
			move.l	d0,vmp_MUI_MenuPreferences(a5)
			beq	.error

		;	lea	MUIC_Menustrip,a0
		;	INITSTACKTAG
		;	STACKREGTAG	vmp_MUI_MenuPreferences(a5),MUIA_Family_Child
		;	STACKREGTAG	vmp_MUI_MenuFile(a5),MUIA_Family_Child
		;	CALLSTACKTAG	_LVOMUI_NewObjectA,a1
		;	move.l	d0,vmp_MUI_Menustrip(a5)
		;	beq	.error


			; Player menu
			
			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PlayerPlayPause, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_PlayPause,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Play/Pause
			move.l	d0,vmp_MUI_MenuPlayerPlayPause(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PlayerNext, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Next,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Next
			move.l	d0,vmp_MUI_MenuPlayerNext(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PlayerPrevious, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Previous,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Previous
			move.l	d0,vmp_MUI_MenuPlayerPrevious(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PlayerPlaylist, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Playlist,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Playlist
			move.l	d0,vmp_MUI_MenuPlayerPlaylist(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PlayerDirlist, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Dirlist,MUIA_Menuitem_Shortcut
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Dirlist
			move.l	d0,vmp_MUI_MenuPlayerDirlist(a5)
			beq	.error

			lea	MUIC_Menuitem,a0
			INITSTACKTAG
			STACKADRTAG	txt_Menu_PlayerCompact, MUIA_Menuitem_Title
			STACKADRTAG	txt_Shortcut_Compact,MUIA_Menuitem_Shortcut
			STACKVALTAG	TRUE, MUIA_Menuitem_Checkit
			STACKVALTAG	TRUE, MUIA_Menuitem_Toggle
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Compact
			move.l	d0,vmp_MUI_MenuPlayerCompact(a5)
			beq	.error

			lea	MUIC_Menu,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuPlayerCompact(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPlayerDirlist(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPlayerPlaylist(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPlayerPrevious(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPlayerNext(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPlayerPlayPause(a5),MUIA_Family_Child
			STACKADRTAG	txt_Menu_Player, MUIA_Menu_Title
			CALLSTACKTAG	_LVOMUI_NewObjectA,a1						; Player menu
			move.l	d0,vmp_MUI_MenuPlayer(a5)
			beq	.error


			; Menustrip

			lea	MUIC_Menustrip,a0
			INITSTACKTAG
			STACKREGTAG	vmp_MUI_MenuPreferences(a5),MUIA_Family_Child
			STACKREGTAG	vmp_MUI_MenuPlayer(a5),MUIA_Family_Child
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
 			DOMETHOD vmp_MUI_MainWdwButtonPlay(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPlay
 			DOMETHOD vmp_MUI_MainWdwButtonNext(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonNext
 			DOMETHOD vmp_MUI_MainWdwButtonPrevious(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPrevious
			DOMETHOD vmp_MUI_MainWdwSliderVolume(a5), #MUIM_Notify, #MUIA_Numeric_Value, #MUIV_EveryTime, #MUIV_Notify_Window, #3, #MUIM_CallHook, #vmp_Hook_MainWdwSliderVolume, #MUIV_TriggerValue
			DOMETHOD vmp_MUI_MainWdwSliderPosition(a5), #MUIM_Notify, #MUIA_Pressed, #TRUE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwSliderPositionGrabbed
			DOMETHOD vmp_MUI_MainWdwSliderPosition(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwSliderPositionReleased


			; Dirlist window methods
			DOMETHOD vmp_MUI_DirlistWindow(a5), #MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_CallHook, #vmp_Hook_DirlistButtonClose
			DOMETHOD vmp_MUI_DirlistListview(a5), #MUIM_Notify, #MUIA_Listview_DoubleClick, #TRUE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_DirlistListview
			DOMETHOD vmp_MUI_DirlistList(a5), #MUIM_Notify, #MUIA_Dirlist_Directory, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_DirlistDirChanged
			DOMETHOD vmp_MUI_DirlistDirString(a5), #MUIM_Notify, #MUIA_String_Acknowledge, #MUIV_EveryTime, vmp_MUI_DirlistListview(a5), #3, #MUIM_Set, #MUIA_Dirlist_Directory, #MUIV_TriggerValue

 			DOMETHOD vmp_MUI_DirlistParentButton(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_DirlistParent


						; Playlist window methods
			DOMETHOD vmp_MUI_PlaylistWindow(a5),#MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonClose
			DOMETHOD vmp_MUI_PlaylistWindow(a5),#MUIM_Notify, #MUIA_AppMessage, #MUIV_EveryTime, #MUIV_Notify_Self, #3, #MUIM_CallHook, #vmp_Hook_PlaylistAppMessage, #MUIV_TriggerValue
			DOMETHOD vmp_MUI_PlaylistButtonAddFile(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonAddFile
			DOMETHOD vmp_MUI_PlaylistButtonAddDir(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonAddDir
			DOMETHOD vmp_MUI_PlaylistButtonRemove(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonRemove
			DOMETHOD vmp_MUI_PlaylistButtonClear(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonClear
			DOMETHOD vmp_MUI_PlaylistButtonUp(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonUp
			DOMETHOD vmp_MUI_PlaylistButtonDown(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonDown
			DOMETHOD vmp_MUI_PlaylistShuffle(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistShuffle
			DOMETHOD vmp_MUI_PlaylistLoop(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistLoop
			DOMETHOD vmp_MUI_PlaylistListview(a5), #MUIM_Notify, #MUIA_Listview_DoubleClick, #TRUE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_PlaylistListDoubleclick

			; Settings window methods
			DOMETHOD vmp_MUI_SettingsWindow(a5), #MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_CallHook, #vmp_Hook_SettingsButtonClose
			DOMETHOD vmp_MUI_SettingsSaveButton(a5), #MUIM_Notify, #MUIA_Pressed, #FALSE, #MUIV_Notify_Window, #2, #MUIM_CallHook, #vmp_Hook_SettingsButtonSave

			; About window methods
			DOMETHOD vmp_MUI_AboutWindow(a5), #MUIM_Notify, #MUIA_Window_CloseRequest, #TRUE, #MUIV_Notify_Application, #2, #MUIM_CallHook, #vmp_Hook_AboutButtonClose

			; Compact window methods
			DOMETHOD vmp_MUI_CompactWindow(a5), #MUIM_Notify, #MUIA_AppMessage, #MUIV_EveryTime, #MUIV_Notify_Self, #3, #MUIM_CallHook, #vmp_Hook_MainWdwAppMessage, #MUIV_TriggerValue


			; Menu methods

			DOMETHOD vmp_MUI_MenuFileQuit(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Application, #2, #MUIM_Application_ReturnID, #MUIV_Application_ReturnID_Quit
			DOMETHOD vmp_MUI_MenuFileAbout(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MenuAbout
			DOMETHOD vmp_MUI_MenuFileLoadPL(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonLoadPL
			DOMETHOD vmp_MUI_MenuFileSavePL(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_PlaylistButtonSavePL

			DOMETHOD vmp_MUI_MenuPrefsSettings(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MenuSettings
			DOMETHOD vmp_MUI_MenuPrefsMUISettings(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, vmp_MUI_Application(a5), #1, #MUIM_Application_OpenConfigWindow

		 	DOMETHOD vmp_MUI_MenuPlayerCompact(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MenuCompact
		 	DOMETHOD vmp_MUI_MenuPlayerDirlist(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonDirlist
 			DOMETHOD vmp_MUI_MenuPlayerPlaylist(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPlaylist
 			DOMETHOD vmp_MUI_MenuPlayerPlayPause(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPlay
 			DOMETHOD vmp_MUI_MenuPlayerNext(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonNext
 			DOMETHOD vmp_MUI_MenuPlayerPrevious(a5), #MUIM_Notify, #MUIA_Menuitem_Trigger, #MUIV_EveryTime, #MUIV_Notify_Self, #2, #MUIM_CallHook, #vmp_Hook_MainWdwButtonPrevious



			movem.l	(sp)+,a0-a2/a6
			rts



			;------------------------------------------------------------
			; _PausePlayer
			;------------------------------------------------------------
_PausePlayer		movem.l	d0/a0-a2/a6,-(sp)
			bsr	_PauseMP3
			moveq	#VMP_STATUS_PAUSED,d0
			bsr	_SetStatus
			movem.l	(sp)+,d0/a0-a2/a6
			rts

			;------------------------------------------------------------
			; _ResumePlayer
			;------------------------------------------------------------
_ResumePlayer		movem.l	d0/a0-a2/a6,-(sp)
			bsr	_ResumeMP3
			moveq	#VMP_STATUS_PLAYING,d0
			bsr	_SetStatus
			movem.l	(sp)+,d0/a0-a2/a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonPlay
			;------------------------------------------------------------

_MainWdwButtonPlay
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			tst.l	vmp_Playing(a5)
			bne.s	.togglePause

			; Player is idle! Start playing the selected item
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistListview(a5),a0
			move.l	#MUIA_List_Active,d0
			lea	vmp_PlayingIndex(a5),a1
			LVO	GetAttr
			cmp.l	#MUIV_List_Active_Off,vmp_PlayingIndex(a5)
			beq.s	.done

			; Play it!
			bsr.w	_DirlistClicked
			bra.s	.done

.togglePause
			tst.l	vmp_Paused(a5)
			bne.s	.doResume

			; Currently playing! Pause it.
			bsr	_PausePlayer
			bra.s	.done

.doResume
			; Currently paused! Resume it.
			bsr	_ResumePlayer

.done			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _MainWdwButtonNext
			;------------------------------------------------------------

_MainWdwButtonNext
			movem.l	d2-d3/a3-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; Reload our Struct in a5

			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			beq.s	.dirlist
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			beq.s	.playlist
			bra.w	.done

.dirlist		movea.l	vmp_MUI_DirlistListview(a5),a4
			lea	_DirlistClicked,a3
			bra.s	.findNext

.playlist		movea.l	vmp_MUI_PlaylistList(a5),a4
			lea	_PlaylistClicked,a3

			; Check Shuffle Mode
			tst.l	vmp_PlaylistShuffle(a5)
			bne.s	.shuffleNext

			; Not Shuffle. Normal or Loop.
			move.l	vmp_PlayingIndex(a5),d2
			addq.l	#1,d2

			; Compare with PlaylistCount
			cmp.l	vmp_PlaylistCount(a5),d2
			blt.s	.playPlaylistNext

			; We hit the end of the playlist! Check Loop Mode (2 = Loop All)
			cmp.l	#2,vmp_PlaylistLoop(a5)
			beq.s	.wrapFirstNext

			; Loop is Off or Track. Stop and go to IDLE.
			bra.s	.stopPlaylistNext

.wrapFirstNext	moveq	#0,d2
.playPlaylistNext
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a4,a0
			INITSTACKTAG
			STACKREGTAG	d2, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1
			jsr	(a3)
			bra.s	.done

.shuffleNext	move.l	vmp_PlaylistCount(a5),d3
			cmp.l	#1,d3
			ble.s	.wrapFirstNext

			move.w	$dff006,d0						; Get beam position
			mulu.w	#109,d0
			add.w	#221,d0
			and.l	#$7fff,d0
			divu.w	d3,d0
			swap	d0
			moveq	#0,d2
			move.w	d0,d2
			bra.s	.playPlaylistNext

.stopPlaylistNext
			move.l	#0,vmp_Playing(a5)
			move.l	#0,vmp_FramesToDecode(a5)
			moveq	#VMP_STATUS_IDLE,d0
			bsr	_SetStatus
			moveq	#VMP_AUDIO_CHANNEL,d0
			bsr	_StopAudio
			bra.s	.done

.findNext		move.l	vmp_PlayingIndex(a5),d2

.loopNext		addq.l	#1,d2							; Check next index

			; Get entry at index d2
			lea	vmp_TempVariable(a5),a1
			DOMETHOD a4, #MUIM_List_GetEntry, d2, a1
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
			; _MainWdwButtonPrevious
			;------------------------------------------------------------

_MainWdwButtonPrevious
			movem.l	d2-d3/a3-a6,-(sp)
			movea.l	vmp_StructPointer,a5					; Reload our Struct in a5

			cmp.l	#VMP_PLAYINGFROM_DIRLIST,vmp_PlayingFrom(a5)
			beq.s	.dirlist
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			beq.s	.playlist
			bra.w	.done

.dirlist		movea.l	vmp_MUI_DirlistListview(a5),a4
			lea	_DirlistClicked,a3
			bra.s	.findPrev

.playlist		movea.l	vmp_MUI_PlaylistList(a5),a4
			lea	_PlaylistClicked,a3

			; Check Shuffle Mode
			tst.l	vmp_PlaylistShuffle(a5)
			bne.s	.shufflePrev

			; Not Shuffle. Normal or Loop.
			move.l	vmp_PlayingIndex(a5),d2
			subq.l	#1,d2
			bpl.s	.playPlaylistPrev

			; We went below 0! Check Loop Mode (2 = Loop All)
			cmp.l	#2,vmp_PlaylistLoop(a5)
			beq.s	.wrapLastPrev

			; Loop is Off or Track. Just stay at 0.
			moveq	#0,d2
			bra.s	.playPlaylistPrev

.wrapLastPrev	move.l	vmp_PlaylistCount(a5),d2
			subq.l	#1,d2
			bpl.s	.playPlaylistPrev
			moveq	#0,d2
.playPlaylistPrev
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a4,a0
			INITSTACKTAG
			STACKREGTAG	d2, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1
			jsr	(a3)
			bra.s	.done

.shufflePrev	move.l	vmp_PlaylistCount(a5),d3
			cmp.l	#1,d3
			ble.s	.wrapFirstPrev

			move.w	$dff006,d0
			mulu.w	#109,d0
			add.w	#221,d0
			and.l	#$7fff,d0
			divu.w	d3,d0
			swap	d0
			moveq	#0,d2
			move.w	d0,d2
			bra.s	.playPlaylistPrev

.wrapFirstPrev	moveq	#0,d2
			bra.s	.playPlaylistPrev

.findPrev		move.l	vmp_PlayingIndex(a5),d2

.loopPrev		subq.l	#1,d2							; Check previous index
			bmi.w	.done							; We hit the top, just stop

			; Get entry at index d2
			lea	vmp_TempVariable(a5),a1
			DOMETHOD a4, #MUIM_List_GetEntry, d2, a1
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
			; _MainWdwButtonPressedDirlist
			;------------------------------------------------------------

_MainWdwButtonDirlist
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
			; _MainWdwButtonPlaylist
			;------------------------------------------------------------

_MainWdwButtonPlaylist
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
			move.l	d1,vmp_Volume(a5)			; Store in our structure so it stays in sync!

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
			
			bsr	_PausePlayer

			lea	vmp_FilenameBuffer,a0
			bsr	_NewMP3
			tst.l	d0
			beq.s	.done
			
			bsr	_ResumePlayer
			
.done			moveq	#0,d0
			movem.l	(sp)+,d1-d3/a0-a2/a5-a6
			rts



			;------------------------------------------------------------
			; _MainWdwSliderPositionGrabbed
			;------------------------------------------------------------

_MainWdwSliderPositionGrabbed
			movem.l	a5,-(sp)
			movea.l	vmp_StructPointer,a5
			move.l	#1,vmp_SliderGrabbed(a5)
			movem.l	(sp)+,a5
			moveq	#0,d0
			rts



			;------------------------------------------------------------
			; _MainWdwSliderPositionReleased
			;------------------------------------------------------------

_MainWdwSliderPositionReleased
			movem.l	a0-a2/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			
			; 1. Clear grab flag
			move.l	#0,vmp_SliderGrabbed(a5)
			
			; 2. Get current slider value
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwSliderPosition(a5),a0
			move.l	#MUIA_Numeric_Value,d0
			lea	vmp_TempVariable(a5),a1
			LVO	GetAttr
			tst.l	d0
			beq.s	.done
			
			; 3. Execute seek to target percentage
			move.l	vmp_TempVariable(a5),d0				; d0 = value between 0 and 1000
			bsr	_SeekMP3
			
.done			moveq	#0,d0
			movem.l	(sp)+,a0-a2/a5-a6
			rts



			;------------------------------------------------------------
			; _DirlistButtonClose
			;------------------------------------------------------------

_DirlistButtonClose
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
			; _DirlistClicked
			;------------------------------------------------------------

_DirlistClicked		movem.l	a0-a1/a5-a6,-(sp)

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
			DOMETHOD	vmp_MUI_DirlistListview(a5), #MUIM_List_GetEntry, #MUIV_List_GetEntry_Active, a1
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
			bsr	_PausePlayer
			movea.l		vmp_MUI_TempFilePointer(a5),a0
			bsr	_NewMP3
			tst.l	d0
			beq.s	.done
			bsr	_ResumePlayer
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
			; _DirlistParent
			;------------------------------------------------------------

_DirlistParent		movem.l	d0-d2/a0-a2/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; Get the string pointer from the string gadget
			movea.l	vmp_IntuitionBase(a5),a6
			move.l	#MUIA_String_Contents,d0
			movea.l	vmp_MUI_DirlistDirString(a5),a0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			tst.l	d0
			beq.s	.done

			; Copy the string into vmp_FilenameBuffer
			movea.l	vmp_MUI_TempFilePointer(a5),a0
			lea	vmp_FilenameBuffer,a1
.copyLoop		move.b	(a0)+,(a1)+
			bne.s	.copyLoop

			; Find parent in vmp_FilenameBuffer
			movea.l	vmp_DosBase(a5),a6
			lea	vmp_FilenameBuffer,a0
			move.l	a0,d1
			LVO	PathPart
			tst.l	d0
			beq.s	.done
			
			; Null-terminate at the separator
			movea.l	d0,a0
			move.b	#0,(a0)

			; Update the string gadget with the new truncated parent path
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_DirlistDirString(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_FilenameBuffer,MUIA_String_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Update the Dirlist itself to refresh the file listing
			movea.l	vmp_MUI_DirlistListview(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_FilenameBuffer,MUIA_Dirlist_Directory
			CALLSTACKTAG	_LVOSetAttrsA,a1

			move.l	#-1,vmp_PlayingIndex(a5)

.done			moveq	#0,d0
			movem.l	(sp)+,d0-d2/a0-a2/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonPressedClose
			;------------------------------------------------------------

_PlaylistButtonClose
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Close Playlist window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



						;------------------------------------------------------------
			; _PlaylistButtonPressedAddFile
			;------------------------------------------------------------

_PlaylistButtonAddFile
			movem.l	d5/a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Check if playing, and temporarily pause
			move.l	vmp_Playing(a5),d5			; Save current playing state in d5
			beq.s	.noPause
			tst.l	vmp_Paused(a5)
			bne.s	.noPause					; If already paused, do nothing

			bsr	_PausePlayer

.noPause
			; 2. Open synchronous ASL requester
			lea	vmp_FilenameBuffer,a0
			bsr	_AskFile
			tst.l	d0
			beq.s	.resume

			; 3. Add file to playlist
			lea	vmp_FilenameBuffer,a0
			bsr	_PlaylistAddSingleFile

.resume
			; 4. Resume if we paused
			tst.l	d5
			beq.s	.done
			tst.l	vmp_Paused(a5)
			beq.s	.done
			bsr	_ResumePlayer

.done			moveq	#0,d0
			movem.l	(sp)+,d5/a0/a5-a6
			rts


			;------------------------------------------------------------
			; _PlaylistButtonPressedAddDir
			;------------------------------------------------------------

_PlaylistButtonAddDir
			movem.l	d5/a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Check if playing, and temporarily pause
			move.l	vmp_Playing(a5),d5			; Save current playing state in d5
			beq.s	.noPause
			tst.l	vmp_Paused(a5)
			bne.s	.noPause

			bsr	_PausePlayer

.noPause
			; 2. Open synchronous ASL requester
			lea	vmp_FilenameBuffer,a0
			bsr	_AskDir
			tst.l	d0
			beq.s	.resume

			; 3. Add directory to playlist
			lea	vmp_FilenameBuffer,a0
			bsr	_PlaylistAddSingleDir

.resume
			; 4. Resume if we paused
			tst.l	d5
			beq.s	.done
			tst.l	vmp_Paused(a5)
			beq.s	.done
			bsr	_ResumePlayer

.done			moveq	#0,d0
			movem.l	(sp)+,d5/a0/a5-a6
			rts


			;------------------------------------------------------------
			; _PlaylistAddSingleFile
			;------------------------------------------------------------
			; Input: a0 = path string pointer

_PlaylistAddSingleFile
			movem.l	d3-d7/a3-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			move.l	a0,a4					; a4 = path

			; 1. Verify it's an MP3 (ends with ".mp3" case insensitive)
			movea.l	a4,a0
.findEnd		tst.b	(a0)+
			bne.s	.findEnd
			subq.l	#5,a0					; back up to start of ".mp3"
			cmpa.l	a4,a0
			blt.w	.done					; path too short!

			; Case insensitive check for ".mp3"
			cmp.b	#'.',(a0)+
			bne.w	.done
			move.b	(a0)+,d0
			cmp.b	#'m',d0
			beq.s	.m_ok
			cmp.b	#'M',d0
			bne.w	.done
.m_ok			move.b	(a0)+,d0
			cmp.b	#'p',d0
			beq.s	.p_ok
			cmp.b	#'P',d0
			bne.w	.done
.p_ok			cmp.b	#'3',(a0)+
			bne.w	.done

			; 2. Allocate memory block for PlaylistEntry
			movea.l	4.w,a6
			move.l	#ple_SIZEOF,d0
			move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
			jsr	_LVOAllocVec(a6)
			movea.l	d0,a3					; a3 = PlaylistEntry pointer
			tst.l	d0
			beq.w	.done

			; 3. Copy full path to ple_Path
			movea.l	a4,a0
			lea	ple_Path(a3),a1
.copyPath		move.b	(a0)+,(a1)+
			bne.s	.copyPath

			; 4. Extract filename from path for ple_Name
			movea.l	a4,a0
.scanEnd		tst.b	(a0)+
			bne.s	.scanEnd
			subq.l	#1,a0					; a0 points to null-terminator
.scanBack		cmpa.l	a4,a0
			beq.s	.foundStart
			subq.l	#1,a0
			cmp.b	#'/',(a0)
			beq.s	.foundSlash
			cmp.b	#':',(a0)
			beq.s	.foundSlash
			bra.s	.scanBack
.foundSlash		addq.l	#1,a0					; skip slash
.foundStart
			lea	ple_Name(a3),a1
.copyName		move.b	(a0)+,(a1)+
			bne.s	.copyName

			; 5. Insert into MUI List
			movea.l	vmp_MUI_PlaylistList(a5),a2
			DOMETHOD a2, #MUIM_List_InsertSingle, a3, #MUIV_List_Insert_Bottom

			; 6. Increment track counter
			addq.l	#1,vmp_PlaylistCount(a5)

			; 7. Update status bar text
			bsr	_PlaylistUpdateStatus

.done			movem.l	(sp)+,d3-d7/a3-a6
			rts



			;------------------------------------------------------------
			; _PlaylistAddSingleDir
			;------------------------------------------------------------
			; Input: a0 = folder path string pointer

_PlaylistAddSingleDir
			movem.l	d2-d4/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			move.l	a0,a4					; a4 = folder path

			; 1. Lock the directory
			movea.l	vmp_DosBase(a5),a6
			move.l	a4,d1
			move.l	#ACCESS_READ,d2				; SHARED_LOCK = -2
			LVO	Lock
			move.l	d0,d4					; d4 = locked directory lock
			beq.w	.done

			; 2. Allocate FileInfoBlock
			move.l	#DOS_FIB,d1
			moveq	#0,d2					; tags = NULL
			LVO	AllocDosObject
			movea.l	d0,a3					; a3 = FileInfoBlock pointer
			tst.l	d0
			beq.s	.unlock

			; 3. Examine the directory
			move.l	d4,d1
			move.l	a3,d2
			LVO	Examine
			tst.l	d0
			beq.s	.freeFib

.loopEntries		move.l	d4,d1
			move.l	a3,d2
			LVO	ExNext
			tst.l	d0
			beq.s	.freeFib				; End of directory or error

			move.l	fib_DirEntryType(a3),d0
			blt.s	.fileEntry
			bgt.s	.dirEntry
			bra.s	.loopEntries

.fileEntry
			; Copy folder path to stack buffer
			suba.l	#256,sp
			movea.l	sp,a2
			movea.l	a4,a0
			movea.l	a2,a1
.copyPathLocal1		move.b	(a0)+,(a1)+
			bne.s	.copyPathLocal1

			move.l	a2,d1
			lea	fib_FileName(a3),a0
			move.l	a0,d2
			move.l	#256,d3
			LVO	AddPart
			tst.l	d0
			beq.s	.fileDone

			movea.l	sp,a0
			bsr	_PlaylistAddSingleFile

.fileDone		adda.l	#256,sp
			bra.s	.loopEntries

.dirEntry
			suba.l	#256,sp
			movea.l	sp,a2

			movea.l	a4,a0
			movea.l	a2,a1
.copyPathLocal2		move.b	(a0)+,(a1)+
			bne.s	.copyPathLocal2

			move.l	a2,d1
			lea	fib_FileName(a3),a0
			move.l	a0,d2
			move.l	#256,d3
			LVO	AddPart
			tst.l	d0
			beq.s	.dirDone

			movea.l	a2,a0
			bsr	_PlaylistAddSingleDir

.dirDone		adda.l	#256,sp
			bra.w	.loopEntries

.freeFib		movea.l	vmp_DosBase(a5),a6
			move.l	#DOS_FIB,d1
			move.l	a3,d2
			LVO	FreeDosObject

.unlock			movea.l	vmp_DosBase(a5),a6
			move.l	d4,d1
			LVO	UnLock

.done			movem.l	(sp)+,d2-d4/a2-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonRemove
			;------------------------------------------------------------

_PlaylistButtonRemove
			movem.l	d2-d3/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			movea.l	vmp_MUI_PlaylistList(a5),a2

			; 1. Get active entry index
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a2,a0				; Now a0 holds the List object
			move.l	#MUIA_List_Active,d0
			lea	vmp_TempVariable(a5),a1
			LVO	GetAttr
			move.l	vmp_TempVariable(a5),d2			; d2 = active index
			cmp.l	#MUIV_List_Active_Off,d2
			beq.s	.done

			; 2. Retrieve PlaylistEntry pointer
			lea	vmp_TempVariable(a5),a1
			DOMETHOD a2, #MUIM_List_GetEntry, d2, a1
			move.l	vmp_TempVariable(a5),a3			; a3 = PlaylistEntry pointer
			tst.l	a3
			beq.s	.done

			; 3. Remove from list
			DOMETHOD a2, #MUIM_List_Remove, d2

			; 4. Free structural memory
			movea.l	4.w,a6
			movea.l	a3,a1
			jsr	_LVOFreeVec(a6)

			; 5. Decrement track counter
			subq.l	#1,vmp_PlaylistCount(a5)
			bpl.s	.countOk
			move.l	#0,vmp_PlaylistCount(a5)
.countOk
			; 6. Update status bar
			bsr	_PlaylistUpdateStatus

.done			moveq	#0,d0
			movem.l	(sp)+,d2-d3/a2-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonClear
			;------------------------------------------------------------

_PlaylistButtonClear
			movem.l	d2-d3/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; Stop playback if playing from playlist
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			bne.s	.doClear
			bsr	_PausePlayer

.doClear		movea.l	vmp_MUI_PlaylistList(a5),a2			; a2 = list object

.loop			tst.l	vmp_PlaylistCount(a5)
			beq.s	.finish

			; Get the first entry (always at index 0)
			lea	vmp_TempVariable(a5),a1
			DOMETHOD a2, #MUIM_List_GetEntry, #0, a1
			move.l	vmp_TempVariable(a5),a3			; a3 = entry pointer
			tst.l	a3
			beq.s	.finish

			; Remove from list
			DOMETHOD a2, #MUIM_List_Remove, #0

			; Free memory
			movea.l	4.w,a6
			movea.l	a3,a1
			jsr	_LVOFreeVec(a6)

			subq.l	#1,vmp_PlaylistCount(a5)
			bra.s	.loop

.finish			move.l	#0,vmp_PlaylistCount(a5)
			DOMETHOD a2, #MUIM_List_Clear

			; Update status bar
			bsr	_PlaylistUpdateStatus

.done			moveq	#0,d0
			movem.l	(sp)+,d2-d3/a2-a6
			rts


			;------------------------------------------------------------
			; _SavePlaylistToFile
			;------------------------------------------------------------
			; Input: a0 = pointer to path string
			;------------------------------------------------------------
_SavePlaylistToFile	movem.l	d2-d7/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			move.l	a0,a4					; a4 = path string

			; 1. Open the file for writing
			movea.l	vmp_DosBase(a5),a6
			move.l	a4,d1					; filename
			move.l	#MODE_NEWFILE,d2
			LVO	Open
			move.l	d0,d7					; d7 = file handle
			beq.w	.doneSave				; open failed

			; 2. Iterate list entries
			movea.l	vmp_MUI_PlaylistList(a5),a2		; a2 = list object
			moveq	#0,d5					; d5 = index = 0

.saveLoop		cmp.l	vmp_PlaylistCount(a5),d5
			bhs.s	.closeSaveFile

			lea	vmp_TempVariable(a5),a1
			DOMETHOD a2, #MUIM_List_GetEntry, d5, a1
			move.l	vmp_TempVariable(a5),a3			; a3 = PlaylistEntry pointer
			tst.l	a3
			beq.s	.nextSave

			; 3. Write ple_Path
			lea	ple_Path(a3),a0				; a0 = path pointer
			
			; find length of ple_Path
			movea.l	a0,a1
			moveq	#0,d3					; d3 = length
.lenLoop		tst.b	(a1)+
			bne.s	.addLen
			bra.s	.lenDone
.addLen			addq.l	#1,d3
			bra.s	.lenLoop
.lenDone		tst.l	d3
			beq.s	.nextSave

			; Write track path
			movea.l	vmp_DosBase(a5),a6
			move.l	d7,d1					; file handle
			move.l	a0,d2					; buffer
			LVO	Write

			; Write newline character (LF)
			move.l	d7,d1
			pea	.newline(pc)
			move.l	(sp)+,d2
			moveq	#1,d3
			LVO	Write

.nextSave		addq.l	#1,d5
			bra.s	.saveLoop

.closeSaveFile		movea.l	vmp_DosBase(a5),a6
			move.l	d7,d1
			LVO	Close

.doneSave		movem.l	(sp)+,d2-d7/a2-a6
			rts

.newline		dc.b	10,0
			even



			;------------------------------------------------------------
			; _LoadPlaylistFromFile
			;------------------------------------------------------------
			; Input: a0 = pointer to path string
			;------------------------------------------------------------
_LoadPlaylistFromFile	movem.l	d2-d7/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			move.l	a0,a4					; a4 = path string

			; 1. Open the file for reading
			movea.l	vmp_DosBase(a5),a6
			move.l	a4,d1					; filename
			move.l	#MODE_OLDFILE,d2
			LVO	Open
			move.l	d0,d7					; d7 = file handle
			beq.w	.doneLoad				; open failed

			; 2. Clear the current playlist first
			bsr	_PlaylistButtonClear

			; 3. Allocate a 512-byte buffer on the stack for reading lines
			suba.l	#512,sp
			movea.l	sp,a3					; a3 = line buffer

.readLoop		movea.l	vmp_DosBase(a5),a6
			move.l	d7,d1					; file handle
			move.l	a3,d2					; buffer
			move.l	#512,d3					; max size
			LVO	FGets
			tst.l	d0
			beq.s	.eof					; EOF or error

			; 4. Strip trailing CR/LF
			movea.l	a3,a0
.findEndLoad		tst.b	(a0)+
			bne.s	.findEndLoad
			subq.l	#2,a0					; back up to char before null

			; check LF
			cmpa.l	a3,a0
			blt.s	.checkEmpty
			cmp.b	#10,(a0)
			bne.s	.checkCR
			move.b	#0,(a0)
			subq.l	#1,a0

.checkCR		cmpa.l	a3,a0
			blt.s	.checkEmpty
			cmp.b	#13,(a0)
			bne.s	.checkEmpty
			move.b	#0,(a0)

.checkEmpty		; check empty or comment (#)
			tst.b	(a3)
			beq.s	.readLoop
			cmp.b	#'#',(a3)
			beq.s	.readLoop

			; 5. Add file to playlist
			movea.l	a3,a0
			bsr	_PlaylistAddSingleFile

			bra.s	.readLoop

.eof			adda.l	#512,sp					; free stack buffer

			; 6. Close the file
			movea.l	vmp_DosBase(a5),a6
			move.l	d7,d1
			LVO	Close

.doneLoad		movem.l	(sp)+,d2-d7/a2-a6
			rts



			;------------------------------------------------------------
			; _SaveStateToFile
			;------------------------------------------------------------
			; Input: None
			;------------------------------------------------------------
_SaveStateToFile	movem.l	d2/d4/a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Open state file for writing
			movea.l	vmp_DosBase(a5),a6
			lea	txt_DefaultStatePath,a0
			move.l	a0,d1					; filename
			move.l	#MODE_NEWFILE,d2
			LVO	Open
			move.l	d0,d4					; d4 = file handle
			beq.s	.doneSave				; open failed

			; 2. Allocate buffer on stack for our two LONGs
			suba.l	#8,sp
			move.l	vmp_PlayingIndex(a5),(sp)
			move.l	vmp_PlayingFrom(a5),4(sp)

			; 3. Write index and source
			movea.l	vmp_DosBase(a5),a6
			move.l	d4,d1					; file handle
			move.l	sp,d2					; buffer
			moveq	#8,d3					; size
			LVO	Write

			adda.l	#8,sp					; restore stack pointer

			; 4. Close the file
			movea.l	vmp_DosBase(a5),a6
			move.l	d4,d1					; file handle
			LVO	Close

.doneSave		movem.l	(sp)+,d2/d4/a6
			rts



			;------------------------------------------------------------
			; _RestoreStateOnStartup
			;------------------------------------------------------------
			; Input: None
			;------------------------------------------------------------
_RestoreStateOnStartup	movem.l	d2-d4/a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Check if playlist is empty
			tst.l	vmp_PlaylistCount(a5)
			beq.s	.doneRestore

			; 2. Attempt to open state file for reading
			movea.l	vmp_DosBase(a5),a6
			lea	txt_DefaultStatePath,a0
			move.l	a0,d1					; filename
			move.l	#MODE_OLDFILE,d2
			LVO	Open
			move.l	d0,d4					; d4 = file handle
			beq.s	.fallbackFirst			; open failed (use fallback)

			; 3. Allocate buffer on stack for reading two LONGs
			suba.l	#8,sp
			movea.l	vmp_DosBase(a5),a6
			move.l	d4,d1					; file handle
			move.l	sp,d2					; buffer
			moveq	#8,d3					; size
			LVO	Read
			
			; Preserve read result (d0 = number of bytes read)
			move.l	d0,d3

			; Close the file immediately
			movea.l	vmp_DosBase(a5),a6
			move.l	d4,d1					; file handle
			LVO	Close

			; Check if we read exactly 8 bytes
			cmp.l	#8,d3
			bne.s	.freeStackFallback

			; 4. Retrieve saved values from stack
			move.l	(sp),d0					; d0 = SavedIndex
			move.l	4(sp),d1				; d1 = SavedFrom
			adda.l	#8,sp					; free stack buffer

			; 5. Validate: SavedFrom == VMP_PLAYINGFROM_PLAYLIST AND SavedIndex < PlaylistCount
			cmp.l	#VMP_PLAYINGFROM_PLAYLIST,d1
			bne.s	.fallbackFirst
			cmp.l	vmp_PlaylistCount(a5),d0
			bhs.s	.fallbackFirst

			; State is valid! Set active index and source
			move.l	d0,vmp_PlayingIndex(a5)
			move.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)
			bra.s	.loadSong

.freeStackFallback	adda.l	#8,sp					; free stack buffer if read failed after alloc
.fallbackFirst
			; Fallback: Load first song in playlist (index 0)
			move.l	#0,vmp_PlayingIndex(a5)
			move.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)

.loadSong
			; 6. Retrieve PlaylistEntry pointer using MUIM_List_GetEntry
			lea	vmp_TempVariable(a5),a1
			DOMETHOD	vmp_MUI_PlaylistList(a5), #MUIM_List_GetEntry, vmp_PlayingIndex(a5), a1
			move.l	vmp_TempVariable(a5),a0
			tst.l	a0
			beq.s	.doneRestore

			; Set active entry visually in the Playlist MUI List view
			move.l	vmp_PlayingIndex(a5),d2
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistList(a5),a0
			INITSTACKTAG
			STACKREGTAG	d2, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Set autoloading flag so _NewMP3 loads in absolute silence
			move.l	#1,vmp_Autoloading(a5)

			; Load path
			move.l	vmp_TempVariable(a5),a0
			lea	ple_Path(a0),a0
			bsr	_NewMP3

.doneRestore		movem.l	(sp)+,d2-d4/a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonLoadPL
			;------------------------------------------------------------
_PlaylistButtonLoadPL	movem.l	d5/a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Check if playing, and temporarily pause
			move.l	vmp_Playing(a5),d5			; Save current playing state in d5
			beq.s	.noPauseLoad
			tst.l	vmp_Paused(a5)
			bne.s	.noPauseLoad				; If already paused, do nothing

			bsr	_PausePlayer

.noPauseLoad		; 2. Open ASL File Requester for loading
			lea	vmp_FilenameBuffer,a0
			bsr	_AskFile
			tst.l	d0
			beq.s	.resumeLoad

			; 3. Load the playlist from chosen file
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadPlaylistFromFile

.resumeLoad		; 4. Resume if we paused
			tst.l	d5
			beq.s	.doneLoadBtn
			tst.l	vmp_Paused(a5)
			beq.s	.doneLoadBtn
			bsr	_ResumePlayer

.doneLoadBtn		moveq	#0,d0
			movem.l	(sp)+,d5/a0/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonSavePL
			;------------------------------------------------------------
_PlaylistButtonSavePL	movem.l	d5/a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Check if playing, and temporarily pause
			move.l	vmp_Playing(a5),d5			; Save current playing state in d5
			beq.s	.noPauseSave
			tst.l	vmp_Paused(a5)
			bne.s	.noPauseSave				; If already paused, do nothing

			bsr	_PausePlayer

.noPauseSave		; 2. Open ASL File Requester for saving
			lea	vmp_FilenameBuffer,a0
			bsr	_AskFileSave
			tst.l	d0
			beq.s	.resumeSave

			; 3. Save the playlist to chosen file
			lea	vmp_FilenameBuffer,a0
			bsr	_SavePlaylistToFile

.resumeSave		; 4. Resume if we paused
			tst.l	d5
			beq.s	.doneSaveBtn
			tst.l	vmp_Paused(a5)
			beq.s	.doneSaveBtn
			bsr	_ResumePlayer

.doneSaveBtn		moveq	#0,d0
			movem.l	(sp)+,d5/a0/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistShuffle
			;------------------------------------------------------------

_PlaylistShuffle
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			eori.l	#1,vmp_PlaylistShuffle(a5)

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistShuffle(a5),a0
			tst.l	vmp_PlaylistShuffle(a5)
			beq.s	.shuffleOff
			lea	txt_PlaylistShuffleOn,a1
			bra.s	.updateText
.shuffleOff		lea	txt_PlaylistShuffleOff,a1
.updateText		INITSTACKTAG
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistLoop
			;------------------------------------------------------------

_PlaylistLoop
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			move.l	vmp_PlaylistLoop(a5),d0
			addq.l	#1,d0
			cmp.l	#3,d0
			blt.s	.stateOk
			moveq	#0,d0
.stateOk		move.l	d0,vmp_PlaylistLoop(a5)

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistLoop(a5),a0
			
			cmp.l	#1,d0
			beq.s	.loopTrack
			cmp.l	#2,d0
			beq.s	.loopAll
			lea	txt_PlaylistLoopOff,a1
			bra.s	.updateText
.loopTrack		lea	txt_PlaylistLoopTrack,a1
			bra.s	.updateText
.loopAll		lea	txt_PlaylistLoopAll,a1

.updateText		INITSTACKTAG
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonUp
			;------------------------------------------------------------

_PlaylistButtonUp
			movem.l	d2-d3/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			movea.l	vmp_MUI_PlaylistList(a5),a2

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a2,a0				; Now a0 holds the List object
			move.l	#MUIA_List_Active,d0
			lea	vmp_TempVariable(a5),a1
			LVO	GetAttr
			move.l	vmp_TempVariable(a5),d2
			cmp.l	#MUIV_List_Active_Off,d2
			beq.s	.done
			tst.l	d2
			beq.s	.done

			move.l	d2,d3
			subq.l	#1,d3
			DOMETHOD a2, #MUIM_List_Exchange, d2, d3

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a2,a0
			INITSTACKTAG
			STACKREGTAG	d3, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			moveq	#0,d0
			movem.l	(sp)+,d2-d3/a2-a6
			rts



			;------------------------------------------------------------
			; _PlaylistButtonDown
			;------------------------------------------------------------

_PlaylistButtonDown
			movem.l	d2-d3/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5
			movea.l	vmp_MUI_PlaylistList(a5),a2

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a2,a0				; Now a0 holds the List object
			move.l	#MUIA_List_Active,d0
			lea	vmp_TempVariable(a5),a1
			LVO	GetAttr
			move.l	vmp_TempVariable(a5),d2
			cmp.l	#MUIV_List_Active_Off,d2
			beq.s	.done

			move.l	vmp_PlaylistCount(a5),d3
			subq.l	#1,d3
			cmp.l	d3,d2
			bge.s	.done

			move.l	d2,d3
			addq.l	#1,d3
			DOMETHOD a2, #MUIM_List_Exchange, d2, d3

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	a2,a0
			INITSTACKTAG
			STACKREGTAG	d3, MUIA_List_Active
			CALLSTACKTAG	_LVOSetAttrsA,a1

.done			moveq	#0,d0
			movem.l	(sp)+,d2-d3/a2-a6
			rts



			;------------------------------------------------------------
			; _PlaylistGotAppMessage
			;------------------------------------------------------------

_PlaylistGotAppMessage
			movem.l	d2-d4/a2-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			movea.l	(a1),a1						; a1 = AppMessage
			tst.l	a1
			beq.s	.done

			tst.l	am_NumArgs(a1)
			beq.s	.done

			move.l	am_NumArgs(a1),d4			; d4 = args count
			movea.l	am_ArgList(a1),a2			; a2 = WBArg pointer

.loopArgs		movea.l	vmp_DosBase(a5),a6
			move.l	wa_Lock(a2),d1
			move.l	#vmp_FilenameBuffer,d2
			move.l	#255,d3
			LVO	NameFromLock
			tst.l	d0
			beq.s	.nextArg

			move.l	#vmp_FilenameBuffer,d1
			move.l	wa_Name(a2),d2
			move.l	#255,d3
			LVO	AddPart
			tst.l	d0
			beq.s	.nextArg

			move.l	#vmp_FilenameBuffer,d1
			move.l	#ACCESS_READ,d2
			LVO	Lock
			move.l	d0,d3
			beq.s	.nextArg

			move.l	#DOS_FIB,d1
			moveq	#0,d2
			LVO	AllocDosObject
			movea.l	d0,a3
			tst.l	d0
			beq.s	.unlockArg

			move.l	d3,d1
			move.l	a3,d2
			LVO	Examine
			tst.l	d0
			beq.s	.freeFibArg

			move.l	fib_DirEntryType(a3),d0
			blt.s	.isFileArg
			bgt.s	.isDirArg
			bra.s	.freeFibArg

.isFileArg		lea	vmp_FilenameBuffer,a0
			bsr	_PlaylistAddSingleFile
			bra.s	.freeFibArg

.isDirArg		lea	vmp_FilenameBuffer,a0
			bsr	_PlaylistAddSingleDir

.freeFibArg		movea.l	vmp_DosBase(a5),a6
			move.l	#DOS_FIB,d1
			move.l	a3,d2
			LVO	FreeDosObject

.unlockArg		movea.l	vmp_DosBase(a5),a6
			move.l	d3,d1
			LVO	UnLock

.nextArg		adda.l	#8,a2					; WBArg is 8 bytes
			subq.l	#1,d4
			bne.s	.loopArgs

.done			moveq	#0,d0
			movem.l	(sp)+,d2-d4/a2-a6
			rts



			;------------------------------------------------------------
			; _AskDir
			;------------------------------------------------------------

_AskDir			movem.l	d1/d5/a0-a3/a6,-(sp)

			moveq	#0,d5
			movea.l	a0,a3							; a3 = buffer

			movea.l	vmp_ASLBase(a5),a6
			move.l	#ASL_FileRequest,d0
			suba.l	a0,a0
			LVO	AllocAslRequest
			movea.l	d0,a2							; a2 = requester
			beq.s	.error
	
			; Check settings default MP3 folder path
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsDefaultMP3Path(a5),a0
			move.l	#MUIA_String_Contents,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			move.l	vmp_MUI_TempFilePointer(a5),d2			; d2 = initial drawer path (or 0)

			suba.l	#24,sp
			movea.l	sp,a1

			move.l	#ASLFR_DrawersOnly,(a1)
			move.l	#TRUE,4(a1)

			; If we have a default path in d2, pass it!
			tst.l	d2
			beq.s	.noDefaultDir
			movea.l	d2,a0
			tst.b	(a0)
			beq.s	.noDefaultDir

			move.l	#ASLFR_InitialDrawer,8(a1)
			move.l	d2,12(a1)
			move.l	#TAG_DONE,16(a1)
			bra.s	.tagDone

.noDefaultDir
			move.l	#TAG_DONE,8(a1)
.tagDone
			movea.l	a2,a0
			movea.l	vmp_ASLBase(a5),a6
			LVO	AslRequest
			adda.l	#24,sp
			
			move.l	d0,d5
			beq.s	.canceled
			
			movea.l	fr_Drawer(a2),a0
			cmp.b	#0,(a0)
			beq.s	.pathDone

.pathLoop		move.b	(a0)+,d0
			move.b	d0,(a3)+
			cmp.b	#0,d0
			bne.s	.pathLoop
			
			suba.l	#1,a3
			cmp.b	#"/",-1(a3)
			beq.s	.pathDone
			cmp.b	#":",-1(a3)
			beq.s	.pathDone
			move.b	#0,(a3)

.pathDone
.canceled		movea.l	a2,a0
			LVO	FreeAslRequest

.error			move.l	d5,d0
			movem.l	(sp)+,d1/d5/a0-a3/a6
			rts



			;------------------------------------------------------------
			; _PlaylistListDoubleclick
			;------------------------------------------------------------

_PlaylistListDoubleclick
			movem.l	a5,-(sp)
			movea.l	vmp_StructPointer,a5
			bsr	_PlaylistClicked
			movem.l	(sp)+,a5
			rts



			;------------------------------------------------------------
			; _PlaylistClicked
			;------------------------------------------------------------

_PlaylistClicked	movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; 1. Get active entry index in playlist
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistList(a5),a0
			move.l	#MUIA_List_Active,d0
			lea	vmp_PlayingIndex(a5),a1
			LVO	GetAttr
			cmp.l	#MUIV_List_Active_Off,vmp_PlayingIndex(a5)
			beq.s	.done

			; 2. Retrieve PlaylistEntry pointer
			lea	vmp_TempVariable(a5),a1
			DOMETHOD	vmp_MUI_PlaylistList(a5), #MUIM_List_GetEntry, vmp_PlayingIndex(a5), a1
			move.l	vmp_TempVariable(a5),a0
			tst.l	a0
			beq.s	.done

			; 3. Format name on status text
			move.l	vmp_TempVariable(a5),a1
			movea.l	vmp_MUI_MainWdwStatusText(a5),a0
			INITSTACKTAG
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; 4. Set playing flag
			move.l	#VMP_PLAYINGFROM_PLAYLIST,vmp_PlayingFrom(a5)

			; 5. Load and play MP3
			bsr	_PausePlayer
			move.l	vmp_TempVariable(a5),a0
			lea	ple_Path(a0),a0
			bsr	_NewMP3
			tst.l	d0
			beq.s	.done
			bsr	_ResumePlayer

.done			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _PlaylistUpdateStatus
			;------------------------------------------------------------

_PlaylistUpdateStatus
			movem.l	d0-d2/a0-a2/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			lea	vmp_PlaylistStatusBuf,a0
			move.b	#'T',(a0)+
			move.b	#'r',(a0)+
			move.b	#'a',(a0)+
			move.b	#'c',(a0)+
			move.b	#'k',(a0)+
			move.b	#'s',(a0)+
			move.b	#':',(a0)+
			move.b	#' ',(a0)+

			move.l	vmp_PlaylistCount(a5),d0
			bsr	_IntegerToString

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistStatusText(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_PlaylistStatusBuf, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			movem.l	(sp)+,d0-d2/a0-a2/a5-a6
			rts

_IntegerToString	movem.l	d3/a1,-(sp)
			move.l	a0,a1
			tst.l	d0
			bne.s	.nonZero
			move.b	#'0',(a1)+
			bra.s	.finish
.nonZero		moveq	#0,d3
.loop			tst.l	d0
			beq.s	.pop
			divu.w	#10,d0
			swap	d0
			move.w	d0,d1
			addi.b	#'0',d1
			move.w	d1,-(sp)
			addq.l	#1,d3
			clr.w	d0
			swap	d0
			ext.l	d0
			bra.s	.loop
.pop			move.w	(sp)+,d1
			move.b	d1,(a1)+
			subq.l	#1,d3
			bne.s	.pop
.finish			move.b	#0,(a1)
			movem.l	(sp)+,d3/a1
			rts



			;------------------------------------------------------------
			; _SettingsButtonClose
			;------------------------------------------------------------

_SettingsButtonClose
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Close Settings window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _SettingsButtonSave
			;------------------------------------------------------------

_SettingsButtonSave
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			DOMETHOD	vmp_MUI_Application(a5),#MUIM_Application_Save, #MUIV_Application_Save_ENVARC
			bsr	_SettingsButtonClose
			
			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _AboutButtonClose
			;------------------------------------------------------------

_AboutButtonClose
			movem.l	a0-a1/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Close About window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_AboutWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0-a1/a5-a6
			rts



			;------------------------------------------------------------
			; _MenuAbout
			;------------------------------------------------------------

_MenuAbout		movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Open About window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_AboutWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _MenuSettings
			;------------------------------------------------------------

_MenuSettings		movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			; *** Open Settings window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	1,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			moveq	#0,d0
			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _MenuCompact
			;------------------------------------------------------------

_MenuCompact		movem.l	a0/a5-a6,-(sp)
			movea.l	vmp_StructPointer,a5

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MenuPlayerCompact(a5),a0
			move.l	#MUIA_Menuitem_Checked,d0
			lea	vmp_MUI_TempFilePointer(a5),a1					; Not really a pointer. checked/unchecked
			LVO	GetAttr
			tst.l	d0
			beq.w	.done

			move.l	vmp_MUI_TempFilePointer(a5),d0
			cmp.l	#1,d0
			bne.s	.unchecked


			; Set initial label to create space for song name
			movea.l	vmp_MUI_CompactWdwLabel(a5),a0
			INITSTACKTAG
			STACKADRTAG	txt_CompactLabel, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; *** Open Compact window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_CompactWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	TRUE,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Update song name in Compact window
			movea.l	vmp_MUI_CompactWdwLabel(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_NameBuffer, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; *** Close main window ***
			movea.l	vmp_MUI_MainWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	FALSE,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Check menuitem
		;	movea.l	vmp_MUI_MenuPlayerCompact(a5),a0
		;	INITSTACKTAG
		;	STACKVALTAG	TRUE,MUIA_Menuitem_Toggle
		;	CALLSTACKTAG	_LVOSetAttrsA,a1
			bra.s	.done

.unchecked
			; Set initial label to create space for song name
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwTextSongName(a5),a0
			INITSTACKTAG
			STACKADRTAG	txt_CompactLabel, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; *** Open main window ***
			movea.l	vmp_MUI_MainWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	TRUE,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Update Song Name UI Text
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwTextSongName(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_NameBuffer, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; *** Close Compact window ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_CompactWindow(a5),a0
			INITSTACKTAG
			STACKVALTAG	FALSE,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1

			; Uncheck menuitem
		;	movea.l	vmp_MUI_MenuPlayerCompact(a5),a0
		;	INITSTACKTAG
		;	STACKVALTAG	TRUE,MUIA_Menuitem_Toggle
		;	CALLSTACKTAG	_LVOSetAttrsA,a1

.done			movem.l	(sp)+,a0/a5-a6
			rts



			;------------------------------------------------------------
			; _GetFileNamePart
			;
			; Input: a0 = Full path pointer
			; Output: a0 = File name part pointer
			;------------------------------------------------------------
_GetFileNamePart
			movem.l	a1,-(sp)
			move.l	a0,a1
.findEnd		tst.b	(a1)+
			bne.s	.findEnd
			subq.l	#2,a1								; point to last char
.loop			cmp.b	#'/',(a1)
			beq.s	.found
			cmp.b	#':',(a1)
			beq.s	.found
			subq.l	#1,a1
			cmp.l	a0,a1
			bhs.s	.loop
			bra.s	.done
.found			addq.l	#1,a1
			move.l	a1,a0
.done			movem.l	(sp)+,a1
			rts



			;------------------------------------------------------------
			; _UpdateUIProgress
			;------------------------------------------------------------
_UpdateUIProgress
			movem.l	d0-d4/a0-a2/a6,-(sp)
			movea.l	vmp_StructPointer,a5
			
			tst.l	vmp_Playing(a5)
			beq.w	.exit
			
			; 1. Calculate Elapsed Time in Milliseconds
			; ElapsedMS = (vmp_DecodedSamples * 1000) / vmp_SongSampleRate
			move.l	vmp_DecodedSamples(a5),d0
			
			; Check if we have duration
			move.l	vmp_SongDuration(a5),d4
			beq.w	.exit
			
			; Avoid division by zero
			move.l	vmp_SongSampleRate(a5),d3
			beq.w	.exit
			
			; Calculate ElapsedMS = (DecodedSamples / SampleRate) * 1000 + ((DecodedSamples % SampleRate) * 1000) / SampleRate
			move.l	d0,d1
			divu.l	d3,d1								; d1 = Seconds (quotient)
			
			move.l	d1,d2								; d2 = Seconds
			mulu.l	d3,d2								; d2 = Seconds * SampleRate
			sub.l	d2,d0								; d0 = Remainder (DecodedSamples - d2)
			
			mulu.l	#1000,d0							; d0 = Remainder * 1000
			divu.l	d3,d0								; d0 = FractionalMS
			
			mulu.l	#1000,d1							; d1 = Seconds * 1000
			add.l	d0,d1								; d1 = ElapsedMS
			
			; Limit to vmp_SongDuration
			cmp.l	d4,d1
			bls.s	.timeOk
			move.l	d4,d1
.timeOk
			move.l	d1,d3								; Preserve ElapsedMS in d3 (preserved register) from clobbering
			
			; 2. Update Slider Value (if not grabbed)
			tst.l	vmp_SliderGrabbed(a5)
			bne.s	.skipSlider
			
			; SliderVal = (ElapsedMS * 1000) / vmp_SongDuration
			move.l	d3,d2								; d2 = ElapsedMS
			cmp.l	#4000000,d4							; check if duration is under 4 million ms (~66 mins)
			bcs.s	.sliderSafePrecision
			
			; Overflow-safe calculation for very long streams
			divu.l	#1000,d2							; d2 = ElapsedSeconds
			mulu.l	#1000,d2							; d2 = ElapsedSeconds * 1000
			move.l	d4,d0								; d0 = SongDuration
			divu.l	#1000,d0							; d0 = DurationSeconds
			divu.l	d0,d2								; d2 = SliderVal (0-1000)
			bra.s	.setSlider
			
.sliderSafePrecision
			mulu.l	#1000,d2
			divu.l	d4,d2								; d2 = SliderVal (0-1000)
			
.setSlider
			cmp.l	vmp_LastSliderVal(a5),d2
			beq.s	.skipSlider
			move.l	d2,vmp_LastSliderVal(a5)

			; Set Slider Value
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwSliderPosition(a5),a0
			INITSTACKTAG
			STACKREGTAG	d2, MUIA_Numeric_Value
			CALLSTACKTAG	_LVOSetAttrsA,a1
			
.skipSlider
			; 3. Format Time String "MM:SS / MM:SS"
			; Convert ElapsedMS (d3) to minutes and seconds
			move.l	d3,d1								; Restore ElapsedMS from preserved d3 into d1
			divu.l	#1000,d1							; d1 = ElapsedSeconds
			
			cmp.l	vmp_LastTimeSecs(a5),d1
			beq.s	.exit
			move.l	d1,vmp_LastTimeSecs(a5)
			
			move.l	d1,d0								; d0 = ElapsedSeconds
			divu.w	#60,d0								; d0.w = quotient (minutes), d0.hw = remainder (seconds)
			move.l	d0,d2								; Keep quotient & remainder in d2
			
			; Convert TotalMS (d4) to minutes and seconds
			divu.l	#1000,d4							; d4 = TotalSeconds
			move.l	d4,d0
			divu.w	#60,d0								; d0.w = quotient (minutes), d0.hw = remainder (seconds)
			move.l	d0,d3								; Keep quotient & remainder in d3
			
			; Format time string: "MM:SS / MM:SS"
			; We will write it into vmp_TimeBuffer
			lea	vmp_TimeBuffer,a0
			move.b	#27,(a0)+							; ESC
			move.b	#'c',(a0)+							; Center command
			
			; Elapsed Minutes
			move.w	d2,d0								; d0 = minutes
			bsr.s	.write2Digits
			move.b	#':',(a0)+
			
			; Elapsed Seconds
			swap	d2
			move.w	d2,d0								; d0 = seconds
			bsr.s	.write2Digits
			
			; Separator
			move.b	#' ',(a0)+
			move.b	#'/',(a0)+
			move.b	#' ',(a0)+
			
			; Total Minutes
			move.w	d3,d0								; d0 = minutes
			bsr.s	.write2Digits
			move.b	#':',(a0)+
			
			; Total Seconds
			swap	d3
			move.w	d3,d0								; d0 = seconds
			bsr.s	.write2Digits
			
			move.b	#0,(a0)								; Null-terminate
			
			; Update Time UI Text
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwTextTime(a5),a0
			INITSTACKTAG
			STACKADRTAG	vmp_TimeBuffer, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1
			
.exit		movem.l	(sp)+,d0-d4/a0-a2/a6
			rts

; Local helper to write 2 digits of d0 to a0
.write2Digits
			andi.l	#$ffff,d0							; Clear high word of d0 to prevent division overflow/garbage
			divu.w	#10,d0
			add.b	#'0',d0								; Tens digit
			move.b	d0,(a0)+
			swap	d0
			add.b	#'0',d0								; Units digit
			move.b	d0,(a0)+
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
			SHOWALERT	txt_ClassAlert
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
			cmp.l	#$00000103,d0					; OM_SET
			beq.s	.set
            
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

.set			movem.l	a0-a2/a6,-(sp)
			move.l	a1,-(sp)
			bsr.w	.super
			move.l	(sp)+,a1
			movem.l	(sp)+,a0-a2/a6

			; Fetch instance data
			movea.l	vmp_CustomButtonClass(a5),a3
			movea.l	24(a3),a3					; a3 = IClass *
			moveq	#0,d1
			move.w	32(a3),d1					; cl_InstOffset
			lea	(a2,d1.l),a3					; a3 = Instance data

			move.l	4(a1),d0					; ops_AttrList
			beq.s	.setExit
			
			movea.l	d0,a0						; a0 = Taglist
			moveq	#0,d5						; d5 = redraw flag
.setTagLoop		move.l	(a0)+,d0
			beq.s	.setDone
			
			cmp.l	#CUSTOMBTN_Image,d0
			beq.s	.setImage
			addq.l	#4,a0
			bra.s	.setTagLoop

.setImage		move.l	(a0)+,d0
			move.l	d0,(a3)						; Update image ptr
			moveq	#1,d5
			bra.s	.setTagLoop

.setDone		tst.l	d5
			beq.s	.setExit

			; Only request redraw if the main window is fully initialized
			tst.l	vmp_MUI_MainWindow(a5)
			beq.s	.setExit

			movem.l	d0-d1/a0-a1/a6,-(sp)
			movea.l	vmp_MUIBase(a5),a6
			movea.l	a2,a0
			moveq	#1,d0						; MADF_DRAWOBJECT
			jsr	_LVOMUI_Redraw(a6)
			movem.l	(sp)+,d0-d1/a0-a1/a6

.setExit		moveq	#0,d0
.setExit2		bra.w	.exit

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
	
			; Check settings default MP3 folder path
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsDefaultMP3Path(a5),a0
			move.l	#MUIA_String_Contents,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			move.l	vmp_MUI_TempFilePointer(a5),d2

			tst.l	d2
			beq.s	.noDefaultFileTags
			movea.l	d2,a0
			tst.b	(a0)
			beq.s	.noDefaultFileTags

			suba.l	#16,sp
			movea.l	sp,a1
			move.l	#ASLFR_InitialDrawer,(a1)
			move.l	d2,4(a1)
			move.l	#TAG_DONE,8(a1)

			movea.l	a2,a0
			movea.l	vmp_ASLBase(a5),a6
			LVO	AslRequest
			adda.l	#16,sp
			bra.s	.fileReqDone

.noDefaultFileTags
			movea.l	a2,a0
			suba.l	a1,a1
			movea.l	vmp_ASLBase(a5),a6
			LVO	AslRequest

.fileReqDone
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
			; _AskFileSave
			;
			; Input:
			;	a0 = pointer to filename buffer
			; Result:
			;	d0 = FALSE if no file is picked
			;------------------------------------------------------------
_AskFileSave		movem.l	d1/d5/a0-a3/a6,-(sp)

			moveq	#0,d5
			movea.l	a0,a3							; a3 = buffer

			movea.l	vmp_ASLBase(a5),a6
			move.l	#ASL_FileRequest,d0
			suba.l	a0,a0
			LVO	AllocAslRequest
			movea.l	d0,a2							; a2 = requester
			beq.s	.errorSave
	
			; Check settings default MP3 folder path
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsDefaultMP3Path(a5),a0
			move.l	#MUIA_String_Contents,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			move.l	vmp_MUI_TempFilePointer(a5),d2

			tst.l	d2
			beq.s	.noDefaultFileTagsSave
			movea.l	d2,a0
			tst.b	(a0)
			beq.s	.noDefaultFileTagsSave

			suba.l	#24,sp
			movea.l	sp,a1
			move.l	#ASLFR_InitialDrawer,(a1)
			move.l	d2,4(a1)
			move.l	#ASLFR_DoSaveMode,8(a1)
			move.l	#TRUE,12(a1)
			move.l	#TAG_DONE,16(a1)

			movea.l	a2,a0
			movea.l	vmp_ASLBase(a5),a6
			LVO	AslRequest
			adda.l	#24,sp
			bra.s	.fileReqDoneSave

.noDefaultFileTagsSave
			suba.l	#16,sp
			movea.l	sp,a1
			move.l	#ASLFR_DoSaveMode,(a1)
			move.l	#TRUE,4(a1)
			move.l	#TAG_DONE,8(a1)

			movea.l	a2,a0
			movea.l	vmp_ASLBase(a5),a6
			LVO	AslRequest
			adda.l	#16,sp

.fileReqDoneSave
			move.l	d0,d5
			beq.s	.canceledSave
			
			; Copy path to buffer
			movea.l	fr_Drawer(a2),a0
			cmp.b	#0,(a0)
			beq.s	.pathDoneSave

.pathLoopSave		move.b	(a0)+,d0
			move.b	d0,(a3)+
			cmp.b	#0,d0
			bne.s	.pathLoopSave
			
			; add "/" if applicable
			suba.l	#1,a3
			cmp.b	#":",-1(a3)
			beq.s	.pathDoneSave
			move.b	#"/",(a3)+	

.pathDoneSave		; Copy filename to buffer
			movea.l	fr_File(a2),a0
.fileLoopSave		move.b	(a0)+,d0
			move.b	d0,(a3)+
			cmp.b	#0,d0
			bne.s	.fileLoopSave

.canceledSave		movea.l	a2,a0
			LVO	FreeAslRequest

.errorSave		move.l	d5,d0
			movem.l	(sp)+,d1/d5/a0-a3/a6
			rts



			;------------------------------------------------------------
			; _SetStatus
			;------------------------------------------------------------
			; Input:
			;	d0 = Status

_SetStatus		movem.l	d0-d2/a0-a1/a6,-(sp)
			move.l	d0,d2

			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_MainWdwStatusText(a5),a0
			lea	vmp_StatusTable,a1
			lsl.l	#2,d0
			adda.l	d0,a1
			movea.l	(a1),a1
			INITSTACKTAG
			STACKREGTAG	a1, MUIA_Text_Contents
			CALLSTACKTAG	_LVOSetAttrsA,a1
			
			; Synchronize Play/Pause button image with the new status
			cmp.l	#VMP_STATUS_PLAYING,d2
			beq.s	.setStatusPlaying
			
			; Not playing (Idle, Error, etc.) -> show Play image
			DOMETHOD vmp_MUI_MainWdwButtonPlay(a5), #MUIM_Set, #CUSTOMBTN_Image, vmp_ImgBuffer_Play(a5)
			bra.s	.setStatusDone

.setStatusPlaying
			; Playing -> show Pause image
			DOMETHOD vmp_MUI_MainWdwButtonPlay(a5), #MUIM_Set, #CUSTOMBTN_Image, vmp_ImgBuffer_Pause(a5)

.setStatusDone
			movem.l	(sp)+,d0-d2/a0-a1/a6
			rts


			section data,Data

				; Main window
txt_MainWindowTitle		dc.b	"VaMP3",0
txt_MainWdwPlaylist		dc.b	"Playlist",0
txt_MainWdwDirlist		dc.b	"Dirlist",0

				; Dirlist window
txt_DirlistWindowTitle		dc.b	"Directory listing",0
txt_DirlistParent		dc.b	27,"c","Parent",0

vmp_FilePattern			dc.b	"#?.mp3",0
vmp_FilePatternToken		ds.b	32

				; Playlist window
txt_PlaylistWindowTitle		dc.b	"Playlist",0
txt_PlaylistAddFile		dc.b	27,"c","Add file",0
txt_PlaylistAddDir		dc.b	27,"c","Add directory",0
txt_PlaylistRemove		dc.b	27,"c","Remove",0
txt_PlaylistClear		dc.b	27,"c","Clear",0
txt_PlaylistUp			dc.b	27,"c","Move Up",0
txt_PlaylistDown		dc.b	27,"c","Move Down",0
txt_PlaylistShuffleOff		dc.b	27,"c","Shuffle: Off",0
txt_PlaylistShuffleOn		dc.b	27,"c","Shuffle: On",0
txt_PlaylistLoopOff		dc.b	27,"c","Loop: Off",0
txt_PlaylistLoopTrack		dc.b	27,"c","Loop: Track",0
txt_PlaylistLoopAll		dc.b	27,"c","Loop: Playlist",0
txt_PlaylistStatusEmpty		dc.b	"Tracks: 0",0
txt_DefaultPlaylistPath		dc.b	"PROGDIR:vaMP3.playlist",0
txt_DefaultStatePath		dc.b	"PROGDIR:vaMP3.state",0

				; Settings window
txt_SettingsWindowTitle		dc.b	"Settings",0
txt_SettingsSave		dc.b	27,"c","Save",0
txt_SettingsDefaultMP3Folder	dc.b	"Default MP3 Folder",0
txt_SettingsImagePath		dc.b	"Path to Tapedeck buttons",0

				; About window
txt_AboutWindowTitle		dc.b	"About VaMP3",0
txt_AboutLabel			dc.b	10,10
				dc.b	27,"b"							; bold style
				dc.b	27,"c","VaMP3 v",VAMP3_VERSION+"0",".",VAMP3_REVISION+"0"," Copyright (c) 2026 Bedroomcoders.com",10,10
				dc.b	27,"n"							; normal style
				dc.b	27,"c","68080 assembly by Tjomp",10
				dc.b	27,"c","Graphics by HANSolo",10,10
				dc.b	27,"c","Sources available on Github",0

				; Compact window
txt_CompactWindowTitle		dc.b	"VaMP3 - Now playing:",0
txt_CompactLabel	;	dc.b	"Compact label",0
				dc.b	$1b,"    - No song loaded -    ",0

				; Menu
txt_Menu_File			dc.b	"File",0
txt_Menu_FileLoadPL		dc.b	"Load playlist",0
txt_Menu_FileSavePL		dc.b	"Save playlist",0
txt_Menu_FileAbout		dc.b	"About",0
txt_Menu_FileQuit		dc.b	"Quit",0
txt_Menu_Preferences		dc.b	"Preferences",0
txt_Menu_PrefsSettings		dc.b	"Settings",0
txt_Menu_PrefsMUISettings	dc.b	"MUI Settings",0
txt_Menu_Player			dc.b	"Player",0
txt_Menu_PlayerPlayPause	dc.b	"Play/Pause",0
txt_Menu_PlayerNext		dc.b	"Next",0
txt_Menu_PlayerPrevious		dc.b	"Previous",0
txt_Menu_PlayerPlaylist		dc.b	"Playlist",0
txt_Menu_PlayerDirlist		dc.b	"Dirlist",0
txt_Menu_PlayerCompact		dc.b	"Compact view",0

				; Shortcut
txt_Shortcut_LoadPL		dc.b	"L",0
txt_Shortcut_SavePL		dc.b	"S",0
txt_Shortcut_About		dc.b	"?",0
txt_Shortcut_Quit		dc.b	"Q",0
txt_Shortcut_Settings		dc.b	"I",0
txt_Shortcut_MUISettings	dc.b	"M",0
txt_Shortcut_PlayPause		dc.b	"A",0
txt_Shortcut_Next		dc.b	"X",0
txt_Shortcut_Previous		dc.b	"Z",0
txt_Shortcut_Playlist		dc.b	"P",0
txt_Shortcut_Dirlist		dc.b	"D",0
txt_Shortcut_Compact		dc.b	"C",0

				; Application
txt_ApplicationTitle		dc.b	"VaMP3",0
txt_AppBase			dc.b	"VAMP3",0

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
MUIC_Aboutmui			dc.b	"Aboutmui.mui",0

vmp_CustomButton_Name		dc.b	"VaMP3CustomButton.mui",0
				even

vmp_Signals			ds.l	1							; Referenced from vmp_Method_Input structure

				; Main windows hooks
vmp_Hook_MainWdwButtonDirlist	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonDirlist				; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPlay	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPlay					; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonNext	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonNext					; h_entry - Pointing to routine to be exeh^ed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPrevious	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPrevious					; h_entry - Pointing to routine to be exeh^ed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwButtonPlaylist	ds.b	MLN_SIZE
				dc.l	_MainWdwButtonPlaylist					; h_entry - Pointing to routine to be executed
				dc.l	0,0							; h_SubEntry, h_data

vmp_Hook_MainWdwSliderVolume	ds.b	MLN_SIZE
				dc.l	_MainWdwSliderVolumeChanged
				dc.l	0,0

vmp_Hook_MainWdwAppMessage	ds.b	MLN_SIZE
				dc.l	_MainWdwGotAppMessage
				dc.l	0,0

vmp_Hook_MainWdwSliderPositionGrabbed	ds.b	MLN_SIZE
				dc.l	_MainWdwSliderPositionGrabbed
				dc.l	0,0

vmp_Hook_MainWdwSliderPositionReleased	ds.b	MLN_SIZE
				dc.l	_MainWdwSliderPositionReleased
				dc.l	0,0

				; Dirlist window hooks
vmp_Hook_DirlistButtonClose	ds.b	MLN_SIZE
				dc.l	_DirlistButtonClose
				dc.l	0,0

vmp_Hook_DirlistListview		ds.b	MLN_SIZE
				dc.l	_DirlistClicked
				dc.l	0,0

vmp_Hook_DirlistDirChanged	ds.b	MLN_SIZE
				dc.l	_DirlistDirChanged
				dc.l	0,0

vmp_Hook_DirlistParent		ds.b	MLN_SIZE
				dc.l	_DirlistParent
				dc.l	0,0

				; Playlist window hooks
vmp_Hook_PlaylistButtonClose	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonClose
				dc.l	0,0
				
vmp_Hook_PlaylistButtonAddFile	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonAddFile
				dc.l	0,0

vmp_Hook_PlaylistButtonAddDir	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonAddDir
				dc.l	0,0

vmp_Hook_PlaylistButtonRemove	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonRemove
				dc.l	0,0

vmp_Hook_PlaylistButtonClear	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonClear
				dc.l	0,0

vmp_Hook_PlaylistButtonUp	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonUp
				dc.l	0,0

vmp_Hook_PlaylistButtonDown	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonDown
				dc.l	0,0

vmp_Hook_PlaylistButtonLoadPL	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonLoadPL
				dc.l	0,0

vmp_Hook_PlaylistButtonSavePL	ds.b	MLN_SIZE
				dc.l	_PlaylistButtonSavePL
				dc.l	0,0

vmp_Hook_PlaylistShuffle	ds.b	MLN_SIZE
				dc.l	_PlaylistShuffle
				dc.l	0,0

vmp_Hook_PlaylistLoop		ds.b	MLN_SIZE
				dc.l	_PlaylistLoop
				dc.l	0,0

vmp_Hook_PlaylistAppMessage	ds.b	MLN_SIZE
				dc.l	_PlaylistGotAppMessage
				dc.l	0,0

vmp_Hook_PlaylistListDoubleclick ds.b	MLN_SIZE
				dc.l	_PlaylistListDoubleclick
				dc.l	0,0

				; Settings window hooks
vmp_Hook_SettingsButtonClose	ds.b	MLN_SIZE
				dc.l	_SettingsButtonClose
				dc.l	0,0

vmp_Hook_SettingsButtonSave	ds.b	MLN_SIZE
				dc.l	_SettingsButtonSave
				dc.l	0,0
				
				; About window hooks
vmp_Hook_AboutButtonClose	ds.b	MLN_SIZE
				dc.l	_AboutButtonClose
				dc.l	0,0

				; Menu hooks
vmp_Hook_MenuSettings		ds.b	MLN_SIZE
				dc.l	_MenuSettings
				dc.l	0,0

vmp_Hook_MenuAbout		ds.b	MLN_SIZE
				dc.l	_MenuAbout
				dc.l	0,0

vmp_Hook_MenuCompact		ds.b	MLN_SIZE
				dc.l	_MenuCompact
				dc.l	0,0


vmp_EmptyTxt		dc.b	$1b,"cNo song loaded",0
vmp_DefaultTimeTxt	dc.b	$1b,"c00:00 / 00:00",0

				even
vmp_FilenameBuffer		ds.b	256


				; Status messages
			
			even
vmp_StatusTable		dc.l	vmp_StatusIdleTxt,vmp_StatusPlayingTxt,vmp_StatusOpenErrorTxt,vmp_StatusDecodingTxt,vmp_StatusPausedTxt,0
vmp_StatusIdleTxt	dc.b	$1b,"c","Idle",0
vmp_StatusPlayingTxt	dc.b	$1b,"c","Playing",0
vmp_StatusOpenErrorTxt	dc.b	$1b,"c","Error opening file.",0
vmp_StatusDecodingTxt	dc.b	$1b,"c","Decoding mp3.",0
vmp_StatusPausedTxt	dc.b	$1b,"c","Paused",0

			;------------------------------------------------------------
			; Local Status string buffer
			;------------------------------------------------------------

			even
vmp_PlaylistStatusBuf	ds.b	32

