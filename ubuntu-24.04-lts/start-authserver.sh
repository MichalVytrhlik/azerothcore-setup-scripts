#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

if [ ! -f "$AC_BIN_DIR/authserver" ]; then
    echo "✗ AzerothCore not built yet!"
    exit 1
fi

echo "Starting authserver..."
screen -dmS authserver bash -lc "cd \"$AC_DIST_DIR\" && ./bin/authserver -c ./etc/authserver.conf"

sleep 1

echo "✓ Authserver started in screen session"
echo ""
echo "Attach to authserver: screen -r authserver"
echo "Detach: Ctrl+A then D"
echo "Stop: screen -S authserver -X quit"
