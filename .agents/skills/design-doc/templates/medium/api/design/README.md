---
type: Design Doc
title: <Service> API design
description: The API module's design hub — contract-level invariants plus the index of per-resource docs.
status: current
last_modified: <YYYY-MM-DD>
tags: [api]
sources: [<api module paths>]
adrs: []
issues: []
---

# <Service> API design

## Goal

<What this API surface exists for — who calls it and what it lets them
do. One paragraph.>

## Conventions

<Surface-wide invariants — authn/authz model, versioning rule, error
shape, pagination, idempotency. What every resource doc below assumes.>

## In this directory

| Doc | Contract surface |
|---|---|
| [<resource>](resource.md) | <resource lifecycle — one line> |

One doc per contract surface — a resource's CRUD family or one endpoint
group. Schemas live in the OpenAPI spec or handlers, not here — these
docs carry the invariants a caller can rely on.
