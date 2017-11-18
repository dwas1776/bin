#!/bin/ksh
#set -x
#set +x
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:	/maint/bin/
#   DATE:	, 1999
#   AUTHOR:	David A. Wasmer
#   PURPOSE:
#
#   Syntax:
#
#   Revised:
#
#
#########|#########|#########|#########|#########|#########|#########|#########|

OUTFILE=/tmp/client_clinfo
COUNTER=1
if [ ! -f "$OUTFILE" ]; then
   touch $OUTFILE
fi

(date
print "COUNTER = $COUNTER"
arp -a
print "label = $label\n\n\n"
) > $OUTFILE

COUNTER=$(expr $COUNTER + 1)
