---
type: Architecture
title: <Service name>
description: <One line — what the service does and its boundary.>
status: current
tags: [<service>, architecture]
sources: [<service paths>]
adrs: []
issues: []
---

# <Service name>

<!-- What this service does, its boundary — what it owns, what it
deliberately doesn't — and how it relates to its neighbors. -->

## Context

<!-- Objective facts that constrain the service — load, data size, latency
budget, who operates it. Facts only; decisions go below. -->

## Goals and non-goals

- **Goals** — <!-- outcomes the service must deliver -->
- **Non-goals** — <!-- reasonable-seeming scope deliberately excluded -->

## Design

<!-- How it works at the invariant level — components, data flow, the rules
that must hold no matter how the code is refactored. Mermaid where a
diagram beats prose; link code for the mechanics. -->

## Interfaces

<!-- What this service exposes and consumes — its own contract surfaces
(endpoints, jobs, events) and the dependencies it calls. Link the
detailed API docs rather than duplicating them. -->

## Decisions and alternatives

<!-- Each significant choice with the alternative it beat and why; link
the ADR or design doc that settled it. -->

- **<decision>** over <rejected alternative> — <why>
  ([ADR-NNNN](../../adr/NNNN-<slug>.md))

## Observability

<!-- Metrics, logs, dashboards, alerts specific to this service; where to
look first when it misbehaves. -->

## Scaling

<!-- Ceilings, headroom, and what breaks first at the limit. -->

## Known issues

- <Limits and holes specific to this service> — filed in
  [../../issues/](../../issues/) when actionable.
