#!/bin/bash
# check_netstat.sh
# Copyright (C) 2016 Nagios Enterprises, LLC
# Version 1.0 - 03/31/2016
# Questions/issues should be posted on the Nagios
# Support Forum at https://support.nagios.com/forum/
# Feedback/recommendations/tips can be sent to
# Robert Kennedy (Clint) rkennedy@nagios.com

# Help menu
print_help() {
echo "This plugin will check netstat (netstat -an|grep :port|wc -l) for the specified port."
echo "Flags:"
echo "-p        Port to check"
echo "-w        Warning value"
echo "-c        Critical Value"
echo "-h        Help menu"
echo ""
echo "Example:"
echo "check_netstat.sh -p 80 -w 5 -c 10"
echo "This will report OK if less than 5 connections, WARNING if 5-10, and CRITICAL if greater than 10."
exit 0
}

# Define input vars
while getopts "p:w:c:h" option
do
        case $option in
                p) port=$OPTARG ;;
                w) warn=$OPTARG ;;
                c) crit=$OPTARG ;;
                h) print_help 0
                exit 0 ;;
        esac
done

# Check input vars
if [ -z "$warn" ] || [ -z "$crit" ] || [ -z "$port" ]; then
echo "Invalid parameters. Script requires a port, warning, and critical. To access the help menu use the -h flag."
exit 0
fi

# Set vars
netstat=$(which netstat)
count=$($netstat -an | grep :$port | wc -l)

# Check Netstat count value
if [ $count -lt $warn ]
then
        state="OK"
                ecode=0
elif [ $count -ge $warn ] && [ $count -lt $crit ]
then
        state="WARNING"
                ecode=1
elif [ $count -ge $crit ]
then
        state="CRITICAL"
                ecode=2
else
        state="UNKNOWN"
                ecode=3
fi
echo "$state: $count|count=$count"
exit $ecode
