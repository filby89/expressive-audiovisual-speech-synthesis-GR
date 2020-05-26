#!/usr/bin/python
import sys

phrase_file = sys.stdout

seg_file = sys.argv[1]
color_code = 124

with open(seg_file) as sf:
    print >> phrase_file, "separator ;"
    print >> phrase_file, "nfields 1"
    print >> phrase_file, "#"
    in_phrase = False
    previous_end_time = 0.0
    for ln in sf:
        ln = ln.rstrip('\r\n')
        ln_info = ln.split()
        if len(ln_info)<3:
            continue
        else:
            end_time = ln_info[0]
            label = ln_info[2]
            duration = float(end_time) - previous_end_time
            if label!='pau':
                in_phrase = True
            elif label=='pau' and duration>0.05 and in_phrase:
                print >> phrase_file, "{} {} 2".format(previous_end_time, color_code)
                in_phrase = False
            previous_end_time = float(end_time)






