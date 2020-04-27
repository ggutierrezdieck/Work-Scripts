#!/bin/csh -f

set sp=""
unset seqcounter1
if ( $#argv == 0 ) then
        	echo "what is the sequence number?"
        	set seq = $<
        	echo "what are the shot points?"
        	#This way to define the variable is to make it an array of inputs from user
        	set sp1 =  $<
        	set sp = ($sp1)
else if ( $#argv == 1 ) then
Usage: #label to jump using goto
	echo Usage:
	echo $0 "<seqnum> <sp> [-option]"
	echo "<seqnum> : sequence number on which shotpoint numbers are to be dumped"
	echo "<sp> : list of shotpoints to dump, shotpoints belongin to <seqnum>"
	echo "[-option] : option from SeismicDumper command to indicate the type of header to dume, default -R: external header"
	SeismicDumper -h
	exit
else
	foreach i ($argv)
		switch ($i)
		case -[a-zA-Z]*:
			set flag=$i
			if ( $flag == -h ) goto Usage
			breaksw
		case [0-9]* #adjust this to be case is a number
			if ($?seqcounter1 == 0 ) then
				set seq = $i
				set seqcounter1 
			else 
				set sp = ($sp $i)
			endif
			breaksw
		endsw
	end
endif
set j=1
foreach i ($sp)
	#set _indx=`grep "$seq""_$sp[$j]_3" /tmp/deletmeshdskdmp.txt | awk '{ print $1}' | grep -v "0$seq"`
	if ($?flag == 1 ) then #this if checks if flag variable exist, it will return 1 if it does exist
		SeismicDumper $flag /shdsk/data/"$seq""_$sp[$j]_"* | more
	else 
		SeismicDumper -R /shdsk/data/"$seq""_$sp[$j]_"* | more
	endif
	if ($j<$#sp) then 
		/usr/bin/echo "\nDumping next shot..."
	endif
	@ j+=1
end
