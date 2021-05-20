#!/bin/bash

set -e

cond_string_minute="$1"
cond_string_hour="$2"
cond_string_day="$3"
cond_string_month="$4"
cond_string_weekday="$5"

min_minute=0
max_minute=59
min_hour=0
max_hour=23
min_day=1
max_day=31
min_month=1
max_month=12
maxmax=100000


check_cond_interval(){
  if [[ $1 -lt $2 ]] || [[ $1 -gt $3 ]]; then
    echo "$cond_string not in range of $min $max"
    exit 1
  fi
}

check_cond(){
  cond_string=$1
  min=$2
  max=$3

  if [[ "$cond_string" =~ ^\*$ ]]; then
    return 0

  elif [[ "$cond_string" =~ ^[[:digit:]]+$ ]]; then
    check_cond_interval $cond_string $min $max

  elif [[ "$cond_string" =~ , ]]; then
    list_cond=( $(echo $cond_string | tr ',' ' ') )
    for el in "${list_cond[@]}"; do
      #echo $el
      check_cond_interval $el $min $max
    done

  elif [[ "$cond_string" =~ - ]]; then
    leftlimit=$(echo $cond_string | cut -d '-' -f1)
    rightlimit=$(echo $cond_string | cut -d '-' -f2)

    check_cond_interval $leftlimit $min $max
    check_cond_interval $rightlimit $min $max

  elif [[ "$cond_string" =~ ^\*/[[:digit:]]+$ ]]; then
    freq=$(echo $cond_string | cut -d '/' -f2)
    check_cond_interval $freq $min $maxmax

  else 
    echo "Error interpreting $cond_string"
    exit 1
  fi
}


check_cond_minute(){
  check_cond "$1" $min_minute $max_minute
}

check_cond_hour(){
  check_cond "$1" $min_hour $max_hour
}

check_cond_day(){
  check_cond "$1" $min_day $max_day
}

check_cond_month(){
  check_cond "$1" $min_month $max_month
}

#check_cond_weekday(){
#}

find_gcd(){
  ! (( $1 % $2 )) && gcd=$2 || find_gcd $2 $(( $1 % $2 ))
}

find_lcm(){
  find_gcd $1 $2
  lcm=$(( $1 * $2 / gcd ))
}

generate_cond(){
  cond_string="$1"
  min=$2
  max=$3

  if [[ "$cond_string" =~ ^\*$ ]]; then
    cond=( "*" )

  elif [[ "$cond_string" =~ ^[[:digit:]]+$ ]]; then
    cond=( "$cond_string" )

  elif [[ "$cond_string" =~ , ]]; then
    cond=( $(echo "$cond_string" | tr ',' ' ') )

  elif [[ "$cond_string" =~ - ]]; then
    leftlimit=$(echo "$cond_string" | cut -d '-' -f1)
    rightlimit=$(echo "$cond_string" | cut -d '-' -f2)

    if [[ $leftlimit -eq $rightlimit ]]; then
      cond=( $leftlimit )
    elif [[ $leftlimit -lt $rightlimit ]]; then
      cond=( $(seq $leftlimit $rightlimit ) )
    elif [[ $leftlimit -gt $rightlimit ]]; then
      cond=( $(seq $min $rightlimit) $(seq $leftlimit $max) )
    fi

  elif [[ "$cond_string" =~ ^\*/[[:digit:]]+$ ]]; then
    freq=$(echo "$cond_string" | cut -d '/' -f2)
    [[ $min -eq 0 ]] && card=$((max + 1)) || card=$max
    find_lcm $freq $card
    cond=( $(seq $min $freq $lcm ) )

  else 
    echo "Error interpreting $cond_string"
    exit 1
  fi
}

generate_cond_minute(){
  generate_cond "$1" $min_minute $max_minute
  minute_cond="${cond[@]}"
}

generate_cond_hour(){
  generate_cond "$1" $min_hour $max_hour
  hour_cond="${cond[@]}"
}

generate_cond_day(){
  generate_cond "$1" $min_day $max_day
  day_cond="${cond[@]}"
}

generate_cond_month(){
  generate_cond "$1" $min_month $max_month
  month_cond="${cond[@]}"
}

#generate_cond_weekday(){
##  generate_cond $1 $min_minute $max_minute 
##  minute_cond="${cond[@]}"
#}

validate_cond(){
  cond_string="$1"
  cron_cond="${!2}"
  echo cron_cond: $cron_cond
  var=$3
  var_counter=$4

  if [[ "$cond_string" =~ ^\*$ ]]; then
    return_val=0
  elif [[ "$cond_string" =~ ^\*/[[:digit:]]+$ ]]; then
    lcm="${cron_cond##* }" # get lcm at last position of cron_cond 
    var_counter_modulo=$((var_counter % lcm))
    regex='\b'$var_counter_modulo'\b'
    [[ "$cron_cond" =~ $regex ]] && return_val=0 || return_val=1
  else
    regex='\b'$var'\b'
    [[ "$cron_cond" =~ $regex ]] && return_val=0 || return_val=1
  fi
}

validate_cond_minute(){
  validate_cond "$cond_string_minute" "minute_cond" $minute $minute_counter
  valid_minute=$return_val
}

#validate_cond_hour(){
#}
#
#validate_cond_day(){
#}
#
#validate_cond_month(){
#}


if [[ "$0" =~ cronfront\.sh ]]; then
check_cond_minute "$1" 
check_cond_hour "$2"
check_cond_day "$3"
check_cond_month "$4"

generate_cond_minute "$1" 
generate_cond_hour "$2"
generate_cond_day "$3"
generate_cond_month "$4"

minute_counter=0
hour_counter=0
day_counter=1
month_counter=1

while true
do
  read -r -a now_date <<< $(date -u +"%M %H %d %m");
  minute="${now_date[0]}"
  hour="${now_date[1]}"
  day="${now_date[2]}"
  month="${now_date[3]}"
  echo "date: ${now_date[@]}"
  echo "counters: $minute_counter $hour_counter $day_counter $month_counter"

  validate_cond_minute 
  validate_cond_hour
  validate_cond_day
  validate_cond_month
  echo output: $valid_minute
  #validate_cond_minute && validate_cond_hour && validate_cond_day && validate_cond_month 

  sleep 60
  minute_counter=$((minute_counter + 1))
  ! ((minute_counter % 60)) && hour_counter=$((hour_counter + 1))
  ! ((minute_counter % 1440)) && day_counter=$((day_counter + 1))
  ! ((minute_counter % 44640)) && month_counter=$((month_counter + 1))
done
fi
