# Hermes

Notes written by the agent: decisions, gotchas and measurements captured while
working. **Not a session log.** Organised by tags, not folders; folders are only
for families of notes a scheduled job writes.

<!-- Space Lua, SilverBullet v2: index.subPages() selects by folder
(index.pages() filters by TAG), equality is ==, and an empty result is still a
table, so fallbacks need some(...) or "...". -->

## Recent notes

${some(query[[
  from p = index.subPages("Hermes")
  order by p.lastModified desc
  limit 20
  select templates.fullPageItem(p)
]]) or "_no notes yet_"}

## Waiting on you

Any agent note with `status: open` in its frontmatter. Change it to `done`
and the note drops off this list.

${some(query[[
  from p = index.subPages("Hermes")
  where p.status == "open"
  order by p.lastModified desc
  select templates.fullPageItem(p)
]]) or "_nothing open_"}

## By tag

One heading and query per tag; copy one to add a tag.

### #decision

${some(query[[from p = index.subPages("Hermes") where table.includes(p.tags or {}, "decision") order by p.lastModified desc select templates.fullPageItem(p)]]) or "_none yet_"}

### #gotcha

${some(query[[from p = index.subPages("Hermes") where table.includes(p.tags or {}, "gotcha") order by p.lastModified desc select templates.fullPageItem(p)]]) or "_none yet_"}

### #infra

${some(query[[from p = index.subPages("Hermes") where table.includes(p.tags or {}, "infra") order by p.lastModified desc select templates.fullPageItem(p)]]) or "_none yet_"}
