---
type: Design Doc
title: <Component name>
description: <One line — the component's responsibility and role.>
status: current
last_modified: <YYYY-MM-DD>
tags: [<topics>]
sources: [<implementation files this doc is derived from>]
---

# <Component name>

## Goal

<The component's responsibility and purpose — one paragraph.>

## Design

<Internal spec and processing flow at the invariant level — data
structures, algorithms, lifecycle. Use a mermaid sequence diagram for
interactions, a flowchart for branching logic — wherever a diagram beats
prose.>

```mermaid
sequenceDiagram
    %% replace with the real flow
    participant A as Caller
    participant B as Component
    A->>B: request
    B-->>A: response
```

## Key decisions

- <Decision> — see [ADR-NNNN](../adr/NNNN-<slug>.md)

## Security

<Trust boundary and enforcement mechanism, if any.>

## Known issues

- <Limits and holes specific to this component.>

## Testing

<Commands and what they cover.>

## Notes

<Caveats that don't fit elsewhere.>
