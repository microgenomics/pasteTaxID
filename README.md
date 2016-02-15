![banner](https://raw.githubusercontent.com/microgenomics/tutorials/master/img/microgenomics.png)
# pasteTaxID
------------
Welcome to the final solution to a lot of headaches :D
This script will take a multifasta file (or many individual fasta files), then search for common IDs (ti, gi, emb, gb), and append the corresponding ti (and gi if missing) to fasta entries at high speed (2-3 fasta entries per second)
pasteTaxID can take large multifasta files (we have tried more than 150000 without any problems), avoiding collapsing your system and saving a lot of time!

##Requirements
* Bash version 4
* Internet connection

## Usage
There are two ways of running the script. If you have a directory with individual fasta files then you could use the first strategy

    bash pasteTaxID.bash --workpath [directory_fastas]

However, if you have a multifasta file, the appropriate command line is

    bash pasteTaxID.bash --multifasta [multifasta_file]

where `--workpath` is a directory where your fastas are and `--multifasta` is the multifasta file (.fna, fn works too). 

In the example folder there are some fastas that don't contain a gi or a ti, just gb. Try testing the script by issueing

	bash PasteTaxID.bash --workpath example

Wait a few seconds and check the fastas again. Now  you should see tax id's and gi's appended to the fasta entries.

### Notes
* If you have a huge multifasta (> million fasta entries), go for a coffee (or 2) while the script runs.
* Notice that the order of fasta entries in a multifasta file might have changed in comparison to the order of fasta entries in the file pasteTaxID produces

