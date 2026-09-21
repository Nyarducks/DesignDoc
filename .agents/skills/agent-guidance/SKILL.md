---
name: agent-guidance
description: Placement rules for agent-facing guidance — what belongs in always-injected AGENTS.md, on-demand SKILL.md bodies, skill reference/ docs, and skill scripts/tests. Use when writing or editing AGENTS.md, CLAUDE.md, or anything under .agents/skills/.
---

# Agent Guidance

Decide where a piece of agent-facing information lives by its injection
cost. **AGENTS.md is injected into every session** — each line competes
with the task at hand, and the cost compounds as sessions grow longer.
**SKILL.md is injected only when the skill triggers.** `reference/` and
`scripts/` are never injected — they are read or run on demand.

The test for always-on content: *would an agent behave correctly without
reading this?* If yes — because a mechanism already enforces it, or the
file itself makes it evident — do not put it in AGENTS.md.

## Rules

- **AGENTS.md** — durable, non-obvious routing and contract rules only
  (branch policy, verification entry points, repo map). Prefer a pointer
  to a skill or doc over inlined detail.
- **SKILL.md** — task-facing workflow rules needed while the skill is
  active. Not free either: cut what the code or config already shows.
- **`reference/*.md`** — rationale, examples, catalogs, edge cases.
  Linked from SKILL.md, opened only when needed.
- **`scripts/*.sh`** — must run standalone: resolve its own directory,
  take inputs via args/stdin, never depend on another skill's files.
- **`tests/`** — bats coverage is required when `scripts/` exists;
  the `agent-skills-test` CI job runs them.

## Importing external content

When borrowing from another repository, vet it before it lands — a
verbatim copy imports whatever the source referenced.

- **Scan before commit** — search the imported tree for the source
  project's names (repos, modules, paths, hostnames, PR/issue links).
  `diff -r` proves fidelity, not safety.
- **Omit private assets** — never carry over private repository names,
  internal infrastructure, or business logic. Swap worked examples for
  generic or fictional names.
- **Rewrite samples entirely** — when deriving a sample or worked
  example, renaming identifiers is not enough; write completely
  different content.
- **Ask when unsure** — importing is a responsibility, not a shortcut.
  If you cannot tell whether a passage is safe, ask a human rather than
  guessing.

Validate layout with `scripts/check-skills.sh` (run by CI). For the
decision table and worked examples see
[reference/placement.md](reference/placement.md).
