#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

if [ ! -f "$AC_BIN_DIR/authserver" ]; then
    echo "✗ AzerothCore not built yet!"
    exit 1
fi

if [ ! -d "$AC_DATA_DIR/maps" ]; then
    echo "✗ Map files not found!"
    echo "  Run: $SCRIPT_DIR/extract-maps.sh"
    exit 1
fi

echo "Starting AzerothCore servers..."
echo ""

echo "[1/2] Running: start-authserver.sh"
bash "$SCRIPT_DIR/start-authserver.sh"

sleep 2

echo ""
echo "[2/2] Running: start-worldserver.sh"
bash "$SCRIPT_DIR/start-worldserver.sh"

echo ""
echo "✓ All servers started"
echo ""
echo "To stop servers:"
echo "  screen -S authserver -X quit"
echo "  screen -S worldserver -X quit"

