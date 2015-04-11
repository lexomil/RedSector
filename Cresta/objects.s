; object.s
; Définition des objets 3D

; Liste des objets 3D
GlenzObjectList:
	dc.l		PyraObject
	dc.l		CubeObject
	dc.l		CylindreObject
	dc.l		MultiObject
	dc.l		ToupieObject
	dc.l		NULL

GlenzObjectAnimation:
	dc.l		PyraObject										; L'objet à afficher
	dc.w		GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME	; Vitesse du zoom, nombre de frames à afficher
	dc.w		0,GLENZ_PLAYTIME
	dc.w		-GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,0														; Fin de la séquence
	dc.l		CubeObject
	dc.w		GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,GLENZ_PLAYTIME
	dc.w		-GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,0
	dc.l		CylindreObject
	dc.w		GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,GLENZ_PLAYTIME
	dc.w		-GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,0
	dc.l		MultiObject
	dc.w		GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,GLENZ_PLAYTIME
	dc.w		-GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,0
	dc.l		ToupieObject
	dc.w		GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,GLENZ_PLAYTIME
	dc.w		-GLENZ_ZOOMSPEED,GLENZ_ZOOMTIME
	dc.w		0,0
	dc.l		NULL													; Fin de la liste

;*******************************************************************************
;	DOUBLE PYRAMIDE
;*******************************************************************************

PYRA_NBPOINT				= 6
PYRA_NBFACE					= 8

PyraObject:
	dc.w		0,0,0													; Angles de rotation
	dc.w		0,0,0													; Centre de rotation
	dc.w		0,0,0													; Coordonnées de l'objet
	dc.w		PYRA_NBPOINT									; Nombre de sommets
	dc.l		PyraObjectPoint								; Liste des sommets
	dc.l		PyraObjectScreen							; Coordonnées écran
	dc.w		PYRA_NBFACE										; Nombre de faces
	dc.l		PyraObjectFace								; Liste des faces
	dc.l		PyraObjectPalette							; Palette de l'objet
PyraBoundingArea:
	dc.w		0,0,0,0												; La bounding area de l'objet
PyraObjectPoint:
	dc.w		00,100,00											; X, Y et Z
	dc.w		-50,00,50
	dc.w		50,00,50
	dc.w		50,00,-50
	dc.w		-50,00,-50
	dc.w		00,-100,00
PyraObjectFace:
	dc.w		1,00,01,02										; Couleur, Point 1, Point 2, Point 3 (anti-horaire)
	dc.w		2,00,02,03
	dc.w		1,00,03,04
	dc.w		2,00,04,01
	dc.w		2,05,02,01
	dc.w		1,05,03,02
	dc.w		2,05,04,03
	dc.w		1,05,01,04
PyraObjectPalette:
	dc.w		$0a00,$0f00,$0fcc,$0fff
PyraObjectScreen:
	dcb.w		2*PYRA_NBPOINT,0							; Les coordonnées après rotation et perspective

;*******************************************************************************
;	CUBE
;*******************************************************************************

CUBE_NBPOINT				= 14
CUBE_NBFACE					= 24

CubeObject:
	dc.w		0,0,0													; Angles de rotation
	dc.w		0,0,0													; Centre de rotation
	dc.w		0,0,0													; Coordonnées de l'objet
	dc.w		CUBE_NBPOINT									; Nombre de sommets
	dc.l		CubeObjectPoint								; Liste des sommets
	dc.l		CubeObjectScreen							; Coordonnées écran
	dc.w		CUBE_NBFACE										; Nombre de faces
	dc.l		CubeObjectFace								; Liste des faces
	dc.l		CubeObjectPalette							; Palette de l'objet
CubeBoundingArea:
	dc.w		0,0,0,0												; La bounding area de l'objet
CubeObjectPoint:
	dc.w		-50,-50,-50										; X, Y et Z
	dc.w		-50,-50,50
	dc.w		50,-50,50
	dc.w		50,-50,-50
	dc.w		-50,00,00
	dc.w		00,00,50
	dc.w		50,00,00
	dc.w		-50,50,-50
	dc.w		-50,50,50
	dc.w		50,50,50
	dc.w		50,50,-50
	dc.w		00,50,00
	dc.w		00,00,-50
	dc.w		00,-50,00
CubeObjectFace:
	dc.w		1,00,01,04										; Couleur, Point 1, Point 2, Point 3 (anti-horaire)
	dc.w		2,01,08,04
	dc.w		1,08,07,04
	dc.w		2,07,00,04
	dc.w		2,01,02,05
	dc.w		1,02,09,05
	dc.w		2,09,08,05
	dc.w		1,08,01,05
	dc.w		1,02,03,06
	dc.w		2,03,10,06
	dc.w		1,10,09,06
	dc.w		2,09,02,06
	dc.w		1,08,09,11
	dc.w		2,09,10,11
	dc.w		1,10,07,11
	dc.w		2,07,08,11
	dc.w		2,07,10,12
	dc.w		1,10,03,12
	dc.w		2,03,00,12
	dc.w		1,00,07,12
	dc.w		1,00,03,13
	dc.w		2,03,02,13
	dc.w		1,02,01,13
	dc.w		2,01,00,13
CubeObjectPalette:
	dc.w		$00a0,$00f0,$0cfc,$0fff
CubeObjectScreen:
	dcb.w		2*CUBE_NBPOINT,0							; Les coordonnées après rotation et perspective

;*******************************************************************************
;	MULTI
;*******************************************************************************

MULTI_NBPOINT				= 14
MULTI_NBFACE				= 24

MultiObject:
	dc.w		0,0,0													; Angles de rotation
	dc.w		0,0,0													; Centre de rotation
	dc.w		0,0,0													; Coordonnées de l'objet
	dc.w		MULTI_NBPOINT									; Nombre de sommets
	dc.l		MultiObjectPoint							; Liste des sommets
	dc.l		MultiObjectScreen							; Coordonnées écran
	dc.w		MULTI_NBFACE									; Nombre de faces
	dc.l		MultiObjectFace								; Liste des faces
	dc.l		MultiObjectPalette						; Palette de l'objet
MultiBoundingArea:
	dc.w		0,0,0,0												; La bounding area de l'objet
MultiObjectPoint:
	dc.w		-50,-50,-50										; X, Y et Z
	dc.w		-50,-50,50
	dc.w		50,-50,50
	dc.w		50,-50,-50
	dc.w		-80,00,00
	dc.w		00,00,80
	dc.w		80,00,00
	dc.w		-50,50,-50
	dc.w		-50,50,50
	dc.w		50,50,50
	dc.w		50,50,-50
	dc.w		00,80,00
	dc.w		00,00,-80
	dc.w		00,-80,00
MultiObjectFace:
	dc.w		1,00,01,04										; Couleur, Point 1, Point 2, Point 3 (anti-horaire)
	dc.w		2,01,08,04
	dc.w		1,08,07,04
	dc.w		2,07,00,04
	dc.w		2,01,02,05
	dc.w		1,02,09,05
	dc.w		2,09,08,05
	dc.w		1,08,01,05
	dc.w		1,02,03,06
	dc.w		2,03,10,06
	dc.w		1,10,09,06
	dc.w		2,09,02,06
	dc.w		1,08,09,11
	dc.w		2,09,10,11
	dc.w		1,10,07,11
	dc.w		2,07,08,11
	dc.w		2,07,10,12
	dc.w		1,10,03,12
	dc.w		2,03,00,12
	dc.w		1,00,07,12
	dc.w		1,00,03,13
	dc.w		2,03,02,13
	dc.w		1,02,01,13
	dc.w		2,01,00,13
MultiObjectPalette:
	dc.w		$000a,$000f,$0ccf,$0fff
MultiObjectScreen:
	dcb.w		2*MULTI_NBPOINT,0							; Les coordonnées après rotation et perspective

;*******************************************************************************
;	CYLINDRE
;*******************************************************************************

CYL_NBPOINT					= 18
CYL_NBFACE					= 32

CylindreObject:
	dc.w		0,0,0													; Angles de rotation
	dc.w		0,0,0													; Centre de rotation
	dc.w		0,0,0													; Coordonnées de l'objet
	dc.w		CYL_NBPOINT										; Nombre de sommets
	dc.l		CylindreObjectPoint						; Liste des sommets
	dc.l		CylindreObjectScreen					; Coordonnées écran
	dc.w		CYL_NBFACE										; Nombre de faces
	dc.l		CylindreObjectFace						; Liste des faces
	dc.l		CylindreObjectPalette					; Palette de l'objet
CylindreBoundingArea:
	dc.w		0,0,0,0												; La bounding area de l'objet
CylindreObjectPoint:
	dc.w		00,50,00
	dc.w		-50,50,00
	dc.w		-35,50,-35
	dc.w		00,50,-50
	dc.w		35,50,-35
	dc.w		50,50,00
	dc.w		35,50,35
	dc.w		00,50,50
	dc.w		-35,50,35
	dc.w		00,-50,00
	dc.w		-50,-50,00
	dc.w		-35,-50,-35
	dc.w		00,-50,-50
	dc.w		35,-50,-35
	dc.w		50,-50,00
	dc.w		35,-50,35
	dc.w		00,-50,50
	dc.w		-35,-50,35
CylindreObjectFace:
	dc.w		1,00,02,01
	dc.w		2,00,03,02
	dc.w		1,00,04,03
	dc.w		2,00,05,04
	dc.w		1,00,06,05
	dc.w		2,00,07,06
	dc.w		1,00,08,07
	dc.w		2,00,01,08
	dc.w		1,09,17,10
	dc.w		2,09,10,11
	dc.w		1,09,11,12
	dc.w		2,09,12,13
	dc.w		1,09,13,14
	dc.w		2,09,14,15
	dc.w		1,09,15,16
	dc.w		2,09,16,17
	dc.w    2,01,02,11
	dc.w    1,02,03,11
	dc.w    2,03,04,13
	dc.w    1,04,05,13
	dc.w    2,05,06,15
	dc.w    1,06,07,15
	dc.w    2,07,08,17
	dc.w    1,08,01,17
	dc.w    1,11,10,01
	dc.w    2,12,11,03
	dc.w    1,13,12,03
	dc.w    2,14,13,05
	dc.w    1,15,14,05
	dc.w    2,16,15,07
	dc.w    1,17,16,07
	dc.w    2,10,17,01
CylindreObjectPalette:
	dc.w		$0aa0,$0ff0,$0ffc,$0fff
CylindreObjectScreen:
	dcb.w		2*CYL_NBPOINT,0								; Les coordonnées après rotation et perspective

;*******************************************************************************
;	TOUPIE
;*******************************************************************************

BAL_NBPOINT					= 18
BAL_NBFACE					= 32

ToupieObject:
	dc.w		0,0,0													; Angles de rotation
	dc.w		0,0,0													; Centre de rotation
	dc.w		0,0,0													; Coordonnées de l'objet
	dc.w		BAL_NBPOINT										; Nombre de sommets
	dc.l		ToupieObjectPoint							; Liste des sommets
	dc.l		ToupieObjectScreen						; Coordonnées écran
	dc.w		BAL_NBFACE										; Nombre de faces
	dc.l		ToupieObjectFace							; Liste des faces
	dc.l		ToupieObjectPalette						; Palette de l'objet
ToupieBoundingArea:
	dc.w		0,0,0,0												; La bounding area de l'objet
ToupieObjectPoint:
	dc.w		00,70,00
	dc.w		-50,15,00
	dc.w		-35,15,-35
	dc.w		00,15,-50
	dc.w		35,15,-35
	dc.w		50,15,00
	dc.w		35,15,35
	dc.w		00,15,50
	dc.w		-35,15,35
	dc.w		00,-70,00
	dc.w		-50,-15,00
	dc.w		-35,-15,-35
	dc.w		00,-15,-50
	dc.w		35,-15,-35
	dc.w		50,-15,00
	dc.w		35,-15,35
	dc.w		00,-15,50
	dc.w		-35,-15,35
ToupieObjectFace:
	dc.w		1,00,02,01
	dc.w		2,00,03,02
	dc.w		1,00,04,03
	dc.w		2,00,05,04
	dc.w		1,00,06,05
	dc.w		2,00,07,06
	dc.w		1,00,08,07
	dc.w		2,00,01,08
	dc.w		1,09,17,10
	dc.w		2,09,10,11
	dc.w		1,09,11,12
	dc.w		2,09,12,13
	dc.w		1,09,13,14
	dc.w		2,09,14,15
	dc.w		1,09,15,16
	dc.w		2,09,16,17
	dc.w    2,01,02,11
	dc.w    1,02,03,11
	dc.w    2,03,04,13
	dc.w    1,04,05,13
	dc.w    2,05,06,15
	dc.w    1,06,07,15
	dc.w    2,07,08,17
	dc.w    1,08,01,17
	dc.w    1,11,10,01
	dc.w    2,12,11,03
	dc.w    1,13,12,03
	dc.w    2,14,13,05
	dc.w    1,15,14,05
	dc.w    2,16,15,07
	dc.w    1,17,16,07
	dc.w    2,10,17,01
ToupieObjectPalette:
	dc.w		$0a0a,$0f0f,$0fcf,$0fff
ToupieObjectScreen:
	dcb.w		2*BAL_NBPOINT,0								; Les coordonnées après rotation et perspective
