#!/bin/env bash
# expend to anything connected, eDP1 is laptop's screen

FALLBACK="eDP1"
EXCEPT="eDP|VIRTUAL"
CON_TARGET=`xrandr | grep ' connected' | grep -vE "${EXCEPT}" | cut -f1 -d\ `
DISCON_TARGET=`xrandr | grep ' disconnected' | grep -vE "${EXCEPT}" | cut -f1 -d\ `
DISCON_TARGET=${DISCON_TARGET:-${CON_TARGET}} # HDMI is hotplug-able, unplug then trigger stop cmd


if [[ "$1" == "stop" ]]
then xrandr --output ${DISCON_TARGET} --off --output ${FALLBACK} --auto
fi

if [[ "$1" == "mirror" ]]
then xrandr --output $CON_TARGET --auto
fi
if [[ "$1" == "single" ]]
then xrandr --output $CON_TARGET --auto --output ${FALLBACK} --off
else xrandr --output $CON_TARGET --auto --left-of ${FALLBACK} # default to expand
fi
