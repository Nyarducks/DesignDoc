---
type: Reference
title: Freightloop — ADR index
description: Architecture decision records — numbered point-in-time decisions, one file each.
status: current
last_modified: 2026-09-22
tags: [adr]
sources: []
---

# Architecture decision records

ADRs record significant decisions in Context / Decision / Consequences
form, numbered sequentially as `NNNN-<slug>.md`, with OKF v0.2 frontmatter
(`type: ADR`, `status`, `last_modified`). Write one in the same commit as
the change that introduces the decision. ADRs are immutable point-in-time
records — write a new ADR when a decision is revisited. *(Fictional
example — the Freightloop project.)*

| ADR | Decision |
|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions — this convention itself |
| [0002](0002-redis-rate-limit-state.md) | Rate-limit counters live in shared Redis, not per-pod memory |
