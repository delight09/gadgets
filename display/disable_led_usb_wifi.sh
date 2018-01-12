#!/bin/sh
# Wait for associate then disable led on USB wifi adapter with led sub-system

disable_led() {
local DEVICE_NAME=rt2800usb-phy0

sleep 60
for i in /sys/class/leds/${DEVICE_NAME}*
do
    echo 0 > ${i}/brightness
done
}

(disable_led ) &
