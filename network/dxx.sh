#!/bin/env sh
# Drill -x eXtra, get extra info besides PTR record
# NOTICE: https://www.ipip.net/api.html
# DEPENT: API(ipip.net), drill(or dig), curl
# USAGE: dxx.sh 8.8.4.4

TOOLCHAIN_DNS="drill"
STR_IP="$1"


print_prettify_string() {
    echo -e "\n==> $1 <=="
}

query_ptr() {
    local _argu="-x"
    local _cmd="${TOOLCHAIN_DNS} ${_argu} ${STR_IP}"

    eval "$_cmd"
}

query_api_ipip_net() {
    local _api_leading="http://freeapi.ipip.net/"

    curl -sSfL "${_api_leading}${STR_IP}" |  sed 's/[",]/ /g'
}

# Main
print_prettify_string "$TOOLCHAIN_DNS"
query_ptr

print_prettify_string "API: ipip.net"
query_api_ipip_net
