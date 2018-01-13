#!/bin/env bash
# USAGE: dualduel.sh stop   -- disconnect all external screen, enable embed one
#        dualduel.sh mirror -- enable both external and embed screens.
#        dualduel.sh single -- enable only the external screen, disable the embed one
#        dualduel.sh expand -- expand the external screen to left side of embed one

# MAGIC parts
SCR_EMBED="eDP1"
SCR_EXTR="HDMI1"

do_stop() {
    xrandr --output $SCR_EXTR --off --output $SCR_EMBED --auto

}

do_mirror() {
    xrandr --output $SCR_EXTR --auto --output $SCR_EMBED --auto

}

do_single() {
    xrandr --output $SCR_EXTR --auto --output $SCR_EMBED --off

}

do_expand() {
    xrandr --output $SCR_EXTR --auto --left-of $SCR_EMBED --output $SCR_EMBED --auto

}


is_external_disconnected() {
     xrandr | grep $SCR_EXTR | grep -qi disconnected

}


case "$1" in 
stop)
    do_stop
;;

mirror)
    if is_external_disconnected;then
        do_stop
    else
        do_mirror
    fi
;;

single)
    if is_external_disconnected;then
        do_stop
    else
        do_single
    fi
;;

expand)
    if is_external_disconnected;then
        do_stop
    else
        do_expand
    fi
;;

*)
    echo "USAGE: $0 <stop|mirror|single|expand>"
    exit 1

esac
