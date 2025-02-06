#!/bin/bash
set -eu

echo "[2/4] : faucet eth to environment accounts"

# .env
FAUCET_PRIVATE_KEY="$L1_FAUCET_PRIVATE_KEY"
FAUCET_ADDRESS="$L1_FAUCET_ADDRESS"

# Check if wallets.yaml exists, if not generate it
if [ ! -f "$WALLET_PATH" ]; then
    echo "wallets.yaml not found. Running generate_wallets.sh..."
    /script/generate_wallets.sh
    echo "Wallets generated and saved to $WALLET_PATH"

    # Output the contents of the newly created wallets.yaml
    echo -e "\nContents of newly generated wallets.yaml:"
    cat "$WALLET_PATH"
    echo -e "\n"
fi

# Function to parse YAML and get address
get_address() {
    local role="$1"
    yq eval ".$role.address" "$WALLET_PATH"
}

send_eth() {
  receiver_address="$1"
  amount_to_eth="$2"
  amount_to_send=$(cast to-wei $amount_to_eth)

  # if receiver has more eth than amount to send, no need to send
  receiver_balance=$(cast balance --rpc-url "$L1_RPC_URL" "$receiver_address")
  if [ "$(echo "$receiver_balance >= $amount_to_send" | bc)" -eq 1 ]; then
    echo "$receiver_address already has enough balance"
  else
    echo "$receiver_address doesn't have enough balance, let's top it up..."

    # if FAUCET_PRIVATE_KEY is not set, error
    if [ -z "$FAUCET_PRIVATE_KEY" ]; then
      echo "FAUCET_PRIVATE_KEY is not set"
      exit 1
    fi

    # if sender has less eth than amount to send, error
    sender_balance=$(cast balance --rpc-url "$L1_RPC_URL" "$FAUCET_ADDRESS")
    if [ "$(echo "$sender_balance < $amount_to_send" | bc)" -eq 1 ]; then
      echo "$FAUCET_ADDRESS does not have enough balance"
      exit 1
    fi

    # send eth
    cast send "$receiver_address" --priority-gas-price $PRIORITY_GAS_PRICE --value "$amount_to_send" --from "$FAUCET_ADDRESS" --private-key "$FAUCET_PRIVATE_KEY" --rpc-url "$L1_RPC_URL"
    echo "Sent $amount_to_eth eth to $receiver_address"
  fi
}

# List of roles that need ETH
roles=("deployer" "operator" "blob_operator" "fee_account" "governor" "token_multiplier_setter")

# Send ETH to each address
for role in "${roles[@]}"; do
    address=$(get_address "$role")
    if [ -n "$address" ]; then
        echo "Processing $role..."
        send_eth "$address" $FAUCET_AMOUNT_ETH
    else
        echo "Warning: Could not get address for $role"
    fi
done
