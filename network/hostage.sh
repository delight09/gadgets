#!/bin/env sh
# Connect host(age) w/ mosh
# DEPENT: mosh, ssh
# USAGE: hostage 10.0.0.1 [2222]

PORT_MOSH=$((RANDOM % 900 + 60099)) #skip 60000 - 60099
PORT_SSH=${2:-30022}

mosh -p $PORT_MOSH --ssh="ssh -p ${PORT_SSH}" $1
