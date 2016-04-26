#!/bin/bash
# check_hpprocurve.sh
# Copyright (C) 2016 Nagios Enterprises, LLC
# Version 1.0 - 04/26/2016
# Questions/issues should be posted on the Nagios
# Support Forum at https://support.nagios.com/forum/
# Feedback/recommendations/tips can be sent to
# Robert Kennedy (Clint) rkennedy@nagios.com

# Help menu
print_help() {
echo "This plugin will check a HP Procurve switch for specific OID's"
echo "Flags:"
echo "-v        SNMP version"
echo "-c        Community string"
echo "-H        Host"
echo "-t        Check type (1 (load), 2 (uptime), 3 (interface status - requires i)"
echo "-i        Interface (if required by type of check)"
echo "-h        Help menu"
echo ""
echo "Example:"
echo "check_hpprocurve.sh -v 2c -c public -H 1.2.3.4 -t 1"
echo "check_hpprocurve.sh -v 2c -c public -H 1.2.3.4 -t 3 -i 21"
exit 0
}

# Define input vars
while getopts "v:c:H:t:i:h" option
do
        case $option in
                v) vers=$OPTARG ;;
                c) comm=$OPTARG ;;
                H) host=$OPTARG ;;
                t) type=$OPTARG ;;
                i) int=$OPTARG;;
                h) print_help 0
                exit 0 ;;
        esac
done

# Check input vars
if [ -z "$vers" ] || [ -z "$comm" ] || [ -z "$host" ] || [ -z "$type" ]; then
echo "Invalid parameters. Script requires a SNMP version, community string, host, and type. To access the help menu use the -h flag."
exit 0
elif [ $type -eq 3 ] && [ -z "$int" ]; then
echo "No interface number specified"
exit 0
fi

# Run check based on type
if [ $type -eq 1 ]; then
load=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.4.1.11.2.14.11.5.1.9.6.1.0)
echo "$load"
elif [ $type -eq 2 ]; then
upti=$(snmpwalk -v $vers -c $comm $host 1.3.6.1.2.1.1.3.0)
echo "$upti"
elif [ $type -eq 3 ]; then
intstat=$(snmpwalk -v $vers -c $comm $host ifOperStatus.$int)
echo "$intstat"
fi
exit 0