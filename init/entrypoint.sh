#!/bin/bash
set -e

# Ensure NVM_DIR is set
export NVM_DIR="/root/.nvm"

# Source nvm and cargo environments
. "$NVM_DIR/nvm.sh"
. ~/.cargo/env

# Optional: Verify that yarn is available
yarn --version

# Make scripts executable
chmod +x /script/*.sh

# Execute your scripts
source /script/1_init_environment.sh
/script/2_faucet.sh

cd /app

# Add error handling for the failing script
if ! /script/3_create_ecosystem.sh; then
    echo "zkstack crashed. Here is the crash report:"
    cat /tmp/report-*.toml || echo "No crash report found."
    exit 1
fi

# /script/4_init_ecosystem.sh
