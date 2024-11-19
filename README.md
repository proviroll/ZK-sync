# ZK-sync
ZK-sync for rollups as a service

# ZKStack Ecosystem Setup

## Build Docker Image
```bash
docker build -t zkstack-ecosystem
```
## ZKStack Ecosystem Creation, Initiation, Running
Note: Please take care of the wallets( creation and topping up) before proceeding to run the network.

```bash
docker run -v /local/path/to/wallets.yaml:/container/path/wallets.yaml \
           -e wallet_path=/container/path/wallets.yaml \
           zkstack-ecosystem
```
### Available Environment Variables
# Default environment variables for zkstack ecosystem creation
Default environment variables for zkstack ecosystem creation:
```
ENV ECOSYSTEM_NAME=provi
ENV CHAIN_NAME=proviNet
ENV SET_AS_DEFAULT=true
ENV WALLET_CREATION=random
ENV PROVER_MODE=gpu
ENV CHAIN_ID=271
ENV L1_NETWORK=sepolia
ENV L1_BATCH_COMMIT_DATA_GENERATOR_MODE=rollup
ENV LINK_TO_CODE=/zksync
ENV BASE_TOKEN_ADDRESS="0x0000000000000000000000000000000000000001"
ENV BASE_TOKEN_PRICE_NOMINATOR=1
ENV BASE_TOKEN_PRICE_DENOMINATOR=1
ENV START_CONTAINERS=false
```

## Wallets

### Wallet Configuration Template

Create a `wallets.yaml` file with the following structure:

```yaml
deployer:
  address: 0x..
  private_key: 0x..
operator:
  address: 0x..
  private_key: 0x..
blob_operator:
  address: 0x..
  private_key: 0x..
fee_account:
  address: 0x..
  private_key: 0x..
governor:
  address: 0x..
  private_key: 0x..
token_multiplier_setter:
  address: 0x..
  private_key: 0x..
```

### Topping up the Wallets

Transfer a sufficient amount of L1 ETH to each account. (e.g. 5 Sepolia ETH for each account)
