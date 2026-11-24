# Doca on Railway: the official image, pinned by version and digest, plus a small wrapper.
FROM docker.io/smartdoca/doca:0.2.42@sha256:fa06a4aefadbaa05186b6e4497dbdf06f55ad192075cd2935e32528f9903d483

USER root
COPY railway/patch-health.mjs /tmp/patch-health.mjs
COPY railway/railway-init.ts /app/apps/server/src/bootstrap/railway-init.ts
COPY railway/start.sh /usr/local/bin/doca-railway-start
COPY railway/heavy-guard.sh /usr/local/bin/doca-heavy-guard
# Railway's health check sends its own Host header; Doca answers 421 to any Host other than
# DOCA_ORIGIN. Let only the read-only /health, /live and /ready probes skip that check.
RUN node /tmp/patch-health.mjs /app/apps/server/src/app/create-app.ts \
    && rm /tmp/patch-health.mjs \
    && chmod 755 /usr/local/bin/doca-railway-start /usr/local/bin/doca-heavy-guard \
    && ln -s /usr/local/bin/doca-heavy-guard /usr/local/bin/doca-soffice \
    && ln -s /usr/local/bin/doca-heavy-guard /usr/local/bin/doca-pdf-python

EXPOSE 39120
# The wrapper starts as root only to fix the volume's ownership, then runs Doca as `node`.
ENTRYPOINT []
CMD ["/usr/local/bin/doca-railway-start"]
