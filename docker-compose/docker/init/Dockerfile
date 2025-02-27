FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    pkg-config \
    cmake \
    clang \
    lldb \
    lld \
    libssl-dev \
    libpq-dev \
    software-properties-common \
    wget \
    bc \
    postgresql-client \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js and yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && yarn set version 1.22.19

# Install Cargo tools
RUN cargo install cargo-nextest \
    && cargo install sqlx-cli --version 0.8.1

# Install foundry and foundry-zksync
RUN curl -L https://foundry.paradigm.xyz | bash \
    && ~/.foundry/bin/foundryup \
    && curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash \
    && ~/.foundry/bin/foundryup-zksync

# Add foundry to PATH
ENV PATH="/root/.foundry/bin:${PATH}"

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

# Install zkstack CLI
RUN cargo install --git https://github.com/matter-labs/zksync-era/ --locked zkstack --force

# Set environment variable for non-CUDA setup
ENV ZKSYNC_USE_CUDA_STUBS=true

# Create necessary directories
RUN mkdir -p /script /app /zksync

WORKDIR /app
ENTRYPOINT ["/script/entrypoint.sh"]
