---
type: Design Doc
title: <Mechanism>
description: <One line — what the mechanism does and when it matters.>
status: current
last_modified: <YYYY-MM-DD>
tags: [infra, <topic>]
sources: [<manifest/terraform/config paths>]
services: [<service names this mechanism affects>]
---

# <Mechanism>

## Goal

<What the mechanism provides and why it exists.>

## Design

<How it works at the invariant level — triggers, feedback loops,
failure modes. Mermaid where a diagram beats prose.>

## Service impact

| Change to this mechanism | Services affected | Blast radius |
|---|---|---|
| <e.g. threshold tuning> | <api, worker> | <latency / availability / data> |

`services:` in frontmatter names the same set — tools can walk it.

## Observability

<Metrics and alerts specific to this mechanism; where to look first
when it misbehaves.>

## Scaling

<Ceilings, headroom, and what breaks first at the limit.>

## Known issues

- <Limits and holes specific to this mechanism.>
