import glob,os
os.chdir("/Users/castrolab01/Desktop/no_redundant_hmp/union")

fastaapend=open("merged.fna", "w")
for file in glob.glob("*.fasta"):
	fasta=open(file, "r")
	lines = fasta.readlines()
	seq="".join(lines)
	fastaapend.write(seq)
	fasta.close()

fastaapend.close()
