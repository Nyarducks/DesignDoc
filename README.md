# DesignDoc

Design-doc conventions packaged as agent skills, organized by project
scale — pick a scale, copy its template tree, apply its conventions.

## What's inside

| Path | Contents |
|---|---|
| `.agents/skills/design-doc/` | The doc-writing skill — scale ladder, per-scale conventions |
| `.agents/skills/design-doc-template/` | The template-authoring skill — how scales get distilled |
| `.agents/skills/design-doc/templates/<scale>/` | Copy-ready `docs/` trees |
| `docs/example/<scale>/` | Worked examples (fictional projects) |

Scales so far: `small`, `medium`.

## Use

Copy `.agents/skills/` into a repo (or point your agent at it) and ask it
to write or update design docs — the skill picks the scale and the
matching template tree.

## Contributing

See `CONTRIBUTING.md` — template-authoring rules, including the no-leak
rule for reference repos.
