---
type: Architecture
title: Freightloop API — error handling
description: The shared error contract — problem-shape envelope, status taxonomy, and caller retry rules. Per-surface docs link here instead of restating it.
status: current
tags: [api, errors]
sources: [api/internal/errors/, api/openapi.yaml]
adrs: []
issues: []
---

# Error handling

One error contract across every surface — partner SDKs key retries off
it, so the shape and the status semantics are load-bearing.
*(Fictional example — the Freightloop project.)*

## Envelope

Every non-2xx response is an RFC 9457 problem shape:

| Field | Content |
|---|---|
| `type` | URI identifying the error class |
| `title` | Short human summary — stable per `code` |
| `status` | HTTP status, mirrored |
| `detail` | Instance-specific explanation |
| `code` | Stable machine key — SDKs branch on this, never on `title` |

`code` values are an API contract: adding one is additive, renaming or
removing one is a breaking change and needs a new version prefix.

## Status taxonomy

| Status | Meaning | Retryable |
|---|---|---|
| 401/403 | Missing key, or key not scoped to the resource | No — fix credentials/scope |
| 404 | Unknown shipment ID | No |
| 409 | Duplicate `event_id` — the write already landed | Success-equivalent; safe to ignore |
| 422 | Malformed payload | No — fix the request |
| 429 | Tenant over rate limit | Yes — after `Retry-After` |
| 503 | Queue unavailable — nothing was applied | Yes — retry the whole batch after `Retry-After` |

## Retry rules

- Transient statuses (429, 503) always carry `Retry-After`; callers
  honor it verbatim, no exponential backoff on top.
- 4xx other than 429 is never retryable — the request, not the timing,
  is wrong.
- A retried batch is safe end to end: `event_id` dedupes at write, so
  redelivery is a no-op (see [shipments.md](shipments.md)).

## Failure modes

| Failure | Caller sees |
|---|---|
| Rate limiter can't reach Redis | Requests pass through (fail-open) — no error surfaced |
| Queue unavailable | `503` + `Retry-After`; nothing partially applied |

## Decisions and alternatives

- **RFC 9457 problem shape** over ad-hoc `{error: "msg"}` — partner SDKs
  key retries off a stable `code`; a free-text message can't serve as
  one.
- **`409` for duplicate `event_id`** over `200` — the duplicate is worth
  surfacing in client metrics even though it's success-equivalent.
