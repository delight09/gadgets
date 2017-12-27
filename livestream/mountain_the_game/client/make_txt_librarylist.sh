#!/bin/bash --
# Make txt, list sheets dir in pretty way

# Import configure
source env.conf

# MAGIC global variables
STR_SPECIAL_SHEET="danmaku"

# Init
_t=""
rm -f $FD_TEMP

# Real World character Length
LEN_NON_ANSI=2
getRWLength() {
    local _string=$1
    local _count=0
    
    for i in $(seq 0 $((${#_string} - 1)))
    do
	if echo ${_string:$i:1} | grep -qE '[a-z,A-Z]'
	then
	    _count=$(($_count + 1))
	else
	    _count=$(($_count + $LEN_NON_ANSI))
	fi
    done
    echo $_count
}


for i in $(ls $RPATH_SHEET_DIR | grep -v $STR_SPECIAL_SHEET)
do
    _t=${i%.mnt.txt}
    _t="${_t%.*} - feat.${_t#*.}"
    
    echo $(getRWLength "$_t")" $_t" >> $FD_TEMP
    
done 
# Sort sheet files with RWLength
cat $FD_TEMP | sort -n -s | cut -d" " -f2- >$FD_TEMP_FIN

# Split lines to FD_DEST1 and FD_DEST2
rm -f $FD_DEST1 $FD_DEST2
_loop_times=$(($(wc -l $FD_TEMP | cut -d " " -f1) - $LIMIT_LINES_FILE1))
for i in $(seq 1 $_loop_times)
do
    sed -n "$(($i * 2 -1)),$(($i * 2 -1))p" $FD_TEMP_FIN >>$FD_DEST1
    sed -n "$(($i * 2)),$(($i * 2))p" $FD_TEMP_FIN >>$FD_DEST2
    
done
# Padding rest to FD_DEST1
sed -n "$(($_loop_times * 2 + 1)),\$p" $FD_TEMP_FIN >>$FD_DEST1
