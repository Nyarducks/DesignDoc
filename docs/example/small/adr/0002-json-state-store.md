---
type: ADR
title: Keep state in an atomic JSON file, not an embedded DB
description: Last-seen markers persist to a single JSON file written via tmp+rename; no SQLite dependency.
status: accepted
last_modified: 2026-09-20
tags: [persistence, state]
---

# ADR-0002: Keep state in an atomic JSON file, not an embedded DB

## Status

Accepted

## Context

Feedping needs one durable value per feed (the last-seen marker). Options:
an embedded DB (SQLite/BoltDB), a directory of marker files, or a single
JSON file. The state is a map with tens of keys, read once at startup and
written once per poll cycle — far below what a DB is for.

## Decision

State lives in one JSON file, written atomically via tmp-file + fsync +
rename. No embedded database dependency.

## Consequences

- The state file is human-readable and diffable in git if users check it
  in.
- A torn write can't corrupt the store — worst case is re-posting a few
  entries, which the dedupe key tolerates poorly but chat survives.
- If state ever needs queries or concurrent writers, revisit with an
  embedded DB — this ADR does not cover that world.
