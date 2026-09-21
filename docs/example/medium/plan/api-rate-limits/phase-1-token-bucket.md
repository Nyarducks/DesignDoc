---
type: Plan
title: Phase 1 — Token-bucket middleware
description: Per-tenant token bucket enforced in the API middleware — 429 + Retry-After over quota, fail-open on Redis outage.
status: merged
last_modified: 2026-09-22
tags: [plan, api, rate-limiting]
issues: [0001]
designs: [api/design/shipments]
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

## Problem

`POST /v1/shipments/{id}/events` accepts unbounded traffic — one
misbehaving partner degrades ingest lag for every tenant.

## Evidence

- `api/internal/handlers/shipments.go` — no quota check on the request
  path.
- 2026-09-08 incident: 40k events in 3 minutes from one carrier →
  4-minute fleet-wide lag.

## Impact

Without this phase, the noisy-neighbor failure remains unmitigated;
phase 2 (dashboard + HA) has nothing to meter against.

## Proposed change

1. Token-bucket middleware before the shipments handler: `INCR`
   `rl:<tenant>:<minute>` + `EXPIRE`; over quota → 429 + `Retry-After`.
2. Quotas per carrier key in config; default 600 events/min.
3. Redis unreachable → log + allow (fail open per ADR-0002).

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
