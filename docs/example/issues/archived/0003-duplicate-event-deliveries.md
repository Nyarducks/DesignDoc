---
type: Issue
title: Duplicate event deliveries on client retry
description: Carriers retrying a timed-out POST could double-enqueue an event batch — same shipment event appeared twice on timelines.
status: done
last_modified: 2026-08-30
tags: [issue, api, ingestion]
sources: [api/internal/handlers/shipments.go]
resolved_by: "#58"
---

# Duplicate event deliveries on client retry

## Problem

A carrier POST that timed out after enqueue looked like a failure to the
sender; the retry re-enqueued the same batch. Timelines showed duplicate
events until a daily compaction job merged them.

## Resolution

Resolved via #58 — the events endpoint now takes an
`Idempotency-Key` header and dedupes on it for 24h.
