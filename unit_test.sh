#!/bin/bash

set -ex

. cronfront.sh

print_red(){
  echo -e "\e[31m${@}\e[0m"
}

print_green(){
  echo -e "\e[32m${@}\e[0m"
}

print_bold(){
  echo -e "\e[1m${@}\e[0m"
}

read -r -a now_date <<< $(date -u +"%M %H %d %m");
minute="${now_date[0]}"
hour="${now_date[1]}"
day="${now_date[2]}"
month="${now_date[3]}"

minute_counter=0
hour_counter=0
day_counter=1
month_counter=1
weekday_counter=$min_weekday

echo "date: ${now_date[@]}"
echo "counters: $minute_counter $hour_counter $day_counter $month_counter"

echo ""
print_bold 'test * - 1'
cond_string_minute='*'
print_green "$cond_string_minute"
minute_counter=1
expected_output=0
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test */3 - 0"
cond_string_minute="*/3"
minute_counter=0
expected_output=0
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test */3 - 21"
cond_string_minute="*/3"
minute_counter=21
expected_output=0
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test */3 - 1"
cond_string_minute="*/3"
minute_counter=1
expected_output=1
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test 1,2,3 - 1"
cond_string_minute="1,2,3"
minute=1
expected_output=0
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test 1,2,3 - 1"
cond_string_minute="1,2,3"
minute=5
expected_output=1
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test 1-15 - 10"
cond_string_minute="1-15"
minute=10
expected_output=0
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test 1-15 - 20"
cond_string_minute="1-15"
minute=20
expected_output=1
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test 50-15 - 10"
cond_string_minute="50-15"
minute=10
expected_output=0
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test 50-15 - 10"
cond_string_minute="50-15"
minute=20
expected_output=1
check_cond_minute "$cond_string_minute" 
generate_cond_minute "$cond_string_minute" 
validate_cond_minute 
echo "cron_cond: $cron_cond"
output=$valid_minute
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test weekday 1 - 1"
cond_string_weekday="1"
weekday=1
expected_output=0
check_cond_weekday "$cond_string_weekday" 
generate_cond_weekday "$cond_string_weekday" 
validate_cond_weekday 
echo "cron_cond: $cron_cond"
output=$valid_weekday
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"

echo ""
print_bold "test weekday */2 - 1"
cond_string_weekday="*/3"
weekday=1
expected_output=0
check_cond_weekday "$cond_string_weekday" 
generate_cond_weekday "$cond_string_weekday" 
validate_cond_weekday 
echo "cron_cond: $cron_cond"
output=$valid_weekday
[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"



#echo ""
#print_bold "test 0-4/2 - 2"
#cond_string_minute='0-4/2'
#minute=2
#minute_counter=1
#expected_output=0
#check_cond_minute "$cond_string_minute" 
#generate_cond_minute "$cond_string_minute" 
#validate_cond_minute 
#echo "cron_cond: $cron_cond"
#output=$valid_minute
#[[ $output -eq $expected_output ]] && print_green "SUCCESS" || print_red "FAILED"










#echo "test 1"
#generate_cond "1" 0 59
#generate_cond 1000 0 59
#echo "test *"
#generate_cond "*" 0 59
#echo "test 1,2"
#generate_cond 1,2 0 59
#generate_cond 1,2,5,6,1000 0 59
#echo "test 1-2"
#generate_cond "1-9" 0 59
#generate_cond "50-10" 0 59
#generate_cond "1-1" 0 59
#generate_cond "*/5" 0 59
#generate_cond "*/25" 0 59

#find_gcd 25 60
#echo $gcd
#find_lcm 25 60
#echo $lcm
#generate_cond "*/5" 0 59
#generate_cond "*/25" 0 59
#generate_cond "*/500" 0 59
