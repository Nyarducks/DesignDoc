---
type: Design Doc
title: Freightloop API — basic design
description: Basic design — surface-level architecture, conventions, and contract inventory.
status: current
last_modified: 2026-09-22
tags: [api, design]
sources: [api/]
adrs: [0002]
issues: [0001]
---

# Freightloop API — basic design

How the surface is put together. What it must satisfy lives
in [requirements.md](requirements.md); per-resource internals live in
[detailed.md](detailed.md).

## System architecture

```mermaid
flowchart LR
    Carriers["carrier integrations"] --> LB["ingress LB"]
    Web["dashboard (web/)"] --> LB
    LB --> MW["middleware: auth · rate-limit · validation"]
    MW --> H["handlers"]
    H --> PG[(PostgreSQL — shipments, events, projections)]
    H -->|enqueue events| Q[(job queue — PG table)]
    Q --> W["worker/"]
    MW -.->|rate-limit counters| Redis[(Redis)]
```

The API is thin by design: authenticate, validate, dedupe, persist or
enqueue, ack. Everything computable later (ETA, alerts, notifications)
is deferred to the worker so ingestion latency stays flat.

## Conventions

Each convention is a decision; the rejected alternative is what keeps
it from being arbitrary.

- **Auth** — partner keys scoped per carrier (`events:write`,
  `shipments:read`); dashboard calls carry the user's SSO session.
  Scoped keys over OAuth bearer flows because several carrier bridges
  can't run a token-refresh dance.
- **Versioning** — path prefix (`/v1/`); breaking changes ship a new
  prefix, never a flag. URL pinning is the only mechanism every
  integration — including FTP-bridge schedulers — actually honors.
- **Errors** — RFC 9457 problem shape (`type`, `title`, `status`,
  `detail`, `code`). Chosen over ad-hoc `{error: "msg"}` because
  partner SDKs key retries off a stable `code`.
- **Pagination** — cursor-based on every list endpoint; `next_cursor`
  is null at the end. Offset was rejected: event tables are
  append-heavy, so offsets drift under concurrent writes.
- **Idempotency** — writes dedupe on a client-supplied key. Carriers
  retry non-2xx aggressively, so idempotent writes are the surface's
  correctness guarantee, not a nicety.

## Contract inventory

| Surface | Base path | Callers | Detail |
|---|---|---|---|
| shipments | `/v1/shipments*` | `events:write`, `shipments:read`; dashboard | [detailed.md](detailed.md#shipments) |

## Data model

Two stores behind the surface: `events` — an append-only log keyed by
client `event_id` — and `shipments` — the folded projection the GET
endpoints serve. The API writes events and reads projections; the
worker owns the fold, so read and write paths never contend on the same
rows. Column-level schema lives in `api/openapi.yaml` and migrations.

## Dependencies

| Depends on | Why |
|---|---|
| PostgreSQL | shipments, events, folded projections, queue table |
| Job queue (PG table) | durable event handoff to the worker — see [worker/design/](../../worker/design/) |
| Redis | rate-limit counters ([ADR-0002](../../adr/0002-redis-rate-limit-state.md)) — fails open |

## Decisions and alternatives

- **Thin API, deferred computation** over doing ETA/alert work in the
  request path — ingestion ack latency must stay flat under 10k/s
  bursts; anything computable later is the worker's job. The cost is
  projection lag, which the `eta.stale` flag makes honest.
- **PG table as the queue** over a dedicated broker — already deployed,
  `SKIP LOCKED` covers competitive claiming; the worker doc records
  when to revisit.
- **Rate-limit counters in Redis** over per-pod buckets and over PG
  counters — limits must hold under HPA without a write per request on
  the hot path; [ADR-0002](../../adr/0002-redis-rate-limit-state.md).

## Risks and mitigations

- A partner bursts beyond fair share → per-tenant token buckets landing
  in [the rate-limit plan](../../plan/api-rate-limits/); until it
  finishes, tracked as [issue 0001](../../issues/0001-api-no-backpressure.md).
- Redis on the request path → fail-open on outage; HA pair in the
  plan's phase 2.
