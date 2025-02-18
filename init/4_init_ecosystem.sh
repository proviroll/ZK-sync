#!/bin/bash
set -eu

echo "[4/4] : ecosystem initialization"

# Ecosystem init command
ZKSTACK_INIT_COMMAND="zkstack ecosystem init \
    --deploy-erc20=${DEPLOY_ERC20} \
    --deploy-ecosystem=${DEPLOY_ECOSYSTEM} \
    --l1-rpc-url=${L1_RPC_URL} \
    --observability=${OBSERVABILITY} \
    --deploy-paymaster=${DEPLOY_PAYMASTER} \
    --server-db-url=${SERVER_DB_URL} \
    --server-db-name=${SERVER_DB_NAME} --ignore-prerequisites --verbose"

cd /app/${ECOSYSTEM_NAME}

exec $ZKSTACK_INIT_COMMAND

zkstack ecosystem init \
    --deploy-erc20=true \
    --deploy-ecosystem=true \
    --l1-rpc-url="https://sepolia-rpc.chainsafe.dev/HZOr49jM3N0kOj5J5AoMmVNlNT71-R_atsWK83ZeANE" \
    --observability=true \
    --deploy-paymaster=true \
    --server-db-url="postgres://postgres:mysecretpassword@localhost:5432" \
    --server-db-name="zksync_server_sepolia_provi" \
    --ignore-prerequisites \
    --verbose


#!/bin/bash
set -eu

# Get faucet address from env
FAUCET_ADDRESS="0xE74f5A6D3C4b8CD2078d9C559E1492d4883bE36C"
L1_RPC_URL="https://sepolia-rpc.chainsafe.dev/HZOr49jM3N0kOj5J5AoMmVNlNT71-R_atsWK83ZeANE"
PRIORITY_GAS_PRICE=10000

# Function to send ETH back to faucet
send_eth_to_faucet() {
    local from_address="$1"
    local private_key="$2"
    
    # Get balance
    balance=$(cast balance --rpc-url "$L1_RPC_URL" "$from_address")
    
    if [ "$balance" != "0" ]; then
        # Calculate gas cost (approximate)
        gas_cost=$(cast --to-wei 0.001)
        transfer_amount=$(echo "$balance - $gas_cost" | bc)
        
        if [ "$transfer_amount" -gt "0" ]; then
            echo "Sending $transfer_amount wei from $from_address to faucet"
            cast send "$FAUCET_ADDRESS" \
                --private-key "$private_key" \
                --value "$transfer_amount" \
                --rpc-url "$L1_RPC_URL" || echo "Failed to send from $from_address"
        fi
    fi
}

# List of roles to process
roles=("deployer" "operator" "blob_operator" "fee_account" "governor" "token_multiplier_setter")

# Process each role
for role in "${roles[@]}"; do
    address=$(yq eval ".$role.address" wallets.yaml)
    private_key=$(yq eval ".$role.private_key" wallets.yaml)
    if [ -n "$address" ] && [ -n "$private_key" ]; then
        echo "Processing $role..."
        send_eth_to_faucet "$address" "$private_key"
    fi
done

deployer:                                                                                                                                                                                                       
  address: '0x325d2C2d41a1DfF32E8363aDCF9923da297Fe6f0'                                                                                                                                                         
  private_key: '0xcc4e1caa564085e02a18a0d20dbc1ba3935afc4bd6c9aa3d6a48789ab9f75f69'                                                                                                                             
operator:                                                                                                                                                                                                       
  address: '0xF801e2171787d2250846378BA1299f4dF0523f64'                                                                                                                                                         
  private_key: '0xb4e4028a448861def705fcb0994a5e56012c9aaafb2045bb2e8321c617938d40'                                                                                                                             
blob_operator:                                                                                                                                                                                                  
  address: '0xfbd8de60F6eeC750c600B22Ce8A14F5C0d747F2d'                                                                                                                                                         
  private_key: '0x117d7c8c193ec65801f5d06c1645f2335158239aa372a0201ff12a994e5b8726'                                                                                                                             
fee_account:                                                                                                                                                                                                    
  address: '0x8A9a61E4D209f5fd5c8C6be94A98663eF2fc0214'                                                                                                                                                         
  private_key: '0x883e4f37b5c057619e77ff5fce67c5c7ded17f7631572267bf9bf57931dc7989'                                                                                                                             
governor:                                                                                                                                                                                                       
  address: '0x66A782D1d1B1bd5B3c9e893d3B9d9F68c61b6628'                                                                                                                                                         
  private_key: '0x29c2cb6486c698e9c53ad78f4401735523ca74d798686552a1401e1c732c2f3c'                                                                                                                             
token_multiplier_setter:                                                                                                                                                                                        
  address: '0x60E24D00D8C560AE951422c4BB3b95358CdE4CD4'                                                                                                                                                         
  private_key: '0xcc7051e0b706603adc075f3719901718cfdfab3b8cf67e526bca25a9027f89f1'