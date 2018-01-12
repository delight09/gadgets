#!/bin/bash --
# Filter cURL commands of bilibili video webpage
# return cURL commands with all slices from video resource

# Filter keywords
FILTER_SITE_METADATA="api.bilibili.com|data.bilibili.com|live.bilibili.com|cnzz.com|qq.com"
FILTER_TYPE_METADATA=".css|.js|.png|.gif|.webp|.jpg"
FILTER_CONTENT_METADATA=";base64|comment"
FILTER_TYPE_VIDEO=".mp4|.flv"
FILTER_KEYWORD_VIDEO="Range: bytes"

# Global variables
FD_TEMPFILE=/tmp/filtered.raw
FD_TEMPFILE_FIN=/tmp/filtered.fin.raw
FD_ALL_CURL=$1

patch_unify_content() {
    sed -i -r 's>Range: bytes=[[:digit:]]+->Range: bytes=0->g' $1

}

escape_string() {
    echo "$1" | sed 's=\.=\\.=g'

}

is_not_video_resource() {
    local _url="$1"

    echo $_url |grep -qiE "${FILTER_TYPE_METADATA}"'|'"${FILTER_SITE_METADATA}"'|'"${FILTER_CONTENT_METADATA}"

}

# Init
if [[ -z $1 ]];then
    echo "USAGE: $0 <cURL_commands file>"
    exit 1
fi
rm -f $FD_TEMPFILE
rm -f $FD_TEMPFILE_FIN

# escape filter keywords for regexp
FILTER_SITE_METADATA=$(escape_string "$FILTER_SITE_METADATA")
FILTER_TYPE_METADATA=$(escape_string "$FILTER_TYPE_METADATA")
FILTER_CONTENT_METADATA=$(escape_string "$FILTER_CONTENT_METADATA")
FILTER_TYPE_VIDEO=$(escape_string "$FILTER_TYPE_VIDEO")
FILTER_KEYWORD_VIDEO=$(escape_string "$FILTER_KEYWORD_VIDEO")


# Main
while read i
do
    if is_not_video_resource "$i";then
        sleep 0
    else
        echo $i >> $FD_TEMPFILE
    fi
done < $FD_ALL_CURL

# Unify cURL contents then sort, uniq the result
patch_unify_content $FD_TEMPFILE
grep -iE "${FILTER_TYPE_VIDEO}" $FD_TEMPFILE | grep -iE "${FILTER_KEYWORD_VIDEO}" | sort | uniq > $FD_TEMPFILE_FIN


patch_filename() {
    local _line="$1"
    local _fn=$(echo $_line | grep -oE "[^/]*(${FILTER_TYPE_VIDEO})\?" | tr -d '?')

    echo $_line | sed "s>;$>-o $_fn ;>"

}

# Add filename and output commands
while read i
do
    patch_filename "$i"

done < $FD_TEMPFILE_FIN
