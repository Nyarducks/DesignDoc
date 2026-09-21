---
type: Plan
title: Supplier sync retry
description: Retry a failed supplier sync with exponential backoff instead of waiting a full day for the next window.
status: done
last_modified: 2026-08-30
tags: [plan, sync]
issues: [0002]
designs: [worker]
---

# Supplier sync retry

*(Fictional example — an archived single-file plan.)*

| | |
|---|---|
| **Status** | Done — delivered via #98 |
| **Priority** | P1 |
| **Repository** | acme/stockpilot |
| **Depends on** | — |
| **Blocks** | — |
| **Pull request** | #98 |

## Problem

A supplier sync that misses its window — a timeout, a transient 5xx —
waits a full day for the next scheduled run (issue 0002).

## Evidence

`worker/jobs/sync.go` runs the sync on a fixed daily cron with no retry
path; a failed run only logs and exits.

## Impact

Stock levels drift for up to 24h on any transient supplier outage.

## Proposed change

1. On sync failure, enqueue a retry job with exponential backoff
   (1m → 30m cap, 5 attempts).
2. Mark the run's last-attempt outcome on the job record so operators
   can see give-up vs. retry-pending.

## Acceptance criteria

- A failed sync retries automatically and recovers within the backoff
  schedule.
- After the attempt cap, the job is marked failed and listed in the
  issues table as needing attention.

## Progress log

| Date | Change | By |
|---|---|---|
| 2026-08-14 | Plan drafted | @ops |
| 2026-08-30 | Merged via #98 | @ops |
