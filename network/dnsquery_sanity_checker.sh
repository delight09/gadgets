#!/bin/env bash
# Query on the www-server domain with default DNS server, 
#   fire HTTP request with bash TCP socket pseudo-path and echo result
# USAGE: dnsquery_sanity_checker.sh <domain>

_STR_DOMAIN="$1"
_POSIX_REGEX_DNS_RECORD="[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+"
_TOOLCHAIN_DNS="getent"
_TOOLCHAIN_DNS_ARGU="ahostsv4"

exit_on_notfound() {
  echo Domain "$_STR_DOMAIN": not found in DNS
  exit 2
}

_cmd="${_TOOLCHAIN_DNS} ${_TOOLCHAIN_DNS_ARGU} ${_STR_DOMAIN}"
_str_ip=$(_t=$(eval $_cmd) && \
              (echo $_t | grep -o -e "${_POSIX_REGEX_DNS_RECORD}" | head -n 1) || \
              echo "ERR_NOTFOUND")

if [[ "$_str_ip" == "ERR_NOTFOUND" ]];then
  exit_on_notfound
fi

echo "Trying to establish TCP connection against >${_str_ip}:80 ..."
exec 3<>/dev/tcp/${_STR_DOMAIN}/80

echo "Connection established, fire HTTP request ..."
echo -e "GET / HTTP/1.0\nHOST: ${_str_ip}\n\n" >&3 && head <&3
