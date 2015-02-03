#!/usr/bin/env bats

load test-helper
fixtures env

test_m_missing () {
  load "$FIXTURE_ROOT/missing.bash"
  local template="$TMP/dynamic.tmpl"

  run "$EXEC" $1 "$template"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -gt 1 ]
  [ "${lines[0]}" == 'Error: the variables below are referenced but not defined!' ]
  [ "${lines[1]}" == '_thing' ]
}

@test "\`-m' reports missing variables and exit with 1" {
  test_m_missing -m
}

@test "\`--missing' reports missing variables and exit with 1" {
  test_m_missing --missing
}
