#!/bin/ksh
#set -x
#set +x
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:		errotd
#   DATE:		Jan. 28, 2004
#   AUTHOR:		David A. Wasmer
#   PURPOSE:
#
#   SYNTAX:
#
#   REVISIONS:
#
#
#########|#########|#########|#########|#########|#########|#########|#########|

function FUNC_HELP
{
   print "
        ${REV}USAGE:                                                               $NORM

        errotd [ date ]
               date is given in two digit month/date/year format as in
               errotd 01-28-04

"
exit 0
}

ARG=$1
MONTH="$(print $ARG | cut -d/ -f1)"
DAY="$(print $ARG | cut -d/ -f2)"
YEAR="$(print $ARG | cut -d/ -f3)"

#errpt -s $(date +"%m%d0000%y")
errpt -s ${MONTH}${DAY}0000${YEAR}

# END
