#!/usr/bin/env bats
# check-doc-frontmatter.bats — fixture-repo tests for
# check-doc-frontmatter.sh.
#
# Each case builds a scratch git repo with a docs/ tree and asserts on
# exit code and output. The script is not diff-based — no commits needed.

SCRIPT="$(cd "$BATS_TEST_DIRNAME/../scripts" && pwd)/check-doc-frontmatter.sh"

setup() {
  REPO=$(mktemp -d)
}

teardown() {
  rm -rf "$REPO"
}

contains() {
  if ! echo "$output" | grep -qF "$1"; then
    printf 'Expected output to contain: %s\nActual output:\n%s\n' "$1" "$output" >&2
    return 1
  fi
}

# init a scratch repo (the script needs a git toplevel).
new_repo() {
  git init -qb main "$REPO"
  git -C "$REPO" config user.email test@example.com
  git -C "$REPO" config user.name test
}

# write a doc with valid frontmatter.
good_doc() {
  mkdir -p "$(dirname "$1")"
  cat > "$1" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [topic]
sources: []
---
# body
EOF
}

@test "valid doc passes" {
  new_repo
  good_doc "$REPO/docs/design/a.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "missing frontmatter fails" {
  new_repo
  mkdir -p "$REPO/docs/design"; echo "# no fm" > "$REPO/docs/design/a.md"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "missing frontmatter"
}

@test "unterminated frontmatter fails" {
  new_repo
  mkdir -p "$REPO/docs/design"; printf -- '---\ntype: Design Doc\n' > "$REPO/docs/design/a.md"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "unterminated"
}

@test "missing required key fails" {
  new_repo
  mkdir -p "$REPO/docs/design"
  cat > "$REPO/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
last_modified: 2026-09-21
---
# body
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "missing required key: status"
}

@test "unknown type fails" {
  new_repo
  mkdir -p "$REPO/docs/design"
  cat > "$REPO/docs/design/a.md" <<'EOF'
---
type: NotAType
title: Sample
status: current
last_modified: 2026-09-21
---
# body
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "unknown type: NotAType"
}

@test "type Plan accepted" {
  new_repo
  mkdir -p "$REPO/docs/plan/p"
  cat > "$REPO/docs/plan/p/README.md" <<'EOF'
---
type: Plan
title: Sample plan
status: in-progress
last_modified: 2026-09-21
---
# plan
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "bad date fails" {
  new_repo
  mkdir -p "$REPO/docs/design"
  cat > "$REPO/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: yesterday
---
# body
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "not YYYY-MM-DD"
}

@test "unquoted colon-space fails" {
  new_repo
  mkdir -p "$REPO/docs/design"
  cat > "$REPO/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
description: covers the bug: a race in teardown
---
# body
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "unquoted scalar"
}

@test "char-split list fails" {
  new_repo
  mkdir -p "$REPO/docs/design"
  cat > "$REPO/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [f, r, o, n, t, e, n, d]
---
# body
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "character-split"
}

@test "empty list item fails" {
  new_repo
  mkdir -p "$REPO/docs/design"
  cat > "$REPO/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [a, , b]
---
# body
EOF
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "empty item"
}

@test "archives exempt" {
  new_repo
  mkdir -p "$REPO/docs/plan/archived" "$REPO/docs/reviews"
  echo "# old plan" > "$REPO/docs/plan/archived/p.md"
  echo "# review record" > "$REPO/docs/reviews/r.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "archive frontmatter still validated" {
  new_repo
  mkdir -p "$REPO/docs/plan/archived"
  printf -- '---\ntype: Bogus\n---\n# old plan\n' > "$REPO/docs/plan/archived/p.md"
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  contains "unknown type"
}

@test "no docs/ passes" {
  new_repo
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
}
