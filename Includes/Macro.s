;*******************************************************************************
;	Macro.s
;	Macros pratiques
; V1.5 Octobre 2014
;*******************************************************************************

;*******************************************************************************
; Macros pour la Copperlist
;*******************************************************************************

; Transfert une donnée dans un registre (CMOVE value,register)
CMOVE	MACRO
	dc.w	(\2)&$0ffe,\1
	ENDM

; Attends une position du faisceau (CWAIT x,y)
CWAIT	MACRO
	dc.w	((\2)&$ff)<<8!((\1)&$fe)!1,$fffe
	ENDM

; Passe l'instruction suivante (CSKIP x,y)
CSKIP	MACRO
	dc.w	((\2)&$ff)<<8!((\1)&$fe)!1,$ffff
	ENDM

; Ne fait rien NO-OP
CNOOP MACRO
	dc.l	$01fe0000
	ENDM

; Fin de copperlist (CEND)
CEND MACRO
	dc.l	$fffffffe
	dc.l	$fffffffe
	ENDM

;*******************************************************************************
; Autres macros
;*******************************************************************************

; Attends une ligne raster (RWAIT x,y)
RWAIT MACRO
.RasterWait\@:
	cmpi.w	#((\2)&$ff)<<8!((\1)&$ff),CUSTOM+VHPOSR
	blo.s		.RasterWait\@
	ENDM

; Alloue un buffer mémoire (ALLOCMEM size,memtype,adrsave,error)
ALLOCMEM MACRO
	move.l	$4.w,a6
	move.l	#\1,d0
	move.l	#\2,d1
	jsr			_AllocMem(a6)
	move.l	d0,\3
	beq			\4
	ENDM

; Libère un buffer mémoire (FREEMEM size,adrsave)
FREEMEM MACRO
	move.l	$4.w,a6
	move.l	#\1,d0
	move.l	\2,a1
	jsr			_FreeMem(a6)
	ENDM

; Attend la fin d'activité du blitter
; a6 = custom base
WAITBLT	MACRO
	tst.b		2(a6)
.BlitWait\@:
	btst		#6,2(a6)
	bne.s		.BlitWait\@
	ENDM

; Traite un nombre à virgule fixe de 14 bits
FIXEDVAL	MACRO
	addx.l	\1,\1
	add.l		\1,\1
	swap		\1
	ENDM
