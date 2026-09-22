---
type: Reference
title: Architecture docs
description: Living docs for the system as it is — one directory per service, updated in the same commit as the code they describe.
status: current
last_modified: <YYYY-MM-DD>
tags: [architecture]
sources: []
---

# Architecture docs

Living docs — they describe the system **as it is now** and stay bound
to the code by the `sources:` contract (a commit that changes a
declared source updates the doc in the same commit). Proposals for
changes live in [../design-docs/](../design-docs/), not here; an ADR in
[../adr/](../adr/) records a decision, not the current state.

## Shape

- **`<service>/`** — one directory per service or coherent subsystem:
  `README.md` is the hub (context, invariants, surface-wide
  conventions, the index of its docs); each `<topic>.md` documents one
  unit of change — a contract surface, a route, a mechanism.
- **`<component>.md`** — when a part of the system is small enough that
  one file says it, keep it flat alongside the service dirs; when it
  grows several docs, promote it to a directory named after it.
- A cross-cutting policy that outgrows a hub's Conventions section gets
  its own file — e.g. `error-handling.md`, `authentication.md`.
- **`glossary.md`** — ubiquitous domain terms; design docs link to it
  rather than redefining, and a term a proposal introduces is promoted
  here when the change ships.

Name docs after the thing they describe, never after a document tier —
a change should touch one doc, not the same section in three. Docs
record behavior and decisions — never field lists or payloads; link
the schema file and list it in `sources:` instead.
