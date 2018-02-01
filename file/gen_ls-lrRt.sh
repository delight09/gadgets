#!/usr/bin/env sh
# Generate ls-lrRt.txt for your NAS

TARGET_DIR=/path/to/your/disk/mount

cd $TARGET_DIR
ls -lrRt | sed 's/$/'"`echo \\\r`/" > ls-lrRt.txt
