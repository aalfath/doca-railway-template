# Deploy and Host Doca on Railway

Doca is an open-source (MIT) document management system and knowledge base for individuals and small teams. It combines rich-text documents with real-time co-editing, Markdown, spreadsheets, slides and infinite canvases, a file manager, knowledge libraries, an MCP endpoint and an optional AI assistant that works with your own model provider.

## About Hosting Doca

Doca runs as one Node.js server that keeps its data in SQLite and stores uploaded files on local disk. This template builds the official `smartdoca/doca` image, pinned by version and digest, from a public GitHub repository and puts all state (`doca.db`, AI memory, plugins and files) on a Railway volume at `/data`. The public HTTPS address, the 64-character credential master key and the administrator password are generated on the first deploy, and the administrator account is created before the server starts, so there is no open setup screen. Railway's health check uses `/health`. Updates arrive as Railway update notices when the repository's pinned version is bumped.

## Common Use Cases

* A private team wiki and knowledge base with shared libraries and document history
* Real-time co-editing of documents, sheets, slides and whiteboard canvases
* A self-hosted file and document store you can connect to AI tools over MCP

## Dependencies for Doca Hosting

* One Railway service built from `aalfath/doca-railway-template` (official `smartdoca/doca` image)
* One Railway volume mounted at `/data` for SQLite, AI memory, plugins and uploaded files

### Deployment Dependencies

* Doca source and releases: https://github.com/workhold/doca/releases
* Doca documentation: https://workhold.github.io/doca/
* Template repository: https://github.com/aalfath/doca-railway-template

### Implementation Details

After the deploy finishes, open the service's public URL and sign in with the login `admin` and the password in the `DOCA_ADMIN_PASSWORD` variable (Service, Variables). Change it under your profile, then invite users or open registration in the administration area. The site starts in English with the UTC time zone; both can be changed by the administrator.

Keep `DOCA_CREDENTIAL_MASTER_KEY` unchanged for the life of the deployment: it encrypts stored provider keys and credentials. The AI assistant is optional and is configured in the administration area with your own OpenAI-compatible API key.

Doca's idle server uses about 330 MB of RAM, so it runs on a 0.5 GB service. Office-to-PDF conversion (LibreOffice) and PDF export (WeasyPrint) need more memory: below 900 MB they return a clear error instead of crashing the service. Give the service 1 GB or more to use them.

To update, apply the "update available" notice Railway shows when the template repository moves to a newer Doca release; read `CHANGELOG.md` in the repository first. Your data stays on the volume.

## Why Deploy Doca on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Doca on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
