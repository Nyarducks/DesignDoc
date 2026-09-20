---
type: Issue
title: A single huge import occupies a worker for minutes
description: No fair scheduling between job types — one 100k-row import starves syncs and reports.
status: planned
last_modified: 2026-09-20
tags: [issue, worker, scheduling]
sources: [worker/runner/]
---

# A single huge import occupies a worker for minutes

## Problem

The runner claims jobs strictly by arrival order within a worker; one
100k-row import holds that worker until done. Syncs and reports enqueued
behind it wait minutes even though they're seconds of work.

## Evidence

Job claiming is `FOR UPDATE SKIP LOCKED` in arrival order — see
[../design/worker.md](../design/worker.md). No per-type concurrency or
preemption exists.

## Impact

Supplier syncs and scheduled reports slip unpredictably whenever a big
import lands; operators see "stuck" dashboards.

## Options

- Per-type worker pools (import workers vs sync workers) — simplest
  fairness, needs pool sizing config.
- Batch-interleaved scheduling — fairer, but complicates checkpointing.

## Resolution

Scheduled under the [bulk-import plan](../plan/bulk-import/) — pool
split lands with Phase 2.
