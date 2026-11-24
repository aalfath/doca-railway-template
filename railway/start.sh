#!/bin/sh
# Railway start script for Doca. Any failure exits non-zero so Railway restarts the service.
set -eu

# Railway volumes mount as root: hand /data to the image's `node` user, then drop root.
if [ "$(id -u)" = "0" ]; then
  mkdir -p /data/storage /data/plugins
  [ "$(stat -c %u /data)" = "1000" ] || chown -R node:node /data
  [ "$(stat -c %u /data/storage)" = "1000" ] || chown -R node:node /data/storage
  exec setpriv --reuid=node --regid=node --init-groups "$0" "$@"
fi
cd /app

# Public origin: Doca rejects requests for any other host.
if [ -z "${DOCA_ORIGIN:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  DOCA_ORIGIN="https://${RAILWAY_PUBLIC_DOMAIN}"
fi
: "${DOCA_ORIGIN:?Set DOCA_ORIGIN to the public https:// address, or add a Railway domain}"
: "${DOCA_CREDENTIAL_MASTER_KEY:?DOCA_CREDENTIAL_MASTER_KEY (64 hex characters) is required}"
export DOCA_ORIGIN DOCA_CREDENTIAL_MASTER_KEY

# The upstream image bakes these in as ENV, so set them explicitly.
export NODE_ENV=production
export DOCA_HOST="${DOCA_HOST:-0.0.0.0}"
export DOCA_PORT="${PORT:-39120}"
export DOCA_DATABASE=sqlite
export DOCA_DATA_DIR=/data
export DOCA_SQLITE_PATH=/data/doca.db
export DOCA_AI_SQLITE_PATH=/data/ai.db
export DOCA_PLUGINS_DIR=/data/plugins
export DOCA_FILE_STORE_ID="${DOCA_FILE_STORE_ID:-local}"
local_store='{"version":1,"stores":{"local":{"provider":"local","root":"/data/storage"}}}'
export DOCA_FILE_STORES_JSON="${DOCA_FILE_STORES_JSON:-$local_store}"
# Railway's edge proxy connects from its private range; trust it so rate limits see real client IPs.
export DOCA_TRUST_PROXY="${DOCA_TRUST_PROXY:-100.64.0.0/10,fd00::/8}"
# Heavy renderers (LibreOffice, WeasyPrint) go through a RAM guard; see heavy-guard.sh.
export DOCA_OFFICE_RENDERER=/usr/local/bin/doca-soffice
export DOCA_PDF_PYTHON=/usr/local/bin/doca-pdf-python
unset DOCA_PDF_CHROMIUM 2>/dev/null || true

# Size the V8 heap to the service's memory limit (Railway shows the host's RAM otherwise).
limit=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)
if [ "$limit" != "max" ]; then
  mb=$((limit / 1048576))
  heap=$((mb * 70 / 100))
  [ "$heap" -gt 2048 ] && heap=2048
  [ "$heap" -lt 192 ] && heap=192
  export NODE_OPTIONS="${NODE_OPTIONS:-} --max-old-space-size=${heap}"
fi
export UV_THREADPOOL_SIZE="${UV_THREADPOOL_SIZE:-4}"

# First boot: create the administrator from the template's generated variables.
node --import tsx apps/server/src/bootstrap/railway-init.ts

exec node --import tsx apps/server/src/main.ts
