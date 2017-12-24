#!/bin/bash
# Read danmaku from database

URL_DB="/cygdrive/c/Users/dummyred/AppData/Local/bililive/User Data/90369/bililive.db"
URL_STATUS="/cygdrive/r/txt/status.txt"
URL_LOG_BACKLOG="/cygdrive/r/txt/backlog.txt"
URL_PLAYLIST="/cygdrive/r/txt/playlist.txt"
FD_PLAYER_HANDLER_PIDFILE="/tmp/playlist_handler.pid"
RPATH_SHEET_DIR="sheets"
SEC_DB_CHECK_INTERVAL=1.0

MAGIC_FINGERPRINT=""
INDEX_LAST_READ="0"
INDEX_PROCESS="0"
STR_TABLE="danmaku_ex"
SQL_VIEW="select type,uname,text from $STR_TABLE where id="
TYPE_ISGIFT="2"
LIMIT_WRAP_STATUS=23
LIMIT_LINES_STATUS=6

getDanmakuCount() {
    echo $(sqlite3 "${URL_DB}" "select COUNT(*) from $STR_TABLE")

}

checkUpdate_db() {
    local _cur=$(stat --format="%Y" "$URL_DB")

	if [[ $_cur -eq $MAGIC_FINGERPRINT ]];then
	    return 1
	else
	    MAGIC_FINGERPRINT=$_cur
		#if (exit-code 0) is success
	    return 0
	fi
}

queryDanmakuContent() {
    local _id_db=$1
	sqlite3 "$URL_DB" "$SQL_VIEW"${_id_db}";"

}

updateStatus() {
    local _content=$1
	
	# Write to backlog
	echo $_content | sed "s/.\{$LIMIT_WRAP_STATUS\}/&\n/" >> $URL_LOG_BACKLOG # Wrap the first $LIMIT_WRAP_STATUS chars
	
	# Clean up status.txt
    tail -n $LIMIT_LINES_STATUS $URL_LOG_BACKLOG  >$URL_STATUS
}

parseContentOnGift() {
    updateStatus "感谢 $1"

}

parseContentOnCmd() {
    local _user=$1
	local _friendly_sheet=$(parseFriendlySheetName $2)

	echo "$1"'>'"$2" >> $URL_PLAYLIST 
    updateStatus "由${_user}提名, '${_friendly_sheet}' 成功加入演奏列表"

}

parseFriendlySheetName() {
    local _url_sheet=$1
    local _t=$(basename ${_url_sheet%.mnt.txt})
	
	echo "${_t%.*} - feat.${_t#*.}"

}

checkValiadCmd() {
    local _jinyu='大山大山'
	local _cmd='演奏'
    local _hint_sheet="$1"
	
	if $(echo "$_hint_sheet" | grep -qE "${_jinyu}[[:space:]]*[,.，。]*${_cmd}");then # TODO less MAGIC HERE, try func
	    if [[ $(ls "$RPATH_SHEET_DIR" | grep -i $(echo $_hint_sheet | sed 's/[,.，。大山演奏 ]//g') | wc -l) -eq 1 ]];then
		    return 0
	    fi
	fi
	return 1
	

	
}

worker_triggerMountainPlayer() {
    local _user=$1 # TODO make a background worker
	local _url_sheet=$2

    ./make_txt_player.sh cur $_url_sheet $_user
    /cygdrive/c/Program\ Files\ \(x86\)/ahk/AutoHotkeyU32.exe mnt_player-ng.ahk $_url_sheet # TODO $_user_beat

}

parseDanmaku() {
    local _t="" # temp
    local _rurl_sheet=""
    local _content=""
    local _user=""
	
    local _cur_index=$(getDanmakuCount)
    # read danmaku and check type
    for i in $(seq $(($INDEX_LAST_READ + 1)) $_cur_index)
    do
        _t=$(queryDanmakuContent $i)
        _content=$(echo $_t | awk -F '|' '{print $3}')
	    _user=$(echo $_t | awk -F '|' '{print $2}')
	
	    if [[ ${_t:0:1} -eq $TYPE_ISGIFT ]];then
	        parseContentOnGift $_content
	    else
	        if checkValiadCmd "$(echo $_t | awk -F '|' '{print $3}')";then
	    	    #success and go find sheet resource
	    		_rurl_sheet="$RPATH_SHEET_DIR""/"$(basename $(ls "$RPATH_SHEET_DIR" | grep -i $(echo $_content | sed 's/[,.，。大山演奏 ]//g')))
		    	parseContentOnCmd $_user $_rurl_sheet
		    	
		    fi
	    fi
	
    done
	
	INDEX_LAST_READ=$_cur_index
}

parsePlaylist() {
    # worker_triggerMountainPlayer $_user $_rurl_sheet
	sleep 0.5


}

# Init
INDEX_LAST_READ=$(getDanmakuCount)

while true
do
    if checkUpdate_db;then
         parseDanmaku
		
	fi

	parsePlaylist
    sleep $SEC_DB_CHECK_INTERVAL
done
	
    
