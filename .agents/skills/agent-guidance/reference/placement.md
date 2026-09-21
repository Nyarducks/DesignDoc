# Placement reference

Extended rationale and examples for the rules in `../SKILL.md`.

## Cost model

| Location | Injected when | Budget rule |
|---|---|---|
| `AGENTS.md` (and `CLAUDE.md` which includes it) | every session, before the first message | only what every task needs and nothing else provides |
| `<skill>/SKILL.md` body | when the skill's description matches the task | what an agent needs mid-task, not orientation |
| `<skill>/reference/*.md` | only when the agent opens it | unlimited — detail lives here |
| `<skill>/scripts/*.sh`, `tests/` | never injected | correctness enforced by running, not reading |
| `docs/` | never injected; reached via `sources:` and links | design rationale, ADRs, plans |

## The self-evident test

Before adding a line to AGENTS.md, ask whether the information is
already carried by the repository itself. Typical cases that fail the
test:

- **Mechanism-enforced behavior** — e.g. hooks that run automatically.
  An agent does not need to know a dispatcher exists for it to work;
  the config file and the script's header comment are the documentation.
- **Lists that duplicate discovery** — runtimes already surface skills
  by description; an always-on copy of the catalog is redundancy that
  must be maintained by hand.
- **What a file's header says** — restating a script's own comment in
  AGENTS.md creates two sources of truth that drift.

Cases that pass the test: rules an agent cannot infer and will violate
without them (`feat/` branch policy, PR-label requirements, "verify via
`make verify-*` only"), and pointers that route tasks to the right skill
or doc.

## Worked examples

| Content | Right home | Why |
|---|---|---|
| "Commits to main are blocked; branch `feat/<topic>`" | AGENTS.md | needed every session; not inferable before the mistake |
| How `optimize_sweep` parameters map to planner fields | `backtest-optimize` SKILL.md / reference | only relevant mid-optimization |
| The CI pipeline's base-SHA fallback rules | `docs/ci/design/change-detection.md` | design rationale, linked via `sources:` |
| "A dispatcher reinstalls git hooks on `git commit`" | script header comment | runs automatically; documenting it in AGENTS.md is noise |
| Skill layout conventions themselves | this skill | consulted only when authoring guidance |

## Standalone scripts

A skill's scripts must work when the skill is used in isolation:

- Resolve paths from `BASH_SOURCE` or explicit arguments — never assume
  the caller's cwd, and never read files from sibling skills.
- Depend only on ubiquitous tools (bash, git, coreutils, jq) or degrade
  gracefully when they are absent.
- Keep behavior verifiable: every script ships bats tests under
  `tests/`; CI (`agent-skills-test` job, gated on `.agents/` changes)
  runs `scripts/check-skills.sh` plus all skill tests.

`check-skills.sh` enforces the layout: each skill directory needs a
`SKILL.md` whose frontmatter `name:` equals the directory name and whose
`description:` is non-empty; any `scripts/` directory requires
executable files and a `tests/` directory containing `.bats` files.
