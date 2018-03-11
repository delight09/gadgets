#!/usr/bin/env bash
# Update index.html with last hour humidity summary


device_terminal=/dev/ttyACM0
pipe_humidity_sample=/dev/shm/humidity.pipe
fd_index_html=/dev/shm/humi_assets/index.html
TIMEDATE_INIT=$(date +%Y%m%d_%H%M)
MINU_GENERATE_INTERVAL=10
SEC_SENSOR_SAMPLE_INTERVAL=30

dir_index_html=''
TIMEDATE_CURR=''
arr_humi_data=()

show_max() {
  local a=( ${arr_humi_data[@]} )
  printf "%s\n" "${a[@]}" | sort -nr | head -n 1

}

show_min() {
  local a=( ${arr_humi_data[@]} )
  printf "%s\n" "${a[@]}" | sort -n | head -n 1

}

show_delta() {
  local a=( ${arr_humi_data[@]} )
  echo $(echo "${a[-1]} - ${a[0]}" | bc)

}

show_average() {
  local a=( ${arr_humi_data[@]} )
  echo "${a[@]}" | awk '{s=0; for (i=1;i<=NF;i++)s+=$i; print s/NF;}'

}

raw_data_append() {
  local fd="${dir_index_html}/hhs_${TIMEDATE_CURR}.html"
  printf '%s\n' "${arr_humi_data[@]}" | tee -a $fd

}

fd_append_content() {
  local fd="${dir_index_html}/hhs_${TIMEDATE_CURR}.html"
  echo "$1" >>$fd

}

update_index_html() {
  local fd="${dir_index_html}/hhs_${TIMEDATE_CURR}.html"
  ln -f $fd "${dir_index_html}/index.html"

}

parse_pipe_content() {
  local fd="$1"
  local lines=$((60 * 60 / $SEC_SENSOR_SAMPLE_INTERVAL)) # MAGIC: last hour
  arr_humi_data=( $(grep -v '^$' "$fd" | tail -n $lines | awk -F ',' '{print $1}') )

}

# Init serial terminal
stty -F $device_terminal cs8 115200 ignbrk -brkint -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts
cat $device_terminal > $pipe_humidity_sample &

# Init structure
dir_index_html=$(dirname $fd_index_html)
mkdir -p $dir_index_html
## rm -f "${dir_index_html}/*"

# Main
while true
do
  sleep $(($MINU_GENERATE_INTERVAL * 60))

  parse_pipe_content $pipe_humidity_sample
  TIMEDATE_CURR=$(date +%Y%m%d_%H%M)

  fd_append_content 'Humidity Hourly Summary'
  fd_append_content '======================='
  fd_append_content "Tracking start: $TIMEDATE_INIT; Summary at: $TIMEDATE_CURR"
  fd_append_content "average: $(show_average); delta: $(show_delta); max: $(show_max); min: $(show_min)"
  fd_append_content ""
  fd_append_content "--.--.--raw data output--.--.--.--"
  raw_data_append

  update_index_html
done
