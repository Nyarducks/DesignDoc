---
name: design-doc-template
description: >-
  Create or extend the design-doc skill's conventions, templates, and
  worked example — how to distill a reference project's documentation
  approach into a generic template without leaking its internals. Use
  when changing what the shipped docs should look like. For writing a
  design doc for a real project, use the design-doc skill instead.
metadata:
  author: Nyarducks
  license: MIT
  url: https://github.com/Nyarducks/DesignDoc
---

# Design doc template authoring

This repo packages design-doc conventions — one scale-independent
pattern — into the `design-doc` skill. This skill covers **authoring**
that material — studying a reference project and distilling its
conventions into generic templates.

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

1. Read the reference repo's doc surface — overview docs, per-service
   docs, proposals, decision records, generated or agent-facing docs.
   Use `gh` for GitHub repos.
2. Map what you find onto the doc kinds (living / proposal / decision /
   issue / reference / generated).
3. Write the conventions generically — describe the pattern, never the
   content.
4. Ship the deliverables per `CONTRIBUTING.md`: the `SKILL.md`
   conventions, the `templates/` tree, and the fictional `docs/example/`
   worked example — one tree each, not per scale.
5. Write placeholders agents can act on — prose instructions in
   `<!-- -->` comments under each heading; `<value>` placeholders only
   where a value is expected (titles, paths, table cells, frontmatter).
6. Verify every file renders: frontmatter parses as YAML, mermaid blocks
   are valid, no `<placeholders>` inside diagram syntax.
