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

## Context

<Objective facts constraining the whole surface — who the callers are,
what they can and cannot do (legacy SDKs, firewall rules, retry
habits), volume and SLOs. These facts justify the conventions below.>

## Conventions

<Surface-wide choices — authn/authz model, versioning rule, error
shape, pagination, idempotency. Each convention is a decision: state it
with the constraint or rejected alternative that produced it ("cursor
pagination — offset is unstable under append-heavy writes"), not just
the rule.>

## In this directory

| Doc | Contract surface |
|---|---|
| [<resource>](resource.md) | <resource lifecycle — one line> |

One doc per contract surface — a resource's CRUD family or one endpoint
group. Schemas live in the OpenAPI spec or handlers, not here — these
docs carry the invariants a caller can rely on.
