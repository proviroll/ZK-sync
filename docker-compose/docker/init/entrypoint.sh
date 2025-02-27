#!/bin/bash
set -eu

echo "[1/3] Generating & provisioning wallets..."
/script/provision_wallets.sh

echo "[2/3] Creating ecosystem..."
# Create ecosystem
if [ "$SKIP_CREATE_ECOSYSTEM" = "false" ]; then
    # Clean up existing ecosystem directory if it exists
    if [ -d "$ECOSYSTEM_NAME" ]; then
        echo "Cleaning up existing ecosystem directory..."
        rm -rf "$ECOSYSTEM_NAME"
    fi

    zkstack ecosystem create \
        --ecosystem-name="$ECOSYSTEM_NAME" \
        --chain-name="$CHAIN_NAME" \
        --set-as-default="$SET_AS_DEFAULT" \
        --prover-mode="$PROVER_MODE" \
        --chain-id="$CHAIN_ID" \
        --l1-network="$L1_NETWORK" \
        --link-to-code="" \
        --l1-batch-commit-data-generator-mode="$L1_BATCH_COMMIT_DATA_GENERATOR_MODE" \
        --evm-emulator=false \
        --start-containers=false \
        --wallet-path="$WALLET_PATH" \
        --wallet-creation="in-file" \
        --base-token-address="$BASE_TOKEN_ADDRESS" \
        --base-token-price-nominator="$BASE_TOKEN_PRICE_NOMINATOR" \
        --base-token-price-denominator="$BASE_TOKEN_PRICE_DENOMINATOR" \
        --ignore-prerequisites \
        --verbose
fi

echo "[3/3] Initializing ecosystem..."
# Initialize ecosystem
cd "${ECOSYSTEM_NAME}"
if [ "$SKIP_INIT_ECOSYSTEM" = "false" ]; then
    zkstack ecosystem init \
        --deploy-erc20="$DEPLOY_ERC20" \
        --deploy-ecosystem="$DEPLOY_ECOSYSTEM" \
        --l1-rpc-url="$L1_RPC_URL" \
        --observability="$OBSERVABILITY" \
        --deploy-paymaster="$DEPLOY_PAYMASTER" \
        --server-db-url="$SERVER_DB_URL" \
        --server-db-name="$SERVER_DB_NAME" \
        --ignore-prerequisites \
        --verbose
fi

echo "Setup complete!"
