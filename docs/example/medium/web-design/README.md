---
type: Design Doc
title: Freightloop dashboard design
description: The web module's design hub — app-level conventions plus the index of per-route docs.
status: current
last_modified: 2026-09-22
tags: [frontend]
sources: [web/]
adrs: []
issues: []
---

# Freightloop dashboard design

## Context

Dispatch teams keep the dashboard open all shift on aging depot
hardware, often behind congested site Wi-Fi. Their decisions ("reroute
this truck, call that depot") are made in seconds off stale-risky data —
freshness and degraded-mode honesty matter more than visual polish.

## Goal

The ops dashboard — a dispatch team's live view of every active
shipment: where it is, whether it's late, and who to call.

## Conventions

Each convention is a decision with its reasoning.

- **Data fetching** — one API client (`web/src/api/`); routes declare
  queries, components never fetch directly. Centralized so cache and
  retry policy live in one place — a screen can't accidentally invent
  its own staleness rules.
- **State model** — server state lives in query cache; local UI state
  (filters, selection) lives in the route. A global store was rejected:
  the app has no cross-route mutations worth its complexity.
- **Permissions** — routes gate by role (`dispatcher`, `viewer`); the
  API enforces, the UI only hides. Hiding is UX, not security — no
  client-side check is ever load-bearing.
- **Live updates** — shipment state pushes over SSE; polling is the
  documented fallback, never silent. WebSockets were rejected: updates
  are unidirectional, and sticky-connection ops cost isn't justified.

## In this directory

| Doc | Route | Surface |
|---|---|---|
| [tracking-map.md](tracking-map.md) | `/shipments` + `/shipments/:id` | Live map, timeline, delay alerts |

One doc per route — a screen's states, data dependencies, and the
decisions behind them. Visual specs live in the components.
