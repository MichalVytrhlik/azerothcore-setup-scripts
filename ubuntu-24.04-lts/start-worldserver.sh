#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

if [ ! -f "$AC_BIN_DIR/worldserver" ]; then
    echo "✗ AzerothCore not built yet!"
    exit 1
fi

if [ ! -d "$AC_DATA_DIR/maps" ]; then
    echo "✗ Map files not found!"
    echo "  Run: $SCRIPT_DIR/extract-maps.sh"
    exit 1
fi

echo "Starting worldserver..."
screen -dmS worldserver bash -lc "cd \"$AC_DIST_DIR\" && ./bin/worldserver -c ./etc/worldserver.conf"

sleep 1

echo "✓ Worldserver started in screen session"
echo ""
echo "Attach to worldserver: screen -r worldserver"
echo "Detach: Ctrl+A then D"
echo "Stop: screen -S worldserver -X quit"
