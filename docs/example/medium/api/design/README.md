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

## Goal

One REST surface for two audiences: carrier integrations pushing
tracking events, and the dashboard reading shipment state. Every
external interaction with Freightloop goes through here.

## Conventions

- **Auth** — partner keys scoped per carrier (`events:write`,
  `shipments:read`); dashboard calls carry the user's SSO session.
- **Versioning** — path prefix (`/v1/`); breaking changes ship a new
  prefix, never a flag.
- **Errors** — RFC 9457 problem shape: `type`, `title`, `status`,
  `detail`, plus `code` for programmatic handling.
- **Pagination** — cursor-based on every list endpoint; `next_cursor`
  is null at the end.

## In this directory

| Doc | Contract surface |
|---|---|
| [shipments.md](shipments.md) | Shipment lifecycle + tracking event ingestion |

One doc per contract surface — a resource's CRUD family or one endpoint
group. Schemas live in `api/openapi.yaml`; these docs carry the
invariants a caller can rely on.
