#!/bin/bash
set -eu

# Get faucet address from env
FAUCET_ADDRESS="<FAUCET_ADDRESS>"
L1_RPC_URL="<L1_RPC_URL>"
PRIORITY_GAS_PRICE=10000

# Function to send ETH back to faucet
send_eth_to_faucet() {
    local from_address="$1"
    local private_key="$2"

    # Get balance
    balance=$(cast balance --rpc-url "$L1_RPC_URL" "$from_address")

    if [ "$balance" != "0" ]; then
        # Estimate gas cost for the transaction
        gas_limit=$(cast estimate --from "$from_address" --value "$balance" "$FAUCET_ADDRESS" --rpc-url "$L1_RPC_URL" || echo "21000")
        gas_price=$(cast gas-price --rpc-url "$L1_RPC_URL")

        # Calculate total gas cost with a 20% buffer
        gas_cost=$(echo "$gas_limit * $gas_price * 1.2" | bc | cut -d. -f1)

        # Leave more buffer for gas fluctuations (0.01 ETH = 10000000000000000 wei)
        buffer_amount=10000000000000000

        # Calculate transfer amount leaving enough for gas
        transfer_amount=$(echo "$balance - $gas_cost - $buffer_amount" | bc | cut -d. -f1)

        # Use bc for comparison to handle large numbers
        if (( $(echo "$transfer_amount > 0" | bc -l) )); then
            echo "Sending $transfer_amount wei from $from_address to faucet"
            cast send "$FAUCET_ADDRESS" \
                --private-key "$private_key" \
                --value "$transfer_amount" \
                --gas-limit "$gas_limit" \
                --priority-gas-price "$PRIORITY_GAS_PRICE" \
                --rpc-url "$L1_RPC_URL" || echo "Failed to send from $from_address"
        else
            echo "Balance too low to cover gas costs for $from_address"
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