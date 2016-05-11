#######################################################################################################################
#Autor: Sandro Valenzuela (sanrrone@hotmail.com)
#pasteTaxID have 2 usage
#Usage 1: bash parseTaxID.bash --workdir [fastas_path] if you have a lot fastas in the workdir
#Usage 2: bash parseTaxID.bash --multifasta [multifasta_file] if you have a huge multifasta file (.fna, .fn works too)
#for debug add --debug
#######################################################################################################################

if [[ "$@" =~ "--debug" ]]; then
	set -ex
else
	set -e
fi

function makePythonWork {
	echo '#!/usr/bin/python

import glob,os
import sys

if len(sys.argv) >= 3:
	os.chdir(sys.argv[1])
	fastaapend=open(sys.argv[2],"wb")

	for file in glob.glob("*.fasta"):
		fasta=open(file, "r")
		oneline = fasta.readline()
		seq =(file,oneline)
		s=" "
		fastaapend.write(s.join(seq))
		fasta.close()
		
	fastaapend.close()

else:
        print "Workpath and file_out are needed";' > appendheaders.py
}

function makeAwkWork {
	echo 'BEGIN{FS="|"}
{
if($1~">"){
	split($1,array,">")
	$1=array[2]
	for (i=1;i<100;i++){
	band=0;
		if($i != ""){
				if($i==ID){
					ID=$(i+1);
					print ID
					exit 0
				}
		}
				
	}
}
}' > parsefasta.awk
}

function makeMergeWork {
	echo '#!/usr/bin/python

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
	print "Workpath and file_out are needed";' > merge.py
}

statusband=0
workpathband=0
multifband=0
multiway=0
for i in "$@"
do
	case $i in
	"--workdir")
		workpathband=1
	;;
	"--multifasta")
		multifband=1
	;;
	"--help")
		echo "Usage 1: bash parseTaxID.bash --workdir [fastas_path] if you have a lot fastas in the workdir"
		echo "Usage 2: bash parseTaxID.bash --multifasta [multifasta_file] if you have a huge multifasta file (.fna, .fn works too)"
		echo "Note: --workdir will take your fastas and put the tax id in the same file, make sure you have a backup of files."
		exit

	;;
	*)
		
		if [ $((workpathband)) -eq 1 ];then
			statusband=$((statusband+1))
			workpathband=0
			WORKDIR=$i
			EXECUTEWORKDIR=`pwd`
		fi

		if [ $((multifband)) -eq 1 ];then
			statusband=$((statusband+1))
			multifband=0
			multiway=1
			actual=`pwd`
			multifname=`echo "$i" |rev |cut -d '/' -f 1 |rev`
			multffolder=`echo "$i" |rev |cut -d '/' -f 2- |rev`
			if [ "$multifname" == "$multffolder" ];then
				multif=$multifname
			else
				cd $multffolder
				multffolder=`pwd`
				cd $actual
				multif="$multffolder/$multifname"
			fi
		fi

	esac
done

if [ $((statusband)) -eq 1 ]; then

######################		SPLIT FASTAS	##########################
	case $multiway in
	"0")
		echo "no multifasta specified, continue" 
	;;
	"1")
		echo "splitting multifasta, (if the file is a huge file, you should go for a coffee while the script works"
		if [ -f $multif ];then
			rm -fr TMP_FOLDER_DONT_TOUCH
			mkdir TMP_FOLDER_DONT_TOUCH
			cd TMP_FOLDER_DONT_TOUCH
			awk '/^>/{close(s);s=++d".fasta"} {print > s}' ../$multif
			echo "Splitting complete, DON'T TOUCH TMP_FOLDER WHILE SCRIPT IS RUNNING"
			WORKDIR=`pwd`
			cd ..

		else
			echo "exist($multifasta) = FALSE"
			exit
		fi
		
	;;
	*)
		echo "unknow error at multifastaflag"
		exit
	;;
	esac


######################		MAKE HEADERS	##########################


	fileout="headers.txt"
	switchfile="newheader.txt"
	echo "making headers from fastas"
	cd $WORKDIR
	makePythonWork
	case $multiway in
		"0")
			#workpath
			python appendheaders.py "." $fileout	#just take the first line of each fasta (>foo|1234|lorem ipsum)
		;;
		"1")
			#multif
			python appendheaders.py $WORKDIR $fileout	#just take the first line of each fasta (>foo|1234|lorem ipsum)
		;;
	esac
	
######################################################################

######################		FETCH ID		##########################

	total=`wc -l $fileout |awk '{print $1}'`
	i=1
	makeAwkWork
	declare pids

	while read line
	do
		echo "fetching Tax ID ($i of $total)"
		#first, we get the critical data through awk and the ID that we find
		fasta=`echo $line |awk '{print $1}'`
		fastaheader=`echo $line |awk '{print $2}'`
		gi=`echo "$fastaheader" |awk -v ID="gi" -f parsefasta.awk &`
		lastpid=$!
		pids[0]="$lastpid"
		ti=`echo "$fastaheader" |awk -v ID="ti" -f parsefasta.awk &`
		lastpid=$!
		pids[1]="$lastpid"
		gb=`echo "$fastaheader" |awk -v ID="gb" -f parsefasta.awk &`
		lastpid=$!
		pids[2]="$lastpid"
		emb=`echo "$fastaheader" |awk -v ID="emb" -f parsefasta.awk &`
		lastpid=$!
		pids[3]="$lastpid"

		for pid in "${pids[@]}"
		do
			while [[ ( -d /proc/$pid ) && ( -z "grep zombie /proc/$pid/status" ) ]]; do
            	sleep 0.1
        	done
		done
		#the purpose this script is get the tax id, if exist just continue with next fasta
		if [  "$ti" != "" ];then
			echo "Tax Id exist in $fasta, new file will not generated"
		else
			if [ "$gi" == "" ] && [ "$gb" == "" ] && [ "$emb" == ""];then
				echo "no id is available for fetch in $fasta"
			else
				if [ "$gi" != "" ];then
					ti=""
					while [ "$ti" == "" ]
					do
						ti=`curl -s "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=nuccore&db=taxonomy&id=$gi" |grep "<Id>"|tail -n1 |awk '{print $1}' |cut -d '>' -f 2 |cut -d '<' -f 1`
					done
					echo "$fasta $ti" >> $switchfile

					gb=""
					emb=""
					dbj=""					
				fi
				
				if [ "$emb" != "" ];then
					ti=""
					while [ "$ti" == "" ]
					do
						gi=`curl -s "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$emb&rettype=fasta" |awk -v ID="gi" -f parsefasta.awk`
						ti=`curl -s "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=nuccore&db=taxonomy&id=$gi" |grep "<Id>"|tail -n1 |awk '{print $1}' |cut -d '>' -f 2 |cut -d '<' -f 1`
					done
					echo "$fasta $ti $gi" >> $switchfile

					gb=""
				fi
				
				if [ "$gb" != "" ];then
					ti=""
					while [ "$ti" == "" ]
					do
						gi=`curl -s "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$gb&rettype=fasta" |awk -v ID="gi" -f parsefasta.awk`
						ti=`curl -s "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=nuccore&db=taxonomy&id=$gi" |grep "<Id>"|tail -n1 |awk '{print $1}' |cut -d '>' -f 2 |cut -d '<' -f 1`
					done
					echo "$fasta $ti $gi" >> $switchfile				

				fi								
				
			fi
		fi
		
		i=$((i+1))
	
	done < <(grep "" $fileout)
####################		ADD ID's		##########################	
	i=1
	total=`wc -l $switchfile |awk '{print $1}'`
	while read line
	do
		fasta=`echo "$line" |awk '{print $1}'`
		ti=`echo "$line" |awk '{print $2}'`
		gi=`echo "$line" |awk '{print $3}'`
		echo "working on $fasta  ($i/$total)"

		if [ "$gi" == "" ];then
			sed "s/>/>ti|$ti|/g" $fasta > tmp
				case $multiway in
				"0")
					mv tmp new_$fasta
				;;
				"1")
					rm $fasta
					mv tmp $fasta
				;;
				esac
		else
			sed "s/>/>ti|$ti|gi|$gi|/g" $fasta > tmp
				case $multiway in
				"0")
					mv tmp new_$fasta
				;;
				"1")
					rm $fasta
					mv tmp $fasta
				;;
				esac
		fi
		i=$((i+1))
		
	done < <(grep "" $switchfile)

###################		MERGE FASTAS		############################
	#python merge.py folder_files file_out_name
	case $multiway in
	"0")
		rm -f appendheaders.py $fileout $switchfile parsefasta.awk
	;;
	"1")
		makeMergeWork
		python merge.py $WORKDIR $multifname.new
		mv $multifname.new new_$multifname
		mv new_$multifname ../.
		cd ..
		rm -rf TMP_FOLDER_DONT_TOUCH
	;;
	esac

	echo "Done"
else
	echo "Invalid or Missing Parameters, print --help to see the options"
	exit
fi
