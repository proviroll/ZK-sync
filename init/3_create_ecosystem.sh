#!/bin/bash
set -eu

echo "[3/4] : creating the ecosystem"

# Ecosystem creation command
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
    --evm-emulator=false \
    --start-containers=${START_CONTAINERS}"

# Moving to the project's root
ZKSTACK_COMMAND+=" --wallet-path=${WALLET_PATH} --wallet-creation=in-file --ignore-prerequisites"

# echo "$ZKSTACK_COMMAND"
exec $ZKSTACK_COMMAND
