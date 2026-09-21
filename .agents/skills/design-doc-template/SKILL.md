---
name: design-doc-template
description: >-
  Create or extend the design-doc skill's per-scale conventions,
  templates, and worked examples — how to distill a reference project's
  documentation approach into a generic template without leaking its
  internals. Use when adding a new scale or changing what a scale's docs
  should look like. For writing a design doc for a real project, use the
  design-doc skill instead.
metadata:
  author: Nyarducks
  license: MIT
  url: https://github.com/Nyarducks/DesignDoc
---

# Design doc template authoring

This repo packages design-doc conventions per project scale into the
`design-doc` skill. This skill covers **authoring** that material —
studying a reference project and distilling its conventions into a
generic template.

The canonical rules live in the repo root `CONTRIBUTING.md`; this skill
is the agent-facing procedure. The short version:

- **Nothing from a reference repo appears in a deliverable — including
  its identity.** No repo names or links, project or module names, file
  paths, PR/issue links, hostnames, schemas, business logic, or
  security-posture details.
- `templates/` and `docs/example/` use **fictional projects** — invented
  names, paths, and links only.
- The `design-doc` skill is the mirror image: at doc-writing time the
  target repo's real details *are* the content. The no-leak rule applies
  to template authoring only.

## Procedure

1. Read the reference repo's doc surface — overview docs, per-component
   docs, plans/proposals, decision records, generated or agent-facing
   docs. Use `gh` for GitHub repos.
2. Map what you find onto the doc kinds (living / proposal / decision /
   reference / generated) and confirm the scale fit.
3. Write the conventions generically — describe the pattern, never the
   content.
4. Ship the three deliverables per `CONTRIBUTING.md`: a `SKILL.md`
   section, a `templates/<scale>/` tree, and a fictional
   `docs/example/<scale>/` — then update the scale table.
5. Verify every file renders: frontmatter parses as YAML, mermaid blocks
   are valid, no `<placeholders>` inside diagram syntax.
