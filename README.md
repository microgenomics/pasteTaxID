# PasteTaxID
Welcome to the final solution for head's pains :D
This script take your fastas, search for common IDs (ti, gi, emb, gb), get the ti (and gi if is missing), and finally put the ID's in the corresponding fastas with high speed (2-3 fastas per second)
Support a lot files (more than 150000), avoiding the system collapse and save a lot of time!

## Usage

    bash PasteTaxID.bash --workpath [directory_fastas]

where workpath is a directory where your fastas are. In the example folder there are some fastas that doesn't contain a gi or a ti, just gb, try to test the script writing:  "bash PasteTaxID.bash --workpath example", wait a seconds and see the fastas again, now you can see the tax id and gi.

### Warning
PasteTaxID doesn't support multi-fastas, you have to cut them. try: csplit -z mymultifasta.fasta '/>/' '{*}'
the same command for .fna, .fn, etc works too.
