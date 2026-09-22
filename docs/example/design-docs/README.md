---
type: Reference
title: Freightloop — design docs
description: Per-change design docs for Freightloop — written before implementation, updated by the PRs that implement them. No hand-maintained index; each doc's frontmatter carries its own status, issues, and designs.
status: current
last_modified: 2026-09-22
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
- A multi-phase change gets a directory: `README.md` is the design doc
  (context, trade-offs, rollout) and each `phase-N-<slug>.md` is the
  execution surface — the smallest independently mergeable increment,
  roughly one PR each. When a phase merges, the doc's `status:`/phase
  index and the living docs listed in `designs:` are updated in the
  same commit.
- When a doc reaches `done` (or `dropped`), move its file or directory
  to `archived/`, set `status:` accordingly, and record the delivering
  PR in the body (e.g. "delivered via #123").
- Design docs omit `sources:` — they record a point-in-time change
  rather than a living derivation; the `sources:` contract applies to
  `docs/architecture/` docs only.
