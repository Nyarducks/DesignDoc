#!/usr/bin/env bash
# check-doc-frontmatter.sh — validate OKF frontmatter on docs/**/*.md.
#
# The sources: contract only holds while frontmatter parses — a malformed
# header silently escapes check-docs-stale.sh, so this script guards the
# fields that check relies on.
#
# Rules:
#   - Live docs MUST carry frontmatter. Archives — docs/plan/archived/
#     and docs/reviews/ — are point-in-time records: frontmatter is
#     optional, but when present it is validated like any other doc.
#   - Frontmatter is --- delimited and contains the required keys:
#       type, title, status, last_modified
#   - type ∈ {Design Doc, ADR, Reference, Plan, Issue}
#   - last_modified is a YYYY-MM-DD date
#   - No unquoted scalar containing ': ' (breaks YAML renders)
#   - Inline lists [a, b] have no empty items and no character-split
#     items ("[f, r, o, n]" — a generator bug shape)
#
# Deliberately a structural check, not a full YAML parse — no yaml tool
# dependency on the runner.
#
# Usage: check-doc-frontmatter.sh
# Exit 0 = all good; exit 1 prints each violation.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [[ ! -d docs ]]; then
  echo "frontmatter ok: no docs/ directory"
  exit 0
fi

violations=0
err() { echo "FRONTMATTER: $1 — $2"; violations=$((violations + 1)); }

is_archive() {
  case "$1" in
    docs/plan/archived/* | docs/reviews/*) return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r file; do
  # --- delimiters: first line must be exactly ---, and a closing ---
  # must exist before any non-frontmatter content.
  if ! head -n 1 "$file" | grep -qx -- '---'; then
    is_archive "$file" || err "$file" "missing frontmatter (archives exempt: plan/archived/, reviews/)"
    continue
  fi
  if ! awk 'NR>1 && /^---/{found=1; exit} END{exit !found}' "$file"; then
    err "$file" "unterminated frontmatter"
    continue
  fi

  fm=$(awk 'NR==1{next} /^---/{exit} {print}' "$file")

  # Required keys
  for key in type title status last_modified; do
    grep -qE "^${key}:" <<< "$fm" || err "$file" "missing required key: ${key}"
  done

  # type enum
  type_line=$(printf '%s\n' "$fm" | grep -E '^type:' | head -1 || true)
  if [[ -n "$type_line" ]]; then
    type_val=$(printf '%s' "${type_line#type:}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    case "$type_val" in
      "Design Doc" | "ADR" | "Reference" | "Plan" | "Issue") ;;
      *) err "$file" "unknown type: ${type_val} (expected Design Doc|ADR|Reference|Plan|Issue)" ;;
    esac
  fi

  # last_modified date shape
  lm_line=$(printf '%s\n' "$fm" | grep -E '^last_modified:' | head -1 || true)
  if [[ -n "$lm_line" ]]; then
    lm_val=${lm_line#last_modified:}
    lm_val=$(printf '%s' "$lm_val" | tr -d '[:space:]"'"'"'')
    grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' <<< "$lm_val" \
      || err "$file" "last_modified is not YYYY-MM-DD: ${lm_val}"
  fi

  # Unquoted scalars containing ': ' — a YAML error ("mapping values are
  # not allowed here"). A top-level `key: value` line whose value is not
  # quoted, not a list, and not a block scalar must not contain a ': '.
  while IFS= read -r line; do
    case "$line" in
      '' | '#'*) continue ;;
    esac
    [[ "$line" =~ ^[a-z_]+:[[:space:]] ]] || continue
    val=${line#*: }
    case "$val" in
      '' | '"'* | "'"* | '['*'{'* | '|'* | '>'*) continue ;;
    esac
    if [[ "$val" == *': '* ]]; then
      err "$file" "unquoted scalar contains ': ' — quote the value: ${line:0:80}..."
    fi
  done <<< "$fm"

  # Inline lists — `key: [a, b]`: no empty items, no char-split items
  while IFS= read -r line; do
    [[ "$line" =~ ^[a-z_]+:[[:space:]]*\[.*\] ]] || continue
    inner=${line#*[}
    inner=${inner%]*}
    IFS=',' read -ra items <<< "$inner"
    single=0
    for item in "${items[@]}"; do
      item=$(printf '%s' "$item" | tr -d '[:space:]"'"'"'')
      [[ -z "$item" ]] && err "$file" "empty item in inline list: ${line:0:80}"
      [[ ${#item} -eq 1 ]] && single=$((single + 1))
    done
    [[ "$single" -gt 3 ]] && err "$file" "looks character-split: ${line:0:80}"
  done <<< "$fm"
done < <(find docs -name '*.md' -type f | sort)

if [[ "$violations" -gt 0 ]]; then
  echo ""
  echo "$violations frontmatter violation(s)"
  exit 1
fi
echo "frontmatter ok: all docs carry valid frontmatter"
exit 0
