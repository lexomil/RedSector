;*******************************************************************************
;	System.s
;	Sauvegarde et restauration du système
; V1.6 Mars 2015
;*******************************************************************************

;*******************************************************************************
	SECTION SYSTEM,CODE
;*******************************************************************************

;*******************************************************************************
; Sauvegarde le système
;*******************************************************************************
SaveSystem:
	movea.l	$4.w,a6												; Exec library

.StopMultiTask:
	jsr			_Forbid(a6)										;	Stopper le multitache

.CheckCPU:
	moveq.l	#0,d0
	btst.b	#0,EXEC_CPU_TYPE(a6)					; Check le type de CPU présent
	beq.s		.SaveVbr											; Si c'est un 68000 ne récupère pas le VBR

.GetVectorBase:
	lea			GetVBR,a5
	jsr			_Supervisor(a6)
.SaveVbr:
	move.l	d0,VbrBase										;	Récupèrer le VBR

.OpenDOSLib:
	lea			DOSLib,a1
	move.l	#33,d0
	jsr			_OpenLibrary(a6)							; Ouvre la dos.library
	tst.l		d0
	beq			.EndInit											; Si on la trouve pas on quitte
	move.l	d0,DOSBase										; On garde le pointeur

.OpenGraphicsLib:
	lea			GraphicsLib,a1
	move.l	#33,d0
	jsr			_OpenLibrary(a6)							;	Ouvrir la graphics.library
	tst.l		d0
	beq			.EndInit											; Si on la trouve pas on quitte
	move.l	d0,GfxBase										; On garde le pointeur

.CheckForPAL:
	cmpi.l	#37,LIB_VERSION(a6)						; OS 2 ou +
	bge.s		.CheckOs20
	cmpi.b	#50,VB_FREQUENCY(a6)					; Fréquence 50Hz
	bne.s		.CheckForAGA
	move.w	#1,FlagPAL										; Oui c'est du PAL
	bra.s		.CheckForAGA

.CheckOs20:
	movea.l	GfxBase,a6										; Graphics base
	btst.b	#GFXB_PAL,GFX_DISPLAYFLAGS(a6)	; PAL bit
	beq.s		.CheckForAGA
	move.w	#1,FlagPAL										; Oui c'est du PAL

.CheckForAGA:
	movea.l	GfxBase,a6										; Graphics base
	btst.b	#GFXB_AA_ALICE,GFX_CHIPREV(a6)	;	Test le chipset
	beq.s		.NotAGA												; Pas AGA
	move.w	#1,FlagAGA
.NotAGA:

.ReserveBlitter:
	jsr			_WaitBlit(a6)									;	Attendre la fin d'activité blitter
;	jsr			_OwnBlitter(a6)								;	Réserver le blitter

.ResetView:
	move.l	GFX_ACTIVEVIEW(a6),SaveView		; Récupèrer l'ancien view
	move.l	GFX_COPPERLIST(a6),SaveCopper ; Récupèrer l'ancienne copper list
	movea.l	#0,a1
	jsr			_LoadView(a6)									;	Charger un view vide
	jsr			_WaitTOF(a6)
	jsr			_WaitTOF(a6)									; Deux fois pour les écrans entrelacés

.SaveInterrupts:
	movea.l	VbrBase,a0										;	Sauvegarder les registres des IT
	move.l	VEC_KBD(a0),SaveKeyboard			; Le clavier
	move.l	VEC_VBL(a0),SaveVbl						; La VBL

.StopInterrupts:
	move.w	CUSTOM+INTENAR,SaveIntena
	ori.w		#$C000,SaveIntena							; Sauve l'état des IT
	move.w	CUSTOM+DMACONR,SaveDmacon
	ori.w		#$8100,SaveDmacon							; Sauve l'état des DMA

.NoError:
	move.l	#-1,d0												; Init OK

.EndInit:
	rts

;*******************************************************************************
; Récupère le VBR
;*******************************************************************************
GetVBR:
;	movec		vbr,d0												; Pour compilation en 68010 et +
	dc.l		$4E7A0801											; Opcode direct
	rte

;*******************************************************************************
; Restaure le système
;*******************************************************************************
RestoreSystem:
	tst.l		DOSBase
	beq			.CloseGraphicsLib							; Si on a pas réussi à ouvrir la dos lib

	tst.l		GfxBase
	beq			.NoRestore										; Si on a pas réussi à ouvrir la gfx lib

	lea			CUSTOM,a6
.StopInterrupts:
	move.w	#INT_STOP,INTENA(a6)					; Stop les interruptions
	move.w	#INT_STOP,INTREQ(a6)					; Stop les requests
	move.w	#DMA_STOP,DMACON(a6)					; Stop le DMA

.RestoreVectors:
	move.l	VbrBase,a0										;	Restaurer les vecteurs
	move.l	SaveKeyboard,VEC_KBD(a0)			; Le clavier
	move.l	SaveVbl,VEC_VBL(a0)						; La VBL

.RestoreCopper:
	move.l	SaveCopper,COP1LC(a6)					;	Restaurer la Copperlist

.RestoreInterrupts:
	move.w	SaveIntena,INTENA(a6)					; Restaure les IT
	move.w	SaveDmacon,DMACON(a6)					; Restaure le DMA

.RestoreView:
	movea.l	GfxBase,a6
	movea.l	SaveView,a1
	jsr			_LoadView(a6)									;	Restaurer la view
	jsr			_WaitTOF(a6)
	jsr			_WaitTOF(a6)									; Toujours deux fois pour les écrans entrelacés

.FreeBlitter:
	jsr			_WaitBlit(a6)
;	jsr			_DisownBlitter(a6)						;	Libérer le blitter

.CloseGraphicsLib:
	movea.l	$4.w,a6
	movea.l	GfxBase,a1
	jsr			_CloseLibrary(a6)							;	Fermer la librairie	GRAPHICS

.CloseDOSLib:
	movea.l	$4.w,a6
	movea.l	DOSBase,a1
	jsr			_CloseLibrary(a6)							;	Fermer la librairie DOS

.NoRestore
	jsr			_Permit(a6)										;	Relancer le multitache
	rts

;*******************************************************************************
	SECTION	SYSTEMSAVE,DATA
;*******************************************************************************

GraphicsLib:
	dc.b		"graphics.library",0

DOSLib:
	dc.b		"dos.library",0

	EVEN

SaveIntena:
	dc.w		0
SaveDmacon:
	dc.w		0
FlagAGA:
	dc.w		0
FlagPAL:
	dc.w		0
VbrBase:
	dc.l		0
GfxBase:
	dc.l		0
DOSBase:
	dc.l		0
SaveKeyboard:
	dc.l		0
SaveVbl:
	dc.l		0
SaveView:
	dc.l		0
SaveCopper:
	dc.l		0
