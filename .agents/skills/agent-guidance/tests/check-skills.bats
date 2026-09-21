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

@test "形式が正しい skill のとき exit 0 を返す" {
  mk_skill foo
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 0 ]
  contains "skill layout ok"
}

@test "SKILL.md がない skill のとき違反を返す" {
  mkdir -p "$SKILLS/foo"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "foo — missing SKILL.md"
}

@test "frontmatter の name が dir 名と一致しないとき違反を返す" {
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

@test "description がないとき違反を返す" {
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

@test "description が folded scalar のとき許容する" {
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

@test "scripts/ があるのに tests/ がないとき違反を返す" {
  mk_skill foo
  mkdir -p "$SKILLS/foo/scripts"
  printf '#!/usr/bin/env bash\n' > "$SKILLS/foo/scripts/x.sh"
  chmod +x "$SKILLS/foo/scripts/x.sh"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "foo — has scripts/ but no tests/ dir"
}

@test "script が実行可能でないとき違反を返す" {
  mk_skill foo
  mkdir -p "$SKILLS/foo/scripts" "$SKILLS/foo/tests"
  printf '#!/usr/bin/env bash\n' > "$SKILLS/foo/scripts/x.sh"
  printf '#!/usr/bin/env bats\n' > "$SKILLS/foo/tests/x.bats"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 1 ]
  contains "script not executable"
}

@test "scripts/ + tests/*.bats が揃っているとき exit 0 を返す" {
  mk_skill foo
  mkdir -p "$SKILLS/foo/scripts" "$SKILLS/foo/tests"
  printf '#!/usr/bin/env bash\n' > "$SKILLS/foo/scripts/x.sh"
  chmod +x "$SKILLS/foo/scripts/x.sh"
  printf '#!/usr/bin/env bats\n' > "$SKILLS/foo/tests/x.bats"
  run bash "$SCRIPT" "$SKILLS"
  [ "$status" -eq 0 ]
  contains "skill layout ok"
}

@test "引数なしのとき skill 同梱の skills ツリーを既定で検査する" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
}
