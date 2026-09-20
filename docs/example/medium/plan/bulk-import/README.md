---
type: Plan
title: Bulk import
description: CSV bulk import for products and stock — async jobs with per-row error reporting and resume.
status: in-progress
last_modified: 2026-09-20
tags: [plan, import, csv]
sources: [worker/jobs/import/, api/internal/jobs/, web/src/features/import/]
issues: [0001]
---

# Bulk import — Overview

Add CSV bulk import for products and stock levels: upload a file, get an
async job, see per-row results. *(Fictional example plan.)*

- **Created**: 2026-09-01
- **Repositories**: `acme/stockpilot`
- **Scope**: this plan is maintained with the implementation — keep the
  phase index and status column current.

## Context

Imports today are SQL dumps run by an engineer on request. Operators need
self-serve import with errors they can fix themselves.

### Operating assumptions

| Assumption | Value |
|---|---|
| File size ceiling | 100k rows / 25 MB |
| Format | CSV only — no XLSX this plan |
| Execution | Existing worker fleet; no new infra |
| Conflicts | Last-write-wins per SKU, reported per row |

## Goal mapping

| Goal | Phases |
|---|---|
| Self-serve upload + tracking | 1, 2 |
| Operators can fix bad rows | 2, 3 |
| Safe against malformed input | 1, 3 |

## Phase index

| Phase | Title | Priority | Status | Pull request |
|---|---|---|---|---|
| 1 | [Upload and validate](phase-1-upload-and-validate.md) | P0 | In progress | #211 |
| 2 | Staged apply with per-row results | P0 | Not started | _none_ |
| 3 | Error report export | P1 | Not started | _none_ |

Status legend: Not started · In progress · In review · Merged ·
Deferred · Dropped

## Dependency order

```text
Phase 1 (upload/validate)  ──>  Phase 2 (staged apply)  ──>  Phase 3 (error export)
```

## Rejected alternatives

- **Synchronous import in the API request** — simplest, but ties import
  duration to a request lifecycle and blocks the connection on bad
  files; rejected in favor of the existing job machinery.
- **Streaming upserts per row** — doubles write load for no operator
  benefit; staged apply gives an atomic-looking result per batch.

## Companion plans

_None — single-repo change._

## Notes

Phase 2 owns the checkpoint format; later phases must not change it
without a new plan.
