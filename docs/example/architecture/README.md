---
type: Reference
title: Freightloop — architecture docs
description: Living docs for Freightloop's current state — one directory per service, updated in the same commit as the code they describe.
status: current
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

- **`<service>/`** — one directory per service or coherent subsystem
  (`api`, `web`, `worker`, `infra`): `README.md` is the hub (context,
  invariants, surface-wide conventions, the index of its docs); each
  `<topic>.md` documents one unit of change — a contract surface, a
  route, a mechanism.
- A cross-cutting policy that outgrows a hub's Conventions section gets
  its own file — e.g. `error-handling.md`, `authentication.md`.
- **[`glossary.md`](glossary.md)** — ubiquitous domain terms; design
  docs link to it rather than redefining, and a term a proposal
  introduces is promoted here when the change ships.
- **[`tags.json`](tags.json)** — the controlled tag vocabulary for
  `tags:` frontmatter across `docs/`: each entry maps a tag to its
  meaning. Define a tag here before using it, so `grep -rl 'api'` hits
  stay meaningful.

Name docs after the thing they describe, never after a document tier —
a change should touch one doc, not the same section in three. Docs
record behavior and decisions — never field lists or payloads; link
the schema file and list it in `sources:` instead.
