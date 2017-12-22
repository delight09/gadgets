#!/bin/sh 
# Make txt, list sheets dir in pretty way

FD_TEMP=/tmp/temp.librarylist.raw
FD_DEST=/cygdrive/r/txt/librarylist.txt

ls sheets | grep -v danmaku > $FD_TEMP
sed -i 's/.mnt.txt//g' $FD_TEMP

sed -i '1,12 s/$/|/g' $FD_TEMP
sed -n '13,$p' $FD_TEMP >${FD_TEMP}.yet
sed -i '13,$d' $FD_TEMP
paste $FD_TEMP ${FD_TEMP}.yet >${FD_TEMP}.fin

echo '曲库' > $FD_TEMP
column -s '|' -t -c 80 -o ' ' ${FD_TEMP}.fin >> $FD_TEMP
cat $FD_TEMP

cp $FD_TEMP $FD_DEST
