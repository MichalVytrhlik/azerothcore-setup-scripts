# AzerothCore setup scripts for Raspberry Pi 4B

These scripts automate installing and running **AzerothCore (WotLK)** on **Ubuntu 24.04 LTS** on a Raspberry Pi 4B.

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
| `init-db.sh` | Sets up MySQL user/databases, imports base SQL, configures `realmlist` |
| `configure-azerothcore.sh` | Writes DB/data paths into configs, installs helper scripts to `$AC_INSTALL_HELPERS_DIR` (default: `$HOME/scripts`), updates `.bashrc` welcome block |
| `extract-maps.sh` | Interactive map setup: extract from local WoW client or download pre-extracted data |
| `start-servers.sh` | Starts `authserver` and `worldserver` in detached `screen` sessions |
| `status.sh` | Shows build/maps/DB/server status |
| `acore-env.sh` | Shared environment defaults (paths, DB creds, build settings, URLs) |
| `acore-welcome.sh` | Welcome banner and post-install hints |

---

## Install on target machine

On the Raspberry Pi target machine:

```bash
git clone https://github.com/MichalVytrhlik/azerothcore-setup-scripts.git
cd azerothcore-setup-scripts/rasberry-pi-4b
chmod +x *.sh
./setup-azerothcore.sh
```

After setup finishes (by default helper scripts are installed to `$HOME/scripts`):

```bash
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/extract-maps.sh"
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/start-servers.sh"
"${AC_INSTALL_HELPERS_DIR:-$HOME/scripts}/status.sh"
```

---

## Configuration

All scripts source `acore-env.sh`. You can override defaults with environment variables before running setup, for example:

```bash
export AC_MYSQL_USER=acore
export AC_MYSQL_PASS=strong-password
export AC_REPO_BRANCH=master
export AC_BUILD_CORES=4
export AC_INIT_DB_FROM_SCRATCH=true
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
- `AC_INSTALL_HELPERS_DIR` (default: `$HOME/scripts`)

---

## Notes

- `build-azerothcore.sh` can take a long time on Pi 4B (commonly 1-2 hours).
- `init-db.sh` is interactive when existing `acore_*` databases are detected (unless `AC_INIT_DB_FROM_SCRATCH` is set).
- `start-servers.sh` requires map data in `$AC_DIST_DIR/data/maps`.
