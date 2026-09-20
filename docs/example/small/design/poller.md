---
type: Design Doc
title: Poller — feed fetch and diff loop
description: How feeds are polled and new entries detected — the dedupe key and ordering guarantees.
status: current
last_modified: 2026-09-20
tags: [poller, feeds]
sources: [internal/poller/poller.go, internal/poller/poller_test.go]
---

# Poller

## Goal

Fetch each configured feed on its interval, detect entries newer than the
last-seen marker, and hand them to the notifier — without ever blocking on
a slow or dead feed.

## Design

```mermaid
sequenceDiagram
    participant T as Ticker
    participant P as Poller
    participant F as Feed
    participant S as Store
    participant N as Notifier

    T->>P: tick (per feed)
    P->>F: GET with ETag/Last-Modified
    F-->>P: 304 or feed body
    P->>P: diff entries vs last-seen
    P->>N: emit new entries, oldest first
    N-->>P: posted
    P->>S: advance last-seen
```

- **Dedupe key** — `guid` if present, else `link`, else a hash of
  `title+published`. The key, not the timestamp, decides "new".
- **Ordering** — new entries emit oldest-first so chat reads naturally.
- **Isolation** — each feed polls in its own goroutine with a per-request
  timeout; a hung feed can't starve the others.

## Key decisions

- File-based last-seen store instead of an embedded DB — see
  [ADR-0002](../adr/0002-json-state-store.md).

## Known issues

- Feeds that mint fresh `guid`s per entry (bad publishers) spam once,
  then settle — accepted, no special-casing.
- Conditional GET is skipped for feeds known to mishandle ETags.

## Testing

`internal/poller` tests cover the dedupe-key fallback order, oldest-first
emission, and timeout isolation between feeds.
