#!/bin/sh --
# Digital Big Ben, it's Big Danny
# For this moment, it's dummy(no sound effect)
# Notice: Need `figlet` tool
# USAGE: BigDanny.sh 30 # exit after 30 minutes

# GLOBAL VARIABLES
STR_FORTUNE=''
SEC_REFRESH_INTERVAL=5
[ -z $1 ] && MIN_STOP=99999 || MIN_STOP=$1

fetch_yiyan() { # fetch fortune cookie with yiyan API wrapper
    STR_FORTUNE=$(yayan.tostring.rb)
}

SEC_INIT=$(date +%s)
SEC_LAST=$((60 * ${MIN_STOP}))

fetch_yiyan
while [ $(( $(date +%s) - ${SEC_LAST} )) -lt ${SEC_INIT} ]; do
    tput clear
    echo -e "$(date '+%m/%d'| sed -e 's/\(.\)/\1 /g')\n$(date '+%H : %M : %S')" | figlet
    echo $STR_FORTUNE

    read -rsn1 -t $SEC_REFRESH_INTERVAL input
    if [ "$input" = "f" ]; then
        fetch_yiyan
    fi
done

# Dummy solution to alert
[ ! -z "$2" ] && echo "$2" | figlet
echo -e "\a" # Ring a dummy bell
