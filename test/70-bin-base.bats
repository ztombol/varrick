#!/usr/bin/env bats

load bin-test-helper
fixtures bin

# Internal prefix.
@test 'report error when the internal prefix is detected in the environment' {
  export _d8e1_=1 _d8e1_a=1
  run "$EXEC"
  [ "$status" -eq 2 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == "Error: no variable with the prefix \`_d8e1_'\ should exist in the environment!" ]
  [ "${lines[1]}" == '_d8e1_' ]
  [ "${lines[2]}" == '_d8e1_a' ]
}

# General.
@test "\`-u' displays usage information" {
  run "$EXEC" -u
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[0]}" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test "\`--usage' displays usage information" {
  run "$EXEC" --usage
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test "\`-h' displays help" {
  run "$EXEC" -h
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -gt 5 ]
  [ $(expr "${lines[0]}" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test "\`--help' displays help" {
  run "$EXEC" --help
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -gt 5 ]
  [ $(expr "${lines[0]}" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test "\`-v' displays version information" {
  run "$EXEC" -v
  [ "$status" -eq 0 ]
  [ $(expr "$output" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
}

@test "\`--version' displays version information" {
  run "$EXEC" --version
  [ "$status" -eq 0 ]
  [ $(expr "$output" : 'Varrick v[0-9].[0-9].[0-9]$') -ne 0 ]
}

# Input source detection.
@test 'reading template from file when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'reading template from file when no TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template" 0>/dev/null
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'reading template from piped input when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'reading template from piped input when no TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'" 0>/dev/null
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'reading template from redirected input when TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "'$EXEC' < '$template'"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'reading template from redirected input when no TTY is available' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "'$EXEC' < '$template'" 0>/dev/null
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

# Input from file.
@test 'FILE template: running without arguments prints usage' {
  run "$EXEC"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test 'FILE template: running with more than 2 arguments prints usage' {
  run "$EXEC" arg1 arg2 arg3
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test 'FILE template: report error if the template file does not exist' {
  local template="$TMP/does_not_exist.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 1 ]
  [ "$output" == "Error: no such file \`$template'" ]
}

@test 'FILE template: output to STDOUT when no destination is specified' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'FILE template: output to file when destination is not a directory' {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$expanded"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "FILE template: output to file when destination is a directory and template ends in \`.tmpl'" {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  local dest="$(dirname "$expanded")"
  run "$EXEC" "$template" "$dest"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "FILE template: output to file when destination is a directory and template does not end in \`.tmpl'" {
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
@test 'STDIN template: running with more than 1 argument prints usage' {
  run bash -c "echo '' | '$EXEC' arg1 arg2"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 5 ]
  [ $(expr "${lines[1]}" : '^Usage:') -ne 0 ]
}

@test 'STDIN template: output to STDOUT when no destination is specified' {
  local template="$FIXTURE_ROOT/static.tmpl"
  run bash -c "cat '$template' | '$EXEC'"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'STDIN template: output to file when destination is not a directory' {
  local template="$FIXTURE_ROOT/static.tmpl"
  local expanded="$TMP/static"
  run bash -c "cat '$template' | '$EXEC' '$expanded'"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test 'STDIN template: report error when destination is a directory' {
  run bash -c "echo '' | '$EXEC' '$TMP'"
  [ "$status" -eq 1 ]
  [ "$output" == 'Error: destination cannot be a directory when reading the template from STDIN!' ]
}

# Test in-place expansion.
@test 'expanding in-place' {
  export _thing='thing' _do='Do'
  local template="$TMP/dynamic.tmpl"
  cp "$FIXTURE_ROOT/dynamic.tmpl" "$template"
  run "$EXEC" "$template" "$template"
  [ "$status" -eq 0 ]
  [ "$(cat "$template")" == 'The thing! Do the thing!' ]
}
