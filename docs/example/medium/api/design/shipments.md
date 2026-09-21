---
type: Design Doc
title: Shipments API
description: Shipment CRUD and tracking-event ingestion — the contract surface carriers and the dashboard share.
status: current
last_modified: 2026-09-22
tags: [api, shipments, ingestion]
sources: [api/internal/handlers/shipments.go, api/internal/routes/v1.go]
adrs: []
issues: [0001]
---

# Shipments API

## Goal

Carriers register shipments and push tracking events; the dashboard and
integrations read shipment state and timelines. This surface is the only
write path for tracking data.

## Contract

| Endpoint | Verb | Effect |
|---|---|---|
| `/v1/shipments` | POST | Register a shipment; returns its ID |
| `/v1/shipments` | GET | List shipments (cursor-paginated, filtered) |
| `/v1/shipments/{id}` | GET | Shipment detail incl. current ETA |
| `/v1/shipments/{id}/events` | POST | Ingest tracking events (batch) |
| `/v1/shipments/{id}/events` | GET | Event timeline (cursor-paginated) |

- Events are scoped to the shipment in the path — a carrier key can only
  write to its own shipments.
- Event batches apply in arrival order; the server does not reorder by
  event timestamp (late events still count).

## Invariants

- `POST /events` is idempotent by the client-supplied `event_id` —
  retries never double-record.
- List endpoints paginate by cursor; `page_size` caps at 200.
- A shipment is `delivered` only via a `delivered` event — no direct
  status writes.

## Errors

| Status | When |
|---|---|
| 401/403 | Missing key, or key not scoped to the shipment's carrier |
| 409 | Duplicate `event_id` (safe to ignore on retry) |
| 422 | Malformed event payload |
| 429 | Tenant over rate limit — see [the rate-limit plan](../../plan/api-rate-limits/) |

## Key decisions

- Event ingestion stays synchronous-with-ack: the API validates and
  enqueues, the worker computes — keeps ingestion latency flat.

## Security

Carrier keys never see another carrier's shipments; dashboard reads are
role-scoped. Event payloads carry IDs, not PII.

## Known issues

- No backpressure — a partner can burst beyond fair share; tracked as
  [issue 0001](../../issues/0001-api-no-backpressure.md).
