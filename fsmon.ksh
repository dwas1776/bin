#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:   fsmon
#   DATE:       Sept. 12, 2000
#   AUTHOR:     David Wasmer
#   PURPOSE:    Test a filesystem fullness against specified thresholds.
#		If the lower threshold is exceeded, the script sends out
#		email(s) to the Warning Mail List.  If the upper
#		threshold is exceeded, the script sends out email(s)
#		to the Critical Mail List.
#
#   Syntax:     fsmon
#
#		FTEST function options:
#			-n Filesystem Name
#			-w Warning Threshold
#			-m Mail List for exceeding Warning Threshold
#			-c Critical Threshold
#			-p Mail List for exceeding Critical Threshold
#
#   Revised:
#
#
#########|#########|#########|#########|#########|#########|#########|#########|
while getopts "n:w:m:c:p:" OPTION; do
      case $OPTION in
           n ) FS_NAME="$OPTARG"             ;;
           w ) WARN_THRESHOLD=${OPTARG}      ;;
           m ) WARNLIST=${OPTARG}            ;;
           c ) CRITICAL_THRESHOLD=${OPTARG}  ;;
           p ) CRITLIST=${OPTARG}            ;;
           * ) FUNC_HELP ; exit 0            ;;
       esac
done
shift $(($OPTIND - 1))
if [ "$TRACE" = true ]; then
   set -x
fi

.  /usr/local/qc/bin/setvariables logfile

case $OS in
     AIX   ) FS_USED=$(df -k $FS_NAME | tail -1 | awk '{print $4}' | cut -d % -f 1) ;;
     HP-UX ) FS_USED=$(df -P $FS_NAME | tail -1 | awk '{print $5}' | cut -d % -f 1) ;;
     OSF1  ) FS_USED=$(df -k $FS_NAME | tail -1 | awk '{print $5}' | cut -d % -f 1) ;;
     SunOS ) FS_USED=$(df -k $FS_NAME | tail -1 | awk '{print $5}' | cut -d % -f 1) ;;
      *    ) print "OS not recognized" ; exit  ;;
esac

SEVERITY=
MAILLIST=
THRESHOLD=

if [[ -n "$CRITICAL_THRESHOLD" && "$FS_USED" -ge "$CRITICAL_THRESHOLD" ]]; then
      SEVERITY=CRITICAL
      MAILLIST=$CRITLIST
      THRESHOLD=$CRITICAL_THRESHOLD
elif [ $FS_USED -ge "$WARN_THRESHOLD" ]; then
      SEVERITY=WARNING
      MAILLIST=$WARNLIST
      THRESHOLD=$WARN_THRESHOLD
fi

if [ -n "$SEVERITY" ] ; then
      BODYTEXT="The ${HOSTNAME}:${FS_NAME} filesystem is ${FS_USED}% used. \
               \nThis exceeds the $SEVERITY threshold of ${THRESHOLD}%. \
               \nTime: $TIME, $DATE."
      print "SEVERITY: $BODYTEXT" | mailx -s "${SEVERITY}   ${HOSTNAME}:${FS_NAME} is ${FS_USED}% full" $MAILLIST
fi

########################
#  END OF fsmon
########################
