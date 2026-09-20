---
name: spec-driven-development
description: >-
  Execute documented plans — confirm PR granularity with the user before
  dispatching work, keep phases as milestones (one phase ≈ one PR), and
  keep plan docs' status in sync as work lands. Pairs with the
  design-doc skill, which owns how plans and design docs are written.
---

# Spec-driven development

The execution half of the docs. `design-doc` owns how design docs,
plans, and issues are *written*; this skill owns *running* a plan —
turning phases into PRs without losing the paper trail.

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
   table, the plan overview's phase index, and the design docs listed in
   `designs:` — in the same commit or PR.

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
