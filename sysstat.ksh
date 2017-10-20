#!/bin/ksh
# set -x
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:	sysstat
#   DATE:	Oct. 16, 2002
#   AUTHOR:	David A. Wasmer
#   PURPOSE:	Capture system stats
#
#   Syntax:
#
#   Revised:
#
#
#########|#########|#########|#########|#########|#########|#########|#########|
LOGFILE=/admin/metrics/logs/sysstat_logs/sysstat_$(hostname)_0.xls
P=300
H=$(hostname)
T="$(date +%H:%M)"
D="$(date +%m\\/%d\\/%y)"

if [ ! -f $LOGFILE ]; then
   {  print "Host	Date	Time	r	b	avm	fre	re	pi	po	fr	sr	cy	in	sy	cs	us	sy	id	wa	sr/fr	%ps_used	numperm"
   }  >>  $LOGFILE
fi

PgSp=$(lsps -s | tail -n1 | awk '{print $2}')
if [ -x /usr/samples/kernel/vmtune ] ; then
   NUMPERM=$(/usr/samples/kernel/vmtune | grep numperm | awk '{print $8}' | cut -d= -f2)
else
   NUMPERM=null
fi

VMSTAT_OUT=$(vmstat $P 2  | tail -n 1 )
FR=$(print  $VMSTAT_OUT | awk '{print $8}')
if [[ $FR -gt 0 ]]; then
   SRFR=$(print $VMSTAT_OUT | awk '{srfr = $9 / $8 ; print srfr}')
else
   SRFR=0
fi

print $VMSTAT_OUT | sed "s/^/${H}  ${D}  ${T}  /g" | sed "s/$/  ${SRFR}  $PgSp  $NUMPERM/g" | sed "s/  */	/g" >> $LOGFILE

# END
