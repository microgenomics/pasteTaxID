BEGIN{FS="|"}
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
}