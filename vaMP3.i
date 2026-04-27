	; Hardware registers
DMACON			equ	$dff096
DMACON2			equ	$dff296
AUD0L			equ	$dff400
CIAAPRA			equ	$bfe001
INTREQ			equ	$dff09c
INTREQR			equ	$dff01c


	; MPEGA
_LVOMPEGA_Open		equ	-30
_LVOMPEGA_Decode	equ	-42
_LVOMPEGA_Close		equ	-36

mp3_ms_duration		equ	14	; Offset in struct


	; Application specific constants
VMP_WINDOWID		equ	1
VMP_WINDOWWIDTH		equ	300
VMP_WINDOWHEIGHT	equ	500

VMP_MP3BUFFERSIZE	equ	32768
VMP_AUDIOCHANNEL	equ	3

VMP_STATUS_IDLE		equ	0
VMP_STATUS_PLAYING	equ	1
VMP_STATUS_OPENERROR	equ	2
VMP_STATUS_DECODING	equ	3


