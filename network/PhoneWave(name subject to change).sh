#!/bin/sh --
# Let's travel with O.V.E.N(Office VPN Environment Node)
# A cisco anyconnect client helper
# USAGE: PhoneWave.sh start

ANYCONNECT_PASS=str0ngpassla
ANYCONNECT_ENDPOINT="http://office.example.com:443"
pidfile=/var/run/oven.pid
ANYCONNECT_USERGROUP="MyGroup"
ANYCONNECT_USERNAME="user@example.com"

case "$1" in
start)
       echo $ANYCONNECT_PASS | exec sudo openconnect -b --pid-file=$pidfile $ANYCONNECT_ENDPOINT  \
         --servercert=sha256:a3a \
         --authgroup=$ANYCONNECT_USERGROUP -u $ANYCONNECT_USERNAME --passwd-on-stdin
;;

stop)
       sudo kill -HUP $(cat $pidfile)
;;

*)
       echo "Usage: $0 {start|stop}"
       exit 1
;;
esac
exit 0
