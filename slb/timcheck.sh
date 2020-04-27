#!/bin/sh

#
#	The next script checks the status of the tim servers
#	if any server is not running in shows error and the server not running
#	to acknowledge the message press enter, to exit type exit.
#
#
#
#
until [ ${i:-d} = exit ] 	#it creates a default value for i if i is not defined
do
	sleep  2
	$var=tim status | grep "not running"
	if [ $? -eq 0 ]
		then
		banner ERROR!!
		echo $var
		read i 
	fi
done
