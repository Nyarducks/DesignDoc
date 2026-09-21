---
type: Reference
title: Feedping — ADR index
description: Architecture decision records for Feedping — numbered point-in-time decisions, one file each.
status: current
last_modified: 2026-09-20
tags: [adr]
sources: []
---

# Architecture decision records

ADRs record significant decisions in Context / Decision / Consequences
form, numbered sequentially as `NNNN-<slug>.md`, with OKF v0.2 frontmatter
(`type: ADR`, `status`, `last_modified`). Immutable point-in-time records —
write a new ADR when a decision is revisited.

| ADR | Decision |
|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions — this convention itself |
| [0002](0002-json-state-store.md) | Keep state in an atomic JSON file, not an embedded DB |
