---
type: Design Doc
title: <Resource> API
description: <One line — the contract surface and who consumes it.>
status: current
last_modified: <YYYY-MM-DD>
tags: [api, <resource>]
sources: [<handler/router paths for this resource>]
adrs: []
issues: []
---

# <Resource> API

## Context

<Objective facts that constrain this surface — who calls it, at what
volume, what the callers can and cannot do (legacy SDKs, retry
behavior), upstream systems it must fit. Facts only, no design yet.>

## Goal

<What callers can do with this surface — the resource lifecycle in one
paragraph.>

## Contract

| Endpoint | Verb | Effect |
|---|---|---|
| `<path>` | <GET/POST/…> | <what it does> |

<Contract-level rules callers rely on — ownership scoping, state
transitions, visibility rules. Not a schema dump; link the spec.>

## Lifecycle

<The resource's state machine — states, what transitions them, terminal
states, and who can trigger each. A mermaid stateDiagram when the states
aren't trivial.>

## Design

<How the surface works underneath at the invariant level — the data
model that backs it, the flow a request takes, where state lives.
The parts a reviewer needs to evaluate the decisions below, not an
implementation walkthrough.>

## Failure modes

<What each dependency failure looks like to the caller — which endpoints
degrade, what error surfaces, what retries are safe.>

## Decisions and alternatives

<Each significant choice, stated with the alternative it beat and why —
one or two lines each. Link the ADR or plan that settled it for the
full analysis; the doc still shows the reasoning.>

- **<decision>** over <rejected alternative> — <why the trade-off lands
  this way given the goals> (settled by [ADR-NNNN](../../adr/NNNN-<slug>.md))

## Errors

| Status | When |
|---|---|
| <code> | <condition> |

## Security

<Auth scope per endpoint; data one caller must never see.>

## Known issues

- <Limits and holes specific to this surface.>
