#!/usr/bin/env bats
# doc-checks-ci.bats — fixture-repo tests for doc-checks-ci.sh.
#
# Each case builds a scratch repo, runs install/uninstall/status, and
# asserts on exit code, output, and resulting workflow contents.

SCRIPT="$(cd "$BATS_TEST_DIRNAME/../scripts" && pwd)/doc-checks-ci.sh"

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

file_contains() {
  [ -f "$1" ] || { printf 'missing file: %s\n' "$1" >&2; return 1; }
  grep -qF "$2" "$1" || { printf 'expected %s to contain: %s\n' "$1" "$2" >&2; return 1; }
}

file_lacks() {
  [ ! -f "$1" ] && return 0
  ! grep -qF "$2" "$1" || { printf 'unexpected match in %s: %s\n' "$1" "$2" >&2; return 1; }
}

new_repo() {
  git init -qb main "$REPO"
  git -C "$REPO" config user.email test@example.com
  git -C "$REPO" config user.name test
}

run_install() { (cd "$REPO" && bash "$SCRIPT" install "$@" 2>&1); }
run_uninstall() { (cd "$REPO" && bash "$SCRIPT" uninstall "$@" 2>&1); }
run_status() { (cd "$REPO" && bash "$SCRIPT" status "$@" 2>&1); }

existing_ci() {
  mkdir -p "$REPO/.github/workflows"
  cat > "$REPO/.github/workflows/ci.yaml" <<'EOF'
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - run: shellcheck scripts/*.sh
EOF
}

@test "install creates workflow" {
  new_repo
  run run_install
  [ "$status" -eq 0 ]
  contains "installed docs job"
  file_contains "$REPO/.github/workflows/ci.yaml" "# doc-checks-ci:start"
  file_contains "$REPO/.github/workflows/ci.yaml" "# doc-checks-ci:end"
  file_contains "$REPO/.github/workflows/ci.yaml" "check-docs-stale.sh"
  file_contains "$REPO/.github/workflows/ci.yaml" "check-doc-frontmatter.sh"
  file_contains "$REPO/.github/workflows/ci.yaml" "github.base_ref"
}

@test "install is idempotent" {
  new_repo
  run run_install; [ "$status" -eq 0 ]
  run run_install
  [ "$status" -eq 0 ]
  contains "already installed"
}

@test "install inserts job into existing workflow" {
  new_repo; existing_ci
  run run_install
  [ "$status" -eq 0 ]
  file_contains "$REPO/.github/workflows/ci.yaml" "lint:"
  file_contains "$REPO/.github/workflows/ci.yaml" "# doc-checks-ci:start"
}

@test "existing job intact after uninstall" {
  new_repo; existing_ci
  run run_install; [ "$status" -eq 0 ]
  run run_uninstall
  [ "$status" -eq 0 ]
  file_contains "$REPO/.github/workflows/ci.yaml" "lint:"
  file_lacks "$REPO/.github/workflows/ci.yaml" "doc-checks-ci"
}

@test "status reports absent" {
  new_repo
  run run_status
  [ "$status" -eq 0 ]
  contains "not installed"
}

@test "status reports installed" {
  new_repo; run run_install
  run run_status
  [ "$status" -eq 0 ]
  contains "installed"
}

@test "uninstall when absent is a no-op" {
  new_repo
  run run_uninstall
  [ "$status" -eq 0 ]
  contains "not installed"
}

@test "round trip twice" {
  new_repo; existing_ci
  run run_install; [ "$status" -eq 0 ]
  run run_uninstall; [ "$status" -eq 0 ]
  run run_install; [ "$status" -eq 0 ]
  run run_uninstall
  [ "$status" -eq 0 ]
  file_contains "$REPO/.github/workflows/ci.yaml" "lint:"
  file_lacks "$REPO/.github/workflows/ci.yaml" "doc-checks-ci"
}

@test "install: ci.yaml without jobs fails" {
  new_repo
  mkdir -p "$REPO/.github/workflows"
  printf 'name: CI\non: push\n' > "$REPO/.github/workflows/ci.yaml"
  run run_install
  [ "$status" -eq 1 ]
  contains "'jobs:'"
}

@test "unknown command fails" {
  new_repo
  run bash -c "cd \"$REPO\" && bash \"$SCRIPT\" bogus 2>&1"
  [ "$status" -ne 0 ]
}

@test "--workflow override" {
  new_repo
  run run_install --workflow .buildkite/pipe.yaml
  [ "$status" -eq 0 ]
  file_contains "$REPO/.buildkite/pipe.yaml" "# doc-checks-ci:start"
  file_lacks "$REPO/.github/workflows/ci.yaml" "doc-checks-ci"
}

@test "--scripts-dir override" {
  new_repo
  run run_install --scripts-dir .agents/skills/design-doc/scripts
  [ "$status" -eq 0 ]
  file_contains "$REPO/.github/workflows/ci.yaml" ".agents/skills/design-doc/scripts"
}

@test "status after uninstall" {
  new_repo
  run run_install; [ "$status" -eq 0 ]
  run run_uninstall; [ "$status" -eq 0 ]
  run run_status
  [ "$status" -eq 0 ]
  contains "not installed"
}
