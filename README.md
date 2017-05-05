![banner](https://raw.githubusercontent.com/microgenomics/tutorials/master/img/microgenomics.png)
# pasteTaxID
------------

This script will take a multifasta file (or many individual fasta files), then search for common IDs (ti, gi, emb, gb), and append the corresponding ti to fasta entries at high speed (5 fasta entries per second depending on your internet connection).  
pasteTaxID can take large multifasta files (we have tried more than 150000 without any problems), avoiding collapsing your system and saving a lot of time!

## Requirements
* Bash version 4 (comes with Linux and Mac)
* Python >= 2.7
* Internet connection

## Usage
There are two ways of running the script. If you have a directory with individual fasta files, then use the following strategy:  

    bash pasteTaxID.bash --workdir [directory_fastas]

However, if you have a multifasta file, the appropriate command line is:  

    bash pasteTaxID.bash --multifasta [multifasta_file]

where `--workpath` is a directory where your fasta files are located and `--multifasta` is the multifasta file (.fna, .fn or .fasta works too). 

In the example folder there are some fasta files that don't contain a gi or a ti, just gb. Try testing the script by issuing

	bash PasteTaxID.bash --workdir example

Wait a few seconds and check the fastas again. Now  you should see taxonomy id's and gi's appended to the fasta entries.

### Notes
* If you have a huge multifasta (> 1 million fasta entries), go for a coffee (or 2) while the script runs.
* Notice that the order of fasta entries in a multifasta file might have changed in comparison to the order of fasta entries in the file pasteTaxID produces

