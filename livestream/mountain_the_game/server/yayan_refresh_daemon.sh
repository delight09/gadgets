#!/bin/bash --
# use yayan.tostring.rb to fetch metadata for client

while 1
do
    yayan.tostring.rb  | sed 's/s:/\n -- /' | sed 's/.\{14\}/&\n/g' > /tmp/yayan.txt
    sleep $((15 * 55))
done
