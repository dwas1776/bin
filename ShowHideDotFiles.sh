#!/bin/bash
# set -x
# set +x
#####################################################################
# NAME:
#   ShowHideDotFiles -- Finder: show/hide dot files
#
# SYNOPSIS:
#   ShowHideDotFiles -y
#   ShowHideDotFiles -n
#
# DESCRIPTION:
#   For Mac OS X, change the Finder to show or hide dot files.
#
#####################################################################
# REVISIONS:
#   20170930 DW creation date
#
#####################################################################
ACTION=0

usage() {
    echo "Usage:"
    echo ""
    echo "  ShowHideDotFiles [yn]"
    echo "     -y  show dot files in the Finder"
    echo "     -n  hide dot files in the Finder"
    echo ""
    exit 0
}

warning() {
    ACTION=$1
    if [ "${ACTION}" = YES ]; then
        TEXT=show
    elif [ "${ACTION}" = NO ]; then
        TEXT=hide
    else
        usage
    fi
    echo ""
    echo "WARNING:  This will $TEXT dot files in the Finder and then"
    echo "          RELAUNCH the Finder. Are you sure you want to proceed?"
    echo ""
    read -p "[y/n]:   " answer
    echo ""
    answer=${answer:-n}
    if [ "${answer}" = n ]; then
        echo "exiting without making any changes..."
        sleep 1
        exit 0
    fi
    defaults write com.apple.finder AppleShowAllFiles $ACTION
    killall -TERM Finder
}

####################
#   GETOPTS
####################
while getopts ":yn" opt; do
    case $opt in
        y)  warning YES
            ;;
        n)  warning NO
            ;;
        *)  usage
            ;;
    esac
done
shift $(($OPTIND - 1))

if [ "$ACTION" = 0 ]; then
    usage
    exit 0
fi

# END
