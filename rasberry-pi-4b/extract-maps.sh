#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/acore-env.sh"

echo "=========================================="
echo "AzerothCore Map Extraction"
echo "=========================================="
echo ""

echo "Map files are required to run WorldServer"
echo ""
echo "Options:"
echo "  1. Extract from WoW 3.3.5a client"
echo "  2. Download pre-extracted maps (~2-3GB)"
echo ""
read -p "Choose option (1 or 2): " option

if [ "$option" = "1" ]; then
    echo ""
    echo "Running map extractor..."
    echo "Place your WoW 3.3.5a client in a directory"
    read -p "Enter WoW client path: " WOW_PATH
    
    if [ ! -d "$WOW_PATH" ]; then
        echo "✗ Path not found: $WOW_PATH"
        exit 1
    fi
    
    mkdir -p "$AC_DATA_DIR"
    cd "$AC_BIN_DIR"
    
    # Run extractor
    ./mapextractor "$WOW_PATH"
    
    # Move extracted files
    mv maps "$AC_DATA_DIR/" 2>/dev/null || true
    mv vmaps "$AC_DATA_DIR/" 2>/dev/null || true
    mv mmaps "$AC_DATA_DIR/" 2>/dev/null || true
    
elif [ "$option" = "2" ]; then
    echo ""
    echo "Downloading pre-extracted maps (2-3GB)..."
    echo "Source: $AC_MAPS_DOWNLOAD_URL"
    mkdir -p "$AC_DATA_DIR"
    cd "$AC_DATA_DIR"

    TMP_DATA_ZIP="/tmp/Data.zip"
    if [ -f "$TMP_DATA_ZIP" ]; then
        echo "$TMP_DATA_ZIP already exists, skipping download"
    else
        wget -O "$TMP_DATA_ZIP" "$AC_MAPS_DOWNLOAD_URL"
    fi
    unzip -o "$TMP_DATA_ZIP"
    
else
    echo "Invalid option"
    exit 1
fi

echo ""
echo "✓ Maps ready"
echo "  Location: $AC_DATA_DIR"
