#!/usr/bin/perl -w
#########|#########|#########|#########|#########|#########|#########|#########|
#                                                                              
#  FILENAME:      mkprinter                                                   
#  DATE CREATED:  May 25, 2005                                                
#  AUTHOR:        David A. Wasmer                                             
#  PURPOSE:       make standard "type" printers                               
#  SYNTAX:        mkprinter -q queuename [ -d driver ] [ -t type ] [ -h ]                         
#   
#
#  REVISION HISTORY:                                                                    
#  =========================================================================
#  05/25/2005 - daw - translated previous Korn shell script to Perl.
#                   - added printer type for remote CATIA printers. 
# 
#
#########|#########|#########|#########|#########|#########|#########|#########|

#############################
#  DECALRE VARIABLES 
#  & SUBROUTINES
#############################
sub Help();
sub Jetdirectq();
sub Remoteq(); 
sub TestPage(); 

use vars qw ( $help $queue $type $driver $information $logname );
$queue  = undef      ;
$type   = "STD"      ;

#############################
#  PARSE OPTIONS
#############################
use Getopt::Long;
GetOptions
    (  "help"          => \$help 
    ,  "queue=s"       => \$queue
    ,  "type=s"        => \$type
    ,  "driver=s"      => \$driver
    ,  "information=s" => \$information
    ) ;

$help           and Help();

#############################
# Is $LOGNAME authorized?
#############################
   chomp($logname = `whoami`) ;
   if ( $logname ne "dwasmer" ) { die "\nERROR:\tYou must be root to run this program.\n\tYou are currently logged on as $logname.\n\n\tAborting with no changes...\n\n" ; }


#############################
# Verify Queue Name Is Ok
#############################
   # Require queue name option.
   if ( ! $queue ) { print "\nERROR:\tYou must provide a queue name.\n\tAborting...\n\n"; Help();}

   # Verify queue name is resolvable to IP address.
   if (! `host $queue`) { die "\nERROR:\tCannot resolve \"$queue\" queue name to an IP address.\n\tDid you forget to make an entry in the /etc/hosts file?\n\n\tAborting with no changes...\n\n" ; }

   # Verify queue, or one of its alises, does not already exist.
   chomp($hostaliases = `host $queue | sed "s/,//g"`) ;
   @aliases = split (' ', $hostaliases) ;
   @cut = splice @aliases, 1, 3 ;
   for ($i=0; $i<=$#aliases; $i++)
      {
      $rcode = system ("enq -WesP $aliases[$i] >/dev/null 2>&1");
      if ( $rcode == 0  )
         {
         if ( $queue eq $aliases[$i] ) { die "\nERROR:\tThe printer queue \"$queue\" already exists.\n\tIt resolves to the IP address of $cut[1].\n\n\tAborting with no changes...\n\n" ;}
         else { die "\nERROR:  The queue name \"$queue\" is aliased to \"$aliases[$i]\" \n\tand the \"$aliases[$i]\" printer queue already exists. \n\tBoth names resolve to the IP address of $cut[1].\n\n\tAborting with no changes...\n\n" ; }
         }
      }


#############################
# Verify Type Is Ok
#############################
   @allowed_types = qw/ STD W2 CATIA /;
   undef %is_type;
   for (@allowed_types) { $is_type{$_} = 1 ; }
   if ( ! defined $is_type{$type} ) { die "\nERROR:\tType \"$type\" is an invalid printer configuration type.\n\tPlease use one of the following configuration types: \n\n\t\t@allowed_types\n\n\n\tAborting with no changes...\n\n"; }
   if ( $type eq "CATIA" ) { Remoteq() ; }


#############################
# Verify Driver is installed
#############################
   if ( ! defined $driver ) { $driver = "hplj-5si" ; }
   system "lslpp -l printers.${driver}.rte 1>/dev/null" and die "\nERROR:\tThe driver \"$driver\" is not installed on this system.\n\tEither install the driver or choose a different driver.\n\n\tAborting with no changes...\n\n" ;
   Jetdirectq(); 


#########|#########|#########|#########|#########|#########|#########|#########|
#########|#########|#########|#########|#########|#########|#########|#########|
#########|#########|#########|#########|#########|#########|#########|#########|


#############################
sub Help ()
{ print  <<end_of_help;
USAGE:

   mkprinter [ -queue name ] [ -driver name ] [ -type name ] [ -help ] 

end_of_help
exit ;
}


#############################
sub Jetdirectq ()
   {
   print "\n" ;
   if ( defined $information ) { print "NOTE:\tYou provided printer information (description),\n\tbut information is only needed when making\n\tremote CATIA printer queues.\n\tThe information provided will be ignored.\n\n\tContinuing...\n\n" ; }
   print "/usr/lib/lpd/pio/etc/piomkjetd mkpq_jetdirect -p $driver -D pcl -q $queue -h $queue -x 9100 \n" ;
   if ( $type eq W2 ) { print "/usr/lib/lpd/pio/etc/piochpq  -q $queue -d hp\@$queue -l 180 -w 180 \n" ; }
   else { print "/usr/lib/lpd/pio/etc/piochpq  -q $queue -d hp\@$queue -l 180 -w 180 -d p -j 0 -J '!' -Z '!' \n" ; }
   TestPage();
   }


#############################
sub Remoteq () 
   { 
   if ( ! defined $information ) { die "\nERROR:\tYou must provide some information (description) about the printer.\n\tAt a minimum, please include the manufacturer\'s name\n\tand the printer\'s location.  Don't forget to quote \n\tyour text string!\n\n\tAborting with no changes...\n\n" ; } 
   if ( defined $driver ) { print "\nNOTE:\tYou provided a driver, but drivers are not\n\tneeded to create remote printer queues.\n\tIt will be ignored.\n\n\tContinuing...\n\n" ; }
   print "/usr/lib/lpd/pio/etc/piomisc_ext mkpq_remote_ext -q $queue -h $queue -r raw -t aix -d \"$information\"\n" ;
   TestPage(); 
   }


#############################
sub TestPage () 
   {
   print "/usr/local/bin/TestPage  $queue\n" ;
   sleep(2);
   print "enq -WP $queue\n" ;
   exit ;
   }


#############################
#  END
#############################
