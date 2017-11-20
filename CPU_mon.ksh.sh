#!/bin/ksh
# set -x
# set +x
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:	CPU_mon
#   DATE:	Feb 23, 2000
#   AUTHOR:	David A. Wasmer
#   PURPOSE:	Monitors system idle column and sends notification when threshold is exceeded.
#
#   Syntax:
#
#   Revised:	10-09-01 LHS Addedd call to CPU_notify to page and/or email notification and
#                            list of top 25 process hogs by CPU and memory
#               07-26-02 LHS Modified for EB servers and to look for 5 consecutive minutes of busyness
#
#
#########|#########|#########|#########|#########|#########|#########|#########|
#set -x
.  /usr/local/qc/bin/setvariables
ITERATION=11
let LINES=$ITERATION-1
PERIOD=120

let CPU=100-$(vmstat $PERIOD  $ITERATION  | tail -n $LINES | awk '{print $16}')

/usr/local/bin/CPU_notify $CPU

# END
