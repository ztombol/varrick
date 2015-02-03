#!/usr/bin/env bats

load test-helper

# Input from file.
@test 'FILE template: running without arguments prints usage' {
  run "$EXEC"
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : '^Usage:') -ne 0 ]
}

@test 'FILE template: running with more than 2 arguments prints usage' {
  run "$EXEC" arg1 arg2 arg3
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : '^Usage:') -ne 0 ]
}

@test 'FILE template: output to STDOUT when no destination is specified' {
  local template="$TMP/static.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'FILE template: output to file when destination is not a directory' {
  local template="$TMP/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$expanded"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "FILE template: output to file when destination is a directory and template ends in \`.tmpl'" {
  local template="$TMP/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$TMP"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "FILE template: output to file when destination is a directory and template does NOT end in \`.tmpl'" {
  local template="$TMP/static.template"
  local expanded="$TMP/dest/static.template"
  mv "$TMP/static.tmpl" "$template"
  mkdir "$TMP/dest"
  run "$EXEC" "$template" "$TMP/dest"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

# Input from STDIN.
@test 'STDIN template: running with more than 1 argument prints usage' {
  run bash -c "echo '' | $EXEC arg1 arg2"
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : '^Usage:') -ne 0 ]
}

@test 'STDIN template: output to STDOUT when no destination is specified' {
  local template="$TMP/static.tmpl"
  run bash -c 'cat '"$template"' | "$EXEC"'
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test 'STDIN template: output to file when destination is not a directory' {
  local template="$TMP/static.tmpl"
  local expanded="$TMP/static"
  run bash -c 'cat '"$template"' | "$EXEC" '"$expanded"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test 'STDIN template: report error and exit with 1 when destination is a directory' {
  run bash -c 'echo "" | "$EXEC" "$TMP"'
  [ "$status" -eq 1 ]
  [ "$output" == 'Error: destination cannot be a directory when reading the template from STDIN!' ]
}
