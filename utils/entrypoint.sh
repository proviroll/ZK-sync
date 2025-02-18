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

cleanup_and_exit() {
    echo "Error occurred. Running cleanup..."
    if [ -f "$WALLET_PATH" ]; then
        echo "Running cleanup script..."
        /script/cleanup_wallets.sh || echo "Cleanup failed"
    fi
    exit 1
}

# Run script 3 with error handling
if ! /script/3_create_ecosystem.sh; then
    echo "zkstack ecosystem creation crashed. Here is the crash report:"
    cat /tmp/report-*.toml || echo "No crash report found."
    cleanup_and_exit
fi

# Run script 4 with error handling
if ! /script/4_init_ecosystem.sh; then
    echo "zkstack ecosystem initialization crashed. Here is the crash report:"
    cat /tmp/report-*.toml || echo "No crash report found."
    cleanup_and_exit
fi