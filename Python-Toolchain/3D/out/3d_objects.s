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
