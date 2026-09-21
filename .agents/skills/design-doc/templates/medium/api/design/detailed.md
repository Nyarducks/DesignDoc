---
type: Design Doc
title: <Service> API — detailed design
description: "詳細設計 — per-resource internals: contract detail, lifecycle, request flow, failure modes."
status: current
last_modified: <YYYY-MM-DD>
tags: [api, design]
sources: [<handler/router paths>]
adrs: []
issues: []
---

# <Service> API — detailed design

詳細設計 — per-resource internals. Scope and targets live in
[requirements.md](requirements.md); surface-wide conventions live in
[basic.md](basic.md). One `##` section per contract surface.

## <Resource>

Surface: `<base path>` — callers: <key scopes / audiences>

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

### Decisions and alternatives

<Each significant choice on this surface with the alternative it beat
and why; link the ADR or plan that settled it for the full analysis.>

- **<decision>** over <rejected alternative> — <why>
  ([ADR-NNNN](../../adr/NNNN-<slug>.md))

### Failure modes

| Dependency fails | Caller sees |
|---|---|
| <dependency> | <observable behavior; what retries are safe> |

### Security

<Auth scope per endpoint; data one caller must never see — only what
this resource adds beyond the surface conventions.>

### Testing

<What the suite covers for this surface — contract cases, idempotency,
lifecycle transitions.>
