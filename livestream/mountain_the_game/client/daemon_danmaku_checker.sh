#!/bin/bash
# Read and parse danmaku from database

URL_DB="/cygdrive/c/Users/dummyred/AppData/Local/bililive/User Data/90369/bililive.db"
URL_STATUS="/cygdrive/r/txt/status.txt"
URL_LOG_BACKLOG="/cygdrive/r/txt/backlog.txt"
URL_PLAYLIST="/cygdrive/r/txt/playlist.txt"
FD_PLAYLIST_HANDLER_PIDFILE="/tmp/playlist_handler.pid"
RPATH_SHEET_DIR="sheets"
SEC_DB_CHECK_INTERVAL=1.0
MULTI_FADEOUT_STATUS=8 # (SEC_DB_CHECK_INTERVAL * MULTI_FADEOUT_STATUS) seconds to fadeout status.txt

MAGIC_SHEET_NIL="Tuturu~ ♫"
MAGIC_USER_NIL="Akarin"
MAGIC_FINGERPRINT=""
MAGIC_FADEOUT=0
INDEX_LAST_READ="0"
INDEX_PROCESS="0"
STR_TABLE="danmaku_ex"
SQL_VIEW="select type,uname,text from $STR_TABLE where id="
TYPE_ISGIFT="2"
LIMIT_WRAP_STATUS=23
LIMIT_LINES_STATUS=6
LIMITE_FADEOUT_STATUS=1
LIMIT_USER_BEAT_MAX=666
LIMIT_USER_BEAT_MIN=99

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
    
    # Update in status.txt
    tail -n $LIMIT_LINES_STATUS $URL_LOG_BACKLOG  >$URL_STATUS
}

processStatusFadeOut() {
    if [[ $MAGIC_FADEOUT -eq $MULTI_FADEOUT_STATUS ]];then
	sed -i "1,${LIMITE_FADEOUT_STATUS}d" $URL_STATUS
        MAGIC_FADEOUT=0
    fi
}

parseContentOnGift() {
    updateStatus "感谢 $1"

}

parseContentOnCmd() {
    local _user=$1
    local _friendly_sheet=$(parseFriendlySheetName $2)
    local _user_beat=$3
    local _entry_playlist="${_user}>${2}"

    if [[ ! -z $_user_beat ]];then
	_entry_playlist="${_entry_playlist}>${_user_beat}"
    fi
    echo "$_entry_playlist" >> $URL_PLAYLIST 
    updateStatus "由${_user}提名, '${_friendly_sheet}' 成功加入演奏列表"
    parsePlaylist
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
    
    # Check command schema(_without_ user_beat) and sheet resource exists
    if $(echo "$_hint_sheet" | grep -qE "${_jinyu}[[:space:]]*[,.，。]*${_cmd}");then # TODO less MAGIC HERE, try func
	if [[ $(ls "$RPATH_SHEET_DIR" | grep -i $(echo $_hint_sheet | sed 's/[,.，。大山演奏 ]//g') | wc -l) -eq 1 ]];then
	    return 0
	fi
    fi
    return 1
    

    
}

parseDanmaku() {
    # Valid Danmaku CMD example: ${_jinyu} [,.，。 ]* ${_cmd} [,.，。 ]* $_hint_sheet [,.，。 ]* [ @${_user_beat}[ ]* ]
    local _t="" # temp
    local _rurl_sheet=""
    local _content=""
    local _user=""
    local _user_beat=""
    
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
	    if checkValiadCmd "${_content%@*}";then
	    	_rurl_sheet="$RPATH_SHEET_DIR""/"$(basename $(ls "$RPATH_SHEET_DIR" | grep -i $(echo ${_content%@*} | sed 's/[,.，。大山演奏 ]//g')))
		
		# filter _user_beat
		if $(echo $_t | grep -q '@');then
		    _user_beat=$(echo $_t | sed 's/.*@[[:space:]]*\([[:digit:]]*\).*/\1/')
		    if [[ ! -z $_user_beat ]];then
			if [[ $_user_beat -gt $LIMIT_USER_BEAT_MAX ]] || [[ $_user_beat -lt $LIMIT_USER_BEAT_MIN ]];then
			    _user_beat=""
			fi
		    fi
		fi
		parseContentOnCmd $_user $_rurl_sheet $_user_beat
		
	    fi
	fi
	
    done
    
    INDEX_LAST_READ=$_cur_index
}

updatePlayerTXTNext() {
    local _user=$1
    local _url_sheet=$2

    ./make_txt_player.sh nxt "$_url_sheet" "$_user"

}

parsePlaylist() {
    # Update next part in player.txt 
    local _line=$(wc -l $URL_PLAYLIST | cut -d " " -f1)
    if [[ $_line -eq 2 ]];then
	_t_user=$(sed -n '2,2p' $URL_PLAYLIST | awk -F '>' '{print $1}')
	_t_sheet=$(sed -n '2,2p' $URL_PLAYLIST | awk -F '>' '{print $2}')
	updatePlayerTXTNext  "$_t_user" "$_t_sheet"
    fi
    
    kill -s SIGUSR1 $PID_PLAYLIST_HANDLER

}

updateStatusFriendlyExit() {
    ./make_txt_player.sh wat
    exit 1
}

updateStatusFriendlyStartup() {
    ./make_txt_player.sh cur "$MAGIC_SHEET_NIL" "$MAGIC_USER_NIL"
}

# Main
trap updateStatusFriendlyExit SIGINT SIGTERM

(./daemon_playlist_handler.sh) &
sleep 1.0 # Wait for daemon startup
INDEX_LAST_READ=$(getDanmakuCount)
PID_PLAYLIST_HANDLER=$(cat $FD_PLAYLIST_HANDLER_PIDFILE)
updateStatusFriendlyStartup

while true
do
    if checkUpdate_db;then
        parseDanmaku
	
    fi

    MAGIC_FADEOUT=$(($MAGIC_FADEOUT + 1))
    processStatusFadeOut
    sleep $SEC_DB_CHECK_INTERVAL
done
