#!/bin/ksh
# set -x
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:	CPU_notify
#   DATE:	    Oct 9, 2001
#   AUTHOR:	    David A Wasmer
#   PURPOSE:	Notifies when CPU is busy and provides list of hungriest processes
#
#   Syntax:
#
#   Revised:
#    10/31/01 - LHS - Revised the command used to determine the CPU hogs from ps aux
#                     to ps -ef |sort -nrk4,4.  This uses the C column values.
#    01/23/02 - LHS - Removed references to perfadmin so I stopped getting those
#                      annoying emails I can't do anything about!
#
#########|#########|#########|#########|#########|#########|#########|#########|
#set -x
.  /usr/local/qc/bin/setvariables

# CPU busy can be passed in as argument. Else it reacts as though 100% busy.
if [ $# -eq 0 ] ;then
  CPU=100
else
  CPU=$1
fi

WARN_NOTIFY="unixadmin"
CRITICAL_NOTIFY="unixadmin"
#CRITICAL_NOTIFY="unixadmin_pager"
TMP_FILE=/tmp/cpu_notify_message
DEFAULT_WARN=97
DEFAULT_CRITICAL=100

rm -f $TMP_FILE

#
#  Send "page" that critical threshold has been met
#
if [ "$CPU" -ge $DEFAULT_CRITICAL ] ; then
   print "$HOSTNAME:	The CPU is ${CPU}% busy.  This exceeds the critical threshold level of $DEFAULT_CRITICAL." | mail -s "$HOSTNAME: $SCRIPTNAME: Critial" $CRITICAL_NOTIFY
fi

#
# Send email that warning or criticial threshold has been met and CPU hog list
#
if [ "$CPU" -ge $DEFAULT_CRITICAL ] ; then
  print "$HOSTNAME:    The CPU is ${CPU}% busy.  This exceeds the critical threshold level of $DEFAULT_CRITICAL." >$TMP_FILE
elif [ "$CPU" -ge $DEFAULT_WARN ] ; then
  print "$HOSTNAME:    The CPU is ${CPU}% busy.  This exceeds the warning threshold level of $DEFAULT_WARN." >$TMP_FILE
fi
echo "" >>$TMP_FILE
echo "" >>$TMP_FILE
echo "" >>$TMP_FILE
echo " *** Top 10 busiest processes by CPU (ps -ef |sort -nrk4,4 |head -11):" >>$TMP_FILE
echo "" >>$TMP_FILE
ps -ef |sort -nrk4,4 |head -11 >>$TMP_FILE

if [ "$CPU" -ge $DEFAULT_CRITICAL ] ; then
  cat $TMP_FILE |mail -s "$HOSTNAME: $SCRIPTNAME: Critial" $WARN_NOTIFY
elif [ "$CPU" -ge $DEFAULT_WARN ] ; then
  cat $TMP_FILE |mail -s "$HOSTNAME: $SCRIPTNAME: Warning" $WARN_NOTIFY
fi

# END
