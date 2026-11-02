# Hermes

Notes written by the agent: decisions, gotchas and measurements captured while
working. **Not a session log.** Organised by tags, not folders; folders are only
for families of notes a scheduled job writes.

## Recent notes

${query[[
  from p = index.pages("Hermes")
  order by p.lastModified desc
  limit 20
  select templates.fullPageItem(p)
]]}

## Waiting on you

Any agent note with `status: open` in its frontmatter. Change it to `done`
and the note drops off this list.

${query[[
  from p = index.pages("Hermes") where p.status = "open"
  order by p.lastModified desc
  select templates.fullPageItem(p)
]] || "_nothing open_"}

## By tag

${each(["infra", "decision", "gotcha", "howto"], t => `### #${t}\n\n${query[[from p = index.pages("Hermes") where p.tags = "${t}" order by p.lastModified desc select templates.fullPageItem(p)]] || "_none yet_"}`)}
