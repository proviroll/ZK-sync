#!/bin/bash

# Source NVM and Rust environment
. "$NVM_DIR/nvm.sh"
. ~/.cargo/env

# Initialize base command
ZKSTACK_COMMAND="zkstack ecosystem create \
    --ecosystem-name=${ECOSYSTEM_NAME} \
    --chain-name=${CHAIN_NAME} \
    --set-as-default=${SET_AS_DEFAULT} \
    --prover-mode=${PROVER_MODE} \
    --chain-id=${CHAIN_ID} \
    --l1-network=${L1_NETWORK} \
    --l1-batch-commit-data-generator-mode=${L1_BATCH_COMMIT_DATA_GENERATOR_MODE} \
    --link-to-code=${LINK_TO_CODE} \
    --base-token-address=${BASE_TOKEN_ADDRESS} \
    --base-token-price-nominator=${BASE_TOKEN_PRICE_NOMINATOR} \
    --base-token-price-denominator=${BASE_TOKEN_PRICE_DENOMINATOR} \
    --start-containers=${START_CONTAINERS}"

# Conditionally add wallet-related parameters
if [ -n "$wallet_path" ]; then
    ZKSTACK_COMMAND+=" --wallet-path=${wallet_path} --wallet-creation=in-file"
else
    ZKSTACK_COMMAND+=" --wallet-creation=${WALLET_CREATION}"
fi

# Execute the command or use a custom command if provided
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Run zkstack ecosystem create command
    exec $ZKSTACK_COMMAND

    # Change directory to ecosystem name and run init command
    cd ${ECOSYSTEM_NAME}
    zkstack ecosystem init
    zkstack server
fi
