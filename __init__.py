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

_DIR = Path(__file__).parent
_COMMENT = re.compile(r"<!--.*?-->\s*", re.S)


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


def register(ctx):
    for child in sorted((_DIR / "skills").iterdir()):
        skill_md = child / "SKILL.md"
        if child.is_dir() and skill_md.exists():
            ctx.register_skill(child.name, skill_md)

    # Rendered once at load: settings changes take effect after a gateway
    # restart, then on each new session.
    ctx.register_system_prompt_section(f"{ctx.manifest.name}.vault", _render(ctx), max_chars=2000)
