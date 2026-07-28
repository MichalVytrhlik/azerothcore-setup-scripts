#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "[1.1] Updating system..."
sudo apt update && sudo apt upgrade -y
echo "      ✓ Updated"

echo "[1.2] Installing dependencies..."
sudo apt install -y \
    git cmake make gcc g++ clang \
    libmysqlclient-dev libssl-dev libbz2-dev \
    libreadline-dev libncurses-dev libboost-all-dev \
    mysql-server mysql-client \
    p7zip curl unzip wget sudo screen
echo "      ✓ Installed"

echo "[1.3] Disabling cloud-init..."
sudo touch /etc/cloud/cloud-init.disabled
echo "      ✓ Disabled"
