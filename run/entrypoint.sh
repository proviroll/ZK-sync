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
/script/2_run_ecosystem.sh
