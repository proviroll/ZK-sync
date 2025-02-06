#!/bin/bash
set -eu

echo "[2/2] : running the ecosystem"

# Ecosystem run command
ZKSTACK_RUN_COMMAND="zkstack server --ignore-prerequisites --verbose"

cd /app/${ECOSYSTEM_NAME}
exec $ZKSTACK_RUN_COMMAND