#!/bin/bash --
# Notice: minimal restart interval ==> ( MAX_ERR_TRY * MINS_ERR_INTERVAL ), default is 6 minutes
# USAGE: <run as daemon>

MAX_ERR_TRY=3
MINS_ERR_INTERVAL=2
MINS_PASS_INTERVAL=10
SEC_CURL_MAX_WAIT=10
# ARG_PROXY="-x socks://127.0.0.1:1088"
TARGET="http://baidu.com"
CMD_TRIGGER='touch /tmp/nc_trigged.$(date +%T)'
# CMD_TRIGGER="systemctl restart proxy"
# CMD_TRIGGER="service networking stop; sleep 60; service networking start"
LOGFILE="/tmp/proxychecker.log"
CMD_LOGOUT="%networkchecker daemon triggered: $CMD_TRIGGER >> $LOGFILE"

COUNT_ERR=0
while true
do
    if ! $(curl -m $SEC_CURL_MAX_WAIT -sfL $PROXY $TARGET >/dev/null); then
        if [[ $COUNT_ERR -eq $(($MAX_ERR_TRY - 1)) ]]; then
            eval "$CMD_TRIGGER"
            eval "echo "$(date '+%D - %T')$CMD_LOGOUT
	    COUNT_ERR=0
        else
            COUNT_ERR=$(($COUNT_ERR + 1))
        fi
    else
        if [[ $COUNT_ERR -ne 0 ]];then
            COUNT_ERR=$(($COUNT_ERR - 1))
        fi
    fi

    if [[ $COUNT_ERR -eq 0 ]]; then
        sleep $(($MINS_PASS_INTERVAL * 60))
    else
        sleep $(($MINS_ERR_INTERVAL * 60))
    fi
done
