---
type: Plan
title: <Change name>
description: <One line — what this plan delivers and why.>
status: in-progress            # draft | in-progress | done | dropped
last_modified: <YYYY-MM-DD>
tags: [plan, <topic>]
issues: []      # issue IDs this plan resolves — e.g. [0001]
designs: []     # design docs this plan modifies — paths under docs/, e.g. [worker/design, api/design/shipments]
---

# <Change name> — Overview

<2–3 lines: what this plan delivers and why now.>

- **Created**: <YYYY-MM-DD>
- **Repositories**: <repos in scope>
- **Scope**: this plan is maintained with the implementation — keep the
  phase index and status column current.

## Context

<Objective facts — what exists today and why it falls short.>

### Operating assumptions

| Assumption | Value |
|---|---|
| <constraint or decision that bounds the plan> | <value> |

## Goal mapping

| Goal | Phases |
|---|---|
| <goal> | <phase numbers> |

## Phase index

| Phase | Title | Priority | Status | Pull request |
|---|---|---|---|---|
| 1 | [<title>](phase-1-<slug>.md) | P0 | Not started | _none_ |

Status legend: Not started · In progress · In review · Merged ·
Deferred · Dropped

## Dependency order

```text
Phase 1 ──┐
          ├─ independent, ship first
Phase 2 ──┘
Phase 2 ──> Phase 3
```

## Rejected alternatives

- **<option>** — <why it was dropped; the trade-off it loses on>

## Companion plans

| Repository | Plan |
|---|---|
| <owner/repo> | <link or path to the companion plan dir> |

## Notes

<Caveats, rollout notes, anything that doesn't fit above.>
