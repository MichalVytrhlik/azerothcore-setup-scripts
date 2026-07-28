#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "AzerothCore Status:"
echo "=================="
echo ""

if [ -d "$AC_BIN_DIR" ]; then
    echo "✓ Build Status: COMPLETE"
    echo "  Binaries: $AC_BIN_DIR/"
else
    echo "✗ Build Status: NOT BUILT"
    exit 1
fi

if [ -d "$AC_DATA_DIR/maps" ]; then
    echo "✓ Maps Status: READY"
    echo "  Location: $AC_DATA_DIR/"
else
    echo "✗ Maps Status: NOT FOUND"
fi

echo ""
echo "Database Status:"
mysql -h "$AC_MYSQL_HOST" -u "$AC_MYSQL_USER" -p"$AC_MYSQL_PASS" -e "SHOW DATABASES;" 2>/dev/null | grep acore || echo "✗ Database connection failed"

echo ""
echo "Running Servers:"
screen -ls | grep -E "authserver|worldserver" || echo "No servers running"

echo ""
echo "Repository Size:"
du -sh $AC_CODE_DIR
