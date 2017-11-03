#!/bin/bash --
# Notice: minimal restart interval ==> ( MAX_ERR_TRY * MINS_ERR_INTERVAL ), default is 6 minutes
# USAGE: <run as daemon>

MAX_ERR_TRY=3
MINS_ERR_INTERVAL=2
MINS_PASS_INTERVAL=10
PROXY="socks://127.0.0.1:1088"
TARGET="https://httpbin.org/ip"
SEC_CURL_MAX_WAIT=10
CMD_TRIGGER="sudo systemctl restart proxy"

COUNT_ERR=0
while true
do
    if ! $(curl -m $SEC_CURL_MAX_WAIT -sL -x $PROXY $TARGET >/dev/null); then
        if [[ $COUNT_ERR -eq $(($MAX_ERR_TRY - 1)) ]]; then
            eval $CMD_TRIGGER
            echo $(date +%D-%T)'%proxy restart triggered'
	    COUNT_ERR=0
        else
            COUNT_ERR=$(($COUNT_ERR + 1))
        fi
    else
        COUNT_ERR=$(($COUNT_ERR - 1))
    fi

    if [[ $COUNT_ERR -eq 0 ]]; then
        sleep $(($MINS_PASS_INTERVAL * 60))
    else
        sleep $(($MINS_ERR_INTERVAL * 60))
    fi
done
