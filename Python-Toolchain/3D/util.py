import os
from math import pi

# Browse the current path and get the list of files
# that end with one of the extensions provided as a list
def get_files_list(_path, _extension_list = [".mp4"]):
	_raw_list = os.listdir(_path)
	_files_list = []

	for _entry in _raw_list:
		for _ext in _extension_list:
			if _entry.find(_ext) != -1:
				_files_list.append(_entry)

	return _files_list

def format_number(n, accuracy=6):
    """Formats a number in a friendly manner (removes trailing zeros and unneccesary point."""
   
    fs = "%."+str(accuracy)+"f"
    str_n = fs%float(n)
    if '.' in str_n:
        str_n = str_n.rstrip('0').rstrip('.')
    if str_n == "-0":
        str_n = "0"
    #str_n = str_n.replace("-0", "0")
    return str_n
   

def lerp(a, b, i):
    """Linear enterpolate from a to b."""
    return a+(b-a)*i