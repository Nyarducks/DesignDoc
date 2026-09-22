---
type: Architecture
title: <Component>
description: <One line — the component's responsibility and boundary.>
status: current
tags: [architecture, <component>]
sources: [<paths this doc is derived from>]
adrs: []
issues: []
---

# <Component>

<!-- What this component does, its boundary — what it owns, what it
deliberately doesn't. -->

## Context

<!-- Objective facts that constrain the component — request volume, data
size, latency budget, team. Facts only. -->

## Design

<!-- How it works at the invariant level — the rules that must hold no
matter how the code is refactored. Mermaid where a diagram beats
prose. -->

```mermaid
flowchart LR
    %% replace with the real flow, or drop the diagram
    In --> Process --> Out
```

## Decisions and alternatives

<!-- Each significant choice with the alternative it beat and why. -->

- **<decision>** over <rejected alternative> — <why>
  ([ADR-NNNN](../adr/NNNN-<slug>.md))

## Known issues

- <Limit or hole specific to this component> — filed in
  [issues/](../issues/) when actionable.
