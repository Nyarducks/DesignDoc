#!/usr/bin/env bash
# test_check_docs_stale.sh — fixture-repo tests for check-docs-stale.sh.
#
# Each case builds a scratch git repo with a docs/ tree, commits a base
# on main, applies a change on a branch, then runs the script with
# base=main and asserts on exit code and output.
set -u
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$(pwd)/.agents/skills/design-doc/scripts/check-docs-stale.sh"
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

# new_repo <dir> — init a scratch repo with an initial commit on main.
new_repo() {
  git init -qb main "$1"
  git -C "$1" config user.email test@example.com
  git -C "$1" config user.name test
  git -C "$1" commit -qm init --allow-empty
}

# commit_all <dir> — stage and commit everything on the current branch.
commit_all() { git -C "$1" add -A && git -C "$1" commit -qm change; }

# run_check <dir> — run the script inside the repo, base=main.
run_check() { (cd "$1" && bash "$SCRIPT" main 2>&1); }

# doc <path> <sources> — write a frontmatter doc.
doc() {
  mkdir -p "$(dirname "$1")"
  printf -- '---\ntype: Design Doc\nsources: [%s]\n---\n# doc\n' "$2" > "$1"
}

# --- case: no changes — fresh -----------------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"
out=$(run_check "$r"); rc=$?
check "clean repo passes" 0

# --- case: source changed, doc untouched — STALE ----------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/a.c"; commit_all "$r"
out=$(run_check "$r"); rc=$?
check "stale doc fails" 1 STALE

# --- case: source + doc changed together — fresh ----------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/a.c"; echo update >> "$r/docs/design/a.md"; commit_all "$r"
out=$(run_check "$r"); rc=$?
check "same-commit update passes" 0

# --- case: source deleted — MISSING -----------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
rm "$r/src/a.c"; commit_all "$r"
out=$(run_check "$r"); rc=$?
check "deleted source fails" 1 MISSING

# --- case: docs/adr/ is never checked ---------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/adr"; echo x > "$r/src/a.c"
doc "$r/docs/adr/0001-x.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/a.c"; commit_all "$r"
out=$(run_check "$r"); rc=$?
check "adr excluded" 0

# --- case: docs/example/ sources are fictional — skipped --------------
r=$(mktemp -d); new_repo "$r"
doc "$r/docs/example/small/design/x.md" no/such/file.c
commit_all "$r"; git -C "$r" checkout -qb feat
out=$(run_check "$r"); rc=$?
check "example excluded" 0

# --- case: directory source covers its tree only ----------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src/pkg" "$r/src/pkgx" "$r/docs/design"
echo x > "$r/src/pkg/a.c"; echo x > "$r/src/pkgx/b.c"
doc "$r/docs/design/a.md" src/pkg
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/pkgx/b.c"; commit_all "$r"   # sibling dir — not a match
out=$(run_check "$r"); rc=$?
check "dir source: sibling prefix not matched" 0
echo y > "$r/src/pkg/a.c"; commit_all "$r"    # inside the dir — match
out=$(run_check "$r"); rc=$?
check "dir source: nested change flagged" 1 STALE

# --- case: empty sources and no docs/ --------------------------------
r=$(mktemp -d); new_repo "$r"
doc "$r/docs/design/a.md" ""
commit_all "$r"; git -C "$r" checkout -qb feat
out=$(run_check "$r"); rc=$?
check "empty sources passes" 0

r=$(mktemp -d); new_repo "$r"
git -C "$r" checkout -qb feat
out=$(run_check "$r"); rc=$?
check "no docs/ passes" 0

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
