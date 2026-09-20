# AGENTS.md — DesignDoc

Design-doc conventions packaged as agent skills, organized by project scale.

## Rules — always follow

1. **Skills are agent-agnostic** — canonical location is
   `.agents/skills/<name>/SKILL.md`, not a tool-specific config dir.
2. **`design-doc` writes docs, `design-doc-template` authors them** —
   writing a design doc for a real project uses the real repo's details;
   authoring templates never copies a reference repo's internals. The
   no-leak rule lives in `design-doc-template`.
3. **Scale lives inside `design-doc`** — the skill picks the scale; each
   scale is a section in `SKILL.md` plus a `templates/<scale>/` tree that
   mirrors the target `docs/` layout. Scales so far: `small`, `medium`.
4. **Every scale ships a worked example** — `docs/example/<scale>/` holds
   the template applied to a **fictional** project.
5. **Skill format** — `SKILL.md` starts with `name:`/`description:`
   frontmatter; the description states when the skill applies. The body is
   imperative and concise — procedures and rules, not essays.
6. **Templates are copy-ready** — a template is a complete, valid artifact
   (frontmatter included) with `<placeholders>` for the variable parts —
   not a fragment, not an essay on writing.
7. **Distill, don't transcribe** — each scale's section names the
   reference repo it was distilled from, so conventions stay traceable.
   Nothing beyond the name crosses over.

## Pointers

- Skills: `.agents/skills/`
- Worked examples: `docs/example/`
- Small-scale reference: `docs/design/`, `docs/adr/`, `CONTRIBUTING.md` in
  [Nyarducks/Worktreeharness](https://github.com/Nyarducks/Worktreeharness)
- Medium-scale reference: phased plans under `docs/plan/` and
  module-local `docs/` in
  [Nyarducks-FX/TradeLab](https://github.com/Nyarducks-FX/TradeLab)
