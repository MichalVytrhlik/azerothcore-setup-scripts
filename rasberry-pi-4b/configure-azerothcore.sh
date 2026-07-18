#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "[5.1] Updating configuration files..."
echo "      Auth config: $AC_ETC_DIR/authserver.conf"
echo "      World config: $AC_ETC_DIR/worldserver.conf"
echo "      Data directory: $AC_DATA_DIR"

sed -i "s|^LoginDatabaseInfo = .*|LoginDatabaseInfo = \"$AC_MYSQL_HOST;3306;$AC_MYSQL_USER;$AC_MYSQL_PASS;acore_auth\"|" \
    "$AC_ETC_DIR/authserver.conf"
sed -i "s|^WorldDatabaseInfo = .*|WorldDatabaseInfo = \"$AC_MYSQL_HOST;3306;$AC_MYSQL_USER;$AC_MYSQL_PASS;acore_world\"|" \
    "$AC_ETC_DIR/worldserver.conf"
sed -i "s|^CharacterDatabaseInfo = .*|CharacterDatabaseInfo = \"$AC_MYSQL_HOST;3306;$AC_MYSQL_USER;$AC_MYSQL_PASS;acore_characters\"|" \
    "$AC_ETC_DIR/worldserver.conf"
sed -i "s|^LoginDatabaseInfo = .*|LoginDatabaseInfo = \"$AC_MYSQL_HOST;3306;$AC_MYSQL_USER;$AC_MYSQL_PASS;acore_auth\"|" \
    "$AC_ETC_DIR/worldserver.conf"
sed -i "s|^DataDir = .*|DataDir = \"$AC_DATA_DIR\"|" \
    "$AC_ETC_DIR/worldserver.conf"

echo "      ✓ Configuration updated"

echo "[5.2] Installing helper scripts..."
mkdir -p "$AC_INSTALL_HELPERS_DIR"
echo "      Helper install directory: $AC_INSTALL_HELPERS_DIR"

for helper_script in \
    acore-env.sh \
    install-deps.sh \
    sync-source.sh \
    build-azerothcore.sh \
    init-db.sh \
    configure-azerothcore.sh \
    extract-maps.sh \
    start-servers.sh \
    status.sh \
    acore-welcome.sh \
    setup-azerothcore.sh; do
    install -m 755 "$SCRIPT_DIR/$helper_script" "$AC_INSTALL_HELPERS_DIR/$helper_script"
done

echo "      ✓ Helper scripts installed to $AC_INSTALL_HELPERS_DIR"

BASHRC_MARKER_START="# >>> acore-welcome >>>"
BASHRC_MARKER_END="# <<< acore-welcome <<<"

if grep -q "$BASHRC_MARKER_START" "$HOME/.bashrc"; then
    awk -v start="$BASHRC_MARKER_START" -v end="$BASHRC_MARKER_END" '
        $0 == start { in_block = 1; next }
        $0 == end { in_block = 0; next }
        !in_block { print }
    ' "$HOME/.bashrc" > "$HOME/.bashrc.tmp"
    mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
fi

cat >> "$HOME/.bashrc" <<EOF

$BASHRC_MARKER_START
if [ -f "$AC_INSTALL_HELPERS_DIR/acore-welcome.sh" ]; then
    source "$AC_INSTALL_HELPERS_DIR/acore-welcome.sh"
fi
$BASHRC_MARKER_END
EOF
