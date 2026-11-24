[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/doca?utm_medium=integration&utm_source=button&utm_campaign=doca)

# Doca on Railway

One-click Railway template for [Doca](https://github.com/workhold/doca) (MIT): self-hosted documents, sheets, slides, canvases, files and a knowledge base with real-time co-editing and an optional AI assistant.

**Version:** Doca 0.2.42, official image `docker.io/smartdoca/doca:0.2.42@sha256:fa06a4aefadbaa05186b6e4497dbdf06f55ad192075cd2935e32528f9903d483`.

## What it deploys

| Service | What it does |
|---|---|
| Doca | The Doca server (web UI, API, real-time editing, MCP). SQLite database, AI memory, plugins and uploaded files live on a Railway volume at `/data`. Health check: `/health`. |

## Variables

| Variable | Default | Notes |
|---|---|---|
| `PORT` | `8080` | Port Doca listens on. |
| `DOCA_ORIGIN` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public address. Doca rejects requests for any other host, so change it if you add a custom domain. |
| `DOCA_CREDENTIAL_MASTER_KEY` | generated, 64 hex | Encrypts stored credentials. Never change it after the first deploy. |
| `DOCA_ADMIN_LOGIN` | `admin` | Administrator created on the first boot. |
| `DOCA_ADMIN_PASSWORD` | generated, 24 characters | Administrator password, read on the first boot only. Change it in Doca afterwards. |

No prompts: every value is generated or derived.

## After deploying

1. Open the public URL and sign in as `admin` with the password from the `DOCA_ADMIN_PASSWORD` variable.
2. Change the password under your profile, then add users or open registration in the administration area.
3. Optional: configure the AI assistant with your own OpenAI-compatible provider key in the administration area.

## What the wrapper changes

- Railway's health check sends its own `Host` header and Doca answers `421` to any host but `DOCA_ORIGIN`. A build-time patch lets only the read-only `/health`, `/live` and `/ready` probes skip that check.
- Doca has no default account; `railway/railway-init.ts` creates the administrator from the variables above before the server starts (only when no administrator exists) and sets the site's default language to English and time zone to UTC.
- The start script fixes the volume's ownership, sizes the Node heap to the service's memory limit, trusts Railway's proxy range for client IPs and exits non-zero on any failure so Railway restarts it.

## Memory

The idle server uses about 330 MB, so it fits a 0.5 GB service. Office-to-PDF (LibreOffice) and PDF export (WeasyPrint) start a large extra process: below 900 MB of service memory (`DOCA_HEAVY_MIN_MB`) they fail with a clear error instead of getting the service OOM-killed. Use 1 GB or more for them.

## Updates

This template builds from this repository's `main` branch. When the pinned Doca version is bumped here, Railway shows deployers an "update available" notice; read [CHANGELOG.md](CHANGELOG.md) before applying it. Data on the volume is kept.

The overview shown on Railway is in [OVERVIEW.md](OVERVIEW.md).
