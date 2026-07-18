#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "Initializing AzerothCore database..."
echo ""

# Start MySQL
echo "[4.1] Starting MySQL service..."
sudo service mysql start
sleep 3
echo "      ✓ MySQL started"

EXISTING_ACORE_DB_COUNT=$(sudo mysql -Nse "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name IN ('acore_world', 'acore_characters', 'acore_auth');")

INIT_DB_FROM_SCRATCH="$AC_INIT_DB_FROM_SCRATCH"
if [ -z "$INIT_DB_FROM_SCRATCH" ]; then
    if [ "$EXISTING_ACORE_DB_COUNT" -eq 0 ]; then
        INIT_DB_FROM_SCRATCH="true"
        echo "[4.2] No AzerothCore databases found - initializing from scratch"
    elif [ -t 0 ]; then
        echo "[4.2] Database initialization mode..."
        read -r -p "Initialize AzerothCore MySQL database from scratch? This will remove existing acore_* data (y/N): " INIT_DB_RESPONSE
        case "$INIT_DB_RESPONSE" in
            [Yy]|[Yy][Ee][Ss])
                INIT_DB_FROM_SCRATCH="true"
                ;;
            *)
                INIT_DB_FROM_SCRATCH="false"
                ;;
        esac
    else
        INIT_DB_FROM_SCRATCH="false"
        echo "[4.2] Existing AzerothCore databases detected - preserving them in non-interactive mode"
        echo "      Set AC_INIT_DB_FROM_SCRATCH=true to force reset"
    fi
fi

case "$INIT_DB_FROM_SCRATCH" in
    [Tt][Rr][Uu][Ee]|1|[Yy]|[Yy][Ee][Ss])
        INIT_DB_FROM_SCRATCH="true"
        ;;
    *)
        INIT_DB_FROM_SCRATCH="false"
        ;;
esac

MYSQL_RESET_SQL=""
if [ "$INIT_DB_FROM_SCRATCH" = "true" ]; then
    echo "[4.3] Resetting database user and databases..."
    MYSQL_RESET_SQL=$(cat <<EOF
DROP USER IF EXISTS '$AC_MYSQL_USER'@'$AC_MYSQL_HOST';
DROP DATABASE IF EXISTS acore_world;
DROP DATABASE IF EXISTS acore_characters;
DROP DATABASE IF EXISTS acore_auth;
EOF
)
else
    echo "[4.3] Ensuring database user exists..."
fi

sudo mysql -u root <<EOF
$MYSQL_RESET_SQL
CREATE USER IF NOT EXISTS '$AC_MYSQL_USER'@'$AC_MYSQL_HOST' IDENTIFIED BY '$AC_MYSQL_PASS';
ALTER USER '$AC_MYSQL_USER'@'$AC_MYSQL_HOST' IDENTIFIED BY '$AC_MYSQL_PASS';
GRANT ALL PRIVILEGES ON *.* TO '$AC_MYSQL_USER'@'$AC_MYSQL_HOST';
FLUSH PRIVILEGES;
EOF

if [ "$INIT_DB_FROM_SCRATCH" = "true" ]; then
    echo "      ✓ Databases reset from scratch"
else
    echo "      ✓ User ready: $AC_MYSQL_USER"
fi

# Test connection
echo "[4.4] Testing database connection..."
mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" -e "SELECT 1;" > /dev/null
echo "      ✓ Connection successful"
echo ""

# Create databases
echo "[4.5] Creating databases..."
mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS acore_world;
CREATE DATABASE IF NOT EXISTS acore_characters;
CREATE DATABASE IF NOT EXISTS acore_auth;
EOF

echo "      ✓ Databases created"

if [ "$INIT_DB_FROM_SCRATCH" = "true" ]; then
    echo "[4.6] Importing database structure..."
    AUTH_SQL_FILES=("$AC_SQL_BASE_DIR"/db_auth/*.sql)
    CHAR_SQL_FILES=("$AC_SQL_BASE_DIR"/db_characters/*.sql)
    WORLD_SQL_FILES=("$AC_SQL_BASE_DIR"/db_world/*.sql)

    if [ "${AUTH_SQL_FILES[0]}" = "$AC_SQL_BASE_DIR/db_auth/*.sql" ] || \
       [ "${CHAR_SQL_FILES[0]}" = "$AC_SQL_BASE_DIR/db_characters/*.sql" ] || \
       [ "${WORLD_SQL_FILES[0]}" = "$AC_SQL_BASE_DIR/db_world/*.sql" ]; then
        echo "      ✗ Base SQL files not found under $AC_SQL_BASE_DIR"
        exit 1
    fi

    echo "      Importing auth database..."
    for SQL_FILE in "${AUTH_SQL_FILES[@]}"; do
        mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" acore_auth < "$SQL_FILE"
    done

    echo "      Importing character database..."
    for SQL_FILE in "${CHAR_SQL_FILES[@]}"; do
        mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" acore_characters < "$SQL_FILE"
    done

    echo "      Importing world database (this may take a while)..."
    for SQL_FILE in "${WORLD_SQL_FILES[@]}"; do
        mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" acore_world < "$SQL_FILE"
    done

    echo "      ✓ Database structure imported"
else
    echo "[4.6] Skipping full import (existing database preserved)"

    if ! mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" -Nse "SELECT 1 FROM information_schema.tables WHERE table_schema = 'acore_auth' AND table_name = 'account_banned' LIMIT 1;" | grep -q 1; then
        echo "      ✗ Existing acore_auth schema is incomplete (missing account_banned)"
        echo "      Re-run with AC_INIT_DB_FROM_SCRATCH=true to rebuild databases"
        exit 1
    fi
fi

echo ""
echo "[4.7] Configuring realm IP for LAN clients..."
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
    echo "      ⚠ realmlist table not found; skipping realm IP configuration"
fi
