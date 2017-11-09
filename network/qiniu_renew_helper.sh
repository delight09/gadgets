#!/bin/bash --
# Qiniu won't push file changes to CDN nodes, force refresh.
# API refer: https://developer.qiniu.com/fusion/api/1229/cache-refresh
# NOTICE: only accept one url as argument
# USAGE: qiniu_renew_helper.sh http://xx.clouddn.com/resource-name.type

SECRET_AK=xxxxxxxxx
SECRET_SK=sssssssss

single_url=$1
TK=$(echo "/v2/tune/refresh" |openssl dgst -binary -hmac $SECRET_SK -sha1 |base64 | tr + - | tr / _)

_curl_data="{\"urls\":[\" $single_url \"]}"
_curl_cmd="curl -X POST -H '""Authorization: QBox ${SECRET_AK}:${TK}""' http://fusion.qiniuapi.com/v2/tune/refresh -d '"$_curl_data"' -H Content-Type:application/json"

eval "$_curl_cmd"
