#!/usr/bin/env bash
# test_doc_checks_ci.sh — fixture-repo tests for doc-checks-ci.sh.
#
# Each case builds a scratch git repo and asserts on exit code, output,
# and the resulting workflow file contents.
set -u
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$(pwd)/.agents/skills/doc-checks-ci/scripts/doc-checks-ci.sh"
readonly SCRIPT

pass=0 fail=0
ok()  { pass=$((pass+1)); echo "ok   $1"; }
bad() { fail=$((fail+1)); echo "FAIL $1"; }

# check <name> <want-rc> [needle] — asserts on $rc and $out.
check() {
  local name="$1" want_rc="$2" needle="${3:-}"
  if [[ ${rc} -eq ${want_rc} && ( -z "${needle}" || ${out} == *"${needle}"* ) ]]; then
    ok "${name}"
  else
    bad "${name}: rc=${rc} (want ${want_rc})"
    echo "${out}"
  fi
}

# filecheck <name> <file> <needle> — asserts the file contains needle.
filecheck() {
  if grep -qF "$3" "$2"; then ok "$1"; else bad "$1: '$3' not in $2"; fi
}

# nocheck <name> <file> <needle> — asserts the file does NOT contain needle.
nocheck() {
  if grep -qF "$3" "$2"; then bad "$1: '$3' still in $2"; else ok "$1"; fi
}

new_repo() {
  git init -qb main "$1"
  git -C "$1" config user.email test@example.com
  git -C "$1" config user.name test
  git -C "$1" commit -qm init --allow-empty
}

run_in() { (cd "$1" && shift && bash "$SCRIPT" "$@" 2>&1); }

existing_ci() {
  mkdir -p "$1/.github/workflows"
  cat > "$1/.github/workflows/ci.yaml" <<'EOF'
name: CI

on:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - run: make test
EOF
}

# --- case: install creates a workflow when none exists -----------------
r=$(mktemp -d); new_repo "$r"
out=$(run_in "$r" install); rc=$?
check "install creates ci.yaml" 0 "created"
filecheck "  has jobs:" "$r/.github/workflows/ci.yaml" "jobs:"
filecheck "  has docs job" "$r/.github/workflows/ci.yaml" "  docs:"
filecheck "  has start anchor" "$r/.github/workflows/ci.yaml" "# doc-checks-ci:start"
filecheck "  has stale run" "$r/.github/workflows/ci.yaml" "check-docs-stale.sh"
filecheck "  has frontmatter run" "$r/.github/workflows/ci.yaml" "check-doc-frontmatter.sh"

# --- case: install into an existing workflow preserves jobs ------------
r=$(mktemp -d); new_repo "$r"; existing_ci "$r"
out=$(run_in "$r" install); rc=$?
check "install into existing" 0 "installed"
filecheck "  keeps test job" "$r/.github/workflows/ci.yaml" "  test:"
filecheck "  adds docs job" "$r/.github/workflows/ci.yaml" "  docs:"
filecheck "  keeps trigger" "$r/.github/workflows/ci.yaml" "pull_request:"

# --- case: install is idempotent ---------------------------------------
r=$(mktemp -d); new_repo "$r"; existing_ci "$r"
run_in "$r" install >/dev/null
out=$(run_in "$r" install); rc=$?
check "second install is a no-op" 0 "already installed"
n=$(grep -c "doc-checks-ci:start" "$r/.github/workflows/ci.yaml")
if [[ $n -eq 1 ]]; then ok "  single anchored block"; else bad "  anchor count: $n"; fi

# --- case: uninstall removes only the anchored block --------------------
r=$(mktemp -d); new_repo "$r"; existing_ci "$r"
run_in "$r" install >/dev/null
out=$(run_in "$r" uninstall); rc=$?
check "uninstall" 0 "removed"
nocheck "  anchors gone" "$r/.github/workflows/ci.yaml" "doc-checks-ci"
filecheck "  test job kept" "$r/.github/workflows/ci.yaml" "  test:"
filecheck "  jobs key kept" "$r/.github/workflows/ci.yaml" "jobs:"

# --- case: uninstall when nothing installed is a no-op ------------------
r=$(mktemp -d); new_repo "$r"; existing_ci "$r"
out=$(run_in "$r" uninstall); rc=$?
check "uninstall no-op" 0 "not installed"
filecheck "  file untouched" "$r/.github/workflows/ci.yaml" "  test:"

# --- case: workflow without jobs: fails honestly ------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/.github/workflows"
printf 'name: CI\n\non:\n  pull_request:\n' > "$r/.github/workflows/ci.yaml"
out=$(run_in "$r" install); rc=$?
check "no jobs key fails" 1 "no 'jobs:' mapping"
nocheck "  nothing written" "$r/.github/workflows/ci.yaml" "doc-checks-ci"

# --- case: status reports both states -----------------------------------
r=$(mktemp -d); new_repo "$r"; existing_ci "$r"
out=$(run_in "$r" status); rc=$?
check "status absent" 0 "not installed"
run_in "$r" install >/dev/null
out=$(run_in "$r" status); rc=$?
check "status present" 0 "installed ("

# --- case: --workflow targets another file ------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/.github/workflows"
cat > "$r/.github/workflows/docs.yaml" <<'EOF'
name: docs
on:
  pull_request:
jobs:
  lint:
    runs-on: ubuntu-latest
    steps: []
EOF
out=$(run_in "$r" install --workflow .github/workflows/docs.yaml); rc=$?
check "custom workflow path" 0 "installed"
filecheck "  wrote that file" "$r/.github/workflows/docs.yaml" "# doc-checks-ci:start"
nocheck "  ci.yaml untouched" "$r/.github/workflows/docs.yaml" "make test"

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
