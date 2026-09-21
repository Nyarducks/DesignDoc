#!/usr/bin/env bash
# check-skills — validate the .agents/skills/ layout conventions.
#
# Rules enforced per skill directory:
#   - SKILL.md exists, with frontmatter `name:` equal to the directory
#     name and a non-empty `description:` (folded `>` scalars allowed)
#   - every scripts/*.sh is executable
#   - a skill with scripts/ must ship a tests/ dir holding .bats files
#
# Usage: check-skills.sh [skills-dir]
#   skills-dir defaults to the skills tree this script lives in, so the
#   script stays standalone-runnable from the skill directory alone.
#
# Exit 0 = all skills conform; exit 1 prints each violation.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${1:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

violations=0
err() { echo "SKILLS: $1"; violations=$((violations+1)); }

for dir in "${SKILLS_DIR}"/*/; do
  [ -d "${dir}" ] || continue
  name="$(basename "${dir}")"
  skill="${dir}SKILL.md"

  if [ ! -f "${skill}" ]; then
    err "${name} — missing SKILL.md"
    continue
  fi

  fm="$(awk 'NR==1 && $0=="---"{infm=1;next} infm && $0=="---"{exit} infm{print}' "${skill}")"

  printf '%s\n' "${fm}" | grep -qE "^name:[[:space:]]*${name}[[:space:]]*$" \
    || err "${name} — frontmatter 'name:' missing or does not match directory"
  printf '%s\n' "${fm}" | grep -qE '^description:[[:space:]]*\S' \
    || err "${name} — frontmatter missing 'description:'"

  if [ -d "${dir}scripts" ]; then
    while IFS= read -r s; do
      [ -x "${s}" ] || err "${name} — script not executable: ${s}"
    done < <(find "${dir}scripts" -name '*.sh' -type f)

    if [ ! -d "${dir}tests" ]; then
      err "${name} — has scripts/ but no tests/ dir"
    elif ! find "${dir}tests" -name '*.bats' -type f | grep -q .; then
      err "${name} — tests/ has no .bats files"
    fi
  fi
done

if [ "${violations}" -gt 0 ]; then
  echo ""
  echo "${violations} skill-layout violation(s)"
  exit 1
fi
echo "skill layout ok"
