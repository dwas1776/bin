#!/bin/ksh
# set -x
# set +x
#####################################################################
# NAME:
#   aix_collect.ksh
#
# SYNOPSIS:
#   gather system setting information
#
# DESCRIPTION:
#
#
#####################################################################
# REVISIONS:
#
#
#####################################################################
exit 0
File=/tmp/aix.collect.out
Name=$(hostname)
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo  "##############################################################################*\n\n" >>$File
echo "\n--> uname -a \n"		>> $File
uname -a		>> $File
echo "\n--> uname -M \n"		>> $File
uname -M 		>> $File
echo "\n--> oslevel \n"		>> $File
oslevel			>> $File
echo "\n--> oslevel -r \n"	>> $File
oslevel -r		>> $File
echo "################################################################################\n"	>> $File

echo "\n\n###### Last Reboot ######\n"		>> $File
echo "\n--> who -b \n" 			>> $File
who -b 			>> $File
echo "################################################################################\n"	>> $File

echo "\n\n###### Environment variables ######\n"		>> $File
echo "\n--> env \n"				>> $File
env				>> $File

File=$Name-error-report-a
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### error report info -a ######\n"		>> $File
echo "\n--> errpt -a \n"			>> $File
errpt -a			>> $File

echo "################################################################################\n"	>> $File
File=$Name-error-report
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### error report info ######\n"		>> $File
echo "\n--> errpt \n"			>> $File
errpt 			>> $File
echo "################################################################################\n"	>> $File

File=$Name-physical-volume-info
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" 	>$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
echo  "###############################################################################\n\n" 	>>$File
echo "\n### lspv ###" 						>> $File
echo "\n--> lspv \n" 	>> $File
lspv 			>> $File  	2>> $File
echo  "###############################################################################\n\n" 	>>$File

File=$Name-physical-vol-to-filesystem-info
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" 	>$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
echo  "###############################################################################\n\n" 	>>$File
for i in `lspv |grep power |cut -c0-14`
do
	echo "\n###$i:###"                >> $File
	echo "\n--> lspv -l $i \n"        >> $File
	lspv -l $i                        >> $File
	echo "###end of $i###"            >> $File
done
echo "#################################################################################\n\n"     >> $File

File=$Name-powerpath-info
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" 	>$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
echo  "###############################################################################\n\n" 	>>$File
echo "\n### powermt display ###" 						>> $File
echo "\n--> powermt display \n" 	>> $File
powermt display 			>> $File  	2>> $File
echo  "###############################################################################\n\n" 	>>$File
echo "\n### powermt display dev=all ###" 						>> $File
echo "\n--> powermt display dev=all \n" 	>> $File
powermt display dev=all 			>> $File  	2>> $File
echo  "###############################################################################\n\n" 	>>$File
echo "\n### powermt display paths ###" 						>> $File
echo "\n--> powermt display paths \n" 	>> $File
powermt display paths 			>> $File  	2>> $File
echo  "###############################################################################\n\n" 	>>$File
echo "\n### powermt display ports ###" 						>> $File
echo "\n--> powermt display ports \n" 	>> $File
powermt display ports 			>> $File  	2>> $File
echo  "###############################################################################\n\n" 	>>$File

File=$Name-bootlog
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### boot log info ######\n"		>> $File
echo "\n--> alog -of /var/adm/ras/bootlog \n"		>> $File
alog -of /var/adm/ras/bootlog 		>> $File
echo "################################################################################\n"	>> $File

File=$Name-consolelog
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### console log info ######\n"		>> $File
echo "\n--> alog -of /var/adm/ras/conslog \n"		>> $File
alog -of /var/adm/ras/conslog 		>> $File
echo "################################################################################\n"	>> $File

File=$Name-software
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### Software ######\n"	>> $File
echo "\n--> lslpp -L \n"		>> $File
lslpp -L 		>> $File
echo "################################################################################\n"	>> $File

File=$Name-configuration-info
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### configuration info ######" >> $File
echo "\n--> lscfg -v 	\n"	>> $File
lscfg -v 		>> $File
echo "################################################################################\n"	>> $File

File=$Name-sp-adapter-driver-info
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### SCSI info ######" >> $File
echo "\n--> lsdev -Cs SCSI \n" >> $File
lsdev -Cs SCSI >> $File
echo "\n\n###### sp info ######" >> $File
lsdev -Cc array		>> $File
for a in `lsdev -Cc array | cut -d " " -f 1`
do
	echo "\n" $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "################################################################################\n"	>> $File

echo "\n\n###### fchan adapter info ######" >> $File
echo "\n--> lsdev -Cc adapter \n">> $File
lsdev -Cc adapter | grep fchan |grep -v "\."		>> $File
for a in `lsdev -Cc adapter | grep fchan | grep -v "\." | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "################################################################################\n"	>> $File
#
# ### this section added 10/23/02 ###
#
echo "\n\n###### fclar adapter info ######" >> $File
echo "\n--> lsdev -Cc adapter \n">> $File
lsdev -Cc adapter | grep fclar |grep -v "\."		>> $File
for a in `lsdev -Cc adapter | grep fclar | grep -v "\." | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "################################################################################\n"	>> $File
#
# ### this section added 10/23/02 ###
#
echo "\n\n###### fcs adapter info ######" >> $File
echo "\n--> lsdev -Cc adapter \n">> $File
lsdev -Cc adapter | grep fcs |grep -v "\."		>> $File
for a in `lsdev -Cc adapter | grep fcs | grep -v "\." | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "################################################################################\n"	>> $File

echo "\n\n###### driver info ######" >> $File
echo "--> lsdev -Cc driver \n"		>> $File
lsdev -Cc driver		>> $File
for a in `lsdev -Cc driver | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n" 	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "################################################################################\n"	>> $File

INT=`lsdev -Ccdriver | grep 'atf' | awk '{print $1}'`
for INC in $INT
do
	echo "\n--> /usr/sbin/atf/atfi -d $INC -p \n" >> $File
	/usr/sbin/atf/atfi -d $INC -p >> $File 2>> $File
done
echo "################################################################################\n"	>> $File

File=$Name-HBA-driver-trace-info
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### fchandd info ######" >> $File

INT=`lsdev -Cc adapter | grep 'fchan' | grep -v 'fchan[0-9]\.' | awk '{print $1}'`
for INC in $INT
do
	echo "\n--> /usr/sbin/fcsport -d $INC \n">> $File
	/usr/sbin/fcsport -d $INC >> $File 2>/dev/null
done

echo "\n--> /usr/sbin/fcsinfo  \n">> $File
/usr/sbin/fcsinfo  >> $File 2> /dev/null
echo "\n--> /usr/sbin/fcsinfo -v -v -t\n"  >> $File
/usr/sbin/fcsinfo -v -v -t >> $File 2>/dev/null
echo "################################################################################\n"	>> $File
#
# ### this section added 10/23/02 ###
#
echo "\n\n###### fclardd info ######" >> $File

INT=`lsdev -Cc adapter | grep 'fclar' | grep -v 'fclar[0-9]\.' | awk '{print $1}'`
for INC in $INT
do
	echo "\n--> /usr/sbin/fcsport -d $INC \n">> $File
	/usr/sbin/fcsport -d $INC >> $File 2>/dev/null
done

echo "\n--> /usr/sbin/fcsinfo  \n">> $File
/usr/sbin/fcsinfo  >> $File 2> /dev/null
echo "\n--> /usr/sbin/fcsinfo -v -v -t\n"  >> $File
/usr/sbin/fcsinfo -v -v -t >> $File 2>/dev/null
echo "################################################################################\n"	>> $File
#
# ### this section added 10/23/02 ###
#
echo "\n\n###### fcsdd info ######" >> $File

INT=`lsdev -Cc adapter | grep 'fcs' | grep -v 'fcs[0-9]\.' | awk '{print $1}'`
for INC in $INT
do
	echo "\n--> /usr/sbin/fcsport -d $INC \n">> $File
	/usr/sbin/fcsport -d $INC >> $File 2>/dev/null
done

echo "\n--> /usr/sbin/fcsinfo  \n">> $File
/usr/sbin/fcsinfo  >> $File 2> /dev/null
echo "\n--> /usr/sbin/fcsinfo -v -v -t\n"  >> $File
/usr/sbin/fcsinfo -v -v -t >> $File 2>/dev/null
echo "################################################################################\n"	>> $File

File=$Name-disks
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### Disks ######\n"	>> $File
echo "\n--> lsdev -Cc disk \n"		>> $File
lsdev -Cc disk				>> $File
echo "#################################################################################\n"	>> $File

echo "\n\n###### Physical Disks ######\n">> $File
for a in `lsdev -Cc disk |cut -d " " -f 1`
do
	echo "\n ### $a ###"			>> $File
	echo "\n--> lsattr -El $a\n"		>> $File
	lsattr -El $a		>> $File	2>> $File
done
echo "################################################################################\n"	>> $File

File=$Name-volume-groups
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### Volume Groups ######\n"	>> $File

echo "\n--> lsvg\n"				>> $File
lsvg				>> $File

for i in `lsvg`
do
	echo "\n ### $i: ###"		>> $File
	echo "\n--> lsvg -l $i \n"	>> $File  	2>> $File
	lsvg -l $i 	>> $File  	2>> $File
	echo "### end of $i ###"	>> $File
done
echo "################################################################################\n"	>> $File

File=$Name-logical-volumes
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### Logical Volumes ######\n "	>> $File
for i in `lsvg`
do
	echo "\n ### $i: ###"		>> $File
	echo "\n--> lsvg $i -l"		>> $File
	lsvg $i -l			>> $File

	for a in `lsvg -l $i 2>> $File | cut -d " " -f 1 | grep -v ":"`
	do
          if [ "LV" != $a ]
          then
		echo "\n--> lslv $a\n"			>> $File
		lslv $a			>> $File	2>> $File
          fi
	done
	echo "### end of $i ###"	>> $File
done

echo "################################################################################\n"	>> $File

File=$Name-file-systems
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
echo "\n\n###### Mounted devices ######\n"	>> $File
echo "\n--> mount\n"			>> $File
mount			>> $File
echo "################################################################################\n"	>> $File

echo "\n\n###### Filesystems ######\n"	>> $File
lsfs					>> $File
echo "\n"				>> $File
echo "\n--> cat /etc/filesystems\n"			>> $File
cat /etc/filesystems			>> $File
echo "################################################################################\n"	>> $File

echo "\n\n###### File System Usage ######\n"	>> $File
echo "\n--> df -k\n"				>> $File
df -k				>> $File
echo "################################################################################\n"	>> $File

if [ -s /tmp/hacmp.out ]
then
	File=$Name-hacmp-file
	echo "\n$File..."
	echo  "\n\n###############################################################################\n\n" >$File
	echo  "######### Information listing for `uname -n` as of `date` #########\n\n" >>$File
	echo "\n\n###### Mounted devices ######\n"	>> $File
	echo "\n--> cat /tmp/hacmp.out\n"		>> $File
	cat /tmp/hacmp.out				>> $File
	echo "################################################################################\n"	>> $File
fi

File=$Name-navi-agent-config
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 		>>$File
echo  "###############################################################################\n\n" 	>>$File
echo "\n\n###### Navisphere Agent Config File ######\n" >> $File
echo "\n--> cat /etc/Navisphere/agent.config \n" 	>> $File
cat /etc/Navisphere/agent.config 			>> $File
echo "################################################################################\n"	>> $File

File=$Name-navi-agent-log
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 		>>$File
echo  "###############################################################################\n\n" 	>>$File
echo "\n\n###### Agent log info ######\n"	>> $File
echo "\n--> cat /etc/log/agent.log \n"		>> $File
cat /etc/log/agent.log 				>> $File
echo "\n--> cat /etc/logagent.log \n"		>> $File
cat /etc/logagent.log 				>> $File
echo "################################################################################\n"	>> $File

File=$Name-navi-getagent
echo "\n$File..."
echo  "\n\n###############################################################################\n\n" >$File
echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 		>>$File
echo  "###############################################################################\n\n" 	>>$File
echo "\n\n###### navicli getagent ######\n" 	 >> $File

# navi commands are different for FC4700
case $fc4700array in
y|Y)
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n"			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n\n###### navicli agent information ######\n"  			>> $File
     if [ -s $spaerrorFile -a -s $spberrorFile ]
     then
	echo "\n Netiher SP is responding so no information \n"		>> $File
     else
        if [ ! -s $spaerrorFile ]
        then
           echo "\n### getagent info for $spaIP###" 					>> $File
           echo "\n--> /usr/bin/navicli -h $spaIP getagent \n" 	>> $File
           /usr/bin/navicli -h $spaIP getagent 			>> $File 	2>> $File
           echo "################################################################################\n"		>> $File
        fi

        if [ ! -s $spberrorFile ]
        then
           echo "\n### getagent info for $spbIP###" 					>> $File
           echo "\n--> /usr/bin/navicli -h $spbIP getagent \n" 	>> $File
           /usr/bin/navicli -h $spbIP getagent 			>> $File 	2>> $File
           echo "################################################################################\n"		>> $File
        fi
     fi

     echo "################################################################################\n"	>> $File

     File=$Name-navicli-$spaIP-SP-log-info
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n"			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n\n###### navicli SP log information ######\n"  			>> $File

     if [ ! -s $spaerrorFile ]
     then
        echo "\n$File...  this may take a little while to collect..."
        echo "\n### logs for $spaIP###" 					>> $File
        echo "\n--> /usr/bin/navicli -h $spaIP getlog \n" 	>> $File
        /usr/bin/navicli -h $spaIP getlog 			>> $File 	2>> $File
        echo "################################################################################\n"		>> $File
     else
        echo "\nSP $spaIP does not respond so no information\n"		>>$File
     fi

     File=$Name-navicli-$spbIP-SP-log-info
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n"			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n\n###### navicli SP log information ######\n"  			>> $File
     if [ ! -s $spberrorFile ]
     then
        echo "\n$File...  this may take a little while to collect..."
        echo "\n### logs for $spbIP###" 					>> $File
        echo "\n--> /usr/bin/navicli -h $spbIP getlog \n" 	>> $File
        /usr/bin/navicli -h $spbIP getlog 			>> $File 	2>> $File
        echo "################################################################################\n"		>> $File
     else
        echo "\nSP $spbIP does not respond so no information\n"		>>$File
     fi

     File=$Name-navicli-LUN-info
     echo "\n$File..."
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n### LUNs ###" 						>> $File

     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP getlun \n" 	>> $File
        /usr/bin/navicli -h $spIP getlun 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi

     echo "################################################################################\n"		>> $File

     File=$Name-navicli-LUN-summary-info
     echo "\n$File..."
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n### LUNs ###" 						>> $File

     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP getlun -rg -type -default -owner -crus -capacity\n" 	>> $File
        /usr/bin/navicli -h $spIP getlun -rg -type -default -owner -crus -capacity		>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi

     echo "################################################################################\n"		>> $File

     File=$Name-navicli-CRU-info
     echo "\n$File..."
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n### CRU info ###" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP getcrus \n" 	>> $File
        /usr/bin/navicli -h $spIP getcrus 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "################################################################################\n"		>> $File

     File=$Name-navicli-port-all-info
     echo "\n$File..."
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n### ports ###" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP port -list -all \n" 	>> $File
        /usr/bin/navicli -h $spIP port -list -all 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "################################################################################\n"		>> $File

     File=$Name-navicli-port-info
     echo "\n$File..."
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n### ports ###" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP port -list \n" 	>> $File
        /usr/bin/navicli -h $spIP port -list  			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "################################################################################\n"		>> $File

     File=$Name-navicli-storagegroup-info
     echo "\n$File..."
     echo  "\n\n###############################################################################\n\n" 	>$File
     echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
     echo  "###############################################################################\n\n" 	>>$File
     echo "\n### storagegroups ###" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP storagegroup -list \n" 	>> $File
        /usr/bin/navicli -h $spIP storagegroup -list 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "################################################################################\n"		>> $File
     ;;
N|n)
     echo "\n--> /usr/bin/navicli getagent \n" 	>> $File
     /usr/bin/navicli getagent 			>> $File  	2>> $File
     echo "################################################################################\n"		>> $File
     i="aaa"
     for i in `/usr/bin/navicli getagent 2>> $File | grep "Physical Node"| sed s/"Physical "// | sed s/"Node:"//`
     do
        if [ "aaa" != $i ]
        then
	   File=$Name-navicli-$i-SP-log-info
	   echo "\n$File..."
           echo  "\n\n###############################################################################\n\n"	>$File
	   echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 		>>$File
           echo  "###############################################################################\n\n" 	>>$File
	   echo "\n\n###### navicli SP log info ######\n"  		>> $File
	   echo "\n### $i logs ###" 					>> $File
	   echo "\n--> /usr/bin/navicli -d $i getlog \n"	>> $File
	   /usr/bin/navicli -d $i getlog 			>> $File 	2>> $File
	   echo "################################################################################\n"	>> $File
        else
	   File=$Name-navicli-SP-LUN-CRU-port-storagegroup-systemtype-info
	   echo "\n$File..."
           echo  "\n\n###############################################################################\n\n"	>$File
	   echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 		>>$File
           echo  "###############################################################################\n\n" 	>>$File
	   echo "\nThere is no information available to display"
        fi
     done
     if [ "aaa" != $i ]
     then
        File=$Name-navicli-LUN-info
        echo "\n$File..."
        echo  "\n\n###############################################################################\n\n" 	>$File
        echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
        echo  "###############################################################################\n\n" 	>>$File
        echo "\n### LUNs ###" 					>> $File
        echo "\n--> /usr/bin/navicli -d $i getlun \n" 	>> $File
        /usr/bin/navicli -d $i getlun 			>> $File  	2>> $File
        echo "################################################################################\n"		>> $File

        File=$Name-navicli-CRU-info
        echo "\n$File..."
        echo  "\n\n###############################################################################\n\n" 	>$File
        echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
        echo  "###############################################################################\n\n" 	>>$File
        echo "\n### CRU info ###" 					>> $File
        echo "\n--> /usr/bin/navicli -d $i getcrus \n" 	>> $File
        /usr/bin/navicli -d $i getcrus 			>> $File  	2>> $File
        echo "################################################################################\n"		>> $File

        File=$Name-navicli-port-info
        echo "\n$File..."
        echo  "\n\n###############################################################################\n\n" 	>$File
        echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
        echo  "###############################################################################\n\n" 	>>$File
        echo "\n### ports ###" 						>> $File
        echo "\n--> /usr/bin/navicli -d $i port -list -all \n" 	>> $File
        /usr/bin/navicli -d $i port -list -all			>> $File  	2>> $File
        echo "################################################################################\n"		>> $File

        File=$Name-navicli-storagegroup-info
        echo "\n$File..."
        echo  "\n\n###############################################################################\n\n" 	>$File
        echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
        echo  "###############################################################################\n\n" 	>>$File
        echo "\n### storagegroups ###" 						>> $File
        echo "\n--> /usr/bin/navicli -d $i storagegroup -list \n" 	>> $File
        /usr/bin/navicli -d $i storagegroup -list 			>> $File  	2>> $File
        echo "################################################################################\n"		>> $File

        File=$Name-navicli-systemtype-info
        echo "\n$File..."
        echo  "\n\n###############################################################################\n\n" 	>$File
        echo  "######### Information listing for `uname -n` as of `date` #########\n\n" 			>>$File
        echo  "###############################################################################\n\n" 	>>$File
        echo "\n### systemtype ###" 					>> $File
        echo "\n--> /usr/bin/navicli -d $i systemtype \n" 	>> $File
        /usr/bin/navicli -d $i systemtype 			>> $File 	2>> $File
        echo "################################################################################\n"		>> $File

    fi
    ;;
esac
echo "\n\n###### Procedure complete ######" >> $File
tar -cf $TarName $Name-*
rm $Name-*
rm $Name-* $DeleteMe $spaerrorFile $spberrorFile 2> /dev/null
compress $TarName
echo "\n\n###### Procedure complete ######"
echo "\nzipped file name is $TarName.Z"
echo "\n\n###### Please download this file using BINARY transfer mode and send to CLARiiON Technical Support"

