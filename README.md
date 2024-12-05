# ZKStack Ecosystem Setup Guide
A containerized solution for ZK-sync rollups as a service

## Setup

### 1. Build Docker Images
```bash
# Build initialization image
docker build -t zk-sync-init ./init

# Build runtime image
docker build -t zk-sync-run ./run
```

### 2. Deploy and Run
```bash
# Step 1: Initialize the ecosystem
docker run --network=host \
    --name my_container_init \
    --env-file .env \
    -v /path/to/wallets.yaml:/scripts/wallets.yaml \
    -v zksync-app-data:/app \
    zk-sync-init

# Step 2: Run the ecosystem
# Note: Uses volumes from init container
docker run --network=host \
    --volumes-from=my_container_init \
    --name my_container_run \
    --env-file .env \
    zk-sync-run
```

## Configuration

### Environment Variables
Create a `.env` file with the following configuration:
```env
ECOSYSTEM_NAME=provi
CHAIN_NAME=proviTestnet
WALLET_PATH=/scripts/wallets.yaml
PROVER_MODE=gpu
L1_NETWORK=sepolia
LINK_TO_CODE=/app/zksync
L1_FAUCET_ADDRESS=<your_faucet_address>
L1_FAUCET_PRIVATE_KEY=<your_faucet_private_key>
```

### Wallet Setup

#### 1. Faucet Configuration
> ⚠️ **Important**: Only the faucet account needs to be funded. It will automatically distribute funds to other required wallets.
- Add faucet address and private key to `.env` file
- Ensure faucet has sufficient L1 ETH

#### 2. Wallet Configuration Template
Create a `wallets.yaml` file with the following structure:
```yaml
deployer:
  address: 0x...
  private_key: 0x...
operator:
  address: 0x...
  private_key: 0x...
blob_operator:
  address: 0x...
  private_key: 0x...
fee_account:
  address: 0x...
  private_key: 0x...
governor:
  address: 0x...
  private_key: 0x...
token_multiplier_setter:
  address: 0x...
  private_key: 0x...
```

## Container Workflow
1. **Initialization Container (`zk-sync-init`)**
   - Sets up the initial ecosystem
   - Creates necessary volumes and configurations

2. **Runtime Container (`zk-sync-run`)**
   - Depends on initialization container
   - Mounts volumes from init container
   - Runs the actual ZKStack ecosystem

## Notes
- The runtime container requires the initialization container's volume
- Automatic wallet funding is handled by the faucet account
- Manual wallet funding is not required except for the faucet account