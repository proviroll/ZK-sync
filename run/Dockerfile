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
    postgresql-client \
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

# Install Cargo tools
ENV PATH="/root/.cargo/bin:${PATH}"
RUN . ~/.cargo/env && \
    cargo install cargo-nextest && \
    cargo install sqlx-cli --version 0.8.1

    # Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
/root/.foundry/bin/foundryup
ENV PATH="/root/.foundry/bin:${PATH}"

# Install Foundry ZKsync
RUN curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash && \
    ~/.foundry/bin/foundryup-zksync

# Set environment variable for non-CUDA setup
ENV ZKSYNC_USE_CUDA_STUBS=true

WORKDIR /zksync
RUN git clone https://github.com/matter-labs/zksync-era.git . && \
    git submodule update --init --recursive

# Install the zkstack tool from the repository
RUN cargo install --git https://github.com/matter-labs/zksync-era/ --locked zkstack --force

# Add shell initialization for nvm and rust
RUN echo '. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '. ~/.cargo/env' >> ~/.bashrc

# Copy and set permissions for scripts
COPY *.sh /script/
RUN chmod +x /script/*.sh

ENTRYPOINT ["/bin/bash", "-c", "\
    chmod +x /script/*.sh && \
    source /script/1_init_environment.sh && \
    /script/2_run_ecosystem.sh"]
