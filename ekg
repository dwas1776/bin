#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:   ekg
#   DATE:       April 14, 2000
#   AUTHOR:     David A. Wasmer
#   PURPOSE:    Check that servers are alive by first trying to ping them
#               and then trying to rsh the date command to them.
#
#   SYNTAX:     ekg
#
#   REVISIONS:
#
#########|#########|#########|#########|#########|#########|#########|#########|
if [ "$TRACE" = true ]; then
       set -x
fi

CRITICALMAIL="unixadmin_pager"
WARNMAIL="unixadmin"

NICS="
	iesc0001
	esc0001
	iessf1n1
	iessf1n3
	iessf1n5
	iessf1n7
	iessf1n9
	iessf1n11
	iessf1n13
	essf1n1
	essf1n3
	essf1n5
	essf1n7
	essf1n9
	essf1n11
	essf1n13
	iessf2n1
	psftprod
	iessf2n5
	psfthan
	psftdev
	resumix
	orapms
"
for PATIENT in $NICS ; do
   if grep -v ^# /etc/qclist | grep -q $PATIENT ; then
      if ping -c 1 $PATIENT > /dev/null  2>&1 ; then
         PING=true
      else
         sleep 15
         if ping -c 3 $PATIENT > /dev/null  2>&1 ; then
            print "$TIME $DATE - HOSTNAME: $SCRIPTNAME: first ping test to $PATIENT failed, but second ping succeeded." | mail -s "$PATIENT: 1st ping failed" $WARNMAIL
            PING=true
         else
            print "$PATIENT is not reachable from $(hostname) on $(date)." | mail -s "$PATIENT: not reachable" $CRITICALMAIL
            PING=false
         fi
      fi

      if [ "$PING" = true ]; then
            if rsh $PATIENT date  > /dev/null  2>&1 ; then
               :
            else
               print "$PATIENT did not return rsh request from $(hostname) on $(date)." | mail -s "$PATIENT: not responding " $CRITICALMAIL
            fi
      fi
   fi
done

######################
#   END OF ekg
######################
