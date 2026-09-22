---
type: Design Doc
title: <Change name>
description: <One line — what this change delivers and why.>
status: in-review            # draft | in-review | in-progress | done | dropped
last_modified: <YYYY-MM-DD>
tags: [<topic>]
authors: []     # who's accountable for the design — e.g. [@yamada]
reviewers: []   # who must weigh in before approval — e.g. [@lead, @sre]
issues: []      # issue IDs this resolves — e.g. [0001]
designs: []     # living docs this changes — paths under docs/, e.g. [architecture/worker, architecture/api/shipments]
---

# <Change name> — Overview

<!-- 2–3 lines: what this design doc proposes and why now. -->

- **Created**: <YYYY-MM-DD>
- **Repositories**: <repos in scope>
- **Scope**: this doc is maintained with the implementation — keep the
  phase index and status column current. Once every phase ships it
  freezes; the `designs:` docs carry the living truth.

## Context

**Resolves:** [issue NNNN — <title>](../../issues/NNNN-<slug>.md)

<!-- Objective facts — what exists today and why it falls short. Link the
issues it resolves; don't duplicate their narrative. -->

### Operating assumptions

| Assumption | Value |
|---|---|
| <constraint or decision that bounds the design> | <value> |

## Goals and non-goals

| Goal | Phases |
|---|---|
| <goal> | <phase numbers> |

<!-- Non-goals: adjacent scope deliberately excluded from this change. -->

## Options and trade-offs

| Option | Cost / trade-off | Verdict |
|---|---|---|
| <chosen approach> | <what it costs — the trade accepted> | **Accepted** |
| <alternative> | <why it loses on the goals> | Rejected |

## Proposed architecture

<!-- The chosen design — compress, don't enumerate. Model surfaces with
tables and diagrams (route map, interface matrix, state machine), not
walkthroughs of every endpoint or view. Link schema sources of truth
(OpenAPI/protobuf) instead of inlining payloads or field lists. -->

## Cross-cutting concerns

<!-- Security, observability, fault tolerance — the systemic aspects a
reviewer must weigh. -->

## Rollout and migration

| Phase | Title | Priority | Status | Pull request |
|---|---|---|---|---|
| 1 | [<title>](phase-1-<slug>.md) | P0 | Not started | _none_ |

Status legend: Not started · In progress · In review · Merged ·
Deferred · Dropped

```text
Phase 1 ──┐
          ├─ independent, ship first
Phase 2 ──┘
Phase 2 ──> Phase 3
```

- **Rollback**: <how it reverts — flag, config, redeploy>

## Success metrics

<!-- Measurable signals that the change worked — SLOs held, incident
classes eliminated, overhead added. -->

## Open questions

- [ ] <unresolved technical ambiguity or external dependency>

## Companion docs

| Repository | Design doc |
|---|---|
| <owner/repo> | <link or path to the companion doc> |
