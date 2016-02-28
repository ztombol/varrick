#!/usr/bin/env bats

load bin-test-helper
fixtures bin

# Input source detection.
@test 'varrick <in>: read from <in> when STDIN is a TTY' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template"
  assert_success
  assert_output "$(cat "$template")"
}

@test 'varrick <in>: read from <in> when STDIN is not a TTY' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template" 0>/dev/null
  assert_success
  assert_output "$(cat "$template")"
}

@test '... | varrick: read from pipe when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'"
  assert_success
  assert_output "$(cat "$template")"
}

@test '... | varrick: read from pipe when TTY is not available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'" 0>/dev/null
  assert_success
  assert_output "$(cat "$template")"
}

@test 'varrick < <in>: read from redirected input when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "'$EXEC' < '$template'"
  assert_success
  assert_output "$(cat "$template")"
}

@test 'varrick < <in>: read from redirected input when TTY is not available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "'$EXEC' < '$template'" 0>/dev/null
  assert_success
  assert_output "$(cat "$template")"
}

# Input from file.
@test 'varrick: return 1 and display usage' {
  run "$EXEC"
  assert_failure 1
  assert_equal "${#lines[@]}" 5
  assert_line --index 1 --regexp '^Usage:'
}

@test 'varrick <arg...>: return 1 and display usage if more than 2 arguments are specified' {
  run "$EXEC" arg1 arg2 arg3
  assert_failure 1
  assert_equal "${#lines[@]}" 5
  assert_line --index 1 --regexp '^Usage:'
}

@test 'varrick <in>: return 1 and display an error message if <in> does not exist' {
  local template="$TMP/does_not_exist.tmpl"
  run "$EXEC" "$template"
  assert_failure 1
  assert_output "Error: no such file \`$template'"
}

@test 'varrick <in>: write to STDOUT' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template"
  assert_success
  assert_output "$(cat "$template")"
}

@test 'varrick <in> <out>: write to <out> if it is a file' {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$expanded"
echo "$output"
  assert_success
  assert_file_exist "$expanded"
  assert_equal "$(cat "$expanded")" "$(cat "$template")"
}

@test "varrick <in>.tmpl <out_dir>: write to <out_dir>/<in> if <out_dir> is a directory" {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  local dest="$(dirname "$expanded")"
  run "$EXEC" "$template" "$dest"
  assert_success
  assert_file_exist "$expanded"
  assert_equal "$(cat "$expanded")" "$(cat "$template")"
}

@test "varrick <in> <out_dir>: write to <out_dir>/<in> if <out_dir> is a directory and <in> does not end in \`.tmpl'" {
  local template="$TMP/static.template"
  local expanded="$TMP/dest/static.template"
  local dest="$(dirname "$expanded")"
  cp "$FIXTURE_ROOT/static.tmpl" "$template"
  mkdir "$dest"
  run "$EXEC" "$template" "$dest"
  assert_success
  assert_file_exist "$expanded"
  assert_equal "$(cat "$expanded")" "$(cat "$template")"
}

# Input from STDIN.
@test '... | varrick <arg...>: return 1 and display usage if more than 1 argument is specified' {
  run bash -c "echo '' | '$EXEC' arg1 arg2"
  assert_failure 1
  assert_equal "${#lines[@]}" 5
  assert_line --index 1 --regexp '^Usage:'
}

@test '... | varrick: write to STDOUT' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'"
  assert_success
  assert_output "$(cat "$template")"
}

@test '... | varrick <out>: write to <out> if it is a file' {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  run bash -c "cat '$template' | '$EXEC' '$expanded'"
  assert_success
  assert_file_exist "$expanded"
  assert_equal "$(cat "$expanded")" "$(cat "$template")"
}

@test '... | varrick <out_dir>: return 1 and display an error message if <out_dir> is a directory' {
  run bash -c "echo '' | '$EXEC' '$TMP'"
  assert_failure 1
  assert_output 'Error: destination cannot be a directory when reading the template from STDIN!'
}

# Test in-place expansion.
@test 'varrick <in> <in>: expand template in-place' {
  export _thing='thing' _do='Do'
  local template="$TMP/dynamic.tmpl"
  cp "$FIXTURE_ROOT/dynamic.tmpl" "$template"
  run "$EXEC" "$template" "$template"
  assert_success
  assert_equal "$(cat "$template")" 'The thing! Do the thing!'
}
