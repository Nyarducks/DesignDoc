---
type: Plan
title: Phase 2 — Usage meter and Redis HA
description: Surface per-tenant quota usage in the dashboard and make the rate-limit counter store survive failover.
status: in-progress
last_modified: 2026-09-22
tags: [plan, frontend, infra, rate-limiting]
issues: [0001]
designs: [web/design, infra/design, infra/design/autoscaling]
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

## Problem

Phase 1 enforces limits but operators can't see them — a throttled
carrier looks identical to a quiet one. And the counter store is
single-node Redis, now on the request path.

## Evidence

- `infra/design/` service map — Redis listed as single-node.
- Phase 1 progress log — fail-open means a Redis outage silently
  disables enforcement.

## Impact

Without HA, a Redis restart erases in-flight windows (briefly unlimited)
then blocks nothing; without the usage meter, ops can't tune quotas or
explain 429s to partners.

## Proposed change

1. Redis → primary/replica pair with sentinel failover; api reconnect
   handling.
2. `GET /v1/usage` — per-tenant current-window usage + quota.
3. Dashboard: usage bar on the shipment detail panel; admin quota
   editor (dispatcher role).

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
