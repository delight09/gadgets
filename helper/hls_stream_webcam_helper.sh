#!/bin/sh
# Listen for SIGUSR1 signal and streaming for 10 minutes

dir_hls_segment=$1
mins_duration=10
magic_sec_sleep=5

do_stream() {
    ffmpeg -f video4linux2 -i /dev/video0 -t $(($mins_duration * 60))\
    -c:v h264 -flags +cgop -g 30     \
    -hls_time 10 -hls_list_size 10   \
    -hls_start_number_source datetime\
    -hls_segment_type mpegts "${dir_hls_segment}/gt.m3u8"

}


if ! test -d ${dir_hls_segment}; then
  sleep $magic_sec_sleep ;exit 2
fi
_pid=$$
echo $_pid >/var/run/hls.pid
chmod +r /var/run/hls.pid

trap do_stream SIGUSR1

while true
do
    sleep $magic_sec_sleep
done

