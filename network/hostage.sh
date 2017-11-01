#!/bin/env sh
# connect host(age) w/ mosh
# USAGE: hostage 10.0.0.1 2222

PORT=${2:-30022}
mosh --ssh="ssh -p ${PORT}" $1
