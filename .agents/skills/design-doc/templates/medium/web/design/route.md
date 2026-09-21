---
type: Design Doc
title: <Route name>
description: <One line — what the screen does and who uses it.>
status: current
last_modified: <YYYY-MM-DD>
tags: [frontend, <route>]
sources: [<route/component/api-client paths>]
adrs: []
issues: []
---

# <Route name>

Route: `<path>` — permission: <role/scope>

## Goal

<What the user accomplishes on this screen.>

## Contract

- **Data in** — <queries/endpoints the route depends on>
- **States** — loading / empty / error / ready: <what each shows>
- **Actions** — <what the user can trigger; which API calls>

## Interactions

```mermaid
sequenceDiagram
    %% replace with the real flow, or drop the diagram if prose suffices
    participant U as User
    participant R as Route
    participant A as API
    U->>R: open
    R->>A: fetch
    A-->>R: data
```

## Key decisions

- <Decision> — see [ADR-NNNN](../../adr/NNNN-<slug>.md)

## Security

<What a user without permission sees; what the route must never render.>

## Known issues

- <Limits and holes specific to this route.>
