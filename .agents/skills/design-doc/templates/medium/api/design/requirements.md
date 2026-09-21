---
type: Design Doc
title: <Service> API — requirements
description: 要件定義 — what the API surface must deliver, for whom, under what constraints.
status: current
last_modified: <YYYY-MM-DD>
tags: [api, requirements]
sources: []      # prescriptive — this doc defines targets, not derivations
adrs: []
issues: []
---

# <Service> API — requirements

要件定義 — the "what and why" for this surface. Design choices live in
[basic.md](basic.md) and [detailed.md](detailed.md); this doc defines
the targets they must satisfy.

## Overview

<What this API surface is for — who calls it and what it lets them do.
One paragraph.>

## Background and motivation

<Objective facts that constrain the surface — who the callers are, what
they can and cannot do (legacy SDKs, firewall rules, retry habits),
volume, upstream systems it must fit. Facts only; every requirement and
convention downstream should trace back to a fact here.>

## Goals and non-goals

### Goals

- <caller-observable outcomes the surface must deliver>

### Non-goals

- <reasonable-seeming scope deliberately excluded — e.g. a query
  language, bulk import, a second protocol>

## Requirements

**Functional**

- <what callers can do — each requirement observable from the outside:
  endpoints exist, writes are idempotent, errors carry a stable code>

**Non-functional**

- <the qualities and constraints — sustained/burst volume, latency and
  freshness SLOs, availability, operability limits>

## Dependencies

<What the surface is built on — datastores, queues, sibling services —
one line each, why it's on the critical path.>

## Risks and mitigations

- <open risk> — <mitigation>; actionable items get a row in
  [../../issues/](../../issues/).
