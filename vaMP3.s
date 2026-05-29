**	File: vaMP3.s 
**	Platgorm: Apollo Vampire with MUI
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
			include	"intuition/classusr.i"
			include	"graphics/graphics_lib.i"
			include	"libraries/mui.i"
			include	"lvo/mui_lib.i"
			include	"lvo/asl_lib.i"
			include	"libraries/asl.i"
			include	"cybergraphics/cybergraphics_lib.i"
			include	"dos/dos.i"
			include	"dos/dosextens.i"
			include	"dos/dos_lib.i"
			include	"workbench/workbench.i"
			include	"workbench/startup.i"
			include	"datatypes/datatypes_lib.i"
			include	"datatypes/pictureclass.i"

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
			APTR	vmp_MPEGABase
			APTR	vmp_DosBase
			APTR	vmp_DatatypesBase
			APTR	vmp_CustomButtonClass
			LONG	vmp_Quit
			LONG	vmp_Playing
			LONG	vmp_Paused
			LONG	vmp_Volume
			LONG	vmp_PlayingFrom					; Started from Dirlist or Playlist?
			LONG	vmp_PlayingIndex				; Which song in the list?
			LONG	vmp_SongDuration
			LONG	vmp_SongSampleRate
			LONG	vmp_DecodedSamples
			LONG	vmp_SliderGrabbed
			APTR	vmp_Intui_Window
			APTR	vmp_Intui_UserPort
			LONG	vmp_InterruptSignal
			STRUCT	vmp_InterruptStruct,IS_SIZE
			APTR	vmp_OldInterrupt
			APTR	vmp_MainTask
			LONG	vmp_InterruptMask
			LONG	vmp_TempVariable
			APTR	vmp_MUI_Application
			APTR	vmp_MUI_MainWindow
			APTR	vmp_MUI_MainWdwGroup
			APTR	vmp_MUI_MainWdwButtonPlaylist
			APTR	vmp_MUI_MainWdwButtonDirlist
			APTR	vmp_MUI_MainWdwSliderVolume
			APTR	vmp_MUI_MainWdwButtonPlay
			APTR	vmp_MUI_MainWdwButtonNext
			APTR	vmp_MUI_MainWdwButtonPrevious
			APTR	vmp_MUI_MainWdwStatusText
			APTR	vmp_MUI_MainWdwSliderPosition
			APTR	vmp_MUI_MainWdwTextTime
			APTR	vmp_MUI_MainWdwTextSongName
			APTR	vmp_MUI_MainWdwButtonHGroup
			APTR	vmp_MUI_MainWdwVGroup
			APTR	vmp_MUI_DirlistWindow
			APTR	vmp_MUI_DirlistVGroup
			APTR	vmp_MUI_DirlistList
			APTR	vmp_MUI_DirlistListview
			APTR	vmp_MUI_DirlistPopDrawer
			APTR	vmp_MUI_DirlistParentButton
			APTR	vmp_MUI_DirlistDirString
			APTR	vmp_MUI_DirlistPopasl
			APTR	vmp_MUI_DirlistHGroup1
			LONG	vmp_MUI_TempFilePointer
			APTR	vmp_MUI_PlaylistWindow
			APTR	vmp_MUI_PlaylistVGroup
			APTR	vmp_MUI_PlaylistList
			APTR	vmp_MUI_PlaylistListview
			APTR	vmp_MUI_PlaylistButtonAddFile
			APTR	vmp_MUI_PlaylistButtonAddDir
			APTR	vmp_MUI_PlaylistHGroup1
			APTR	vmp_MUI_PlaylistButtonRemove
			APTR	vmp_MUI_PlaylistButtonClear
			APTR	vmp_MUI_PlaylistButtonUp
			APTR	vmp_MUI_PlaylistButtonDown
			APTR	vmp_MUI_PlaylistStatusText
			APTR	vmp_MUI_PlaylistShuffle
			APTR	vmp_MUI_PlaylistLoop
			APTR	vmp_MUI_PlaylistHGroup2
			APTR	vmp_MUI_PlaylistHGroup3
			LONG	vmp_PlaylistShuffle
			LONG	vmp_PlaylistLoop
			LONG	vmp_PlaylistCount
			APTR	vmp_MUI_SettingsWindow
			APTR	vmp_MUI_SettingsHGroup1
			APTR	vmp_MUI_SettingsHGroup2
			APTR	vmp_MUI_SettingsVGroup
			APTR	vmp_MUI_SettingsSaveButton
			APTR	vmp_MUI_SettingsImagePath
			APTR	vmp_MUI_SettingsImagePathLabel
			APTR	vmp_MUI_SettingsImagePathPopdrawer
			APTR	vmp_MUI_SettingsImagePathPopasl
			APTR	vmp_MUI_SettingsDefaultMP3Label
			APTR	vmp_MUI_SettingsDefaultMP3Path
			APTR	vmp_MUI_SettingsDefaultMP3Popdrawer
			APTR	vmp_MUI_SettingsDefaultMP3Popasl
			APTR	vmp_MUI_AboutWindow
			APTR	vmp_MUI_AboutHGroup1
			APTR	vmp_MUI_AboutVGroup
			APTR	vmp_MUI_AboutLabel
			APTR	vmp_MUI_AboutLogo
			APTR	vmp_MUI_CompactWindow
			APTR	vmp_MUI_CompactWdwLabel
			APTR	vmp_MUI_CompactWdwVGroup
			APTR	vmp_MUI_Menustrip
			APTR	vmp_MUI_MenuFile
			APTR	vmp_MUI_MenuFileLoadPL
			APTR	vmp_MUI_MenuFileSavePL
			APTR	vmp_MUI_MenuFileAbout
			APTR	vmp_MUI_MenuFileQuit
			APTR	vmp_MUI_MenuPreferences
			APTR	vmp_MUI_MenuPrefsSettings
			APTR	vmp_MUI_MenuPrefsMUISettings
			APTR	vmp_MUI_MenuPlayer
			APTR	vmp_MUI_MenuPlayerPlayPause
			APTR	vmp_MUI_MenuPlayerNext
			APTR	vmp_MUI_MenuPlayerPrevious
			APTR	vmp_MUI_MenuPlayerPlaylist
			APTR	vmp_MUI_MenuPlayerDirlist
			APTR	vmp_MUI_MenuPlayerCompact
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
			APTR	vmp_ImgBuffer_Pause
			LONG	vmp_ImgWidth_Pause
			LONG	vmp_ImgHeight_Pause
			APTR	vmp_ImgBuffer_Play
			LONG	vmp_ImgWidth_Play
			LONG	vmp_ImgHeight_Play
			APTR	vmp_ImgBuffer_Next
			LONG	vmp_ImgWidth_Next
			LONG	vmp_ImgHeight_Next
			APTR	vmp_ImgBuffer_Prev
			LONG	vmp_ImgWidth_Prev
			LONG	vmp_ImgHeight_Prev
			APTR	vmp_ImgBuffer_Playlist
			LONG	vmp_ImgWidth_Playlist
			LONG	vmp_ImgHeight_Playlist
			APTR	vmp_ImgBuffer_Dirlist
			LONG	vmp_ImgWidth_Dirlist
			LONG	vmp_ImgHeight_Dirlist
		LABEL	vmp_SIZEOF



			section code,Code


			;-------------------------------------------------------------
			; Initial startup code for Workbench or Command Line Interface
			;-------------------------------------------------------------

_Startup		movem.l	d0/a0,-(sp)

			movea.l	$4.w,a6
			suba.l	a1,a1
			LVO	FindTask
			movea.l	d0,a4

			movea.l	d0,a1
			moveq	#1,d0
			LVO	SetTaskPri


			tst.l	pr_CLI(a4)			; was I called from CLI?
			bne.s	.fromCLI			; if so, skip out this bit...

			lea	pr_MsgPort(a4),a0
			LVO	WaitPort

			lea	pr_MsgPort(a4),a0
			LVO	GetMsg
			move.l	d0,vmp_WorkbenchMessage

.fromCLI		movem.l	(sp)+,d0/a0

			bsr	_Init

			move.l	d0,-(sp)

			tst.l	vmp_WorkbenchMessage		; Is there a message?
			beq.s	.Return				; if not, skip...

			movea.l	(4).w,a6
			movea.l	vmp_WorkbenchMessage,a1
			LVO	ReplyMsg

.Return			move.l	(sp)+,d0			; exit application
			rts



			;------------------------------------------------------------
			; _Init
			;------------------------------------------------------------

_Init			move.l	4.w,a6


			; Check if the MUI application port "VAMP3" is already running
			LVO	Forbid
			
			lea	vmp_UniquePortName,a1
			LVO	FindPort
			move.l	d0,d7
			
			LVO	Permit
			
			tst.l	d7
			beq.s	.notRunning
			moveq	#20,d0							; return FAIL if already running
			rts

.notRunning		move.l	#vmp_SIZEOF,d0
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
			bne.w	.cleanup
			move.l	#1,vmp_TimerDeviceBase(a5)				; Just set non-zero flag

			; Start timer
			lea	vmp_TimerReq(a5),a1
			move.w	#9,28(a1)						; io_Command = TR_ADDREQUEST
			move.l	#0,32(a1)						; tv_secs = 0
			move.l	#20000,36(a1)						; tv_micro = 20000 (20ms)
			movea.l	4.w,a6
			LVO	SendIO



			; Populate variables
			move.l	#VMP_AUDIO_VOLUME,vmp_Volume(a5)

			; Open Libs
			OPENLIB	Graphics,0
			beq	.cleanup

			OPENLIB	Intuition,0
			beq	.cleanup

			OPENLIB	CyberGfx, 41
			
			bne.s	.cgxOpened
			SHOWALERT	txt_CGXAlert
			bra	.cleanup

.cgxOpened		OPENLIB	MUI,0
			bne.s	.muiOpened
			SHOWALERT	txt_MUIAlert
			bra	.cleanup

.muiOpened		OPENLIB	ASL,0
			bne.s	.aslOpened
			SHOWALERT	txt_ASLAlert
			bra	.cleanup

.aslOpened		OPENLIB	MPEGA,0
			bne.s	.mpegaOpened
			SHOWALERT	txt_MPEGAAlert
			bra.w	.cleanup

.mpegaOpened		OPENLIB	Dos,37
			bne.s	.dosOpened
			SHOWALERT	txt_DosAlert
			bra.w	.cleanup

.dosOpened		OPENLIB	Datatypes,43
			bne.s	.dtOpened
			SHOWALERT	txt_DTAlert
			bra.w	.cleanup

.dtOpened		; Init MUI stuff
			bsr	_InitApplication
			bne.w	.cleanup


			; Load Custom Button Images
			
			lea	str_ImgPlay,a0
			bsr	_BuildImageFilename
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadARGBImage
			move.l	d0,vmp_ImgBuffer_Play(a5)
			move.l	d1,vmp_ImgWidth_Play(a5)
			move.l	d2,vmp_ImgHeight_Play(a5)
			
			lea	str_ImgPause,a0
			bsr	_BuildImageFilename
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadARGBImage
			move.l	d0,vmp_ImgBuffer_Pause(a5)
			move.l	d1,vmp_ImgWidth_Pause(a5)
			move.l	d2,vmp_ImgHeight_Pause(a5)
			
			lea	str_ImgNext,a0
			bsr	_BuildImageFilename
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadARGBImage
			move.l	d0,vmp_ImgBuffer_Next(a5)
			move.l	d1,vmp_ImgWidth_Next(a5)
			move.l	d2,vmp_ImgHeight_Next(a5)
			
			lea	str_ImgPrev,a0
			bsr	_BuildImageFilename
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadARGBImage
			move.l	d0,vmp_ImgBuffer_Prev(a5)
			move.l	d1,vmp_ImgWidth_Prev(a5)
			move.l	d2,vmp_ImgHeight_Prev(a5)

			lea	str_ImgPlaylist,a0
			bsr	_BuildImageFilename
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadARGBImage
			move.l	d0,vmp_ImgBuffer_Playlist(a5)
			move.l	d1,vmp_ImgWidth_Playlist(a5)
			move.l	d2,vmp_ImgHeight_Playlist(a5)

			lea	str_ImgDirlist,a0
			bsr	_BuildImageFilename
			lea	vmp_FilenameBuffer,a0
			bsr	_LoadARGBImage
			move.l	d0,vmp_ImgBuffer_Dirlist(a5)
			move.l	d1,vmp_ImgWidth_Dirlist(a5)
			move.l	d2,vmp_ImgHeight_Dirlist(a5)

			; Create MUI - Application, Window, buttons, etc
			bsr	_InitCustomClass
			bsr	_BuildGui
			beq.s	.guiBuilt
			SHOWALERT	txt_GUIAlert
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
			SHOWALERT	txt_WDWAlert
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
			move.l	#txt_ApplicationTitle,LN_NAME(a1)
			move.l	#_InterruptHandler,IS_CODE(a1)
			move.l	a5,IS_DATA(a1)
			move.w	#$0400,INTREQ
			tst.w	INTREQR							; Dummy read to flush bus
			LVO	SetIntVector
			move.l	d0,vmp_OldInterrupt(a5)
			
			move.w	#$8400,$dff09a


			; EventHandler is the mainloop
			bsr	_EventHandler

			; Auto-save current playlist to PROGDIR:vaMP3.playlist
			lea	txt_DefaultPlaylistPath,a0
			bsr	_SavePlaylistToFile

			; Close Playlist window in advance to speed up list clearing
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_PlaylistWindow(a5),a0
			tst.l	a0
			beq.s	.skipClosePlaylist
			INITSTACKTAG
			STACKVALTAG	0,MUIA_Window_Open
			CALLSTACKTAG	_LVOSetAttrsA,a1
.skipClosePlaylist

			; Free playlist memory structures to prevent leaks at exit
			bsr	_PlaylistButtonClear



			; Remove interrupt handler for processing audio
			move.w	#$0400,$dff09a
			movea.l	4.w,a6
			moveq	#INTB_AUD3,d0
			lea	vmp_OldInterrupt(a5),a1
			LVO	SetIntVector

			; Stop playing audio and close any active stream
			bsr	_CloseMP3

			movea.l	vmp_MUIBase(a5),a6
			movea.l	vmp_MUI_Application(a5),a0
			LVO	MUI_DisposeObject		

.cleanup		movea.l	4.w,a6
			
			movea.l	vmp_ImgBuffer_Play(a5),a1
			jsr	_LVOFreeVec(a6)
			
			movea.l	vmp_ImgBuffer_Pause(a5),a1
			jsr	_LVOFreeVec(a6)
			
			movea.l	vmp_ImgBuffer_Next(a5),a1
			jsr	_LVOFreeVec(a6)
			
			movea.l	vmp_ImgBuffer_Prev(a5),a1
			jsr	_LVOFreeVec(a6)

			CLOSELIB	Datatypes
			CLOSELIB	Dos
			CLOSELIB	MPEGA
			CLOSELIB	ASL
			CLOSELIB	MUI
			CLOSELIB	CyberGfx
			CLOSELIB	Intuition
			CLOSELIB	Graphics

			movea.l	4.w,a6
			
			; Timer Cleanup
			tst.l	vmp_TimerDeviceBase(a5)
			beq.s	.noTimer
			lea	vmp_TimerReq(a5),a1
			LVO	AbortIO
			lea	vmp_TimerReq(a5),a1
			LVO	WaitIO
			lea	vmp_TimerReq(a5),a1
			LVO	CloseDevice

.noTimer		move.l	vmp_TimerSignal(a5),d0
			LVO	FreeSignal

			move.l	vmp_InterruptSignal(a5),d0
			LVO	FreeSignal

.allocsignalError	movea.l	4.w,a6
			movea.l	a5,a1
			move.l	#vmp_SIZEOF,d0
			LVO	FreeMem

.allocError		moveq	#0,d0
			rts



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
			bsr	_UpdateUIProgress
			
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



			;------------------------------------------------------------
			; _LoadARGBImage
			;------------------------------------------------------------
			;
			; Input: 
			;	a0 = filename
			; Result:
			;	d0 = ARGB buffer (or 0)
			;	d1 = width
			;	d2 = height

_LoadARGBImage		movem.l	d3-d7/a2-a4/a6,-(sp)
			link	a4,#-120
			
			move.l	a0,d7			; Save filename safely
			
			move.l	#0,-4(a4)
			move.l	#0,-8(a4)
			move.l	#0,-12(a4)
			move.l	#0,-16(a4)
			
			movea.l	vmp_DatatypesBase(a5),a6
			
			INITSTACKTAG
			STACKVALTAG	GID_PICTURE,DTA_GroupID
			STACKVALTAG	FALSE,PDTA_Remap
			STACKVALTAG	PMODE_V43,PDTA_DestMode
			move.l	d7,d0			; d0 = filename
			CALLSTACKTAG	_LVONewDTObjectA,a0	; a0 = attrs
			move.l	d0,-16(a4)
			beq.w	.error
			
			movea.l	d0,a0
			suba.l	a1,a1
			suba.l	a2,a2
			lea	vmp_ProcLayoutMsg,a3
			jsr	_LVODoDTMethodA(a6)
			
			; Get BitMap
			movea.l	-16(a4),a0
			INITSTACKTAG
			STACKADRTAG	-20(a4),PDTA_DestBitMap
			CALLSTACKTAG	_LVOGetDTAttrsA,a2
			
			; Get BitMapHeader for Width/Height
			movea.l	-16(a4),a0
			INITSTACKTAG
			STACKADRTAG	-24(a4),PDTA_BitMapHeader
			CALLSTACKTAG	_LVOGetDTAttrsA,a2
			
			movea.l	-24(a4),a0
			moveq	#0,d0
			move.w	(a0),d0
			move.l	d0,-8(a4)
			moveq	#0,d1
			move.w	2(a0),d1
			move.l	d1,-12(a4)
			
			; AllocVec
			move.l	d0,d1
			move.l	-12(a4),d2
			mulu.w	d2,d1			; d1 = w * h
			lsl.l	#2,d1			; d1 = w * h * 4
			move.l	d1,d0
			move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
			movea.l	4.w,a6
			jsr	_LVOAllocVec(a6)
			move.l	d0,-4(a4)
			beq.s	.dtError
			
			; Init RastPort
			movea.l	vmp_GraphicsBase(a5),a6
			lea	-120(a4),a1
			jsr	_LVOInitRastPort(a6)
			
			lea	-120(a4),a1
			move.l	-20(a4),4(a1)		; rp_BitMap
			
			; ReadPixelArray
			movea.l	vmp_CyberGfxBase(a5),a6
			movea.l	-4(a4),a0		; dest
			moveq	#0,d0			; destX
			moveq	#0,d1			; destY
			move.l	-8(a4),d2
			lsl.l	#2,d2			; destMod = w*4
			lea	-120(a4),a1		; srcRP
			moveq	#0,d3			; srcX
			moveq	#0,d4			; srcY
			move.l	-8(a4),d5		; width
			move.l	-12(a4),d6		; height
			moveq	#2,d7			; RECTFMT_ARGB
			jsr	-120(a6)		; ReadPixelArray
			
.dtError		movea.l	vmp_DatatypesBase(a5),a6
			movea.l	-16(a4),a0
			jsr	_LVODisposeDTObject(a6)
			
.error			move.l	-4(a4),d0
			move.l	-8(a4),d1
			move.l	-12(a4),d2
			unlk	a4
			movem.l	(sp)+,d3-d7/a2-a4/a6
			rts



			;------------------------------------------------------------
			; _BuildImageFilename
			;------------------------------------------------------------
			;
			; Input: 
			;	a0 = filename
			; Result:
			;	vmp_FilenameBuffer = path+filename of image to use

_BuildImageFilename	movem.l	d0-d1/a0-a3/a6,-(sp)
			move.l	a0,a3
			
			; *** Copy ImagePath from Prefs ***
			movea.l	vmp_IntuitionBase(a5),a6
			movea.l	vmp_MUI_SettingsImagePath(a5),a0
			move.l	#MUIA_String_Contents,d0
			lea	vmp_MUI_TempFilePointer(a5),a1
			LVO	GetAttr
			tst.l	d0
			beq.s	.noImagePath
			
			movea.l	vmp_MUI_TempFilePointer(a5),a2
			tst.b	(a2)
			beq.s	.noImagePath
			move.l	a2,a1
			bra.s	.pathFound
			
.noImagePath		lea	str_Path,a1
.pathFound		lea	vmp_FilenameBuffer,a2
.copyLoop		move.b	(a1)+,d0
			move.b	d0,(a2)+
			cmp.b	#0,d0
			bne.s	.copyLoop

			movea.l	vmp_DosBase(a5),a6
			move.l	#vmp_FilenameBuffer,d1
			move.l	a3,d2
			move.l	#255,d3
			LVO	AddPart
			
			movem.l	(sp)+,d0-d1/a0-a3/a6
			rts
			
			
			
			section data,Data

vmp_MUIName		dc.b	"muimaster.library",0
vmp_UtilityName		dc.b	"utility.library",0
vmp_CyberGfxName	dc.b	"cybergraphics.library",0
vmp_IntuitionName	dc.b	'intuition.library',0
vmp_GraphicsName	dc.b	'graphics.library',0
vmp_ASLName		dc.b	"asl.library",0
vmp_MPEGAName		dc.b	"mpega.library",0
vmp_DosName		dc.b	"dos.library",0
vmp_DatatypesName	dc.b	"datatypes.library",0
vmp_TimerDeviceName	dc.b	"timer.device",0
vmp_UniquePortName	dc.b	"VAMP3.1",0

vmp_VersionString	dc.b	"$VER: VaMP3 v",VAMP3_VERSION+"0",".",VAMP3_REVISION+"0"," Copyright (c) 2026 Bedroomcoders.com"

			even
vmp_TimeBuffer		ds.b	32
vmp_NameBuffer		ds.b	128
			even

vmp_StructPointer	dc.l	0
vmp_WorkbenchMessage	dc.l	0


			; Image Paths
str_Path		dc.b	"Progdir:images/Childsplay",0
str_ImgPlay		dc.b	"Play",0
str_ImgPause		dc.b	"Pause",0
str_ImgNext		dc.b	"Next",0
str_ImgPrev		dc.b	"Previous",0
str_ImgPlaylist		dc.b	"Playlist",0
str_ImgDirlist		dc.b	"Dirlist",0
			even



			; Alert messages

			even			
txt_MUIAlert		dc.b	"Could not open muimaster.library",0
txt_UtilAlert		dc.b	"Could not open utility.library",0
txt_CGXAlert		dc.b	"Could not open cybergraphics.library",0
txt_ASLAlert		dc.b	"Could not open asl.library",0
txt_MPEGAAlert		dc.b	"Could not open mpega.library",0
txt_DosAlert		dc.b	"Could not open dos.library",0
txt_DTAlert		dc.b	"Could not open datatypes.library",0
txt_GUIAlert		dc.b	"Error building GUI",0
txt_ClassAlert		dc.b	"Failed to create Custom Class!",0
txt_WDWAlert		dc.b	"Could not extract WindowBase",0
txt_MEMAlert		dc.b	"Could not allocate memory",0
txt_AlertTitle		dc.b	"Alert!",0
txt_AlertOK		dc.b	"OK",0
vmp_EasyStruct		ds.b	es_SIZEOF						; EasyStruct for Requesters


			; Datatypes stuff
vmp_ProcLayoutMsg	dc.l	DTM_PROCLAYOUT				; Method
			dc.l	0					; GInfo
			dc.l	1					; Initial

			even
vmp_Logo		incbin	"data/logo.raw"		; 206x85, 32bit

			; Include other source files
			include	"gui.s"
			include	"mp3.s"



