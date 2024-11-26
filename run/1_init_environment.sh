#!/bin/bash
set -eu

# check environment variables
reqenv() {
    if [ -z "${!1:-}" ]; then
        echo "Error: environment variable '$1' is not set. check .env file!"
        exit 1
    fi
}

echo "[1/2] : init environment variables"

reqenv "ECOSYSTEM_NAME"
