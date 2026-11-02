---
name: qmd-search
description: "Fallback semantic search over the notes vault via the qmd MCP server — file tools are primary; always rerank: false on CPU."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    category: research
    tags: [qmd, search, notes, mcp, knowledge-base]
    related_skills: [notes-vault]
---

# qmd Search

The `qmd` MCP server is a local search engine over the markdown in `/notes` (and anything else its `index.yml` lists). Tools: `status`, `query`, `get`, `multi_get`.

## When to Use

**File tools are the primary search path.** In one small test (5 questions over ~110 markdown files, with reranking off and the vector index incomplete), `search_files` + `read_file` found the right page every time, and qmd's natural-language path once ranked a distractor above it. That is not a verdict on qmd, but it is a reason to reach for file tools whenever you can name a likely filename, folder, or keyword.

Use qmd as a **fallback** when:

- The question is conceptual and its wording won't match any page's text
- You need a broad first sweep and don't know where something lives

Don't use it to change anything (it is read-only), for minutes-old content (the index is not live), or for anything outside its collections.

## Procedure

**If the host has no GPU, always pass `rerank: false`.** On an 8-core CPU, reranking took 10–60 s per query and saturated every core; without it the same queries took ~5–40 ms. The tool defaults to `rerank: true`.

1. **Check the index.** `status`: look at `lastUpdated` per collection and `needsEmbedding`. A nonzero `needsEmbedding` means vector recall is incomplete.
2. **Search.** Pick the shape by how precisely you can name the target:
   - `{"searches":[{"type":"lex","query":"..."}]}` — BM25 keywords, phrases, `-exclude`. Fast and exact.
   - `{"searches":[{"type":"vec","query":"..."}]}` — semantic, when the wording won't match.
   - `{"query":"..."}` — auto-expanded and fused, so the broadest recall, but the expansion runs a small LLM first: on CPU, expect it to be much slower than `lex`/`vec`.
   - `query` and `searches` are mutually exclusive.
3. **Read the hit** with `get` (`file`, `fromLine`, `maxLines`) or `read_file`. Cite content, not snippets.
4. **An empty result is an index signal, not absence.** Read `/notes` directly before concluding something doesn't exist.

## Pitfalls

- **Forgetting `rerank: false` on CPU** — the number-one failure; the call hits the MCP timeout.
- **Stale index.** It refreshes on a timer. When the index and the filesystem disagree, the filesystem is right.
- **`needsEmbedding` > 0** — prefer `lex`, which needs no vectors.
