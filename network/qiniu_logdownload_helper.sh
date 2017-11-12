#!/bin/bash --
# Download yesterday's qiniu CDN traffic log for specified domain
# API refer: https://developer.qiniu.com/fusion/api/1226/download-the-log
# NOTICE: Log resource will delay for 8-10 hours, it's a known issue written in API doc.
#     It's recommand to trigger this script after 2 AM UTC in order to get a 24h log.
#     Dependency on `jq`, `curl`, `gunzip` tool.
#     Only accept _ONE_ domain.
# USAGE: qiniu_renew_helper.sh xx.clouddn.com

SECRET_AK=xxxxxx
SECRET_SK=yyyyyy
DIR_LOGFILE=/var/log/qiniu_cdn
PREFIX_LOGFILE=qiniucdn_
COUNT_MAX_TRY=5


super_eval() {
  _exit_code=255 # foo value
  _count=0

  while [[ $_exit_code -ne 0 ]] && [[ $_count -lt $COUNT_MAX_TRY ]]
  do
    eval "$1"
    _exit_code=$(echo $?)

    _count=$(($_count + 1))
  done
}


rm -f ${DIR_LOGFILE}/*.tmp.gz
domain_name=$1
tk=$(echo "/v2/tune/log/list" |openssl dgst -binary -hmac $SECRET_SK -sha1 |base64 | tr + - | tr / _)
target_date=$(TZ="Asia/Shanghai" date +%Y-%m-%d -d "yesterday")
str_json_res=''

_curl_data="{\"day\":\"$target_date\",\"domains\":\"${domain_name}\"}"
_curl_cmd="curl -sfL -X POST -H '""Authorization: QBox ${SECRET_AK}:${tk}""' http://fusion.qiniuapi.com/v2/tune/log/list -d '"$_curl_data"' -H Content-Type:application/json"
str_json_res=$(super_eval "$_curl_cmd")


_index=0
_url=''
_curl_cmd=''
cd $DIR_LOGFILE # enter working dir

for i in $(echo $str_json_res | grep -o url)
do
    _url=$(echo $str_json_res | jq '.data["'$domain_name'"]['$_index'].url' | tr -d \")
    _curl_cmd="curl -sfL -o $_index.tmp.gz '"$_url"'"  # tag .tmp.gz for later concatenate
    super_eval "$_curl_cmd"

    _index=$(($_index + 1))
done
gunzip ./*.gz
cat *.tmp >${PREFIX_LOGFILE}${target_date}.log
rm *.tmp

cd - >/dev/null # exit working dir
