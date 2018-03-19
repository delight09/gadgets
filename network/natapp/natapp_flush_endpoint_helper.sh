#!/bin/sh
# trigger the endpoint flush daemon with SIGUSR1


fd_pid_flush_daemon="/var/run/natapp_flush_daemon.pid"

pid=$(cat $fd_pid_flush_daemon)
kill -SIGUSR1 $pid
