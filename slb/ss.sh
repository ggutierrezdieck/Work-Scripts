#!/bin/sh 
      
awkfun() {
	awk '
	{
		if ( (substr($1,1) == "Streamer")&&(substr($2,1) == '$1') ){ 
			rec = 1 
		}
		if ( rec ) {
			if ( (substr($1,1) == "Streamer")&&(substr($2,1) != '$1') ) {
				rec = 0
			}
			else { print $2,$3 > "Streamer'$1'.csv"}
		}
	}
	'
}
	i=1
	while [ $i -le  10 ]
	do
		less serialnumber.txt | awkfun $i
	i=`expr $i + 1`
	done
