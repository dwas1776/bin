exit 0

Here are some getopts examples to help me get the syntax correct.


#  Examples
#  ================

#  The following getopts command specifies that a, b, and c are valid options, 
#  and that options a and c have arguments:

    getopts a:bc: OPT


#  The following getopts command specifies that a, b, and c are valid options, 
#  that options a and b have arguments, and that getopts set the value of OPT 
#  to ? when it encounters an undefined option on the command line:

    getopts :a:b:c OPT

#  The following script parses and displays it arguments:

==============================================================================
#!/bin/bash

usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

while getopts ":s:p:" o; do
    case "${o}" in
        s)
            s=${OPTARG}
            ((s == 45 || s == 90)) || usage
            ;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${p}" ]; then
    usage
fi

echo "s = ${s}"
echo "p = ${p}"


############
Example runs:

$ ./myscript.sh
Usage: ./myscript.sh [-s <45|90>] [-p <string>]

$ ./myscript.sh -h
Usage: ./myscript.sh [-s <45|90>] [-p <string>]

$ ./myscript.sh -s "" -p ""
Usage: ./myscript.sh [-s <45|90>] [-p <string>]

$ ./myscript.sh -s 10 -p foo
Usage: ./myscript.sh [-s <45|90>] [-p <string>]

$ ./myscript.sh -s 45 -p foo
s = 45
p = foo

$ ./myscript.sh -s 90 -p bar
s = 90
p = bar



==============================================================================
#!/bin/bash

aflag=
bflag=

while getopts ab: name; do

  case $name in
    a)  aflag=1;;

    b)  bflag=1
        bval="$OPTARG";;

    ?)  printf "Usage: %s: [-a] [-b value] args\n" $0
        exit 2;;
  esac
done

if [ ! -z "$aflag" ]; then
   printf "Option -a specified\n"
fi
 
if [ ! -z "$bflag" ]; then
   printf 'Option -b "%s" specified\n' "$bval"
fi
 
shift $(($OPTIND -1))
printf "Remaining arguments are: %s\n" "$*"

# if you begin the option letter string with a colon, getopts won't print the
# message. You should specify the colon and provide your own error message by
# using the handle ?.
#    getopts ":i" 
# This feature is necessary because you cannot redirect getopts standard error
# to /dev/null....  it results in a core dump.
