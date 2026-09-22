---
type: Plan
title: Phase 1 — Token-bucket middleware
description: Per-tenant token bucket enforced in the API middleware — 429 + Retry-After over quota, fail-open on Redis outage.
status: merged
tags: [design-doc, api, rate-limiting]
issues: [0001]
designs: [architecture/api/shipments]
---

# Phase 1: Token-bucket middleware

| | |
|---|---|
| **Status** | Merged |
| **Priority** | P0 |
| **Repository** | acme/freightloop |
| **Depends on** | — |
| **Blocks** | Phase 2 |
| **Pull request** | #81 |

## Scope

Lands enforcement: token-bucket middleware on the ingestion path plus
the quota config. The design and its rationale live in
[README.md](README.md) — this file tracks execution only.

## Task checklist

- [x] `api/internal/middleware/ratelimit.go` — bucket check + fail-open
- [x] Quota table in `api/config/limits.yaml`
- [x] 429 + `Retry-After` problem-shape response
- [x] Contract tests: over-quota burst, retry idempotency, Redis down

## Acceptance criteria

- 601st event in a minute returns 429 with a problem-shape body; the
  602nd after window rollover succeeds.
- `redis-cli shutdown` during the test → requests still accepted.

## Risks and open questions

- Single-node Redis is a request-path dependency until phase 2 lands
  the HA pair — fail-open bounds the risk.

## Progress log

| Date | Change | By |
|---|---|---|
| 2026-09-15 | Phase drafted | yamada |
| 2026-09-19 | Merged via #81 | yamada |
