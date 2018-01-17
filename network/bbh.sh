#!/bin/env bash
# Bad Boy sHell, connect clusters with Single Simple non-Hashed password
# DEPTENT: sshpass
# USAGE: bbh 10.0.0.1

PASSWORD="redhat"
sshpass -p $PASSWORD ssh -oStrictHostKeyChecking=no root@$@
