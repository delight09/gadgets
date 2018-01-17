#!/bin/env bash
# Cuz `curl -O -L ` takes e-l-e-v-e-n key strokes, let us boost!!
# DEPENT: curl
# NOTICE: For temporary disable proxy, use cudl.sh <url> -x http:// <your-url>
# USAGE: cudl.sh https://exmaple.tld/path/to/resource

PROXY='socks://127.0.0.1:1088'

curl -x $PROXY -O -L $@
