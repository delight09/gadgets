#!/bin/sh
# Listen for SIGUSR1 signal and flush latest natapp endpoint to public


magic_sec_sleep=5
logfile_natapp="/var/log/natapp/logfile"

_build_redirect_html() {
    local _tempfile="/tmp/redirect_natapp_endpoint.html"
    echo '<html>' >$_tempfile
    echo '<meta http-equiv="refresh" content="0;url=https://'${1}'/">' >>$_tempfile
    echo '</html>' >>$_tempfile

}

helper_scp() {
    _build_redirect_html $1
    # scp html file and trigger update script
    su example_user -c 'scp -P example_port /tmp/redirect_natapp_endpoint.html example_host:index.html'
    su example_user -c 'ssh -p example_port example_host /path/to/update_script.sh /home/example_user/index.html /srv/www/domain.name/index.html'

}

check_if_endpoint_updated() {
    local _endpoint=$(grep -o 'Tunnel established at tcp://.*' $logfile_natapp \
                   | sed 's>.*tcp://\(.*\)>\1>' | tail -n 1)
    if test ! -z $_endpoint;then
        if test -z $CURR_ENDPOINT;then
            helper_scp $_endpoint
        elif test $_endpoint != $CURR_ENDPOINT;then
            helper_scp $_endpoint
        fi
    fi
    CURR_ENDPOINT=$_endpoint

}


# Main
trap check_if_endpoint_updated SIGUSR1
CURR_ENDPOINT=""

while true
do
    sleep $magic_sec_sleep
done
