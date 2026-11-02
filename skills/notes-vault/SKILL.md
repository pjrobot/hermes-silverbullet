---
name: notes-vault
description: "Edit the user's SilverBullet vault at /notes, rendered live."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    category: note-taking
    tags: [notes, silverbullet, vault, markdown, wiki-links]
    related_skills: [qmd-search]
---

# Notes Vault (SilverBullet)

The user's knowledge base lives in a SilverBullet vault at `/notes` — plain markdown, one file per page, rendered live in their browser as you edit. This skill governs how to read, extend, and safely change those notes. It is a shared workspace, not scratch space.

## When to Use

- Any request to write, append, edit, organise, or create notes in `/notes`
- Recording durable reference material (project context, decisions, conventions)
- The user mentions "my notes", "a note", "/notes", or SilverBullet
- Reading back or verifying a note that was just written

Don't use for ephemeral session recall — that belongs in memory, not the vault.

## SilverBullet Syntax That Matters

- **Wiki links:** `[[Page Name]]` links pages. Plain `[text](url)` for external URLs.
- **Tags:** `#tagname`, single word. SilverBullet indexes them for queries.
- **Frontmatter:** a YAML block between `---` lines at the top of a page. Queries read it, so keys like `status:` and `tags:` are how a page shows up on a dashboard.
- **Queries/widgets:** `${query[[...]]}` blocks are live dashboards — leave them intact when editing a page that contains them.

## Create vs Append

- **New page:** a distinct, durable topic that will be linked to and revisited.
- **Append:** a new finding on a topic that already has a home page. Find it first and extend it.
- If there is already a page that is *the* home for this information, append. Split only when the content is genuinely separate. The choice is yours.

## Procedure

1. **Locate the target.** `search_files`/`read_file` to find whether a page already covers the topic.
2. **Choose create vs append** (above).
3. **Write with `write_file`, or `patch` for a targeted edit.** Prefer `patch` for an existing page — a full rewrite destroys the user's formatting and jolts a page they may have open.
4. **Read the file back** to confirm the write landed. Do not trust tool-reported success alone.
5. **Report** what you wrote and where.

## Naming & Folders

- **Filenames:** lowercase-kebab-case (`ingest-pipeline-notes.md`), one page per `.md` file.
- **Tags are the primary organisation.** Folders are for machine-managed families only (e.g. a folder of dated notes written by a cron job that shouldn't have to parse tags to find its files). Never build a pre-planned taxonomy (`development/`, `recipes/`, …) — it drifts and ends in reorganisation.
- **Tags:** topical, lowercase, single-word. Check a new frontmatter key renders cleanly before using it vault-wide; an unexpected one can break SilverBullet's highlighter.

## Pitfalls

- **Never touch `.silverbullet.auth.json`** — SilverBullet's signing secret. Do not read, edit, or delete it.
- **Never touch `.git` or `.gitignore`** — `.git` holds the snapshot history.
- **Edits appear live.** Match existing structure, prefer additive edits, do not experiment on real pages.
- **Tool-reported success ≠ write landed.** If the read-back differs, say the write is unconfirmed rather than assuming it worked.

## Verification

- [ ] After any write, `read_file` returns the expected content for the affected region
- [ ] No change touched `.silverbullet.auth.json`, `.git`, or `.gitignore`
- [ ] New pages follow the naming convention
- [ ] Existing pages were patched, not wholesale rewritten
