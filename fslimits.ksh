#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:		fslimits
#   DATE:               Nov. 20, 2001
#   AUTHOR:             David A. Wasmer
#   PURPOSE:		Check filesystem fullness.
#			This script is called from root's crontab.
#
#   SYNTAX:		fslimits
#
#   RELATED FILES:	fsmon
#
#   REVISIONS:
#
#
#########|#########|#########|#########|#########|#########|#########|#########|
#set -x
#set +x
if [ "$TRACE" = true ]; then
   set -x
fi

FSCHECK=/usr/local/qc/bin/fsmon

$FSCHECK  -n /             -w 80  -c 90  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /admin        -w 80  -c 95  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /apps         -w 90  -c 99  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /home         -w 80  -c 95  -m "unixadmin" -p "unixadmin_pager"
#$FSCHECK  -n /spdata       -w 98  -c 99  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /tftpboot     -w 80  -c 95  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /tmp          -w 80  -c 95  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /userdata/sp  -w 80  -c 95  -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /usr          -w 100        -m "unixadmin" -p "unixadmin_pager"
$FSCHECK  -n /var          -w 80  -c 95  -m "unixadmin" -p "unixadmin_pager"



###########################################################################################
###
###   root@iesc0001: (/)# date
###   Fri Apr 26 10:44:33 EDT 2002
###
###   root@iesc0001: (/)# df | sort -k7 | grep -v :
###   Filesystem       512-blocks      Free %Used    Iused %Iused Mounted on
###   /dev/hd4             196608     93400   53%     3816     8% /
###   /dev/adminlv         131072    124808    5%       86     1% /admin
###   /dev/appslv          655360    574512   13%     1027     2% /apps
###   /dev/hd1              32768     31480    4%       58     2% /home
###   /dev/spdata2lv_N   53084160   3758120   93%    29954     1% /spdata
###   /dev/tftplv           65536     45896   30%       32     1% /tftpboot
###   /dev/hd3             327680    311992    5%      165     1% /tmp
###   /dev/usrdtsplv_N    1638400    432320   74%    31153    16% /userdata/sp
###   /dev/hd2            3178496    199848   94%    42854    11% /usr
###   /dev/hd9var          524288    394808   25%     2120     4% /var
###
###
###########################################################################################
#
#   root@iesc0001: (/)# date
#   Tue Feb 26 16:21:08 EST 2002
#
#   root@iesc0001: (/)# df | sort -k7 | grep -v :
#   Filesystem       512-blocks      Free %Used    Iused %Iused Mounted on
#   /dev/hd4             196608     98848   50%     3810     8% /
#   /dev/adminlv         131072    124808    5%       86     1% /admin
#   /dev/appslv          655360    574512   13%     1027     2% /apps
#   /dev/hd1              32768     31480    4%       58     2% /home
#   /dev/spdata2lv_N   47251456    525112   99%    29512     1% /spdata
#   /dev/tftplv           65536     45832   31%       40     1% /tftpboot
#   /dev/hd3             327680    314560    5%      139     1% /tmp
#   /dev/usrdtsplv_N    1638400    315144   81%    31998    16% /userdata/sp
#   /dev/hd2            3178496    162328   95%    42884    11% /usr
#   /dev/hd9var          524288    395664   25%     1984     4% /var
#
###########################################################################################

##########################
#   END OF fslimits
##########################
