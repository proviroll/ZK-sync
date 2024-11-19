# Use Ubuntu as base image
FROM ubuntu:20.04

# Prevent timezone prompt
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    cmake \
    clang \
    lldb \
    lld \
    libssl-dev \
    libpq-dev \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configure git for HTTPS instead of SSH
RUN git config --global url."https://github.com/".insteadOf git@github.com: && \
    git config --global url."https://".insteadOf git://

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install NVM, Node.js, and Yarn
RUN curl -o-  | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    npm install -g yarn && \
    yarn set version 1.22.19

# Install Docker (note: this is for docker-in-docker scenarios, might not be needed)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" && \
    apt-get update && \
    apt-get install -y docker-ce && \
    rm -rf /var/lib/apt/lists/*

# Install Cargo tools
ENV PATH="/root/.cargo/bin:${PATH}"
RUN . ~/.cargo/env && \
    cargo install cargo-nextest && \
    cargo install sqlx-cli --version 0.8.1

# Install Foundry ZKsync
RUN curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash && \
    ~/.foundry/bin/foundryup-zksync

# Set environment variable for non-CUDA setup
ENV ZKSYNC_USE_CUDA_STUBS=true

# Clone zksync-era repository
WORKDIR /zksync
RUN git clone https://github.com/matter-labs/zksync-era.git . && \
    git submodule update --init --recursive

# Add shell initialization for nvm and rust
RUN echo '. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '. ~/.cargo/env' >> ~/.bashrc

# Add a script to handle configurable zkstack ecosystem creation
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default environment variables for zkstack ecosystem creation
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

# Entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
