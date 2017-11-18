#!/bin/bash
# set -x
# set +x
###############################################################################
# NAME:
#    XmasCountDown
#
# SYNOPSIS
#    XmasCountDown
#
# Descripton
#    calculated the number of shopping days remaining until Christmas.
#
###############################################################################


# text formating
BOLD=$(tput bold)
DIM=$(tput dim)
REVRS=$(tput rev)
NORML=$(tput sgr0)

# dates
JULIAN=$(date +%j)
SHOPDAYS=$(expr 359 - $(date +%j))

# print
printf  "\n${REVRS}  $SHOPDAYS more shopping days till Christmas!  "
printf  "${NORML}\n\n"

# END
