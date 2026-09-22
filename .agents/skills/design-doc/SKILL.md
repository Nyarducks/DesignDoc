---
name: design-doc
description: >-
  Write and maintain design docs with a single scale-independent
  pattern — living docs under docs/architecture/, proposals under
  docs/design-docs/, decisions under docs/adr/, issues under
  docs/issues/. Copy the template tree, apply the conventions. Aligned
  with Google's design doc practice (context and goals, design
  trade-offs, alternatives considered, cross-cutting concerns). Use when
  creating or updating design documentation.
metadata:
  author: Nyarducks
  license: MIT
  url: https://github.com/Nyarducks/DesignDoc
---

# Design docs

One documentation pattern for any project size — copy `templates/` into
`docs/` and apply the conventions below. Scale changes depth and review
formality, not the layout.

## Installing into a project

The skill ships alone — no `AGENTS.md`, no `docs/example/` come with it.
After installing, append this block to the project's `AGENTS.md` (create
the file if missing). The anchors delimit the block so it can be opted
in or out at any time:

```markdown
<!-- design-doc:start -->
## Design docs

- Doc layout and conventions follow the `design-doc` skill —
  `docs/architecture/` living docs, `docs/design-docs/` proposals,
  `docs/adr/` decision records, `docs/issues/` known problems.
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
  Every doc opens with the why.
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
  "Fix 2" — fix history belongs in design docs and ADRs.
- **Hard-to-document is a finding** — when a doc resists clean
  boundaries (scattered sources, no clear invariant), record the
  underlying design weakness in `issues/` instead of writing around it.
- **Know when not to write** — if the design is unambiguous (no real
  trade-offs, no alternatives worth weighing), skip the doc. Design docs
  earn their overhead through consensus and early issue detection.

## Layout

`templates/` mirrors the target `docs/` tree — copy it and rename:

```
docs/
├── README.md                    # system overview — the entry point
├── architecture/                # LIVING DOCS — the system as it is
│   ├── README.md                #   architecture conventions
│   ├── glossary.md              #   ubiquitous domain terms
│   ├── <service>/               #   one dir per service or coherent
│   │   ├── README.md            #     subsystem: hub + index of its docs
│   │   └── <topic>.md           #     one doc per unit of change —
│   │                            #     a contract surface, route, mechanism
│   └── <component>.md           #   flat file while one page says it;
│                                #   promote to a dir when it grows docs
├── design-docs/                 # PROPOSALS — point-in-time changes
│   ├── README.md                #   conventions — the listing is the index
│   ├── NNNN-<change>.md         #   a change that fits one PR
│   ├── NNNN-<change>/           #   a multi-PR change
│   │   ├── README.md            #     self-contained design doc
│   │   └── phase-N-<slug>.md    #     per-phase execution surface
│   └── archived/                #   done/dropped docs — frozen records
├── adr/
│   ├── README.md                # ADR conventions — no index table
│   └── NNNN-<slug>.md           # one file per significant decision
└── issues/
    ├── README.md                # issue conventions — no index table
    ├── NNNN-<slug>.md           # one file per issue
    └── archived/                # done/deferred/wontfix — frozen records
```

Two doc *kinds* do the work: **living docs** describe the system as it
is (`architecture/` — updated in the same commit as code); **proposal
docs** describe a change before it is built (`design-docs/` — written
for consensus, frozen once shipped). ADRs and issues sit alongside as
cross-cutting records.

Root docs stay slim: `README.md` is quick start only, `AGENTS.md` is
must-follow rules only — structure and usage live in `docs/`. Fact
inventories (config tables, script lists) live with the doc that owns
them; a shared `docs/reference/` bucket collects ownerless pages that
rot — reserve it for genuinely cross-cutting inventories.

**What makes either kind a *design* doc** — it records decisions, not
just behavior. The shared spine: **Overview → Background and motivation
(objective constraints: who calls it, volume, SLOs, what callers can't
do) → Goals and non-goals → Detailed design (contract, data model /
state machine, flow) → Decisions and alternatives → Failure modes →
Risks and mitigations → Testing**. In an `architecture/<service>/`
subtree the spine splits across docs, never repeats: the `README.md`
hub carries overview, context, goals, and surface-wide conventions; each
`<topic>.md` carries one unit's contract, lifecycle, flow, decisions,
and failure modes. A doc that only says "this is how it works" is an
implementation manual, not a design doc; if there were genuinely no
trade-offs, the code alone was probably enough. Living docs keep the
decision digest so the reasoning survives after the proposal archives.

## Frontmatter (OKF v0.2)

Every doc under `docs/` carries YAML frontmatter:

```yaml
---
type: Architecture         # Architecture | Design Doc | ADR | Reference | Plan | Issue
title: <title>
description: <one line — what it covers and why>
status: current            # living docs: current | deprecated
                           # design docs: draft | in-review | in-progress | done | dropped
                           # issues: open | investigating | planned | in-progress | done | deferred | wontfix
                           # ADRs: accepted | superseded | ...
tags: [<topics>]           # every tag must be defined in
                           # architecture/tags.json
sources: [<files the doc is derived from>]   # architecture docs only
adrs: []                   # ADR numbers governing this doc — e.g. [0002]
issues: []                 # open issues affecting it — e.g. [0001, 0007]
services: []               # infra docs only — services a change to this
                           # mechanism affects — e.g. [api, worker]
closed_pr:                 # design docs / issues only — the PR that
                           # shipped/dropped/closed it; set when archiving
---
```

**The `sources:` contract** — a living doc derived from code lists the
files it summarizes; any commit that changes a source file must update
the doc in the same commit. Keep the list as
narrow as the doc's real dependencies. Prescriptive docs — pure
conventions — set `sources: []`. Enforce the contract in CI with
`scripts/check-docs-stale.sh` (shipped with this skill): it fails a PR
that changes a declared source without touching its doc, or that leaves
a `sources:` path dangling after a rename/delete. Its companion
`check-doc-frontmatter.sh` validates the frontmatter itself — required
keys, the `type` enum, malformed scalars and lists — because a malformed
header silently escapes the sources check. Wire them into the project's
workflow with the `doc-checks-ci` skill, which ships its own copies.

**`tags:` is a controlled vocabulary** — `architecture/tags.json` maps
each tag to a one-line meaning so tag searches stay meaningful. Define a
tag there before using it on a doc.

**`adrs:` / `issues:` / `designs:` / `resolved_by:` — the
machine-readable doc graph.** Living docs declare the ADRs governing
them (`adrs:`) and the open issues affecting them (`issues:`); design
docs declare the issues they resolve (`issues:`) and the living docs
they modify (`designs:`); issue docs point back at the design doc or PR
that resolves them (`resolved_by:`). Prose links stay for human readers
— frontmatter is the index a tool can walk.

## Living docs — `docs/architecture/`

Updated in the same commit as the behavior they describe; `sources:`
lists what they're derived from.

### The overview — `docs/README.md`

The system entry point, structured like every other doc (GitHub renders
a directory's `README.md`). Section order — the template carries
`<!-- -->` prompt comments under each heading:

1. **Title + pitch** — what it is, why it was made, why it is needed.
2. **Goal / Non-Goal** — what it does; what it deliberately does not.
   Non-goals are things that could reasonably be goals but are explicitly
   excluded — not negated goals.
3. **Requirements** — split **functional** (what the system does) from
   **non-functional** (the qualities and constraints it must hold).
4. **Background** — the problem context that motivated it; objective
   facts only.
5. **Repositories** — multi-repo systems only; drop for a single repo.
6. **High-level architecture** — a mermaid diagram of the whole system.
7. **Components** — table of parts with each part's responsibility,
   linking the per-service docs.
8. **Component internals** — per-part flow at the invariant level; defer
   to the service docs beyond a paragraph.
9. **Security** — trust boundaries and enforcement.
10. **Decisions and alternatives** — the choices that shaped the system;
    link the settling ADR.
11. **Risks and known issues** — operational risks and known holes;
    actionable items get a file in `issues/`.
12. **Testing** — the commands and what they cover.
13. **Operations** — how to run, observe, and steer the system.
14. **References**, **Notes**, and an "In this directory" table.

### Service subtrees — `architecture/<service>/`

One directory per service or coherent subsystem (`api`, `web`, `worker`,
`infra`…). The `README.md` is the hub: context and goals, invariants,
surface-wide conventions, the index of its docs. Each `<topic>.md`
documents one unit of change. The templates ship three canonical kinds —
copy the dirs you need:

- **API** — `api/README.md` hub + one `<resource>.md` per contract
  surface. Keep surface docs at contract level — endpoint tables,
  lifecycle state machines, request flow, caller-visible semantics.
  **Never inline schemas or field lists**: link the OpenAPI/protobuf
  source of truth (and list it in `sources:`); inlined schemas rot. A
  cross-cutting policy that outgrows the hub's Conventions section gets
  its own file — `authentication.md`, `error-handling.md`,
  `versioning.md`.
- **Frontend** — `web/README.md` hub + one `<route>.md` per route:
  data dependencies, states, degraded behavior, transport and rendering
  decisions — not visual specs.
- **Infrastructure** — `infra/README.md` hub (topology diagram, service
  map, observability, scaling model) + one `<mechanism>.md` per
  mechanism. Each mechanism doc declares `services:` in frontmatter and
  repeats the mapping in a Service impact table with blast radius, so
  an infra change's reviewers can see who breaks.

A service with no kind template uses `architecture/__service__/` — the
hub shape minus the kind-specific index. A part of the system too small
for a directory stays a flat `architecture/<component>.md`; when it
grows several docs, promote it to a directory named after it.

### Glossary — `architecture/glossary.md`

The single source of truth for ubiquitous domain terms. Every other doc
links a term instead of redefining it; a design doc defines only the
concepts the proposal itself introduces and promotes them to the
glossary when the change ships.

## Proposal docs — `docs/design-docs/`

Written before implementation, reviewed as a PR, frozen once shipped —
then the `architecture/` docs carry the living truth. Numbered like ADRs
and issues — `NNNN-<slug>` per file or directory — so the listing orders
them and parallel doc PRs never fight over names.

- **Shape** — a change that fits one PR is a flat `NNNN-<change>.md`; a
  multi-PR change gets `NNNN-<change>/` with a `README.md` plus one
  `phase-N-<slug>.md` per phase. Skip the doc entirely when the change
  is unambiguous.
- **The root doc is self-contained for review** — context (with a
  `**Resolves:**` link to the issues it settles), goals/non-goals,
  options and trade-offs, proposed architecture, rollout and migration,
  rollback, success metrics, open questions. A reviewer reads the README
  alone; design narrative never lives in phase files.
- **Phase files are execution surfaces** — scope pointer, task
  checklist, acceptance criteria, risks, progress log, PR link. A phase
  is the smallest independently mergeable increment: one phase ≈ one
  PR, and the system stays coherent after each lands. Executing them —
  confirming PR granularity, managing stacked PRs — is workflow, not doc
  convention: it lives in `spec-driven-development`.
- **Frontmatter links** — `issues:` the IDs it resolves (issue docs
  point back with `resolved_by:`); `designs:` the living docs it
  modifies. When a phase merges, update the doc's status/phase index
  and the `designs:` docs in the same commit, like the `sources:`
  contract. Design docs themselves omit `sources:` — a proposal is a
  point-in-time record, not a living derivation.
- **No index table** — `design-docs/README.md` holds conventions only;
  the listing plus each doc's `status:`/`issues:`/`designs:` frontmatter
  is the index.
- **Archiving** — the PR that ships the last phase (or drops the
  proposal) moves the file or directory to `design-docs/archived/` in
  the same PR, sets `status: done`/`dropped`, and records `closed_pr:` —
  no post-merge archive step, nothing left in-flight as `in-progress`.

## ADRs — `docs/adr/NNNN-<slug>.md`

Record every significant decision in the same commit that introduces it:

- Sequential number, kebab-case slug; `type: ADR`, `status: accepted`.
  Body: Context → Decision → Consequences. Context is where the
  alternatives and their trade-offs live.
- `templates/adr/0001-record-architecture-decisions.md` doubles as a
  project's ADR-0001 — adopt it verbatim and the convention records
  itself.
- Immutable point-in-time records — write a new ADR when a decision is
  revisited. No index table; the numbered listing is the index.

## Issues — `docs/issues/`

Known problems and improvement backlog as a scannable directory:

- `NNNN-<slug>.md` — one file per issue, numbered like ADRs. No index
  table. A file can stay thin — frontmatter plus a Problem paragraph;
  grow it with Evidence → Impact → Options → Resolution as earned.
- `status:` — open · investigating · planned · in-progress are active;
  done · deferred · wontfix: the closing PR moves the file to
  `archived/` and records `closed_pr:` in frontmatter.
- `resolved_by:` — the design doc or PR once scheduled.
- Line-drawing: an issue tracker owns assigned, actively-worked tasks;
  `docs/issues/` owns the visible backlog of *known* problems.

## Writing rules

- **Update docs in the same commit** as the behavior change.
- **Checkable claims only** — no counts or universal quantifiers over
  code-derived facts ("every agent implements …", "28 checks") unless a
  test asserts them; enumerate the matrix or name the exception instead.
- **Don't restate files** — if reading a file answers it (config layout,
  versions, job lists), point at the file or state the rule behind it.
- **Link neighbors** — `docs/README.md` is the entry point; every doc
  links the docs it depends on.

## Docs in the workflow

- The design doc PR *is* the review — reviewers read the rendered
  markdown, not a meeting invite.
- `docs/README.md` answers the newcomer's first question: "where is the
  design doc?"
- The `sources:` contract plus same-commit updates substitutes for a
  maintenance phase — staleness fails in review, not a year later.
- Multi-repo changes: one design-doc dir per repo, cross-linked via a
  Companion docs table; shared contracts get reference docs both sides
  cite.
- Operational docs start life as service-scoped topics —
  `architecture/<service>/oncall.md` and the like, kept fresh by the
  `sources:` contract. Promote them to a top-level `docs/runbooks/`
  only when on-call search volume or quantity justifies it.
- Generated agent-facing docs (code indexes, task→file maps) live in
  their own tree, regenerated by scripts with the regeneration wired
  into CI — a generated tree whose regeneration lapses rots silently.
  Never hand-edit generated docs; fix the generator.

## Scaling with size

The layout is constant; what grows with scale is depth and formality —
requirements become explicit and measurable (SLOs, capacity budgets),
alternatives get quantitative analysis, proposals carry named reviewers
and lifecycle status, review widens from PR comments to cross-team
sign-off. Length runs ~1–3 pages per living doc at small scale to
10–20 pages for a major proposal — split the problem beyond that. At
large scale add dedicated security/privacy docs, risk registers, and a
central index as organizational memory.

## Procedure

1. **Starting a project's docs** — copy `templates/` to `docs/`; fill in
   `README.md` and `architecture/`, keep `adr/0001-…` if the project
   records decisions, drop the subtrees that don't apply.
2. **Adding or changing a component** — write or update its service dir
   or component doc; update the overview's Components and "In this
   directory" tables.
3. **Changing behavior** — update every living doc whose `sources:`
   intersects the changed files, in the same commit.
4. **Proposing a change** — write `design-docs/NNNN-<change>.md` (one
   PR) or `NNNN-<change>/` (multi-PR); link the issues it resolves.
5. **Making a significant decision** — add `docs/adr/NNNN-<slug>.md`.
6. **Closing out** — the delivering PR archives the record: move a
   shipped/dropped design doc to `design-docs/archived/` or a closed
   issue to `issues/archived/`, set the terminal `status:`, and record
   `closed_pr:` — all in that same PR.

## References

- [Design Docs at Google](https://www.industrialempathy.com/posts/design-docs-at-google/)
  — anatomy, lifecycle, and when not to write one
- [Google Open Knowledge Format v0.2](https://github.com/google/open-knowledge-format)
  — frontmatter convention
