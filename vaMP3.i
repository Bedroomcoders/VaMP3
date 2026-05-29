	; Hardware registers
DMACON				equ	$dff096
DMACON2				equ	$dff296
AUD0L				equ	$dff400
CIAAPRA				equ	$bfe001
INTREQ				equ	$dff09c
INTREQR				equ	$dff01c



	; MPEGA
_LVOMPEGA_Open			equ	-30
_LVOMPEGA_Decode		equ	-42
_LVOMPEGA_Close			equ	-36
_LVOMPEGA_Seek			equ	-48

mp3_ms_bitrate			equ	18
mp3_ms_duration			equ	14	; Offset in struct
mp3_dec_frequency		equ	28



	; MUI Custom Button Tags
	
CUSTOMBTN_Image     EQU $80010001
CUSTOMBTN_Width     EQU $80010002
CUSTOMBTN_Height    EQU $80010003



	; Datatypes stuff
PDTA_DestMode		equ	$800010fb							; Not defined in ApolloOS include files
PMODE_V43		equ	$1



	; Application specific constants

VAMP3_VERSION			equ	1
VAMP3_REVISION			equ	0

VMP_MAINWINDOWID		equ	1
VMP_MAINWINDOWWIDTH		equ	500
VMP_MAINWINDOWHEIGHT		equ	500

VMP_DIRLISTWINDOWID		equ	2
VMP_DIRLISTWINDOWWIDTH		equ	300
VMP_DIRLISTWINDOWHEIGHT		equ	500

VMP_PLAYLISTWINDOWID		equ	3
VMP_PLAYLISTWINDOWWIDTH		equ	300
VMP_PLAYLISTWINDOWHEIGHT	equ	500

VMP_SETTINGSWINDOWID		equ	4
VMP_SETTINGSWINDOWWIDTH		equ	250
VMP_SETTINGSWINDOWHEIGHT	equ	250

VMP_ABOUTWINDOWID		equ	5
VMP_ABOUTWINDOWWIDTH		equ	250
VMP_ABOUTWINDOWHEIGHT		equ	250

VMP_COMPACTWINDOWID		equ	6
VMP_COMPACTWINDOWWIDTH		equ	150
VMP_COMPACTWINDOWHEIGHT		equ	40

VMP_AUDIO_VOLUME		equ	100
VMP_AUDIO_CHANNEL		equ	3

VMP_MP3BUFFERSIZE		equ	131072
VMP_FRAMESPERTICK		equ	4

VMP_STATUS_IDLE			equ	0
VMP_STATUS_PLAYING		equ	1
VMP_STATUS_OPENERROR		equ	2
VMP_STATUS_DECODING		equ	3
VMP_STATUS_PAUSED		equ	4

VMP_PLAYINGFROM_DIRLIST		equ	1
VMP_PLAYINGFROM_PLAYLIST	equ	2

	; Object ID's for saving preferences
VMP_SETTINGS_IMAGEPATHID		equ	1
VMP_SETTINGS_DEFAULTMP3FOLDERID	equ	2
VMP_MAIN_VOLUMEID		equ	3
VMP_MAIN_POSITIONID		equ	4

	; Playlist entry structure
	STRUCTURE PlaylistEntry,0
		STRUCT ple_Name,128		; Null-terminated filename/title (displayed directly by MUI List)
		STRUCT ple_Path,256		; Null-terminated absolute path (used for loading/playback)
		LABEL ple_SIZEOF


