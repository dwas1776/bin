#!/bin/ksh
#########|#########|#########|#########|#########|#########|#########|#########|
# NAME
#    sdate
#
# SYNOPSIS
#    Input: sdate n (e.g. sdate 5)
#    Output Form: Month Day Year
#
# Description
#    prints the date "n" days ago, where n is the argument.
#
#########|#########|#########|#########|#########|#########|#########|#########|
# REVISIONS
#    20020301  DW  creation date
#
#########|#########|#########|#########|#########|#########|#########|#########|
#set -x

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

# Subtract n from the current day.
day=`expr $day - $n`

# While the day is less than or equal to
# 0, decrement the month.
while [ $day -le 0 ]
do
  month=`expr $month - 1`

  # If month is 0 then it is Dec of last year.
  if [ $month -eq 0 ]; then
    year=`expr $year - 1`
    month=12
  fi

  # Add the number of days appropriate to the
  # month.
  case $month in
    1|3|5|7|8|10|12) day=`expr $day + 31`;;
    4|6|9|11) day=`expr $day + 30`;;
    2)
      if [ `expr $year % 4` -eq 0 ]; then
        if [ `expr $year % 400` -eq 0 ]; then
          day=`expr $day + 29`
        elif [ `expr $year % 100` -eq 0 ]; then
          day=`expr $day + 28`
        else
          day=`expr $day + 29`
        fi
      else
        day=`expr $day + 28`
      fi
    ;;
  esac
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
