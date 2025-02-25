#!/bin/bash
set -eu

# check environment variables
reqenv() {
    if [ -z "${!1:-}" ]; then
        echo "Error: environment variable '$1' is not set. check .env file!"
        exit 1
    fi
}

reqenv "ECOSYSTEM_NAME"
reqenv "CHAIN_NAME"
reqenv "WALLET_PATH"
reqenv "PROVER_MODE"
reqenv "L1_NETWORK"
reqenv "LINK_TO_CODE"
reqenv "L1_FAUCET_ADDRESS"
reqenv "L1_FAUCET_PRIVATE_KEY"

echo "[1/4] : init environment variables"

if [ -z "${PRIORITY_GAS_PRICE:-}" ]; then
	export PRIORITY_GAS_PRICE=10000
fi

if [ -z "${SET_AS_DEFAULT:-}" ]; then
	export SET_AS_DEFAULT=true
fi

if [ -z "${CHAIN_ID:-}" ]; then
	export CHAIN_ID=53151462
fi

if [ -z "${L1_BATCH_COMMIT_DATA_GENERATOR_MODE:-}" ]; then
	export L1_BATCH_COMMIT_DATA_GENERATOR_MODE=rollup
fi

if [ -z "${BASE_TOKEN_ADDRESS:-}" ]; then
	export BASE_TOKEN_ADDRESS="0x0000000000000000000000000000000000000001"
fi

if [ -z "${BASE_TOKEN_PRICE_NOMINATOR:-}" ]; then
	export BASE_TOKEN_PRICE_NOMINATOR=1
fi

if [ -z "${BASE_TOKEN_PRICE_DENOMINATOR:-}" ]; then
	export BASE_TOKEN_PRICE_DENOMINATOR=1
fi

if [ -z "${START_CONTAINERS:-}" ]; then
	export START_CONTAINERS=false
fi

if [ -z "${FAUCET_AMOUNT_ETH:-}" ]; then
	export FAUCET_AMOUNT_ETH=6
fi

if [ -z "${DEPLOY_ERC20:-}" ]; then
	export DEPLOY_ERC20=true
fi

if [ -z "${DEPLOY_ECOSYSTEM:-}" ]; then
	export DEPLOY_ECOSYSTEM=true
fi

if [ -z "${L1_RPC_URL:-}" ]; then
	export L1_RPC_URL=https://sepolia-rpc.chainsafe.dev/HZOr49jM3N0kOj5J5AoMmVNlNT71-R_atsWK83ZeANE
fi

if [ -z "${OBSERVABILITY:-}" ]; then
	export OBSERVABILITY=true
fi

if [ -z "${DEPLOY_PAYMASTER:-}" ]; then
	export DEPLOY_PAYMASTER=true
fi

if [ -z "${SERVER_DB_URL:-}" ]; then
	export SERVER_DB_URL=postgres://postgres:mysecretpassword@localhost:5432
fi

if [ -z "${SERVER_DB_NAME:-}" ]; then
	export SERVER_DB_NAME=zksync_server_${L1_NETWORK}_${ECOSYSTEM_NAME}
fi
