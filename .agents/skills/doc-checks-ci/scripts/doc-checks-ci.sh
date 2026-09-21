#!/usr/bin/env bash
# doc-checks-ci.sh — install or remove the docs-checks CI job.
#
# Adds an anchored `docs` job to the project's CI workflow that runs the
# bundled check scripts (the sources: contract and OKF frontmatter) —
# this skill is self-contained and needs no other skill installed. The
# block is delimited by `# doc-checks-ci:start` / `# doc-checks-ci:end`
# comments, so opting out is one command and the edit merges cleanly.
#
# Usage:
#   doc-checks-ci.sh install   [--workflow PATH] [--scripts-dir PATH]
#   doc-checks-ci.sh uninstall [--workflow PATH]
#   doc-checks-ci.sh status    [--workflow PATH]
#
# Defaults: --workflow    .github/workflows/ci.yaml
#           --scripts-dir .agents/skills/doc-checks-ci/scripts
set -euo pipefail

readonly START='# doc-checks-ci:start'
readonly END='# doc-checks-ci:end'

usage() {
  sed -n '2,/^set /p' "$0" | sed '$d' >&2
  exit 2
}

cmd="${1:-}"
[[ -z "${cmd}" || "${cmd}" == -* ]] && usage
shift || true

workflow=".github/workflows/ci.yaml"
scripts_dir=".agents/skills/doc-checks-ci/scripts"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workflow)    workflow="${2:?--workflow needs a path}"; shift 2 ;;
    --scripts-dir) scripts_dir="${2:?--scripts-dir needs a path}"; shift 2 ;;
    *) echo "unknown flag: $1" >&2; usage ;;
  esac
done

cd "$(git rev-parse --show-toplevel)"

# The anchored job block, at jobs-map indentation.
block() {
  sed "s|@SCRIPTS_DIR@|${scripts_dir}|g" <<'EOF'
  # doc-checks-ci:start — managed by the doc-checks-ci skill; remove with `doc-checks-ci.sh uninstall`
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Docs sources contract
        run: bash @SCRIPTS_DIR@/check-docs-stale.sh "origin/${{ github.base_ref || github.event.repository.default_branch }}"
      - name: Docs frontmatter
        run: bash @SCRIPTS_DIR@/check-doc-frontmatter.sh
  # doc-checks-ci:end
EOF
}

installed() {
  [[ -f "${workflow}" ]] && grep -qF "${START}" "${workflow}"
}

install() {
  if installed; then
    echo "doc-checks-ci already installed in ${workflow}"
    return 0
  fi
  if [[ ! -f "${workflow}" ]]; then
    mkdir -p "$(dirname "${workflow}")"
    {
      cat <<'EOF'
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
EOF
      block
    } > "${workflow}"
    echo "created ${workflow} with the docs job"
    return 0
  fi
  if ! grep -qE '^jobs:[[:space:]]*(#.*)?$' "${workflow}"; then
    echo "${workflow} has no 'jobs:' mapping — add the docs job manually" >&2
    return 1
  fi
  awk -v block="$(block)" '
    /^jobs:[[:space:]]*(#.*)?$/ && !done { print; print block; done = 1; next }
    { print }
  ' "${workflow}" > "${workflow}.tmp"
  mv "${workflow}.tmp" "${workflow}"
  echo "installed docs job into ${workflow}"
}

uninstall() {
  installed || { echo "doc-checks-ci not installed in ${workflow}"; return 0; }
  sed "/${START}/,/${END}/d" "${workflow}" > "${workflow}.tmp"
  mv "${workflow}.tmp" "${workflow}"
  echo "removed docs job from ${workflow}"
}

status() {
  if installed; then
    echo "installed (${workflow})"
  else
    echo "not installed (${workflow})"
  fi
}

case "${cmd}" in
  install)   install ;;
  uninstall) uninstall ;;
  status)    status ;;
  *) usage ;;
esac
