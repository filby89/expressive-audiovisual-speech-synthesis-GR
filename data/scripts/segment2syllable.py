#!/usr/bin/python
# coding: utf-8
import sys
import codecs

stressed_vowels = ['ά', 'έ','ό', 'ί', 'ύ']

syllable_file = sys.argv[1]
segment_file = sys.argv[2]
phone_map_file = sys.argv[3]
out_file = sys.stdout

color_code = 121
sil_label = 'pau'
phone_mapping = {}
with codecs.open(phone_map_file, encoding='utf-8') as pm:
    for ln in pm:
        ln = ln.rstrip('\r\n')
        ln_info = ln.split()
        if len(ln_info)==2:
            phone_mapping[ln_info[0]] = ln_info[1]
        else:
            phone_mapping[ln_info[0]] = 'null'


with codecs.open(syllable_file, encoding='utf-8') as sf:
    with codecs.open(segment_file, encoding='utf-8') as lf:
        print >> out_file, "separator ;"
        print >> out_file, "nfields 2"
        print >> out_file, "#"
        stressed_syllables = sf.readline().rstrip('\r\n').split()
        for syl in stressed_syllables:
            syl_phones = list(syl)
            is_stressed = 0
            conv_syl_phones = []
            end_time = 0
            lab_info = []
            for sp in syl_phones:
                if sp.encode("utf-8") in stressed_vowels:
                    is_stressed = 1
                if phone_mapping[sp]!='null':
                    conv_syl_phones.append(phone_mapping[sp])
                    lab_line = lf.readline().rstrip('\r\n')
                    lab_info = lab_line.split()
                    lab_ph = ''
                    if len(lab_info)>2:
                        lab_ph = lab_info[2]
                    if lab_ph==sil_label:
                        end_time = lab_info[0]
                        #print >> out_file, "{} {} {} ; stress 0".format(end_time, color_code, sil_label)
                    while lab_ph != phone_mapping[sp]:
                        lab_line = lf.readline().rstrip('\r\n')
                        if lab_line=='':
                            raise Exception("File finished and phoneme label not found.")
                        lab_info = lab_line.split()
                        if len(lab_info)>2:
                            lab_ph = lab_info[2]
                        if lab_ph==sil_label:
                            end_time = lab_info[0]
                            #print >> out_file, "{} {} {} ; stress 0".format(end_time, color_code, sil_label)
                else:
                    break
            end_time = lab_info[0]
            conv_syl = ".".join(conv_syl_phones)
            print >> out_file, "{} {} {} ; stress {} ;".format(end_time, color_code, conv_syl, is_stressed)

        # Checking for a possible silence label in the end
        lab_line = lf.readline().rstrip('\r\n')
        lab_info = lab_line.split()
        if len(lab_info)>2:
            lab_ph = lab_info[2]
        if lab_ph==sil_label:
            end_time = lab_info[0]
            #print >> out_file, "{} {} {} ; stress 0".format(end_time, color_code, sil_label)



