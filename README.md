# pasteTaxID
------------
Welcome to the final solution to a lot of headaches :D
This script will take a multifasta file (or many individual fasta files), then search for common IDs (ti, gi, emb, gb), and append the corresponding ti (and gi if missing) to fasta entries at high speed (10000 entries in just 4 minutes!, depending on your internet connection).
pasteTaxID can take large multifasta files (we have tried more than 150000 without any problems), avoiding collapsing your system and saving a lot of time!

## Requirements
* Bash version 4 (comes with Linux and Mac)
* Python == 2.7.x
* Internet connection

## Usage
There are two ways of running the script. If you have a directory with individual fasta files then you could use the first strategy

#### Simple way

    bash pasteTaxID.bash --workpath [directory_fastas]

However, if you have a multifasta file, the appropriate command line is

    bash pasteTaxID.bash --multifasta [multifasta_file]

where `--workdir` is a directory where your fastas are and `--multifasta` is the multifasta file (.fna, .fn or .fasta works too). 

In the example folder there are some fastas that don't contain a gi or a ti, just gb. Try testing the script by issueing

	bash PasteTaxID.bash --workpath example

Wait a few seconds and check the fastas again. Now  you should see tax id's and gi's appended to the fasta entries.

#### Complete way

Additionally there is a complete way (two more parameters). If your default python is not 2.7, you can add --pythonBin and pass the full path to your python 2.7.

	bash pasteTaxID.bash --multifasta myfasta.fasta --pythonBin /home/Peter/programs/python2.7/bin/python

And finally, you can set the number of parallel process to improve the fetch speed (Max jobs: 60).

	bash pasteTaxID.bash --multifasta myfasta.fasta --parallelJobs 40

This fetch 40 IDs at the same time (max number you can set: 40).

### Notes
* If you have a huge multifasta (> million fasta entries), go for a coffee (or 2) while the script runs.
* Notice that the order of fasta entries in a multifasta file might have changed in comparison to the order of fasta entries in the file pasteTaxID produces

## External useful tools
check for these tools to extract some useful information from your data:

* [multiGenomicContext](https://github.com/Sanrrone/multiGenomicContext): Check the genomic context of several genomes or sequence just providing the GBK files.

* [fetchMyLineage](https://github.com/Sanrrone/fetchMyLineage): Return the complete lineage of your organism just providing the genus and species names.

* [extractSeq](https://github.com/Sanrrone/extractSeq): Extract and size defined sequence from and specific contig, from and specific genome.

* [plotMyGBK](https://github.com/Sanrrone/plotMyGBK): Plot your GBK in a circular graph with COG categories.

* [pasteTaxID](https://github.com/Sanrrone/pasteTaxID): fetch the taxonomic IDs to your fastas.

* [GGisy](https://github.com/Sanrrone/GGisy): Plot synteny of two sequence (you can use two genomes), and see the identity of the matched regions.

* [getS2](https://github.com/Sanrrone/getS2): obtain the order parameter to each residue of your simulation.
