---
type: Issue
title: API has no backpressure on ingestion bursts
description: Partner integrations can send unbounded event bursts; the API accepts everything and the queue absorbs the damage.
status: in-progress
tags: [issue, api, reliability]
sources: [api/internal/handlers/shipments.go]
resolved_by: ../design-docs/0002-api-rate-limits/
---

# API has no backpressure on ingestion bursts

## Problem

Any partner key can push events at unlimited rate. The API accepts and
enqueues every batch — the queue grows, workers saturate, and ingest lag
for *every* carrier degrades.

## Evidence

- `api/internal/handlers/shipments.go` — the events endpoint validates
  and enqueues unconditionally; there is no quota check anywhere in the
  request path.
- 2026-09-08 incident: one carrier's retry loop pushed ~40k events in
  3 minutes; fleet-wide ingest lag hit 4 minutes.

## Impact

A single misbehaving partner degrades the shared SLO (ingest lag < 30 s)
for every carrier — a noisy-neighbor failure with no mitigation today.

## Options

- **Per-tenant token bucket in the API** — reject with 429 + `Retry-After`
  over quota; needs shared counter state across pods (see
  [ADR-0002](../adr/0002-redis-rate-limit-state.md)).
- **Queue-level shedding** — cheaper, but drops already-accepted work
  and punishes well-behaved tenants equally.

## Resolution

Scheduled as [design doc 0002](../design-docs/0002-api-rate-limits/) — phase 1
lands the token bucket; phase 2 surfaces usage in the dashboard and
makes the counter store HA.
