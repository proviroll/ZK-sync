#!/bin/bash
set -e  # Exit on any error

# Set environment variables
L1_FAUCET_PRIVATE_KEY="<private_key>"
L1_FAUCET_ADDRESS="0xE74f5A6D3C4b8CD2078d9C559E1492d4883bE36C"
CHAIN_NAME=proviroll_testnet
ECOSYSTEM_NAME=zksync

# Create directories
mkdir -p tmp-data artifacts script

# Build the init image
echo "Building init image..."
if ! docker build -t zk-sync-init ../rollup/init; then
    echo "Failed to build init image"
    exit 1
fi

# Create .env file in current directory
cat > .env << EOL
ECOSYSTEM_NAME=$ECOSYSTEM_NAME
CHAIN_NAME=$CHAIN_NAME
WALLET_PATH=/script/wallets.yaml
PROVER_MODE=gpu
L1_NETWORK=sepolia
LINK_TO_CODE=/app/zksync
L1_FAUCET_ADDRESS=$L1_FAUCET_ADDRESS
L1_FAUCET_PRIVATE_KEY=$L1_FAUCET_PRIVATE_KEY
EOL

# Check if container already exists and remove it
if docker ps -a | grep -q ${ECOSYSTEM_NAME}_init; then
    echo "Removing existing container..."
    docker rm -f ${ECOSYSTEM_NAME}_init
fi

echo "Running init container..."
# Run init container with log capture
docker run --network=host --name ${ECOSYSTEM_NAME}_init \
    --env-file .env \
    -v zksync-app-data:/app \
    -v "$(pwd)/tmp-data:/tmp" \
    zk-sync-init 2>&1 | tee artifacts/init.log || \
(
    echo 'Container failed, collecting crash data...' && \
    cp tmp-data/report-*.toml artifacts/ 2>/dev/null || true && \
    docker logs ${ECOSYSTEM_NAME}_init > artifacts/init_crash.log 2>&1 && \
    docker inspect ${ECOSYSTEM_NAME}_init > artifacts/inspect.log 2>&1 && \
    echo '=== Container Logs ===' && \
    cat artifacts/init.log artifacts/init_crash.log && \
    echo '=== Crash Report ===' && \
    cat artifacts/report-*.toml 2>/dev/null || echo 'No crash report found' && \
    echo '=== Container Inspection ===' && \
    cat artifacts/inspect.log && \
    exit 1
)

echo "Init container completed successfully"