#!/bin/sh
# USAGE: this_filter.sh <--domain|--hostname> filename.txt
# tracker lists can be obtained from https://github.com/notracking/hosts-blocklists

output_regex_domain() {
  grep -vE '(::|^#|^$)' "$1" | awk -F '/' '{print $2}' \
    | sed -e 's>^>(^|\.)>' -e 's>$>$>'
}

output_hostname() {
  grep -vE '(::|^#|^$)' "$1" | awk -F ' ' '{print $2}'

}

show_usage() {
  echo "USAGE: $0 < --domain | --hostname > domain_list.txt"
  exit 1
}

# Main
if test -z "$2" -o ! -f "$2";then
  show_usage
fi

case "$1" in
"--domain")
  output_regex_domain "$2"
  ;;
"--hostname")
  output_hostname "$2"
  ;;
*)
  show_usage
  ;;
esac
