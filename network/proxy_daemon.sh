#!/bin/bash --
# USAGE: <run as daemon>

SEC_MAX_WAIT=10
MAX_TRY=3
MINS_INTERVAL=10
PROXY="socks://127.0.0.1:1088"
TARGET="https://httpbin.org/ip"
CMD_TRIGGER="sudo systemctl restart proxy"
COUNT=0

while true
do
    if ! $(curl -m $SEC_MAX_WAIT -sSL -x $PROXY $TARGET); then
        if [[ $COUNT -eq $MAX_TRY ]]; then
            eval $CMD_TRIGGER
	    COUNT=0
        else
            COUNT=$(($COUNT + 1))
        fi
    fi

    sleep $(($MINS_INTERVAL * 60))
done
