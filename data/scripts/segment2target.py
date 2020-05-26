#!/usr/bin/python
import sys
from math import exp

voiced_phonemes = ['ly', 'E', 'A', 'i', 'D', 'g', 'm', 'G', 'u', 'o', 'N', 'b', 'd', 'J', 'l', 'n', 'r', 'v', 'z']
seg_file = sys.argv[1]
lf0_file = sys.argv[2]
samp_period = float(sys.argv[3])
target_file = sys.stdout

color_code = 105

pitch_values = []
with open(lf0_file) as lf:
    pitch_values = lf.readlines()

print >> target_file, "separator ;"
print >> target_file, "nfields 1"
print >> target_file, "#"

with open(seg_file) as sf:
    previous_end_time = 0.0
    for ln in sf:
        ln = ln.rstrip('\r\n')
        ln_info = ln.split()
        n_elems = len(ln_info)
        if n_elems>2:
            end_time = float(ln_info[0])
            ph_label = ln_info[2]
            if ph_label in voiced_phonemes:
                start_time = previous_end_time
                start_index = int(start_time/samp_period) - 1
                end_index = int(end_time/samp_period) - 1
                pitch_val = -1e+10
                pitch_sum = 0.0
                n_vals = 0
                for i in range(start_index, end_index + 1):
                    p = float(pitch_values[i])
                    if p>0.0:
                        pitch_sum += p
                        n_vals += 1
                if n_vals>0:
                    pitch_val = pitch_sum / n_vals
                mid_seg_time = (start_time + end_time) / 2
                #pitch_index = int(mid_seg_time/samp_period)
                #print "{} {} {}".format(mid_seg_time, samp_period, pitch_index)
                pitch_val = exp(float(pitch_val))
                print >> target_file, "{:.2f} {} {:.4f}".format(mid_seg_time, color_code, pitch_val)
            previous_end_time = end_time

