#!/bin/bash
set -e
function fail {
  echo "CRITICAL: $@"
  exit 2
}

if [ -f /root/openrc ]; then
  source /root/openrc
  netname=`hostname`
  neutron net-list -D || fail 'neutron net-list failed'
  for net in `neutron net-list -D | grep $netname | awk '/[a-z][a-z]*[0-9][0-9]*/ {print $2}'`; do
    echo "Found unexpected network leftover from previous test"
    neutron net-delete $net || fail 'neutron net-delete failed'
  done
  netid=`neutron net-create $netname | grep ' id ' | awk  '{print $4}'` || fail 'failed to create network'
  neutron subnet-create $netid 10.0.0.0/24 || fail 'neutron subnet-create failed'
  portid=`neutron port-create $netid | grep ' id ' | awk  '{print $4}'` || fail 'neutron port-create failed'
  neutron port-delete $portid || fail "Could not delete port $portid"
  neutron net-delete $netid || fail "Could not delete network $netid"
else
  echo 'Critical: Openrc does not exist'
  exit 2
fi
