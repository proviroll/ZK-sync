#!/bin/bash
set -eu

echo "[4/4] : ecosystem initialization"

# Ecosystem init command
ZKSTACK_INIT_COMMAND="zkstack ecosystem init \
    --deploy-erc20=${DEPLOY_ERC20} \
    --deploy-ecosystem=${DEPLOY_ECOSYSTEM} \
    --l1-rpc-url=${L1_RPC_URL} \
    --observability=${OBSERVABILITY} \
    --deploy-paymaster=${DEPLOY_PAYMASTER} \
    --server-db-url=${SERVER_DB_URL} \
    --server-db-name=${SERVER_DB_NAME}"

cd ${ECOSYSTEM_NAME}
exec $ZKSTACK_INT_COMMAND
