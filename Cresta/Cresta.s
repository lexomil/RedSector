;*******************************************************************************
; Cresta.s (aka Moon Cresta)
; Démo screen pour RSi
; Amiga OCS / ECS version
; V1.4 Mars 2015
;*******************************************************************************

; Définition des registres
	INCLUDE	"Includes/Register.s"

; Constantes système
	INCLUDE	"Includes/Constant.s"

; Macros
	INCLUDE	"Includes/Macro.s"

; Activation DMA	
DMA_SET 						= DMA_ON+DMA_BITPLANE+DMA_COPPER+DMA_BLITTER+DMA_SPRITE

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

VBL_SECOND					= 50

;*******************************************************************************
; Constantes des étoiles
;*******************************************************************************

STAR_NUMBER					= 176
STAR_POSX						= 0
STAR_POSY						= 0
STAR_HEIGHT					= 176

;*******************************************************************************
; Constantes du logo
;*******************************************************************************

; Image du logo
LOGOPIC_WIDTH				= 320
LOGOPIC_HEIGHT			= 82
LOGOPIC_DEPTH				= 5
LOGOPIC_SIZE				= (LOGOPIC_WIDTH/8)*LOGOPIC_HEIGHT*LOGOPIC_DEPTH

; Playfield
LOGOPF_WIDTH				= 336
LOGOPF_HEIGHT				= 96
LOGOPF_DEPTH 				= 5
LOGOPF_LINE					= (LOGOPF_WIDTH/8)*LOGOPF_DEPTH	; Interleaved
LOGOPF_SIZE					= (LOGOPF_WIDTH/8)*LOGOPF_HEIGHT*LOGOPF_DEPTH
LOGOPF_MOD	 				= LOGOPF_LINE-((SCREEN_WIDTH+16)/8)

LOGO_WIDTH					= 320
LOGO_HEIGHT					= 82
LOGO_POSX						= 0
LOGO_POSY						= (LOGOPF_HEIGHT-LOGO_HEIGHT)/2

;*******************************************************************************
; Constantes du scrolltext
;*******************************************************************************

; Image des fontes
FONTPIC_WIDTH				= 256
FONTPIC_HEIGHT			= 200
FONTPIC_DEPTH				= 3
FONTPIC_LINE				= (FONTPIC_WIDTH/8)*FONTPIC_DEPTH
FONTPIC_SIZE				= (FONTPIC_WIDTH/8)*FONTPIC_HEIGHT*FONTPIC_DEPTH

FONT_WIDTH					= 32
FONT_HEIGHT					= 32

; Playfield du scrolltext
SCROLLPF_WIDTH			= 320+320+(FONT_WIDTH*2)
SCROLLPF_HEIGHT			= 80+80-FONT_HEIGHT+2
SCROLLPF_DEPTH 			= 3
SCROLLPF_LINE				= (SCROLLPF_WIDTH/8)*SCROLLPF_DEPTH	; Interleaved
SCROLLPF_SIZE				= (SCROLLPF_WIDTH/8)*SCROLLPF_HEIGHT*SCROLLPF_DEPTH
SCROLLPF_MOD	 			= SCROLLPF_LINE-((SCREEN_WIDTH+16)/8)

SCROLL_HEIGHT				= 80
SCROLL_MAXMES				= 1000
SCROLL_SPEED				= 4

SCROLL_STARTX				= FONT_WIDTH
SCROLL_STOPX				= 320+(FONT_WIDTH*2)
SCROLL_POSY					= 48

;*******************************************************************************
; Constantes de l'animation du sol
;*******************************************************************************

; Image du sol de la planète
GROUND_WIDTH				= 640
GROUND_HEIGHT				= 80

GROUND_STARTY				= LOGOPF_HEIGHT+SCROLL_HEIGHT	; Début du sol
GROUND_NBLEVEL			= 16								; 16 niveaux de scrolling
GROUND_LEVELHT			= 5									; 5 pixels par niveau

; Playfield du sol
GROUNDPF_WIDTH			= 320*3
GROUNDPF_HEIGHT			= 80
GROUNDPF_DEPTH			= 3
GROUNDPF_LINE				= (GROUNDPF_WIDTH/8)*GROUNDPF_DEPTH	; Interleaved
GROUNDPF_SIZE				= (GROUNDPF_WIDTH/8)*GROUNDPF_HEIGHT*GROUNDPF_DEPTH
GROUNDPF_MOD				= GROUNDPF_LINE-((SCREEN_WIDTH+16)/8)

; Sprite des structures
GROUND_NBSPRITE			= 6
GROUND_SPRWIDTH			= 16

;*******************************************************************************
; Constantes du Glenz
;*******************************************************************************

; Playfield du glenz
GLENZPF_WIDTH				= 320+16
GLENZPF_HEIGHT			= 160
GLENZPF_DEPTH				= 3
GLENZPF_LINE				= (GLENZPF_WIDTH/8)	; Standard
GLENZPF_PLANE				= GLENZPF_LINE*GLENZPF_HEIGHT
GLENZPF_SIZE				= GLENZPF_PLANE*GLENZPF_DEPTH
GLENZPF_MOD					= GLENZPF_LINE-((SCREEN_WIDTH+16)/8)

GLENZ_ZOOMSPEED			= 20
GLENZ_ZOOMTIME			= 4*VBL_SECOND
GLENZ_PLAYTIME			= (4*VBL_SECOND)+10

;*******************************************************************************
	SECTION PROGRAM,CODE
;*******************************************************************************

Start:
	jsr			SaveSystem										; Sauve les données système
	tst.l		d0
	beq			Restore												; Restaure en cas d'erreur

.Initialize:
	bsr			InitSprites										; Initialise les sprites
	bsr			InitStarfield									; Initialise le starfield
	bsr			InitLogo											; Initialise le logo
	bsr			InitScrollText								; Initialise le scrolltext
	bsr			InitGround										; Initialise le sol
	bsr			InitGlenz											; Initialise le glenz

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

.StartMusic:
	lea			CUSTOM,a6
	move.l	VbrBase,a0
	move.b	#1,d0
	jsr			mt_install_cia
	lea			Music,a0
	movea.l	#0,a1
	move.w	#0,d0
	jsr			mt_init
	st			mt_Enable

;*******************************************************************************

MainLoop:
	move.w	#$0,FlagVBL
WaitVBL:
	tst.w		FlagVBL
	beq.s		WaitVBL												; On attend la vbl

	bsr			SetGlenzPlayfield
	bsr			GlenzClearScreen
	bsr			AnimateGlenz
	bsr			SwitchGlenzPlayfield
	WAITBLT

	btst		#MOUSE_BUTTON1,CIAA+CIAPRA		; Test la souris
	bne.s		MainLoop

;*******************************************************************************

.StopMusic:
	lea			CUSTOM,a6
	jsr			mt_end
	jsr			mt_remove_cia

Restore:
	jsr			RestoreSystem
	
	moveq.l	#0,d0
	rts

;*******************************************************************************
;	Routines d'initialisation
;*******************************************************************************

InitSprites:
	lea     CLSpriteAdr,a0
	lea			GroundSpriteData,a1
	move.l	#(SCREEN_STARTY<<16)|SCREEN_STARTX,d3	; Position de l'écran
	move.w  #SPR_MAXSPRITE-1,d7
.NextSprite:
	move.l	(a1)+,a2											; Adresse du sprite
	move.l	(a1)+,d0											; Position absolue en X (zap la scroll zone)
	move.w	(a1)+,d1											; Position absolue en Y (ne change pas)
	move.w	(a1)+,d2											; Hauteur du sprite
	jsr			CalculSpriteControl						; Calcul le mot de controle
	move.l	d0,(a2)												; Le sauve pour le sprite
	move.l	a2,d0													; Adresse du sprite
	move.w  d0,6(a0)											; Copie dans la copper list
	swap    d0
	move.w  d0,2(a0)
	adda.l	#8,a0
	dbra		d7,.NextSprite
	rts

;*******************************************************************************

InitStarfield:

	lea			CLStarSpriteAdr,a0						; Pointeur du sprite 6
	move.l	#StarSprite,d0								; Notre sprite
	move.w	d0,6(a0)
	swap		d0
	move.w	d0,2(a0)

.PrecalPosition
	lea			StarPosition,a0								; Notre table des positions
	moveq.l	#0,d7													; Position en X
	move.w	#SCREEN_WIDTH-1,d6
.NextPosition:
	move.w	d7,d0													; Position X du sprite
	move.w	#STAR_POSY,d1									; Position Y
	move.w	#STAR_HEIGHT,d2								; Et hauteur fixe
	move.l	#(SCREEN_STARTY<<16)|SCREEN_STARTX,d3	; Position de l'écran
	jsr			CalculSpriteControl						; Calcul le mot de controle
	move.l	d0,(a0)+											; Stocke le résultat dans notre table
	addq.l	#1,d7													; Position suivante
	dbra		d6,.NextPosition

.PrecalcStarSpeed:
	move.l	#'Rs1.',RandomSeed						; Seed pour fonction random
	lea			StarData,a1										; Données des étoiles
	move.w	#STAR_NUMBER-1,d7							; 176 étoiles
.NextStar:
	move.w	#SCREEN_WIDTH,d0
	jsr			RandXorShift
	lsl.w		#2,d0													; Multiplie par 4 pour index dans la table
	move.w	d0,(a1)+											; Position initiale de l'étoile
	move.w	#3,d0													; 3 vitesses possibles
	jsr			RandXorShift
	addi.w	#1,d0
	lsl.w		#2,d0													; Multiplie par 4 pour index dans la table
	move.w	d0,(a1)+											; Vitesse de l'étoile
	dbra		d7,.NextStar

.SetStarsColor:
	lea			StarData,a0										; Données des étoiles
	lea			CLStarsLogo,a1								; La copper list
	move.w	#LOGOPF_HEIGHT-1,d7						; 96 lignes à faire
StarsLogoColor:
	move.w	2(a0),d0											; Vitesse de l'étoile
	lea			4(a0),a0
	cmpi.w	#4,d0													; Vitesse lente
	bne.s		.Speed2
	move.w	#$0555,d1											; Couleur de l'étoile
	bra.s		.SetColor
.Speed2:
	cmpi.w	#8,d0													; Vitesse moyenne
	bne.s		.Speed3
	move.w	#$0AAA,d1											; Couleur de l'étoile
	bra.s		.SetColor
.Speed3:
	move.w	#$0FFF,d1											; Couleur de l'étoile
.SetColor:
	move.w	d1,14(a1)											; Sauve la couleur dans la copper list
	lea			20(a1),a1											; Etoile suivante
	dbra		d7,StarsLogoColor

	lea			CLStarInter,a1								; Etoile de transition (logo / sol)
StarInterColor:
	move.w	2(a0),d0
	lea			4(a0),a0
	cmpi.w	#4,d0
	bne.s		.Speed2
	move.w	#$0555,d1
	bra.s		.SetColor
.Speed2:
	cmpi.w	#8,d0
	bne.s		.Speed3
	move.w	#$0AAA,d1
	bra.s		.SetColor
.Speed3:
	move.w	#$0FFF,d1
.SetColor:
	move.w	d1,2(a1)

	lea			CLStarsGround,a1							; Etoiles niveau sol
	move.w	#SCROLL_HEIGHT-2,d7
StarsGroundColor:
	move.w	2(a0),d0
	lea			4(a0),a0
	cmpi.w	#4,d0
	bne.s		.Speed2
	move.w	#$0555,d1
	bra.s		.SetColor
.Speed2:
	cmpi.w	#8,d0
	bne.s		.Speed3
	move.w	#$0AAA,d1
	bra.s		.SetColor
.Speed3:
	move.w	#$0FFF,d1
.SetColor:
	move.w	d1,14(a1)
	lea			20(a1),a1
	dbra		d7,StarsGroundColor

	rts

;*******************************************************************************

InitLogo:

.CopyLogo:
	lea			LogoPlayfield,a0
	adda.l	#(LOGOPF_LINE*LOGO_POSY)+1,a0
	lea			LogoPicture,a1
	move.w	#(LOGO_HEIGHT*LOGOPIC_DEPTH)-1,d7
.NextLine:
	move.w	#(LOGO_WIDTH/8)-1,d6
.NextByte:
	move.b	(a1)+,(a0)+
	dbra		d6,.NextByte
	lea			2(a0),a0
	dbra		d7,.NextLine

.SetBplPointer:
	lea			CLLogoBitplaneAdr,a0
	move.l	#LogoPlayfield,d0							; Notre playfield
	move.w	#LOGOPF_DEPTH-1,d7
.NextBplPointer:
	move.w	d0,6(a0)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a0)											; Adresse bitplan
	swap		d0
	addi.l	#LOGOPF_WIDTH/8,d0						; Bitplan suivant (interleave)
	lea			8(a0),a0
	dbra		d7,.NextBplPointer

.PrecalcSwingTable:
	lea			LogoSwingTable,a0							; Table des positions du logo
	lea			ScrollingTable,a1							; Table des offsets de scrolling
.NextOffset:
	move.w	(a0),d0												; Valeur du décalage
	cmpi.w	#-1,d0												; Fin de la table ?
	beq.s		.InitEnd											; Oui
	add.w		d0,d0
	add.w		d0,d0													; x4
	move.l	0(a1,d0.w),d0									; Récupère l'offset de décalage
	move.w	d0,(a0)+											; Sauve la valeur
	bra.s		.NextOffset										; Offset suivant

.InitEnd:
	rts

;*******************************************************************************

InitScrollText:

	lea			ScrollTextMessage,a0					; Texte du scrolling
	lea			ScrollTextBuffer,a1						; Buffer pour stocker l'adresse des lettres
.NextText:
	move.b	(a0)+,d0											; Charge une lettre du scrolltext
	beq.s		.EndText											; On est a la fin du texte
.DecodeLetter:
	lea			ScrollTextTranslate,a2				; Table de conversion
	moveq.l	#0,d1													; Colonne de la lettre
	moveq.l	#0,d2													; Ligne de la lettre
.NextLetter:
	move.b	(a2)+,d3											; Récupère une lettre de la table de conversion
	bne.s		.CheckLine										; Pas a la fin de la table
	move.l	#FontePicture,(a1)+						; Caractère non trouvé on met un espace
	bra.s		.NextText											; Lettre suivante
.CheckLine:
	cmpi.b	#1,d3													; Fin de la ligne
	bne.s		.CheckLetter									; Pas encore
	moveq.l	#0,d1
	addq.l	#1,d2													; Compte les lignes
	bra.s		.NextLetter										; Lettre suivante
.CheckLetter:
	cmp.b		d0,d3													; Est-ce notre lettre
	bne.s		.NoMatch											; Non
	mulu.w	#FONT_WIDTH/8,d1							; Adresse de la colonne
	mulu.w	#FONT_HEIGHT*FONTPIC_LINE,d2	; Adresse de la ligne
	move.l	#FontePicture,d3							; Adresse de la fonte
	add.l		d1,d3
	add.l		d2,d3													; Adresse de la lettre
	move.l	d3,(a1)+											; On sauve l'adresse
	bra.s		.NextText											; Lettre suivante
.NoMatch:
	addq.l	#1,d1													; Compte les colonnes
	bra.s		.NextLetter										; Passe à la lettre suivante
.EndText:
	move.l	#0,(a1)												; Indique la fin du buffer

.SetBplPointer:
	lea			CLScrollTextBitplaneAdr,a0
	move.l	#ScrollTextPlayfield,d0				; Notre playfield
	move.w	#SCROLLPF_DEPTH-1,d7
.NextBplPointer:
	move.w	d0,6(a0)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a0)											; Adresse bitplan
	swap		d0
	addi.l	#SCROLLPF_WIDTH/8,d0					; Bitplan suivant (interleaved)
	lea			8(a0),a0
	dbra		d7,.NextBplPointer

.SetFonteDegrade:
	lea			ScrollTextColors,a0
	lea			CLStarsGround,a1
	move.w	#SCROLL_HEIGHT-2,d7
.NextFonteColor:
	move.w	(a0)+,18(a1)
	lea			20(a1),a1
	dbra		d7,.NextFonteColor

.PrecalcScrollTable:
	lea			ScrollTextTable,a0						; Table de décalage du playfield
	lea			ScrollingTable,a1							; Table des offset de scrolling
	move.w	#0,d0													; Position de départ
	move.w	#SCROLL_STOPX-1,d7						; Nombre de positions à calculer
.NextPosition:
	move.w	d0,d1													; Position actuelle
	andi.w	#$f,d1												; Ne garde que les 4 bits de poids faible
	add.w		d1,d1
	add.w		d1,d1													; x4
	move.l	0(a1,d1.w),d1									; Offset / décalage
	move.w	d0,d2													; Position actuelle
	lsr.w		#4,d2													; Divisée par 16
	add.w		d2,d2													; x2
	swap		d1
	add.w		d2,d1													; Calcul l'offset d'adresse
	swap		d1
	move.l	d1,(a0)+
	addq.w	#1,d0													; Position suivante
	dbra		d7,.NextPosition

.SetScrollAddr:
	lea			ScrollBufferLetter,a0
	move.l	#ScrollTextPlayfield,d0
	addi.l	#SCROLL_POSY*SCROLLPF_LINE,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)

	rts

;*******************************************************************************

InitGround:

.PrecalcScrollTable:
	lea			GroundPlayfieldTable,a0				; Table de décalage du playfield
	lea			ScrollingTable,a1							; Table des offset de scrolling
	move.w	#0,d0													; Position de départ
	move.w	#GROUND_WIDTH-1,d7						; Nombre de positions à calculer (640)
.NextPosition:
	move.w	d0,d1													; Position actuelle
	andi.w	#$f,d1												; Ne garde que les 4 bits de poids faible
	add.w		d1,d1
	add.w		d1,d1													; x4
	move.l	0(a1,d1.w),d1									; Offset / décalage
	move.w	d0,d2													; Position actuelle
	lsr.w		#4,d2													; Divisée par 16
	add.w		d2,d2													; x2
	swap		d1
	add.w		d2,d1													; Calcul l'offset d'adresse
	swap		d1
	move.l	d1,(a0)+
	addq.w	#1,d0													; Position suivante
	dbra		d7,.NextPosition

.PrecalGroundScroll:
	move.l	#GroundPlayfield,d0						; Adresse de départ du playfield
	lea			GroundScrollingTable,a0				; Table du scrolling du sol
	lea			CLGroundLevelAdr,a1						; Copper list
	lea			8(a1),a1											; Pointeur des bitplans
	move.w	#GROUND_NBLEVEL-1,d7					; 16 niveaux à faire
.NextLevel:
	move.w	(a0),d1												; Récupère la vitesse
	add.w		d1,d1													; x2 pour vitesse en fixed point (1=0.25, 2=0.5, 4=1)
	move.w	d1,(a0)												; Sauve la nouvelle vitesse
	move.l	d0,4(a0)											; Sauve l'adresse du niveau

	move.l	d0,d1
	move.w	#GROUNDPF_DEPTH-1,d6					; 3 plans
.NextLevelPointer:
	move.w	d1,6(a1)											; Adresse bitplan
	swap		d1
	move.w	d1,2(a1)											; Adresse bitplan
	swap		d1
	addi.l	#GROUNDPF_WIDTH/8,d1					; Bitplan suivant (interleaved)
	lea			8(a1),a1											; Bitplan suivant
	dbra		d6,.NextLevelPointer
	lea			12(a1),a1											; Niveau suivant
	
	addi.l	#GROUNDPF_LINE*GROUND_LEVELHT,d0	; Adresse niveau suivant
	lea			8(a0),a0											; Niveau suivant
	dbra		d7,.NextLevel

	rts

;*******************************************************************************

InitGlenz:

	move.l	#GlenzPlayfield,d0
	move.l	d0,GlenzPlayfieldDraw
	addi.l	#GLENZPF_SIZE,d0
	move.l	d0,GlenzPlayfieldWork

	lea			GlenzObjectList,a2
.NextObject:
	tst.l		(a2)
	beq.s		.SetBplPointer
	move.l	(a2)+,a0											; Notre objet
.PrepareObject:
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
	bra.s		.NextObject										; Object suivant

.SetBplPointer:
	lea			CLGlenzBitplaneAdr,a0
	move.l	GlenzPlayfieldDraw,d0					; Notre playfield
	move.w	#GLENZPF_DEPTH-1,d7
.NextBplPointer:
	move.w	d0,6(a0)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a0)											; Adresse bitplan
	swap		d0
	addi.l	#(GLENZPF_WIDTH/8)*GLENZPF_HEIGHT,d0	; Bitplan suivant (standard)
	lea			8(a0),a0
	dbra		d7,.NextBplPointer

	rts

;*******************************************************************************
;	Routines d'animation
;*******************************************************************************

AnimateStarfield:
	lea			StarData,a1
	lea			StarPosition,a2

AnimateStarsLogo:
	lea			CLStarsLogo,a0
	move.w	#LOGOPF_HEIGHT-1,d7
.NextStar:
	move.w	(a1),d0												; Position de l'étoile
	sub.w		2(a1),d0											; Vitesse
	bge.s		.NoWrap
	addi.w	#SCREEN_WIDTH*4,d0
.NoWrap:
	move.w	d0,(a1)												; Sauve la nouvelle position
	lea			4(a1),a1											; Prochaine étoile
	move.l	0(a2,d0.w),d0									; Mots de contrôle du sprite
	move.w	d0,10(a0)
	swap		d0
	move.w	d0,6(a0)											; On le met à jour dans la copper list
	lea			20(a0),a0											; Sprite suivant
	dbra		d7,.NextStar									; Etoile suivante
	
AnimateStarInter:
	lea			CLStarInter,a0
	move.w	(a1),d0												; Position de l'étoile
	sub.w		2(a1),d0											; Vitesse
	bge.s		.NoWrap
	addi.w	#SCREEN_WIDTH*4,d0
.NoWrap:
	move.w	d0,(a1)												; Sauve la nouvelle position
	lea			4(a1),a1											; Prochaine étoile
	move.l	0(a2,d0.w),d0									; Mots de contrôle du sprite
	move.w	d0,6(a0)
	swap		d0
	move.w	d0,2(a0)											; On le met à jour dans la copper list

AnimateStarsGround:
	lea			CLStarsGround,a0
	move.w	#SCROLL_HEIGHT-2,d7
.NextStar:
	move.w	(a1),d0												; Position de l'étoile
	sub.w		2(a1),d0											; Vitesse
	bge.s		.NoWrap
	addi.w	#SCREEN_WIDTH*4,d0
.NoWrap:
	move.w	d0,(a1)												; Sauve la nouvelle position
	lea			4(a1),a1											; Prochaine étoile
	move.l	0(a2,d0.w),d0									; Mots de contrôle du sprite
	move.w	d0,10(a0)
	swap		d0
	move.w	d0,6(a0)											; On le met à jour dans la copper list
	lea			20(a0),a0											; Sprite suivant
	dbra		d7,.NextStar									; Etoile suivante

	rts

;*******************************************************************************

AnimateLogo:
	movea.l	LogoSwingPtr,a0								; Pointeur sur la table des vagues
	lea			CLLogoScroll,a1								; Copper list
	move.w	#LOGO_HEIGHT-1,d7							; 82 lignes a faire
.NextLine:
	lea			18(a1),a1											; Registre BPLCON1 de la copper list
	move.w	(a0)+,(a1)+										; Valeur du décalage
	dbra		d7,.NextLine									; Ligne suivante
	cmpi.w	#-1,(a0)											; Fin de la table ?
	bne.s		.NoWrap												; Non
	move.l	#LogoSwingTable,LogoSwingPtr	; Oui, on revient au début
	rts
.NoWrap:
	addi.l	#2,LogoSwingPtr								; On passe a la coordonnée suivante
	rts

;*******************************************************************************

TextScrolling:

	movea.l	ScrollSwingPtr,a0
	cmpi.w	#-1,(a0)
	bne.s		.NoWrapSwing
	lea			ScrollSwingTable,a0
.NoWrapSwing:
	move.w	(a0)+,d0
	move.l	a0,ScrollSwingPtr
	move.w	d0,ScrollPosition+2

	move.w	LetterChange,d0								; Nouvelle lettre à charger ?
	bne.s		.NoNewLetter
	movea.l	ScrollTextPtr,a0							; Message en cours
	tst.l		(a0)													; Fin du message ?
	bne.s		.NoEndText
	lea			ScrollTextBuffer,a0						; Retour au début du message
.NoEndText:
	move.l	(a0)+,a1											; Adresse de la lettre à afficher
	move.l	a0,ScrollTextPtr							; Sauve le pointeur
.LoadLetter:
	move.l	ScrollBufferLetter,d1					; Adresse du buffer de la lettre
	move.l	d1,a2
	move.w	#(FONT_HEIGHT*SCROLLPF_DEPTH)-1,d7
.CopyLetterLine:
	lea			((SCREEN_WIDTH+FONT_WIDTH)/8)(a2),a3	; Second buffer de la lettre
	move.l	(a1),(a2)+										; Copie premier buffer
	move.l	(a1)+,(a3)+										; Copie second buffer
	lea			((FONTPIC_WIDTH-FONT_WIDTH)/8)(a1),a1
	lea			((SCROLLPF_WIDTH-FONT_WIDTH)/8)(a2),a2
	dbra		d7,.CopyLetterLine
	addi.l	#FONT_WIDTH/8,d1							; Adresse du prochain buffer
	move.l	d1,ScrollBufferLetter					; Que l'on sauve
	move.w	#FONT_WIDTH,d0								; Largeur de la fonte
.NoNewLetter:
	subi.w	#SCROLL_SPEED,d0							; Retire la vitesse du scroll
	move.w	d0,LetterChange								; Sauve pour prochain passage

.SetupScrolling:
	move.w	ScrollPosition,d0							; Position du scrolltext
	addi.w	#SCROLL_SPEED,d0							; On avance
	cmpi.w	#SCROLL_STOPX,d0							; Fin du scroll ?
	bne.s		.NoEndScroll
	move.w	#SCROLL_STARTX,d0							; Retour au début
	move.l	ScrollBufferLetter+4,ScrollBufferLetter	; Pour le buffer aussi
.NoEndScroll:
	move.w	d0,ScrollPosition							; On sauve la nouvelle position
	
	lea			ScrollTextTable,a0						; Table des décalage du scrolling
	lea			CLScrollText,a1								; La copperlist
	add.w		d0,d0
	add.w		d0,d0													; x4
	move.l	(a0,d0.w),d0									; Offset adresse / décalage
	andi.w	#$f,d0												; Ne conserve que l'offset du playfield impair
	move.w	d0,2(a1)											; Pousse la valeur dans la copperlist
	swap		d0														; Offset adresse
	ext.l		d0														; Etend pour le signe
	
	move.w	ScrollPosition+2,d1						; Position Y du scrolltext
	mulu.w	#SCROLLPF_LINE,d1							; Offset de la ligne
	addi.l	#ScrollTextPlayfield,d1				; Adresse de la ligne

	add.l		d1,d0													; Adresse du playfield

	lea			4(a1),a1
	move.w	#SCROLLPF_DEPTH-1,d7
.NextBitplanPointer:
	move.w	d0,6(a1)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a1)											; Adresse bitplan
	swap		d0
	addi.l	#SCROLLPF_WIDTH/8,d0					; Bitplan suivant (interleaved)
	lea			8(a1),a1											; Bitplan suivant
	dbra		d7,.NextBitplanPointer

	rts

;*******************************************************************************

AnimateGround:

	lea			GroundScrollingTable,a0				; Table des niveau du sol
	lea			CLGroundLevelAdr,a1						; Copper list
	lea			GroundPlayfieldTable,a2				; Table des offset de scrolling
	lea			4(a1),a1											; Décalage du playfield

	move.w	#GROUND_NBLEVEL-1,d7					; 16 niveaux à faire
.NextLevel:
	move.w	(a0)+,d0											; Récupère la vitesse du niveau
	add.w		(a0),d0												; Ajoute la position courante
	cmpi.w	#GROUND_WIDTH*4,d0						; Test le débordement
	blt.s		.NoWrap
	subi.w	#GROUND_WIDTH*4,d0
.NoWrap:
	move.w	d0,(a0)+											; Sauve la nouvelle position
	andi.w	#$fffc,d0											; Multiple de 4 pour l'index
	move.l	0(a2,d0.w),d0									; Offset + décalage du niveau 
	andi.w	#$f,d0												; Ne conserve que l'offset du playfield impair
	move.w	d0,2(a1)
	swap		d0														; Offset adresse
	ext.l		d0														; Etend pour le signe
	add.l		(a0)+,d0											; Adresse du playfield

	lea			4(a1),a1
	move.w	#GROUNDPF_DEPTH-1,d6					; 3 plans
.NextLevelPointer:
	move.w	d0,6(a1)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a1)											; Adresse bitplan
	swap		d0
	addi.l	#GROUNDPF_WIDTH/8,d0					; Bitplan suivant (interleaved)
	lea			8(a1),a1											; Bitplan suivant
	dbra		d6,.NextLevelPointer

	lea			8(a1),a1											; Niveau suivant
	dbra		d7,.NextLevel

	rts

;*******************************************************************************

AnimateSprite:
	lea			GroundSpriteData,a0						; Table des données des sprites
	lea			GroundScrollingTable,a1				; Table des niveau du sol
	move.l	#(SCREEN_STARTY<<16)|SCREEN_STARTX,d3	; Position de l'écran
	move.w	#GROUND_NBSPRITE-1,d7					; 6 sprites à traiter
.NextSprite:
	move.l	(a0)+,a2											; Adresse du sprite
	move.w	(a0)+,d6											; Zone du scroll du sprite
	move.w	(a0)+,d0											; Coordonnées X absolue du sprite
	lsl.w		#3,d6													; d6 x 8
	move.w	2(a1,d6.w),d6									; Position absolue du niveau
	lsr.w		#2,d6													; / 4
	move.w	d0,d5													; Position X du sprite
	addi.w	#GROUND_SPRWIDTH,d5						; + largeur du sprite
	cmp.w		d5,d6													; Sprite visibile ?
	bge.s		.SpriteOnLeft									; Peut-être à gauche
	sub.w		d6,d0													; Oui on calcul son X relatif
	bra.s		.CalculControl								; Et on calcul le mot de controle
.SpriteOnLeft:
	addi.w	#GROUND_WIDTH,d0							; Position relative du sprite de droite
	addi.w	#GROUND_WIDTH/2,d6						; Position de fin du niveau
	cmp.w		d0,d6													; Sprite visible ?
	blt.s		.NoDrawSprite									; Pas du tout
	subi.w	#GROUND_WIDTH/2,d6						; Position absolue du niveau
	sub.w		d6,d0													; Position X relative du sprite
	bra.s		.CalculControl								; On calcul le mot de controle
.NoDrawSprite:
	move.w	#-16,d0												; Sinon on le cache à gauche
.CalculControl:
	move.w	(a0)+,d1											; Position Y
	move.w	(a0)+,d2											; Hauteur du sprite
	jsr			CalculSpriteControl						; Calcul le mot de controle
	move.l	d0,(a2)												; Le sauve pour le sprite
	dbra		d7,.NextSprite								; Sprite suivant
	rts

;*******************************************************************************

SetGlenzPlayfield:
	lea			CLGlenzBitplaneAdr,a0
	move.l	GlenzPlayfieldDraw,d0					; Notre playfield
	subq.l	#2,d0
	move.w	#GLENZPF_DEPTH-1,d7
.NextBplPointer:
	move.w	d0,6(a0)											; Adresse bitplan
	swap		d0
	move.w	d0,2(a0)											; Adresse bitplan
	swap		d0
	addi.l	#GLENZPF_PLANE,d0							; Bitplan suivant (standard)
	lea			8(a0),a0
	dbra		d7,.NextBplPointer
	rts

;*******************************************************************************

GlenzClearScreen:

	lea			GlenzBlitAreaWork,a1					; Données calculées
	move.l	(a1)+,d0											; Fin du bitplan
	beq			.NoClear											; Si NULL rien à effacer
	move.w	(a1)+,d1											; Modulo
	move.w	(a1),d2												; Taille de la fenêtre blitter
	move.l	#GLENZPF_PLANE,d3							; Taille d'un plan

	lea			CUSTOM,a6

.ClearPlane1:
	WAITBLT
	move.l	d0,BLTDPT(a6)									; Adresse destination D
	move.w	d1,BLTDMOD(a6)								; Modulo destination
	move.w	#BLT_CLEAR,BLTCON0(a6)				; Sources D et décalage
	move.w	#BLT_DESCENDING,BLTCON1(a6)		; Blitter control 1
	move.w	d2,BLTSIZE(a6)								; Taille fenêtre à traiter = lance le blitter

.ClearPLane2:
	add.l		d3,d0
	WAITBLT
	move.l	d0,BLTDPT(a6)									; Adresse destination D
	move.w	d1,BLTDMOD(a6)								; Modulo destination
	move.w	#BLT_CLEAR,BLTCON0(a6)				; Sources D et décalage
	move.w	#BLT_DESCENDING,BLTCON1(a6)		; Blitter control 1
	move.w	d2,BLTSIZE(a6)								; Taille fenêtre à traiter = lance le blitter

.ClearPlane3:
	add.l		d3,d0
	WAITBLT
	move.l	d0,BLTDPT(a6)									; Adresse destination D
	move.w	d1,BLTDMOD(a6)								; Modulo destination
	move.w	#BLT_CLEAR,BLTCON0(a6)				; Sources D et décalage
	move.w	#BLT_DESCENDING,BLTCON1(a6)		; Blitter control 1
	move.w	d2,BLTSIZE(a6)								; Taille fenêtre à traiter = lance le blitter

.NoClear:
	rts

;*******************************************************************************

SwitchGlenzPlayfield:
	movem.l	GlenzPlayfieldDraw,d0-d5
	exg			d0,d3														; Swap les buffer écran
	exg			d1,d4														; Swap les données blitter
	exg			d2,d5
	movem.l	d0-d5,GlenzPlayfieldDraw				; Echange les données physique et logique
	rts

;*******************************************************************************

AnimateGlenz:
	bsr			PlayGlenzAnimation
	bsr			MoveGlenzObject
	bsr			CalculMatrice
	bsr			CalculPoints
	bsr			CalculBlitterArea
	bsr			DrawGlenzObject
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
ADR_PALETTE					= 34								; Offset palette de l'objet
ADR_BOUNDING_AREA		= 38								; Offset bounding area de l'objet
M00									= 0									; Offsets matrice
M01									= 2
M02									= 4
M10									= 6
M11									= 8
M12									= 10
M20									= 12
M21									= 14
M22									= 16
Z_OBSERVER					= 4400							; Distance de l'observateur

;*******************************************************************************
; Joue les animation des objets
;	OUT	:	a0.l = adresse de l'objet à afficher
;*******************************************************************************
PlayGlenzAnimation:
	movea.l	GlenzAnimationPtr,a1					; Pointeur sur l'animation en cours
	tst.l		GlenzCurrentObject						; Un objet est en cours d'affichage
	bne.s		.NoNewObject									; Oui
	move.l	(a1)+,GlenzCurrentObject			; Nouvel objet
.NoNewObject:
	tst.w		GlenzAnimCount								; Animation en cours ?
	bne.s		.NoNewAnimation								; Oui, on ne fait rien
	move.l	(a1)+,d0
	bne.s		.NoNewSequence								; Nouvelle séquence à jouer
	tst.l		(a1)													; Fin de la liste ?
	bne.s		.NoEndAnimation								; Non, pas encore
	lea			GlenzObjectAnimation,a1				; Retour au début de la liste
.NoEndAnimation:
	move.l	(a1)+,GlenzCurrentObject			; Nouvel objet à afficher
	move.l	(a1)+,d0											; Zoom et frames à jouer
.NoNewSequence:
	move.l	d0,GlenzZoomSpeed							; Sauve la nouvelle vitesse du zoom et le nombre de frames
.NoNewAnimation:
	subi.w	#1,GlenzAnimCount							; Décrémente le compteur d'animation
	move.l	a1,GlenzAnimationPtr					; Sauve le pointeur d'animation
	move.l	GlenzCurrentObject,a0					; L'objet en cours

.LoadObjectPalette
	movea.l	ADR_PALETTE(a0),a1						; Palette de l'objet
	lea			CLGlenzPalette,a2							; Copper list
	move.w	(a1)+,2(a2)
	move.w	(a1)+,6(a2)
	move.w	(a1)+,10(a2)
	move.w	(a1),14(a2)

	rts

;*******************************************************************************
; Fait bouger l'objet
; IN	:	a0.l = paramètres de l'objet 3D
;*******************************************************************************
MoveGlenzObject:

	move.w	X_ANGLE(a0),d0								; Angle x de l'objet en degrés
	addq.w	#1,d0													; On fait tourner
	cmp.w		#360,d0												; Si on atteint 360 degrés
	bne.s		.NoXLimit
	clr.w		d0														; On revient à zéro
.NoXLimit:
	move.w	d0,X_ANGLE(a0)								; Et on sauve
	move.w	Y_ANGLE(a0),d0								; Idem angle y
	addq.w	#2,d0
	cmp.w		#360,d0
	bne.s		.NoYLimit
	clr.w		d0
.NoYLimit:
	move.w	d0,Y_ANGLE(a0)
	move.w	Z_ANGLE(a0),d0								; Idem angle z
	addq.w	#3,d0
	cmp.w		#360,d0
	bne.s		.NoZLimit
	clr.w		d0
.NoZLimit:
	move.w	d0,Z_ANGLE(a0)

	move.w	Z_OBJ(a0),d2									; Coordonnée Z de l'objet
	add.w		GlenzZoomSpeed,d2
	move.w	d2,Z_OBJ(a0)									; Et on sauve

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
	lea			GlenzRotationMatrix,a1				; Matrice de rotation
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
	lea			GlenzRotationMatrix,a1				; Matrice de rotation
	movea.l	ADR_TAB_POINT(a0),a2					; Sommets de l'objet
	movea.l	ADR_BUF_COORD(a0),a3					; Buffer pour stocker les coordonnées
	lea			ADR_BOUNDING_AREA(a0),a4			; Bounding area de l'objet

	move.w	#GLENZPF_WIDTH-1,(a4)					; Reset les coordonnées
	move.w	#GLENZPF_HEIGHT-1,2(a4)
	move.l	#0,4(a4)

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
	addi.w	#GLENZPF_WIDTH/2,d5
	move.w	d5,(a3)+											; Coordonnée écran X
	add.w		Y_OBJ(a0),d6
	ext.l		d6
	asl.l		#8,d6
	divs.w	d0,d6
	neg.w		d6
	addi.w	#GLENZPF_HEIGHT/2,d6
	move.w	d6,(a3)+											; Coordonnée écran Y
.CheckBoundingBox:
	move.l	(a4),d0												; XMin / YMin actuels
	cmp.w		d6,d0
	blo.s		.NotYMin
	move.w	d6,d0
.NotYMin:
	swap		d0
	cmp.w		d5,d0
	blo.s		.NotXMin
	move.w	d5,d0
.NotXMin:
	swap		d0
	move.l	d0,(a4)												; Sauve les nouveaux XMin / YMin
	move.l	4(a4),d1											; XMax / YMax actuels
	cmp.w		d6,d1
	bgt.s		.NotYMax
	move.w	d6,d1
.NotYMax:
	swap		d1
	cmp.w		d5,d1
	bgt.s		.NotXMax
	move.w	d5,d1
.NotXMax:
	swap		d1
	move.l	d1,4(a4)											; Sauve les nouveaux XMax / YMax	
.NextPerspective:
	dbra		d7,.CalculNextPoint
	rts

;*******************************************************************************
; Calcul la fenêtre d'utilisation du blitter
; IN	:	a0.l = paramètres de l'objet 3D
;*******************************************************************************

CalculBlitterArea:
	lea			ADR_BOUNDING_AREA(a0),a1			; Bounding area de l'objet

; Calcul adresse de départ
; = (YMax * GLENZPF_LINE) + ((XMax & $fff0) / 8)
	move.w	6(a1),d0											; d0 = YMax
	mulu.w	#GLENZPF_LINE,d0							; d0 = YMax * GLENZPF_LINE , offset ligne de fin
	move.w	4(a1),d1											; d1 = XMax
	andi.l	#$fff0,d1											; d1 = XMax & $fff0 , multiple de 16
	move.w	d1,d2													; d2 = XMax & $fff0
	lsr.w		#3,d1													; d1 = (XMax & $fff0) / 8
	add.l		d1,d0													; d0 = (YMax * GLENZPF_LINE) + ((XMax & $fff0) / 8) , offset de départ
	add.l		GlenzPlayfieldWork,d0					; Adresse de départ

; Calcul modulo
; = GLENZPF_LINE - 4 - (((XMax & $fff0) - (XMin & $fff0))) / 8)
	move.w	#GLENZPF_LINE-4,d1						; d1 = GLENZPF_LINE - 4
	move.w	(a1),d3												; d3 = XMin
	andi.w	#$fff0,d3											; d3 = XMin & $fff0 , multiple de 16
	sub.w		d3,d2													; d2 = (XMax & $fff0) - (XMin & $fff0)
	move.w	d2,d3													; d3 = (XMax & $fff0) - (XMin & $fff0)
	lsr.w		#3,d2													; d2 = ((XMax & $fff0) - (XMin & $fff0)) / 8
	sub.w		d2,d1													; d1 = GLENZPF_LINE - 4 - (((XMax & $fff0) - (XMin & $fff0)) / 8)

; Calcul BLTSIZE
; = ((YMax - YMin) * 64) + (((XMax & $fff0) - (XMin & $fff0)) / 16) + 2
	move.w	6(a1),d2											; d2 = YMax
	sub.w		2(a1),d2											; d2 = YMax - Ymin
	lsl.w		#6,d2													; d2 = (YMax - YMin) * 64
	lsr.w		#4,d3													; d3 = ((XMax & $fff0) - (XMin & $fff0)) / 16
	add.w		d3,d2													; d2 = ((YMax - YMin) * 64) + (((XMax & $fff0) - (XMin & $fff0)) / 16)
	addq.w	#2,d2													; d2 = ((YMax - YMin) * 64) + (((XMax & $fff0) - (XMin & $fff0)) / 16) + 2 , 2 mots en plus

	lea			GlenzBlitAreaWork,a1					; Buffer de sauvegarde des infos
	move.l	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)

	rts

;*******************************************************************************

DrawGlenzObject:

	lea			CUSTOM,a6

	WAITBLT																; On attend le blitter

	move.w	#-1,BLTAFWM(a6)								; masque gauche = $ffff
	move.w	#-1,BLTBDAT(a6)								; pattern ligne = $ffff
	move.w	#$8000,BLTADAT(a6)						; valeur arbitraire du point
	move.w	#GLENZPF_LINE,BLTCMOD(a6)			; largeur bitplan
	move.w	#GLENZPF_LINE,BLTDMOD(a6)			; largeur bitplan

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

	movea.l	GlenzPlayfieldWork,a2					; Adresse plan 1

	btst		#0,d6													; Plan 1 ?
	beq.s		.NotColor1										; Non
	bra.s		.DrawLines										; Dessine les lignes

.NotColor1:
	btst		#1,d6													; Plan 2 ?
	beq.s		.NotColor2										; Non
	lea			GLENZPF_PLANE(a2),a2						; Adresse plan 2
	btst		#2,d6													; Plan 3 ?
	beq.s		.DrawLines										; Non
	lea			GLENZPF_PLANE(a2),a2						; Adresse plan 3

.DrawLines:
	bsr.s		DrawLine											; Ligne X1,Y1 -> X2,Y2

	exg			d0,d4													; d0 = X3, d4 = X1
	exg			d1,d5													; d1 = Y3, d5 = Y1
	bsr			DrawLine											; Ligne X3,Y3 -> X1,Y1

	move.w	d4,d2													; d2 = X1
	move.w	d5,d3													; d3 = Y1
	bsr.s		DrawLine											; Ligne X3,Y3 -> X1,Y1

.NotColor2:
	dbra		d7,.NextFace

.FillFace:
	lea			GlenzBlitAreaWork,a1					; Données calculées
	move.l	(a1)+,d0											; Fin du bitplan
	move.w	(a1)+,d1											; Modulo
	move.w	(a1),d2												; Taille de la fenêtre blitter
	move.l	#GLENZPF_PLANE,d3							; Taille d'un plan
	bsr			FillFace

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
	mulu.w	#GLENZPF_LINE,d1
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
	ELSEIF
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
	move.w	d3,BLTSIZE(a6)								; ((GrandDelta+1) * 64) + 2

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
; Rempli une surface au blitter
; IN	:	d0.l = adresse bitplan
;				d1.w = modulo
;				d2.w = taille de la fenêtre
;				d3.l = taille du bitplan
;*******************************************************************************

FillFace:
	lea			CUSTOM,a6

.FillPlane1:
	WAITBLT
	move.l	d0,BLTAPT(a6)
	move.l	d0,BLTDPT(a6)
	move.w	d1,BLTAMOD(a6)
	move.w	d1,BLTDMOD(a6)
	move.w	#BLT_FILL,BLTCON0(a6)
	move.w	#BLT_FILLEXCLU,BLTCON1(a6)
	move.w	d2,BLTSIZE(a6)

.FillPlane2:
	add.l		d3,d0
	WAITBLT
	move.l	d0,BLTAPT(a6)
	move.l	d0,BLTDPT(a6)
	move.w	d1,BLTAMOD(a6)
	move.w	d1,BLTDMOD(a6)
	move.w	#BLT_FILL,BLTCON0(a6)
	move.w	#BLT_FILLEXCLU,BLTCON1(a6)
	move.w	d2,BLTSIZE(a6)

.FillPLane3:
	add.l		d3,d0
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

	bsr			AnimateStarfield
	bsr			AnimateLogo
	bsr			TextScrolling
	bsr			AnimateGround
	bsr			AnimateSprite

	move.w	#$FFFF,FlagVBL								; Indique la fin de la VBL
	move.w	#$20,CUSTOM+INTREQ						; Libère l'interruption

	movem.l	(sp)+,d0-a6
	rte

;*******************************************************************************
	SECTION	GENERAL,DATA
;*******************************************************************************

FlagVBL:
	dc.w		0

GlenzPlayfieldDraw:
	dc.l		0															; Adresse du playfield affiché
GlenzBlitAreaDraw:
	dc.w		0,0,0,0												; Zone de travail du blitter
GlenzPlayfieldWork:
	dc.l		0															; Adresse du playfield de travail
GlenzBlitAreaWork:
	dc.w		0,0,0,0

GlenzAnimationPtr:
	dc.l		GlenzObjectAnimation					; Pointeur sur la liste des animations

GlenzCurrentObject:
	dc.l		0															; Objet affiché
GlenzZoomSpeed:
	dc.w		0															; Vitesse du zoom
GlenzAnimCount:
	dc.w		0															; Compteur pour animation du glenz

GlenzObject:
	INCLUDE	'objects.s'

; La matrice de rotation finale
GlenzRotationMatrix:
	dcb.w		9,0

ScrollTextColors:
	dc.w		$001,$002,$003,$004,$005,$006,$007,$008
	dc.w		$008,$009,$00a,$00b,$00c,$00d,$00e,$00f
	dc.w		$10f,$20f,$30f,$40f,$50f,$60f,$70f,$80f
	dc.w		$80f,$90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f
	dc.w		$f0f,$f0e,$f0d,$f0c,$f0b,$f0a,$f09,$f08
	dc.w		$f07,$f06,$f05,$f04,$f03,$f02,$f01,$f00
	dc.w		$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80
	dc.w		$f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
	dc.w		$ff0,$ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0
	dc.w		$7f0,$6f0,$5f0,$4f0,$3f0,$2f0,$1f0,$0f0

ScrollTextPtr:
	dc.l		ScrollTextBuffer

LetterChange:
	dc.w		0															; Compteur pour nouvelle lettre

ScrollPosition:
	dc.w		SCROLL_STARTX									; Position X du scrolltext
	dc.w		1															; Position Y du scrolltext

ScrollBufferLetter:
	dc.l		0,0														; Adresse des buffers pour les lettres (courant, initial)

GroundScrollingTable:
groundspeed	SET	1
	REPT		GROUND_NBLEVEL
	dc.w		groundspeed,0									; Vitesse et position du scrolling
	dc.l		0															; Adresse du playfield
groundspeed	SET groundspeed+1
	ENDR

ScrollingTable:
	dc.w		-2,$0000,0,$00ff,0,$00ee,0,$00dd,0,$00cc,0,$00bb,0,$00aa,0,$0099
	dc.w		0,$0088,0,$0077,0,$0066,0,$0055,0,$0044,0,$0033,0,$0022,0,$0011

ScrollTextMessage:
	dc.b		"YI-HAA !!!! -=:: RED SECTOR INC. ::=- CELEBRATING ITS 30TH YEAR IN "
	dc.b		"THE SCENE IS BACK WITH YET ANOTHER AMIGA PRODUCTION CALLED 'CRESTA' "
	dc.b		"RUNNING ON STOCK A500 AND RELEASED AT 7DX DEMO PARTY 2015 AKA "
	dc.b		"'THE LAST PARTY' IN ISTANBUL/TURKEY... MERHABA TURKIYE ;) PLEASE "
	dc.b		"ENJOY THIS LITTLE NOSTALGIC GLENZ DENTRO CODED BY OUR NEWEST MEMBER "
	dc.b		"LEXO USING FRA'S GRAPHICS WITH HELP OF PTOING ON DEN'S CHIPMUSIC. "
	dc.b		"FUCKING TO LAMERS, GREETINGS TO ELITES : ALPHA FLIGHT, BLABLA, "
	dc.b		"BONBON, CODEX, DEFENCE-FORCE, DESIRE, FREEZERS, LIVE!, MANDARINE, "
	dc.b		"QUARTEX, RAZOR 1911, REBELS, RIOT, TITANS AND TRBL. AND REMEMBER... "
	dc.b		"RED SECTOR NR 1.                   ",0

ScrollTextTranslate:
	dc.b		" BCDEFGH",1
	dc.b		"IJKLMNOP",1
	dc.b		"QRSTUVWX",1
	dc.b		"YZ012345",1
	dc.b    "6789A;=:",1
	dc.b		"!?'(),-.",0

	EVEN

; Table des sprites du sol
GroundSpriteData:
	dc.l		Sprite0												; Adresse du sprite
	dc.w		15,82,49+GROUND_STARTY,30			; Scroll zone, X, Y, hauteur
	dc.l		Sprite1
	dc.w		14,220,52+GROUND_STARTY,22
	dc.l		Sprite2
	dc.w		11,262,46+GROUND_STARTY,14
	dc.l		Sprite3
	dc.w		10,26,29+GROUND_STARTY,26
	dc.l		Sprite4
	dc.w		7,140,30+GROUND_STARTY,10
	dc.l		Sprite5
	dc.w		3,180,12+GROUND_STARTY,8
	dc.l		DefaultSprite
	dc.w		0,0,0
	dc.l		DefaultSprite
	dc.w		0,0,0

ScrollSwingPtr:
	dc.l		ScrollSwingTable

ScrollSwingTable:
	INCLUDE	'scrollwave.s'

LogoSwingPtr:
	dc.l		LogoSwingTable

LogoSwingTable:
	INCLUDE	'sinwave.s'

LogoPicture:
	INCBIN	'logo.data'

FontePicture:
	INCBIN	'font.data'

;*******************************************************************************
	SECTION BUFFER,BSS
;*******************************************************************************

StarData:
	ds.l		STAR_NUMBER										; Données des étoiles W:Position, W:Vitesse

StarPosition:
	ds.l		SCREEN_WIDTH									; Table de position des étoiles (W: SPRxPOS, W: SPRxCTL)

ScrollTextTable:
	ds.l		SCROLL_STOPX									; Table pour scrolling playfield texte (W: offset adresse, W: décalage)

ScrollTextBuffer:
	ds.l		SCROLL_MAXMES									; Buffer pour le message du scrolltext

GroundPlayfieldTable:
	ds.l		GROUND_WIDTH									; Table pour scrolling playfield sol (W: offset adresse, W: décalage)

;*******************************************************************************
	SECTION SCREEN,BSS_C
;*******************************************************************************

LogoPlayfield:
	ds.b		LOGOPF_SIZE

ScrollTextPlayfield:
	ds.b		SCROLLPF_SIZE

GlenzPlayfield:
	ds.b		GLENZPF_SIZE*2

;*******************************************************************************
	SECTION GROUND,DATA_C
;*******************************************************************************

GroundPlayfield:
	INCBIN	'ground.data'

;*******************************************************************************
	SECTION SPRITE,DATA_C
;*******************************************************************************

DefaultSprite:
	dc.l		0,0,0,0

StarSprite:
	dc.w		0,0
	REPT		STAR_HEIGHT
	dc.w		$8000,$8000
	ENDR
	dc.w		0,0

	INCLUDE	'ground_sprite.s'

;*******************************************************************************
	SECTION MUSIC,DATA_C
;*******************************************************************************

Music:
	INCBIN	'wasabi.mod'

;*******************************************************************************
	SECTION COPPER,DATA_C
;*******************************************************************************

CopperList:
	CMOVE		(SCREEN_STARTY<<8)|SCREEN_STARTX+1,DIWSTRT
	CMOVE		$2CC1,DIWSTOP

CLSpriteAdr:														; Sprites pour éléments du sol
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
CLStarSpriteAdr:												; Sprite pour le starfield
	CMOVE		$0000,SPR6PTH
	CMOVE		$0000,SPR6PTL
	CMOVE		$0000,SPR7PTH									; Sprite non disponible à cause du scrolling
	CMOVE		$0000,SPR7PTL

CLScreenDef:
	CWAIT		$0000,SCREEN_STARTY-2					; 2 lignes avant le début de l'écran
	CMOVE		$0030,DDFSTRT									; Fetch start
	CMOVE		$00D0,DDFSTOP									; Fetch stop
	CMOVE		$5200,BPLCON0									; Ecran 32 couleurs lowres
	CMOVE		$0000,BPLCON1									; Pas de décalage pour ce playfield
	CMOVE		$0043,BPLCON2									; Priorité sprites / playfield (sprites 6 & 7 derrière, pf2 devant tout)
	CMOVE		$0C00,BPLCON3									; Pour compatibilité AGA
	CMOVE		$0011,BPLCON4									; Pour compatibilité AGA

CLLogoBitplaneAdr:
	CMOVE		$0000,BPL1PTH									; Les 5 plans du playfield du logo (96 lignes)
	CMOVE		$0000,BPL1PTL
	CMOVE		$0000,BPL2PTH
	CMOVE		$0000,BPL2PTL
	CMOVE		$0000,BPL3PTH
	CMOVE		$0000,BPL3PTL
	CMOVE		$0000,BPL4PTH
	CMOVE		$0000,BPL4PTL
	CMOVE		$0000,BPL5PTH
	CMOVE		$0000,BPL5PTL
	CMOVE		LOGOPF_MOD,BPL1MOD
	CMOVE 	LOGOPF_MOD,BPL2MOD

CLLogoPalette:
	INCBIN	'logo.pal'										; Palette du logo

starpos		SET SCREEN_STARTY							; On démarre en haut de l'écran

	CMOVE		$8000,SPR6DATA								; Préload les données du sprite
	CMOVE		$8000,SPR6DATB

CLStarsLogo:
	REPT		LOGO_POSY											; Les 7 premières lignes du logo
	CWAIT		$0000,starpos									; Attends le début de la ligne
	CMOVE		$0000,SPR6POS									; Force la position du sprite
	CMOVE		$0000,SPR6CTL
	CMOVE		$0000,COLOR31									; Couleur de l'étoile
	CMOVE		$0000,BPLCON1									; Décalage de la ligne
starpos		SET starpos+1									; Ligne suivante
	ENDR

CLLogoScroll:
	REPT		LOGOPF_HEIGHT-LOGO_POSY				; Les 89 lignes suivantes du logo
	CWAIT		$0000,starpos									; Attends le début de la ligne
	CMOVE		$0000,SPR6POS									; Force la position du sprite
	CMOVE		$0000,SPR6CTL
	CMOVE		$0000,COLOR31									; Couleur de l'étoile
	CMOVE		$0000,BPLCON1									; Décalage de la ligne
starpos		SET starpos+1									; Ligne suivante
	ENDR

CLGroundSetup:
	CWAIT		$00C8,starpos-1								; Début du playfield du sol
	CMOVE		$6600,BPLCON0									; Ecran 8 couleurs lowres DPF

CLScrollText:
	CMOVE		$0000,BPLCON1

CLScrollTextBitplaneAdr:
	CMOVE		$0000,BPL1PTH									; Les 3 plans du playfield du scrolltext
	CMOVE		$0000,BPL1PTL
	CMOVE		$0000,BPL3PTH
	CMOVE		$0000,BPL3PTL
	CMOVE		$0000,BPL5PTH
	CMOVE		$0000,BPL5PTL
	CMOVE		SCROLLPF_MOD,BPL1MOD					; Modulo du scrolltext

CLGlenzBitplaneAdr:
	CMOVE		$0000,BPL2PTH									; Les 3 plans du playfield du glenz
	CMOVE		$0000,BPL2PTL
	CMOVE		$0000,BPL4PTH
	CMOVE		$0000,BPL4PTL
	CMOVE		$0000,BPL6PTH
	CMOVE		$0000,BPL6PTL
	CMOVE 	GLENZPF_MOD,BPL2MOD						; Modulo du glenz

CLStarInter:
	CMOVE		$0000,SPR6POS									; Force la position du sprite
	CMOVE		$0000,SPR6CTL
CLStarInterColor:
	CMOVE		$0000,COLOR31									; Couleur de l'étoile
starpos		SET starpos+1

CLFontePalette:													; Palette de la fonte
	CMOVE		$0000,COLOR00
	CMOVE		$0446,COLOR01
	CMOVE		$0658,COLOR02
	CMOVE		$088a,COLOR03
	CMOVE		$0bbc,COLOR04
	CMOVE		$0ede,COLOR05
	CMOVE		$0fff,COLOR06

CLGlenzPalette:													; Palette du glenz
	CMOVE		$0a00,COLOR09
	CMOVE		$0f00,COLOR10
	CMOVE		$0fcc,COLOR13
	CMOVE		$0fff,COLOR14
	CMOVE		$0000,COLOR08
	CMOVE		$0000,COLOR11
	CMOVE		$0000,COLOR12
	CMOVE		$0000,COLOR15

CLGroundSpritePalette:
	CMOVE		$0000,COLOR16
	CMOVE		$0777,COLOR17
	CMOVE		$0ccc,COLOR18
	CMOVE		$0fff,COLOR19
	CMOVE		$0000,COLOR20
	CMOVE		$0777,COLOR21
	CMOVE		$0ccc,COLOR22
	CMOVE		$0fff,COLOR23
	CMOVE		$0000,COLOR24
	CMOVE		$0777,COLOR25
	CMOVE		$0ccc,COLOR26
	CMOVE		$0fff,COLOR27

CLStarsGround:
	REPT		SCROLL_HEIGHT-1								; Les 79 lignes avant le sol
	CWAIT		$0000,starpos
	CMOVE		$0000,SPR6POS
	CMOVE		$0000,SPR6CTL
	CMOVE		$0000,COLOR31									; Couleur de l'étoile
	CMOVE		$0000,COLOR07									; Couleur de la fonte
starpos		SET starpos+1
	ENDR

CLGroundLevel:
	CWAIT		$00C0,starpos-1
	CMOVE		GROUNDPF_MOD,BPL1MOD					; Modulo du sol

CLGroundPalette:												; Palette du sol
	CMOVE		$0000,COLOR00
	CMOVE		$0344,COLOR01
	CMOVE		$0565,COLOR02
	CMOVE		$0787,COLOR03
	CMOVE		$09a8,COLOR04
	CMOVE		$0ac9,COLOR05
	CMOVE		$0bec,COLOR06
	CMOVE		$0dfd,COLOR07

CLGroundLevelAdr:
	REPT		GROUND_NBLEVEL
	CWAIT		$0000,starpos
	CMOVE		$0000,BPLCON1									; Décalage du playfield
	CMOVE		$0000,BPL1PTH									; Les 3 plans du playfield du sol
	CMOVE		$0000,BPL1PTL
	CMOVE		$0000,BPL3PTH
	CMOVE		$0000,BPL3PTL
	CMOVE		$0000,BPL5PTH
	CMOVE		$0000,BPL5PTL
	CWAIT		$00E0,starpos									; Attends la fin de la ligne pour la coupure sur la ligne 255
starpos		SET starpos+GROUND_LEVELHT
	ENDR

CLEnd:
	CEND

;*******************************************************************************
; Fonctions utiles
;*******************************************************************************

	INCLUDE "Includes/System.s"
	INCLUDE "Includes/Math.s"
	INCLUDE "Includes/ModPlayer.s"

	END
