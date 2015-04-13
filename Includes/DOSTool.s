;*******************************************************************************
;	DOSTool.s
;	Fonctions de gestion des fichiers
; V1.1 Mars 2015
;*******************************************************************************

;*******************************************************************************
	SECTION DOSTOOL,CODE
;*******************************************************************************

;*******************************************************************************
; Charge un fichier dans un buffer
; IN	:	a1.l = nom du fichier à charger
; 			a2.l = adresse du buffer
; OUT	:	d0.l = taille du fichier chargé ou 0 si erreur
;*******************************************************************************
LoadFile:
	movem.l d1-a6,-(sp)
	move.w	#INT_ON+INT_PORTS,CUSTOM+INTENA	; IT pour les IO
	move.w	#DMA_ON+DMA_DISK,CUSTOM+DMACON
.OpenFile:
	move.l  a1,d1                         ; Fichier a ouvrir
	move.l  #MODE_OLDFILE,d2              ; Ouverture en lecture seule
	move.l  DOSBase,a6
	jsr     _Open(a6)
	tst.l   d0                            ; Ouverture OK
	beq     .OpenError                    ; Non
	move.l  d0,d7                         ; Sauve le file handler
.GetFileSize:
	move.l  d7,d1
	move.l  #0,d2
	move.l  #OFFSET_END,d3
	jsr     _Seek(a6)                     ; On se positionne a la fin du fichier
	move.l  d7,d1
	move.l  #0,d2
	move.l  #OFFSET_BEGINNING,d3
	jsr     _Seek(a6)                     ; On se positionne au début du fichier
	tst.l   d0                            ; Taille > à 0
	beq     .CloseFile
	move.l  d0,d6                         ; Sauve la taille du fichier
.ReadFile:
	move.l  d7,d1                         ; File handler
	move.l  a2,d2                         ; Buffer
	move.l  d6,d3                         ; Nombre d'octets à lire
	jsr     _Read(a6)                     ; Lit le fichier
	move.l  d0,d6
	tst.l   d0
	bgt.s   .CloseFile                    ; Pas d'erreur de lecture
	moveq.l #0,d6
.CloseFile:
	move.l  d7,d1
	jsr     _Close(a6)
	move.l  d6,d0
.OpenError:
	movem.l (sp)+,d1-a6
	rts
