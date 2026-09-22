---
type: Issue
title: ETA model drifts during carrier-wide delays
description: Weather events and strikes delay whole fleets at once; the ETA model keeps predicting per-shipment and drifts badly during correlated delays.
status: open
tags: [issue, worker, eta]
sources: [worker/pipeline/]
resolved_by:
---

# ETA model drifts during carrier-wide delays

## Problem

The ETA model scores each shipment independently. During carrier-wide
disruptions — weather, strikes — every ETA is off in the same direction
at once, and the dashboard reads optimistic for days.

## Impact

Ops teams stop trusting ETAs exactly when they need them most; alert
thresholds tuned for independent error flood or stay silent.

## Resolution

_Not scheduled._
