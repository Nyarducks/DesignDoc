# AGENTS.md — DesignDoc

Design-doc conventions packaged as agent skills — one scale-independent
pattern.

## Rules — always follow

1. **Skills are agent-agnostic** — canonical location is
   `.agents/skills/<name>/SKILL.md`.
2. **Skill split** — `design-doc` writes docs, `design-doc-template`
   authors them, `spec-driven-development` executes design docs,
   `doc-checks-ci` wires the check scripts into a project's CI, and
   `agent-guidance` decides where agent-facing guidance lives. Template
   rules live in `CONTRIBUTING.md`; its no-leak rule is non-negotiable.
3. **Ship a template tree + fictional example** — `templates/` mirrors
   the target `docs/` layout; `docs/example/` is a worked example for
   an invented project.

## Pointers

- How to work here: `CONTRIBUTING.md`
- Skills: `.agents/skills/`
- Worked examples: `docs/example/`
