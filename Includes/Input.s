;*******************************************************************************
;	Input.s
;	Fonctions pour tester l'état des joystick / gamepad / souris / clavier
; V1.5 Octobre 2014
;*******************************************************************************

; Constantes des positions du joystick
JOY_CENTER          = 0
JOY_UP							= 1
JOY_DOWN						= 2
JOY_LEFT						= 4
JOY_RIGHT						= 8
JOY_FIRE1						= 16
JOY_FIRE2						= 32

JOY_BUP							= 0
JOY_BDOWN						= 1
JOY_BLEFT						= 2
JOY_BRIGHT					= 3
JOY_BFIRE1					= 4
JOY_BFIRE2					= 5

; Constantes des positions du gamepad
PAD_CENTER          = 0
PAD_UP							= 1
PAD_DOWN						= 2
PAD_LEFT						= 4
PAD_RIGHT						= 8
PAD_PLAY						= 16
PAD_REWIND					= 32
PAD_FORWARD					= 64
PAD_GREEN						= 128
PAD_YELLOW					= 256
PAD_RED							= 512
PAD_BLUE						= 1024

PAD_BUP							= 0
PAD_BDOWN						= 1
PAD_BLEFT						= 2
PAD_BRIGHT					= 3
PAD_BPLAY						= 4
PAD_BREWIND					= 5
PAD_BFORWARD				= 6
PAD_BGREEN					= 7
PAD_BYELLOW					= 8
PAD_BRED						= 9
PAD_BBLUE						= 10

;*******************************************************************************
	SECTION INPUT,CODE
;*******************************************************************************

;*******************************************************************************
;	Lecture de la position d'un joystick
; OUT	:	d0.w = état du joystick
;*******************************************************************************
;	Bits		F  .  .  .  .  .  .  .  .  .  .  .  .  .  .  0
; Valeur	Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0 X7 X6 X5 X4 X3 X2 X1 X0
;*******************************************************************************
;	Y0 Y1 X1 X0 => Position
;	0  0  0  0	=	CENTRE
;	0  0  0  1	=	BAS
;	0  0  1  0	=	BAS DROIT
;	0  0  1  1	=	DROITE
;	0  1  0  0	=	HAUT
;	0  1  0  1	=	CENTRE
;	0  1  1  0	=	CENTRE
;	0  1  1  1	=	HAUT DROIT
;	1  0  0  0	=	HAUT GAUCHE
;	1  0  0  1	=	CENTRE
;	1  0  1  0	=	CENTRE
;	1  0  1  1	=	CENTRE
;	1  1  0  0	=	GAUCHE
;	1  1  0  1	=	BAS GAUCHE
;	1  1  1  0	=	CENTRE
;	1  1  1  1	=	CENTRE
;*******************************************************************************

; Détermine l'état du port 0 (en général la souris)
CheckJoystick0:
	movem.l	d1/a0,-(a7)
	move.w	CUSTOM+JOY0DAT,d0							; Données du joystick 0
	andi.w	#$303,d0
	move.w	d0,d1
	lsr.w		#6,d1
	or.b		d0,d1
	lea			JoystickTable,a0							; Notre table des positions
	move.b	(a0,d1.w),d0									; Etat du joystick
	btst		#6,CIAA+CIAPRA								; Bouton feu 1
	bne.s		.NotFire1
	or.b		#JOY_FIRE1,d0
.NotFire1:
	move.w	CUSTOM+POTGOR,d1							; Bouton feu 2
	btst		#10,d1
	bne.s		.NotFire2
	or.b		#JOY_FIRE2,d0
.NotFire2:
	move.w	#$0C00,CUSTOM+POTGO						; Reset le potar du feu 2
	move.b	d0,Joystick0State							; Sauve le statut du joystick
	movem.l	(a7)+,d1/a0
	rts

; Détermine l'état du port 1 (en général le joystick)
CheckJoystick1:
	movem.l	d1/a0,-(a7)
	move.w	CUSTOM+JOY1DAT,d0
	andi.w	#$303,d0
	move.w	d0,d1
	lsr.w		#6,d1
	or.b		d0,d1
	lea			JoystickTable,a0
	move.b	(a0,d1.w),d0
	btst		#7,CIAA+CIAPRA
	bne.s		.NotFire1
	or.b		#JOY_FIRE1,d0
.NotFire1:
	move.w	CUSTOM+POTGOR,d1
	btst		#14,d1
	bne.s		.NotFire2
	or.b		#JOY_FIRE2,d0
.NotFire2:
	move.w	#$C000,CUSTOM+POTGO
	move.b	d0,Joystick1State
	movem.l	(a7)+,d1/a0
	rts

;*******************************************************************************
;	Lecture de la position d'un gamepad
; OUT	:	d0.w = état du gamepad
;*******************************************************************************

; Détermine l'état du port 1
CheckGamepad1:
	movem.l	d1-d3/a0,-(a7)
	move.w	CUSTOM+JOY1DAT,d0
	andi.w	#$303,d0
	move.w	d0,d1
	lsr.w		#6,d1
	or.b		d0,d1
	lea			JoystickTable,a0
	move.b	(a0,d1.w),d3
.CheckButtons:
	bset		#7,CIAA+CIADDRA
	bclr		#7,CIAA+CIAPRA
	move.w	#$6F00,CUSTOM+POTGO
	moveq.l	#0,d0
	moveq.l	#7,d1
	bra.b		.TestButton2		
.TestButton:
	tst.b		CIAA+CIAPRA
	tst.b		CIAA+CIAPRA
	tst.b		CIAA+CIAPRA
.TestButton2:
	tst.b		CIAA+CIAPRA
	tst.b		CIAA+CIAPRA
	tst.b		CIAA+CIAPRA
	tst.b		CIAA+CIAPRA
	tst.b		CIAA+CIAPRA
	move.w	CUSTOM+POTGOR,d2
	bset		#7,CIAA+CIAPRA
	bclr		#7,CIAA+CIAPRA
	btst		#14,d2
	bne.b		.NotPressed
	bset		d1,d0
.NotPressed:
	dbf			d1,.TestButton
	bclr		#7,CIAA+CIADDRA
	move.w	#$FFFF,CUSTOM+POTGO
	lsl.w		#3,d0
	or.b		d3,d0
	move.w	d0,Gamepad1State
	movem.l	(a7)+,d1-d3/a0
	rts

;*******************************************************************************
;	Initialise les paramètres de la souris
; IN	:	d0.w = limite X de la souris (ex: 320)
; 			d1.w = limite Y de la souris (ex: 256)
;*******************************************************************************
InitMouse:
	move.w	#$0000,CUSTOM+JOYTEST					; Reset les positions
	subi.w	#1,d0
	move.w	d0,MouseLimit
	subi.w	#1,d1
	move.w	d1,MouseLimit+2
	rts

;*******************************************************************************
;	Lecture de la position relative de la souris
; OUT	:	d0.l = delta souris (high: delta Y, low: delta X)
;*******************************************************************************
CheckMouse:
	movem.l	d1-d2,-(sp)
	move.w	CUSTOM+JOY0DAT,d0							; Récupère les données souris
	move.w	d0,d1
	lsr.w		#8,d0													; Les bits pour Y
	move.w	MouseOldCounter+2,d2					; Ancienne donnée de la souris
	move.w	d0,MouseOldCounter+2					; Mise à jour
	sub.w		d2,d0
	cmpi.w	#127,d0												; Test le dépassement
	ble.s		.NoSubY
	subi.w	#256,d0
.NoSubY:
	cmpi.w	#-127,d0											; Test le dépassement
	bge.s		.NoAddY
	addi.w	#256,d0
.NoAddY:
	andi.w	#$FF,d1												; Les bits pour X
	move.w	MouseOldCounter,d2						; Ancienne donnée de la souris
	move.w	d1,MouseOldCounter						; Mise à jour
	sub.w		d2,d1
	cmpi.w	#127,d1												; Test le dépassement
	ble.s		.NoSubX
	subi.w	#256,d1
.NoSubX:
	cmpi.w	#-127,d1											; Test le dépassement
	bge.s		.NoAddX
	addi.w	#256,d1
.NoAddX:
	swap		d0														; Place les bits Y
	move.w	d1,d0													; Et les bits X
	move.l	d0,MouseDeltaY								; Sauve le delta en Y et en X
	movem.l	(sp)+,d1-d2
	rts

;*******************************************************************************
;	Lecture de la position absolue de la souris
; OUT	:	d0.l = position souris (high: position Y, low: position X)
;*******************************************************************************
CheckMouseAbsolute:
	movem.l	d1-d2,-(sp)
	bsr			CheckMouse
	add.w		MousePositionX,d0							; On ajoute la position X souris
	tst.w		d0
	bpl.s		.NoLeftBorder									; Position X négative
	move.w	#0,d0													; On force à 0
.NoLeftBorder:
	cmp.w		MouseLimit,d0
	ble.s		.NoRightBorder								; On sort de l'écran à droite
	move.w	MouseLimit,d0									; On fixe à la limite
.NoRightBorder:
	swap		d0														; Delta Y souris
	add.w		MousePositionY,d0
	tst.w		d0
	bpl.s		.NoTopBorder									; Position Y négative
	move.w	#0,d0													; On force à 0
.NoTopBorder:
	cmp.w		MouseLimit+2,d0
	ble.s		.NoBottomBorder								; On sort de l'écran en bas
	move.w	MouseLimit+2,d0								; On fixe à la limite
.NoBottomBorder
	swap		d0														; On reposition Y puis X
	move.l	d0,MousePositionY							; Sauve la position de la souris
	movem.l	(sp)+,d1-d2
	rts

;*******************************************************************************
	SECTION	INPUTDATA,DATA
;*******************************************************************************

; Etat des joystick
; Bits		7  6  5  4  3  2  1  0
; Valeur  .  .  F2 F1 R  L  D  U
	
Joystick0State:
	dc.b		0
Joystick1State:
	dc.b		0

; Etat des gamepad
; Bits		A  9  8  7  6  5  4  3  2  1  0
; Valeur  FB FR FY FG FW RW PL R  L  D  U

	EVEN
Gamepad0State:
	dc.w		0
Gamepad1State:
	dc.w		0

	EVEN
JoystickTable:
	dc.b		JOY_CENTER,JOY_DOWN,JOY_DOWN+JOY_RIGHT,JOY_RIGHT
	dc.b		JOY_UP,JOY_CENTER,JOY_CENTER,JOY_UP+JOY_RIGHT
	dc.b		JOY_UP+JOY_LEFT,JOY_CENTER,JOY_CENTER,JOY_CENTER
	dc.b		JOY_LEFT,JOY_DOWN+JOY_LEFT,JOY_CENTER,JOY_CENTER

	EVEN
MouseLimit:
	dc.w		0,0

MouseOldCounter:
	dc.w		0,0

MouseDeltaY:
	dc.w		0

MouseDeltaX:
	dc.w		0

MousePositionY:
	dc.w		0

MousePositionX:
	dc.w		0
