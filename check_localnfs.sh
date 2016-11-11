#!/bin/bash
# check_localnfs.sh
# Copyright (C) 2016 Nagios Enterprises, LLC
# Version 1.0 - 11/11/2016
# Questions/issues should be posted on the Nagios
# Support Forum at https://support.nagios.com/forum/
# Feedback/recommendations/tips can be sent to
# Clint Kennedy rkennedy@nagios.com

# Help menu
print_help() {
echo "This plugin will check for specific NFS mounts (mount | grep 'type nfs' | grep path | wc -l) for the specified port."
echo "Flags:"
echo "-p        Path to check"
echo "-h        Help menu"
echo ""
echo "Example:"
echo "check_localnfs.sh -p /mnt/nfs/nfsshare"
exit 0
}

# Define input vars
while getopts "p:w:c:h" option
do
        case $option in
                p) path=$OPTARG ;;
                h) print_help 0
                exit 0 ;;
        esac
done

# Check input vars
if [ -z "$path" ]; then
echo "Invalid parameters. Script requires a path. To access the help menu use the -h flag."
exit 0
fi


# Set vars
count=$(/usr/bin/timeout 10 /usr/local/nagios/libexec/check_disk -w 10 -c 20 -p "$path" | wc -l)


# Check count value
if [ $count -eq 1 ]
then
        state="OK"
        ecode=0
        output="NFS mount point $path is active."
elif [ $count -eq 0 ]
then
        state="CRITICAL"
        ecode=2
        output="NFS mount point $path is down."
else
        state="UNKNOWN"
        ecode=3
fi
echo "$state: $output"
exit $ecode
