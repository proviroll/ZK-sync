#!/bin/bash

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Create a temporary directory in the current directory
TMP_DIR="/temp_wallet_generator"
mkdir -p $TMP_DIR

# Create a temporary Node.js script to generate wallets
cat > $TMP_DIR/generate_wallets.js << EOL
const { ethers } = require('ethers');
const fs = require('fs');
const yaml = require('js-yaml');

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

// Ensure directory exists
if (!fs.existsSync('scripts')) {
    fs.mkdirSync('scripts');
}

// Convert to YAML and write to file
const yamlStr = yaml.dump(walletData);
fs.writeFileSync('/script/wallets.yaml', yamlStr);
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

# Execute the script
node $TMP_DIR/generate_wallets.js

# Clean up
rm -rf $TMP_DIR