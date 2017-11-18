#!/user/bin/ksh
# set -x
# set +x
#####################################################################
# NAME:
#   errpt_yesterday.ksh
#
# SYNOPSIS:
#
# REVISIONS:
#
#####################################################################
BOLD=$(tput bold)
REV=$(tput rev)
NORMAL=$(tput sgr0)

TODAY=$(date +%d)
if [ $TODAY -ne 1 ]; then
   let YESTERDAY=$TODAY-1
   if [ $YESTERDAY -lt 10 ]; then
      YESTERDAY=0$YESTERDAY
   fi
   print "\n\n\n${BOLD}${REV}          S e r v e r    E r r o r     R e p o r t s          ${NORMAL}"
   print "\n             Yesterday's Errors\n\n"
   CWS_ERR=$(errpt -s $(date +%m${YESTERDAY}0000%y))
   if [ -n "$CWS_ERR" ] ; then
      print "esc0001: $CWS_ERR \n"
   fi
   DEV_ERR=$(rsh psftdev errpt -s $(date +%m${YESTERDAY}0000%y))
   if [ -n "$DEV_ERR" ] ; then
      print "psftdev: $DEV_ERR \n"
   fi
   dsh errpt -s $(date +%m${YESTERDAY}0000%y)
   print ""
else
   print "New month, you must run manually"
   let LASTMONTH=$(date +%m)-1
   print "dsh errpt -s \$(date +%${LASTMONTH}[last day of month]0000%y"
fi
