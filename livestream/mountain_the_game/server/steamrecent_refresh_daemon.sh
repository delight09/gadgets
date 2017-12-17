#!/bin/bash --
# fetch steam recent as JPEG picture for client

while 1
do
phantomjs /path/to/steamrecent_domcapture.js 'http://steamcommunity.com/id/dummyred' /tmp/steam_showbox.jpg 2>&1
sleep $((60 * 59))
done

