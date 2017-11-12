#!/bin/bash --
# piwik log import tool helper
# NOTICE: It's recommend to call this helper after log get download
#     This script will load your CPU and take much memory.
#     It usually takes ~3mins for analytics_tool process, try not use wildcard on _logname
# USAGE: piwik_qiniulog_importer.sh 3

PIWIK_DOMAIN=https://example.com/piwik
RECORDERS=3

_target_id=$1
_target_date=$(TZ="Asia/Shanghai" date +%Y-%m-%d -d "yesterday")
_path_analytics_tool=/var/lib/piwik/misc/log-analytics/import_logs.py
_path_piwik_console=/var/lib/piwik/console
_logname="/var/log/qiniu_cdn/qiniucdn_"$_target_date".log"
_quiet_arg="--output=/dev/null"
_log_format_spec='--log-format-regex=(?P<ip>\S+) (?P<cdnhit>\S+) (?P<resptime>\S+) \[(?P<date>[\w\/\:]+) (?P<timezone>[\d\-\+]+)\] "\w+ (?P<path>.*?)(?: \S+)" (?P<status>\d+) (?P<length>\d+) "(?P<referrer>.*?)" "(?P<user_agent>.*?)"'

python $_path_analytics_tool $_quiet_arg --url=$PIWIK_DOMAIN \
        --idsite=$_target_id --recorders=$RECORDERS \
        --enable-static \
        "$_log_format_spec" $_logname

# force process piwik data analystic
php $_path_piwik_console core:archive --url=$PIWIK_DOMAIN  --force-idsites=$target_id >/dev/null
