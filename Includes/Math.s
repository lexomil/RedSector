;*******************************************************************************
;	Math.s
;	Fonctions mathématiques
; Sinus, cosinus, random, etc...
; V1.0 Janvier 2015
;*******************************************************************************

;*******************************************************************************
	SECTION MATH,CODE
;*******************************************************************************

;*******************************************************************************
;	Retourne un nombre aléatoire compris entre 0 et X
;	IN	: d0.w = borne supérieure
;	OUT	: d0.w = valeur aléatoire
;*******************************************************************************
RandXorShift:
	movem.l	d1-d7,-(sp)

	move.l	RandomSeed,d1									; randomseed

	move.l	RandomX,d2										; x
	move.l	RandomY,d3										; y
	move.l	RandomZ,d4										; z

	move.l	d2,d7													; t = x
	moveq.l	#11,d5
	lsl.l		d5,d7													; t = x << 11
	eor.l		d2,d7													; t = x ^ (x << 11)
	andi.l	#$7fffffff,d7									; t = (x ^ (x << 11)) & 0x7fffffff
	
	exg			d2,d3													; x = y
	exg			d3,d4													; y = z
	move.l	d1,d4													; z = randomseed
	
	move.l	d7,d6
	moveq.l	#8,d5
	lsr.l		d5,d6													; t >> 8
	eor.l		d6,d7													; t ^ (t >> 8)
	
	move.l	d1,d6													; randomseed
	moveq.l	#19,d5
	lsr.l		d5,d6													; randomseed = randomseed >> 19
	eor.l		d6,d1													; randomseed = randomseed ^ (randomseed >> 19)
	
	eor.l		d7,d1													; randomseed = randomseed ^ (randomseed >> 19) ^ (t ^ (t >> 8))

	move.l	d1,RandomSeed									; Sauve pour le prochain appel
	move.l	d2,RandomX
	move.l	d3,RandomY
	move.l	d4,RandomZ

	swap		d1
	rol.l		#1,d1													; randomseed >> 15
	mulu.w	d1,d0
	swap		d0														; Résultat

	movem.l	(sp)+,d1-d7	
	rts
	
;*******************************************************************************
	SECTION	MATHDATA,DATA
;*******************************************************************************

RandomSeed:
	dc.l		987654321
RandomX:
	dc.l		123456789
RandomY:
	dc.l		362436069
RandomZ:
	dc.l		521288629

; Table des sinus/cosinus fixed point 14 bits
SinCosTable:														; W: Sinus, W: Cosinus
	dc.w		$0000,$4000,$011d,$3ffd,$023b,$3ff6,$0359,$3fe9,$0476,$3fd8
	dc.w		$0593,$3fc1,$06b0,$3fa6,$07cc,$3f85,$08e8,$3f60,$0a03,$3f36
	dc.w		$0b1d,$3f07,$0c36,$3ed2,$0d4e,$3e99,$0e65,$3e5c,$0f7b,$3e19
	dc.w		$1090,$3dd1,$11a4,$3d85,$12b6,$3d34,$13c6,$3cde,$14d6,$3c83
	dc.w		$15e3,$3c23,$16ef,$3bbf,$17f9,$3b56,$1901,$3ae9,$1a07,$3a77
	dc.w		$1b0c,$3a00,$1c0e,$3985,$1d0e,$3906,$1e0b,$3882,$1f07,$37f9
	dc.w		$1fff,$376c,$20f6,$36db,$21ea,$3646,$22db,$35ac,$23c9,$350e
	dc.w		$24b5,$346c,$259e,$33c6,$2684,$331c,$2766,$326e,$2846,$31bc
	dc.w		$2923,$3106,$29fc,$304d,$2ad3,$2f8f,$2ba5,$2ece,$2c75,$2e09
	dc.w		$2d41,$2d41,$2e09,$2c75,$2ece,$2ba5,$2f8f,$2ad3,$304d,$29fc
	dc.w		$3106,$2923,$31bc,$2846,$326e,$2766,$331c,$2684,$33c6,$259e
	dc.w		$346c,$24b5,$350e,$23c9,$35ac,$22db,$3646,$21ea,$36db,$20f6
	dc.w		$376c,$2000,$37f9,$1f07,$3882,$1e0b,$3906,$1d0e,$3985,$1c0e
	dc.w		$3a00,$1b0c,$3a77,$1a07,$3ae9,$1901,$3b56,$17f9,$3bbf,$16ef
	dc.w		$3c23,$15e3,$3c83,$14d6,$3cde,$13c6,$3d34,$12b6,$3d85,$11a4
	dc.w		$3dd1,$1090,$3e19,$0f7b,$3e5c,$0e65,$3e99,$0d4e,$3ed2,$0c36
	dc.w		$3f07,$0b1d,$3f36,$0a03,$3f60,$08e8,$3f85,$07cc,$3fa6,$06b0
	dc.w		$3fc1,$0593,$3fd8,$0476,$3fe9,$0359,$3ff6,$023b,$3ffd,$011d
	dc.w		$4000,$0000,$3ffd,$fee3,$3ff6,$fdc5,$3fe9,$fca7,$3fd8,$fb8a
	dc.w		$3fc1,$fa6d,$3fa6,$f950,$3f85,$f834,$3f60,$f718,$3f36,$f5fd
	dc.w		$3f07,$f4e3,$3ed2,$f3ca,$3e99,$f2b2,$3e5c,$f19b,$3e19,$f085
	dc.w		$3dd1,$ef70,$3d85,$ee5c,$3d34,$ed4a,$3cde,$ec3a,$3c83,$eb2a
	dc.w		$3c23,$ea1d,$3bbf,$e911,$3b56,$e807,$3ae9,$e6ff,$3a77,$e5f9
	dc.w		$3a00,$e4f4,$3985,$e3f2,$3906,$e2f2,$3882,$e1f5,$37f9,$e0f9
	dc.w		$376c,$e001,$36db,$df0a,$3646,$de16,$35ac,$dd25,$350e,$dc37
	dc.w		$346c,$db4b,$33c6,$da62,$331c,$d97c,$326e,$d89a,$31bc,$d7ba
	dc.w		$3106,$d6dd,$304d,$d604,$2f8f,$d52d,$2ece,$d45b,$2e09,$d38b
	dc.w		$2d41,$d2bf,$2c75,$d1f7,$2ba5,$d132,$2ad3,$d071,$29fc,$cfb3
	dc.w		$2923,$cefa,$2846,$ce44,$2767,$cd92,$2684,$cce4,$259e,$cc3a
	dc.w		$24b5,$cb94,$23c9,$caf2,$22db,$ca54,$21ea,$c9ba,$20f6,$c925
	dc.w		$2000,$c894,$1f07,$c807,$1e0b,$c77e,$1d0e,$c6fa,$1c0e,$c67b
	dc.w		$1b0c,$c600,$1a07,$c589,$1901,$c517,$17f9,$c4aa,$16ef,$c441
	dc.w		$15e3,$c3dd,$14d6,$c37d,$13c6,$c322,$12b6,$c2cc,$11a4,$c27b
	dc.w		$1090,$c22f,$0f7b,$c1e7,$0e65,$c1a4,$0d4e,$c167,$0c36,$c12e
	dc.w		$0b1d,$c0f9,$0a03,$c0ca,$08e8,$c0a0,$07cc,$c07b,$06b0,$c05a
	dc.w		$0593,$c03f,$0476,$c028,$0359,$c017,$023b,$c00a,$011d,$c003
	dc.w		$0000,$c000,$fee3,$c003,$fdc5,$c00a,$fca7,$c017,$fb8a,$c028
	dc.w		$fa6d,$c03f,$f950,$c05a,$f834,$c07b,$f718,$c0a0,$f5fd,$c0ca
	dc.w		$f4e3,$c0f9,$f3ca,$c12e,$f2b2,$c167,$f19b,$c1a4,$f085,$c1e7
	dc.w		$ef70,$c22f,$ee5c,$c27b,$ed4a,$c2cc,$ec3a,$c322,$eb2a,$c37d
	dc.w		$ea1d,$c3dd,$e911,$c441,$e807,$c4aa,$e6ff,$c517,$e5f9,$c589
	dc.w		$e4f4,$c600,$e3f2,$c67b,$e2f2,$c6fa,$e1f5,$c77e,$e0f9,$c807
	dc.w		$e001,$c894,$df0a,$c925,$de16,$c9ba,$dd25,$ca54,$dc37,$caf2
	dc.w		$db4b,$cb94,$da62,$cc3a,$d97c,$cce4,$d89a,$cd92,$d7ba,$ce44
	dc.w		$d6dd,$cefa,$d604,$cfb3,$d52d,$d071,$d45b,$d132,$d38b,$d1f7
	dc.w		$d2bf,$d2bf,$d1f7,$d38b,$d132,$d45b,$d071,$d52d,$cfb3,$d604
	dc.w		$cefa,$d6dd,$ce44,$d7ba,$cd92,$d899,$cce4,$d97c,$cc3a,$da62
	dc.w		$cb94,$db4b,$caf2,$dc37,$ca54,$dd25,$c9ba,$de16,$c925,$df0a
	dc.w		$c894,$e000,$c807,$e0f9,$c77e,$e1f5,$c6fa,$e2f2,$c67b,$e3f2
	dc.w		$c600,$e4f4,$c589,$e5f9,$c517,$e6ff,$c4aa,$e807,$c441,$e911
	dc.w		$c3dd,$ea1d,$c37d,$eb2a,$c322,$ec3a,$c2cc,$ed4a,$c27b,$ee5c
	dc.w		$c22f,$ef70,$c1e7,$f085,$c1a4,$f19b,$c167,$f2b2,$c12e,$f3ca
	dc.w		$c0f9,$f4e3,$c0ca,$f5fd,$c0a0,$f718,$c07b,$f834,$c05a,$f950
	dc.w		$c03f,$fa6d,$c028,$fb8a,$c017,$fca7,$c00a,$fdc5,$c003,$fee3
	dc.w		$c000,$0000,$c003,$011d,$c00a,$023b,$c017,$0359,$c028,$0476
	dc.w		$c03f,$0593,$c05a,$06b0,$c07b,$07cc,$c0a0,$08e8,$c0ca,$0a03
	dc.w		$c0f9,$0b1d,$c12e,$0c36,$c167,$0d4e,$c1a4,$0e65,$c1e7,$0f7b
	dc.w		$c22f,$1090,$c27b,$11a4,$c2cc,$12b6,$c322,$13c6,$c37d,$14d6
	dc.w		$c3dd,$15e3,$c441,$16ef,$c4aa,$17f9,$c517,$1901,$c589,$1a07
	dc.w		$c600,$1b0c,$c67b,$1c0e,$c6fa,$1d0e,$c77e,$1e0b,$c807,$1f07
	dc.w		$c894,$1fff,$c925,$20f6,$c9ba,$21ea,$ca54,$22db,$caf2,$23c9
	dc.w		$cb94,$24b5,$cc3a,$259e,$cce4,$2684,$cd92,$2766,$ce44,$2846
	dc.w		$cefa,$2923,$cfb3,$29fc,$d071,$2ad3,$d132,$2ba5,$d1f7,$2c75
	dc.w		$d2bf,$2d41,$d38b,$2e09,$d45b,$2ece,$d52d,$2f8f,$d604,$304d
	dc.w		$d6dd,$3106,$d7ba,$31bc,$d899,$326e,$d97c,$331c,$da62,$33c6
	dc.w		$db4b,$346c,$dc37,$350e,$dd25,$35ac,$de16,$3646,$df0a,$36db
	dc.w		$e000,$376c,$e0f9,$37f9,$e1f5,$3882,$e2f2,$3906,$e3f2,$3985
	dc.w		$e4f4,$3a00,$e5f9,$3a77,$e6ff,$3ae9,$e807,$3b56,$e911,$3bbf
	dc.w		$ea1d,$3c23,$eb2a,$3c83,$ec3a,$3cde,$ed4a,$3d34,$ee5c,$3d85
	dc.w		$ef70,$3dd1,$f085,$3e19,$f19b,$3e5c,$f2b2,$3e99,$f3ca,$3ed2
	dc.w		$f4e3,$3f07,$f5fd,$3f36,$f718,$3f60,$f834,$3f85,$f950,$3fa6
	dc.w		$fa6d,$3fc1,$fb8a,$3fd8,$fca7,$3fe9,$fdc5,$3ff6,$fee3,$3ffd
