#!/bin/bash --
# piwik log import tool helper
# NOTICE: special args:
#    http_upgrade ==> defined vhost with no Log field in configure
#    fallback     ==> not defined vhost visit, use --log-format-regex
# My apache combined Logformat, piwik do not support HTTP METHOD
#    LogFormat "%h %u %t \"%r\" %>s %B \"%{Referer}i\" \"%{User-Agent}i\"" combined
# USAGE: piwik_apachelog_importer.sh placeholder 3

PIWIK_DOMAIN=http://example.com/piwik
RECORDERS=1

_target_id=$2
_target_log_prefix=$1
_path_analytics_tool=/var/lib/piwik/misc/log-analytics/import_logs.py
_wildcard_logname="/var/log/apache2/${_target_log_prefix}-*"
_quiet_arg="--output=/dev/null"
_log_format_spec=""

if [[ $_target_log_prefix == 'fallback' ]];then
    RECORDERS=$(($RECORDERS + 1))
    _log_format_spec='--log-format-regex=(?P<ip>\S+) (?P<user>\S+) \[(?P<date>[\w\/\:]+) (?P<timezone>[\d\-\+]+)\] "\w+ (?P<path>.*?)(?: \S+)" (?P<status>\d+) (?P<length>\d+) "(?P<referrer>.*?)" "(?P<user_agent>.*?)"'
    _wildcard_logname="/var/log/apache2/access.log* /var/log/apache2/error.log*"

fi

if [[ $_target_log_prefix == 'http_upgrade' ]];then
    _wildcard_logname="/var/log/apache2/other_vhosts_access*"
fi

python $_path_analytics_tool $_quiet_arg --url=$PIWIK_DOMAIN \
        --idsite=$_target_id --recorders=$RECORDERS \
        --enable-http-errors --enable-http-redirects \
        --enable-static --enable-bots \
        "$_log_format_spec" $_wildcard_logname
