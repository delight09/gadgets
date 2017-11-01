#!/bin/sh --
# Digital BigBen, it's BigDanny
# For now, it's dummy(no sound)

## fetch fortune cookie from yiyan
fetch_yiyan() {
    FortuneC=$(/home/jiahao/git/fetch_yiyan/yiyan.rb)
}

fetch_yiyan
START=$(date +%s)
[ -z $1 ] && WAIT_FIN_MINUTE=99999 || WAIT_FIN_MINUTE=$1


DURING=$((60 * ${WAIT_FIN_MINUTE}))
while [ $(( $(date +%s) - ${DURING} )) -lt ${START} ]; do
	tput clear
	echo -e "$(date '+%m / %d')\n$(date '+%H : %M : %S')" | figlet
        echo $FortuneC


read -rsn1 -t 3 input
if [ "$input" = "f" ]; then
    fetch_yiyan
fi

done

# Dummy solution to alert
[ ! -z "$2" ] && echo "$2" | figlet
echo -e "\a" # Ring a dummy bell
