#!/bin/bash
# check_hpprocurve.sh
# Copyright (C) 2016 Nagios Enterprises, LLC
# Version 1.1 - 11/15/2016
# Questions/issues should be posted on the Nagios
# Support Forum at https://support.nagios.com/forum/
# Feedback/recommendations/tips can be sent to
# Clint Kennedy rkennedy@nagios.com

# Help menu
print_help() {
echo "This plugin will check a HP Procurve switch for specific OID's"
echo "Flags:"
echo "-v        SNMP version"
echo "-c        Community string"
echo "-H        Host"
echo "-t        Check type (1 (load), 2 (uptime), 3 (interface status - requires i)"
echo "-t        Check type 4 (IfInBroad), 5 (IfOutBroad), 6 (IfOutMulti), 7 (IfInMulti), 8 (Excess Collissions)"
echo "-i        Interface (if required by type of check)"
echo "-C		Critical threshold (use to check if greater than or equal to)"
echo "-h        Help menu"
echo ""
echo "Example:"
echo "check_hpprocurve.sh -v 2c -c public -H 1.2.3.4 -t 1"
echo "check_hpprocurve.sh -v 2c -c public -H 1.2.3.4 -t 3 -i 21"
echo "check_hpprocurve.sh -v 2c -c public -H 1.2.3.4 -t 8 -i 21 -C 1"
exit 0
}

# Define input vars
while getopts "v:c:H:t:i:C:h" option
do
        case $option in
                v) vers=$OPTARG ;;
                c) comm=$OPTARG ;;
                H) host=$OPTARG ;;
                t) type=$OPTARG ;;
                i) int=$OPTARG;;
				C) crit=$OPTARG;;
                h) print_help 0
                exit 0 ;;
        esac
done

# Check input vars
if [ -z "$vers" ] || [ -z "$comm" ] || [ -z "$host" ] || [ -z "$type" ]; then
echo "Invalid parameters. Script requires a SNMP version, community string, host, and type. To access the help menu use the -h flag."
exit 2
elif [ $type -ge 3 ] && [ -z "$int" ]; then
echo "No interface number specified"
exit 2
fi

# Run check based on type

#CPU
if [ $type -eq 1 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.4.1.11.2.14.11.5.1.9.6.1.0)
checkresult=

#Uptime 
elif [ $type -eq 2 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.1.3.0)
uptimedays=$(echo $check | cut -d " " -f 5)
uptimehms=$(echo $check | cut -d " " -f 7)
critalert=$uptimedays
checkresult="Uptime is $uptimedays days $uptimehms"

#ifOperStatus
elif [ $type -eq 3 ]; then
check=$(snmpwalk -v $vers -c $comm $host ifOperStatus.$int)
upordown=$(echo $check | grep 'up' | wc -l)
if [ $upordown -eq 1 ]; then
checkresult="Interface $int is up."
critalert="0"
else
checkresult="Interface $int is unknown."
critalert="1"
fi

#ifInBroadcastPkts
elif [ $type -eq 4 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.31.1.1.1.3.$int)
critalert=$(echo $check | cut -d " " -f 4)
checkresult="ifInBroadcastPkts on interface $int is $critalert"

#ifOutBroadcastPkts
elif [ $type -eq 5 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.31.1.1.1.5.$int)
critalert=$(echo $check | cut -d " " -f 4)
checkresult="ifOutBroadcastPkts on interface $int is $critalert"

#ifOutMulticastPkts
elif [ $type -eq 6 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.31.1.1.1.4.$int)
critalert=$(echo $check | cut -d " " -f 4)
checkresult="ifOutMulticastPkts on interface $int is $critalert"

#ifInMulticastPkts
elif [ $type -eq 7 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.31.1.1.1.2.$int)
critalert=$(echo $check | cut -d " " -f 4)
checkresult="ifInMulticastPkts on interface $int is $critalert"

#Excessive Collisions
elif [ $type -eq 8 ]; then
check=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.10.7.2.1.9.$int)
critalert=$(echo $check | cut -d " " -f 4)
checkresult="Excessive collisions on interface $int is $critalert"
fi

#Check if crit var is empty
if [ -z "$crit" ]; then
state="OK"
stateexit="0"
elif [ $critalert -ge $crit ]; then
state="CRITICAL"
stateexit="2"
else
state="OK"
stateexit="0"
fi

echo "$state: $checkresult"
exit $stateexit