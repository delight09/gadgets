#!/bin/env bash
# Query on the www-server domain with default DNS server, 
#   fire HTTP request with bash TCP socket pseudo-path and echo result
# USAGE: dnsquery_sanity_checker.sh <domain>
# NOTICE: depandence on drill(or dig), curl

_TOOLCHAIN_DNS="drill"
_STR_DOMAIN="$1"
_POSIX_REGEX_DNS_RECORD="IN[[:space:]]+A"
_STR_MARK_COMMENT=";;"

_cmd="${_TOOLCHAIN_DNS} ${_STR_DOMAIN} | grep -E '${_POSIX_REGEX_DNS_RECORD}'
                                       | grep -v '${_STR_MARK_COMMENT}' | tail -n 1| cut -f5"
_str_ip=$(eval $_cmd)

echo "Trying to establish TCP connection against >${_str_ip}:80 ..."
exec 3<>/dev/tcp/${_STR_DOMAIN}/80

echo "Connection established, fire HTTP request ..."
echo -e "GET / HTTP/1.0\nHOST: ${_str_ip}\n\n" >&3 && head <&3
