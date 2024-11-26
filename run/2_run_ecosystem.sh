#!/bin/bash
set -eu

echo "[2/2] : running the ecosystem"

# Ecosystem run command
ZKSTACK_RUN_COMMAND="zkstack server"

cd ${ECOSYSTEM_NAME}
exec $ZKSTACK_RUN_COMMAND