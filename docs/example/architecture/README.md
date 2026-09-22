---
type: Reference
title: Freightloop — architecture docs
description: Living docs for Freightloop's current state — one directory per module, updated in the same commit as the code they describe.
status: current
last_modified: 2026-09-22
tags: [architecture]
sources: []
---

# Architecture docs

Living docs — they describe the system **as it is now** and stay bound
to the code by the `sources:` contract (a commit that changes a
declared source updates the doc in the same commit). Proposals for
changes live in [../design-docs/](../design-docs/), not here.
*(Fictional example — the Freightloop project.)*

## Shape

- **`<module>/`** — one directory per module: `README.md` is the
  module hub (context, invariants, surface-wide conventions, the index
  of its docs); each `<topic>.md` documents one unit of change — a
  contract surface, a route, a mechanism.

Name docs after the thing they describe, never after a document tier —
a change should touch one doc, not the same section in three.
