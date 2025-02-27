#!/bin/bash
set -e

echo "Stopping all running containers..."
docker-compose down

echo "Removing ZKSync volumes..."
docker volume rm zksync-data zksync-postgres-data || true

echo "Removing any dangling containers..."
docker container prune -f

echo "Removing any dangling volumes..."
docker volume prune -f

# echo "Removing ZKSync images..."
# docker rmi $(docker images | grep 'zksync' | awk '{print $3}') || true

echo "Cleanup complete!"