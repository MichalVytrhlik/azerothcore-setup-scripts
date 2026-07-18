#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

if [ ! -f "$AC_BIN_DIR/authserver" ]; then
    echo "✗ AzerothCore not built yet!"
    exit 1
fi

if [ ! -d "$AC_DATA_DIR/maps" ]; then
    echo "✗ Map files not found!"
    echo "  Run: $AC_INSTALL_HELPERS_DIR/extract-maps.sh"
    exit 1
fi

echo "Starting AzerothCore servers..."
echo ""

# Start in screen sessions for easy management
echo "[1/2] Starting authserver..."
screen -dmS authserver bash -lc "cd \"$AC_DIST_DIR\" && ./bin/authserver -c ./etc/authserver.conf"

sleep 2

echo "[2/2] Starting worldserver..."
screen -dmS worldserver bash -lc "cd \"$AC_DIST_DIR\" && ./bin/worldserver -c ./etc/worldserver.conf"

echo ""
echo "✓ Servers started in screen sessions"
echo ""
echo "Attach to authserver: screen -r authserver"
echo "Attach to worldserver: screen -r worldserver"
echo "Detach: Ctrl+A then D"
echo ""
echo "Stop servers:"
echo "  screen -S authserver -X quit"
echo "  screen -S worldserver -X quit"
