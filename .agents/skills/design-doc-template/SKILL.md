---
name: design-doc-template
description: >-
  Create or extend the design-doc skill's per-scale conventions,
  templates, and worked examples — how to distill a reference project's
  documentation approach into a generic template without leaking its
  internals. Use when adding a new scale or changing what a scale's docs
  should look like. For writing a design doc for a real project, use the
  design-doc skill instead.
---

# Design doc template authoring

This repo packages design-doc conventions per project scale into the
`design-doc` skill. This skill covers **authoring** that material —
studying a reference project and distilling its conventions into a
generic template.

## Confidentiality — the hard rule

A reference repo is read for **conventions only**. Nothing inside it may
appear in a deliverable:

- No real project or module names, file paths, PR/issue links, hostnames,
  schemas, business logic, or security-posture details.
- Naming the repo as the source — "conventions distilled from
  `owner/repo`" in `SKILL.md`/`AGENTS.md` — is the only permitted
  reference: attribution, not content.
- `templates/` and `docs/example/` use **fictional projects** — invented
  names, paths, and links only.

The `design-doc` skill is the mirror image: at doc-writing time the
target repo's real details *are* the content. The no-leak rule applies to
template authoring only — never strip real content out of a design doc
being written for an actual project.

## What to distill (and what to leave)

- **Distill** — doc kinds and their directories, section anatomy,
  metadata conventions, status/review workflow, update discipline,
  multi-repo handling.
- **Leave behind** — anything that answers "what does their system do"
  rather than "how do they document".

## Per-scale deliverables

Each scale ships three things:

1. A section in `.agents/skills/design-doc/SKILL.md` — the conventions,
   naming the reference repo.
2. `.agents/skills/design-doc/templates/<scale>/` — a copy-ready tree
   mirroring the target `docs/` layout.
3. `docs/example/<scale>/` — the template applied to a fictional project,
   marked as such.

Then update the scale table in `SKILL.md` and the "scales so far" line in
`AGENTS.md`.

## Procedure

1. Read the reference repo's doc surface — overview docs, per-component
   docs, plans/proposals, decision records, generated or agent-facing
   docs. Use `gh` for GitHub repos.
2. Map what you find onto the doc kinds (living / proposal / decision /
   reference / generated) and confirm the scale fit.
3. Write the conventions generically — describe the pattern, never the
   content.
4. Build the template tree, then verify every file renders: frontmatter
   parses as YAML, mermaid blocks are valid, no `<placeholders>` inside
   diagram syntax.
5. Write the fictional worked example end-to-end — it is what reviewers
   judge the scale by.
