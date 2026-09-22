---
type: Reference
title: Freightloop — Plans
description: Per-change plans for Freightloop — written before implementation, updated by the PRs that implement them. No hand-maintained index; each plan's frontmatter carries its own status, issues, and designs.
status: current
last_modified: 2026-09-22
tags: [plan]
sources: []
---

# Plans

Per-change proposal docs — written before implementation, reviewed as a
PR, updated by the PRs that implement them. One `NNNN-<change>/`
directory per change — numbered like ADRs and issues so the listing
orders them; a change that fits a single PR is a lone `NNNN-<change>.md`
in this directory. *(Fictional example — the Freightloop project.)*

## Finding plans

There is intentionally **no index table** — it duplicates each plan's
frontmatter and forces every parallel plan PR to edit the same rows.

- **Active**: files and directories directly under `docs/plan/`
  (excluding this README and `archived/`).
- **Archived**: [`archived/`](archived/) — done and dropped plans keep
  their full history there.
- Each plan's frontmatter carries `status`, `issues`, and `designs` —
  query those instead of a list:

  ```bash
  grep -rl '^status: in-progress' docs/plan/ --include='*.md'
  ```

## Conventions

- Status legend: `draft` · `in-progress` · `done` · `dropped`.
- Phases are milestones — the smallest independently mergeable
  increment, roughly one PR each. When a phase merges, the plan's
  `status:`/phase index and the design docs listed in `designs:` are
  updated in the same commit.
- When a plan reaches `done` (or `dropped`), move its file or directory
  to `archived/`, set `status:` accordingly, and record the delivering
  PR in the plan body (e.g. "delivered via #123").
- Plan docs omit `sources:` — they record a point-in-time change rather
  than a living derivation; the `sources:` contract applies to living
  docs only.
