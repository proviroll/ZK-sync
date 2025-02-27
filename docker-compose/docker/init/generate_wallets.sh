#!/bin/bash

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Add debug logging
echo "WALLET_PATH is set to: $WALLET_PATH"
echo "Current directory: $(pwd)"

# Use the temp directory from the parent script
TMP_DIR="$HOME/temp_wallet_generator"
mkdir -p $TMP_DIR

# Create a temporary Node.js script to generate wallets
cat > $TMP_DIR/generate_wallets.js << EOL
const { ethers } = require('ethers');
const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

// Function to generate wallet and return formatted object
function generateWalletData() {
    const wallet = ethers.Wallet.createRandom();
    return {
        address: wallet.address,
        private_key: wallet.privateKey
    };
}

const walletData = {
    deployer: generateWalletData(),
    operator: generateWalletData(),
    blob_operator: generateWalletData(),
    fee_account: generateWalletData(),
    governor: generateWalletData(),
    token_multiplier_setter: generateWalletData()
};

// Convert to YAML and write to file
const yamlStr = yaml.dump(walletData);
const outputPath = process.env.WALLET_PATH;

if (!outputPath) {
    console.error('WALLET_PATH environment variable is not set');
    process.exit(1);
}

// Ensure the directory exists
const dir = path.dirname(outputPath);
if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
}

try {
    fs.writeFileSync(outputPath, yamlStr);
    console.log('Successfully wrote wallet data to:', outputPath);
} catch (error) {
    console.error('Failed to write wallet file:', error);
    process.exit(1);
}
EOL

# Create package.json
cat > $TMP_DIR/package.json << EOL
{
    "dependencies": {
        "ethers": "^5.7.2",
        "js-yaml": "^4.1.0"
    }
}
EOL

# Install dependencies
cd $TMP_DIR && npm install

# Execute the script with environment variable explicitly passed
WALLET_PATH="$WALLET_PATH" node $TMP_DIR/generate_wallets.js

# Clean up
rm -rf $TMP_DIR

# Verify the file was created
if [ ! -f "$WALLET_PATH" ]; then
    echo "Error: Failed to generate wallets.yaml at $WALLET_PATH"
    exit 1
else
    echo "Successfully generated wallets at $WALLET_PATH"
    ls -l "$WALLET_PATH"
fi