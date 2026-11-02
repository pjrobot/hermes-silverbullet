"""SilverBullet knowledge-base plugin for Hermes Agent.

Registers the bundled skills and renders prompt.md into an always-on system
prompt section. The section has to be always on: "capture knowledge without
being asked" must apply in sessions where notes are not the topic, which is
exactly when an on-demand skill would never load.
"""

from __future__ import annotations

import re
from pathlib import Path
from string import Template

import yaml

_DIR = Path(__file__).parent
_COMMENT = re.compile(r"<!--.*?-->\s*", re.S)
_FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)

# Hermes DROPS a section over this size rather than truncating it, with only a
# log warning to show for it. The rendered text is ~1,000 characters today.
_MAX_CHARS = 2000


def _render(ctx) -> str:
    namespace = ctx.manifest.name
    template = Template(_COMMENT.sub("", (_DIR / "prompt.md").read_text()).strip())
    text = template.substitute(
        owner=ctx.get_config("owner_name", "the user"),
        notes_path=ctx.get_config("notes_path", "/notes").rstrip("/"),
        agent_folder=ctx.get_config("agent_folder", "Hermes").strip("/"),
        notes_skill=f"{namespace}:notes-vault",
    )
    if ctx.get_config("search_enabled", False):
        text += (
            f" For a vague question the vault might answer, load `{namespace}:qmd-search`"
            " — but reach for file search first when you can name the terms."
        )
    return text


def _frontmatter(skill_md: Path) -> dict:
    match = _FRONTMATTER.match(skill_md.read_text())
    return (yaml.safe_load(match.group(1)) or {}) if match else {}


def register(ctx):
    for child in sorted((_DIR / "skills").iterdir()):
        skill_md = child / "SKILL.md"
        if child.is_dir() and skill_md.exists():
            # The skills list shows the description passed here, not the
            # SKILL.md's own, so without it both skills list blank.
            meta = _frontmatter(skill_md)
            ctx.register_skill(child.name, skill_md, meta.get("description", ""), meta)

    # A callable is evaluated once per new session and get_config re-reads
    # config.yaml, so a settings change applies on the next /new -- no
    # gateway restart.
    ctx.register_system_prompt_section(
        f"{ctx.manifest.name}.vault", lambda _session: _render(ctx), max_chars=_MAX_CHARS)
