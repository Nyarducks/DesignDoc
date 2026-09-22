---
type: Plan
title: Phase 2 — Usage meter and Redis HA
description: Surface per-tenant quota usage in the dashboard and make the rate-limit counter store survive failover.
status: in-progress
last_modified: 2026-09-22
tags: [design-doc, frontend, infra, rate-limiting]
issues: [0001]
designs: [architecture/web, architecture/infra, architecture/infra/autoscaling]
---

# Phase 2: Usage meter and Redis HA

| | |
|---|---|
| **Status** | In progress |
| **Priority** | P1 |
| **Repository** | acme/freightloop |
| **Depends on** | Phase 1 |
| **Blocks** | — |
| **Pull request** | #96 |

## Scope

Adds operator visibility — `GET /v1/usage`, dashboard usage bar, quota
editor — and makes the counter store HA. The design and its rationale
live in [README.md](README.md); this file tracks execution only.

## Task checklist

- [x] `infra/terraform/redis-ha.tf` — replica pair + sentinel
- [ ] `api/internal/handlers/usage.go` — usage endpoint
- [ ] `web/src/routes/usage/` — meter UI + quota editor
- [ ] Failover drill — kill primary mid-burst, assert limits resume

## Acceptance criteria

- Sentinel failover during a burst: ≤ 5 s of fail-open, then counters
  resume without lost-window overflow.
- Dashboard shows current usage vs quota per tenant; quota edits take
  effect within one window.

## Risks and open questions

- Sentinel adds a third failure mode — covered by the failover drill
  acceptance criterion.
- Usage endpoint itself needs a (generous) limit — unbounded reads are
  the same class of bug we're fixing.

## Progress log

| Date | Change | By |
|---|---|---|
| 2026-09-20 | Phase drafted | tanaka |
| 2026-09-22 | Redis HA landed in #96 (partial) | tanaka |
