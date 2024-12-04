# Use Ubuntu as base image
FROM ubuntu:22.04

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
    wget \
    bc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Configure git for HTTPS instead of SSH
RUN git config --global url."https://github.com/".insteadOf git@github.com: && \
    git config --global url."https://".insteadOf git://

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install NVM, Node.js, and Yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    npm install -g yarn && \
    yarn set version 1.22.19

# Install Cargo tools
ENV PATH="/root/.cargo/bin:${PATH}"
RUN . ~/.cargo/env && \
    cargo install cargo-nextest && \
    cargo install sqlx-cli --version 0.8.1

# Install yq (Go-based version)
RUN wget https://github.com/mikefarah/yq/releases/download/v4.35.1/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

SHELL ["/bin/bash", "-c"]

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /root/.foundry/bin/foundryup
ENV PATH="/root/.foundry/bin:${PATH}"

# Install Foundry ZKsync
RUN curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash && \
    ~/.foundry/bin/foundryup-zksync

# Set environment variable for non-CUDA setup
ENV ZKSYNC_USE_CUDA_STUBS=true

WORKDIR /app
RUN git clone https://github.com/matter-labs/zksync-era.git zksync && cd zksync && \
    git submodule update --init --recursive

# Install the zkstack tool from the repository
RUN cargo install --git https://github.com/matter-labs/zksync-era/ --locked zkstack --force

# Add shell initialization for nvm and rust
RUN echo '. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '. ~/.cargo/env' >> ~/.bashrc

# Copy and set permissions for the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy and set permissions for scripts
COPY *.sh /script/
RUN chmod +x /script/*.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
