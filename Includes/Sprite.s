;*******************************************************************************
;	Sprite.s
;	Fonctions de gestion des sprites
; V1.0 Mars 2015
;*******************************************************************************

;*******************************************************************************
	SECTION SPRITE,CODE
;*******************************************************************************

;*******************************************************************************
; Calcul les mots de controle du sprite
; IN	:	d0.w = coordonnée X
;				d1.w = coordonnée Y
;				d2.w = hauteur du sprite
;				d3.w = position écran (W: starty, W: startx)
; OUT	: d0.l = mots de controle du sprite
;
; V = VSTART, H = HSTART, S = VSTOP, A = ATTACH, x = UNUSED
;
; SPRxPOS : 15 .  .  .  .  .  .  8  7  .  .  .  .  .  .  0
;           V7 V6 V5 V4 V3 V2 V1 V0 H8 H7 H6 H5 H4 H3 H2 H1
;
; SPRxCTL : 15 .  .  .  .  .  .  8  7  .  .  .  .  .  .  0
;           S7 S6 S5 S4 S3 S2 S1 S0 A  x  x  x  x  V8 S8 H0
;*******************************************************************************
CalculSpriteControl:
	andi.l	#$FFFF,d0
	add.w		d3,d0													; On ajoute l'offset écran X
	andi.l	#$FFFF,d1
	swap		d3
	add.w		d3,d1													; On ajoute l'offset écran Y
	andi.l	#$FFFF,d2
	swap		d3														; Retour à la normale
	add.w		d1,d2													; Fin du sprite Y
	lsl.l		#8,d1													; Positionne les low bits VSTART
	ror.l		#1,d0													; Positionne les high bits HSTART
	or.w		d1,d0													;	Forme le premier mot de controle (SPRxPOS)
	swap		d0														; Récupère le low bit HSTART
	rol.w		#1,d0													; Que l'on met en première position
	lsl.l		#8,d2													; Positionne les low bits VSTOP
	or.w		d2,d0													;	Que l'on place pour le second mot de controle (SPRxCTL)
	swap		d1														; Récupère le high bit VSTART
	lsl.w		#2,d1													; Que l'on met en troisième position
	or.w		d1,d0													; Ajoute le au mot de controle
	swap		d2														; Récupère le high bit VSTOP
	add.w		d2,d2													; Que l'on met en deuxième position
	or.w		d2,d0													;	Et qu'on ajoute au mot de controle
	rts
