#!/bin/env bash
# AKA - Bad Boy sHell using one password for tuns of machines
# USAGE: bbh 10.0.0.1

PASSWORD="redhat"
sshpass -p $PASSWORD ssh -oStrictHostKeyChecking=no root@$@
