BOLD=$(tput bold)
REV=$(tput rev)
NORMAL=$(tput sgr0)


print "\n\n\n${BOLD}${REV}          S e r v e r    E r r o r     R e p o r t s          ${NORMAL}"
print "\n             $(date)\n\n"
CWS_ERR=$(errpt -s $(date +%m%d0000%y))
if [ -n "$CWS_ERR" ] ; then
   print "esc0001: $CWS_ERR \n"
fi
DEV_ERR=$(rsh psftdev errpt -s $(date +%m%d0000%y))
if [ -n "$DEV_ERR" ] ; then
   print "psftdev: $DEV_ERR \n"
fi

rsh iessf2n5 /usr/local/bin/clearerr

dsh errpt -s $(date +%m%d0000%y)
print ""
