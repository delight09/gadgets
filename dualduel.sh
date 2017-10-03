#!/bin/env bash
# expend to anything connected, eDP1 is laptop's screen

EXCEPT="eDP|VIRTUAL"
CON_TARGET=`xrandr | grep ' connected' | grep -vE "${EXCEPT}" | cut -f1 -d\ `
DISCON_TARGET=`xrandr | grep ' disconnected' | grep -vE "${EXCEPT}" | cut -f1 -d\ `
DISCON_TARGET=${DISCON_TARGET:-${CON_TARGET}} # HDMI is hotplug-able


if [[ "$1" == "stop" ]]
then xrandr --output ${DISCON_TARGET} --off
else xrandr --output $CON_TARGET --auto --left-of eDP1
fi
