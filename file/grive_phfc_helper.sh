#!/bin/bash --
# Fire PHFC to clean files and use grive to upload(sync) changes
# USAGE: grive_phfc_helper.sh 60 /srv/google-drive/Placeholder

MINS_FRESH=$1
STR_PATH_PLACEHOLDER=$2
STR_DIR_GOOGLE_DRIVE_TARGET=Placeholder
STR_PATH_SYNCDIR=/srv/google-drive
STR_URI_PHFC=/usr/local/bin/placeholder_freshness_checker.sh

$STR_URI_PHFC $MINS_FRESH $STR_PATH_PLACEHOLDER # Control freshness with phfc
grive -u -s $STR_DIR_GOOGLE_DRIVE_TARGET -p $STR_PATH_SYNCDIR # upload changes by grive2
