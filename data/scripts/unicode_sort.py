#!/usr/bin/python
import sys
import codecs

in_filename = sys.argv[1]

with codecs.open(in_filename, encoding='utf-8') as f:
    lines = f.read().splitlines()
    lines.sort()
    print "\n".join(lines).encode("utf-8")

