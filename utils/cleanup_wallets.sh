#!/bin/bash
set -eu

echo "Starting cleanup - returning ETH to faucet..."

# Source environment variables
FAUCET_ADDRESS="$L1_FAUCET_ADDRESS"
PRIORITY_GAS_PRICE="${PRIORITY_GAS_PRICE:-10000}"

# Function to parse YAML and get wallet data
get_wallet_data() {
    local role="$1"
    local field="$2"
    yq eval ".$role.$field" "$WALLET_PATH"
}

send_eth_to_faucet() {
    local from_address="$1"
    local private_key="$2"

    # Get balance
    balance=$(cast balance --rpc-url "$L1_RPC_URL" "$from_address")

    if [ "$balance" != "0" ]; then
        # Calculate gas cost for transfer (approximate)
        gas_cost=$(cast --to-wei 0.001)
        transfer_amount=$(echo "$balance - $gas_cost" | bc)

        if [ "$transfer_amount" -gt "0" ]; then
            echo "Sending $transfer_amount wei from $from_address to faucet"
            cast send "$FAUCET_ADDRESS" \
                --priority-gas-price "$PRIORITY_GAS_PRICE" \
                --value "$transfer_amount" \
                --from "$from_address" \
                --private-key "$private_key" \
                --rpc-url "$L1_RPC_URL" || echo "Failed to send from $from_address"
        fi
    fi
}

# List of roles to clean up
roles=("deployer" "operator" "blob_operator" "fee_account" "governor" "token_multiplier_setter")

# Return ETH from each wallet
for role in "${roles[@]}"; do
    address=$(get_wallet_data "$role" "address")
    private_key=$(get_wallet_data "$role" "private_key")
    if [ -n "$address" ] && [ -n "$private_key" ]; then
        echo "Processing $role..."
        send_eth_to_faucet "$address" "$private_key"
    fi
done

echo "Cleanup complete"