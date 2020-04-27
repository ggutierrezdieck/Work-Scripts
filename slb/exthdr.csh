#!/bin/csh -f

whatsonBuffer.sh -format cols

echo "what is the sequence number?"
set _seqno = $<
echo "what are the shot points?"
set _sp1 =  $< 
set _sp = ($_sp1)
set i=1
while($#_sp >= $i)
	set _dsk=`eval grep -w  "$_seqno" /triacq/onshdsk.txt | grep -w "$_sp[$i]" | grep -w 3 | cut -c4-11`
	set _file=`eval grep -w  "$_seqno" /triacq/onshdsk.txt | grep -w "$_sp[$i]" | grep -w 3 | cut -c18-23`
	#set _pth[$i]="$_dsk/$_file"
	#echo $_pth
	SeismicDumper -R $_dsk/$_file
	read
	@ i+=1
end

# Things to do: 
# 1.- Find a way to imput the data as a flag
# 2.- Create the loop for use several shotpoints
# 3.- Create the conditionals for separating bad shots from good shots
