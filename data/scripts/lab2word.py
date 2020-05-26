#!/usr/bin/python
# The format is described here:
# http://festvox.org/docs/speech_tools-1.2.0/x444.htm
# Essentially 26 corresponds to a color code.
import sys

in_lab = sys.stdin
out_lab = sys.stdout

htk_time_const = 10000000.0
color_code = 36

print >> out_lab, "separator ;"
print >> out_lab, "nfields 2"
print >> out_lab, "#"
word_label = None
word_labels = {}
n_words = 0
for ln in in_lab:
    ln = ln.rstrip('\r\n')
    ln_info = ln.split()
    start_time = int(ln_info[0])
    end_time = int(ln_info[1])
    duration = end_time - start_time
    ph_label = ln_info[2]

    # The word is the fourth field in the row corresponding to
    # its first phoneme
    if len(ln_info)==4:
        word_label=ln_info[3]
        if word_label=='silence':
            word_label = 'pau'
        if word_label not in word_labels:
            n_words += 1
            word_labels[word_label] = n_words

    if ph_label=='sil' or ph_label=='sp':
        ph_label = 'pau'

    if ph_label=='pau':
        if word_label != 'pau':
            f_time = start_time
        else:
            f_time = end_time
        f_time /= htk_time_const
        if word_label is None:
            raise Exception("The word label has not been initialized.")
        if word_label != 'pau':
            print >> out_lab, "{:.2f} {} {} ; wordlab \"{}\" ;".format(f_time, color_code, word_label, word_labels[word_label])
        #if word_label != 'pau' and duration>0:
        #    print >> out_lab, "{:.2f} {} {} ; wordlab \"{}\" ;".format(end_time/htk_time_const, color_code, 'pau', word_labels['pau'])

        word_label = None
