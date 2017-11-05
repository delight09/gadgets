#!/bin/babsh --
#
# USAGE: grive_phfc_helper.sh

STR_DIR_GOOGLE_DRIVE_TARGET=Placeholder
STR_PATH_PLACEHOLDER=/srv/google-drive
STR_URI_PHFC=/usr/local/bin/placeholder_freshness_checker.sh

$STR_URI_PHFC # Control directory freshness
grive -u -s $STR_DIR_GOOGLE_DRIVE -p $STR_PATH_PLACEHOLDER # upload changes by grive2
