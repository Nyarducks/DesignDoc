---
type: Plan
title: Tracking events v2 schema
description: Migrated the event payload to schema v2 — carrier-specific fields moved into a typed detail map.
status: done
last_modified: 2026-09-22
tags: [plan, api, events]
issues: []
designs: [api-design/detailed]
---

# Tracking events v2 — Overview

Replaced the free-form `payload` blob on tracking events with schema v2:
a fixed envelope plus a typed `details` map per event kind. Single-PR
change — this file is the whole plan. **Delivered via #74.**

## Context

Carriers stuffed vendor-specific fields into `payload`, making ingestion
validation a guessing game and the timeline UI dependent on undocumented
keys.

## What shipped

- `event_id`, `kind`, `occurred_at`, `details` envelope in
  `POST /v1/shipments/{id}/events`.
- Old payloads rejected with 422 + a pointer to the v2 shape; carriers
  migrated over a two-week window coordinated out-of-band.

## Notes for future readers

- v1 requests fail loudly by design — there is no compat shim to
  remove later.
- The worker's ETA pipeline reads only the envelope, so event kinds can
  grow without worker changes.
