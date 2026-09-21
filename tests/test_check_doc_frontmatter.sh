#!/usr/bin/env bash
# test_check_doc_frontmatter.sh — fixture-repo tests for
# check-doc-frontmatter.sh.
#
# Each case builds a scratch git repo with a docs/ tree and asserts on
# exit code and output. The script is not diff-based — no commits needed.
set -u
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$(pwd)/.agents/skills/design-doc/scripts/check-doc-frontmatter.sh"
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

# new_repo <dir> — init a scratch repo (script needs a git toplevel).
new_repo() {
  git init -qb main "$1"
  git -C "$1" config user.email test@example.com
  git -C "$1" config user.name test
}

# run_check <dir> — run the script inside the repo.
run_check() { (cd "$1" && bash "$SCRIPT" 2>&1); }

# good_doc <path> — write a doc with valid frontmatter.
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

# --- case: valid frontmatter passes -----------------------------------
r=$(mktemp -d); new_repo "$r"
good_doc "$r/docs/design/a.md"
out=$(run_check "$r"); rc=$?
check "valid doc passes" 0

# --- case: live doc without frontmatter fails -------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"; echo "# no fm" > "$r/docs/design/a.md"
out=$(run_check "$r"); rc=$?
check "missing frontmatter fails" 1 "missing frontmatter"

# --- case: unterminated frontmatter fails -----------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"; printf -- '---\ntype: Design Doc\n' > "$r/docs/design/a.md"
out=$(run_check "$r"); rc=$?
check "unterminated frontmatter fails" 1 "unterminated"

# --- case: missing required key fails ----------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"
cat > "$r/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
last_modified: 2026-09-21
---
# body
EOF
out=$(run_check "$r"); rc=$?
check "missing status fails" 1 "missing required key: status"

# --- case: unknown type fails; Plan is accepted ------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design" "$r/docs/plan/p"
cat > "$r/docs/design/a.md" <<'EOF'
---
type: NotAType
title: Sample
status: current
last_modified: 2026-09-21
---
# body
EOF
cat > "$r/docs/plan/p/README.md" <<'EOF'
---
type: Plan
title: Sample plan
status: in-progress
last_modified: 2026-09-21
---
# plan
EOF
out=$(run_check "$r"); rc=$?
check "unknown type fails" 1 "unknown type: NotAType"

r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/plan/p"
cat > "$r/docs/plan/p/README.md" <<'EOF'
---
type: Plan
title: Sample plan
status: in-progress
last_modified: 2026-09-21
---
# plan
EOF
out=$(run_check "$r"); rc=$?
check "type Plan accepted" 0

# --- case: malformed last_modified fails -------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"
cat > "$r/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: yesterday
---
# body
EOF
out=$(run_check "$r"); rc=$?
check "bad date fails" 1 "not YYYY-MM-DD"

# --- case: unquoted ': ' scalar fails ----------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"
cat > "$r/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
description: covers the bug: a race in teardown
---
# body
EOF
out=$(run_check "$r"); rc=$?
check "unquoted colon-space fails" 1 "unquoted scalar"

# --- case: character-split inline list fails ---------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"
cat > "$r/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [f, r, o, n, t, e, n, d]
---
# body
EOF
out=$(run_check "$r"); rc=$?
check "char-split list fails" 1 "character-split"

# --- case: empty item in inline list fails ------------------------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/design"
cat > "$r/docs/design/a.md" <<'EOF'
---
type: Design Doc
title: Sample
status: current
last_modified: 2026-09-21
tags: [a, , b]
---
# body
EOF
out=$(run_check "$r"); rc=$?
check "empty list item fails" 1 "empty item"

# --- case: archives are exempt from the frontmatter requirement --------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/plan/archived" "$r/docs/reviews"
echo "# old plan" > "$r/docs/plan/archived/p.md"
echo "# review record" > "$r/docs/reviews/r.md"
out=$(run_check "$r"); rc=$?
check "archives exempt" 0

# --- case: archive doc with frontmatter is still validated --------------
r=$(mktemp -d); new_repo "$r"
mkdir -p "$r/docs/plan/archived"
printf -- '---\ntype: Bogus\n---\n# old plan\n' > "$r/docs/plan/archived/p.md"
out=$(run_check "$r"); rc=$?
check "archive frontmatter still validated" 1 "unknown type"

# --- case: no docs/ passes ---------------------------------------------
r=$(mktemp -d); new_repo "$r"
out=$(run_check "$r"); rc=$?
check "no docs/ passes" 0

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
