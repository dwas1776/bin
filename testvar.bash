#!/bin/bash
#set -x
#set +x

if [[ "$OSTYPE" = linux-gnu ]]; then
   FLAVOR=$(grep ^NAME= /etc/os-release | cut -d= -f2)
else
   FLAVOR="\"$(echo $OSTYPE)\""
fi
echo "Operating system is $FLAVOR"
set +x 

if [ -z "$x" ]; then
   echo "The variable x is not defined."
else
   echo "The variable x is equal to $x"
fi

if [[ $x -eq 5 ]]; then
   echo "x equals 5"
else
   echo "x does NOT equal 5"
fi

if [[ "$x" = 5 ]]; then
   echo "x equals 5"
else
   echo "x does NOT equal 5"
fi

if [[ "$x" == 5 ]]; then
   echo "x equals 5"
else
   echo "x does NOT equal 5"
fi

# END
