#!/usr/bin/python

import glob,os
import sys

if len(sys.argv) >= 3:
	os.chdir(sys.argv[1])
	fastappend=open(sys.argv[2], "w")
	for file in glob.glob("*.fasta"):
		fasta=open(file, "r")
		lines = fasta.readlines()
		seq="".join(lines)
		fastappend.write(seq)
		fasta.close()
	fastappend.close()
else:
        print "Workpath and file_out are needed";
