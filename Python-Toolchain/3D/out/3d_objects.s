;******************************************
;	CUBE
;******************************************

CUBE_NBPOINT		= 8
CUBE_NBFACE		= 12

CubeObject:
	dc.w		0,0,0					; Rotation angles
	dc.w		0,0,0					; Rotation pivot
	dc.w		0,0,0					; Object translation
	dc.w		CUBE_NBPOINT					; Vertice count
	dc.l		CubeObjectPoint					; Vertice list
	dc.l		CubeObjectScreen					; Screen coordinates
	dc.w		CUBE_NBFACE					; Faces count
	dc.l		CubeObjectFace					; Faces list
	dc.l		CubeObjectPalette					; Object palette
CubeBoundingArea:
	dc.w		0,0,0,0					; Object bounding box area
CubeObjectPoint:					; X, Y and Z
	dc.w		50,-50,50
	dc.w		50,50,50
	dc.w		-50,50,50
	dc.w		-50,-50,50
	dc.w		50,-50,-50
	dc.w		-50,-50,-50
	dc.w		-50,50,-50
	dc.w		50,50,-50
CubeObjectFace:					; Color, Vertex 1, 2, 3
	dc.w		0,0,1,2,
	dc.w		0,2,3,0,
	dc.w		0,4,5,6,
	dc.w		0,6,7,4,
	dc.w		0,7,6,2,
	dc.w		0,2,1,7,
	dc.w		0,4,7,1,
	dc.w		0,1,0,4,
	dc.w		0,5,4,0,
	dc.w		0,0,3,5,
	dc.w		0,6,5,3,
	dc.w		0,3,2,6,
CubeObjectPalette:
	dc.w		$444,$888,$ddd,$fff
CubeObjectScreen:
	dcb.w		 2*CUBE_NBPOINT

;******************************************
;	TEAPOT
;******************************************

TEAPOT_NBPOINT		= 94
TEAPOT_NBFACE		= 152

TeapotObject:
	dc.w		0,0,0					; Rotation angles
	dc.w		0,0,0					; Rotation pivot
	dc.w		0,0,0					; Object translation
	dc.w		TEAPOT_NBPOINT					; Vertice count
	dc.l		TeapotObjectPoint					; Vertice list
	dc.l		TeapotObjectScreen					; Screen coordinates
	dc.w		TEAPOT_NBFACE					; Faces count
	dc.l		TeapotObjectFace					; Faces list
	dc.l		TeapotObjectPalette					; Object palette
TeapotBoundingArea:
	dc.w		0,0,0,0					; Object bounding box area
TeapotObjectPoint:					; X, Y and Z
	dc.w		26,27,-22
	dc.w		36,1,-22
	dc.w		34,1,-24
	dc.w		24,25,-24
	dc.w		0,38,-22
	dc.w		0,35,-24
	dc.w		-26,27,-22
	dc.w		-25,25,-24
	dc.w		-37,1,-22
	dc.w		-35,1,-24
	dc.w		-26,-25,-22
	dc.w		-25,-23,-24
	dc.w		0,-36,-22
	dc.w		0,-33,-24
	dc.w		26,-25,-22
	dc.w		24,-23,-24
	dc.w		34,36,14
	dc.w		49,1,14
	dc.w		0,50,14
	dc.w		-35,36,14
	dc.w		-49,1,14
	dc.w		-35,-34,14
	dc.w		0,-48,14
	dc.w		34,-34,14
	dc.w		30,31,27
	dc.w		43,1,27
	dc.w		22,23,35
	dc.w		31,1,35
	dc.w		0,44,27
	dc.w		0,32,35
	dc.w		-31,31,27
	dc.w		-22,23,35
	dc.w		-43,1,27
	dc.w		-32,1,35
	dc.w		-31,-29,27
	dc.w		-22,-21,35
	dc.w		0,-42,27
	dc.w		0,-30,35
	dc.w		30,-29,27
	dc.w		22,-21,35
	dc.w		0,1,37
	dc.w		-62,6,-14
	dc.w		-60,1,-12
	dc.w		-40,1,-13
	dc.w		-38,6,-16
	dc.w		-71,6,-7
	dc.w		-65,1,-7
	dc.w		-65,1,-17
	dc.w		-37,1,-18
	dc.w		-74,1,-7
	dc.w		-62,-4,-14
	dc.w		-38,-4,-16
	dc.w		-71,-4,-7
	dc.w		-47,6,10
	dc.w		-46,1,6
	dc.w		-49,1,13
	dc.w		-47,-4,10
	dc.w		41,1,1
	dc.w		41,13,11
	dc.w		77,4,-24
	dc.w		69,1,-23
	dc.w		41,1,22
	dc.w		84,1,-24
	dc.w		41,-11,11
	dc.w		77,-2,-24
	dc.w		74,3,-22
	dc.w		69,1,-22
	dc.w		79,1,-22
	dc.w		74,-1,-22
	dc.w		5,6,-36
	dc.w		7,1,-36
	dc.w		0,1,-41
	dc.w		3,4,-29
	dc.w		4,1,-29
	dc.w		0,9,-36
	dc.w		0,6,-29
	dc.w		-6,6,-36
	dc.w		-3,4,-29
	dc.w		-8,1,-36
	dc.w		-5,1,-29
	dc.w		-6,-4,-36
	dc.w		-3,-2,-29
	dc.w		0,-6,-36
	dc.w		0,-3,-29
	dc.w		5,-4,-36
	dc.w		3,-2,-29
	dc.w		22,24,-22
	dc.w		31,1,-22
	dc.w		0,33,-22
	dc.w		-23,24,-22
	dc.w		-32,1,-22
	dc.w		-23,-21,-22
	dc.w		0,-31,-22
	dc.w		22,-21,-22
TeapotObjectFace:					; Color, Vertex 1, 2, 3
	dc.w		0,0,1,2,
	dc.w		0,2,3,0,
	dc.w		0,4,0,3,
	dc.w		0,3,5,4,
	dc.w		0,6,4,5,
	dc.w		0,5,7,6,
	dc.w		0,8,6,7,
	dc.w		0,7,9,8,
	dc.w		0,10,8,9,
	dc.w		0,9,11,10,
	dc.w		0,12,10,11,
	dc.w		0,11,13,12,
	dc.w		0,14,12,13,
	dc.w		0,13,15,14,
	dc.w		0,1,14,15,
	dc.w		0,15,2,1,
	dc.w		0,1,0,16,
	dc.w		0,16,17,1,
	dc.w		0,0,4,18,
	dc.w		0,18,16,0,
	dc.w		0,4,6,19,
	dc.w		0,19,18,4,
	dc.w		0,6,8,20,
	dc.w		0,20,19,6,
	dc.w		0,8,10,21,
	dc.w		0,21,20,8,
	dc.w		0,10,12,22,
	dc.w		0,22,21,10,
	dc.w		0,12,14,23,
	dc.w		0,23,22,12,
	dc.w		0,14,1,17,
	dc.w		0,17,23,14,
	dc.w		0,24,25,17,
	dc.w		0,17,16,24,
	dc.w		0,25,24,26,
	dc.w		0,26,27,25,
	dc.w		0,28,24,16,
	dc.w		0,16,18,28,
	dc.w		0,24,28,29,
	dc.w		0,29,26,24,
	dc.w		0,30,28,18,
	dc.w		0,18,19,30,
	dc.w		0,28,30,31,
	dc.w		0,31,29,28,
	dc.w		0,32,30,19,
	dc.w		0,19,20,32,
	dc.w		0,30,32,33,
	dc.w		0,33,31,30,
	dc.w		0,34,32,20,
	dc.w		0,20,21,34,
	dc.w		0,32,34,35,
	dc.w		0,35,33,32,
	dc.w		0,36,34,21,
	dc.w		0,21,22,36,
	dc.w		0,34,36,37,
	dc.w		0,37,35,34,
	dc.w		0,38,36,22,
	dc.w		0,22,23,38,
	dc.w		0,36,38,39,
	dc.w		0,39,37,36,
	dc.w		0,25,38,23,
	dc.w		0,23,17,25,
	dc.w		0,38,25,27,
	dc.w		0,27,39,38,
	dc.w		0,27,26,40,
	dc.w		0,26,29,40,
	dc.w		0,29,31,40,
	dc.w		0,31,33,40,
	dc.w		0,33,35,40,
	dc.w		0,35,37,40,
	dc.w		0,37,39,40,
	dc.w		0,39,27,40,
	dc.w		0,41,42,43,
	dc.w		0,43,44,41,
	dc.w		0,45,46,42,
	dc.w		0,42,41,45,
	dc.w		0,47,41,44,
	dc.w		0,44,48,47,
	dc.w		0,49,45,41,
	dc.w		0,41,47,49,
	dc.w		0,50,47,48,
	dc.w		0,48,51,50,
	dc.w		0,52,49,47,
	dc.w		0,47,50,52,
	dc.w		0,42,50,51,
	dc.w		0,51,43,42,
	dc.w		0,46,52,50,
	dc.w		0,50,42,46,
	dc.w		0,46,45,53,
	dc.w		0,53,54,46,
	dc.w		0,45,49,55,
	dc.w		0,55,53,45,
	dc.w		0,49,52,56,
	dc.w		0,56,55,49,
	dc.w		0,52,46,54,
	dc.w		0,54,56,52,
	dc.w		0,57,58,59,
	dc.w		0,59,60,57,
	dc.w		0,58,61,62,
	dc.w		0,62,59,58,
	dc.w		0,61,63,64,
	dc.w		0,64,62,61,
	dc.w		0,63,57,60,
	dc.w		0,60,64,63,
	dc.w		0,65,66,60,
	dc.w		0,60,59,65,
	dc.w		0,67,65,59,
	dc.w		0,59,62,67,
	dc.w		0,68,67,62,
	dc.w		0,62,64,68,
	dc.w		0,66,68,64,
	dc.w		0,64,60,66,
	dc.w		0,69,70,71,
	dc.w		0,72,73,70,
	dc.w		0,70,69,72,
	dc.w		0,74,69,71,
	dc.w		0,75,72,69,
	dc.w		0,69,74,75,
	dc.w		0,76,74,71,
	dc.w		0,77,75,74,
	dc.w		0,74,76,77,
	dc.w		0,78,76,71,
	dc.w		0,79,77,76,
	dc.w		0,76,78,79,
	dc.w		0,80,78,71,
	dc.w		0,81,79,78,
	dc.w		0,78,80,81,
	dc.w		0,82,80,71,
	dc.w		0,83,81,80,
	dc.w		0,80,82,83,
	dc.w		0,84,82,71,
	dc.w		0,85,83,82,
	dc.w		0,82,84,85,
	dc.w		0,70,84,71,
	dc.w		0,73,85,84,
	dc.w		0,84,70,73,
	dc.w		0,73,72,86,
	dc.w		0,86,87,73,
	dc.w		0,72,75,88,
	dc.w		0,88,86,72,
	dc.w		0,75,77,89,
	dc.w		0,89,88,75,
	dc.w		0,77,79,90,
	dc.w		0,90,89,77,
	dc.w		0,79,81,91,
	dc.w		0,91,90,79,
	dc.w		0,81,83,92,
	dc.w		0,92,91,81,
	dc.w		0,83,85,93,
	dc.w		0,93,92,83,
	dc.w		0,85,73,87,
	dc.w		0,87,93,85,
TeapotObjectPalette:
	dc.w		$444,$888,$ddd,$fff
TeapotObjectScreen:
	dcb.w		 2*TEAPOT_NBPOINT

