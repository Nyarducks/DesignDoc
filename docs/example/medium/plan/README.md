# Plans

Per-change proposal docs — written before implementation, reviewed as a
PR, updated by the PRs that implement them. One directory per change;
a change that fits a single PR is a lone `<change>.md` in this directory.

| Plan | Status | Resolves | Modifies |
|---|---|---|---|
| [bulk-import/](bulk-import/) | in-progress | [#0001](../issues/0001-worker-monopolization.md) | [worker](../design/worker.md) |

Status legend: draft · in-progress · done · dropped

Phases are milestones — the smallest independently mergeable increment,
roughly one PR each. When a phase merges, the design docs listed in
`designs:` are updated in the same commit.
