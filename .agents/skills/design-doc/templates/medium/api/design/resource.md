---
type: Design Doc
title: <Resource> API
description: <One line — the contract surface and who consumes it.>
status: current
last_modified: <YYYY-MM-DD>
tags: [api, <resource>]
sources: [<handler/router paths for this resource>]
adrs: []
issues: []
---

# <Resource> API

## Goal

<What callers can do with this surface — the resource lifecycle in one
paragraph.>

## Contract

| Endpoint | Verb | Effect |
|---|---|---|
| `<path>` | <GET/POST/…> | <what it does> |

<Contract-level rules callers rely on — ownership scoping, state
transitions, visibility rules. Not a schema dump; link the spec.>

## Invariants

- <e.g. writes are idempotent by client-supplied key; list endpoints
  paginate by cursor; soft-deleted records never appear in lists>

## Errors

| Status | When |
|---|---|
| <code> | <condition> |

## Key decisions

- <Decision> — see [ADR-NNNN](../../adr/NNNN-<slug>.md)

## Security

<Auth scope per endpoint; data one caller must never see.>

## Known issues

- <Limits and holes specific to this surface.>
