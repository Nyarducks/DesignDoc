#!/usr/bin/env bats
# check-docs-stale.bats — fixture-repo tests for check-docs-stale.sh.
#
# Each case builds a scratch git repo with a docs/ tree, commits a base
# on main, applies a change on a branch, then runs the script with
# base=main and asserts on exit code and output.

SCRIPT="$(cd "$BATS_TEST_DIRNAME/../scripts" && pwd)/check-docs-stale.sh"

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

# init a scratch repo with an initial commit on main.
new_repo() {
  git init -qb main "$REPO"
  git -C "$REPO" config user.email test@example.com
  git -C "$REPO" config user.name test
  git -C "$REPO" commit -qm init --allow-empty
}

# stage and commit everything on the current branch.
commit_all() { git -C "$REPO" add -A && git -C "$REPO" commit -qm change; }

# run the script inside the repo, base=main.
run_check() { (cd "$REPO" && bash "$SCRIPT" main 2>&1); }

# write a frontmatter doc: doc <path> <sources>
doc() {
  mkdir -p "$(dirname "$1")"
  printf -- '---\ntype: Design Doc\nsources: [%s]\n---\n# doc\n' "$2" > "$1"
}

@test "clean repo passes" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/architecture"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/architecture/a.md" src/a.c
  commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "stale doc fails" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/architecture"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/architecture/a.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 1 ]
  contains "STALE"
}

@test "same-commit update passes" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/architecture"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/architecture/a.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; echo update >> "$REPO/docs/architecture/a.md"; commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "deleted source fails" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/architecture"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/architecture/a.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  rm "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 1 ]
  contains "MISSING"
}

@test "adr excluded" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/adr"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/adr/0001-x.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "example excluded" {
  new_repo
  doc "$REPO/docs/example/architecture/x.md" no/such/file.c
  commit_all; git -C "$REPO" checkout -qb feat
  run run_check
  [ "$status" -eq 0 ]
}

@test "dir source: sibling prefix not matched" {
  new_repo
  mkdir -p "$REPO/src/pkg" "$REPO/src/pkgx" "$REPO/docs/architecture"
  echo x > "$REPO/src/pkg/a.c"; echo x > "$REPO/src/pkgx/b.c"
  doc "$REPO/docs/architecture/a.md" src/pkg
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/pkgx/b.c"; commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "dir source: nested change flagged" {
  new_repo
  mkdir -p "$REPO/src/pkg" "$REPO/src/pkgx" "$REPO/docs/architecture"
  echo x > "$REPO/src/pkg/a.c"; echo x > "$REPO/src/pkgx/b.c"
  doc "$REPO/docs/architecture/a.md" src/pkg
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/pkg/a.c"; commit_all
  run run_check
  [ "$status" -eq 1 ]
  contains "STALE"
}

@test "empty sources passes" {
  new_repo
  doc "$REPO/docs/architecture/a.md" ""
  commit_all; git -C "$REPO" checkout -qb feat
  run run_check
  [ "$status" -eq 0 ]
}

@test "no docs/ passes" {
  new_repo
  git -C "$REPO" checkout -qb feat
  run run_check
  [ "$status" -eq 0 ]
}

@test "block-style sources flagged" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/architecture"; echo x > "$REPO/src/a.c"
  cat > "$REPO/docs/architecture/a.md" <<'EOF'
---
type: Design Doc
sources:
  - src/a.c
---
# doc
EOF
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 1 ]
  contains "STALE"
}

@test "archived design doc excluded" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/design-docs/archived/old"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/design-docs/archived/old/README.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "archived issue excluded" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/issues/archived"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/issues/archived/old.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "review records excluded" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/reviews"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/reviews/r.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 0 ]
}

@test "active design doc sources still enforced" {
  new_repo
  mkdir -p "$REPO/src" "$REPO/docs/design-docs/p"; echo x > "$REPO/src/a.c"
  doc "$REPO/docs/design-docs/p/README.md" src/a.c
  commit_all; git -C "$REPO" checkout -qb feat
  echo y > "$REPO/src/a.c"; commit_all
  run run_check
  [ "$status" -eq 1 ]
  contains "STALE"
}
