#!/usr/bin/python
# coding: utf-8
import sys
import re
import codecs

in_filename = sys.argv[1]
lexicon = sys.argv[2]
out_filename = sys.argv[3]

vowels = ['a', 'e', 'o', 'u', 'i', 'ά', 'έ','ό', 'ί', 'ύ']
consonants = ['L', 'D', 'G', 'M', 'J', 'N', 'T', 'X', 'c', 'b', 'd', 'g', 'f', 'h', 'k', 'j', 'm', 'l', 'n', 'p', 's', 'r', 't', 'v', 'x', 'z']

#print "Number of vowels: {}".format(len(vowels))
#print "Number of consonants: {}".format(len(consonants))

dico = {}
with codecs.open(lexicon, encoding='utf-8') as lex:
    for ln in lex:
        ln = ln.rstrip('\r\n')
        ln_info = ln.split()
        if len(ln_info)>1:
            if ln_info[1][0] in dico:
                dico[ln_info[1][0]].append(ln_info[1])
            else:
                dico[ln_info[1][0]] = [ln_info[1]]

out_file = codecs.open(out_filename, 'w', encoding='utf-8')
with codecs.open(in_filename, encoding='utf-8') as in_file:
    for ln in in_file:
        ln = ln.rstrip('\r\n')
        ln_info = ln.split()
        for wrd in ln_info:
            phones = list(wrd)
            n_phones = len(phones)
            i_phone = 0
            n_vowels = 0
            front_part = []
            mid_part = []
            while i_phone<n_phones:
                ph = phones[i_phone]
                if n_vowels==0:
                    front_part.append(ph)
                    if ph.encode("utf-8") in vowels:
                        n_vowels += 1
                else:
                    if ph in consonants:
                        mid_part.append(ph)
                    else:
                        if len(mid_part)==0:
                            front_part.append(ph)
                            n_vowels = 1
                        elif len(mid_part)==1:
                            s = "".join(front_part)
                            print >> out_file, s,
                            front_part = mid_part[:]
                            front_part.append(ph)
                            n_vowels = 1
                            mid_part = []
                        elif len(mid_part)>1:
                            found_wrd = False
                            if mid_part[0] in dico:
                                for i in dico[mid_part[0]]:
                                    if re.match("".join(mid_part), i):
                                        s = "".join(front_part)
                                        print >> out_file, s,
                                        front_part = mid_part[:]
                                        front_part.append(ph)
                                        n_vowels = 1
                                        found_wrd = True
                                        mid_part = []
                                        break
                            if not found_wrd:
                                front_part.append(mid_part.pop(0))
                                s = "".join(front_part)
                                print >> out_file, s,
                                front_part = mid_part[:]
                                front_part.append(ph)
                                mid_part = []
                                n_vowels = 1
                i_phone += 1

            if len(front_part)>0:
                s = "".join(front_part)
                if len(mid_part)>0:
                    s += "".join(mid_part)
                print >> out_file, s,
        print >> out_file, ""


out_file.close()











