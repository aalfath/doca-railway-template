#!/bin/sh
# Office-to-PDF (LibreOffice) and PDF export (WeasyPrint) each start a large extra process.
# On a small Railway plan that would get the whole service OOM-killed, so below
# DOCA_HEAVY_MIN_MB of RAM these features fail with a clear error and Doca stays up.
min="${DOCA_HEAVY_MIN_MB:-900}"
limit=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)
if [ "$limit" != "max" ] && [ "$((limit / 1048576))" -lt "$min" ]; then
  echo "Doca: this feature needs at least ${min} MB of RAM; this service has $((limit / 1048576)) MB. Raise the service's memory limit on Railway (or set DOCA_HEAVY_MIN_MB) and redeploy." >&2
  exit 1
fi
case "$(basename "$0")" in
  doca-soffice) exec /usr/bin/soffice "$@" ;;
  doca-pdf-python) exec /opt/doca-pdf/bin/python "$@" ;;
esac
echo "doca-heavy-guard: unknown tool $(basename "$0")" >&2
exit 1
