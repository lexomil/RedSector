;*******************************************************************************
; TestVector.s
; Test le rendu fil de fer
; V1.0 Février 2015
;*******************************************************************************

; Définition des registres
	INCLUDE	"Includes/Register.s"

; Constantes système
	INCLUDE	"Includes/Constant.s"

; Macros
	INCLUDE	"Includes/Macro.s"

; Activation des interruptions
INT_SET							= INT_ON+INT_VERTB

; AGA Burst
BURST_SET						= BURST_NONE

; Activation DMA	
SHIPDMA_SET 				= DMA_ON+DMA_BITPLANE+DMA_COPPER+DMA_SPRITE+DMA_BLITTER

;*******************************************************************************
;	Définition de l'écran
;*******************************************************************************
SHIPSCR_STARTX			= $80
SHIPSCR_STARTY			= $2C
SHIPSCR_WIDTH				= 320
SHIPSCR_HEIGHT			= 256

;*******************************************************************************
; Constantes de l'animation 3D
;*******************************************************************************

; Playfield
SHIPPF_WIDTH				= 320
SHIPPF_HEIGHT				= 160
SHIPPF_DEPTH				= 3
SHIPPF_LINE					= (SHIPPF_WIDTH/8)	; Standard
SHIPPF_PLANE				= SHIPPF_LINE*SHIPPF_HEIGHT	; Standard
SHIPPF_SIZE					= SHIPPF_PLANE*SHIPPF_DEPTH
SHIPPF_MOD					= SHIPPF_LINE-(SHIPSCR_WIDTH/8)

VIEW_WIDTH					= 320
VIEW_HEIGHT					= 160

;*******************************************************************************
	SECTION SHIPPART,CODE
;*******************************************************************************

Start:
	jsr			SaveSystem										; Sauve les données système
	tst.l		d0
	beq			Restore												; Restaure en cas d'erreur

;	bsr			ShipInitialize								; Initialise les éléments de la démo
;	bsr			AnimateShip

.SetVBL:
	move.l	VbrBase,a6
	move.l	#VBL,VEC_VBL(a6)

	lea			CUSTOM,a6
	tst.w		FlagAGA
	beq.s		.NoBurstMode
	move.w	#BURST_SET,FMODE(a6)					; Mode burst AGA
.NoBurstMode

.SetInterrupts:
	move.w	#INT_STOP,INTENA(a6)					; Stop les interruptions
	move.w	#INT_STOP,INTREQ(a6)					; Stop les requests
	move.w	#DMA_STOP,DMACON(a6)					; Stop le DMA
	move.w	#INT_SET,INTENA(a6)						; Interruptions VBL on

.Initialize:
	bsr			ShipInitialize								; Initialise les éléments de la démo
	tst.l		d0
	beq.s		Restore

	move.w	#1,FlagAnimationRunning

;*******************************************************************************

MainLoop:
	move.w	#$0,FlagVBL
WaitVBL:
	tst.w		FlagVBL
	beq.s		WaitVBL												; On attend la vbl

	bsr			ShipAnimation									; Anime les éléments de la démo

	tst.w		FlagAnimationRunning					; Fin de l'animation ?
	beq.s		Restore												; Oui

	btst		#MOUSE_BUTTON1,CIAA+CIAPRA		; Test la souris
	bne.s		MainLoop

;*******************************************************************************

Restore:
	bsr			ShipRestore									; Restaure les éléments de la démo

	jsr			RestoreSystem
	
	moveq.l	#0,d0
	rts

;*******************************************************************************
;	Routines d'initialisation
;*******************************************************************************

ShipInitialize:

	ALLOCMEM (SHIPPF_SIZE*2),MEMF_CHIP|MEMF_CLEAR,ShipPlayfield,.EndOfInit

	move.l	ShipPlayfield,d0
	move.l	d0,ShipPlayfieldDraw
	addi.l	#SHIPPF_SIZE,d0
	move.l	d0,ShipPlayfieldWork

.PrepareObject:
	lea			ShipObject,a0									; Notre objet
	movea.l	ADR_TAB_FACE(a0),a1						; Données des faces de l'objet
	move.w	NBR_FACE(a0),d7								; Nombre de faces de l'objet
	subq.w	#1,d7
.NextFace:
	move.w	2(a1),d0											; Récupère le premier point
	add.w		d0,d0
	add.w		d0,d0													; Multiplie son index par 4
	move.w	d0,2(a1)											; Sauve la donnée
	move.w	4(a1),d0											; Récupère le deuxième point
	add.w		d0,d0
	add.w		d0,d0													; Multiplie son index par 4
	move.w	d0,4(a1)											; Sauve la donnée
	move.w	6(a1),d0											; Récupère le troisième point
	add.w		d0,d0
	add.w		d0,d0													; Multiplie son index par 4
	move.w	d0,6(a1)											; Sauve la donnée
	lea			8(a1),a1
	dbra		d7,.NextFace									; Face suivante

.SetBplPointer:
	lea			CLShipBitplaneAdr,a0
	move.l	ShipPlayfieldDraw,d0					; Notre playfield
	move.w	#SHIPPF_DEPTH-1,d7
.NextBplPointer:
	move.w	d0,6(a0)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a0)											; Adresse bitplan
	swap		d0
	addi.l	#SHIPPF_PLANE,d0							; Bitplan suivant (standard)
	lea			8(a0),a0
	dbra		d7,.NextBplPointer
	
	bsr			InitShipSprites								; Reset les sprites

.SetCopper:
	lea			CUSTOM,a6
	move.l	#CLShipPart,COP1LC(a6)				; Notre Copper list
	clr.w		COPJMP1(a6)										; Que l'on démarre
.SetDMA:
	move.w	#DMA_STOP,DMACON(a6)					; Stop le DMA
	move.w	#SHIPDMA_SET,DMACON(a6)				; Canaux DMA

.NoError:
	moveq.l	#1,d0
.EndOfInit:

	rts

;*******************************************************************************

InitShipSprites:
	move.l  #ShipSprite,d0 			         ; Sprite vide
	lea     CLShipSpriteAdr,a0
	move.w  #SPR_MAXSPRITE-1,d7
.NextSprite
	move.w  d0,6(a0)
	swap    d0
	move.w  d0,2(a0)
	swap    d0
	adda.l	#8,a0
	dbra		d7,.NextSprite
	rts

;*******************************************************************************
;	Routines de restauration
;*******************************************************************************

ShipRestore:
	tst.l		ShipPlayfield
	beq.s		.NoShipBuffer
	FREEMEM (SHIPPF_SIZE*2),ShipPlayfield
.NoShipBuffer:
	rts

;*******************************************************************************
;	Routines d'animation
;*******************************************************************************

ShipAnimation:
	bsr			SetShipPlayfield
	bsr			ShipClearScreen
	bsr			AnimateShip
	bsr			SwitchShipPlayfield
	move.w	#$000,CUSTOM+COLOR00
	rts

;*******************************************************************************

SetShipPlayfield:
	lea			CLShipBitplaneAdr,a0
	move.l	ShipPlayfieldDraw,d0					; Notre playfield
	move.w	#SHIPPF_DEPTH-1,d7
.NextBplPointer:
	move.w	d0,6(a0)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a0)											; Adresse bitplan
	swap		d0
	addi.l	#SHIPPF_PLANE,d0							; Bitplan suivant (standard)
	lea			8(a0),a0
	dbra		d7,.NextBplPointer
	rts

;*******************************************************************************

SwitchShipPlayfield:
	movem.l	ShipPlayfieldDraw,d0-d1
	exg			d0,d1
	movem.l	d0-d1,ShipPlayfieldDraw				; Echange les écrans physique et logique
	rts

;*******************************************************************************

ShipClearScreen:
	move.w	#$f00,CUSTOM+COLOR00

	move.l	ShipPlayfieldWork,d0
	lea			CUSTOM,a6

	WAITBLT

	move.l	d0,BLTDPT(a6)									; Adresse destination D
	move.w	#0,BLTDMOD(a6)								; Modulo destination
	move.w	#BLT_CLEAR,BLTCON0(a6)				; Sources D et décalage
	move.w	#0,BLTCON1(a6)								; Blitter control 1
	move.w	#(SHIPPF_HEIGHT*SHIPPF_DEPTH*64)+(SHIPPF_WIDTH/16),BLTSIZE(a6)	; Taille fenêtre à traiter = lance le blitter

	rts

;*******************************************************************************

AnimateShip:
	move.w	#$0f0,CUSTOM+COLOR00
	lea			ShipObject,a0
;	bsr			MoveShipObject
	bsr			CalculMatrice
	move.w	#$00f,CUSTOM+COLOR00
	bsr			CalculPoints
	move.w	#$ff0,CUSTOM+COLOR00
	bsr			DrawShipObject

	WAITBLT

	rts

;*******************************************************************************
; Constantes pour rotation 3D et perspective
;*******************************************************************************
X_ANGLE							=	0									; Offset angle X objet
Y_ANGLE							=	2									; Offset angle Y objet
Z_ANGLE							=	4									; Offset angle Z objet
CENTER_ROT_X				=	6									; Offset centre X objet
CENTER_ROT_Y				=	8									; Offset centre Y objet
CENTER_ROT_Z				=	10								; Offset centre Z objet
X_OBJ								=	12								; Offset coordonnée X objet
Y_OBJ								=	14								; Offset coordonnée Y objet
Z_OBJ								=	16								; Offset coordonnée Z objet
NBR_POINT						=	18								; Offset compteur points objet
ADR_TAB_POINT				=	20								; Offset liste des points de l'objet
ADR_BUF_COORD				=	24								; Offset buffer des coordonnées écran
NBR_FACE						=	28								; Offset compteur faces objet
ADR_TAB_FACE				=	30								; Offset liste faces de l'objet
M00									= 0									; Offsets matrice
M01									= 2
M02									= 4
M10									= 6
M11									= 8
M12									= 10
M20									= 12
M21									= 14
M22									= 16
Z_OBSERVER					= 300								; Distance de l'observateur

;*******************************************************************************
; Fait bouger l'objet
;*******************************************************************************
MoveShipObject:

	move.w	X_ANGLE(a0),d0								; Angle x de l'objet en degrés
	add.w		#1,d0													; On fait tourner
	cmp.w		#360,d0												; Si on atteint 360 degrés
	bne.s		.NoXLimit
	clr.w		d0														; On revient à zéro
.NoXLimit:
	move.w	d0,X_ANGLE(a0)								; Et on sauve
	move.w	Y_ANGLE(a0),d0								; Idem angle y
	add.w		#1,d0
	cmp.w		#360,d0
	bne.s		.NoYLimit
	clr.w		d0
.NoYLimit:
	move.w	d0,Y_ANGLE(a0)
	move.w	Z_ANGLE(a0),d0								; Idem angle z
	add.w		#1,d0
	cmp.w		#360,d0
	bne.s		.NoZLimit
	clr.w		d0
.NoZLimit:
	move.w	d0,Z_ANGLE(a0)

;	move.w	Z_OBJ(a0),d2									; Coordonnée Z de l'objet
;	add.w		#5,d2													; On déplace l'objet
;	move.w	d2,Z_OBJ(a0)									; Et on sauve

	rts

;*******************************************************************************
; Calcul la matrice de rotation
; IN	:	a0.l = paramètres de l'objet 3D
;*******************************************************************************
CalculMatrice:
	lea			SinCosTable,a1								; La table des sinus / cosinus
	move.w	Z_ANGLE(a0),d0
	add.w		d0,d0
	add.w		d0,d0													; Angle Z * 4					
	move.l	(a1,d0.w),d2									; = Sinus / Cosinus Z
	move.w	Y_ANGLE(a0),d0
	add.w		d0,d0
	add.w		d0,d0													; Angle Y * 4
	move.l	(a1,d0.w),d1									; = Sinus / Cosinus Y
	move.w	X_ANGLE(a0),d0
	add.w		d0,d0
	add.w		d0,d0													; Angle X * 4
	move.l	(a1,d0.w),d0									; = Sinus / Cosinus X
	lea			ShipRotationMatrix,a1					; Matrice de rotation
	move.w	d1,d3
	muls.w	d2,d3
	addx.l	d3,d3
	add.l		d3,d3
	swap		d3
	move.w	d3,M00(a1)										; = Cos(Y) * Cos(Z)
	move.w	d1,d3
	muls.w	d0,d3
	addx.l	d3,d3
	add.l		d3,d3
	swap		d3
	move.w	d3,M22(a1)										; = Cos(X) * Cos(Y)
	move.w	d2,d3
	muls.w	d0,d3
	addx.l	d3,d3
	add.l		d3,d3
	swap		d3
	swap		d0
	swap		d1
	move.w	d1,M02(a1)										; = Sin(Y)
	move.w	d0,d4
	muls.w	d1,d4
	addx.l	d4,d4
	add.l		d4,d4
	swap		d4
	move.w	d4,d5
	muls.w	d2,d4
	addx.l	d4,d4
	add.l		d4,d4
	swap		d4
	swap		d2
	muls		d2,d5
	addx.l	d5,d5
	add.l		d5,d5
	swap		d5
	sub.w		d5,d3
	move.w	d3,M11(a1)										; = (Sin(X) * Sin(Y) * -Sin(Z)) + (Cos(X) * Cos(Z))
	swap		d0
	move.w	d0,d3
	muls.w	d2,d3
	addx.l	d3,d3
	add.l		d3,d3
	swap		d3
	add.w		d4,d3
	move.w	d3,M10(a1)										; = (Sin(X) * Sin(Y) * Cos(Z)) + (Cos(X) * Sin(Z))
	move.w	d0,d3
	muls.w	d1,d3
	addx.l	d3,d3
	add.l		d3,d3
	swap		d3
	move.w	d3,d4
	muls.w	d2,d4
	addx.l	d4,d4
	add.l		d4,d4
	swap		d4
	swap		d0
	swap		d1
	move.w	d1,d5
	muls.w	d2,d5
	addx.l	d5,d5
	add.l		d5,d5
	swap		d5
	neg.w		d5
	move.w	d5,M01(a1)										; = Cos(Y) * -Sin(Z)
	move.w	d0,d5
	muls.w	d2,d5
	addx.l	d5,d5
	add.l		d5,d5
	swap		d5
	swap		d2
	muls.w	d2,d3
	addx.l	d3,d3
	add.l		d3,d3
	swap		d3
	sub.w		d3,d5
	move.w	d5,M20(a1)										; = (Cos(X) * -Sin(Y) * Cos(Z)) + (Sins(X) * Sin(Z))
	muls.w	d0,d2
	addx.l	d2,d2
	add.l		d2,d2
	swap		d2
	add.w		d2,d4
	move.w	d4,M21(a1)										; = (Cos(X) * -Sin(Y) * -Sin(Z)) + (Sin(X) * Cos(Z))
	muls.w	d0,d1
	addx.l	d1,d1
	add.l		d1,d1
	swap		d1
	neg.w		d1
	move.w	d1,M12(a1)										; = -Sin(X) * Cos(Y)
	rts

;*******************************************************************************
; Applique la matrice de rotation aux coordonnées des sommets de l'objet
; et calcul la perspective pour l'affichage
; IN	:	a0.l = paramètres de l'objet 3D
;*******************************************************************************
CalculPoints:
	lea			ShipRotationMatrix,a1					; Matrice de rotation
	movea.l	ADR_TAB_POINT(a0),a2					; Sommets de l'objet
	movea.l	ADR_BUF_COORD(a0),a3					; Buffer pour stocker les coordonnées
	move.w	NBR_POINT(a0),d7
	subq.w	#1,d7
.CalculNextPoint:
	move.w	(a2)+,d0											; Coordonnée X
	move.w	d0,d3
	move.w	(a2)+,d1											; Coordonnée Y
	move.w	d1,d4
	move.w	(a2)+,d2											; Coordonnée Z
	move.w	d2,d5
	muls.w	M00(a1),d3
	muls.w	M01(a1),d4
	add.l		d3,d4
	muls.w	M02(a1),d5
	add.l		d4,d5
	asl.l		#2,d5
	swap		d5														; Crd X après rotation
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d6
	muls.w	M10(a1),d3
	muls.w	M11(a1),d4
	add.l		d3,d4
	muls.w	M12(a1),d6
	add.l		d4,d6
	asl.l		#2,d6
	swap		d6														; Crd Y après rotation
	muls.w	M20(a1),d0
	muls.w	M21(a1),d1
	add.l		d0,d1
	muls.w	M22(a1),d2
	add.l		d2,d1
	asl.l		#2,d1
	swap		d1														; Crd Z après rotation
.Perspective
	add.w		Z_OBJ(a0),d1
	move.w	#Z_OBSERVER,d0
	sub.w		d1,d0
	bne.s		.NoDivZero
	move.w	d0,(a3)+
	move.w	d0,(a3)+
	bra.s		.NextPerspective
.NoDivZero:
	add.w		X_OBJ(a0),d5
	ext.l		d5
	asl.l		#8,d5
	divs.w	d0,d5
	addi.w	#VIEW_WIDTH/2,d5
	move.w	d5,(a3)+											; Coordonnée écran X
	add.w		Y_OBJ(a0),d6
	ext.l		d6
	asl.l		#8,d6
	divs.w	d0,d6
	neg.w		d6
	addi.w	#VIEW_HEIGHT/2,d6
	move.w	d6,(a3)+											; Coordonnée écran Y
.NextPerspective:
	dbra		d7,.CalculNextPoint
	rts

;*******************************************************************************

DrawShipObject:

	lea			CUSTOM,a6

	WAITBLT																; On attend le blitter

	move.w	#-1,BLTAFWM(a6)								; masque gauche = $ffff
	move.w	#-1,BLTBDAT(a6)								; pattern ligne = $ffff
	move.w	#$8000,BLTADAT(a6)						; valeur arbitraire du point
	move.w	#SHIPPF_LINE,BLTCMOD(a6)			; largeur bitplan
	move.w	#SHIPPF_LINE,BLTDMOD(a6)			; largeur bitplan

	movea.l	ADR_TAB_FACE(a0),a3						; Liste des faces de l'objet
	movea.l	ADR_BUF_COORD(a0),a4					; Buffer des coordonnées transformées
	move.w	NBR_FACE(a0),d7
	subq.w	#1,d7
.NextFace:
	move.w	(a3)+,d6											; Couleur face

	move.w	(a3)+,d5											; Index premier point
	move.w	0(a4,d5.w),d0									; X1
	move.w	2(a4,d5.w),d1									; Y1
	move.w	(a3)+,d5											; Index deuxième point
	move.w	0(a4,d5.w),d2									; X2
	move.w	2(a4,d5.w),d3									; Y2
	move.w	(a3)+,d5											; Index troisième point
	move.w	0(a4,d5.w),d4									; X3
	move.w	2(a4,d5.w),d5									; Y3

.HiddenFace:
	movem.l	d0-d5,-(sp)										; Sauve les coordonnées

	sub.w		d2,d0													; X1-X2
	sub.w		d4,d2													; X2-X3
	sub.w		d3,d1													; Y1-Y2
	sub.w		d5,d3													; Y2-Y3
	muls		d1,d2													; d2 = (Y1-Y2)*(X2-X3)
	muls		d3,d0													; d0 = (Y2-Y3)*(X1-X2)

	cmp.w		d2,d0													; Face visible ?
	bge.s		.VisibleFace									; Oui

	bset	#2,d6														; Sinon force plan 3
	bclr	#0,d6														; Au lieu du plan 1

.VisibleFace:
	movem.l	(sp)+,d0-d5										; Restaure les coordonnées

	movea.l	ShipPlayfieldWork,a2					; Adresse plan 1

	btst		#0,d6													; Plan 1 ?
	beq.s		.NotColor1										; Non
	bra.s		.DrawLines										; Dessine les lignes

.NotColor1:
	btst		#1,d6													; Plan 2 ?
	beq.s		.NotColor2										; Non
	lea			SHIPPF_PLANE(a2),a2						; Adresse plan 2
	btst		#2,d6													; Plan 3 ?
	beq.s		.DrawLines										; Non
	lea			SHIPPF_PLANE(a2),a2						; Adresse plan 3

.DrawLines:
	bsr.s		DrawLine											; Ligne X1,Y1 -> X2,Y2

	exg			d0,d4													; d0 = X3, d4 = X1
	exg			d1,d5													; d1 = Y3, d5 = Y1
	bsr			DrawLine											; Ligne X3,Y3 -> X1,Y1

	move.w	d4,d2													; d2 = X1
	move.w	d5,d3					
	bsr.s		DrawLine											; Ligne X3,Y3 -> X1,Y1

.NotColor2:
	dbra		d7,.NextFace

	move.l	ShipPlayfieldWork,a2					; Notre playfield
	adda.l	#SHIPPF_SIZE-2,a2							; Fin du playfield-2
	moveq.l	#0,d0

	lea			CUSTOM,a6
	WAITBLT

;	move.l	#$09f00012,BLTCON0(a6)
;	move.l	d0,BLTAMOD(a6)
;	move.l	a2,BLTAPT(a6)
;	move.l	a2,BLTDPT(a6)
;	move.w	#(SHIPPF_HEIGHT*SHIPPF_DEPTH*64)+(SHIPPF_WIDTH/16),BLTSIZE(a6)

	rts

HiddenFace:
	rts

;*******************************************************************************
; Trace une ligne avec le blitter
; IN	:	d0.w = X1
;				d1.w = Y1
;				d2.w = X2
;				d3.w = Y2
;				a2.l = adresse bitplan
;				a6.l = adresse custom base
;*******************************************************************************

BLT_LINE_MOD = 2												; 0 = LINE, 2 = FILL

DrawLine:
	movem.l	d0-d5/a2,-(a7)

	cmp.w		d1,d3													; Y1 > Y2
	bge.s		Y1InfY2												; Non
	exg			d0,d2													; On dessine toujours
	exg			d1,d3													; du haut vers le bas
Y1InfY2:
	sub.w		d1,d3													; d3 = Y2 - Y1 = deltaY
	move.w	d1,d4													; d4 = Y1
	mulu.w	#SHIPPF_LINE,d1
	add.l		d1,a2													; a2 = Adresse ligne
	moveq		#0,d1
	sub.w		d0,d2													; d2 = X2 - X1 = deltaX
	bge.s		DXPositif											; Positif
	addq.w	#2,d1													; d1 = 2 (Octant)
	neg.w		d2														; d2 -> positif
DXPositif:
	moveq		#$f,d4
	and.w		d0,d4													; d4 = X1 & $F = décalage point

	IFEQ		BLT_LINE_MOD-2
	move.b	d4,d5													; d5 = d4
	not.b		d5														; d5 = !d4 , pour mode FILL
	ENDC

	lsr.w		#3,d0													; d0 = X1 / 8
	add.w		d0,a2													; a2 = adresse de départ de la ligne
	ror.w		#4,d4													; Positionne les bits de décalage

	IFEQ		BLT_LINE_MOD
	or.w		#$bca,d4											; Minterm + sources, pour mode LINE
	ELSE
	or.w		#$b4a,d4											; Minterm + sources , pour mode FILL, n'écrase pas les points déjà mis
	ENDC

	swap		d4
	cmp.w		d2,d3													; DeltaX > DeltaY
	bge.s		DYInfDX												; Non
	addq.w	#1,d1													; d1 = 3 (Octant)
	exg			d2,d3													; d2 = DeltaY et d3 = DeltaX
DYInfDX:																; d2 = PetitDelta, d3 = GrandDelta
	add.w		d2,d2													; d2 = 2 * PetitDelta
	move.w	d2,d0													; d0 = 2 * PetitDelta
	sub.w		d3,d0													; d0 = (2 * PetitDelta) - GrandDelta
	addx.w	d1,d1													; d1 x 2
	move.b	Octants(pc,d1.w),d4						; d4 = Minterm + sources + octant

	swap		d2
	move.w	d0,d2													; d2 = 2 * PetitDelta | (PetitDelta * 2) - GrandDelta
	sub.w		d3,d2													; d2 = 2 * PetitDelta | 2 * (PetitDelta - GrandDelta) 
	moveq		#6,d1													; d1 = 6

	lsl.w		d1,d3													; d3 = GrandDelta * 64 (=> longueur * 64)
	
	add.w		#$42,d3												; d3 = (GrandDelta * 64) + 66 = ((GrandDelta+1) * 64) + 2

	WAITBLT																; On attend le blitter

	IFEQ		BLT_LINE_MOD-2
	bchg		d5,(a2)												; Pour mode FILL
	ENDC

	move.l	d4,BLTCON0(a6)								; Minterm + sources + octant (BLTCON0 & BLTCON1)
	move.l	d2,BLTBMOD(a6)								; 2 * PetitDelta | 2 * (PetitDelta - GrandDelta) (BLTBMOD & BLTAMOD)
	move.l	a2,BLTCPT(a6)									; adresse de départ
	move.w	d0,BLTAPTL(a6)								; (2 * PetitDelta) - GrandDelta
	move.l	a2,BLTDPT(a6)									; adresse de départ
	move.w	d3,BLTSIZE(a6)								; (GrandDelta * 64) + 2

	movem.l	(a7)+,d0-d5/a2
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

FlagAnimationRunning:
	dc.w		0

ShipPlayfield:
	dc.l		0															; Buffer pour le playfield de l'animation 3D

ShipPlayfieldDraw:
	dc.l		0															; Adresse du playfield affiché
ShipPlayfieldWork:
	dc.l		0															; Adresse du playfield de travail

SHIP_NBPOINT				= 14
SHIP_NBFACE					= 24

ShipObject:
	dc.w	0,0,0														; Angles de rotation
	dc.w	0,0,0														; Centre de rotation
	dc.w	0,0,0														; Coordonnées de l'objet
	dc.w	SHIP_NBPOINT										; Nombre de sommets
	dc.l	ShipObjectPoint									; Liste des sommets
	dc.l	ShipObjectScreen								; Coordonnées écran
	dc.w	SHIP_NBFACE											; Nombre de faces
	dc.l	ShipObjectFace									; Liste des faces
ShipObjectPoint:
	dc.w	-50,-50,-50
	dc.w	-50,-50,50
	dc.w	50,-50,50
	dc.w	50,-50,-50
	dc.w	-50,00,00
	dc.w	00,00,50
	dc.w	50,00,00
	dc.w	-50,50,-50
	dc.w	-50,50,50
	dc.w	50,50,50
	dc.w	50,50,-50
	dc.w	00,50,00
	dc.w	00,00,-50
	dc.w	00,-50,00
ShipObjectFace:
	dc.w	1,00,01,04
	dc.w	2,01,08,04
	dc.w	1,08,07,04
	dc.w	2,07,00,04
	dc.w	2,01,02,05
	dc.w	1,02,09,05
	dc.w	2,09,08,05
	dc.w	1,08,01,05
	dc.w	1,02,03,06
	dc.w	2,03,10,06
	dc.w	1,10,09,06
	dc.w	2,09,02,06
	dc.w	1,08,09,11
	dc.w	2,09,10,11
	dc.w	1,10,07,11
	dc.w	2,07,08,11
	dc.w	2,07,10,12
	dc.w	1,10,03,12
	dc.w	2,03,00,12
	dc.w	1,00,07,12
	dc.w	1,00,03,13
	dc.w	2,03,02,13
	dc.w	1,02,01,13
	dc.w	2,01,00,13
ShipObjectScreen:
	dcb.w	2*SHIP_NBPOINT,0								; Les coordonnées après rotation et perspective

; La matrice de rotation finale
ShipRotationMatrix:
	dcb.w	9,0

;*******************************************************************************
	SECTION TABLE,DATA_C
;*******************************************************************************

ShipSprite:
	dc.w		0,0,0,0

;*******************************************************************************
	SECTION COPPER,DATA_C
;*******************************************************************************

CLShipPart:
	CMOVE		(SHIPSCR_STARTY<<8)+SHIPSCR_STARTX+1,DIWSTRT
	CMOVE		$2CC1,DIWSTOP
CLShipSpriteAdr:												; Sprites non utilisés pour cet écran
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

CLShipScreenDef:
	CWAIT		$0000,SHIPSCR_STARTY-2				; 2 lignes avant le début de l'écran
	CMOVE		$0038,DDFSTRT									; Fetch start
	CMOVE		$00D0,DDFSTOP									; Fetch stop
	CMOVE		$3200,BPLCON0									; Ecran 8 couleurs lowres
	CMOVE		$0000,BPLCON1									; Pas de décalage pour ce playfield
	CMOVE		$0000,BPLCON2									; Priorité sprites / playfield (sprites 6 & 7 derrière)
	CMOVE		$0C00,BPLCON3									; Pour compatibilité AGA
	CMOVE		$0011,BPLCON4									; Pour compatibilité AGA

CLShipBitplaneAdr:
	CMOVE		$0000,BPL1PTH									; Les 3 plans du playfield du vaisseau
	CMOVE		$0000,BPL1PTL
	CMOVE		$0000,BPL2PTH
	CMOVE		$0000,BPL2PTL
	CMOVE		$0000,BPL3PTH
	CMOVE		$0000,BPL3PTL
	CMOVE		SHIPPF_MOD,BPL1MOD
	CMOVE 	SHIPPF_MOD,BPL2MOD

CLShipPalette:
;	CMOVE		$0000,COLOR00
	CMOVE		$000a,COLOR01
	CMOVE		$000f,COLOR02
	CMOVE		$0f0f,COLOR03
	CMOVE		$0f0f,COLOR04
	CMOVE		$0ccf,COLOR05
	CMOVE		$0fff,COLOR06
	CMOVE		$0f0f,COLOR07

;	CWAIT		$0007,SHIPSCR_STARTY-1
;	CMOVE		$0fff,COLOR00
;	CWAIT		$0007,SHIPSCR_STARTY
;	CMOVE		$0000,COLOR00

	CWAIT		$0007,SHIPSCR_STARTY+VIEW_HEIGHT
;	CMOVE		$0fff,COLOR00
	CMOVE		$0200,BPLCON0									; Plus d'affichage
;	CWAIT		$0007,SHIPSCR_STARTY+VIEW_HEIGHT+1
;	CMOVE		$0500,COLOR00

CLShipEnd:
	CEND

;*******************************************************************************
; Fonctions utiles
;*******************************************************************************

	INCLUDE "Includes/System.s"
	INCLUDE "Includes/Math.s"

	END
