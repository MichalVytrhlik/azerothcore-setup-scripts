#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "Configuring realm IP for LAN clients..."
REALM_ADDRESS="$AC_REALM_ADDRESS"
if [ -z "$REALM_ADDRESS" ]; then
    REALM_ADDRESS=$(hostname -I | awk '{print $1}')
fi
if [ -z "$REALM_ADDRESS" ]; then
    REALM_ADDRESS="127.0.0.1"
fi

REALM_LOCAL_ADDRESS="$AC_REALM_LOCAL_ADDRESS"
if [ -z "$REALM_LOCAL_ADDRESS" ]; then
    REALM_LOCAL_ADDRESS="$REALM_ADDRESS"
fi

echo "      Realm address to be used by clients: $REALM_ADDRESS"
echo "      Local realm address: $REALM_LOCAL_ADDRESS"
echo "      Local subnet mask: $AC_REALM_SUBNET"

if mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" -Nse "SELECT 1 FROM information_schema.tables WHERE table_schema = 'acore_auth' AND table_name = 'realmlist' LIMIT 1;" | grep -q 1; then
    mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" acore_auth <<EOF
INSERT INTO realmlist
    (id, name, address, localAddress, localSubnetMask, port, icon, flag, timezone, allowedSecurityLevel, population, gamebuild)
VALUES
    (1, 'AzerothCore', '$REALM_ADDRESS', '$REALM_LOCAL_ADDRESS', '$AC_REALM_SUBNET', 8085, 0, 0, 1, 0, 0, 12340)
ON DUPLICATE KEY UPDATE
    address = VALUES(address),
    localAddress = VALUES(localAddress),
    localSubnetMask = VALUES(localSubnetMask),
    port = VALUES(port),
    gamebuild = VALUES(gamebuild);
EOF
    echo "      ✓ Realmlist configured: address=$REALM_ADDRESS localAddress=$REALM_LOCAL_ADDRESS subnet=$AC_REALM_SUBNET"
else
    echo "      ⚠ realmlist table not found; start the servers to initialize the database, then run this script again"
fi
