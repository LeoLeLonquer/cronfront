#!/bin/bash

set -e

min_minute=0
max_minute=59
min_hour=0
max_hour=23
min_day=1
max_day=31
min_month=1
max_month=12
min_weekday=1
max_weekday=7

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
    [[ $freq -lt $min ]] && echo "freq $freq under $min" && exit 1 || true

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

check_cond_weekday(){
  check_cond "$1" $min_weekday $max_weekday 
}

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
    cond=''

  elif [[ "$cond_string" =~ ^[[:digit:]]+$ ]]; then
    cond="$cond_string"

  elif [[ "$cond_string" =~ , ]]; then
    cond=$(echo "$cond_string" | tr ',' ' ')

  elif [[ "$cond_string" =~ - ]]; then
    leftlimit=$(echo "$cond_string" | cut -d '-' -f1)
    rightlimit=$(echo "$cond_string" | cut -d '-' -f2)

    if [[ $leftlimit -eq $rightlimit ]]; then
      cond="$leftlimit"
    elif [[ $leftlimit -lt $rightlimit ]]; then
      cond="$(seq -s' ' $leftlimit $rightlimit )"
    elif [[ $leftlimit -gt $rightlimit ]]; then
      cond="$(seq -s' ' $min $rightlimit) $(seq -s' ' $leftlimit $max)"
    fi

  elif [[ "$cond_string" =~ ^\*/[[:digit:]]+$ ]]; then
    freq=$(echo "$cond_string" | cut -d '/' -f2)
    [[ $min -eq 0 ]] && card=$((max + 1)) || card=$max
    find_lcm $freq $card
    shifted_lcm=$((lcm + $min))
    cond="$(seq -s' ' $min $freq $shifted_lcm)" 

  else 
    echo "Error interpreting $cond_string"
    exit 1
  fi
}

generate_cond_minute(){
  generate_cond "$1" $min_minute $max_minute
  minute_cond="$cond"
}

generate_cond_hour(){
  generate_cond "$1" $min_hour $max_hour
  hour_cond="$cond"
}

generate_cond_day(){
  generate_cond "$1" $min_day $max_day
  day_cond="$cond"
}

generate_cond_month(){
  generate_cond "$1" $min_month $max_month
  month_cond="$cond"
}

generate_cond_weekday(){
  generate_cond $1 $min_weekday $max_weekday
  weekday_cond="$cond"
}

validate_cond(){
  cond_string="$1"
  cron_cond="$2"
  var=$3
  var_counter=$4

  if [[ "$cond_string" =~ ^\*$ ]]; then
    return_val=0
  elif [[ "$cond_string" =~ ^\*/[[:digit:]]+$ ]]; then
    shifted_lcm="${cron_cond##* }" # get shifted_lcm at last position of cron_cond 
    min="${cron_cond%% *}" # get min at first position of cron_cond
    lcm=$((shifted_lcm - $min))
    
    var_counter_modulo=$((var_counter % adjusted_lcm))
    regex='\b'$var_counter_modulo'\b'
    [[ "$cron_cond" =~ $regex ]] && return_val=0 || return_val=1
  else
    regex='\b'$var'\b'
    [[ "$cron_cond" =~ $regex ]] && return_val=0 || return_val=1
  fi
}

validate_cond_minute(){
  validate_cond "$cond_string_minute" "$minute_cond" $minute $minute_counter
  valid_minute=$return_val
}

validate_cond_hour(){
  validate_cond "$cond_string_hour" "$hour_cond" $hour $hour_counter
  valid_hour=$return_val
}

validate_cond_day(){
  validate_cond "$cond_string_day" "$day_cond" $day $day_counter
  valid_day=$return_val
}

validate_cond_month(){
  validate_cond "$cond_string_month" "$month_cond" $month $month_counter
  valid_month=$return_val
}

validate_cond_weekday(){
  validate_cond "$cond_string_weekday" "$weekday_cond" $weekday $weekday_counter
  valid_weekday=$return_val
}

if [[ "$0" =~ cronfront\.sh ]]; then
cron_cond_string="$1"
#cond_string_seconds="$1"
cond_string_minute="$(echo "$cron_cond_string" | cut -d ' ' -f1)"
cond_string_hour="$(echo "$cron_cond_string" | cut -d ' ' -f2)"
cond_string_day="$(echo "$cron_cond_string" | cut -d ' ' -f3)"
cond_string_month="$(echo "$cron_cond_string" | cut -d ' ' -f4)"
cond_string_weekday="$(echo "$cron_cond_string" | cut -d ' ' -f5)"
shift
commands=$@

check_cond_minute "$cond_string_minute" 
check_cond_hour "$cond_string_hour"
check_cond_day "$cond_string_day"
check_cond_month "$cond_string_month"
check_cond_weekday "$cond_string_weekday"

generate_cond_minute "$cond_string_minute" 
generate_cond_hour "$cond_string_hour"
generate_cond_day "$cond_string_day"
generate_cond_month "$cond_string_month"
generate_cond_weekday "$cond_string_weekday"

minute_counter=$min_minute
hour_counter=$min_hour
day_counter=$min_day
month_counter=$min_month
weekday_counter=$min_weekday

while true
do
  read -r -a now_date <<< $(date -u +"%M %H %d %m %w");
  minute="${now_date[0]}"
  hour="${now_date[1]}"
  day="${now_date[2]}"
  month="${now_date[3]}"
  weekday=$(( "${now_date[4]}" + 1 ))
  echo "date: $minute $hour $day $month $weekday"
  echo "counters: $minute_counter $hour_counter $day_counter $month_counter"

  validate_cond_minute 
  validate_cond_hour
  validate_cond_day
  validate_cond_month
  validate_cond_weekday
  if ! (( $valid_minute + $valid_hour + $valid_day + $valid_month + $valid_weekday)); then
    eval "$commands &"
  fi

  sleep 60
  minute_counter=$((minute_counter + 1))
  ! ((minute_counter % 60)) && hour_counter=$((hour_counter + 1))
  ! ((minute_counter % 1440)) && day_counter=$((day_counter + 1))
  ! ((minute_counter % 44640)) && month_counter=$((month_counter + 1))
  ! ((minute_counter % 10080)) && weekday_counter=$((weekday_counter + 1))
done
fi
