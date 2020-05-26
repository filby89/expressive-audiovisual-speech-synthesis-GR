#!/usr/bin/python
# The format is described here:
# http://festvox.org/docs/speech_tools-1.2.0/x444.htm
# Essentially 26 corresponds to a color code.
import sys

in_lab = sys.stdin
out_lab = sys.stdout
phone_map_file = sys.argv[1]

phone_map = {}
with open(phone_map_file) as pmf:
    for ln in pmf:
        ln = ln.rstrip('\r\n')
        ln_info = ln.split()
        if len(ln_info)>1:
            phone_map[ln_info[0]] = ln_info[1]

htk_time_const = 10000000.0

print >> out_lab, "separator ;"
print >> out_lab, "nfields 1"
print >> out_lab, "#"
for ln in in_lab:
    ln = ln.rstrip('\r\n')
    ln_info = ln.split()
    start_time = int(ln_info[0])
    end_time = int(ln_info[1])
    ph_label = ln_info[2]

    if ph_label=='J-ly':
        ph_label = 'ly'

    if end_time>start_time:
        end_time /= htk_time_const
        print >> out_lab, "{:.2f} {} {}".format(end_time, 26, phone_map[ph_label])
