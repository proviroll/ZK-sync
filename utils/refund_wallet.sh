#!/bin/bash
set -eu

# Get faucet address from env
FAUCET_ADDRESS="0xE74f5A6D3C4b8CD2078d9C559E1492d4883bE36C"
L1_RPC_URL="<rpc_url>"
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