#!/bin/bash --
# kill old proc, cleanup, start app

LOGFILE=/tmp/v2ray.log

r_pid=$(ps -W | grep v2ray | grep -v grep | awk '{print $1}')
for i in $r_pid
do
    taskkill.exe /F /pid $i
done

rm -rf $LOGFILE

/cygdrive/c/proxy/v2ray/v2ray.exe > $LOGFILE &

