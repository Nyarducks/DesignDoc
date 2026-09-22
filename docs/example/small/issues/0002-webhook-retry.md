---
type: Issue
title: No durable retry when the webhook is down
description: Delivery failures while the receiver is down are retried in memory only — a restart loses them.
status: investigating
last_modified: 2026-09-22
tags: [issue, webhook, reliability]
sources: [internal/poller/]
resolved_by:
---

# No durable retry when the webhook is down

## Problem

Failed deliveries retry in memory with backoff. If the process restarts
mid-backoff — or the receiver stays down past the cap — the notification
is silently lost.

## Impact

Rare but real: a deploy during a receiver outage drops pending
notifications.

## Resolution

_Not scheduled._
