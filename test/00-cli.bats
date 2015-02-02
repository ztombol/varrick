#!/usr/bin/env bats

load test-helper

@test "running without arguments prints usage" {
  run "$EXEC"
  [ "$status" -eq 1 ]
  [ $(expr "${lines[0]}" : "^Usage:") -ne 0 ]
}

@test "output to STDOUT when no output file is specified" {
  local template="$TMP/static.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == "$(cat "$template")" ]
}

@test "output to file when one is specified" {
  local template="$TMP/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$expanded"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "output to file when destination is a directory and template end in \`.tmpl'" {
  local template="$TMP/static.tmpl"
  local expanded="$TMP/static"
  run "$EXEC" "$template" "$TMP"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}

@test "output to file when destination is a directory and template does NOT end in \`.tmpl'" {
  local template="$TMP/static.template"
  local expanded="$TMP/dest/static.template"
  mv "$TMP/static.tmpl" "$template"
  mkdir "$TMP/dest"
  run "$EXEC" "$template" "$TMP/dest"
  [ "$status" -eq 0 ]
  [ -f "$expanded" ]
  [ "$(cat "$expanded")" == "$(cat "$template")" ]
}
