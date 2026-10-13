# AzerothCore setup scripts for Ubuntu 24.04 LTS

These scripts automate installing and running **AzerothCore (WotLK)** on **Ubuntu 24.04 LTS**.

## What these scripts do

They implement a 5-step flow:

1. Install required system packages (`install-deps.sh`)
2. Clone or update AzerothCore source (`sync-source.sh`)
3. Build and install AzerothCore (`build-azerothcore.sh`)
4. Create/configure MySQL databases (`init-db.sh`)
5. Configure server files and install helper scripts (`configure-azerothcore.sh`)

Then you can:

- Prepare client data (`extract-maps.sh`)
- Start auth/world servers in `screen` sessions (`start-servers.sh`)
- Check current status (`status.sh`)

---

## Script overview

| Script | Purpose |
|---|---|
| `setup-azerothcore.sh` | Runs full 5-step setup in order |
| `install-deps.sh` | Installs apt packages needed to build/run AzerothCore |
| `sync-source.sh` | Clones repository on first run, pulls updates on later runs |
| `build-azerothcore.sh` | CMake configure + compile + install + create `.conf` files |
| `init-db.sh` | Sets up MySQL user/databases and optionally imports base SQL |
| `configure-realm.sh` | Configures the `realmlist` address and subnet for LAN clients |
| `configure-azerothcore.sh` | Writes DB/data paths into configs, installs helper scripts to `$AC_INSTALL_HELPERS_DIR` (default: `$HOME/scripts`), updates `.bashrc` welcome block |
| `extract-maps.sh` | Interactive map setup: extract from local WoW client or download pre-extracted data |
| `start-servers.sh` | Starts `authserver` and `worldserver` in detached `screen` sessions |
| `status.sh` | Shows build/maps/DB/server status |
| `acore-env.sh` | Shared environment defaults (paths, DB creds, build settings, URLs) |
| `acore-welcome.sh` | Welcome banner and post-install hints |

---

## Install on target machine

On the target Ubuntu 24.04 LTS machine:

```bash
git clone https://github.com/MichalVytrhlik/azerothcore-setup-scripts.git
cd azerothcore-setup-scripts/ubuntu-24.04-lts
chmod +x *.sh
./setup-azerothcore.sh
```

After setup finishes (by default helper scripts are installed to `$HOME/scripts`):

```bash
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/extract-maps.sh"
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/start-servers.sh"
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/status.sh"
```

After the auth database has been initialized, configure the realm's LAN address:

```bash
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/configure-realm.sh"
```

Run `configure-realm.sh` only after the database exists and has been populated: either `init-db.sh` imported the base SQL (`AC_INIT_DB_IMPORT_BASE_SQL=true`), or `authserver`/`worldserver` have been started and their automatic database import has completed.

---

## Configuration

All scripts source `acore-env.sh`. You can override defaults with environment variables before running setup, for example:

```bash
export AC_MYSQL_USER=acore
export AC_MYSQL_PASS=strong-password
export AC_REPO_BRANCH=master
export AC_BUILD_CORES=4
export AC_INIT_DB_FROM_SCRATCH=true
export AC_INIT_DB_IMPORT_BASE_SQL=false
./setup-azerothcore.sh
```

Important variables:

- `AC_CODE_DIR` (default: `$HOME/azerothcore`)
- `AC_DIST_DIR` (default: `$AC_CODE_DIR/env/dist`)
- `AC_MYSQL_USER`, `AC_MYSQL_PASS`, `AC_MYSQL_HOST`
- `AC_REPO_URL`, `AC_REPO_BRANCH`
- `AC_REALM_ADDRESS`, `AC_REALM_LOCAL_ADDRESS`, `AC_REALM_SUBNET`
- `AC_MAPS_DOWNLOAD_URL`
- `AC_BUILD_CORES`
- `AC_INIT_DB_IMPORT_BASE_SQL` (default: `false`; let authserver/worldserver populate and update the databases on startup; set to `true` to import base SQL during initialization)
- `AC_INSTALL_HELPERS_DIR` (default: `$HOME/scripts`)

---

## Notes

- `build-azerothcore.sh` can take a long time on slower hardware.
- `init-db.sh` is interactive when existing `acore_*` databases are detected (unless `AC_INIT_DB_FROM_SCRATCH` is set).
- During scratch initialization, `init-db.sh` asks whether to import base SQL now. The default is `false`; if unchanged, authserver and worldserver populate and update the databases automatically when started.
- Run `configure-realm.sh` after the servers have initialized the auth database to configure the realm's LAN address; set `AC_REALM_ADDRESS`, `AC_REALM_LOCAL_ADDRESS`, and `AC_REALM_SUBNET` in `acore-env.sh` or the environment to override its defaults.
- `start-servers.sh` requires map data in `$AC_DIST_DIR/data/maps`.
