#!/bin/env bash
# Cuz `curl -O -L ` takes 11 key strokes, let's boost!!
# NOTICE: for non-proxy situation, use curldl.sh <url> -x http:// instead
# USAGE: curldl.sh https://exmaple.tld/path/to/resource

PROXY='socks://127.0.0.1:1088'

curl -x $PROXY -O -L $@
