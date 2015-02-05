#!/usr/bin/env bats

load test-helper
fixtures env

@test "expanding defined variabes" {
  load "$FIXTURE_ROOT/all.bash"
  local template="$TMP/dynamic.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'The thing! Do the thing!' ]
}

@test "expanding missing variables to empty string" {
  load "$FIXTURE_ROOT/missing.bash"
  local template="$TMP/dynamic.tmpl"
  run "$EXEC" "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'The ! Do the !' ]
}
