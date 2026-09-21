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

## Goal

The ops dashboard — a dispatch team's live view of every active
shipment: where it is, whether it's late, and who to call.

## Conventions

- **Data fetching** — one API client (`web/src/api/`); routes declare
  their queries, components never fetch directly.
- **State model** — server state lives in query cache; local UI state
  (filters, selection) lives in the route.
- **Permissions** — routes gate by role (`dispatcher`, `viewer`); the
  API enforces, the UI only hides.
- **Live updates** — shipment state pushes over SSE; polling is a
  fallback for degraded connections only.

## In this directory

| Doc | Route | Surface |
|---|---|---|
| [tracking-map.md](tracking-map.md) | `/shipments` + `/shipments/:id` | Live map, timeline, delay alerts |

One doc per route — a screen's states and data dependencies. Visual
specs live in the components; these docs carry behavior and data
contracts.
