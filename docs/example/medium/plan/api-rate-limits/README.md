---
type: Plan
title: Per-tenant API rate limits
description: Token-bucket rate limiting on the ingestion path — shared Redis counters, 429 + Retry-After, usage surfaced in the dashboard.
status: in-progress
last_modified: 2026-09-22
tags: [plan, api, rate-limiting]
issues: [0001]
designs: [api/design/detailed, infra/design/autoscaling]
---

# Per-tenant API rate limits — Overview

Adds per-tenant rate limits to the ingestion surface so one partner's
burst can't degrade the shared SLO. Phase 1 lands enforcement; phase 2
makes the counter store HA and surfaces usage to operators.

- **Created**: 2026-09-15
- **Repositories**: `acme/freightloop`
- **Scope**: this plan is maintained with the implementation — keep the
  phase index and status column current.

## Context

[Issue 0001](../../issues/0001-api-no-backpressure.md) — the events
endpoint has no quota check; one carrier's retry loop already caused a
fleet-wide 4-minute ingest lag incident. The queue absorbs bursts today
but lag is shared across tenants.

### Operating assumptions

| Assumption | Value |
|---|---|
| Limit granularity | Per carrier key, per minute window |
| Default quota | 600 events/min per tenant (2× observed p99) |
| Counter store | Redis — see [ADR-0002](../../adr/0002-redis-rate-limit-state.md) |
| Redis outage behavior | Fail open (log + allow) — never block ingestion |

## Goal mapping

| Goal | Phases |
|---|---|
| Enforce per-tenant limits on ingestion | 1 |
| Operators can see and tune quotas | 2 |
| Counter store survives a Redis failover | 2 |

## Phase index

| Phase | Title | Priority | Status | Pull request |
|---|---|---|---|---|
| 1 | [Token-bucket middleware](phase-1-token-bucket.md) | P0 | Merged | #81 |
| 2 | [Usage meter + Redis HA](phase-2-usage-and-redis-ha.md) | P1 | In progress | #96 |

Status legend: Not started · In progress · In review · Merged ·
Deferred · Dropped

## Dependency order

```text
Phase 1 ──> Phase 2
(enforcement first; dashboard + HA build on the same counters)
```

## Rejected alternatives

- **Queue-level shedding** — drops already-accepted work and punishes
  well-behaved tenants; rejected for unfair blast radius.
- **Per-pod in-memory buckets** — limit becomes `quota × pod count`
  under HPA; rejected (ADR-0002).
