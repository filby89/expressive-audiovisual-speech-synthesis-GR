#!/usr/bin/python
# The format is described here:
# http://festvox.org/docs/speech_tools-1.2.0/x444.htm
# Essentially 26 corresponds to a color code.
import sys

if __name__=="__main__":
    lab_file = sys.stdin
    est_file = sys.stdout

    temp_unit = float(sys.argv[1])

    print >> est_file, "separator ;"
    print >> est_file, "nfields 1"
    print >> est_file, "#"


    for ln in lab_file:
        ln = ln.rstrip("\r\n")
        ln_info = ln.split(" ")

        if len(ln_info)<3:
            break
        end_time = float(ln_info[1]) / temp_unit
        label = ln_info[2]

        if label=='sp' or label=='sil':
            label = 'pau'

        print >> est_file, "\t {0} {1}\t {2}".format(end_time, 26, label)



