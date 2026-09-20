---
type: Plan
title: Phase 1 — Upload and validate
description: Accept a CSV upload, parse and validate every row, persist a staged run without touching live stock.
status: in-progress
last_modified: 2026-09-20
tags: [plan, import, csv]
sources: [worker/jobs/import/validate.go, api/internal/jobs/import_handler.go]
designs: [worker]
---

# Phase 1: Upload and validate

| | |
|---|---|
| **Status** | In progress |
| **Priority** | P0 |
| **Repository** | `acme/stockpilot` |
| **Depends on** | — |
| **Blocks** | Phase 2, Phase 3 |
| **Pull request** | #211 |

## Problem

There is no self-serve import path: operators hand engineers a
spreadsheet and wait. The first tractable slice is accepting a file and
validating it completely before anything writes to stock tables.

## Evidence

Support tickets are ~30% "please import this CSV". Every such import
today is a manual `psql` session with no audit trail.

## Impact

Without this phase the later ones have nothing to build on; shipping it
alone still removes the malformed-file class of failed imports.

## Proposed change

1. `POST /imports` accepts a CSV upload, enqueues an `import.validate`
   job, returns a job ID.
2. The worker parses the file, validates each row (schema, SKU format,
   quantity bounds), and writes the staged rows + per-row errors to
   `import_staging`.
3. `GET /imports/{id}` reports counts and the first N row errors.

## Task checklist

- [x] Upload endpoint with 25 MB limit and content-type check
- [x] `import.validate` job handler: parse → validate → stage
- [ ] Per-row error codes (`BAD_SKU`, `NEGATIVE_QTY`, `UNKNOWN_COLUMN`)
- [ ] Status endpoint returning staged/error counts

## Acceptance criteria

- A 100k-row file validates in under 60s without API impact.
- Every rejected row has a stable error code and the original line.
- Live stock tables are untouched by this phase.

## Risks and open questions

- Encoding: Shift-JIS exports from supplier tools may need a charset
  option — flagged, defaults to UTF-8 for now.
- Duplicate SKUs inside one file: flagged as errors, not merged.

## Progress log

| Date | Change | By |
|---|---|---|
| 2026-09-01 | Phase drafted | A. Worker |
| 2026-09-18 | Upload + staging landed behind flag | A. Worker |
