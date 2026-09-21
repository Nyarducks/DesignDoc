---
type: Design Doc
title: Freightloop API design
description: The API module's design hub — surface-wide conventions plus the index of per-resource docs.
status: current
last_modified: 2026-09-22
tags: [api]
sources: [api/]
adrs: [0002]
issues: [0001]
---

# Freightloop API design

## Context

Two caller classes share one surface: carrier integrations pushing
events (many on legacy bridges that can only POST), and the ops
dashboard reading state. Sustained ingestion is ~2k events/s with 10k/s
hourly bursts; every convention below exists because some caller or
volume constraint forced it.

## Goal

One REST surface for both audiences. Every external interaction with
Freightloop goes through here — no direct database access, ever.

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

## In this directory

| Doc | Contract surface |
|---|---|
| [shipments.md](shipments.md) | Shipment lifecycle + tracking event ingestion |

One doc per contract surface — a resource's CRUD family or one endpoint
group. Schemas live in `api/openapi.yaml`; these docs carry the
invariants and decisions a caller relies on.
