#!/bin/bash
# Hourly qmd refresh, e.g.  47 * * * * /path/to/refresh.sh
#
# qmd has no watch mode, and `update` builds the keyword index only -- without
# `embed`, semantic search silently degrades to keyword search. Niced INSIDE the
# exec: prefixing `docker exec` would only renice the client.
set -euo pipefail

NICE="nice -n 19 ionice -c 3"
# Fetches any model the config needs but the cache lacks. Without it the
# generation and rerank models download during the first query instead, which
# can outlast the MCP timeout. A no-op once the cache is warm.
docker exec qmd $NICE qmd pull
docker exec qmd $NICE qmd update
docker exec qmd $NICE qmd embed --max-docs-per-batch 16
