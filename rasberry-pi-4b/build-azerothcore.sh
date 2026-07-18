#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "Starting AzerothCore build..."
echo "This may take 1-2 hours on Raspberry Pi 4B"
echo "Build directory: $AC_CODE_DIR/build"
echo "Install directory: $AC_DIST_DIR"
echo "Toolchain: C=$AC_CMAKE_C_COMPILER CXX=$AC_CMAKE_CXX_COMPILER Jobs=$AC_BUILD_CORES"
echo ""

cd "$AC_CODE_DIR"

echo "[3.1] Creating build directory..."
mkdir -p build
cd build
echo "      ✓ Created"

echo "[3.2] Running CMake..."
cmake ../ \
    -DCMAKE_INSTALL_PREFIX="$AC_DIST_DIR/" \
    -DCMAKE_C_COMPILER="$AC_CMAKE_C_COMPILER" \
    -DCMAKE_CXX_COMPILER="$AC_CMAKE_CXX_COMPILER" \
    -DWITH_WARNINGS=1 \
    -DTOOLS_BUILD="$AC_TOOLS_BUILD" \
    -DSCRIPTS="$AC_SCRIPTS_BUILD" \
    -DMODULES="$AC_MODULES_BUILD"
echo "      ✓ CMake configured"

echo "[3.3] Compiling (using $AC_BUILD_CORES cores)..."
make -j"$AC_BUILD_CORES"
echo "      ✓ Compiled"

echo "[3.4] Installing..."
make install
echo "      ✓ Installed"

echo "[3.5] Creating configuration files..."
cp "$AC_ETC_DIR/authserver.conf.dist" "$AC_ETC_DIR/authserver.conf"
cp "$AC_ETC_DIR/worldserver.conf.dist" "$AC_ETC_DIR/worldserver.conf"
echo "      ✓ Created"
