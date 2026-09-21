---
type: ADR
title: Rate-limit counters live in shared Redis
description: Token-bucket state is shared per-cluster in Redis so limits hold regardless of which api pod serves the request.
status: accepted
last_modified: 2026-09-22
tags: [adr, api, rate-limiting, redis]
---

# ADR-0002: Rate-limit counters live in shared Redis

## Status

Accepted

## Context

Per-tenant rate limiting ([plan api-rate-limits](../plan/api-rate-limits/))
needs a counter visible to every api pod. Options weighed:

- **In-process per-pod counters** — zero dependencies, but each pod gets
  its own bucket: a tenant's real limit becomes `limit × pod count`, and
  HPA reshapes it mid-burst.
- **PostgreSQL counters** — correct and already deployed, but a write per
  request on the hot ingestion path adds latency and write contention we
  can't afford at 10k events/s bursts.
- **Shared Redis** — atomic `INCR`/`EXPIRE` buckets; adds a hot-path
  dependency but Redis is already in-cluster for the job queue.

## Decision

Rate-limit counters live in Redis (`rl:<tenant>:<window>` keys with TTL),
checked by middleware before the handler runs. Redis is promoted from
queue-only to request-path dependency; the HA pair lands in phase 2 of
the plan.

## Consequences

- Limits hold exactly regardless of pod count — safe under autoscaling.
- A Redis outage must fail open (log + allow) or the whole API stalls;
  the middleware documents this fallback.
- Infra gains a request-path component — see the service map in
  [infra/design/](../infra/design/).
