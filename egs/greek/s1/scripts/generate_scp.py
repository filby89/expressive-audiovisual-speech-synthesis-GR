import os
import sys

DIR = sys.argv[1]

scp = open(os.path.join(DIR, "file_id_list.scp"), "w")

def exists(DIR, _type, base):
	# print os.path.join(DIR, _type, base + "." + _type)
	if os.path.isfile(os.path.join(DIR, _type, base + "." + _type)):
		return True
	else:
		return False

for mgc in os.listdir(os.path.join(DIR, "mgc")):
	if mgc.endswith(".mgc"):
		base = mgc.split(".")[0]
		if exists(DIR, "lf0", base) and exists(DIR, "bap", base) and exists(DIR, "texture", base) and exists(DIR, "shape", base):
			scp.write(base+"\n")

scp.close()