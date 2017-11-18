#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|

#
#   FILENAME:   /usr/local/bin/mkprinter
#   DATE:       Jan. 13, 2000
#   AUTHOR:     David A. Wasmer
#   PURPOSE:    Create new printer using default values
#
#   Syntax:     /usr/local/bin/mkprinter -? 
#
#   Revised:
#
#
#########|#########|#########|#########|#########|#########|#########|#########|
#set -x
#set +x

##############################
#   HELP FUNCTION
##############################
function FUNC_HELP
{
print "
    $(tput rev)   USAGE:                                                                      $(tput sgr0)
    mkprinter  [ -a Address ] [ -q Queue ] [ -m Model ] [ -b BU ] [ -c Contact ]

               -a   Enter the IP address of printer
               -q   Enter the Queue name for the printer
               -b   Enter the Business Unit name who will use this printer
               -c   Enter a Contact phone number near the printer
                    "
exit 0
}


##############################
#   PROCESS FILE FUNCTION
##############################
function PROCESSFILE
{
while read ADDRESS QUEUE MODEL ; do
   print "\nAbout to process the printer $(tput rev) ${QUEUE} $(tput sgr0) \c"
   print "at $(tput rev) ${ADDRESS} $(tput sgr0) using the $(tput rev) ${MODEL} $(tput sgr0) drivers."
   if [[ "$(grep $QUEUE /etc/hosts)" = "$(grep $ADDRESS /etc/hosts)" && "$(grep $QUEUE /etc/hosts | wc -l)" -eq 1 ]]; then
      print "   IP and Queue entries match in the hosts file and only one entry exists. Continuing..."
   else
      print "ERROR: IP and Queue are NOT equal"
   fi

   if lpstat -p$QUEUE > /dev/null 2>&1; then
      print "\nERROR: Queue $QUEUE already exists.\nExiting...\n"
      exit
   fi

   print "   Verified that Queue $QUEUE does not already exist.  Continuing..."
   case $MODEL in
        lexOptraN	)    MODEL=lexOptraN   ;;
        lex4049		)    MODEL=lex4049     ;;
	hplj-2		)    MODEL=hplj-2      ;;
	hplj-3		)    MODEL=hplj-3      ;;
	hplj-3si	)    MODEL=hplj-3si    ;;
	hplj-4		)    MODEL=hplj-4      ;;
	hplj-4si	)    MODEL=hplj-4si    ;;
	hplj-4v		)    MODEL=hplj-4v     ;;
        hplj-5si	)    MODEL=hplj-5si    ;;
        hplj-c		)    MODEL=hplj-c      ;;
        *		)    MODEL=BAD	       ;;
   esac

   if [[ "$MODEL" = BAD ]]; then
      print "\n\n\nERROR:   The print model, $MODEL, is not recognized.  Please rexamine the model selected"
      print "and either change it or add it to the case statement in the mkprinter script.\n\n"
      exit
   fi

   print "   Creating queue ..."
  /usr/lib/lpd/pio/etc/piomkjetd mkpq_jetdirect -p $MODEL -D pcl -q $QUEUE -h $QUEUE -x '9100'

   print "   Changing virtual printer attributes..."
  /usr/lib/lpd/pio/etc/piochpq  -q $QUEUE -d hp@$QUEUE -l 180 -w 180 -d p -j 0 -J '!' -Z '!'

   print "   Sending test page to printer ..."
  /usr/local/bin/qtest $QUEUE
done
}



##############################
#   MAIN
##############################
while getopts "a:m:q:f:h" OPTION; do
   case $OPTION in
	a ) ADDRESS="$OPTARG"		;;
	m ) MODEL="$OPTARG" 		;;
	q ) QUEUE="$OPTARG"		;;
        f ) FILE="$OPTARG"     		;;
	f ) FUNC_HELP ; exit 0          ;;
        ? ) FUNC_HELP ; exit 0          ;;
	* ) FUNC_HELP ; exit 0		;;
   esac
done
shift $(($OPTIND - 1))

if [[ ! -z "${ADDRESS}${MODEL}${QUEUE}" &&  ! -z "${FILE}" ]]; then
   print "\nERROR: cannot accept command line input and read input from a file at same time.\n"
   FUNC_HELP
fi

if [[ ! -z "${FILE}" ]]; then
   cat $FILE | PROCESSFILE
else
   MODEL=${MODEL:=hplj-5si}
   ADDRESS=${ADDRESS:=$(host $QUEUE | awk '{print $3}')}
   print "\nAddress = $ADDRESS\n\nQueue = $QUEUE\n\nModel = $MODEL\n"
   sleep 5
   print "$ADDRESS $QUEUE $MODEL" | PROCESSFILE
fi

###############
#  END
##########
