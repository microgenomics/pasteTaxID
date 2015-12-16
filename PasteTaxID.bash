#######################################################################################################################
#Autor: Sandro Valenzuela (sanrrone@hotmail.com)
#pasteTaxID have 2 usage
#Usage 1: bash parseTaxID.bash --workdir [fastas_path] if you have a lot fastas in the workdir
#Usage 2: bash parseTaxID.bash --multifasta [multifasta_file] if you have a huge multifasta file (.fna, .fn works too)
#######################################################################################################################
set -e

statusband=0
workpathband=0
multifband=0
multiway=0
for i in "$@"
do
	case $i in
	"--workpath")
		workpathband=1
	;;
	"--multifasta")
		multifband=1
	;;
	"--help")
		echo "Usage 1: bash parseTaxID.bash --workdir [fastas_path] if you have a lot fastas in the workdir"
		echo "Usage 2: bash parseTaxID.bash --multifasta [multifasta_file] if you have a huge multifasta file (.fna, .fn works too)"
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
			multif=$i
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
			mkdir TMP_FOLDER_DONT_TOUCH
			mv $multif TMP_FOLDER_DONT_TOUCH/.
			cd TMP_FOLDER_DONT_TOUCH
			multifname=`echo "$multif" |rev |cut -d '/' -f 1 |rev`
			awk '/^>/{close(s);s=++d".fasta"} {print > s}' $multifname
			mv $multifname ../.
			echo "Splitting complete, DON'T ENTER TO TMP_FOLDER WHILE SCRIPT IS RUNNING"
			WORKDIR=`pwd`
			cd ..
			EXECUTEWORKDIR=`pwd`

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
	echo "make headers from fastas"
	python appendheaders.py $WORKDIR $fileout	#just take the first line of each fasta (>foo|1234|)
	cd $WORKDIR
	
	
######################################################################

######################		FETCH ID		##########################

	total=`wc -l $fileout |awk '{print $1}'`
	i=1
	while read line
	do
		echo "fetching Tax ID ($i of $total)"
		#first, we get the critical data through awk and the ID that we find
		fasta=`echo $line |awk '{print $1}'`
		gi=`echo "$line" |awk -v ID="gi" -f ${EXECUTEWORKDIR}/parsefasta.awk &`
		ti=`echo "$line" |awk -v ID="ti" -f ${EXECUTEWORKDIR}/parsefasta.awk &`
		gb=`echo "$line" |awk -v ID="gb" -f ${EXECUTEWORKDIR}/parsefasta.awk &`
		emb=`echo "$line" |awk -v ID="emb" -f ${EXECUTEWORKDIR}/parsefasta.awk &`
		wait $!

		#the purpose this script is get the tax id, if exist just continue with next fasta
		if [  "$ti" != "" ];then
			echo "Tax Id exist, continue with next fasta"
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
	
	done < $fileout
####################		ADD ID's		##########################	
	i=1
	while read line
	do
		fasta=`echo "$line" |awk '{print $1}'`
		ti=`echo "$line" |awk '{print $2}'`
		gi=`echo "$line" |awk '{print $3}'`
		echo "working on $fasta  ($i/$total)"

		if [ "$gi" == "" ];then
			sed -i '' "s/>/>ti|$ti|/g" $fasta
		else
			sed -i '' "s/>/>ti|$ti|gi|$gi|/g" $fasta
		fi
		i=$((i+1))
		
	done < $switchfile

###################		MERGE FASTAS		############################
	#python merge.py folder_files file_out_name
	python ${EXECUTEWORKDIR}/merge.py $WORKDIR $multifname.new
	mv $multifname.new new_$multifname
	mv new_$multifname ../.
	cd ..
	rm -r TMP_FOLDER_DONT_TOUCH
else
	echo "Invalid or Missing Parameters, print --help to see the options"
	exit
fi
