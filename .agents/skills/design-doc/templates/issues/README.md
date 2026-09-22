---
type: Reference
title: Issues
description: Known problems and improvement backlog — one NNNN-<slug>.md file per issue; closed ones move to archived/.
status: current
tags: [issues]
sources: []
---

# Issues

Known problems and improvement backlog. One file per issue,
`NNNN-<slug>.md` — numbered like ADRs so the directory listing orders
them. An issue that gets scheduled becomes a design doc
(`docs/design-docs/NNNN-<change>/`) or a code change; set `resolved_by:`
in its frontmatter.

## Finding issues

There is intentionally **no index table** — every parallel issue PR
would edit the same rows.

- **Active**: files directly under `docs/issues/` (excluding this README
  and `archived/`).
- **Archived**: [`archived/`](archived/) — `done`, `deferred`, and
  `wontfix` issues keep their history there.
- Each issue's frontmatter carries `status` and `resolved_by` — query
  those instead of a list:

  ```bash
  grep -rl '^status: open' docs/issues/ --include='*.md'
  ```

## Conventions

- Status legend: `open` · `investigating` · `planned` · `in-progress` —
  active; `done` · `deferred` · `wontfix` — move the file to
  `archived/` in the closing PR.
- A file can stay thin — frontmatter plus a Problem paragraph is enough;
  grow it when the issue needs evidence or options.
