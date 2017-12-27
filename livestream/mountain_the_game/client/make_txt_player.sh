#!/bin/bash --
# Update player.txt on propose

# Import configure
source env.conf

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
    local _rurl_sheet="$1"
    local _user="$2"
    local _content=""
    
    if [[ "$_rurl_sheet" == "$MAGIC_SHEET_NIL" ]];then
	_content="$MAGIC_SHEET_NIL"" 没有下一首了"
    else
	local _sheet=$(basename "$_rurl_sheet")
	local _name_sheet=${_sheet%.mnt.txt} # remove suffix
	
	_content="下一首\`\`${_name_sheet%.*} - feat.${_name_sheet#*.}'', 由$_user选取"
	
    fi
    sed -i "4,4 s>.*>${_content}>" $FD_DIST

}

do_current() {
    local _rurl_sheet="$1"
    local _user="$2"
    local _beat="$3"
    local _content_cur=""
    local _content_meta=""
    
    if [[ "$_rurl_sheet" != "$MAGIC_SHEET_NIL" ]];then
    	local _sheet=$(basename "$_rurl_sheet")
    	local _name_sheet=${_sheet%.mnt.txt} # remove suffix
        local _count_line=$(cat "$_rurl_sheet" | grep -vE '^#|^%' | wc -l  | cut -d\  -f1)
	
    	if [[ -z $_beat ]];then
    	    # go check in sheet file
    	    local _beat_infile=$(grep '^%' "$_rurl_sheet")
    	    if [[ -z $_beat_infile ]];then
	    	_beat=$DEFAULT_BEAT
	    else
    		_beat=$(echo $_beat_infile | sed 's>^%\S*\(\d*\)\S*>\1>' | sed 's/[\r\n]//g') # TODO
	    fi
	fi
	
    	_content_cur="当前演奏\`\`${_name_sheet%.*} - feat.${_name_sheet#*.}'', 由$_user选取"
    	_content_meta="歌曲信息 [0/${_count_line}]    节拍 ${_beat}ms"
    else
	_content_cur="当前没有在演奏哦, 性感大山在线吹水, 月入5小电... 额, 5根拉条(ι´Д｀)ﾉ"
    	_content_meta="歌曲信息 [-/-]    节拍 --ms"
	sed -i "3,3 s<.*<>>> 没有乐谱信息<" $FD_DIST
    fi
    sed -i "1,1 s>.*>${_content_cur}>" $FD_DIST
    sed -i "2,2 s>.*>${_content_meta}>" $FD_DIST

}

do_pointer() {
    local _line="$1"
    local _note="$2"
    
    sed -ri "2,2 s>\[[[:digit:]]+\/>[${_line}/>" $FD_DIST
    sed -i "3,3 s<.*<>>> ${_note}<" $FD_DIST

}

do_wait() {
    local _content_cur="大山修整中~ 稍后回来..." # TODO Random content from ext file
    local _content_meta="歌曲信息 [-/-]    节拍 --ms"
    sed -i "1,1 s>.*>${_content_cur}>" $FD_DIST
    sed -i "2,2 s>.*>${_content_meta}>" $FD_DIST
    sed -i "3,3 s<.*<>>> 没有乐谱信息<" $FD_DIST

}

# Main
subcmd="$1"
case $subcmd in
    nxt)
	do_next "$2" "$3"
	;;
    cur)
	do_current "$2" "$3" "$4"
	;;
    ptr)
	do_pointer "$2" "$3"
	;;
    wat)
	do_wait
	;;
    *)    # fallback
	echo 'USAGE: make_txt_player.sh <nxt|cur|ptr|wat> <arg1> <arg2> ...'
	exit 1
	;;
esac
