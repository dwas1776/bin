#!/usr/bin/perl
######################################################################
#     Script: switch.pl                                              #
######################################################################
# (C) Copyright International Business Machines Corp. 2002.
# All rights reserved.
#
# This script has not been submitted to any formal IBM test and
# is distributed AS IS.  The use of this script or implementation
# of any of its techniques is a customer responsibility and depends
# on the customer's ability to evaluate and integrate them into the
# customer's operational environment.  This script has been reviewed
# by IBM for accuracy in a specific situation, but there is no
# guarantee that the same or similar results will be obtained
# elsewhere.
######################################################################


$debug = $reset = $noheader = 0;

while ( $ARGV[0] ) {
   if ( $ARGV[0] eq "-h" ) {
      print "Usage:\n\n  switch.pl [-r(eset stats)] [-n(o headers)]";
      print "[-d(ebug)]\n\n";
      exit(1); }
   elsif ( $ARGV[0] eq "-d" ) {
      $debug=1;
      print ("\nDebug mode enabled!\n");
      shift ( @ARGV ); }
   elsif ( $ARGV[0] eq "-r" ) {
      $reset=1;
      shift ( @ARGV ); }
   elsif ( $ARGV[0] eq "-n" ) {
      $noheader=1;
      shift ( @ARGV ); }
   else {
      print "Usage:\n\n  switch.pl [-r(eset stats)] [-n(o headers)]";
      print "[-d(ebug)]\n\n";
      exit(1); }
}

if ( $reset ) {
   @output = `/usr/lpp/ssp/css/estat -r css0 2>/dev/null `;
} else {
   @output = `/usr/lpp/ssp/css/estat css0 2>/dev/null `;
}

if ( $debug ) { print ("@output\n"); }

use Math::BigInt;

foreach ( @output ) {
   if ( /Elapsed/ ) {
      ($junk,$junk,$days,$junk,$hours,$junk,$minutes,$junk,$seconds) = split(/\s+/,$_);
      if ( ! $noheader ) { print ("$_\n"); }
      if ($debug) {
      print ("Days [$days], Hours[$hours], Minutes[$minutes], Seconds[$seconds]\n"); }
   } elsif ( /^Packets:/ ) {
      $tranpkts = $recvpkts = Math::BigInt->new("0");
      ($junk,$tranpkts,$junk,$recvpkts) = split(/\s+/,$_);
      if ($debug) {
      print ("Transmit pkts [$tranpkts], Receive pkts [$recvpkts]\n"); }
   } elsif ( /^Bytes:/ ) {
      $tranbytes = $recvbytes = Math::BigInt->new("0");
      ($junk,$tranbytes,$junk,$recvbytes) = split(/\s+/,$_);
      if ($debug) {
      print ("Transmit bytes [$tranbytes], Receive bytes [$recvbytes]\n"); }
   }

}

$totalseconds = $seconds + (60 * $minutes) + (3600 * $hours);
$totalseconds += 86400 * $days;
if ( ! $tranpkts ) { $tranpkts = 1 };
if ( ! $recvpkts ) { $recvpkts = 1 };
if ( ! $totalseconds ) { $totalseconds = 1 };
$avgtxfr = $tranbytes / $totalseconds;
$avgrcv = $recvbytes / $totalseconds;
$avgtpkt = $tranbytes / $tranpkts ;
$avgrpkt = $recvbytes / $recvpkts ;

#  Transmit AvgPktSize    Receive AvgPktSize
#    MBytes      bytes     MBytes      bytes
#10/17/2001 12:32      255.1        105      276.1        119

if ( ! $noheader ) {
   printf ("%17s %10s %10s %10s %10s\n","","Transmit","AvgPktSize","Receive","AvgPktSize");
   printf ("%-17s %10s %10s %10s %10s\n","Date & time ","MBytes","bytes","MBytes","bytes"); }

($junk,$min,$hour,$day,$mon,$year,$junk,$junk,$junk) = localtime;
print ($mon+1,"/$day/",$year+1900," $hour:$min ");
printf (" %10.1f %10.0f ",$tranbytes/1000000,$avgtpkt);
printf ("%10.1f %10.0f\n",$recvbytes/1000000,$avgrpkt);
