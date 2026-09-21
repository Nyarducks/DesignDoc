#!/usr/bin/env bats

SCRIPT="$(cd "$BATS_TEST_DIRNAME/../scripts" && pwd)/check-skills.sh"

setup() {
  SKILLS=$(mktemp -d)
}

teardown() {
  rm -rf "$SKILLS"
}

contains() {
  if ! echo "$output" | grep -qF "$1"; then
    printf 'Expected output to contain: %s\nActual output:\n%s\n' "$1" "$output" >&2
    return 1
  fi
}

mk_skill() {
  mkdir -p "$SKILLS/$1"
  cat > "$SKILLS/$1/SKILL.md" <<EOF
---
name: $1
description: test skill $1
---
EOF
}

@test "valid skill exits 0" {
  mk_skill foo
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 0 ]
  contains "skill layout ok"
}

@test "missing SKILL.md reports a violation" {
  mkdir -p "$SKILLS/foo"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "foo — missing SKILL.md"
}

@test "name: not matching the directory reports a violation" {
  mkdir -p "$SKILLS/foo"
  cat > "$SKILLS/foo/SKILL.md" <<'EOF'
---
name: bar
description: mismatched
---
EOF
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "foo — frontmatter 'name:' missing or does not match directory"
}

@test "missing description: reports a violation" {
  mkdir -p "$SKILLS/foo"
  cat > "$SKILLS/foo/SKILL.md" <<'EOF'
---
name: foo
---
EOF
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "foo — frontmatter missing 'description:'"
}

@test "folded-scalar description: is accepted" {
  mkdir -p "$SKILLS/foo"
  cat > "$SKILLS/foo/SKILL.md" <<'EOF'
---
name: foo
description: >
  long folded
  description
---
EOF
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 0 ]
}

@test "scripts/ without tests/ reports a violation" {
  mk_skill foo
  mkdir -p "$SKILLS/foo/scripts"
  printf '#!/usr/bin/env bash\n' > "$SKILLS/foo/scripts/x.sh"
  chmod +x "$SKILLS/foo/scripts/x.sh"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "foo — has scripts/ but no tests/ dir"
}

@test "non-executable script reports a violation" {
  mk_skill foo
  mkdir -p "$SKILLS/foo/scripts" "$SKILLS/foo/tests"
  printf '#!/usr/bin/env bash\n' > "$SKILLS/foo/scripts/x.sh"
  printf '#!/usr/bin/env bats\n' > "$SKILLS/foo/tests/x.bats"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "script not executable"
}

@test "scripts/ plus tests/*.bats exits 0" {
  mk_skill foo
  mkdir -p "$SKILLS/foo/scripts" "$SKILLS/foo/tests"
  printf '#!/usr/bin/env bash\n' > "$SKILLS/foo/scripts/x.sh"
  chmod +x "$SKILLS/foo/scripts/x.sh"
  printf '#!/usr/bin/env bats\n' > "$SKILLS/foo/tests/x.bats"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 0 ]
  contains "skill layout ok"
}

@test "no args defaults to the skills tree containing the script" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
}
