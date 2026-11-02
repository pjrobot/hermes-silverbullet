# Upstream ships no image. Thin on purpose: models, config and the SQLite
# index all live on mounts, so a rebuild loses nothing.
FROM node:22-bookworm

ARG QMD_VERSION=2.8.3
RUN npm install -g @tobilu/qmd@${QMD_VERSION} && npm cache clean --force

# uid 1000, matching the space owner, so nothing it writes lands root-owned.
USER node

ENV QMD_CONFIG_DIR=/config \
    XDG_CACHE_HOME=/cache

EXPOSE 8181

# 0.0.0.0 so other containers can reach it; compose sets QMD_ALLOWED_HOSTS
# to restore the Host-header check this disables.
CMD ["qmd", "mcp", "--http", "--host", "0.0.0.0", "--port", "8181"]
