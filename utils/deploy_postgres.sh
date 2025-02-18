#!/bin/bash

# Variables
CONTAINER_NAME="postgres"
POSTGRES_VERSION="latest"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="<pw>"
POSTGRES_DB="zksync"
POSTGRES_PORT="5432"
DATA_VOLUME="postgres_data"

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing..."
    sudo apt update && sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Pull the PostgreSQL image
echo "Pulling PostgreSQL Docker image..."
docker pull postgres:$POSTGRES_VERSION

# Create a persistent volume for PostgreSQL data
docker volume create $DATA_VOLUME
# Create postgres.conf with the correct syntax
echo "listen_addresses = '*'
max_connections = 100
shared_buffers = 128MB
" > postgres.conf

# Create pg_hba.conf
echo "
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32           md5
host    all             all             ::1/128                md5
host    all             all             0.0.0.0/0              md5
" > pg_hba.conf

# Run postgres with both configs
docker run -d \
    --network=host --name postgres \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -e POSTGRES_USER=postgres \
    -p 5432:5432 \
    -v $(pwd)/postgres.conf:/etc/postgresql/postgresql.conf \
    -v $(pwd)/pg_hba.conf:/etc/postgresql/pg_hba.conf \
    postgres \
    -c "config_file=/etc/postgresql/postgresql.conf"

echo "PostgreSQL container is up and running!"
echo "Access it using: docker exec -it $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB"