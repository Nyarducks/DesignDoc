---
name: spec-driven-development
description: >-
  Execute documented plans — confirm PR granularity with the user before
  dispatching work, keep phases as milestones (one phase ≈ one PR), and
  keep plan docs' status in sync as work lands. Pairs with the
  design-doc skill, which owns how plans and design docs are written.
metadata:
  author: Nyarducks
  license: MIT
  url: https://github.com/Nyarducks/DesignDoc
---

# Spec-driven development

The execution half of the docs. `design-doc` owns how design docs,
plans, and issues are *written*; this skill owns *running* a plan —
turning phases into PRs without losing the paper trail.

## Installing into a project

The skill ships alone — no `AGENTS.md` comes with it. After installing,
append this block to the project's `AGENTS.md` (create the file if
missing). The anchors delimit the block so it can be opted in or out at
any time:

```markdown
<!-- spec-driven-development:start -->
## Plan execution

- Executing `docs/plan/<change>/` — confirm PR granularity before
  dispatching; never default silently.
- One phase ≈ one PR; the merge updates the plan's `status:` and phase
  index, and the `designs:` docs in the same PR.
<!-- spec-driven-development:end -->
```

## The flow

1. **Locate the spec** — the work item is a plan (`docs/plan/<change>/`)
   or an issue whose `resolved_by:` names one. If no plan exists and the
   change is non-trivial, write it first using `design-doc` conventions;
   if it fits one PR, skip the plan.
2. **Confirm PR granularity** — ask before dispatching (below).
3. **Dispatch per phase** — a phase is the milestone: the smallest
   independently mergeable increment, roughly one PR. The task checklist
   in the phase doc is the finer breakdown below PR level.
4. **Keep the docs in sync** — when a phase merges, update its status
   table, the plan overview's phase index, the plan's `status:`
   frontmatter, and the design docs listed in `designs:` — in the same
   commit or PR. `docs/plan/README.md` has no per-plan table to update —
   the directory listing is the index. When a plan reaches `done` or
   `dropped`, move it to `docs/plan/archived/`.

## Confirm PR granularity — always ask

If the request doesn't specify how to cut the work into PRs, ask before
dispatching via the agent's ask-question tool (`AskUserQuestion`,
`ask_user_question`, `ask_question`, whichever the runtime exposes).
Never default silently.

Options can be situational, or use the standard set:

1. **One PR for everything** — PoC/prototype work.
2. **Smart split** — review-friendly cuts along natural boundaries.
3. **One PR per phase** — faithful to the plan's milestone structure.

## Stacked PRs — `gh stack`

Splitting means stacks: prefer
[`gh stack`](https://github.com/github/gh-stack) to manage the dependent
PR chain. It's also the escape hatch when a single-PR PoC later needs
splitting for review.
