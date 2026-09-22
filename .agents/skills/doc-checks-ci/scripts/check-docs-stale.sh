#!/usr/bin/env bash
# check-docs-stale.sh — enforce the docs freshness contract.
#
# Docs under docs/ declare the files they are derived from in their
# `sources:` frontmatter. This script fails when:
#
#   MISSING  a declared source path no longer exists (renamed/deleted)
#   STALE    a source changed in <base>...HEAD but the doc did not
#
# Skipped on purpose — point-in-time or fictional records are not
# freshness-bound:
#   docs/adr/             immutable records — a revisited decision gets
#                         a new ADR, never an edit
#   docs/design-docs/archived/   frozen design docs — done/dropped
#                            docs never update
#   docs/issues/archived/ closed issues — done/deferred/wontfix records
#   docs/reviews/         review records — audits, not living docs
#   docs/example/         worked examples; their declared sources are
#                         fictional
#
# Usage: check-docs-stale.sh [base-ref]   (default: origin/main)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [[ ! -d docs ]]; then
  echo "docs fresh: no docs/ directory"
  exit 0
fi

base="${1:-}"
if [[ -z "${base}" ]]; then
  # the default base may not exist locally yet — fetch, but stay usable
  # in offline/single-branch clones where it simply fails below
  git fetch -q origin main 2>/dev/null || true
  base="origin/main"
fi
merge_base="$(git merge-base "${base}" HEAD)"
changed="$(git diff --name-only "${merge_base}" HEAD)"
readonly base merge_base changed

# Print the `sources:` entries of doc $1, one per line. Both YAML list
# forms are read — flow (`sources: [a, b]`) and block (`sources:` then
# `- a` lines) — so a doc cannot escape the contract by restyling.
extract_sources() {
  awk '
    NR == 1 { if ($0 != "---") exit; next }  # not frontmatter — stop
    /^---$/ { exit }                          # closing ---
    /^sources:/ {
      line = $0; sub(/^sources:[[:space:]]*/, "", line)
      if (line ~ /^\[/) {                     # flow style
        sub(/[[:space:]]*#.*$/, "", line)     # strip trailing comment
        gsub(/[][]/, "", line)
        n = split(line, a, ",")
        for (i = 1; i <= n; i++) {
          s = a[i]
          gsub(/^[[:space:]"]+|[[:space:]"]+$/, "", s)
          if (s != "") print s
        }
        exit
      }
      insrc = 1; next                         # block style follows
    }
    insrc && /^[[:space:]]*-[[:space:]]/ {
      s = $0
      sub(/^[[:space:]]*-[[:space:]]*/, "", s)
      sub(/[[:space:]]*#.*$/, "", s)
      gsub(/^[[:space:]"]+|[[:space:]"]+$/, "", s)
      if (s != "") print s
      next
    }
    insrc && /^[a-z_]+:/ { exit }             # next key ends the list
  ' "$1"
}

# Is changed path $1 covered by source $2? Files match exactly;
# directories match by path prefix.
source_covers() {
  if [[ -d "$2" ]]; then
    [[ "$1" == "$2/"* ]]
  else
    [[ "$1" == "$2" ]]
  fi
}

status=0
while IFS= read -r doc; do
  sources="$(extract_sources "${doc}")"
  [[ -n "${sources}" ]] || continue

  # Integrity: declared sources must still exist.
  while IFS= read -r src; do
    if [[ ! -e "${src}" ]]; then
      printf 'MISSING  %s — source %s no longer exists\n' "${doc}" "${src}"
      status=1
    fi
  done <<< "${sources}"

  # Freshness: a changed source implies the doc changed in the same diff.
  touched=""
  while IFS= read -r src; do
    [[ -e "${src}" ]] || continue
    while IFS= read -r c; do
      if source_covers "${c}" "${src}"; then
        touched="${touched} ${src}"
        break
      fi
    done <<< "${changed}"
  done <<< "${sources}"
  if [[ -n "${touched}" ]] && ! grep -qxF "${doc}" <<< "${changed}"; then
    printf 'STALE    %s — sources changed without a doc update:%s\n' "${doc}" "${touched}"
    status=1
  fi
done < <(find docs -name '*.md' -not -path '*/adr/*' -not -path '*/design-docs/archived/*' -not -path '*/issues/archived/*' -not -path '*/reviews/*' -not -path 'docs/example/*')

if [[ "${status}" -eq 0 ]]; then
  echo "docs fresh: declared sources exist and none changed without its doc"
else
  echo "" >&2
  echo "Update the flagged doc in the same PR — or fix its sources: if the" >&2
  echo "path is not really a source of truth for it." >&2
fi
exit "${status}"
