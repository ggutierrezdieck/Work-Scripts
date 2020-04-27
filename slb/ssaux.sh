#!/bin/sh -x
      
awkfun() {
	awk '
	{
		if ( (substr($3,1,1) == '$1') ){ 
			rec = 1 
		}
		if ( rec ) {
			if ( substr($3,1,1) != '$1' ) {
				rec = 0
			}
			print $1,$5,$9 
		}
	}
	'
}
	i=1
	while [ $i -le  10 ]
	do
		less aux_serial_number.txt | awkfun $i
	i=`expr $i + 1`
	done
