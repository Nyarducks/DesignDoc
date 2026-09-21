---
type: Design Doc
title: Freightloop API — requirements
description: Requirements — what the API surface must deliver, for whom, under what constraints.
status: current
last_modified: 2026-09-22
tags: [api, requirements]
sources: []
adrs: []
issues: [0001]
---

# Freightloop API — requirements

The "what and why" for this surface. Design choices live in
[basic.md](basic.md) and [detailed.md](detailed.md); this doc defines
the targets they must satisfy.

## Overview

One REST surface for two audiences: carrier integrations pushing
tracking events, and the ops dashboard reading shipment state. Every
external interaction with Freightloop goes through here — no direct
database access, ever.

## Background and motivation

- ~40 carrier integrations push events; their SDKs range from modern
  HTTP clients to scheduled FTP-to-HTTP bridges that can POST but can't
  poll or hold connections open.
- Sustained ingestion is ~2k events/s with 10k/s hourly bursts (depot
  scan batches land on the hour).
- Carriers retry non-2xx aggressively — duplicate delivery is normal.
- Ops audit shipments after the fact — "what did we believe at time T"
  must be answerable.
- The dashboard reads continuously; reads and writes share one SLO
  window.

## Goals and non-goals

### Goals

- One authenticated surface for event ingestion and shipment reads.
- Idempotent writes — carrier retries must never double-record.
- Contract stability a POST-only bridge can honor for years.
- Reads stay inside SLO while ingestion bursts — no coupling.

### Non-goals

- No bulk import surface — registration is per-shipment, by design.
- No ad-hoc query language or GraphQL — filters stay enumerable.
- No outbound push to carriers — polling/SSE is the caller's side.
- No mutable status field — state is derived, always.

## Requirements

**Functional**

- Register a shipment; ingest a batch of tracking events scoped to it.
- Read shipment state, current ETA, and the full event timeline.
- Authenticate callers per carrier; scope writes to the caller's own
  shipments.
- Reject duplicate submissions by client-supplied `event_id`.
- Surface backpressure as `429` + `Retry-After`, never silent lag.

**Non-functional**

- Sustain 2k events/s ingestion; absorb 10k/s bursts up to 5 minutes.
- P95 read latency < 300 ms at ~500k active shipments.
- Ack (`202`) only after durable queueing — an acked event is never
  lost to an API crash.
- Operable by one small team — no mechanism that pages for
  self-healing conditions.

## Dependencies

- PostgreSQL — shipments, events, folded projections, queue table.
- Job queue (PG table) — durable event handoff to the worker.
- Redis — rate-limit counters ([ADR-0002](../../adr/0002-redis-rate-limit-state.md));
  request-path dependency, fails open.

## Risks and mitigations

- A partner bursts beyond fair share → per-tenant token buckets landing
  in [the rate-limit plan](../../plan/api-rate-limits/); until it
  finishes, tracked as [issue 0001](../../issues/0001-api-no-backpressure.md).
- Redis on the request path → fail-open on outage; HA pair in the
  plan's phase 2.
