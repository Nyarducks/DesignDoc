---
type: ADR
title: Record architecture decisions
description: ADRs live in docs/adr/, numbered sequentially, with OKF v0.2 frontmatter.
status: accepted
last_modified: 2026-09-22
tags: [adr, process]
---

# ADR-0001: Record architecture decisions

## Status

Accepted

## Context

Design decisions were previously recorded only in PR bodies and commit
messages — hard to discover, and lost to squashed history. We need a
durable home for *why* the system is shaped the way it is.

## Decision

Every significant architectural decision is recorded as an ADR under
`docs/adr/NNNN-<slug>.md`, numbered sequentially, written in
Context / Decision / Consequences form with OKF v0.2 YAML frontmatter
(`type: ADR`). Design docs live under `docs/design-docs/` with the same frontmatter
convention. Both are updated in the same commit as the change they
describe.

## Consequences

- Decisions are discoverable and reviewable alongside the code.
- Small documentation overhead per change; the rule is enforced by
  `AGENTS.md`/`CONTRIBUTING.md`.
