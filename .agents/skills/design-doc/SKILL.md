---
name: design-doc
description: >-
  Write and maintain design docs sized to the project's scale — pick the
  scale, copy its structured template tree, apply its conventions.
  Aligned with Google's design doc practice (context and goals, design
  trade-offs, alternatives considered, cross-cutting concerns).
  Ships small- and medium-scale template trees; large-scale conventions
  are documented for orientation. Use when creating or updating design
  documentation.
metadata:
  author: Nyarducks
  license: MIT
  url: https://github.com/Nyarducks/DesignDoc
---

# Design docs

Write design docs sized to the project: pick the scale below, copy its
template tree, and apply its conventions.

## Installing into a project

The skill ships alone — no `AGENTS.md`, no `docs/example/` come with it.
After installing, append this block to the project's `AGENTS.md` (create
the file if missing). The anchors delimit the block so it can be opted
in or out at any time:

```markdown
<!-- design-doc:start -->
## Design docs

- Doc layout and conventions follow the `design-doc` skill —
  `docs/design/` living docs, `docs/adr/`, `docs/issues/`, and
  `docs/plan/` at medium scale.
- The `sources:` contract — a commit that changes a file listed in a
  doc's `sources:` updates that doc in the same commit.
<!-- design-doc:end -->
```

Record the install's provenance — a `metadata:` block or comment in the
installed `SKILL.md` naming the upstream repo and the tree/commit SHA
vendored. It makes drift-checking mechanical: diff the installed tree
against that SHA to surface local edits, and diff upstream HEAD against
it to see what the install is missing.

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
- **Split by unit of change** — a doc's boundary is its `sources:` set
  and its invariants: if two sections change on different triggers,
  answer different questions, or carry disjoint `sources:` lists, they
  are two docs. Group units only when they share a single contract or
  decision that no member owns alone. Never group by theme — a doc that
  needs a table of contents to navigate unrelated sections is already
  too big. When unsure, split: small docs compose via the index README.
- **Granularity follows the doc kind** — API docs split by contract
  surface (one endpoint or one resource's CRUD family), screen specs by
  route, subsystem docs by mechanism, cross-cutting docs by shared
  contract. Do not force one granularity rule across kinds.
- **Overlapping `sources:` need different questions** — two docs may
  cover the same code only when they answer different levels of
  question (design doc = why/invariants; reference = what/spec). If one
  source change forces the *same* edit in both, merge or re-scope.
- **Sections name mechanisms, not events** — "Job persistence", never
  "Fix 2" — fix history belongs in plans and ADRs.
- **Hard-to-document is a finding** — when a doc resists clean
  boundaries (scattered sources, no clear invariant), record the
  underlying design weakness in `issues/` instead of writing around it.
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
│   └── <component>.md     # one doc per unit of change (from component.md)
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
`docs/`. Fact inventories (config tables, script lists) live with the
design doc that owns them; a shared `docs/reference/` bucket collects
ownerless pages that rot — reserve it for genuinely cross-cutting
inventories.

### Frontmatter (OKF v0.2)

Every doc under `docs/` carries YAML frontmatter:

```yaml
---
type: Design Doc           # Design Doc | ADR | Reference | Plan | Issue
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
`sources: []`. Enforce the contract in CI with
`scripts/check-docs-stale.sh` (shipped with this skill): it fails a PR
that changes a declared source without touching its doc, or that leaves
a `sources:` path dangling after a rename/delete. Its companion
`check-doc-frontmatter.sh` validates the frontmatter itself — required
keys, the `type` enum, `last_modified` shape — because a malformed
header silently escapes the sources check. Wire them into the project's
workflow with the `doc-checks-ci` skill, which ships its own copies.

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
│   ├── README.md              # plan conventions — the dir listing is the index
│   ├── <change>/
│   │   ├── README.md          # plan overview — context, phases, status
│   │   └── phase-N-<slug>.md  # one doc per implementation phase
│   └── archived/              # done/dropped plans — frozen records
├── adr/                       # same as small
├── issues/                    # same as small — scheduled rows link their plan
└── <module>/                  # module subtrees — own {design,issues,adr}
```

In a monorepo a module may carry its own `docs/` (`<module>/docs/`), or a
subtree under the central root (`docs/<module>/{design,issues,adr}/`)
when one entry point matters more — either way, living docs sit nearest
the code they describe and the overview links to them. Fact inventories
(config tables, script lists) live inside the owning module's docs — a
shared `docs/reference/` bucket has no owner, and ownerless pages rot.

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
implementation phase. `docs/plan/README.md` holds the conventions only —
the directory listing plus each plan's `status:`/`issues:`/`designs:`
frontmatter is the index; a hand-maintained table conflicts on every
parallel plan PR. When a plan reaches `done` or `dropped`, move its file
or directory to `docs/plan/archived/` and record the delivering PR in
the body.

Executing a plan — confirming PR granularity, managing stacked PRs — is
workflow, not doc convention: it lives in the `spec-driven-development`
skill.

**How plans link the graph** — a plan declares in frontmatter:

- `issues:` — the issue IDs it resolves (issue docs point back with
  `resolved_by:`).
- `designs:` — the `docs/design/` doc slugs it modifies. Design docs
  describe *current* reality, so they never list in-flight plans — when a
  phase merges, update the listed design docs in the same commit, like
  the `sources:` contract.

Plan docs omit `sources:` — a plan records a point-in-time change, not a
living derivation, so the `sources:` contract does not apply to it. The
phase-merge workflow (see `spec-driven-development`) keeps plans in sync
instead.

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
regenerated by scripts or a skill, with the regeneration wired into CI
or the dev loop. A generated tree whose regeneration has lapsed rots
silently — worse than no tree; do not create one without the loop.
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
- Living docs follow the small-scale `sources:` contract; plans are
  point-in-time records kept in sync by the phase-merge workflow, not
  the contract.
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
