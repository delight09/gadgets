#!/bin/bash --
# Trap SIGUSR1 signal to parse playlist

# Import configure
source env.conf

updatePlayerTXTCurrent() {
    local _user=$1
    local _url_sheet=$2
    local _user_beat=$3

    ./make_txt_player.sh cur "$_url_sheet" "$_user" "$_user_beat"

}

updatePlayerTXTNext() {
    local _user=$1
    local _url_sheet=$2

    ./make_txt_player.sh nxt "$_url_sheet" "$_user"

}

updatePlayerTXTPointerMetadata() {
    local _url_sheet=$1
    
    ./make_txt_player.sh ptr 0 "$(sed -n '1,1p' $_url_sheet)"

}

updatePlayerTXTWait() {
    ./make_txt_player.sh wat

}

parsePlaylist() {
    local _line=""
    local _t_user=""
    local _t_sheet=""
    local _t_user_beat=""
    
    # Process playlist if no lock
    if [[ ! -f $FD_PROCESS_LOCK ]];then
	touch $FD_PROCESS_LOCK
	_line=$(wc -l $FD_PLAYLIST | cut -d " " -f1)
	
	while [[ $_line -gt 0 ]];
	do
	    if [[ $_line -eq 1 ]];then
		updatePlayerTXTNext "$MAGIC_USER_NIL" "$MAGIC_SHEET_NIL"
	    else
		_t_user=$(sed -n '2,2p' $FD_PLAYLIST | awk -F '>' '{print $1}')
		_t_sheet=$(sed -n '2,2p' $FD_PLAYLIST | awk -F '>' '{print $2}')
		updatePlayerTXTNext  "$_t_user" "$_t_sheet"
	    fi
	    
	    # Get top metadata
	    _t_user=$(sed -n '1,1p' $FD_PLAYLIST | awk -F '>' '{print $1}')
	    _t_sheet=$(sed -n '1,1p' $FD_PLAYLIST | awk -F '>' '{print $2}')
	    _t_user_beat=$(sed -n '1,1p' $FD_PLAYLIST | awk -F '>' '{print $3}')
	    updatePlayerTXTCurrent "$_t_user" "$_t_sheet" "$_t_user_beat"
	    updatePlayerTXTPointerMetadata "$_t_sheet"
	    
	    # Play the sheet
	    parseSheet "$_t_sheet" "$_t_user_beat"
	    updatePlayerTXTWait
	    sleep $SEC_INTRALIST_INTERVAL
	    
	    sed -i '1,1d' $FD_PLAYLIST
	    _line=$(wc -l $FD_PLAYLIST | cut -d " " -f1) # daemon_danmaku_checker would async update playlist.txt
        done
	# Cleanup player.txt on empty playlist
	updatePlayerTXTCurrent "$MAGIC_USER_NIL" "$MAGIC_SHEET_NIL"
        rm -rf $FD_PROCESS_LOCK
    fi

}

parseSheet() {
    local _url_sheet="$1"
    local _user_beat="$2"

    if [[ ! -z $_user_beat ]];then
        /cygdrive/c/Program\ Files\ \(x86\)/ahk/AutoHotkeyU32.exe mnt_player.ahk "$_url_sheet" "$_user_beat"
    else
	/cygdrive/c/Program\ Files\ \(x86\)/ahk/AutoHotkeyU32.exe mnt_player.ahk "$_url_sheet"
    fi
}

trap parsePlaylist SIGUSR1

# Main
echo $$ > $FD_PLAYLIST_HANDLER_PIDFILE
rm -rf $FD_PROCESS_LOCK

while true
do
    sleep $SEC_AWAKE_INTERVAL
done
