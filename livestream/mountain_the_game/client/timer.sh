#!/bin/bash --
# print live timer to serve
# USAGE timer.sh 1020000

# print prototype
# echo "$(date '+%Y/%M/%d %H:%M')\n山龄 99999 \n技能冷却 AA:BB"

COUNT_METADATA=${1:-999999}
SEC_INTERVAL_COOLDOWN=$((15 * 60))

while true
do
curl -o /cygdrive/r/Temp/yayan.txt <ip-server>:<port>/yayan.txt

_sec_cd=$SEC_INTERVAL_COOLDOWN
while [ $_sec_cd -gt 0 ]; do
	echo "$(date '+%Y/%m/%d %H:%M')\n山龄 $COUNT_METADATA \n技能冷却 $(($_sec_cd / 60)):$(($_sec_cd % 60))" > timer.txt
   if [[ $(($_sec_cd % 3)) -eq 0 ]];then
	 : $((COUNT_METADATA++))
   fi
   sleep 1
   : $((_sec_cd--))
done
# cool down finished

done
