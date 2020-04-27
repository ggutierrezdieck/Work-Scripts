#!/bin/sh

#
# This script displays the content of whats on the SharedDataBuffer.  It
# should only be used as part of a Marine deployment.
#
# IMPORTANT: If the type, number, or ordering of attributes written to the
#    IndexServer for each shot by recording is changed, this script will need 
#    to be updated. At a minimun, the values of "FormatStr" and "HdrFormatStr"
#    will need to be updated.
#    
#
# Usage: whatsonBuffer [-help] [-cfgFile <config_file>] [-format cols|brief|csv] [-file <output_file>]
#     
#     where: <config_file>   is the IndexServer configuration file
#            cols|brief|csv  is optional argument to state whether a complete listing in
#                            formatted columns, a brief/summary listing,  or the raw csv 
#                            listing is required.  Default is for brief output format.
#            <output_file>   name of file to send output to.
#            -help           displays help info.

#################
# Function to display usage information
#
usage()
{
    echo 1>&2 Usage: $0 \[-help\] \[-cfgFile \<config_file\>\] \[-format cols \| brief \| csv \] \[-file \<output_file\>\]
    echo 1>&2 ""
    echo 1>&2 options:
    echo 1>&2 "   " \[-help\]: displays this help info.  
    echo 1>&2 "   " \[-cfgFile \<config_file\>\]: the IndexServer configuration file 
    echo 1>&2 "             "\(default: /shdsk01/IndexServer.cfg\)
    echo 1>&2 "   " \[-format cols \| brief \| csv \]: optional argument to state whether a
    echo 1>&2 "             "complete listing in formatted columns, a brief/summary listing, or
    echo 1>&2 "             "the raw csv listing is required. \(default: brief\)
    echo 1>&2 "   " \[-file \<output_file\> \]: send output to file filename
    echo 1>&2 "             "\(default: /triacq/onshdsk.txt\)
    
}

#################
# Function to display the CSV output from sdbList as formatted columns
#
columnprint()
{
    sort -t , -n +3 $1 | nawk -F , 'BEGIN { FormatStr = "%12s %10d %5d %17.4f %5d %20s %6d %6d %5d %6d %6d\n";
                                            HdrFormatStr ="%12s %10s %5s %17s %5s %20s %6s %6s %5s %6s %6s\n"} 
    $1 ~ /^\/shdsk/ { printf FormatStr, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11 }
    $1 ~ /LOCATION/ { printf HdrFormatStr, "LOCATION","INDEX", "SType", "STime","SeqNr","LName","SPNum","FNum","DType","SDType","LPShot" }
END { } '
}

#################
# Strip location and index from lines
#
stripLocation()
{
    nawk 'BEGIN { FormatStr = "%5d %17.4f %5d %20s %6d %6d %5d %6d %6d\n";
                  HdrFormatStr ="%5s %17s %5s %20s %6s %6s %5s %6s %6s\n" }
    $1 ~ /LOCATION/   { printf HdrFormatStr, "SType", "STime","SeqNr","LName","SPNum","FNum","DType","SDType","LPShot" }
    $1 ~ /shdsk/      { printf FormatStr, $3, $4, $5, $6, $7, $8, $9, $10, $11 } 
    END { }'
}

#################
# Function to display the sequence summary information.  The input to
# this function is expected to be the output from columnprint()
#
summaryprint()
{
    nawk 'BEGIN { SequenceNr_Last="" ; ShotType_Last="" }
    $1 ~ /SType/      { print $0 }
    $1 ~ /([0-9]+)/   { SequenceNr=$3 ; ShotType=$1
                        if ( SequenceNr != SequenceNr_Last )
                        { if ( LastLine != "")
                          { 
                             print LastLine
                          }
                          print "-------------------------------------------------------------------------------------"
                          FirstLine=$0
                          print FirstLine
                          SequenceNr_Last=SequenceNr
                          ShotType_Last=ShotType
                          LastLine=$0
                          next
                        }
                        if ( ShotType != ShotType_Last )
                        { print LastLine
                          FirstLine=$0
                          print FirstLine
                          SequenceNr_Last=SequenceNr
                          ShotType_Last=ShotType
                          LastLine=$0
                          next
                        }
                        LastLine=$0
                      }
END { print LastLine }'
}


#################
# main prog
#

#################
# set defaults for config file and output format
#
CFG_FILE="/shdsk01/IndexServer.cfg"
FORMAT=brief
OUT_FILE="/triacq/onshdsk.txt"

#################
# process command line args - limited checking
#
while [ $# -ge 1 ]; do
   case $1 in
       -help)    usage 
                 exit
                 ;;
       -cfgFile) CFG_FILE="$2";
                 if [ "$CFG_FILE" = "" ]; then 
                    usage
                    exit 127
                 fi;
                 shift; shift
                 ;;
       -format)  case $2 in
                    cols|brief|csv) FORMAT="$2" ;
                                    shift; shift
                                    ;;
                    *)              usage;
                                    exit 127 
                                    ;;
                 esac
                 ;;
       -file)    OUT_FILE="$2";
                 if [ "$OUT_FILE" = "" ]; then 
                    usage
                    exit 127
                 fi;
                 shift; shift
                 ;;                 
       *)        echo Unknown arguments: $1
                 echo
                 usage;
                 exit 127 
                 ;;
   esac
done

echo Using IndexServer configuration file: $CFG_FILE

touch $OUT_FILE 2> /dev/null
if [ ! -f $OUT_FILE ]; then
   echo "Unable to write to " $OUT_FILE
   echo "Operation Aborted"
   exit 127
fi

echo Output will be written to file: $OUT_FILE
echo Output format will be: $FORMAT

##################################
# delete the previous listing file
#
\rm -f $OUT_FILE

#################
# produce the listing
#
case "$FORMAT" in
     csv)    sdbList -cfgFile $CFG_FILE > $OUT_FILE
             ;;
     cols)   sdbList -cfgFile $CFG_FILE | columnprint > $OUT_FILE
             ;;
     brief)  sdbList -cfgFile $CFG_FILE | columnprint | stripLocation | summaryprint > $OUT_FILE
             ;;
     *)      echo "Unknown format:" $FORMAT;
             usage;
             ;;               
esac

exit 0

##+- OmniWorks Replacement History - tim`sbuffer`scripts:whatsonBuffer.sh;7 
##       7*[226860] 18-APR-2007 15:14:35 (GMT) friel 
##         "Upd with file output option" 
##       6*[221511] 20-NOV-2006 07:48:18 (GMT) friel 
##         "add default behaviour" 
##       5*[221163] 09-NOV-2006 08:54:36 (GMT) friel 
##         "Submit new script implementation" 
##       4*[221162] 08-NOV-2006 14:53:07 (GMT) friel 
##         "Undeleted" 
##       3*[203257] 17-JAN-2006 14:30:29 (GMT) friel 
##         "Deleted" 
##       2*[195256] 24-JUN-2005 12:27:11 (GMT) friel 
##         "fix header display bug" 
##       1*[191068] 19-JAN-2005 12:54:32 (GMT) SuperUser 
##         "Initial create after omniworks crash" 
##+- OmniWorks Replacement History - tim`sbuffer`scripts:whatsonBuffer.sh;7 
