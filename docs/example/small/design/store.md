---
type: Design Doc
title: Store — last-seen persistence
description: How per-feed last-seen markers are persisted in a single local file with atomic writes.
status: current
last_modified: 2026-09-20
tags: [store, persistence]
sources: [internal/store/store.go, internal/store/store_test.go]
---

# Store

## Goal

Persist the per-feed last-seen marker so a restart never re-posts entries
— durable enough for a cron-driven CLI, simple enough to inspect by hand.

## Design

One JSON file maps feed URL → `{ dedupe key, timestamp }`. Writes are
atomic: serialize to `state.json.tmp`, `fsync`, `rename` over
`state.json`. A crash mid-write leaves the previous file intact —
re-posting a handful of entries is preferable to a corrupt store.

Reads happen once at startup; the in-memory map is authoritative during
the run and flushed after each feed's entries are posted.

## Key decisions

- JSON file over SQLite — see [ADR-0002](../adr/0002-json-state-store.md).

## Known issues

- The file grows by one entry per feed — bounded by feed count, not
  entries seen.
- Two concurrent `feedping` processes would interleave writes; the
  accepted fix is "don't run two".

## Testing

`internal/store` tests cover round-trip persistence, atomic-rename
recovery from a torn `.tmp`, and concurrent map access.
