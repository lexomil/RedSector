import os
import string
import codecs
import ast
from util import *
from vector3 import Vector3

scale_factor = 4.0

def parse_obj_vector(_string):
	_args = _string.split(' ')
	_vector = Vector3(float(_args[1]), float(_args[2]), float(_args[3]))
	_vector *= scale_factor
	_vector.x = float(int(_vector.x))
	_vector.y = float(int(_vector.y))
	_vector.z = float(int(_vector.z))
	return _vector

def parse_obj_face(_string):
	## f 13//1 15//2 4//3 2//4
	_args = _string.split(' ')
	_args.pop(0)
	_face = []
	_vertex_index = -1
	_uv_index = -1
	_normal_index = -1
	for _arg in _args:
		_corner = _arg.split('/')
		_vertex_index = -1
		_uv_index = -1
		_normal_index = -1
		if len(_corner) > 0:
			if _corner[0] != '':
				_vertex_index = int(_corner[0]) - 1
			if _corner[1] != '':
				_uv_index = int(_corner[1]) - 1
			if _corner[2] != '':
				_normal_index = int(_corner[2]) - 1

		_face.append({'vertex':_vertex_index, 'uv':_uv_index, 'normal':_normal_index})

	# _face = _face[::-1]
	# _face.append(_face.pop(0))
	# _face.append(_face[0])

	return _face

def main():
	folder_in = "in/"
	filename_out = 'out/3d_objects.s'
	fc = codecs.open(filename_out, 'w')

	def write_vect(vec_3, comment_str = None):
		out_str = '\tdc.w\t\t' + str(int(vec_3.x)) + ',' + str(int(vec_3.y)) + ',' + str(int(vec_3.z))
		if comment_str is not None:
			out_str += '\t\t\t\t\t; ' + comment_str
		fc.write(out_str + '\n') 

	filename_list = get_files_list(folder_in, [".obj"])
	for filename_in in filename_list:
		face_list = []
		vertex_list = []
		normal_list = []

		f = codecs.open(os.path.join(folder_in, filename_in), 'r')
		for line in f:
			# print(repr(line))
			if len(line) > 0:
				line = line.replace('\t', ' ')
				line = line.replace('  ', ' ')
				line = line.replace('  ', ' ')
				line = line.strip()
				if line.startswith('v '):
					# print('found a vertex')
					vertex_list.append(parse_obj_vector(line))

				if line.startswith('vn '):
					# print('found a vertex normal')
					normal_list.append(parse_obj_vector(line))

				if line.startswith('f '):
					# print('found a face')
					face_list.append(parse_obj_face(line))

		f.close()

		print('OBJ Parser : "' + filename_in + '", ' + str(len(vertex_list)) + ' vertices, ' + str(len(normal_list)) + ' normals, ' + str(len(face_list)) + ' faces, ')

		obj_name = filename_in.replace('.obj', '')
		obj_name = obj_name.replace(' ', '')
		obj_name = obj_name.replace('-', '_')
		obj_name = obj_name.lower()
		obj_name_upper = obj_name.upper()
		obj_name_cap = obj_name_upper.capitalize()

		##  Object description

		fc.write(';******************************************\n')
		fc.write(';\t' + obj_name_upper + '\n')
		fc.write(';******************************************\n\n')

		fc.write(obj_name_upper + '_NBPOINT\t\t= ' + str(len(vertex_list)) + '\n')
		fc.write(obj_name_upper + '_NBFACE\t\t= ' + str(len(face_list)) + '\n\n')

		##  Creates the C file that lists the vertices
		fc.write(obj_name_cap + 'Object:\n')
		write_vect(Vector3(), 'Rotation angles')
		write_vect(Vector3(), 'Rotation pivot')
		write_vect(Vector3(), 'Object translation')
		fc.write('\tdc.w\t\t' + obj_name_upper + '_NBPOINT' + '\t\t\t\t\t; Vertice count\n')
		fc.write('\tdc.l\t\t' + obj_name_cap + 'ObjectPoint' + '\t\t\t\t\t; Vertice list\n')
		fc.write('\tdc.l\t\t' + obj_name_cap + 'ObjectScreen' + '\t\t\t\t\t; Screen coordinates\n')
		fc.write('\tdc.w\t\t' + obj_name_upper + '_NBFACE' + '\t\t\t\t\t; Faces count\n')
		fc.write('\tdc.l\t\t' + obj_name_cap + 'ObjectFace' + '\t\t\t\t\t; Faces list\n')
		fc.write('\tdc.l\t\t' + obj_name_cap + 'ObjectPalette' + '\t\t\t\t\t; Object palette\n')

		fc.write(obj_name_cap + 'BoundingArea:\n')
		fc.write('\tdc.w\t\t0,0,0,0\t\t\t\t\t; Object bounding box area\n')

		##  Iterate on vertices
		fc.write(obj_name_cap + 'ObjectPoint:\t\t\t\t\t; X, Y and Z\n')
		for _vertex in vertex_list:
			_vertex_tranformed = Vector3(_vertex.x, _vertex.z, _vertex.y * -1.0)
			write_vect(_vertex_tranformed)

		##  Creates the C file that lists the faces

		##  Iterate on faces
		fc.write(obj_name_cap + 'ObjectFace:\t\t\t\t\t; Color, Vertex 1, 2, 3\n')

		for _face in face_list:
			_str_out = ''

			corner_idx = 0
			color_idx = 0
			_str_out += str(color_idx) + ','
			for _corners in _face:
				_str_out += str(_corners['vertex'])
				corner_idx += 1
				_str_out += ','

			fc.write('\tdc.w\t\t' + _str_out + '\n')

		##  Palette
		fc.write(obj_name_cap + 'ObjectPalette:\n')
		fc.write('\tdc.w\t\t$444,$888,$ddd,$fff\n')

		##  Palette
		fc.write(obj_name_cap + 'ObjectScreen:\n')
		fc.write('\tdcb.w\t\t 2*' + obj_name_upper +'_NBPOINT\n')

	fc.close()


if __name__ == "__main__":
	main()