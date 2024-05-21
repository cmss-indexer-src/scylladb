#!/bin/bash
ipv4_regex='([0-9]{1,3}\.){3}[0-9]{1,3}'

alternator_ip=`echo $POD_IP | grep -E -o "$ipv4_regex"`

alternator_port=$1

http_status=$(curl -i -o /dev/null -s -w "%{http_code}\n" http://$alternator_ip:$alternator_port)

mount_status=$(mount -l | grep "/var/lib/scylla" | grep -q "/dev/md"; if [ $? -eq 0 ];then echo "Mounted"; else echo "Not mounted"; fi)

echo "Mount status: $mount_status"
echo "HTTP status: $http_status"

if [[ $http_status -eq 200 && $mount_status == "Mounted" ]]
then
   echo "Ready"
   exit 0
else
   echo "Not Ready!"
   exit 1
fi
