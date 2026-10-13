#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

cat <<EOF

╔════════════════════════════════════════════════════════════╗
║           AzerothCore on Ubuntu 24.04 LTS                   ║
╚════════════════════════════════════════════════════════════╝

Installation Complete! All 5 steps done.

Available scripts in $AC_INSTALL_HELPERS_DIR/:
  1. Extract/Download Maps: $AC_INSTALL_HELPERS_DIR/extract-maps.sh
  2. Start Servers: $AC_INSTALL_HELPERS_DIR/start-servers.sh
  3. Configure Realm LAN Address (after database initialization): $AC_INSTALL_HELPERS_DIR/configure-realm.sh
  4. Check Status: $AC_INSTALL_HELPERS_DIR/status.sh

Next: $AC_INSTALL_HELPERS_DIR/extract-maps.sh
Run configure-realm.sh only after authserver/worldserver have completed their automatic database import.

EOF
