---
type: Architecture
title: <Mechanism>
description: <One line — what the mechanism does and when it matters.>
status: current
last_modified: <YYYY-MM-DD>
tags: [infra, <topic>]
sources: [<manifest/terraform/config paths>]
services: [<service names this mechanism affects>]
---

# <Mechanism>

## Context

<!-- Objective facts that constrain this mechanism — load numbers, SLOs it
must hold, cost budget, team size that operates it. Facts only. -->

## Goal

<!-- What the mechanism provides and why it exists. -->

## Design

<!-- How it works at the invariant level — triggers, feedback loops.
Mermaid where a diagram beats prose. -->

## Failure modes

<!-- What breaks, in what order, under load or dependency loss — and what
the mechanism does about each (degrade, page, fail open/closed). -->

## Decisions and alternatives

<!-- Each significant choice with the alternative it beat and why — e.g.
why this tool/primitive and not the one a reader would expect. -->

- **<decision>** over <rejected alternative> — <why> (settled by
  [ADR-NNNN](../../adr/NNNN-<slug>.md) / the design doc that shipped it)

## Service impact

| Change to this mechanism | Services affected | Blast radius |
|---|---|---|
| <e.g. threshold tuning> | <api, worker> | <latency / availability / data> |

`services:` in frontmatter names the same set — tools can walk it.

## Observability

<!-- Metrics and alerts specific to this mechanism; where to look first
when it misbehaves. -->

## Scaling

<!-- Ceilings, headroom, and what breaks first at the limit. -->

## Known issues

- <Limits and holes specific to this mechanism.>
