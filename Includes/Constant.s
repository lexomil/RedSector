;*******************************************************************************
;	Constant.s
;	Constantes système
; V1.6 Février 2015
;*******************************************************************************

; Constantes classiques
NULL								= 0
TRUE								= -1
FALSE								= 0

;	Fonctions EXEC
_Supervisor 				= -$1E
_Forbid 						= -$84
_Permit 						= -$8A
_AllocMem						= -$C6
_FreeMem						= -$D2
_CloseLibrary 			= -$19E
_OpenLibrary 				= -$228

;	Fonctions GRAPHICS
_LoadView 					= -$DE
_WaitBlit 					= -$E4
_WaitTOF 						= -$10E
_OwnBlitter 				= -$1C8
_DisownBlitter 			= -$1CE

; Fonctions DOS
_Open               = -$1E
_Close              = -$24
_Read               = -$2A
_Write              = -$30
_Seek               = -$42

;	Fonctions INTUITION
_RethinkDisplay 		= -$186

; Vecteurs IT
VEC_KBD							= $68
VEC_VBL							= $6C
VEC_AUDIO						= $70
VEC_TRAP0						= $80

; Constantes EXEC
LIB_VERSION					= $14
EXEC_CPU_TYPE				= $129
VB_FREQUENCY				= $212

; Constantes GRAPHICS
GFXB_AA_ALICE 			= 2
GFXB_PAL						= 2
GFX_DISPLAYFLAGS		= $CE
GFX_CHIPREV					= $EC
GFX_ACTIVEVIEW			= $22
GFX_COPPERLIST			= $26

;	Canaux DMA
DMA_ON 							= $8200
DMA_OFF 						= $0200
DMA_BITPLANE 				= $0100
DMA_COPPER 					= $0080
DMA_NASTYBLIT				= $0400
DMA_BLITTER 				= $0040
DMA_SPRITE 					= $0020
DMA_DISK	 					= $0010
DMA_AUDIO3 					= $0008
DMA_AUDIO2 					= $0004
DMA_AUDIO1 					= $0002
DMA_AUDIO0 					= $0001
DMA_AUDIO						= DMA_AUDIO0+DMA_AUDIO1+DMA_AUDIO2+DMA_AUDIO3
DMA_STOP						= $7FFF

; Interruptions
INT_ON							= $C000
INT_OFF							= $4000
INT_EXTER						= $2000
INT_DSKSYN          = $1000
INT_VERTB						= $0020
INT_PORTS						= $0008
INT_SOFT						= $0004
INT_DSKBLK          = $0002
INT_STOP						= $7FFF

; Burst mode
BURST_NONE					= $0000
BURST_SPR0					= $0000
BURST_SPR2					= $0004
BURST_SPR4					= $000C
BURST_BPL0					= $0000
BURST_BPL2					= $0001
BURST_BPL4					= $0003

; Sprites
SPR_MAXSPRITE				= 8

; Audio
AUDIO_PALCLOCK			= 3546895
AUDIO_NTSCCLOCK			= 3579545
AUDIO_MAXVOLUME			= 64

; Blitter
BLT_SRCA						= $00F0
BLT_SRCB						= $00CC
BLT_SRCC						= $00AA
BLT_USEA						= $0800
BLT_USEB						= $0400
BLT_USEC						= $0200
BLT_USED						= $0100

; Uniquement destination pour effacer une zone
BLT_CLEAR						= BLT_USED

; Minterm et source pour copy standard (A -> D)
BLT_COPY            = (BLT_USEA+BLT_USED)+BLT_SRCA

; Minterm et source pour copy BLOB (A = masque, B = BLOB, A&B|!A&C -> D)
BLT_CCUT            = (BLT_USEA+BLT_USEB+BLT_USEC+BLT_USED)+((BLT_SRCA&BLT_SRCB)+(~BLT_SRCA&BLT_SRCC))

; Minterm et source pour FILL (A -> D)
BLT_FILL						= (BLT_USEA+BLT_USED)+BLT_SRCA

; Mode de remplissage
BLT_FILLEXCLU				= $0012
BLT_FILLINCLU				= $000A

; Mode descending
BLT_DESCENDING			= $0002

; Mémoire
MEMF_PUBLIC					= 1<<0
MEMF_CHIP						= 1<<1
MEMF_FAST						= 1<<2
MEMF_CLEAR					= 1<<16

; Fichier
MODE_OLDFILE        = 1005
MODE_NEWFILE        = 1006
MODE_READWRITE      = 1004
OFFSET_BEGINNING    = -1
OFFSET_CURRENT      = 0
OFFSET_END          = 1

; Joystick / souris
MOUSE_BUTTON1				= 6
MOUSE_BUTTON2				= 2
JOY_BUTTON1					= 7
