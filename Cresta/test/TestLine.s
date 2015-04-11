;*******************************************************************************
; TestLine.s
; Test le tracé de ligne au blitter
; V1.0 Février 2015
;*******************************************************************************

; Définition des registres
	INCLUDE	"Includes/Register.s"

; Constantes système
	INCLUDE	"Includes/Constant.s"

; Macros
	INCLUDE	"Includes/Macro.s"

; Activation DMA	
DMA_SET 						= DMA_ON+DMA_BITPLANE+DMA_COPPER+DMA_BLITTER

; Activation interruptions
INT_SET							= INT_ON+INT_VERTB

; AGA Burst
BURST_SET						= BURST_NONE

;*******************************************************************************
;	Définition de l'écran
;*******************************************************************************

SCREEN_WIDTH				= 320
SCREEN_HEIGHT				= 256
SCREEN_STARTX				= $80
SCREEN_STARTY				= $2C

;*******************************************************************************
;	Définition du Playfield
;*******************************************************************************

PF_WIDTH 						= 320
PF_HEIGHT 					= 256
PF_DEPTH 						= 1
PF_INTER 						= 0
PF_LINE							= PF_WIDTH/8
PF_PLANE						= PF_LINE*PF_HEIGHT
PF_SIZE							= PF_PLANE*PF_DEPTH
PF_MOD	 						= 0

;*******************************************************************************
;	Constantes 3D
;*******************************************************************************

ZOOM								= 1

;*******************************************************************************
	SECTION PROGRAM,CODE
;*******************************************************************************

Start:
	jsr			SaveSystem										; Sauve les données système
	tst.l		d0
	beq			Restore												; Restaure en cas d'erreur

.Initialize:
	bsr			InitScreen										; Initialise l'écran
	bsr			InitCopper										; Initialise la Copper list

.SetVBL:
	move.l	VbrBase,a6
	move.l	#VBL,VEC_VBL(a6)

.SetCopper:
	lea			CUSTOM,a6
	move.l	#CopperList,COP1LC(a6)				; Notre Copper list
	clr.w		COPJMP1(a6)										; Que l'on démarre

	tst.w		FlagAGA
	beq.s		.NoBurstMode
	move.w	#BURST_SET,FMODE(a6)					; Mode burst AGA
.NoBurstMode

.SetInterrupts:
	move.w	#INT_STOP,INTENA(a6)					; Stop les interruptions
	move.w	#INT_STOP,INTREQ(a6)					; Stop les requests
	move.w	#DMA_STOP,DMACON(a6)					; Stop le DMA
	move.w	#INT_SET,INTENA(a6)						; Interruptions VBL on
	move.w	#DMA_SET,DMACON(a6)						; Canaux DMA

;*******************************************************************************

	bsr			TestLine

MainLoop:
	move.w	#$0,FlagVBL
WaitVBL:
	tst.w		FlagVBL
	beq.s		WaitVBL												; On attend la vbl

	btst		#MOUSE_BUTTON1,CIAA+CIAPRA		; Test la souris
	bne.s		MainLoop

;*******************************************************************************

Restore:
	jsr			RestoreSystem
	
	moveq.l	#0,d0
	rts

;*******************************************************************************
;	Routines d'initialisation
;*******************************************************************************

InitScreen:
	move.l	#ScreenBuffer,PhysicBase
	move.l	PhysicBase,a0
	move.l	#$0,d1
	move.w	#(PF_SIZE/4)-1,d0
.FillScreen:
	move.l	d1,(a0)+
	dbf			d0,.FillScreen	
	rts

;***************************************

InitCopper:
	lea			CLBitplaneAdr,a0							; Les bitplans de la CL
	move.l	PhysicBase,d0									; Notre écran
	move.w	#BPL1PT,d1										; Registre BP
	moveq.l	#PF_DEPTH-1,d7
.SetBplPointer:
	move.w	d1,(a0)+											; Adresse registre
	swap		d0
	move.w	d0,(a0)+											; Adresse bitplane
	addq.w	#2,d1													; Registre suivant
	move.w	d1,(a0)+											; Adresse registre
	swap		d0
	move.w	d0,(a0)+											; Adresse bitplane
	addq.w	#2,d1													; Registre suivant
	IFEQ		PF_INTER
	addi.l	#PF_WIDTH/8*PF_HEIGHT,d0			; Bitplane suivant (non interleave)
	ELSEIF
	addi.l	#PF_WIDTH/8,d0								; Bitplane suivant (interleave)
	ENDC
	dbf			d7,.SetBplPointer

	lea			CLSpriteAdr,a0								; Les sprites de la CL
	move.l	#DefaultSprite,d0							; Sprite vide par défaut
	move.w	#SPR_MAXSPRITE-1,d1						; 8 sprites à faire
.SetSpritePtr:
	move.w	d0,6(a0)											; Adresse du sprite
	swap		d0
	move.w	d0,2(a0)											; Adresse du sprite
	swap		d0
	adda.l	#8,a0
	dbf			d1,.SetSpritePtr							; Sprite suivant
	rts

;*******************************************************************************
;	Routines d'animation
;*******************************************************************************

TestLine:
	lea			ScreenBuffer,a0
	move.w	#PF_LINE,d4
	lea			CUSTOM,a6

	lea			Points,a1
.GoFace:
	move.w	(a1)+,d7
	beq			.Fin
.NextPoint:
	move.w	0(a1),d0
	lsr.w		#ZOOM,d0
	addi.w	#ZOOM*16,d0
	move.w	2(a1),d1
	lsr.w		#ZOOM,d1
	addi.w	#ZOOM*16,d1
	move.w	4(a1),d2
	lsr.w		#ZOOM,d2
	addi.w	#ZOOM*16,d2
	move.w	6(a1),d3
	lsr.w		#ZOOM,d3
	addi.w	#ZOOM*16,d3
	bsr			DrawLine

	lea			4(a1),a1
	bra			.Next

	move.w	0(a1),d0
	move.w	2(a1),d1
	move.w	4(a1),d2
	move.w	6(a1),d3
	bsr			DrawLine

	move.w	4(a1),d0
	move.w	6(a1),d1
	move.w	8(a1),d2
	move.w	10(a1),d3
	bsr			DrawLine

	move.w	8(a1),d0
	move.w	10(a1),d1
	move.w	0(a1),d2
	move.w	2(a1),d3
	bsr			DrawLine
	
	lea			6*2(a1),a1

.Next:
	dbra		d7,.NextPoint

	lea			4(a1),a1
	bra			.GoFace

.Fin:
	
	move.l	#ScreenBuffer,d0
	addi.l	#PF_SIZE-2,d0
	move.w	#0,d1
	move.w	#(PF_HEIGHT*64)+(PF_WIDTH/16),d2
	lea			CUSTOM,a6
	bsr			FillFace

	rts

;*******************************************************************************
; Trace une ligne avec le blitter
; IN	:	d0.w = X1
;				d1.w = Y1
;				d2.w = X2
;				d3.w = Y2
;				d4.w = largeur du bitplan en octets
;				a0.l = adresse bitplan
;				a6.l = adresse custom base
;*******************************************************************************

BLT_LINE_MOD = 2												; 0 = LINE, 2 = FILL

DrawLine:
	movem.l	d0-d4/a0,-(a7)

	cmp.w		d1,d3													; Y1 > Y2
	bge.s		Y1InfY2												; Non
	exg			d0,d2													; On dessine toujours
	exg			d1,d3													; du haut vers le bas
Y1InfY2:
	sub.w		d1,d3													; d3 = Y2 - Y1 = deltaY
	move.w	d1,d5													; d5 = Y1
	mulu.w	#PF_LINE,d1
	add.l		d1,a0													; a0 = Adresse ligne
	moveq		#0,d1
	sub.w		d0,d2													; d2 = X2 - X1 = deltaX
	bge.s		DXPositif											; Positif
	addq.w	#2,d1													; d1 = 2 (Octant)
	neg.w		d2														; d2 -> positif
DXPositif:
	moveq		#$f,d5
	and.w		d0,d5													; d5 = X1 & $F = décalage point

	IFEQ		BLT_LINE_MOD-2
	move.b	d5,d6													; d6 = d5
	not.b		d6														; d6 = !d5 , pour mode FILL
	ENDC

	lsr.w		#3,d0													; d0 = X1 / 8
	add.w		d0,a0													; a0 = adresse de départ de la ligne
	ror.w		#4,d5													; Positionne les bits de décalage

	IFEQ		BLT_LINE_MOD
	or.w		#$bca,d5											; Minterm + sources, pour mode LINE
	ELSE
	or.w		#$b4a,d5											; Minterm + sources , pour mode FILL, deux lignes superposées s'annulent
	ENDC

	swap		d5
	cmp.w		d2,d3													; DeltaX > DeltaY
	bge.s		DYInfDX												; Non
	addq.w	#1,d1													; d1 = 3 (Octant)
	exg			d2,d3													; d2 = DeltaY et d3 = DeltaX
DYInfDX:																; d2 = PetitDelta, d3 = GrandDelta
	add.w		d2,d2													; d2 = 2 * PetitDelta
	move.w	d2,d0													; d0 = 2 * PetitDelta
	sub.w		d3,d0													; d0 = (2 * PetitDelta) - GrandDelta
	addx.w	d1,d1													; d1 x 2
	move.b	Octants(pc,d1.w),d5						; d5 = Minterm + sources + octant

	swap		d2
	move.w	d0,d2													; d2 = 2 * PetitDelta | (PetitDelta * 2) - GrandDelta
	sub.w		d3,d2													; d2 = 2 * PetitDelta | 2 * (PetitDelta - GrandDelta) 
	moveq		#6,d1													; d1 = 6

	lsl.w		d1,d3													; d3 = GrandDelta * 64 (=> longueur * 64)
	
	add.w		#$42,d3												; d3 = (GrandDelta+1 * 64) + 2 , pour évité d'avoir H=0

	IFEQ		BLT_LINE_MOD-2
	bchg		d6,(a0)												; Pour mode FILL
	ENDC

	WAITBLT																; On attend le blitter

; Ces 5 lignes peuvent être placées en dehors de la fonction car ces valeurs
; ne sont pas écrasées par le Blitter
	move.w	#-1,BLTAFWM(a6)								; masque gauche = $ffff
	move.w	#-1,BLTBDAT(a6)								; pattern ligne = $ffff
	move.w	#$8000,BLTADAT(a6)						; valeur arbitraire du point
	move.w	d4,BLTCMOD(a6)								; largeur bitplan
	move.w	d4,BLTDMOD(a6)								; largeur bitplan

	move.l	d5,BLTCON0(a6)								; Minterm + sources + octant (BLTCON0 & BLTCON1)
	move.l	d2,BLTBMOD(a6)								; 2 * PetitDelta | 2 * (PetitDelta - GrandDelta) (BLTBMOD & BLTAMOD)
	move.l	a0,BLTCPTH(a6)								; adresse de départ
	move.w	d0,BLTAPTL(a6)								; (2 * PetitDelta) - GrandDelta
	move.l	a0,BLTDPTH(a6)								; adresse de départ
	move.w	d3,BLTSIZE(a6)								; (GrandDelta * 64) + 2

	movem.l	(a7)+,d0-d4/a0
	rts

Octants:
	dc.b		BLT_LINE_MOD+01
	dc.b		BLT_LINE_MOD+01+$40
	dc.b		BLT_LINE_MOD+17
	dc.b		BLT_LINE_MOD+17+$40
	dc.b		BLT_LINE_MOD+09
	dc.b		BLT_LINE_MOD+09+$40
	dc.b		BLT_LINE_MOD+21
	dc.b		BLT_LINE_MOD+21+$40

;*******************************************************************************
; Rempli une surface au blitter
; IN	:	d0.l = adresse bitplan
;				d1.w = modulo
;				d2.w = taille de la fenêtre
;				a6.l = adresse custom base
;*******************************************************************************

FillFace:
	WAITBLT
	move.l	d0,BLTAPT(a6)
	move.l	d0,BLTDPT(a6)
	move.w	d1,BLTAMOD(a6)
	move.w	d1,BLTDMOD(a6)
	move.w	#BLT_FILL,BLTCON0(a6)
	move.w	#BLT_FILLEXCLU,BLTCON1(a6)
	move.w	d2,BLTSIZE(a6)
	rts

;*******************************************************************************
;	Interruptions
;*******************************************************************************
VBL:
	movem.l	d0-a6,-(sp)

	move.w	#$FFFF,FlagVBL								; Indique la fin de la VBL
	move.w	#$20,CUSTOM+INTREQ						; Libère l'interruption

	movem.l	(sp)+,d0-a6
	rte
;*******************************************************************************

;*******************************************************************************
	SECTION	GENERAL,DATA
;*******************************************************************************

FlagVBL:
	dc.w		0

PhysicBase:
	dc.l		0 

Points:
	dc.w		12-2

	dc.w		$5c,$37
	dc.w		$95,$73
	dc.w		$95,$7e
	dc.w		$87,$8c
	dc.w		$95,$9a
	dc.w		$95,$c9
	dc.w		$61,$94
	dc.w		$5d,$c9
	dc.w		$55,$c8
	dc.w		$2a,$99
	dc.w		$2f,$5e
	dc.w		$5c,$37
	
	dc.w		4-2
	dc.w		$5b,$65
	dc.w		$67,$73
	dc.w		$59,$7f
	dc.w		$5b,$65

	dc.w		0

	dc.w		116,10
	dc.w		240,138
	dc.w		240,162
	dc.w		210,194
	dc.w		240,224
	dc.w		240,324
	dc.w		128,212
	dc.w		120,324
	dc.w		102,322
	dc.w		10,222
	dc.w		20,92
	dc.w		116,10

	dc.w		4-2

	dc.w		114,108
	dc.w		140,138
	dc.w		110,164
	dc.w		114,108

;	dc.w		0

	dc.w		11-2

	dc.w		384,12
	dc.w		388,100
	dc.w		364,142
	dc.w		378,158
	dc.w		378,202
	dc.w		258,324
	dc.w		258,228
	dc.w		290,192
	dc.w		258,160
	dc.w		258,138
	dc.w		384,12

;	dc.w		0

	dc.w		4-2

	dc.w		410,12
	dc.w		414,90
	dc.w		502,90
	dc.w		410,12

	dc.w		6-2

	dc.w		414,102
	dc.w		504,102
	dc.w		514,224
	dc.w		426,324
	dc.w		414,324
	dc.w		414,102

	dc.w		0

;*******************************************************************************
	SECTION SCREEN,BSS_C
;*******************************************************************************
	CNOP		0,8														; Alignement sur 8 octets
ScreenBuffer:
	ds.b		PF_SIZE

;*******************************************************************************
	SECTION SPRITE,DATA_C
;*******************************************************************************
	CNOP		0,8														; Alignement sur 8 octets
DefaultSprite:
	dc.l		0,0,0,0

;*******************************************************************************
	SECTION COPPER,DATA_C
;*******************************************************************************
CopperList:
	CMOVE		(SCREEN_STARTY<<8)|(SCREEN_STARTX+1),DIWSTRT
	CMOVE		(((SCREEN_STARTY+SCREEN_HEIGHT)&$FF)<<8)|((SCREEN_STARTX+SCREEN_WIDTH+1)&$FF),DIWSTOP
CLSpriteAdr:
	CMOVE		$0000,SPR0PTH
	CMOVE		$0000,SPR0PTL
	CMOVE		$0000,SPR1PTH
	CMOVE		$0000,SPR1PTL
	CMOVE		$0000,SPR2PTH
	CMOVE		$0000,SPR2PTL
	CMOVE		$0000,SPR3PTH
	CMOVE		$0000,SPR3PTL
	CMOVE		$0000,SPR4PTH
	CMOVE		$0000,SPR4PTL
	CMOVE		$0000,SPR5PTH
	CMOVE		$0000,SPR5PTL
	CMOVE		$0000,SPR6PTH
	CMOVE		$0000,SPR6PTL
	CMOVE		$0000,SPR7PTH
	CMOVE		$0000,SPR7PTL
CLScreenDef:
	CWAIT		$0001,SCREEN_STARTY-2
	CMOVE		$0038,DDFSTRT
	CMOVE		$00D0,DDFSTOP
	CMOVE		$1200,BPLCON0									; Ecran 2 couleurs lowres
	CMOVE		$0000,BPLCON1
	CMOVE		$0000,BPLCON2
	CMOVE		$0C00,BPLCON3
	CMOVE		$0011,BPLCON4
	CMOVE		PF_MOD,BPL1MOD
	CMOVE 	PF_MOD,BPL2MOD
CLBitplaneAdr:
	REPT		PF_DEPTH
	CMOVE		$0000,$0000
	CMOVE		$0000,$0000
	ENDR

CLPalette:
	CMOVE		$0000,COLOR00
	CMOVE		$0f00,COLOR01

	CWAIT		$0007,SCREEN_STARTY-1
	CMOVE		$0fff,COLOR00
	CWAIT		$0007,SCREEN_STARTY
	CMOVE		$0000,COLOR00

CLEnd:
	CEND

;*******************************************************************************
; Fonctions utiles
;*******************************************************************************

	INCLUDE "Includes/System.s"
;	INCLUDE "Includes/IFFTool.s"
	INCLUDE "Includes/Math.s"
;	INCLUDE "Includes/Input.s"
;	INCLUDE "Includes/ModPlayer.s"

	END
