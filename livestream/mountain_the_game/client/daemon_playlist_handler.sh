#!/bin/bash --
# Trap SIGUSER1 to parse playlist

SEC_INTRALIST_INTERVAL=3
SEC_AWAKE_INTERVAL=5
FD_PLAYER_HANDLER_PIDFILE="/tmp/playlist_handler.pid"
URL_PLAYLIST="/cygdrive/r/txt/playlist.txt"
MAGIC_SHEET_NIL="Tuturu~ ♫"
MAGIC_USER_NIL="Akarin"

old_worker() {
    local _user=$1 # TODO make a background worker
	local _url_sheet=$2

    ./make_txt_player.sh cur $_url_sheet $_user
    /cygdrive/c/Program\ Files\ \(x86\)/ahk/AutoHotkeyU32.exe mnt_player-ng.ahk $_url_sheet # TODO $_user_beat

}

updatePlayerTXTCurrent() {
    local _user=$1
	local _url_sheet=$2

    ./make_txt_player.sh cur "$_url_sheet" "$_user"

}

updatePlayerTXTNext() {
    local _user=$1
	local _url_sheet=$2

    ./make_txt_player.sh nxt "$_url_sheet" "$_user"

}

parsePlaylist() {
    local _line=$(wc -l $URL_PLAYLIST | cut -d " " -f1)
	local _t_user=""
	local _t_sheet=""
	
	
    if [[ -f $URL_PLAYLIST ]];then
	    while [[ $_line -gt 0 ]];
	    do
	        if [[ $_line -eq 1 ]];then
			    updatePlayerTXTNext "$MAGIC_USER_NIL" "$MAGIC_SHEET_NIL"
			else
		    	_t_user=$(sed -n '2,2p' $URL_PLAYLIST | awk -F '>' '{print $1}')
		    	_t_sheet=$(sed -n '2,2p' $URL_PLAYLIST | awk -F '>' '{print $2}')
		    	updatePlayerTXTNext  "$_t_user" "$_t_sheet"
		    fi
			
			# Get top metadata, TODO beat($3)
			_t_user=$(sed -n '1,1p' $URL_PLAYLIST | awk -F '>' '{print $1}')
			_t_sheet=$(sed -n '1,1p' $URL_PLAYLIST | awk -F '>' '{print $2}')
			updatePlayerTXTCurrent "$_t_user" "$_t_sheet"
			
			# Play the sheet, TODO beat($2)
			parseSheet $_t_sheet
			sleep $SEC_INTRALIST_INTERVAL
			
			sed -i '1,1d' $URL_PLAYLIST
			_line=$(($_line - 1))
        done
		# Cleanup player.txt on empty playlist
		updatePlayerTXTCurrent "$MAGIC_USER_NIL" "$MAGIC_SHEET_NIL"
	    sed -i "3,3 s<.*<>>><" $FD_DIST

	
	
	fi #TODO error handle

}

parseSheet() {
	local _url_sheet=$1
	local _user_beat=$2

    /cygdrive/c/Program\ Files\ \(x86\)/ahk/AutoHotkeyU32.exe mnt_player-ng.ahk $_url_sheet # TODO $_user_beat

}

trap parsePlaylist SIGUSR1

# Main
echo $$ > $FD_PLAYER_HANDLER_PIDFILE
while true
do
    sleep $SEC_AWAKE_INTERVAL
done