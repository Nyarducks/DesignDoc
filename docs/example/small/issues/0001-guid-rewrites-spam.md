---
type: Issue
title: Feeds that rewrite guids spam the channel once
description: Publishers that mint fresh guids per entry defeat the dedupe key and re-post old entries.
status: open
last_modified: 2026-09-20
tags: [issue, poller]
sources: [internal/poller/poller.go]
---

# Feeds that rewrite `guid`s spam the channel once

## Problem

Some publishers regenerate `guid` on every publish. The poller's dedupe
key prefers `guid`, so every previously-seen entry looks new and the
whole feed re-posts to the channel once.

## Evidence

Dedupe-key order is `guid → link → hash(title+published)` — see
[../design/poller.md](../design/poller.md). With unstable `guid`s the
first leg never matches; `link` is never tried.

## Impact

One channel flood per offending feed, then it settles. Annoying but
self-limiting — no state corruption.

## Options

- Detect `guid` churn (N consecutive full misses) and demote the feed to
  `link`-keyed dedupe — cheap heuristic, fixes the common case.
- Per-feed `dedupe:` config override — explicit but puts burden on the
  user.

## Resolution

_Not scheduled._
