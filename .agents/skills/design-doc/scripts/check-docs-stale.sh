#!/usr/bin/env bash
# check-docs-stale.sh — enforce the docs freshness contract.
#
# Docs under docs/ declare the files they are derived from in their
# `sources:` frontmatter (flow style only: `sources: [a, b]`). This
# script fails when:
#
#   MISSING  a declared source path no longer exists (renamed/deleted)
#   STALE    a source changed in <base>...HEAD but the doc did not
#
# Skipped on purpose:
#   docs/adr/      point-in-time records — a revisited decision gets a
#                  new ADR, never an edit.
#   docs/example/  worked examples; their declared sources are fictional.
#
# Usage: check-docs-stale.sh [base-ref]   (default: origin/main)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [[ ! -d docs ]]; then
  echo "docs fresh: no docs/ directory"
  exit 0
fi

base="${1:-origin/main}"
merge_base="$(git merge-base "${base}" HEAD)"
changed="$(git diff --name-only "${merge_base}" HEAD)"
readonly base merge_base changed

# Print the `sources:` entries of doc $1, one per line. Only the
# flow-style form `sources: [a, b]` is supported — keep entries inline.
extract_sources() {
  local line
  line="$(sed -n '2,/^---$/p' "$1" | grep -m1 '^sources:' || true)"
  [[ "${line}" =~ \[(.*)\] ]] || return 0
  printf '%s\n' "${BASH_REMATCH[1]}" | tr ',' '\n' | sed 's/^ *//; s/ *$//; /^$/d'
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
done < <(find docs -name '*.md' -not -path 'docs/adr/*' -not -path 'docs/example/*')

if [[ "${status}" -eq 0 ]]; then
  echo "docs fresh: declared sources exist and none changed without its doc"
else
  echo "" >&2
  echo "Update the flagged doc in the same PR — or fix its sources: if the" >&2
  echo "path is not really a source of truth for it." >&2
fi
exit "${status}"
