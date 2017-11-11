#!/bin/env bash
# check SHA1 hash of local-cache vs qiniu CDN content
# NOTICE: this script will FLUSH current terminal
# USAGE: qiniu_validator.sh /path/to/local-cache

DIR_LOCAL_CACHE=$1
SEC_CHECK_INTERVAL=60
SEC_FLUSH_SCREEN_INTERVAL=5
QN_HOSTNAME=http://xxxxx.clouddn.com

_timestamp_init=$(date +%s)
_basename=''
_sha1_qiniu=''
_arr_sha1_local=()
_arr_timestamp_lastcheck=()
_arr_path_localcache=()
_arr_str_initwait=()
_arr_str_basename=()

# Build _arr_sha1_local, _arr_timestamp_lastcheck, _arr_path_localcache
_t=''
for i in ${DIR_LOCAL_CACHE}/*
    do
    _basename=$(basename $i)
    _arr_str_basename+=($_basename)
    _arr_path_localcache+=(${DIR_LOCAL_CACHE}/${_basename})
    _t=$(sha1sum ${DIR_LOCAL_CACHE}/${_basename} | cut -d ' ' -f1)
    _arr_sha1_local+=($_t)
    _arr_str_result+=('No(-/-)')
    _arr_str_nextcheck+=($(($RANDOM % $SEC_CHECK_INTERVAL + $_timestamp_init)))  # don't all start at once
    _arr_timestamp_lastcheck+=('0')
done

## sleep 999 #debug
checkConsistSHA1() {
	_sha1_qiniu=$(curl -sSL ${QN_HOSTNAME}/${2} | sha1sum | cut -f1 -d' ')
	if [[ $_sha1_qiniu == $1 ]]; then
		echo "Yes("$(echo $1|cut -c1-5)")"
	else
	# echo curl -sSL ${QN_HOSTNAME}/${2} "| sha1sum | cut -f1 -d' '"
# sleep 999 #debug
		echo "No("$(echo $_sha1_qiniu | cut -c1-5)"/"$(echo $1 | cut -c1-5)")"
	fi
}

_timestamp_curr=''
_header='Next Check\t\tSHA1 Consistency\t\tFile Name\t\t Last Check'
while true
    do
    clear

    # if jj

    _timestamp_curr=$(date +%s)
    _ts_delta=-1
    echo -e $_header
    for i in $(seq 0 $((${#_arr_sha1_local[@]} -1)))
    do
            _ts_delta=$((${_arr_str_nextcheck[$i]} - $_timestamp_curr))
	    echo -e $_ts_delta" seconds\t\t"${_arr_str_result[$i]}"\t\t"${_arr_str_basename[$i]}"\t\t"$(date --date=@${_arr_timestamp_lastcheck[$i]})

    done
    # heavy left, bash do not have callback
    for i in $(seq 0 $((${#_arr_sha1_local[@]} -1)))
    do
            _ts_delta=$((${_arr_str_nextcheck[$i]} - $_timestamp_curr))
	    if [[ $_ts_delta -le 0 ]]; then
		    _arr_str_nextcheck[$i]=$(($_timestamp_curr + $SEC_CHECK_INTERVAL))
		    _arr_timestamp_lastcheck[$i]=$_timestamp_curr
		    _arr_str_result[$i]=$(checkConsistSHA1 ${_arr_sha1_local[$i]} ${_arr_str_basename[$i]})

	    fi
    done

    sleep $SEC_FLUSH_SCREEN_INTERVAL
done

