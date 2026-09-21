---
name: doc-checks-ci
description: >-
  Wire the design-doc check scripts into a project's CI workflow —
  installs an anchored docs job into .github/workflows/ci.yaml that runs
  the sources: contract and frontmatter checks on every PR. Opt in or
  out with one command; requires the design-doc skill.
---

# Doc checks CI

The enforcement half of design docs: the `sources:` contract and OKF
frontmatter only hold if CI actually runs the checks. This skill
installs a `docs` job into the project's workflow that runs
`check-docs-stale.sh` and `check-doc-frontmatter.sh` from the
`design-doc` skill — install that skill first.

## Installing into a project

The skill ships alone — no `AGENTS.md` comes with it. After installing,
append this block to the project's `AGENTS.md` (create the file if
missing). The anchors delimit the block so it can be opted in or out at
any time:

```markdown
<!-- doc-checks-ci:start -->
## Docs CI checks

- `.github/workflows/ci.yaml` carries an anchored `docs` job
  (`# doc-checks-ci:start/end`) running the design-doc check scripts —
  a PR that changes a doc's declared `sources:` must update the doc in
  the same PR, and frontmatter must stay valid.
- Manage it with `doc-checks-ci.sh` (`install` / `uninstall` /
  `status`); do not hand-edit inside the anchors.
<!-- doc-checks-ci:end -->
```

## Usage

From the repo root:

```bash
.agents/skills/doc-checks-ci/scripts/doc-checks-ci.sh install    # opt in
.agents/skills/doc-checks-ci/scripts/doc-checks-ci.sh status     # is it wired?
.agents/skills/doc-checks-ci/scripts/doc-checks-ci.sh uninstall  # opt out
```

Flags: `--workflow PATH` (default `.github/workflows/ci.yaml`),
`--scripts-dir PATH` (default `.agents/skills/design-doc/scripts` —
point elsewhere if the design-doc skill lives at a custom path).

## How it works

- **Idempotent install** — if the anchors are already present, install
  is a no-op; re-running never duplicates the job.
- **No `ci.yaml` yet** — install creates a minimal workflow
  (`pull_request` + `push` to `main`) containing just the `docs` job.
- **Existing `ci.yaml`** — the block is inserted at the top of the
  `jobs:` map; existing jobs and triggers are untouched. A workflow
  without a `jobs:` key fails with a message instead of guessing.
- **Opt out** — `uninstall` deletes everything between the anchors and
  nothing else; the workflow file keeps its formatting.
- **The job** — checks out with full history (the sources check diffs
  against the base ref), then runs the freshness check against
  `github.base_ref` (or the repo default branch on pushes) and the
  frontmatter check.

## Notes

- The job references the check scripts *inside* the installed
  `design-doc` skill — removing that skill without uninstalling the CI
  job breaks the workflow. Uninstall here first.
- The anchors are the opt-in/out mechanism — the same convention as the
  `AGENTS.md` blocks. Keep edits outside them so `uninstall` stays
  surgical.
