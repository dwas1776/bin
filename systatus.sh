#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
#
#   FILENAME:	systatus
#   DATE:	Oct. 29, 1998
#   AUTHOR:	David A. Wasmer
#
#   SYNTAX:	systatus [f]
#		f - forces script to contiune checking regardless of errors.
#
#   PURPOSE:	To check system status of known reoccurring problems.
#
#		Checks the following:
#
#		 Phase 1 checks
#		   - Code servers alive and uptime
#		   - NIS servers alive and uptime
#		   - MVS alive
#		   - Soft5080 Controller alive
#		   - HACMP failover status
#		   - EPROM check on HACMP servers
#
#		 Phase 2 checks
#		   - LUM license serving on rssrv01, rssrv02 and rssrv03
#		   - Stone Rule license servers on rssrv06, rssrv07
#		   - Time daemon on rssrv06
#		   - Broadcast daemon on rssrv06
#		   - NIS Password daemon on rssrv06
#		   - Server Queue Monitor on rssrv06
#		   - ProEngineer on rssrv06
#		   - License server status from client (rs0f30)
#
#		 Phase 3 checks
#		   - /var/spool/qdaemon filesystem on rssrv03
#		   - /tmp filesystem on rssrv04, rssrv06, rssrv07
#		   - User filesystems on rssrv04, rssrv06, rssrv07
#
#########|#########|#########|#########|#########|#########|#########|#########|
#set -x
#set +x


################################################################################
#   VARIABLES
################################################################################
REV=$(tput rev)
NORM=$(tput sgr0)
FORCE="$1"

################################################################################
#   FUNCTIONS
################################################################################
function PAGEME
{
print "${REV}

    Now is a good time to panic!
    Contact a senior administrator and explain the error.
                                                                              ${NORM}"
if [ "$FORCE" = FORCE ]; then
   print "...continuing checks.     "
   sleep 7
else
   exit 0
fi
}

function RERUN
{
print "${REV}
     Then re-run this script to check that it worked!

     Also, please capture the error message and send it to me via Lotus Notes.
                                                                                   \n${NORM}"
if [ "$FORCE" = "FORCE" ]; then
   print "...continuing checks.^G"
   sleep 5
else
   exit 0
fi
}

function I4LS
{
print "${REV}
     If license serving is interrupted on rssrv06 or rssrv07,

     then the catlic and CATLIC processes must be killed on rssrv09
                                                                                  \n${NORM}"
}

################################################################################
#   HELP FUNCTION
################################################################################
function FUNC_HELP
{
   print "
          ${REV}USAGE:                                                               $NORM
          /maint/bin/systatus  [ -a ][ -d ][ -f ][ -h ][ -L ][ -p ][ -s ]

                     -a   Checks all
                     -d   Checks troublesome disk utililization
                     -f   Forces checking to continue - even if errors encountered
                     -h   Help - displays options for this command
                     -L   Checks status of license environment
                     -p   Checks difficult processes
                     -s   Checks servers uptime, 6098's alive and mvs alive
"
exit 0
}

################################################################################
#   SERVERS ALIVE FUNCTION
################################################################################
#  Checks that servers are pingable and reports uptime.
function FUNC_SERVERS_ALIVE
{
   ping -c 1 rs0e4e > /dev/null
   print "${REV}\n\n          Code servers uptime check...                              \c"
   print "                       \n${NORM}"
   #SYSTEMS="rssrv01 rssrv02 rssrv03 rssrv04 rssrv05 rssrv06 rssrv07 rssrv09 rssrv10 rssrvc1 rssrvn1"
   # Modified 11/17/1999 koa (removed rssrvc1 from check)
   SYSTEMS="rssrv01 rssrv02 rssrv03 rssrv04 rssrv05 rssrv06 rssrv07 rssrv09 rssrv10 rssrvn1"
   for x in $SYSTEMS; do
      if ping -c 1 $x > /dev/null ; then
         print "$x:   \c"
         rsh $x uptime | awk '{print $1" "$2" "$3" "$4" "$5" "$6}'
      else
         print "\n\n     $x is not reachable.\n"
         if [[ "$x" = rssrv06 || "$x" = rssrv07 ]]; then
            print "\nFailover did not occur!\n"
            PAGEME
         fi
         PAGEME
      fi
   done

   #  Checks if NIS Servers are pingable
   print "${REV}\n\n          NIS servers uptime check...                               \c"
   print "                       \n${NORM}"
   SYSTEMS="$(ypcat ypservers)"
   for x in $SYSTEMS; do
       if ping -c 1 $x > /dev/null ; then
          print "$x:   \c"
          rsh $x uptime | awk '{print $1" "$2" "$3" "$4" "$5" "$6}'
       else
          print "\n\n     $x is not reachable.\n"
          print "This is an NIS Server.  Try pinging $x."
          print "If you cannot ping the $x, then escalate"
          print "this to a Senior AIX Administrator\n"
       fi
   done

   #  Checks that MVS hosts are reachable.
   print "${REV}\n\n          MVS alive check...                                        \c"
   print "                       \n${NORM}"
   SYSTEMS="ibmhost ibmhost_a ibmhost_b"
   for x in $SYSTEMS; do
      if ping -c 1 $x > /dev/null ; then
         print "$x:	is reachable"
      else
         print "\n\n     $x is not reachable.\n"
         PAGEME
      fi
   done

   #  Checks if Soft5080 controllers are pingable
   print "${REV}\n\n          Soft5080 Controller alive check...                        \c"
   print "                       \n${NORM}"
   SYSTEMS="ibm6098 ibm6098b ibm6098c ibm6098d "
   SYSTEMS="$SYSTEMS ibm6098e ibm6098f ibm6098g "
   # SYSTEMS="$SYSTEMS ibm6098n"
   for x in $SYSTEMS; do
       if ping -c 1 $x > /dev/null ; then
          print "$x:	Soft5080 Controller is reachable."
       else
          print "\n\n     $x is not reachable.\n"
          print "This is a Soft5080 Controller.  Escalate "
          print "this to Network Services.^G\n"
       fi
   done

   #  Checks that rssrv07 is up and that it did not a failover to rssrv06.
   print "${REV}\n\n          HACMP failover check...                                   \c"
   print "                       \n${NORM}"
   HACMP="rssrv06 rssrv07"
   for x in $HACMP; do
      REALNAME="$(rsh $x hostname)"
      if [ "$REALNAME" != $x ]; then
         print "\n\n\n\n\n\n\n\n     $x hostname is $REALNAME"
         print "     One of the HACMP servers may be down!\n\n"
         PAGEME
      else
         print "$x:    appears to be alive."
      fi
   done

   #  Checks EPROM level on HACMP servers
   print "${REV}\n\n          EPROM check on HACMP servers                              \c"
   print "                       \n${NORM}"
   HACMP="rssrv06 rssrv07"
   for x in $HACMP; do
      print "Checking EPROM level on $x..."
      EPROM="$(rsh $x lscfg -vl ioplanar0 | awk '/(RM)/ {print substr($3,1,4)}')"
      if [ "$EPROM" != "0950" ]; then
         print "${REV}\nERROR:  ${NORM}The EPROM for $x is $EPROM,"
         print "but the EPROM should be 0950."
         print "This is not an urgent problem, but please"
         print "notify a senior AIX administrator\n\n"
      else
         print "     EPROM of $EPRPOM for $x is OK.\n"
      fi
   done
}

################################################################################
#   LICENSE FUNCTION
################################################################################
#
function FUNC_LICENSE
{
   print "${REV}\n\n          LUM servers check...                                      \c"
   print "                       \n${NORM}"
   SYSTEMS="rssrv01 rssrv02 rssrv03"
   for x in $SYSTEMS; do
      if ping -c 1 $x > /dev/null ; then
         print "\nLUM - checking on $x..."

         ######################################
         #  Run i4tv to test each license server
         ######################################

         LUMstat=$(rsh $x /var/ifor/i4tv | grep ip)

         NormalLUMstat='    ip:rssrv01 (IBM/AIX) running LUM 4.5.2 AIX
    ip:rssrv02 (IBM/AIX) running LUM 4.5.2 AIX
    ip:rssrv03 (IBM/AIX) running LUM 4.5.2 AIX
    ip:rssrv01 (IBM/AIX) running LUM 4.5.2 AIX'

         if [ "$LUMstat" = "$NormalLUMstat" ]; then
            print "    i4tv looks good on $x."
         else
            print "^G\n     LUM appear to have a problem on $x."
            PAGEME
         fi


         LUMres=$(rsh $x lssrc -a | grep ifor | grep active | awk '{print $1}')

         NormalLUMres='llbd
glbd
i4llmd
i4lmd
i4glbcd'

         NormalLUMresrssrv01='llbd
glbd
i4llmd
i4lmd
i4gdb
i4glbcd'

         if [ "$x" = rssrv01 ]; then
            if [ "$LUMres" = "$NormalLUMresrssrv01" ]; then
               print "    LUM resources look good on $x."
            else
               print "^G\n     LUM appear to have a problem on $x."
               PAGEME
            fi
         else
            if [ "$LUMres" = "$NormalLUMres" ]; then
               print "    LUM resources look good on $x."
            else
               print "^G\n     LUM appear to have a problem on $x."
               PAGEME
            fi
         fi
       else
         print "$x is not reachable"
       fi
done


   #  Checks client workstation rs0f30 ONLY!
   x="rs0f30"
   if ping -c 1 $x > /dev/null ; then
      print "\nLUM - Checking on $x..."
      LUMstat=$(rsh $x /var/ifor/i4tv | grep ip | wc -l)

      NormalLUMstat='       4'

      if [ "$LUMstat" = "$NormalLUMstat" ]; then
         print "    i4tv looks good on $x."
      else
         print "^G\n     LUM appear to have a problem on $x."
         PAGEME
      fi
    else
       print "$x is not reachable"
       PAGEME
    fi







   #  Checks StoneRule

   #SYSTEMS="rssrv07 rssrv06 rssrvc1"

   # Modified 11/17/1999 koa (removed rssrvc1 from check)
   SYSTEMS="rssrv07 rssrv06"
   print "${REV}\n\n          Checking Stone Rule License status...           \c"
   print "                       \n${NORM}"

   for x in $SYSTEMS; do
      if ping -c 1 $x > /dev/null ; then
         print "\nStone Rule process - checking on $x..."
         if rsh $x ps -ef | grep -q [s]rule ; then
            print "     srule is running on $x"
         else
            print "^G\n     Stone Rule is NOT running on $x!"
            print "     To start Stone Rule, login as root on $x"
            print "     and run the following command:"
            print "\n     /catia/prod/bin/start_srule_license_server\n\n"
            RERUN
         fi
       else
         print "$x not reachable"
       fi
   done

}


################################################################################
#  PROCESSES FUNCTION
################################################################################
function FUNC_PROCESSES
{
   x="rssrv06"
      print "${REV}\n\n          $x - Checking difficult processes...                 \c"
      print "                       \n${NORM}"
      #  TIME DAEMON
      print "\nTime daemon - checking on $x..."
      if rsh $x ps -ef | grep -q [t]imed ; then
         print "     timed is running on $x"
      else
         print "\n     Time daemon is NOT running on $x!"
         print "     To start the time daemon, login as root on $x"
         print "     and run the following commands:"
         print "\n     at now"
         print "     /usr/local/bin/catia_timed_startup"
         print "     ^D"
         RERUN
      fi

      #  BROADCAST DAEMON
      print "\nBroadcast daemon - checking on $x..."
      if rsh $x ps -ef | grep -q [b]road ; then
         print "     broadcastd is running on $x"
      else
         print "\n     Broadcast daemon is NOT running on $x!"
         print "     To start the broadcast daemon, login as root on $x"
         print "     and run the following commands:"
         print "\n     at now"
         print "     /common/etc/bin/broadcastd > /dev/null 2>&1"
         print "     ^D"
         RERUN
      fi


      #  server_queue_monitor
      print "\nServer Queue Monitor process - checking on $x..."
      if rsh $x ps -ef | grep -q [s]erver_queue_monitor ; then
         print "     Queue Monitor is running on $x"
      else
         print "^G\n     The Server Queue Monitor is NOT running on $x!"
         print "     To start the process, login as root on $x"
         print "     and run the following commands:"
         print "\n     at now"
         print "     /catia/prod/bin/server_queue_monitor"
         print "     ^D"
         RERUN
      fi

      #  ProEngineer
      print "\nProEngineer process - checking on $x..."
      if rsh $x ps -ef | grep -q [p]roserver ; then
         print "     proserver is running on $x"
      else
         print "\n     ProEngineer is NOT running on $x!"
         print "     To start ProEngineer, login as root on $x"
         print "     and run the following command:"
         print "\n     /plpp/proe/v18.0/bin/prostartserver\n"
         RERUN
      fi







   #  Checks server rssrv01 ONLY!
   x="rssrv01"
      print "${REV}\n\n          $x - Checking NIS Master...                          \c"
      print "                       \n${NORM}"
      #  NIS PASSWD DAEMON
      print "\nNIS Password daemon - checking on $x..."
      if rsh $x lssrc -g yp | grep [y]ppasswdd | grep -q active ; then
         print "     yppasswdd resource is running on $x"
      else
         print "^G\n     NIS Password daemon is NOT running on $x!"
         print "     To start the daemon, login as root on $x"
         print "     and run the following commands:"
         print "\n     startsrc -s yppasswdd"
         RERUN
      fi

      #  Tracker status
      print "\nTracker Status - checking on $x..."
      if rsh $x df | grep ware:/usr2/cadds/parts/a/batch > /dev/null; then
         print "     The remote mount to 'ware' exists on $x..."
      else
         print "^G\n     The remote mount to 'ware' is missing."
         print "^G\n     The Tracker process needs this mount to run."
         PAGEME
      fi

      if [ "$(date +%a)" = Mon ]; then
         MTIME=3
      else
         MTIME=2
      fi

      Rssrv01Srmprs="$(rsh $x find /tmp -name "srmprs.[lo][ou][gt]" -mtime -$MTIME -ls | wc -l)"
      WarePut="$(rsh $x find /home/cv_batch/*put -mtime -$MTIME -type d -ls | wc -l)"

      if [[ "$Rssrv01Srmprs" -eq 2 && "$WarePut" -eq 4 ]]; then
         print "     Tracker log files appear to be up to date on $x"
      else
         print "^G\n     There may be a problem with Tracker on $x!"
         PAGEME
      fi



   #  Checks server rssrv05 ONLY!
   x="rssrv05"
      print "${REV}\n\n          $x - Checking difficult processes...                 \c"
      print "                       \n${NORM}"
      #  DB2
      print "\nDB2 - checking on $x..."
      if rsh $x ps -ef | grep -q "[d]b2wdog" ; then
         print "     db2wdog is running on $x"
         DB2num="$(rsh $x ps -ef | grep "[d]b2" | wc -l )"
         print "$DB2num  DB2 processes are running on $x"
      else
         print "\n     There may be a problem with DB2 on $x!"
         print "     Escalate to a senior administrator:"
         print "           Leeann or Joe is a good start.\n"
         PAGEME
      fi

      #  Checks server rssrv09 ONLY!
      x="rssrv09"
      print "${REV}\n\n          $x - checking difficult processes...                 \c"
      print "                       \n${NORM}"

      #  VFB
      print "\nVFB - checking on $x..."
      if rsh $x ps -ef | grep "[v]fb" > /dev/null ; then
         print "     vfb is running on $x."
      else
         print "\n     vfb is NOT running on $x\n"
         print "       starting /maint/bin/startvfb..."
         rsh $x /maint/bin/startvfb
         print "       completed /maint/bin/startvfb script."
         print "       Re-run this script."
         PAGEME
      fi




   ##########################################################################
   #  ORBIX DAEMON
   ##########################################################################
      print "\norbix daemon - checking on $x..."
      if rsh $x ps -ef | grep "[o]rbixd" > /dev/null ; then
         print "     obix daemon is running on $x."
      else
         print "\n     vfb is NOT running on $x\n"
         print "       starting /maint/bin/startvfb..."
         rsh $x /maint/bin/startvfb
         print "       completed /maint/bin/startvfb script."
         print "       Re-run this script."
         PAGEME
      fi







#         print "\n     orbix daemon is NOT running on $x\n"
#         print "     This is a complicated fix.  Let me try to fix some of it for you"
#         sleep 5
#         print "Checking for the any GW0SRV processes on $x."
#         GW0SRV="$(rsh $x ps -ef | grep [G]W0SRV | awk '{print $2}')"
#         if [ ! -z $GW0SRV ] ; then
#            print "I found some GW0SRV processes.  I will have to kill them now..."
#            rsh $x kill $GW0SRV
#            sleep 5
#            if rsh $x ps -ef | grep "[G]W0SRV" ; then
#               print "I could not kill all the GW0SRV processes."
#               PAGEME
#            else
#               print "Good! I killed all the GW0SRV processes on $x."
#            fi
#         else
#            print "I could not find any GW0SRV processes on $x."
#         fi
#
#         print "\n\nNow you get to do some work... "
#         print "Login in as root on $x and issue the following commands:\n"
#         print "   at now"
#         print "   /nscape/CATwebNavigator/bin/runOrbixDaemon"
#         print "   exit\n\n"
#         print "\n\nPlease capture this session and mail it to Leeann Alexander and David Wasmer.\n"
#         RERUN
#      fi
#
#

}

################################################################################
#   DISK UTILIIZATION FUNCTION
################################################################################
function FUNC_DISK
{
   #  Checks Difficult Filesystems

   #SYSTEMS="rssrv01 rssrv02 rssrv03 rssrv04 rssrv05 rssrv06 rssrv07 rssrv09 rssrv10 rssrvc1"
   # Modified 11/17/1999 koa (removed rssrvc1 from check)
   SYSTEMS="rssrv01 rssrv02 rssrv03 rssrv04 rssrv05 rssrv06 rssrv07 rssrv09 rssrv10"
   print "\n\n"
   for x in $SYSTEMS; do
      print "${REV}\n\n          $x - Difficult Filesystems                           \c"
      print "                       \n${NORM}"
      rsh $x df -vk / /tmp /var /user_files 2>/dev/null | grep -v :
      rsh $x df -vk | grep -v : | grep [1]00%

      # SKIPS CHECKS ON RSSRV03
      if [ "$x" != rssrv03 ]; then
         rsh $x df -vk | grep userdata | grep -v : | sort -nk4
      fi

      #  CHECKS RSSRV03 QDAEMON FILESYSTEM
      if [ "$x" = rssrv03 ]; then
         rsh $x df -vk /var/spool/qdaemon | grep -v Filesystem
      fi

      #  CHECKS RSSRVC1 /user_files
      #if [ "$x" = rssrvc1 ]; then
         #rsh $x df -vk /var/spool/qdaemon /user_files | grep -v Filesystem
         #print "\n\nR E P O R T   G R O U P   Q U O T A\n"
         #rsh $x repquota -a
      #fi
   done
}

################################################################################
#     M A I N
################################################################################
while getopts "adhLpsf" OPTION; do
   case $OPTION in
      a ) ALL="ALL"     			;;
      d ) DISK="DISK"				;;
      h ) HELP="HELP"				;;
      L ) LICENSE="LICENSE"			;;
      p ) PROCESSES="PROCESSES"       		;;
      s ) SERVERS_ALIVE="SERVERS_ALIVE"		;;
      f ) FORCE="FORCE"           		;;
      ? ) FUNC_HELP ; exit 0          		;;
   esac
done
shift $(($OPTIND - 1))

if [ -z "$ALL$DISK$HELP$LICENSE$PROCESSES$SERVERS_ALIVE" ]; then
   print "\nYou must enter arguments\n"
   FUNC_HELP
   exit 0
fi

if [ "$HELP" = HELP ]; then
   FUNC_HELP
fi

if [[ $LOGNAME != "root" || ( $(hostname) != "rssrv06" && $(hostname) != "rssrv07" ) ]]; then
   print "\n   ...so sorry!\n   You must log into rssrv06,"
   print "   as root, to run this script.\n"
   print "   Currently, you are logged on as $LOGNAME on $(hostname).\n\n"
   exit 0
fi

print "${REV}\n                                                                               "
print "                     Output from /maint/bin/systatus script                    "
print "                                                                               "
print "                     Run Time:                                                 "
print "                     $(date)                              "
print "                                                                               "
sleep 1
print "                     See Kris Anderson if you would like                       "
print "                     this script to include more checks.                       "
sleep 1
print "                                                                               ${NORM}\n"
sleep 1

if [ "$SERVERS_ALIVE" = SERVERS_ALIVE ]; then
   FUNC_SERVERS_ALIVE
fi

if [ "$LICENSE" = LICENSE ]; then
   FUNC_LICENSE
fi

if [ "$PROCESSES" = PROCESSES ]; then
   FUNC_PROCESSES
fi

if [ "$DISK" = DISK ]; then
   FUNC_DISK
fi

if [ "$ALL" = ALL ]; then
   FUNC_SERVERS_ALIVE
   FUNC_LICENSE
   FUNC_PROCESSES
   FUNC_DISK

   #  List of manual checks that need to be completed.
   print "${REV}\n\n          Check the following items on your own:                                  \c"
   print "         \n${NORM}"
   print "      1. Start the graphical ls_stat (License Status) and verify"
   print "         that licenses are OK."
   print "      2. Start a Motif CATIA session and verify that you connect "
   print "         to the mainframe database."
   print "      3. Start a Soft5080 session."
   print "      4. Review printed "System Daily Reports" for problems.  "
   print "         If problems are found, take appropriate steps to resolve"
   print "         the problem.\n"
   print "${REV}\n                        $(date)                                       ${NORM}\n"
fi

exit 0

# END
