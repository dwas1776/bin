#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:   migratevg
#   DATE:       Aug 29, 2000
#   AUTHOR:     David A. Wasmer
#   PURPOSE:    migrate contents of one volume group to another volume group
#   SYNTAX:	migratevg [ -s source volume group ] [ -d destination volume group ]
#
#   REVISIONS:
#
#########|#########|#########|#########|#########|#########|#########|#########|
# set -x
# set +x

##############################
function FUNC_HELP
##############################
{
print "

migratevg Command

Purpose

To migrate all of the filesystems (logical volumes) from one 
volume group to another volume group.


Syntax

migratevg  [ -s source volume group ]  [ -d destination volume volume ]


Description

This script will inventory the all the jfs logical volumes that live in 
the source volume group and then copy them, one at a time, to the 
destination volume group.  To maintain lv uniqueness, it appends each 
of the new logical volume names with \"_N\".  

Logical volumes have a 15 character limit.  To append the name requires 
two additional characters.  If the source logical volume name is longer 
than 12 characters, the script will identify it as such and then exit 
without making any changes.  The administrator will have to shorten the
logical volume name to fewer than 13 characters before re-attempting 
this script. 

While coping the jfs logical volumes, the script compiles a list of
the filesystem names, the new logical volume names and the jfslog name.  
After all of the logical volumes have been copied to the destination 
volume group, the script pauses and asks the administrator to manually
update /etc/filesystems.  The script will offer recommendations for this
edit, but the administrator should use judgement based on the earlier 
analysis.

Copy the migrated filesystem entries in /etc/exports from the source server 
to the destination server.  Remove the migrated filesystem entries from
/etc/exports on the source server.  If the source volume group and the 
destination volume group are on the same server, then /etc/exports will 
not have to be modified.

If any of the migrated filesysems were NFS exported, and you choose not
to reboot the servers, then run exportfs against each of the migrated 
NFS filesystems.  

After the administrator completes updating /etc/filesystems and 
/etc/exports, reboot the servers.  It will be easier to identify and 
correct any problems that appear after the reboot rather than wait for
the next scheduled reboot.  

Here are some of the prerequisite issues to running this script:


   1.  The destination volume group may already exist and have jfs 
   logical volumes living there.  Either way, make sure that the 
   destination volume group has adequate space available.  

   2.  Before you migrate, you must analyze the disk activity 
   of the source and destination volume groups to determine the 
   appropriate number and size of jfslogs that will be needed 
   on the destination volume group.

   3.  If your destination volume group requires additional
   jfslogs, you should create these after running this script.
   The initial migration assumes that there is only one jfslog
   on the destination volume group. 

   If your destination volume group is a new volume group, you 
   will have to create exactly one jfslog before running this
   script.

   Here is an example of how to create a jfslog:
      mklv -y jfslog001  -t jfslog  [destination vg name]  1 [hdisk#]
      logform /dev/jfslog001

   4.  Verify that the filesystems you will be migrating can
   be unmounted before running this script.  Get all the procedures
   to find and kill any processes that may be holding a lock on
   these filesystems before starting.

   5.  Backup /etc/filesystems to /etc/filesystem.YYMMDD
   You might also want to run obtain a hard copy of the output 
   from the ls -l and df commands for each filesystem being 
   migrated.  

   6.  Determine if any other servers or client workstations have NFS
   mounts to any of the migrated filesystems.  If so, the administrator
   must manually edit /etc/exports and then run exportfs against the 
   migrated filesystems that are in /etc/exports.  

   It is good practice to reboot the servers that contained the
   source and destination volume groups.  It is easier to fix any 
   problems now rather than wait until they surface at the next
   scheduled reboot.


Flags

-s  The name of the source volume group.

-d  The name of the destination volume group.

-h  This help screen.


Examples

  1. To migrate the jfs logical volumes from the volume group named 
  sourcevg to a volume group named destinationvg, enter the following:
     migratevg -s sourcevg -d destinationvg



Files

/usr/sbin/cplv, /usr/sbin/chfs, /usr/sbin/exportfs  

/tmp Directory where the temporary files are stored while the command is
running.

Related Information

The migratepv command, lslv command (particularly the -p and -l options).

Written by David Wasmer.

"  | more

exit 0

}


##############################
function MIGRATEVG
##############################
{
for f in $FILESYSTEMS ; do
   print "\n\n#######################################################"
   LV=$(lsvg -l $SOURCEVG | grep $f$  | awk '{print $1}')
   print "\nUnmounting $f filesystem belonging to $SOURCEVG..."
   umount $f
   sleep 20
   df | grep $f
   if [ $? = 0 ]; then
      print "\nWARNING:  The $f filesystem could not be unmounted."
      print "# Please manually umount $f in a separate window."
      print "# After this is done press the enter key in this window to continue.\n\n\n"
      read ans
   fi
   date
   print "\nCopying $LV logical volume for $f filesystem"
   print "to the destination volume group, $DESTINATIONVG..."
   print "Here is the command that is running..."
   print "      cplv -v $DESTINATIONVG  -y ${LV}_N  $LV"
   print "=========================================================="

   cplv -v $DESTINATIONVG  -y ${LV}_N  $LV 
   print "\n $f"  >> $TMPFILE
   print "     dev             = /dev/${LV}_N"  >> $TMPFILE
   print "     log             = /dev/$DestinationJFSLOG"  >> $TMPFILE
   print "\nSleeping for 10 seconds before starting next cplv..."
   sleep 10
done
}  

##############################
function UPDATEFS
##############################
{
for f in $FILESYSTEMS ; do
   print "\nUpdating the filesystem changes..."
   print "      chfs $f"
   chfs $f
   print "\nMounting the $f filesystem..."
   print "      mount $f"
   mount $f
   sleep 15
done
}


##############################
#   MAIN
##############################
while getopts "s:d:h" OPTION; do
   case $OPTION in
        s ) SOURCEVG="$OPTARG"		;;
        d ) DESTINATIONVG="$OPTARG"	;;
        h ) FUNC_HELP			;;
        * ) print error; FUNC_HELP	;;
   esac
done
shift $(($OPTIND - 1))

##############################
#   VARIABLES
##############################
DestinationJFSLOG=$(lsvg -l $DESTINATIONVG | grep jfslog | awk '{print $1}')
FILESYSTEMS=$(lsvg -l $SOURCEVG | grep "jfs " | awk '{print $7}')
LOGICALVOLUMES=$(lsvg -l $SOURCEVG | grep "jfs " | awk '{print $1}')
LOGFILE=/tmp/migratevg_out$$
TMPFILE=/tmp/migratevg_tmp$$

if [ $LOGNAME != root ] ; then
   print "You must be root to run the program. \nExiting..."
   exit 0
fi

{
for x in $(lsvg -l $SOURCEVG | grep "jfs " | awk '{print $1}'); do
  CHARCOUNT=$(print $x | wc -m )
  if [ $CHARCOUNT -gt 12 ] ; then
   print "Rename the $x logical volume to have fewer than 12 characters."
   exit 0
  fi
done

print "date is \c"
date
cp -p /etc/filesystems /etc/filesystems.$$.$(date +%y%m%d)
umount all
sleep 10
df
sleep 5
MIGRATEVG
print "date is \c"
date
print "\n\n\n##############################################"
print "##############################################"
print "##############################################"
print "\nYou must manually edit the /etc/filesystems."
print "In a separate window, more the $TMPFILE to see the "
print "changes that are needed."
print "\n       view $TMPFILE"
print " vi /etc/filesystems"
print "\nAfter this is done press the enter key in this window to continue.\n\n\n"
read ans
print "date is \c"
date
UPDATEFS
print "date is \c"
date

for x in $FILESYSTEMS; do
    print "mount $x"
    mount $x
    sleep 5
done
sleep 20
if lsvg -l $DESTINATIONVG | grep close ; then
   print "Opps, there are still closed lv's on $DESTINATIONVG."
   print "Please fix these."
fi

if lsvg -l $SOURCEVG | grep open ; then
   print "Opps, there are still open lv's on $DESTINATIONVG."
   print "Please fix them."
fi


NFS_FS=
for x in $FILESYTEMS; do
    NFS_FS="$NFS_FS $(grep $x /etc/exports)"
done    

if [ -z "$NFS_FS" ]; then
   print "Please verify the entries in /etc/exports for the following filesystems:

$NFS_FS

After you are satisfied, then run exportfs against them.
After running exportfs, you will have to unmount and re-mount these on
all the NFS clients that have mounts to these filesystems.

"  |  more
fi

} 2>&1 | tee $LOGFILE
exit 0

# END
