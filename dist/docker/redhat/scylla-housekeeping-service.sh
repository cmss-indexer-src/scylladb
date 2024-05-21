#!/bin/bash
sleep 5
api_port=$(grep -e '^api_port' /etc/scylla/scylla.yaml|awk -F':' '{ print $NF }')
if [ -z "$api_port" ]; then
    api_port=10000
fi
/opt/scylladb/scripts/scylla-housekeeping --api-port $api_port --uuid-file /var/lib/scylla-housekeeping/housekeeping.uuid --repo-files '/etc/yum.repos.d/scylla*.repo'  -q version --mode cr || true
while true; do
    sleep 1d
    /opt/scylladb/scripts/scylla-housekeeping --api-port $api_port --uuid-file /var/lib/scylla-housekeeping/housekeeping.uuid --repo-files '/etc/yum.repos.d/scylla*.repo' -q version --mode cd || true
done

