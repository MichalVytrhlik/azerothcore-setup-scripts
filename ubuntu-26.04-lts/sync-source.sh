#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "      Repository: $AC_REPO_URL"
echo "      Branch: $AC_REPO_BRANCH"
echo "      Target directory: $AC_CODE_DIR"

if [ ! -d "$AC_CODE_DIR/.git" ]; then
    echo "[2.1] Cloning AzerothCore repository..."
    git clone "$AC_REPO_URL" \
        --branch "$AC_REPO_BRANCH" --single-branch --depth 1 "$AC_CODE_DIR"
    echo "      ✓ Cloned"
else
    echo "[2.1] Repository already exists"
    echo "      Updating..."
    git -C "$AC_CODE_DIR" pull --ff-only
    echo "      ✓ Updated"
fi
