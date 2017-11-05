#!/bin/bash --
# Delete files in placeholder, when lives longer than MINS_FRESH minutes.
# Files elder than MAGIC_MINS_ELDER_SAFTY won't get influenced.
# NOTICE: MINS_FRESH should smaller than MAGIC_MINS_ELDER_SAFTY,
# script should get triggered more than one time within MINS_FRESH.
# USAGE: placeholder_freshness_checker.sh 60 /path/to/placeholder

MINS_FRESH=$1
STR_PATH_PLACEHOLDER=$2
MAGIC_MINS_ELDER_SAFTY=120

echo find $STR_PATH_PLACEHOLDER -mmin +$MINS_FRESH -mmin -$MAGIC_MINS_ELDER_SAFTY -exec 'rm -f {} \;'
