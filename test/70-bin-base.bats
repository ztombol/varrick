#!/usr/bin/env bats

load bin-test-helper
fixtures bin

# Environment.
@test 'return 2 and display an error message if the internal prefix is detected in the environment' {
  export _d8e1_=1 _d8e1_a=1
  run "$EXEC"
  [ "$status" -eq 2 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == "Error: no variable with the prefix \`_d8e1_' should exist in the environment!" ]
  [ "${lines[1]}" == '_d8e1_' ]
  [ "${lines[2]}" == '_d8e1_a' ]
}

# General.
@test '-u: display usage' {
  run "$EXEC" -u
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[0]}" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test '--usage: display usage' {
  run "$EXEC" --usage
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test '-h: display help' {
  run "$EXEC" -h
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -gt 5 ]
  [ $(expr "${lines[0]}" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test '--help: display help' {
  run "$EXEC" --help
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -gt 5 ]
  [ $(expr "${lines[0]}" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test '-v: display version' {
  run "$EXEC" -v
  [ "$status" -eq 0 ]
  [ $(expr "$output" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
}

@test '--version: display version' {
  run "$EXEC" --version
  [ "$status" -eq 0 ]
  [ $(expr "$output" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
}

# Input source detection.
@test 'varrick <in>: read from <in> when STDIN is a TTY' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'varrick <in>: read from <in> when STDIN is not a TTY' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template" 0>/dev/null
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test '... | varrick: read from pipe when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test '... | varrick: read from pipe when TTY is not available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'" 0>/dev/null
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'varrick < <in>: read from redirected input when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "'$EXEC' < '$template'"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'varrick < <in>: read from redirected input when TTY is not available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "'$EXEC' < '$template'" 0>/dev/null
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

# Input from file.
@test 'varrick: return 1 and display usage' {
  run "$EXEC"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test 'varrick <arg...>: return 1 and display usage if more than 2 arguments are specified' {
  run "$EXEC" arg1 arg2 arg3
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test 'varrick <in>: return 1 and display an error message if <in> does not exist' {
  local template="$TMP/does_not_exist.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 1 ]
  [ "$output" == "Error: no such file \`$template'" ]
}

@test 'varrick <in>: write to STDOUT' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'varrick <in> <out>: write to <out> if it is a file' {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$expanded"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "varrick <in>.tmpl <out_dir>: write to <out_dir>/<in> if <out_dir> is a directory" {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  local dest="$(dirname "$expanded")"
  run "$EXEC" "$template" "$dest"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "varrick <in> <out_dir>: write to <out_dir>/<in> if <out_dir> is a directory and <in> does not end in \`.tmpl'" {
  local template="$TMP/static.template"
  local expanded="$TMP/dest/static.template"
  local dest="$(dirname "$expanded")"
  cp "$FIXTURE_ROOT/static.tmpl" "$template"
  mkdir "$dest"
  run "$EXEC" "$template" "$dest"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

# Input from STDIN.
@test '... | varrick <arg...>: return 1 and display usage if more than 1 argument is specified' {
  run bash -c "echo '' | '$EXEC' arg1 arg2"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test '... | varrick: write to STDOUT' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test '... | varrick <out>: write to <out> if it is a file' {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  run bash -c "cat '$template' | '$EXEC' '$expanded'"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test '... | varrick <out_dir>: return 1 and display an error message if <out_dir> is a directory' {
  run bash -c "echo '' | '$EXEC' '$TMP'"
  [ "$status" -eq 1 ]
  [ "$output" == 'Error: destination cannot be a directory when reading the template from STDIN!' ]
}

# Test in-place expansion.
@test 'varrick <in> <in>: expand template in-place' {
  export _thing='thing' _do='Do'
  local template="$TMP/dynamic.tmpl"
  cp "$FIXTURE_ROOT/dynamic.tmpl" "$template"
  run "$EXEC" "$template" "$template"
  [ "$status" -eq 0 ]
  [ "$(cat "$template")" == 'The thing! Do the thing!' ]
}
