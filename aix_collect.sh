#!/usr/bin/sh
# aix_collect.sh
# aix collect script : collect information about system settings
# when using ftp the script always needs to be tranfered via ASCII mode
# the output file needs to be transfered via binary mode in ftp
# To be used ONLY for AIX systems!
# Version 12
#***************************************************************
# created 12/20/2000
# modified 03/09/01 atfi, fcsport and fcsinfo commands added
# modified 05/10/01 navicli storagegroup -list added
# modified 07/24/01 lsdev -Cs SCSI,
#                   odmget -q "name=sp0" CuDv odmget -q "name=sp0" CuAt added
# v05 01/21/2002 added FC4700 capability
#		removed hosts and cron information since it was never used
#		broke information into more,separate files
#		removed duplicate LUN,CRU,port and storagegroup info
#		added commands run to each section
#		changed name of output file to <hostname>_for_EMC...
#               added delete of any work files left over from an aborted run
# v07 10/23/2002 added entries to scan for fclar and fcs devices as well as
#		fchan (modified sect. for lsdev listing and fcsport and fcsinfo)
# v08 2/7/2003 added powerpath information and arraycommpath/failovermode
#		and changed it to ask for fc4700 or cx series
#		The settings for failovermode/arraycommpath only get the setting
#		for the array not for each hba, so I commented them out for now
# v09 3/20/2003 added physical volume info (lspv)
# v10 4/1/2003 added arraycommpath and failover settings as part of the port list
# 		removed failover/arraycommpath info that was commented out as mentioned
#		above
# v11 6/13/2003 added the port list without -all for older versions of navicli.
#		added the errpt command
#		added the oslevel -r command to get the maintance level
#		added a lun summary
# v12 6/19/2003 added customer name and case number
#		added lspv -l for the hdispower devices, to corralate the hdiskpower
#		device to the file system that is mounted on it
#***************************************************************
#
echo "\n\n ******* Collect Script for AIX hosts - Version 12 *******"
version=v12
#
# set the file names
# ask for company name and case number
echo "Please enter your Company Name:\c"
read CompName
echo "Please enter your case number:\c"
read case
# set the file name
Basename=$CompName"_"$case"_aix_"$version"_"`uname -n`
Name=$Basename
#Name=`uname -n`_for_EMC_v11
DeleteMe=/tmp/deleteme
spaerrorFile=/tmp/spadeleteme
spberrorFile=/tmp/spbdeleteme
# determine if file already exists
if [ -s /tmp/$Name.info* ]
then
   (( ctr=$(ls -1 /tmp/$Name.info* |wc -w)  + 1))
else
   ctr=1
fi
TarName=/tmp/$Name.info.$ctr
#
# delete any existing work files
rm /tmp/$Name-* 	2> /dev/null
rm $DeleteMe 		2> /dev/null
rm $spaerrorFile	2> /dev/null
rm $spberrorFile	2> /dev/null
#
# *** this section added 08/21/01 ***
#
# ask if this is a FC4700 or CX series - we need the IP addresses of the SPs if it is
while :
do
   echo "\n Is this host attached to a FC4700 or CX series array? (y/n) \c"
   read fc4700array
   case $fc4700array in
   y|Y)
	echo "Array is a FC4700 or CX series"
	echo "Please enter the IP address of SP A (nnn.nnn.nnn.nnn format): \c"
	read spaIP
	echo "Please enter the IP address of SP B (nnn.nnn.nnn.nnn format): \c"
	read spbIP
	echo "Are these IP numbers correct (y/n)? \c"
	read ans
	case $ans in
        y|Y)
        # determine if both paths are working
	   spIP=""
           echo "Verifying SP A IP address"
           /usr/bin/navicli -h $spaIP getagent 			>> /dev/null  	2> $spaerrorFile
           if [ -s $spaerrorFile ]
           then
               echo "$spaIP is not responding"
               spIP=$spbIP
           else
		spIP=$spaIP
           fi
           echo "Verifying SP B IP address"
           /usr/bin/navicli -h $spbIP getagent 			>> /dev/null  	2> $spberrorFile
           if [ -s $spberrorFile ]
           then
               echo "$spbIP is not responding"
               spIP=$spaIP
           else
		spIP=$spbIP
           fi
           if [ -s $spaerrorFile -a -s $spberrorFile ]
           then
               echo "Neither $spaIP nor $spbIP is responding - do you want to continue anyway? \c"
               read ans
               case $ans in
               y|Y)
	          break
	          ;;
               *)
 	          echo "Error - exiting script"
	          exit
                  ;;
 	       esac
           else
	      break
           fi

	   break
	   ;;
        *)
 	   echo "Error - exiting script"
	   exit
           ;;
	esac
	break
	;;
    n|N)
	echo "Array is not a FC4700 or CX series"
	break
	;;
   *)
        echo "error - please re-enter"
        ;;
   esac
done
#
echo "\n\n****** Creating listing of AIX system information - please wait......."
#
#
# start processing
cd /tmp
#
File=$Name-hostname-oslevel-last-reboot-array-SP-info
echo "\n$File..."
cd /tmp
#
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo  "*******************************************************************************\n\n" >>$File

echo "\n--> uname -a \n"		>> $File
uname -a		>> $File
echo "\n--> uname -M \n"		>> $File
uname -M 		>> $File
echo "\n--> oslevel \n"		>> $File
oslevel			>> $File
echo "\n--> oslevel -r \n"	>> $File
oslevel -r		>> $File
echo "********************************************************************************\n"	>> $File

echo "\n\n****** Last Reboot ******\n"		>> $File
echo "\n--> who -b \n" 			>> $File
who -b 			>> $File
echo "********************************************************************************\n"	>> $File

echo "\n\n****** Environment variables ******\n"		>> $File
echo "\n--> env \n"				>> $File
env				>> $File
echo "********************************************************************************\n"	>> $File

case $fc4700array in
y|Y)
   echo "\n\nArray is a FC4700 or CX series" 		>> $File
   echo "\n****** SP IP information ******\n"		>> $File

   if [ -s $spaerrorFile ]
   then
       echo "SP A $spaIP is not responding" >> $File
   else
       echo "SP A $spaIP is responding" >> $File
   fi
   if [ -s $spberrorFile ]
   then
       echo "SP B $spbIP is not responding" >> $File
   else
       echo "SP B $spbIP is responding" >> $File
   fi
   ;;
n|N)
   echo "\n\nArray is not a FC4700 or CX series"	>> $File
   ;;
esac
#
File=$Name-error-report-a
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** error report info -a ******\n"		>> $File
echo "\n--> errpt -a \n"			>> $File
errpt -a			>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-error-report
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** error report info ******\n"		>> $File
echo "\n--> errpt \n"			>> $File
errpt 			>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-physical-volume-info
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" 	>$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n*** lspv ***" 						>> $File
echo "\n--> lspv \n" 	>> $File
lspv 			>> $File  	2>> $File
echo  "*******************************************************************************\n\n" 	>>$File

File=$Name-physical-vol-to-filesystem-info
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" 	>$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
echo  "*******************************************************************************\n\n" 	>>$File
for i in `lspv |grep power |cut -c0-14`
do
	echo "\n***$i:***"                >> $File
	echo "\n--> lspv -l $i \n"        >> $File
	lspv -l $i                        >> $File
	echo "***end of $i***"            >> $File
done
echo "*********************************************************************************\n\n"     >> $File

File=$Name-powerpath-info
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" 	>$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n*** powermt display ***" 						>> $File
echo "\n--> powermt display \n" 	>> $File
powermt display 			>> $File  	2>> $File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n*** powermt display dev=all ***" 						>> $File
echo "\n--> powermt display dev=all \n" 	>> $File
powermt display dev=all 			>> $File  	2>> $File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n*** powermt display paths ***" 						>> $File
echo "\n--> powermt display paths \n" 	>> $File
powermt display paths 			>> $File  	2>> $File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n*** powermt display ports ***" 						>> $File
echo "\n--> powermt display ports \n" 	>> $File
powermt display ports 			>> $File  	2>> $File
echo  "*******************************************************************************\n\n" 	>>$File

File=$Name-bootlog
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** boot log info ******\n"		>> $File
echo "\n--> alog -of /var/adm/ras/bootlog \n"		>> $File
alog -of /var/adm/ras/bootlog 		>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-consolelog
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** console log info ******\n"		>> $File
echo "\n--> alog -of /var/adm/ras/conslog \n"		>> $File
alog -of /var/adm/ras/conslog 		>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-software
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** Software ******\n"	>> $File
echo "\n--> lslpp -L \n"		>> $File
lslpp -L 		>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-configuration-info
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** configuration info ******" >> $File
echo "\n--> lscfg -v 	\n"	>> $File
lscfg -v 		>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-sp-adapter-driver-info
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** SCSI info ******" >> $File
echo "\n--> lsdev -Cs SCSI \n" >> $File
lsdev -Cs SCSI >> $File
echo "\n\n****** sp info ******" >> $File
lsdev -Cc array		>> $File
for a in `lsdev -Cc array | cut -d " " -f 1`
do
	echo "\n" $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "********************************************************************************\n"	>> $File

echo "\n\n****** fchan adapter info ******" >> $File
echo "\n--> lsdev -Cc adapter \n">> $File
lsdev -Cc adapter | grep fchan |grep -v "\."		>> $File
for a in `lsdev -Cc adapter | grep fchan | grep -v "\." | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "********************************************************************************\n"	>> $File
#
# *** this section added 10/23/02 ***
#
echo "\n\n****** fclar adapter info ******" >> $File
echo "\n--> lsdev -Cc adapter \n">> $File
lsdev -Cc adapter | grep fclar |grep -v "\."		>> $File
for a in `lsdev -Cc adapter | grep fclar | grep -v "\." | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "********************************************************************************\n"	>> $File
#
# *** this section added 10/23/02 ***
#
echo "\n\n****** fcs adapter info ******" >> $File
echo "\n--> lsdev -Cc adapter \n">> $File
lsdev -Cc adapter | grep fcs |grep -v "\."		>> $File
for a in `lsdev -Cc adapter | grep fcs | grep -v "\." | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n"	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "********************************************************************************\n"	>> $File

echo "\n\n****** driver info ******" >> $File
echo "--> lsdev -Cc driver \n"		>> $File
lsdev -Cc driver		>> $File
for a in `lsdev -Cc driver | cut -d " " -f 1`
do
	echo $a 	>> $File
	echo "\n--> lsattr -El $a \n" 	>> $File
	lsattr -El $a 	>> $File	2>> $File
done
echo "********************************************************************************\n"	>> $File

INT=`lsdev -Ccdriver | grep 'atf' | awk '{print $1}'`
for INC in $INT
do
	echo "\n--> /usr/sbin/atf/atfi -d $INC -p \n" >> $File
	/usr/sbin/atf/atfi -d $INC -p >> $File 2>> $File
done
echo "********************************************************************************\n"	>> $File

File=$Name-HBA-driver-trace-info
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** fchandd info ******" >> $File

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
echo "********************************************************************************\n"	>> $File
#
# *** this section added 10/23/02 ***
#
echo "\n\n****** fclardd info ******" >> $File

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
echo "********************************************************************************\n"	>> $File
#
# *** this section added 10/23/02 ***
#
echo "\n\n****** fcsdd info ******" >> $File

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
echo "********************************************************************************\n"	>> $File

File=$Name-disks
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** Disks ******\n"	>> $File
echo "\n--> lsdev -Cc disk \n"		>> $File
lsdev -Cc disk				>> $File
echo "*********************************************************************************\n"	>> $File

echo "\n\n****** Physical Disks ******\n">> $File
for a in `lsdev -Cc disk |cut -d " " -f 1`
do
	echo "\n *** $a ***"			>> $File
	echo "\n--> lsattr -El $a\n"		>> $File
	lsattr -El $a		>> $File	2>> $File
done
echo "********************************************************************************\n"	>> $File

File=$Name-volume-groups
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** Volume Groups ******\n"	>> $File

echo "\n--> lsvg\n"				>> $File
lsvg				>> $File

for i in `lsvg`
do
	echo "\n *** $i: ***"		>> $File
	echo "\n--> lsvg -l $i \n"	>> $File  	2>> $File
	lsvg -l $i 	>> $File  	2>> $File
	echo "*** end of $i ***"	>> $File
done
echo "********************************************************************************\n"	>> $File

File=$Name-logical-volumes
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** Logical Volumes ******\n "	>> $File
for i in `lsvg`
do
	echo "\n *** $i: ***"		>> $File
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
	echo "*** end of $i ***"	>> $File
done

echo "********************************************************************************\n"	>> $File

File=$Name-file-systems
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
echo "\n\n****** Mounted devices ******\n"	>> $File
echo "\n--> mount\n"			>> $File
mount			>> $File
echo "********************************************************************************\n"	>> $File

echo "\n\n****** Filesystems ******\n"	>> $File
lsfs					>> $File
echo "\n"				>> $File
echo "\n--> cat /etc/filesystems\n"			>> $File
cat /etc/filesystems			>> $File
echo "********************************************************************************\n"	>> $File

echo "\n\n****** File System Usage ******\n"	>> $File
echo "\n--> df -k\n"				>> $File
df -k				>> $File
echo "********************************************************************************\n"	>> $File

if [ -s /tmp/hacmp.out ]
then
	File=$Name-hacmp-file
	echo "\n$File..."
	echo  "\n\n*******************************************************************************\n\n" >$File
	echo  "********* Information listing for `uname -n` as of `date` *********\n\n" >>$File
	echo "\n\n****** Mounted devices ******\n"	>> $File
	echo "\n--> cat /tmp/hacmp.out\n"		>> $File
	cat /tmp/hacmp.out				>> $File
	echo "********************************************************************************\n"	>> $File
fi

File=$Name-navi-agent-config
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 		>>$File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n\n****** Navisphere Agent Config File ******\n" >> $File
echo "\n--> cat /etc/Navisphere/agent.config \n" 	>> $File
cat /etc/Navisphere/agent.config 			>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-navi-agent-log
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 		>>$File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n\n****** Agent log info ******\n"	>> $File
echo "\n--> cat /etc/log/agent.log \n"		>> $File
cat /etc/log/agent.log 				>> $File
echo "\n--> cat /etc/logagent.log \n"		>> $File
cat /etc/logagent.log 				>> $File
echo "********************************************************************************\n"	>> $File

File=$Name-navi-getagent
echo "\n$File..."
echo  "\n\n*******************************************************************************\n\n" >$File
echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 		>>$File
echo  "*******************************************************************************\n\n" 	>>$File
echo "\n\n****** navicli getagent ******\n" 	 >> $File

# navi commands are different for FC4700
case $fc4700array in
y|Y)
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n"			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n\n****** navicli agent information ******\n"  			>> $File
     if [ -s $spaerrorFile -a -s $spberrorFile ]
     then
	echo "\n Netiher SP is responding so no information \n"		>> $File
     else
        if [ ! -s $spaerrorFile ]
        then
           echo "\n*** getagent info for $spaIP***" 					>> $File
           echo "\n--> /usr/bin/navicli -h $spaIP getagent \n" 	>> $File
           /usr/bin/navicli -h $spaIP getagent 			>> $File 	2>> $File
           echo "********************************************************************************\n"		>> $File
        fi

        if [ ! -s $spberrorFile ]
        then
           echo "\n*** getagent info for $spbIP***" 					>> $File
           echo "\n--> /usr/bin/navicli -h $spbIP getagent \n" 	>> $File
           /usr/bin/navicli -h $spbIP getagent 			>> $File 	2>> $File
           echo "********************************************************************************\n"		>> $File
        fi
     fi

     echo "********************************************************************************\n"	>> $File

     File=$Name-navicli-$spaIP-SP-log-info
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n"			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n\n****** navicli SP log information ******\n"  			>> $File

     if [ ! -s $spaerrorFile ]
     then
        echo "\n$File...  this may take a little while to collect..."
        echo "\n*** logs for $spaIP***" 					>> $File
        echo "\n--> /usr/bin/navicli -h $spaIP getlog \n" 	>> $File
        /usr/bin/navicli -h $spaIP getlog 			>> $File 	2>> $File
        echo "********************************************************************************\n"		>> $File
     else
        echo "\nSP $spaIP does not respond so no information\n"		>>$File
     fi

     File=$Name-navicli-$spbIP-SP-log-info
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n"			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n\n****** navicli SP log information ******\n"  			>> $File
     if [ ! -s $spberrorFile ]
     then
        echo "\n$File...  this may take a little while to collect..."
        echo "\n*** logs for $spbIP***" 					>> $File
        echo "\n--> /usr/bin/navicli -h $spbIP getlog \n" 	>> $File
        /usr/bin/navicli -h $spbIP getlog 			>> $File 	2>> $File
        echo "********************************************************************************\n"		>> $File
     else
        echo "\nSP $spbIP does not respond so no information\n"		>>$File
     fi

     File=$Name-navicli-LUN-info
     echo "\n$File..."
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n*** LUNs ***" 						>> $File

     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP getlun \n" 	>> $File
        /usr/bin/navicli -h $spIP getlun 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi

     echo "********************************************************************************\n"		>> $File

     File=$Name-navicli-LUN-summary-info
     echo "\n$File..."
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n*** LUNs ***" 						>> $File

     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP getlun -rg -type -default -owner -crus -capacity\n" 	>> $File
        /usr/bin/navicli -h $spIP getlun -rg -type -default -owner -crus -capacity		>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi

     echo "********************************************************************************\n"		>> $File

     File=$Name-navicli-CRU-info
     echo "\n$File..."
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n*** CRU info ***" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP getcrus \n" 	>> $File
        /usr/bin/navicli -h $spIP getcrus 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "********************************************************************************\n"		>> $File

     File=$Name-navicli-port-all-info
     echo "\n$File..."
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n*** ports ***" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP port -list -all \n" 	>> $File
        /usr/bin/navicli -h $spIP port -list -all 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "********************************************************************************\n"		>> $File

     File=$Name-navicli-port-info
     echo "\n$File..."
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n*** ports ***" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP port -list \n" 	>> $File
        /usr/bin/navicli -h $spIP port -list  			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "********************************************************************************\n"		>> $File

     File=$Name-navicli-storagegroup-info
     echo "\n$File..."
     echo  "\n\n*******************************************************************************\n\n" 	>$File
     echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
     echo  "*******************************************************************************\n\n" 	>>$File
     echo "\n*** storagegroups ***" 						>> $File
     if [ ! -s $spaerrorFile -o ! -s $spberrorFile ]
     then
        echo "\n--> /usr/bin/navicli -h $spIP storagegroup -list \n" 	>> $File
        /usr/bin/navicli -h $spIP storagegroup -list 			>> $File  	2>> $File
     else
        echo "\nNeither SP IP is responding so no information\n" 	>> $File
     fi
     echo "********************************************************************************\n"		>> $File
     ;;
N|n)
     echo "\n--> /usr/bin/navicli getagent \n" 	>> $File
     /usr/bin/navicli getagent 			>> $File  	2>> $File
     echo "********************************************************************************\n"		>> $File
     i="aaa"
     for i in `/usr/bin/navicli getagent 2>> $File | grep "Physical Node"| sed s/"Physical "// | sed s/"Node:"//`
     do
        if [ "aaa" != $i ]
        then
	   File=$Name-navicli-$i-SP-log-info
	   echo "\n$File..."
           echo  "\n\n*******************************************************************************\n\n"	>$File
	   echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 		>>$File
           echo  "*******************************************************************************\n\n" 	>>$File
	   echo "\n\n****** navicli SP log info ******\n"  		>> $File
	   echo "\n*** $i logs ***" 					>> $File
	   echo "\n--> /usr/bin/navicli -d $i getlog \n"	>> $File
	   /usr/bin/navicli -d $i getlog 			>> $File 	2>> $File
	   echo "********************************************************************************\n"	>> $File
        else
	   File=$Name-navicli-SP-LUN-CRU-port-storagegroup-systemtype-info
	   echo "\n$File..."
           echo  "\n\n*******************************************************************************\n\n"	>$File
	   echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 		>>$File
           echo  "*******************************************************************************\n\n" 	>>$File
	   echo "\nThere is no information available to display"
        fi
     done
     if [ "aaa" != $i ]
     then
        File=$Name-navicli-LUN-info
        echo "\n$File..."
        echo  "\n\n*******************************************************************************\n\n" 	>$File
        echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
        echo  "*******************************************************************************\n\n" 	>>$File
        echo "\n*** LUNs ***" 					>> $File
        echo "\n--> /usr/bin/navicli -d $i getlun \n" 	>> $File
        /usr/bin/navicli -d $i getlun 			>> $File  	2>> $File
        echo "********************************************************************************\n"		>> $File

        File=$Name-navicli-CRU-info
        echo "\n$File..."
        echo  "\n\n*******************************************************************************\n\n" 	>$File
        echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
        echo  "*******************************************************************************\n\n" 	>>$File
        echo "\n*** CRU info ***" 					>> $File
        echo "\n--> /usr/bin/navicli -d $i getcrus \n" 	>> $File
        /usr/bin/navicli -d $i getcrus 			>> $File  	2>> $File
        echo "********************************************************************************\n"		>> $File

        File=$Name-navicli-port-info
        echo "\n$File..."
        echo  "\n\n*******************************************************************************\n\n" 	>$File
        echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
        echo  "*******************************************************************************\n\n" 	>>$File
        echo "\n*** ports ***" 						>> $File
        echo "\n--> /usr/bin/navicli -d $i port -list -all \n" 	>> $File
        /usr/bin/navicli -d $i port -list -all			>> $File  	2>> $File
        echo "********************************************************************************\n"		>> $File

        File=$Name-navicli-storagegroup-info
        echo "\n$File..."
        echo  "\n\n*******************************************************************************\n\n" 	>$File
        echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
        echo  "*******************************************************************************\n\n" 	>>$File
        echo "\n*** storagegroups ***" 						>> $File
        echo "\n--> /usr/bin/navicli -d $i storagegroup -list \n" 	>> $File
        /usr/bin/navicli -d $i storagegroup -list 			>> $File  	2>> $File
        echo "********************************************************************************\n"		>> $File

        File=$Name-navicli-systemtype-info
        echo "\n$File..."
        echo  "\n\n*******************************************************************************\n\n" 	>$File
        echo  "********* Information listing for `uname -n` as of `date` *********\n\n" 			>>$File
        echo  "*******************************************************************************\n\n" 	>>$File
        echo "\n*** systemtype ***" 					>> $File
        echo "\n--> /usr/bin/navicli -d $i systemtype \n" 	>> $File
        /usr/bin/navicli -d $i systemtype 			>> $File 	2>> $File
        echo "********************************************************************************\n"		>> $File

    fi
    ;;
esac
echo "\n\n****** Procedure complete ******" >> $File
tar -cf $TarName $Name-*
rm $Name-*
rm $Name-* $DeleteMe $spaerrorFile $spberrorFile 2> /dev/null
compress $TarName
echo "\n\n****** Procedure complete ******"
echo "\nzipped file name is $TarName.Z"
echo "\n\n****** Please download this file using BINARY transfer mode and send to CLARiiON Technical Support"

