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

get_mysql_create_sql_file_content() {
    local mysql_create_sql_file="$AC_CODE_DIR/data/sql/create/create_mysql.sql"
    if [ ! -f "$mysql_create_sql_file" ]; then
        echo "      ⚠ MySQL creation script not found: $mysql_create_sql_file; check the AzerothCore source directory." >&2
        printf ''
    else
        sed -i \
            -e "s|'acore'@'localhost'|'$AC_MYSQL_USER'@'$AC_MYSQL_HOST'|g" \
            -e "s|IDENTIFIED BY 'acore'|IDENTIFIED BY '$AC_MYSQL_PASS'|g" \
            "$mysql_create_sql_file" && cat "$mysql_create_sql_file"
    fi
}

if [ "$INIT_DB_FROM_SCRATCH" = "true" ]; then
    echo "[4.3] Resetting database user and databases..."
    MYSQL_CREATE_SQL_FILE_CONTENT=$(get_mysql_create_sql_file_content)
    MYSQL_RESET_SQL=$(cat <<EOF
DROP USER IF EXISTS '$AC_MYSQL_USER'@'$AC_MYSQL_HOST';
DROP DATABASE IF EXISTS acore_world;
DROP DATABASE IF EXISTS acore_characters;
DROP DATABASE IF EXISTS acore_auth;
EOF
)
    sudo mysql -u root <<EOF
$MYSQL_RESET_SQL
$MYSQL_CREATE_SQL_FILE_CONTENT
EOF
elif [ "$EXISTING_ACORE_DB_COUNT" -eq 0 ]; then
    echo "[4.3] Ensuring database user and databases exist..."
    MYSQL_CREATE_SQL_FILE_CONTENT=$(get_mysql_create_sql_file_content)
    sudo mysql -u root <<EOF
$MYSQL_CREATE_SQL_FILE_CONTENT
EOF
    echo "      ✓ User ready: $AC_MYSQL_USER"
else
    echo "[4.3] Existing AzerothCore databases found; preserving them."
fi

# Test connection
echo "[4.4] Testing database connection..."
mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" -e "SELECT 1;" > /dev/null
echo "      ✓ Connection successful"
echo ""

if [ "$INIT_DB_FROM_SCRATCH" = "true" ]; then
    echo "Database schemas and data will be populated by authserver/worldserver on startup."
else
    echo "Existing database preserved; authserver/worldserver will apply pending updates on startup."
fi
