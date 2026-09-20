# DesignDoc

Design-doc conventions packaged as agent skills, organized by project
scale — pick a scale, copy its template tree, apply its conventions.

## What's inside

| Path | Contents |
|---|---|
| `.agents/skills/design-doc/` | The doc-writing skill — scale ladder, per-scale conventions |
| `.agents/skills/design-doc-template/` | The template-authoring skill — how scales get distilled |
| `.agents/skills/spec-driven-development/` | The plan-execution skill — PR granularity, stacked PRs |
| `.agents/skills/design-doc/templates/<scale>/` | Copy-ready `docs/` trees |
| `docs/example/<scale>/` | Worked examples (fictional projects) |

Scales so far: `small`, `medium`.

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`) — PR workflows and skill
  installation.
  - `gh skill` requires **gh v2.90.0+**; this repo's skills live under
    the hidden `.agents/` dir, so pass `--allow-hidden-dirs`.
  - [`gh stack`](https://github.com/github/gh-stack) — only when
    `spec-driven-development` splits work into stacked PRs:
    `gh extension install github/gh-stack` (requires gh v2.0+). Its own
    agent skill ships via `gh skill install github/gh-stack`.

## Installation

Install the skills a project needs — `design-doc` for doc work,
`spec-driven-development` for executing plans:

```sh
gh skill install Nyarducks/DesignDoc --allow-hidden-dirs
```

Or copy `.agents/skills/<name>/` into the project's skills directory —
`.agents/skills/` is shared by Copilot, Codex, Devin, and others; use
your agent's directory if it differs.

Skills arrive without this repo's `AGENTS.md` or `docs/example/` — the
rules a project needs are carried inside each skill. On install, append
the skill's `AGENTS.md` block (in its "Installing into a project"
section) to the project's `AGENTS.md`. Each block is wrapped in
`<!-- <skill>:start -->` / `<!-- <skill>:end -->` anchors so it can be
opted in or out at any time.

## Contributing

See `CONTRIBUTING.md` — template-authoring rules, including the no-leak
rule for reference repos.
