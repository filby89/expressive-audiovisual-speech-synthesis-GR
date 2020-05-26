#!/usr/bin/python
import sys

syllable_file = sys.stdin
intevent_file = sys.stdout

color_code = 71

print >> intevent_file, "separator ;"
print >> intevent_file, "nfields 1"
print >> intevent_file, "#"
for ln in syllable_file:
    ln = ln.rstrip('\r\n')
    ln_info = ln.split()

    n_fields = len(ln_info)
    if n_fields>2:
        end_time = ln_info[0]
        print >> intevent_file, "{} {} {}".format(end_time, color_code, "L*+H")




