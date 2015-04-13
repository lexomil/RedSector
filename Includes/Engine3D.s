;*******************************************************************************
; Engine3D.s
; Fonctions du mini moteur 3D (calcul matrice, transformations des points, perspective)
; V 1.0 Mars 2014
;*******************************************************************************

; Constantes du moteur
LXE_MAXPOINTS				= 128

; Constantes de la structure de l'objet
OBJ_XANGLE					= 0									; Angle X de l'objet
OBJ_YANGLE					= 2									; Angle Y de l'objet
OBJ_ZANGLE					=	4									; Angle Z de l'objet
OBJ_XPOS						=	6									; Coordonnée X de l'objet
OBJ_YPOS						=	8									; Coordonnée Y de l'objet
OBJ_ZPOS						=	10								; Coordonnée Z de l'objet
OBJ_NBPOINT					=	12								; Nombre de sommets de l'objet
OBJ_TABPOINT				=	14								; Adresse tableau des points de l'objet
OBJ_NBFACE					=	18								; Nombre de faces de l'objet
OBJ_TABFACE					=	20								; Adresse liste des faces de l'objet

; Constantes de la matrice
M00 								= 0
M01 								= 2
M02 								= 4
M10 								= 6
M11 								= 8
M12									= 10
M20 								= 12
M21 								= 14
M22 								= 16

;*******************************************************************************
	SECTION ENGINE3D,CODE
;*******************************************************************************

;*******************************************************************************
;	Calcul la matrice de rotation
;	IN	:	a0.l = adresse de la structure de l'objet
;				a1.l = adresse de la matrice de rotation
;*******************************************************************************

;	Pour rappel
;	M00 = cos Y * cos Z
;	M01 = cos Y * sin Z
;	M02 = -sin Y
;	M10 = sin X * sin Y * cos Z - cos X * sin Z
;	M11 = sin X * sin Y * sin Z + cos X * cos Z
;	M12 = sin X * cos Y
;	M20 = cos X * sin Y * cos Z + sin X * sin Z
;	M21 = cos X * sin Y * sin Z - sin X * cos Z
;	M22 = cos X * cos Y

FIXEDVAL	MACRO
	addx.l	\1,\1
	add.l		\1,\1
	swap		\1
	ENDM

BuildRotationMatrix:
	lea			SinCosTable,a5								; La table des sinus et cosinus
	move.w	OBJ_ZANGLE(a0),d0							; Angle Z de l'objet
	add.w		d0,d0
	add.w		d0,d0													; *4
	move.l	(a5,d0.w),d2									; d2 = sin Z / cos Z
	move.w	OBJ_YANGLE(a0),d0							; Angle Y de l'objet
	add.w		d0,d0
	add.w		d0,d0													; *4
	move.l	(a5,d0.w),d1									; d1 = sin Y / cos Y
	move.w	OBJ_XANGLE(a0),d0							; Angle X de l'objet
	add.w		d0,d0
	add.w		d0,d0													; *4
	move.l	(a5,d0.w),d0									; d0 = sin X / cos X

.CalculMatrix:
	move.w	d2,d3													; cos Z
	muls.w	d1,d3													; cos Y * cos Z
	FIXEDVAL	d3													; Fixed point
	move.w	d3,M00(a1)										; M00 = cosY*cos Z

	move.w	d1,d3													; cos Y
	muls.w	d0,d3													; cos X * cos Y
	FIXEDVAL	d3
	move.w	d3,M22(a1)										; M22 = cosX*cosY

	move.w	d2,d4													; cos Z
	muls.w	d0,d4													; cos X * cos Z
	FIXEDVAL	d4

	swap		d2														; sin Z
	move.w	d2,d5													; sin Z
	muls.w	d0,d5													; cos X * sin Z
	FIXEDVAL	d5
	
	move.w	d2,d3													; sin Z
	muls.w	d1,d3													; cos Y * sin Z
	FIXEDVAL	d3
	move.w	d3,M01(a1)										; M01 = cosY*sinZ

	swap		d0														; sin X
	move.w	d0,d3													; sin X
	muls.w	d1,d3													; cos Y * sin X
	FIXEDVAL	d3
	move.w	d3,M12(a1)										; M12 = sinX*cosY

	swap		d1														; sin Y
	move.w	d2,d3													; sin Z
	muls.w	d0,d3													; sin X * sin Z
	FIXEDVAL	d3
	move.w	d4,d6													; cos X * cos Z
	muls.w	d1,d6													; sin Y * cos X * cos Z
	FIXEDVAL	d6
	add.w		d6,d3													; sin Y * cos X * cos Z + sin X * sin Z
	move.w	d3,M20(a1)										; M20 = ([cosX*cosZ]*sinY)+(sinX*sinZ)

	move.w	d1,d6													; sin Y
	muls.w	d0,d6													; sin X * sin Y
	FIXEDVAL	d6

	move.w	d6,d3													; sin X * sin Y
	muls.w	d2,d3													; sin X * sin Y * sin Z
	FIXEDVAL	d3
	add.w		d4,d3													; sin X * sin Y * sin Z + cos X * cos Z
	move.w	d3,M11(a1)										; MA11 = ([sinX*sinY]*sinZ)+([cosX*cosZ])

	swap		d2														; cos Z
	muls.w	d2,d6													; cos Z * sin X * sin Y
	FIXEDVAL	d6
	sub.w		d5,d6													; cos Z * sin X * sin Y - cos X * sin Z
	move.w	d6,M10(a1)										; M10 = ([sinX*sinY]*cosZ)-([cosX*sinZ])

	muls.w	d1,d5													; cos X * sin Z * sin Y
	FIXEDVAL	d5
	muls.w	d0,d2													; sin X * cos Z
	FIXEDVAL	d2
	sub.w		d2,d5													; cos X * sin Z * sin Y - sin X * cos Z
	move.w	d5,M21(a1)										; M21 = ([cosX*sinZ]*sinY)-(sinX*cosZ)

	neg.w		d1														; -sin Y
	move.w	d1,M02(a1)										;	M02 = -sinY

	rts

;*******************************************************************************
;	Transforme les points de notre objet
;	IN	:	a0.l = adresse de la structure de l'objet
;				a1.l = adresse de la matrice de rotation
;				a2.l = buffer pour recevoir les coordonnées transformées
;*******************************************************************************

; Pour rappel
; x' = x * M00 + y * M01 + z * M02
; y' = x * M10 + y * M11 + z * M12
; z' = x * M20 + y * M21 + z * M22

TransformPoint:
	movea.l	OBJ_TABPOINT(a0),a3						; Sommets de l'objet
	move.w	OBJ_NBPOINT(a0),d7
	subq.w	#1,d7
.CalculNextPoint:
	move.w	(a3)+,d0											; Coordonnée X
	move.w	d0,d3
	move.w	(a3)+,d1											; Coordonnée Y
	move.w	d1,d4
	move.w	(a3)+,d2											; Coordonnée Z
	move.w	d2,d5
	muls.w	M00(a1),d3										; x * M00
	muls.w	M01(a1),d4										; y * M01
	add.l		d3,d4
	muls.w	M02(a1),d5										; z * M02
	add.l		d4,d5
	asl.l		#2,d5
	swap		d5														; Coordonnée X après rotation
	move.w	d5,(a2)+											; On sauve
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d6
	muls.w	M10(a1),d3										; x * M10
	muls.w	M11(a1),d4										; y * M11
	add.l		d3,d4
	muls.w	M12(a1),d6										; z * M12
	add.l		d4,d6
	asl.l		#2,d6
	swap		d6														; Coordonnée Y après rotation
	move.w	d6,(a2)+											; On sauve
	muls.w	M20(a1),d0										; x * M20
	muls.w	M21(a1),d1										; y * M21
	add.l		d0,d1
	muls.w	M22(a1),d2										; z * M22
	add.l		d2,d1
	asl.l		#2,d1
	swap		d1														; Coordonnée Z après rotation
	move.w	d1,(a2)+											; On sauve
	dbra		d7,.CalculNextPoint
	rts

;*******************************************************************************
;	Applique la perspective aux points transformés de notre objet
;	IN	:	a0.l = adresse de la structure de l'objet
;				a1.l = buffer des coordonnées transformées
;				a2.l = buffer pour recevoir les coordonnées écran
;				d6.l = (hauteur écran / 2) | (largeur écran / 2) 
;*******************************************************************************

; Pour rappel
; x' = (x * DISTANCE) / z
; y' = (y * DISTANCE) / z

CalculPerspective:
	move.w	OBJ_NBPOINT(a0),d7
	subq.w	#1,d7
.CalculNextPoint:
	move.w	(a1)+,d0											; Coordonnée spatiale X
	move.w	(a1)+,d1											; Coordonnée spatiale Y
	move.w	(a1)+,d2											; Coordonnée spatiale Z
	add.w		OBJ_ZPOS(a0),d2								; Translation sur Z
	bne.s		.NoDivZero										; Prévient la division par 0 (cas ou l'objet est sur la caméra) 
	move.w	d2,(a3)+
	move.w	d2,(a3)+
	bra.s		.NextPerspective
.NoDivZero:
	add.w		OBJ_XPOS(a0),d0								; Translation sur X
	ext.l		d0
	asl.l		#8,d0													; X * DISTANCE
	divs.w	d2,d0													; X * DISTANCE / Z
	add.w		d6,d0													; Centre X de l'écran
	move.w	d0,(a2)+											; Coordonnée écran X
	add.w		OBJ_YPOS(a0),d1								; Translation sur Y
	ext.l		d1
	asl.l		#8,d1													; Y * DISTANCE
	divs.w	d2,d1													; Y * DISTANCE / Z
	neg.w		d1														; Car les coordonnées écran sont inversées
	swap		d6
	add.w		d6,d1													; Centre Y de l'écran
	move.w	d1,(a2)+											; Coordonnée écran Y
	swap		d6
.NextPerspective:
	dbra		d7,.CalculNextPoint
	rts

;*******************************************************************************
;	Détermine si la face est visible
;	IN	:	d0.w = X1
;				d1.w = Y1
;				d2.w = X2
;				d3.w = Y2
;				d4.w = X3
;				d5.w = Y3
;	OUT	:	d6.w = 0 => face non visible, 1 => face visible
;*******************************************************************************

HiddenFace:
	movem.l	d0-d5,-(sp)										; Sauve les coordonnées
	move.w	#1,d6													; Par défaut la face est visible
	sub.w		d2,d0													; X1-X2
	sub.w		d4,d2													; X2-X3
	sub.w		d3,d1													; Y1-Y2
	sub.w		d5,d3													; Y2-Y3
	muls		d1,d2													; d2 = (Y1-Y2)*(X2-X3)
	muls		d3,d0													; d0 = (Y2-Y3)*(X1-X2)
	cmp.w		d0,d2													; Face visible ?
	bge.s		.VisibleFace									; Oui
	move.w	#0,d6
.VisibleFace:
	movem.l	(sp)+,d0-d5										; Restaure les coordonnées
	rts

;*******************************************************************************
; Trace une ligne avec le blitter
; IN	:	d0.w = X1
;				d1.w = Y1
;				d2.w = X2
;				d3.w = Y2
;				d6.w = largeur du bitplan en octets
;				a5.l = adresse bitplan
;				a6.l = adresse custom base
;*******************************************************************************

BLT_LINE_MOD = 0												; 0 = LINE, 2 = FILL

DrawLine:
	movem.l	d0-d5/a5,-(a7)

	cmp.w		d1,d3													; Y1 > Y2
	bge.s		Y1InfY2												; Non
	exg			d0,d2													; On dessine toujours
	exg			d1,d3													; du haut vers le bas
Y1InfY2:
	sub.w		d1,d3													; d3 = Y2 - Y1 = deltaY
	move.w	d1,d4													; d4 = Y1
	mulu.w	d6,d1													; Offset ligne
	add.l		d1,a5													; a5 = Adresse ligne
	moveq		#0,d1
	sub.w		d0,d2													; d2 = X2 - X1 = deltaX
	bge.s		DXPositif											; Positif
	moveq		#2,d1													; d1 = 2 (Octant)
	neg.w		d2														; d2 -> positif
DXPositif:
	moveq		#$f,d4
	and.w		d0,d4													; d4 = X1 & $F = décalage point

	IFEQ		BLT_LINE_MOD-2
	move.b	d4,d5													; d5 = d4
	not.b		d5														; d5 = !d4 , pour mode FILL
	ENDC

	lsr.w		#3,d0													; d0 = X1 / 8
	add.w		d0,a5													; a5 = adresse de départ de la ligne
	ror.w		#4,d4													; Positionne les bits de décalage

	IFEQ		BLT_LINE_MOD
	or.w		#$bca,d4											; Minterm + sources, pour mode LINE
	ELSEIF
	or.w		#$b4a,d4											; Minterm + sources , pour mode FILL, deux lignes superposées s'annulent
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
	
	add.w		#$42,d3												; d3 = (GrandDelta+1 * 64) + 2 , pour éviter d'avoir H=0

	IFEQ		BLT_LINE_MOD-2
	bchg		d5,(a5)												; Pour mode FILL
	ENDC

	WAITBLT																; On attend le blitter

; Ces 5 lignes peuvent être placées en dehors de la fonction car les registres
; ne sont pas écrasés par le Blitter
	move.w	#-1,BLTAFWM(a6)								; Masque gauche = $ffff
	move.w	#-1,BLTBDAT(a6)								; Pattern ligne = $ffff
	move.w	#$8000,BLTADAT(a6)						; Valeur arbitraire du point
	move.w	d6,BLTCMOD(a6)								; Largeur bitplan
	move.w	d6,BLTDMOD(a6)								; Largeur bitplan

	move.l	d4,BLTCON0(a6)								; Minterm + sources + octant (BLTCON0 & BLTCON1)
	move.l	d2,BLTBMOD(a6)								; 2 * PetitDelta | 2 * (PetitDelta - GrandDelta) (BLTBMOD & BLTAMOD)
	move.l	a5,BLTCPTH(a6)								; Adresse de départ
	move.w	d0,BLTAPTL(a6)								; (2 * PetitDelta) - GrandDelta
	move.l	a5,BLTDPTH(a6)								; Adresse de départ
	move.w	d3,BLTSIZE(a6)								; (GrandDelta+1 * 64) + 2

	movem.l	(a7)+,d0-d5/a5
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
