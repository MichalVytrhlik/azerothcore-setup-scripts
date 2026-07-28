#!/bin/bash

export AC_CODE_DIR="${AC_CODE_DIR:-$HOME/azerothcore}"
export AC_DIST_DIR="${AC_DIST_DIR:-$AC_CODE_DIR/env/dist}"
export AC_BIN_DIR="${AC_BIN_DIR:-$AC_DIST_DIR/bin}"
export AC_ETC_DIR="${AC_ETC_DIR:-$AC_DIST_DIR/etc}"
export AC_DATA_DIR="${AC_DATA_DIR:-$AC_DIST_DIR/data}"
export AC_SQL_BASE_DIR="${AC_SQL_BASE_DIR:-$AC_CODE_DIR/data/sql/base}"
export AC_REPO_URL="${AC_REPO_URL:-https://github.com/MichalVytrhlik/azerothcore-wotlk.git}"
export AC_REPO_BRANCH="${AC_REPO_BRANCH:-master}"
export AC_MAPS_DOWNLOAD_URL="${AC_MAPS_DOWNLOAD_URL:-https://github.com/wowgaming/client-data/releases/download/v19/Data.zip}"

export AC_MYSQL_USER="${AC_MYSQL_USER:-acore}"
export AC_MYSQL_PASS="${AC_MYSQL_PASS:-acore}"
export AC_MYSQL_HOST="${AC_MYSQL_HOST:-127.0.0.1}"
export AC_REALM_ADDRESS="${AC_REALM_ADDRESS:-}"
export AC_REALM_LOCAL_ADDRESS="${AC_REALM_LOCAL_ADDRESS:-}"
export AC_REALM_SUBNET="${AC_REALM_SUBNET:-255.255.255.0}"
export AC_INIT_DB_FROM_SCRATCH="${AC_INIT_DB_FROM_SCRATCH:-}"

export AC_CMAKE_C_COMPILER="${AC_CMAKE_C_COMPILER:-/usr/bin/clang}"
export AC_CMAKE_CXX_COMPILER="${AC_CMAKE_CXX_COMPILER:-/usr/bin/clang++}"
export AC_TOOLS_BUILD="${AC_TOOLS_BUILD:-all}"
export AC_SCRIPTS_BUILD="${AC_SCRIPTS_BUILD:-static}"
export AC_MODULES_BUILD="${AC_MODULES_BUILD:-static}"
export AC_BUILD_CORES="${AC_BUILD_CORES:-2}"

export AC_INSTALL_HELPERS_DIR="${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}"
