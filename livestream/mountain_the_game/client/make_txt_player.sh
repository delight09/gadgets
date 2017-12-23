#!/bin/bash
# Update player.txt on propose

# MAGIC global
FD_DIST=/cygdrive/r/txt/player.txt
DEFAULT_BEAT=400

# Init player.txt
if [[ -f $FD_DIST ]];then
    _count_line=$(wc -l $FD_DIST | cut -d\  -f1)
fi

if [[ $_count_line -lt 4 ]];then
    echo '' >$FD_DIST
    echo '' >>$FD_DIST
    echo '' >>$FD_DIST
    echo '' >>$FD_DIST
fi

# Update logic
do_next() {
    local _rurl_sheet=$1
    local _user=$2
	local _sheet=$(basename $_rurl_sheet)
	local _name_sheet=${_sheet%.mnt.txt} # remove suffix
	
	local _content="下一首\`\`${_name_sheet%.*} - feat.${_name_sheet#*.}'', 由$_user选取"
	sed -i "4,4 s>.*>${_content}>" $FD_DIST

}

do_current() {
    local _rurl_sheet=$1
    local _user=$2
	local _beat=$3
	local _sheet=$(basename $_rurl_sheet)
	local _name_sheet=${_sheet%.mnt.txt} # remove suffix
    local _count_line=$(cat $_rurl_sheet | grep -vE '^#|^%' | wc -l  | cut -d\  -f1)
	
	if [[ -z $_beat ]];then
	    # go check in sheet file
		local _beat_infile=$(grep '^%' $_rurl_sheet)
		if [[ -z $_beat_infile ]];then
		    _beat=$DEFAULT_BEAT
		else
		    _beat=$(echo $_beat_infile | sed 's>^%\S*\(\d*\)\S*>\1>' | sed 's/[\r\n]//g')
		fi
	fi
		
	local _content_cur="当前演奏\`\`${_name_sheet%.*} - feat.${_name_sheet#*.}'', 由$_user选取"
	local _content_meta="[0/${_count_line}]    beat ${_beat}ms"
	sed -i "1,1 s>.*>${_content_cur}>" $FD_DIST
	sed -i "2,2 s>.*>${_content_meta}>" $FD_DIST

}

do_pointer() {
    local _line=$1
    local _note="$2"
	
	sed -ri "2,2 s>\[[[:digit:]]+\/>[${_line}/>" $FD_DIST
	sed -i "3,3 s<.*<>>> ${_note}<" $FD_DIST

}

# Main
subcmd="$1"
case $subcmd in
    nxt)
    do_next $2 $3
    ;;
    cur)
    do_current $2 $3 $4
    ;;
    ptr)
    do_pointer $2 "$3"
    ;;
    *)    # fallback
    echo 'USAGE: make_txt_player.sh <nxt|cur|ptr> <arg1> <arg2> ...'
    exit 1
    ;;
esac


