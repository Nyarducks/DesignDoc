# AGENTS.md — DesignDoc

Design-doc conventions packaged as agent skills, organized by project scale.

## Rules — always follow

1. **Skills are agent-agnostic** — canonical location is
   `.agents/skills/<name>/SKILL.md`.
2. **Skill split** — `design-doc` writes docs, `design-doc-template`
   authors them, `spec-driven-development` executes plans. Template rules
   live in `CONTRIBUTING.md`; its no-leak rule is non-negotiable.
3. **Every scale ships a template tree + fictional example** —
   `templates/<scale>/` mirrors the target `docs/` layout;
   `docs/example/<scale>/` is a worked example for an invented project.

## Pointers

- How to work here: `CONTRIBUTING.md`
- Skills: `.agents/skills/`
- Worked examples: `docs/example/`
