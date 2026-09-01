ARG GOGCLI_IMAGE=ghcr.io/openclaw/gogcli:v0.34.1
ARG OPENCLAW_BASE_IMAGE=ghcr.io/openclaw/openclaw:2026.7.1-2

FROM ${GOGCLI_IMAGE} AS gogcli
FROM ${OPENCLAW_BASE_IMAGE}

COPY --from=gogcli /usr/local/bin/gog /usr/local/bin/gog
