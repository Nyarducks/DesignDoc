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

Applies to every shell file — scripts shipped inside skills
(`.agents/skills/*/scripts/`) and everything under `tests/`.

### 1. Safety header

```bash
#!/usr/bin/env bash
set -euo pipefail
```

`-e` exits on error, `-u` errors on unset variables, `-o pipefail`
propagates the failing stage's status through pipelines. Test runners
may drop `-e` to collect failures — `set -u` still applies.

### 2. Naming

- Constants and exported variables: `UPPER_SNAKE`, `readonly`/`export`.
- Internal and `local` variables: `lower_snake` — never collide with
  environment variables like `PATH` or `HOME`.

### 3. Expansion and quoting

- Always double-quote variable references — `"$file"`, never `$file` —
  to prevent word splitting and globbing.
- `${var}` braces are optional for simple references, mandatory for
  concatenation (`"${base}_x"`), array indexing, and parameter expansion
  (`"${timeout:-30}"`).

### 4. Functions and scope

- `name() { ... }` — no `function` keyword.
- Declare internal variables with `local`.

### 5. Lint annotations

CI runs shellcheck over every shell file. Suppress a warning only when
the flagged pattern is intentional, and write the reason in a comment on
the line above the directive — a bare `disable=` reads as "nobody
checked this".

```bash
# $path is a jq variable, not shell — single quotes are intentional
# shellcheck disable=SC2016
jq '.projects[$path].x = true'
```

### 6. Template

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly LOG_DIR="/var/log/app"

backup_logs() {
  local target_app="$1"
  local archive="${LOG_DIR}/${target_app}.tar.gz"

  echo "Creating archive: ${archive}"
}
```
