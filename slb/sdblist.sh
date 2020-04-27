#!/bin/sh

echo "No of SP\tSeqNo\tData Type"
ls /shdsk/data | \
awk 'BEGIN{FS="_"; OFS=" "} \
	 { if ($3==1) {print "\t\t" $1,"\tSS_RAW"} \
      else if ($3==2) {print "\t\t" $1,"\tSS_FILT"} \
      else if ($3==3) {print "\t\t" $1,"\tDEC_FILT"} \
      else if ($3==4) {print "\t\t" $1,"\tWAVE_HEIGHT"} \
      else if ($3==5) {print "\t\t" $1,"\tAF"} \
      else if ($3==6) {print "\t\t" $1,"\tDGF/NFH"} \
}' | sort | uniq -c

