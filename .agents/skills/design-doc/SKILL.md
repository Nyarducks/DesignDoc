---
name: design-doc
description: >-
  Write and maintain design docs sized to the project's scale — pick the
  scale, copy its structured template tree, apply its conventions.
  Aligned with Google's design doc practice (context and goals, design
  trade-offs, alternatives considered, cross-cutting concerns).
  Currently ships the small-scale template; medium/large conventions are
  documented for orientation. Use when creating or updating design
  documentation.
---

# Design docs

Write design docs sized to the project: pick the scale below, copy its
template tree, and apply its conventions.

## Principles

- **What, Why, How** — a design doc answers what the system does, why it
  was made and why it is needed, and how the parts fit — at design level.
  Every doc opens with the why: the pitch and Background sections carry
  it.
- **Trade-offs are the point** — the doc records *why this design* over
  the alternatives, not how to implement it. A doc that reads as an
  implementation manual should have been code instead.
- **Detail rots** — the closer a doc gets to a spec, the faster it
  diverges from code. In AI-driven development agents read the code
  directly, so detailed design in prose costs more than it helps. Write
  invariants and intent; let code answer the rest.
- **Basic design is law** — the design philosophy and base design recorded
  in these docs must not silently break. They are maintained *through*
  the docs: behavior changes update the doc in the same commit.
- **Show, don't only tell** — use mermaid sequence diagrams for
  interactions and flowcharts for structure/branching wherever a diagram
  beats prose. System design docs should nearly always carry one.
- **Split by component** — one doc per functional unit or physical
  component (module, screen). Choose the split that best explains the
  system's purpose and design.
- **Know when not to write** — if the design is unambiguous (no real
  trade-offs, no alternatives worth weighing), skip the doc. Design docs
  earn their overhead through consensus and early issue detection.

## Pick a scale

| Scale | Signals | Template |
|---|---|---|
| Small | One repo, one maintainer or a small team, a handful of components | `templates/small/` — conventions below |
| Medium | Multiple services/modules or a growing team; designs need consensus before implementation | `templates/medium/` — conventions below |
| Large | Multiple teams/repos; cross-team review, launch gates | not yet distilled — see "Large" below |

### How the docs change with scale

| Axis | Small | Medium | Large |
|---|---|---|---|
| Doc kinds | Living overview + per-component docs + ADRs + issue list | + per-change proposal docs | + dedicated security/privacy docs |
| When written | Same commit as the change | Before implementation; the doc PR is the design review | Before implementation; formal review gates |
| Metadata | OKF frontmatter (`status`, `last_modified`) | + authors / reviewers on proposals | + lifecycle status, approvers, target dates |
| Requirements | Goal/Non-Goal + short functional & non-functional bullets | Explicit functional + non-functional requirements per proposal | NFRs with measurable targets (SLOs, capacity, latency budgets) |
| Alternatives | ADR Context records options + trade-offs | "Alternatives considered" section per proposal | Required, often quantitative analysis |
| Risks & ops | Risks/known-issues sections in living docs | Per-proposal rollout and ops plan | Risk register, launch checklist, dedicated ops review |
| Review | Self + PR review | Wider PR review, comment threads | Design review meetings, cross-team sign-off |
| Length | ~1–3 pages per doc | ~5–10 pages | 10–20 pages; split the problem beyond that |

Two doc *kinds* recur at every scale: **living docs** describe the system
as it is (overview, component docs — updated in the same commit as code);
**proposal docs** describe a change before it is built (Google-style
design docs — written for consensus and review). Small projects often
need only living docs plus ADRs; medium and up add proposals.

## Small project

Conventions distilled from a small single-repo reference project — living
docs under `docs/design/`, ADRs under `docs/adr/`, docs updated in the
same commit as code. A worked example lives in this repo at
`docs/example/small/`.

### Layout

`templates/small/` mirrors the target `docs/` tree — copy it and rename:

```
docs/
├── design/
│   ├── README.md          # overview design doc — the entry point
│   └── <component>.md     # one doc per component (from component.md)
├── adr/
│   ├── README.md          # index table of ADRs
│   └── NNNN-<slug>.md     # one file per significant decision
└── issues/
    ├── README.md          # issues list — the table view
    └── NNNN-<slug>.md     # optional detail doc per issue
```

`docs/design/README.md` is the overview because GitHub renders a
directory's `README.md` — the entry point is structured like every other
doc, not a plain index. Root docs stay slim: `README.md` is quick start
only, `AGENTS.md` is must-follow rules only — structure and usage live in
`docs/`. Optionally add `docs/reference/` for fact inventories (config
tables, script lists) as the project grows.

### Frontmatter (OKF v0.2)

Every doc under `docs/` carries YAML frontmatter:

```yaml
---
type: Design Doc           # Design Doc | ADR | Reference
title: <title>
description: <one line — what it covers and why>
status: current            # current | draft | deprecated (ADRs: accepted)
last_modified: YYYY-MM-DD  # bump on every edit
tags: [<topics>]
sources: [<files the doc is derived from>]
adrs: []                   # ADR numbers governing this doc — e.g. [0002]
issues: []                 # open issues affecting it — e.g. [0001, 0007]
---
```

**The `sources:` contract** — a doc derived from code lists the files it
summarizes; any commit that changes a source file must update the doc (and
`last_modified`) in the same commit. Keep the list as narrow as the doc's
real dependencies. Prescriptive docs — pure conventions — set
`sources: []`. Optionally enforce the contract in CI with a check that
fails a PR which changes a source without touching its doc.

**`adrs:` / `issues:` / `designs:` / `resolved_by:` — the
machine-readable doc graph.** Design docs declare the ADRs governing them
(`adrs:`) and the open issues affecting them (`issues:`); plans declare
the issues they resolve (`issues:`) and the design docs they modify
(`designs:`); issue docs point back at the plan or PR that resolves them
(`resolved_by:`). Prose links stay for human readers — frontmatter is the
index a tool can walk.

### Writing rules

- **Update docs in the same commit** as the behavior change.
- **Checkable claims only** — no counts or universal quantifiers over
  code-derived facts ("every agent implements …", "28 checks") unless a
  test asserts them; enumerate the matrix or name the exception instead.
- **Don't restate files** — if reading a file answers it (config layout,
  versions, job lists), point at the file or state the rule behind it.
- **Link neighbors** — `docs/design/README.md` is the entry point; every
  doc links the docs it depends on.

### The overview doc — `docs/design/README.md`

Copy `templates/small/design/README.md` and fill it in. Section order:

1. **Title + pitch** — what it is, why it was made, why it is needed.
2. **Goal / Non-Goal** — what it does; what it deliberately does not.
   Non-goals are things that could reasonably be goals but are explicitly
   excluded — not negated goals.
3. **Requirements** — split **functional** (what the system does) from
   **non-functional** (the qualities and constraints it must hold).
4. **Background** — the problem context that motivated it; objective
   facts only.
5. **High-level architecture** — a mermaid diagram of the whole system.
6. **Components** — table of parts (modules, classes) with each part's
   responsibility and purpose, linking to per-component docs.
7. **Component internals** — per-part internal spec and processing flow
   (data structures, algorithms) at the invariant level; defer to
   component docs for anything longer than a paragraph.
8. **Security** — trust boundaries and enforcement.
9. **Risks and known issues** — operational risks, failure modes, and
   known holes.
10. **Testing** — the commands and what they cover.
11. **Operations** — how to run, observe, and steer the system.
12. **References** — external links the design depends on.
13. **Notes** — doc conventions and caveats, plus an "In this directory"
    table.

### Per-component docs — `docs/design/<component>.md`

Copy `templates/small/design/component.md`. Same frontmatter, with
`title`/`description` scoped to the component and `sources` naming its
implementation files. Sections: Goal (responsibility and purpose) →
Design (internal spec and processing flow — sequence diagrams for
interactions, flowcharts for branching) → Key decisions (link the ADRs)
→ Security → Known issues → Testing → Notes.

### ADRs — `docs/adr/NNNN-<slug>.md`

Record every significant decision in the same commit that introduces it:

- Sequential number, kebab-case slug; frontmatter `type: ADR`,
  `status: accepted`. Body: Context → Decision → Consequences.
- ADR **Context** is where alternatives and their trade-offs live — the
  small-scale home for what Google calls "alternatives considered".
- `templates/small/adr/0001-record-architecture-decisions.md` doubles as
  a project's ADR-0001 — adopt it verbatim and the convention records
  itself.
- Immutable point-in-time records — never edit one to track code drift;
  write a new ADR when a decision is revisited.
- Keep `docs/adr/README.md` as an index table.

### Issues — `docs/issues/`

Known problems and improvement backlog as a scannable list — issue
trackers are poor at "show me the list", so the list lives in a doc:

- `README.md` — a table: `ID | Issue | Severity | Status | Resolved by`.
  Status: open · investigating · planned · in-progress · done ·
  deferred · wontfix.
- `NNNN-<slug>.md` — optional detail doc per issue (Problem → Evidence →
  Impact → Options → Resolution); most rows never need one. Its
  `resolved_by:` frontmatter holds the plan/PR once scheduled — the same
  value as the table's Resolved by column.
- Line-drawing: an issue tracker owns assigned, actively-worked tasks;
  `docs/issues/` owns the visible backlog of *known* problems. A design
  doc's "Risks and known issues" describes design limitations — anything
  actionable gets a row here, and a scheduled row links its plan or PR.

### Docs in the workflow

- The doc PR *is* the review — reviewers read the rendered markdown, not
  a meeting invite.
- `docs/design/README.md` answers the newcomer's first question: "where
  is the design doc?"
- The `sources:` contract plus same-commit updates is the small-scale
  substitute for Google's maintenance phase — staleness fails in review,
  not a year later.

### Procedure

1. **Starting a project's docs** — copy `templates/small/` to `docs/`;
   fill in `design/README.md`, rename `component.md` per component, keep
   `adr/0001-…` if the project records decisions.
2. **Adding or changing a component** — write or update its doc; update
   the overview's Components and "In this directory" tables.
3. **Changing behavior** — update every doc whose `sources:` intersects
   the changed files, in the same commit; bump `last_modified`.
4. **Making a significant decision** — add `docs/adr/NNNN-<slug>.md` and
   index it.

## Medium project

Conventions distilled from a multi-repo reference system whose main repo
is a monorepo of several modules. A worked example lives in this repo at
`docs/example/medium/`.

Medium keeps everything small has and adds **plan docs** — phased
proposal docs written before implementation and maintained with it — plus
module-local living docs and generated agent context.

### Layout

`templates/medium/` mirrors the target `docs/` tree:

```
docs/
├── design/
│   ├── README.md              # system overview — spans modules and repos
│   └── <module>.md            # living doc per module/service
├── plan/
│   ├── README.md              # plan index — all changes as a table
│   └── <change>/
│       ├── README.md          # plan overview — context, phases, status
│       └── phase-N-<slug>.md  # one doc per implementation phase
├── adr/                       # same as small
├── issues/                    # same as small — scheduled rows link their plan
└── reference/                 # optional — API/schema inventories
```

In a monorepo a module may carry its own `docs/` (`<module>/docs/`) —
living docs sit nearest the code they describe; the overview links to
them.

### The overview doc — `docs/design/README.md`

Same section list as small, plus a **Repositories** table naming every
repo in the system and its scope — at medium scale the first question is
often "which repo does this live in".

### Plan docs — `docs/plan/<change>/`

The medium-scale proposal doc: written before implementation, reviewed as
a PR, updated in the same PRs that implement it.

**Format: milestone-type phases.** A phase is the smallest independently
mergeable increment — the system must stay coherent after each one lands.
Phase granularity *is* PR granularity: one phase ≈ one PR (a large phase
may split into stacked PRs, but its acceptance criteria are met by those
PRs collectively). The task checklist inside a phase doc is the finer
breakdown below PR level. Size phases so each delivers observable
behavior — a phase that takes weeks means split the change; a phase
that's a refactor with no behavior isn't a milestone. A change that fits
one PR doesn't need a directory: write a single `plan/<change>.md` in the
phase-doc shape instead.

A plan dir gets a `README.md` overview plus one `phase-N-<slug>.md` per
implementation phase; `docs/plan/README.md` indexes all plans as a table.

**Confirm PR granularity before implementing a plan.** If the request
doesn't say how to cut the work into PRs, ask before dispatching — via
the agent's ask-question tool (`AskUserQuestion`, `ask_user_question`,
`ask_question`, whichever the runtime exposes). Never default silently.
Options can be situational, or use the standard set:

1. **One PR for everything** — PoC/prototype work.
2. **Smart split** — review-friendly cuts along natural boundaries.
3. **One PR per phase** — faithful to the plan's milestone structure.

When splitting into multiple PRs, prefer
[`gh stack`](https://github.com/github/gh-stack) to manage the stack —
it's also the escape hatch when a single-PR PoC later needs splitting.

**How plans link the graph** — a plan declares in frontmatter:

- `issues:` — the issue IDs it resolves (issue docs point back with
  `resolved_by:`).
- `designs:` — the `docs/design/` doc slugs it modifies. Design docs
  describe *current* reality, so they never list in-flight plans — when a
  phase merges, update the listed design docs in the same commit, like
  the `sources:` contract.

Overview sections:

- **Status line** — created date, repos in scope, scope note ("this plan
  is maintained with the implementation").
- **Context** — objective facts plus an operating-assumptions table that
  bounds the plan.
- **Goal mapping** — which phases serve which goals.
- **Phase index** — `phase | title | priority | status | PR`, with a
  status legend: not started · in progress · in review · merged ·
  deferred · dropped.
- **Dependency order** — what ships first, what blocks what (ASCII or
  mermaid).
- **Rejected alternatives** — options weighed and dropped; the
  medium-scale home of "alternatives considered".
- **Companion plans** — a change spanning repos gets a plan dir in each
  repo; each links the others.

Phase doc anatomy: a status table (status, priority, repo, depends-on,
blocks, PR) → **Problem** → **Evidence** → **Impact** → **Proposed
change** → **Task checklist** → **Acceptance criteria** → **Risks and
open questions** → **Progress log**. Plan docs may carry more
implementation detail than living docs — they are the review artifact —
but keep them at trade-off level, not line-by-line.

### Generated and agent-facing docs

Machine-generated context — code indexes, task→file routing maps,
dependency graphs — lives in its own tree, marked as generated and
regenerated by scripts or a skill, ideally with a freshness check in CI.
Never hand-edit generated docs; fix the generator. A curated agent
entrypoint doc (task → "read these files first" table, component map,
read-order guidance, do-not-read list) pays for itself quickly at this
scale.

### Review archives

Optional: per-file or per-PR review records under `docs/reviews/`.
Useful for audits — but they are records, not design docs.

### Docs in the workflow

- The plan doc PR *is* the design review; phase status tracks reality and
  is updated in the same PR as the code.
- Living docs follow the small-scale `sources:` contract; plan docs'
  `sources` cover the files the phases will touch.
- Multi-repo changes: one plan dir per repo, cross-linked; shared
  contracts get reference docs both sides cite.

## Large project

Medium, formalized: proposals carry lifecycle status and named
approvers; design review meetings gate implementation; dedicated
security/privacy design docs with their own reviews; NFRs get measurable
targets (SLOs, capacity, latency budgets); rollout, risk register, and
ops readiness are required sections. A central index keeps proposals
discoverable as organizational memory.

## References

- [Design Docs at Google](https://www.industrialempathy.com/posts/design-docs-at-google/)
  — anatomy, lifecycle, and when not to write one
- [Google Open Knowledge Format v0.2](https://github.com/google/open-knowledge-format)
  — frontmatter convention
