---
type: Design Doc
title: Freightloop API design
description: The API module's design hub — index of the requirements / basic / detailed design docs.
status: current
last_modified: 2026-09-22
tags: [api]
sources: [api/]
adrs: [0002]
issues: [0001]
---

# Freightloop API design

One REST surface for two audiences: carrier integrations pushing
tracking events, and the ops dashboard reading shipment state.

| Doc | Stage | Contents |
|---|---|---|
| [requirements.md](requirements.md) | Requirements | Overview, background, goals/non-goals, functional and non-functional requirements |
| [basic.md](basic.md) | Basic design | System architecture, surface-wide conventions, contract inventory, data model, surface-level decisions |
| [detailed.md](detailed.md) | Detailed design | Per-resource internals — contract detail, lifecycle, request flow, failure modes, per-resource decisions |
