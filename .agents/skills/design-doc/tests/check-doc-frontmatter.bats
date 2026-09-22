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

# run the script inside the scratch repo.
run_check() { (cd "$REPO" && bash "$SCRIPT" 2>&1); }

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
  good_doc "$REPO/docs/architecture/a.md"
  run run_check
  [ "$status" -eq 0 ]
}

@test "missing frontmatter fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"; echo "# no fm" > "$REPO/docs/architecture/a.md"
  run run_check
  [ "$status" -eq 1 ]
  contains "missing frontmatter"
}

@test "unterminated frontmatter fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"; printf -- '---\ntype: Design Doc\n' > "$REPO/docs/architecture/a.md"
  run run_check
  [ "$status" -eq 1 ]
  contains "unterminated"
}

@test "missing required key fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Design Doc
title: Sample
last_modified: 2026-09-21
---
# body
EOF
  run run_check
  [ "$status" -eq 1 ]
  contains "missing required key: status"
}

@test "unknown type fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: NotAType
title: Sample
status: current
last_modified: 2026-09-21
---
# body
EOF
  run run_check
  [ "$status" -eq 1 ]
  contains "unknown type: NotAType"
}

@test "type Plan accepted (phase doc)" {
  new_repo
  mkdir -p "$REPO/docs/design-docs/p"
  cat > "$REPO/docs/design-docs/p/README.md" <<'EOF'
---
type: Plan
title: Sample design doc
status: in-progress
last_modified: 2026-09-21
---
# design doc
EOF
  run run_check
  [ "$status" -eq 0 ]
}

@test "type Architecture accepted" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Architecture
title: Sample living doc
status: current
last_modified: 2026-09-21
---
# doc
EOF
  run run_check
  [ "$status" -eq 0 ]
}

@test "bad date fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: yesterday
---
# body
EOF
  run run_check
  [ "$status" -eq 1 ]
  contains "not YYYY-MM-DD"
}

@test "unquoted colon-space fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
description: covers the bug: a race in teardown
---
# body
EOF
  run run_check
  [ "$status" -eq 1 ]
  contains "unquoted scalar"
}

@test "char-split list fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [f, r, o, n, t, e, n, d]
---
# body
EOF
  run run_check
  [ "$status" -eq 1 ]
  contains "character-split"
}

@test "empty list item fails" {
  new_repo
  mkdir -p "$REPO/docs/architecture"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [a, , b]
---
# body
EOF
  run run_check
  [ "$status" -eq 1 ]
  contains "empty item"
}

@test "archives exempt" {
  new_repo
  mkdir -p "$REPO/docs/design-docs/archived" "$REPO/docs/reviews" "$REPO/docs/example/design-docs/archived" "$REPO/docs/issues/archived"
  echo "# old design doc" > "$REPO/docs/design-docs/archived/p.md"
  echo "# review record" > "$REPO/docs/reviews/r.md"
  echo "# nested archive" > "$REPO/docs/example/design-docs/archived/x.md"
  echo "# closed issue" > "$REPO/docs/issues/archived/i.md"
  run run_check
  [ "$status" -eq 0 ]
}

@test "archive frontmatter still validated" {
  new_repo
  mkdir -p "$REPO/docs/design-docs/archived"
  printf -- '---\ntype: Bogus\n---\n# old design doc\n' > "$REPO/docs/design-docs/archived/p.md"
  run run_check
  [ "$status" -eq 1 ]
  contains "unknown type"
}

@test "no docs/ passes" {
  new_repo
  run run_check
  [ "$status" -eq 0 ]
}
