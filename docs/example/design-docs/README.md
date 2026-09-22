---
type: Reference
title: Freightloop — design docs
description: Per-change design docs for Freightloop — written before implementation, updated by the PRs that implement them. No hand-maintained index; each doc's frontmatter carries its own status, issues, and designs.
status: current
tags: [design-doc]
sources: []
---

# Design docs

Per-change proposal docs — written before implementation, reviewed as a
PR, updated by the PRs that implement them. A design doc records the
decision for one change; once it ships it freezes, and the architecture
docs carry the living truth. One `NNNN-<change>/` directory per change —
numbered like ADRs and issues so the listing orders them; a change that
fits a single PR is a lone `NNNN-<change>.md` in this directory.
*(Fictional example — the Freightloop project.)*

## Finding design docs

There is intentionally **no index table** — it duplicates each doc's
frontmatter and forces every parallel doc PR to edit the same rows.

- **Active**: files and directories directly under `docs/design-docs/`
  (excluding this README and `archived/`).
- **Archived**: [`archived/`](archived/) — done and dropped docs keep
  their full history there.
- Each doc's frontmatter carries `status`, `issues`, and `designs` —
  query those instead of a list:

  ```bash
  grep -rl '^status: in-progress' docs/design-docs/ --include='*.md'
  ```

## Conventions

- Status legend: `draft` · `in-review` · `in-progress` · `done` ·
  `dropped`. `in-review` — the doc PR is open and the design is being
  weighed; `in-progress` — implementation has started.
- A design doc is **self-contained for review** — Context (with a
  `**Resolves:**` link to the issues it settles), goals, options and
  trade-offs, proposed architecture, and rollout all live in the doc
  itself. Compress, don't enumerate: interface tables and diagrams over
  endpoint walkthroughs, and link schema sources of truth instead of
  inlining payloads or field lists.
- Domain terms come from [../architecture/glossary.md](../architecture/glossary.md)
  — link it, don't redefine. A term the proposal introduces is
  promoted to the glossary when the change ships.
- A multi-phase change gets a directory: `README.md` is the design doc
  and each `phase-N-<slug>.md` is the execution surface — scope, task
  checklist, acceptance criteria, PR link, progress log; roughly one PR
  each. Design narrative stays in the README — a reviewer reads the
  README alone. When a phase merges, the doc's `status:`/phase index
  and the living docs listed in `designs:` are updated in the same
  commit.
- When a doc reaches `done` (or `dropped`), move its file or directory
  to `archived/`, set `status:` accordingly, and record the delivering
  PR in the body (e.g. "delivered via #123").
- Design docs omit `sources:` — they record a point-in-time change
  rather than a living derivation; the `sources:` contract applies to
  `docs/architecture/` docs only.
