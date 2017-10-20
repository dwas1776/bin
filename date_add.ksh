#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
# NAME:
#    adate
#
# SYNOPSIS
#    Input: adate n (e.g. adate 5)
#
# Descripton
#    prints the date n days in the future
# 	    Input: adate n (e.g. adate 5)
# 	    Output Form: Month Day Year
#
#########|#########|#########|#########|#########|#########|#########|#########|
# REVISIONS:
#   20020301  DW  creation date
#
#########|#########|#########|#########|#########|#########|#########|#########|
# set -x

# Check that the input is valid.
# There should be exactly 1 argument.
if [ $# -ne 1 ]; then
  echo Error: $0 invalid usage.
  echo Usage: $0 n
  exit 1
fi

# The argument should be an integer.
n=`expr $1 + 0 2> /dev/null`
if [ $? -ne 0 ]; then
  qnbad=0
elif [ $n -lt 0 ]; then
  qnbad=0
else
  qnbad=1
fi
if [ $qnbad -eq 0 ]; then
  echo Error: n must be a positive integer.
  echo Usage: $0 n
  exit 1
fi

# Set the current month day and year.
month=`date +%m`
day=`date +%d`
year=`date +%Y`

# Add 0 to month. This is a
# trick to make month an unpadded integer.
month=`expr $month + 0`

# Add n to the current day.
day=`expr $day + $n`

# Add months and subtract days until
# the future date is reached.
while [ true ]
do
  # Determine the number of days in the
  # current month.
  case $month in
    1|3|5|7|8|10|12) cmday=31;;
    4|6|9|11) cmday=30;;
    2)
      if [ `expr $year % 4` -eq 0 ]; then
        if [ `expr $year % 400` -eq 0 ]; then
          cmday=29
        elif [ `expr $year % 100` -eq 0 ]; then
          cmday=28
        else
          cmday=29
        fi
      else
        cmday=28
      fi
    ;;
  esac

  # If the day is greater than the number
  # of days in the current month then
  # month is incremented; otherwise we are done.
  if [ $day -gt $cmday ]; then
    day=`expr $day - $cmday`
    month=`expr $month + 1`

    # If the month is 13 then it is jan of
    # next year.
    if [ $month -eq 13 ]; then
      month=1
      year=`expr $year + 1`
    fi
  else
    break
  fi
done

# Print the month day and year.
echo $month $day $year


# Print in standard format
case $month in
  1 ) MONTH=Jan ;;
  2 ) MONTH=Feb ;;
  3 ) MONTH=Mar ;;
  4 ) MONTH=Apr ;;
  5 ) MONTH=May ;;
  6 ) MONTH=Jun ;;
  7 ) MONTH=Jul ;;
  8 ) MONTH=Aug ;;
  9 ) MONTH=Sep ;;
 10 ) MONTH=Oct ;;
 11 ) MONTH=Nov ;;
 12 ) MONTH=Dec ;;
esac

print $MONTH $day, $year

# END
