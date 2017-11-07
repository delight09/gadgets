#!/bin/bash --
# Fetch latest feed @bilispace2rss, push to qiniu.
# NOTICE: need `curl` to work, $str_path_qshell executable
# USAGE: feedbummer_qiniu.sh <mid>

set -e    #exit on error

SECRET_AK=xxxxxxxxxxxxxxxxxxxx
SECRET_SK=xxxxxxxxxxxxxxxxxxxx
QN_BUCKET_NAME=EditMeLa
API_GAS="https://script.google.com/macros/s/AKfycbw39jDXxmoZDfKDHtnj3j05Tqem5qjv_Ugn4cKY8gJ0H-ZmOr8/exec?noplayer=450&mid="
_ARG_CURL_PROXY=""    #i.e. _ARG_CURL_PROXY="-x socks://127.0.0.1:1088"

_mid=$1
str_filename_prefix="bilispace2rss_"
str_path_qshell="/usr/local/bin/qshell"
str_filename=${str_filename_prefix}${_mid}".xml"
str_path_feed_storage=/var/tmp

# Fetch lastest feed
curl $_ARG_CURL_PROXY -s -L ${API_GAS}${_mid} --compressed -o ${str_path_feed_storage}/${str_filename}

# Push to qiniu
$str_path_qshell account $SECRET_AK $SECRET_SK
_CMD_QSHELL="${str_path_qshell} fput ${QN_BUCKET_NAME} ${str_filename} ${str_path_feed_storage}/${str_filename} true application/atom+xml >/dev/null"
eval $_CMD_QSHELL
