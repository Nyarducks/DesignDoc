# Contributing

Rules for authoring this repo's templates, skills, and examples. When an
agent does this work it follows `.agents/skills/design-doc-template/`;
this file is the canonical statement of the rules.

## Confidentiality — the hard rule

A reference repo is read for **conventions only**. Nothing inside it may
appear in a deliverable — including its identity:

- No repo names or links, project or module names, file paths, PR/issue
  links, hostnames, schemas, business logic, or security-posture details.
- `templates/` and `docs/example/` use **fictional projects** — invented
  names, paths, and links only.

The `design-doc` skill is the mirror image: at doc-writing time the
target repo's real details *are* the content. The no-leak rule applies to
template authoring only.

## What to distill (and what to leave)

- **Distill** — doc kinds and their directories, section anatomy,
  metadata conventions, status/review workflow, update discipline,
  multi-repo handling.
- **Leave behind** — anything that answers "what does their system do"
  rather than "how do they document".

## Per-scale deliverables

Each scale ships three things:

1. A section in `.agents/skills/design-doc/SKILL.md` — the conventions.
2. `.agents/skills/design-doc/templates/<scale>/` — a copy-ready tree
   mirroring the target `docs/` layout.
3. `docs/example/<scale>/` — the template applied to a fictional project,
   marked as such.

Then update the scale table in `SKILL.md`.

## Quality bar

- Templates are complete, valid artifacts — frontmatter parses, mermaid
  blocks render, `<placeholders>` never appear inside diagram syntax.
- SKILL.md bodies are imperative and concise — procedures and rules, not
  essays.
- `AGENTS.md` carries must-follow rules only — no structure, no usage.

## Shell script style

Every shell file — scripts shipped inside skills
(`.agents/skills/*/scripts/`) and each skill's `tests/` — follows
`docs/reference/shell-style.md`.
