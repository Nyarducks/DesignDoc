#!/usr/bin/env bash
# test_check_docs_stale.sh — fixture-repo tests for check-docs-stale.sh.
#
# Each case builds a scratch git repo with a docs/ tree, commits a base
# on main, applies a change on a branch, then runs the script with
# base=main and asserts on exit code and output.
set -u
cd "$(dirname "$0")/.."
SCRIPT="$(pwd)/.agents/skills/design-doc/scripts/check-docs-stale.sh"

pass=0 fail=0
ok()   { pass=$((pass+1)); echo "ok   $1"; }
bad()  { fail=$((fail+1)); echo "FAIL $1"; }

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
[[ $rc -eq 0 ]] && ok "clean repo passes" || { bad "clean repo: rc=$rc"; echo "$out"; }

# --- case: source changed, doc untouched — STALE ----------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/a.c"; commit_all "$r"
out=$(run_check "$r"); rc=$?
[[ $rc -eq 1 && "$out" == *"STALE"* ]] && ok "stale doc fails" \
  || { bad "stale doc: rc=$rc"; echo "$out"; }

# --- case: source + doc changed together — fresh ----------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/a.c"; echo update >> "$r/docs/design/a.md"; commit_all "$r"
out=$(run_check "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "same-commit update passes" || { bad "same-commit: rc=$rc"; echo "$out"; }

# --- case: source deleted — MISSING -----------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/design"; echo x > "$r/src/a.c"
doc "$r/docs/design/a.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
rm "$r/src/a.c"; commit_all "$r"
out=$(run_check "$r"); rc=$?
[[ $rc -eq 1 && "$out" == *"MISSING"* ]] && ok "deleted source fails" \
  || { bad "deleted source: rc=$rc"; echo "$out"; }

# --- case: docs/adr/ is never checked ---------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src" "$r/docs/adr"; echo x > "$r/src/a.c"
doc "$r/docs/adr/0001-x.md" src/a.c
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/a.c"; commit_all "$r"
out=$(run_check "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "adr excluded" || { bad "adr excluded: rc=$rc"; echo "$out"; }

# --- case: docs/example/ sources are fictional — skipped --------------
r=$(mktemp -d); new_repo "$r"
doc "$r/docs/example/small/design/x.md" no/such/file.c
commit_all "$r"; git -C "$r" checkout -qb feat
out=$(run_check "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "example excluded" || { bad "example excluded: rc=$rc"; echo "$out"; }

# --- case: directory source covers its tree only ----------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/src/pkg" "$r/src/pkgx" "$r/docs/design"
echo x > "$r/src/pkg/a.c"; echo x > "$r/src/pkgx/b.c"
doc "$r/docs/design/a.md" src/pkg
commit_all "$r"; git -C "$r" checkout -qb feat
echo y > "$r/src/pkgx/b.c"; commit_all "$r"   # sibling dir — not a match
out=$(run_check "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "dir source: sibling prefix not matched" \
  || { bad "dir prefix: rc=$rc"; echo "$out"; }
echo y > "$r/src/pkg/a.c"; commit_all "$r"    # inside the dir — match
out=$(run_check "$r"); rc=$?
[[ $rc -eq 1 && "$out" == *"STALE"* ]] && ok "dir source: nested change flagged" \
  || { bad "dir nested: rc=$rc"; echo "$out"; }

# --- case: empty sources and no docs/ --------------------------------
r=$(mktemp -d); new_repo "$r"
doc "$r/docs/design/a.md" ""
commit_all "$r"; git -C "$r" checkout -qb feat
out=$(run_check "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "empty sources passes" || { bad "empty sources: rc=$rc"; echo "$out"; }

r=$(mktemp -d); new_repo "$r"
commit_all "$r"; git -C "$r" checkout -qb feat
out=$(run_check "$r"); rc=$?
[[ $rc -eq 0 ]] && ok "no docs/ passes" || { bad "no docs: rc=$rc"; echo "$out"; }

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
