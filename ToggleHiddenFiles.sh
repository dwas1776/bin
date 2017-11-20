#!/bin/bash
# set -x
# set +x
#####################################################################
# NAME:
#   ToogleHiddenFiles -- Finder: toggle curren show/hide dot files
#
# SYNOPSIS:
#   ToogleHiddenFiles
#
# DESCRIPTION:
#   For Mac OS X, toogle the Finder's current behavior to either
#   show or hide dot files.
#
#####################################################################
# REVISIONS:
#   20170930 DW creation date
#
#####################################################################
usage() {
    echo "syntax error, exiting without making any changes..."
    sleep 1
    exit 0
}

CSTATE=$(defaults read com.apple.finder AppleShowAllFiles)

case $CSTATE in
    YES ) NSTATE=hide ;;
    NO  ) NSTATE=show ;;
esac

echo ""
echo "WARNING:  This will toggle the Finder to $NSTATE dot files"
echo "          It will then RELAUNCH the Finder."
echo "          Are you sure you want to proceed?"
echo ""
read -p "[y/n]:   " answer
echo ""
answer=${answer:-n}
if [ "${answer}" = n ]; then
    echo "exiting without making any changes..."
    sleep 1
    exit 0
fi

case $CSTATE in
    YES ) defaults write com.apple.finder AppleShowAllFiles NO
          killall -TERM Finder
          ;;
    NO  ) defaults write com.apple.finder AppleShowAllFiles YES
          killall -TERM Finder
          ;;
    *   )
          usage
          ;;
esac

# END
