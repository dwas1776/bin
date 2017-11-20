#!/bin/ksh
#####################################################################
# tar a source host/file, cp to destination host, and untar it
#
# Syntax:  /userdata/b45/reports/bin/archive dhost:ddir shost:sdir filepat
# Example: archive rs0e01:/catia_ops/ecgl/rptdata/lsstat /tmp "lsstat_*"
#                        $1                               $2    $3
#
#####################################################################
# set -x
# set +x

function Help {
   print "Syntax:  $1 <-rm> dhost:ddir                             shost:sdir \"filepat\""
   print "Example: $1  -rm rs0e01:/catia_ops/ecgl/rptdata/lsstat rssrv06:/tmp \"lsstat_*\""
   print
   print "This example copies the rssrv06:/tmp/lsstat_* files to"
   print "the directory rs0e01:/catia_ops/ecgl/rptdata/lsstat"
   print
   print "Specifying the -rm flag causes the source files to be rm'ed after"
   print "the operation."
   exit 0
}

function ChkHost {
   if /etc/ping -c 1 $1 2>/dev/null >/dev/null; then
      : #hostname ok
   else
      print "Hostname $1 is not responding.  Script aborted..."
      exit 1
   fi
}

rm="0"
if [[ ${1#-} != $1 ]]; then	# -flags have been specified
   case $1 in
      "-rm") rm="1";;
       "-?") Help $0;;
          *) print "Invalid option: $1!  Script aborted..."
	     exit 1;;
   esac
   shift
fi

dhost=$(print "$1"|cut -d: -f1)
ddir=$(print "$1"|cut -d: -f2)
shost=$(print "$2"|cut -d: -f1)
sdir=$(print "$2"|cut -d: -f2)

if [[ "$shost" = "$sdir" ]]; then
   shost="$(hostname)"
fi
ChkHost $shost
ChkHost $dhost

if [[ -z "$3" ]]; then
   print "No file specified.  Abort!"
   exit 1
fi

#rsh $shost -n "cd ${sdir};tar -cf- $3" | rsh $dhost "cd ${ddir};tar -tf-"
#print "rsh $shost -n \"cd ${sdir};tar -cf- $3\" | rsh $dhost \"cd ${ddir};tar -tf-\""

# the old way:
#rsh $shost -n "cd ${sdir};tar -cf- $3" | rsh $dhost "cd ${ddir};tar -xf-"
# but, if the cd fails on $dhost, the tar -x will extract into the "/" root directory.
# instead, we want to skip the tar if the cd fails!
rsh $shost -n "cd ${sdir} && tar -cf- $3" | rsh $dhost "cd ${ddir} && tar -xf-"

if [[ $rm = "0" ]]; then
   print -- "rm flag not specified.  Removal not attempted..."
   exit 0
fi

bad=""
for fil in $(rsh $shost -n "cd ${sdir};ls -1 $3"); do
   if [[ -n $(rsh $dhost -n ls ${ddir}/${fil}) ]]; then
      print "removing $fil..."
      rsh $shost -n /usr/bin/rm ${sdir}/${fil}
   else
      print "$fil not found on $dhost; rm skipped..."
      bad="1"
   fi
done
if [[ -n $bad ]]; then
   print "One or more files not copied/removed..."
else
   print "All files copied and removed successfully..."
fi
exit 0
