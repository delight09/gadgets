#!/bin/sh
# Listen for SIGUSR1 signal and streaming for 10 minutes

do_stream() {
    ffmpeg -f video4linux2 -i /dev/video0 -t 6000\
    -c:v h264 -flags +cgop -g 30     \
    -hls_time 10 -hls_list_size 10   \
    -hls_start_number_source datetime\
    -hls_segment_type fmp4 /var/www/livecam/source/gt.m3u8

}


_pid=$$
echo $_pid >/var/run/hls.pid
chmod +r /var/run/hls.pid

trap do_stream SIGUSR1

while true
do
    sleep 5 #MAGIC
done

