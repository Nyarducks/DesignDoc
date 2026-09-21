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

Surface: `<base path>` — callers: <key scopes / audiences>

<One line of scope. The surface-level overview, background, and
goals/non-goals live in [README.md](README.md) — this doc starts at the
detailed design for its resource.>

## Detailed design

### Contract

| Endpoint | Verb | Effect |
|---|---|---|
| `<path>` | <GET/POST/…> | <what it does> |

<Contract-level rules callers rely on — ownership scoping, visibility
rules. Not a schema dump; link the spec.>

| Status | When |
|---|---|
| <code> | <condition> |

### Data model

<The resource's lifecycle as a state machine — states, transitions,
terminal states, who triggers each — plus how the data is shaped
(append-only log, projection) where it shapes the contract. Mermaid
stateDiagram when the states aren't trivial.>

### Request flow

<How a call traverses the system — what's synchronous vs async, where
state changes land. A sequence diagram where it beats prose.>

## Decisions and alternatives

<Each significant choice, stated with the alternative it beat and why —
one or two lines each. Link the ADR or plan that settled it for the
full analysis; the doc still shows the reasoning.>

- **<decision>** over <rejected alternative> — <why the trade-off lands
  this way given the goals> (settled by [ADR-NNNN](../../adr/NNNN-<slug>.md))

## Failure modes

<What each dependency failure looks like to the caller — which endpoints
degrade, what error surfaces, what retries are safe. Table form.>

## Security

<Auth scope per endpoint; data one caller must never see.>

## Risks and mitigations

- <open risk on this surface> — <mitigation>; actionable items get a row
  in [../../issues/](../../issues/).

## Testing

<What the suite covers for this surface — contract cases, idempotency,
lifecycle transitions.>
