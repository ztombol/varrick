#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_m_missing () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == 'Error: the variables below are referenced but not defined!' ]
  [ "${lines[1]}" == '_thing' ]
}

@test "\`-m' reports missing variables" {
  test_m_missing -m
}

@test "\`--missing' reports missing variables" {
  test_m_missing --missing
}

# Test default.
@test "\`-m' does not affect behaviour when all referenced variables are defined" {
  local template='$_thing'
  export _thing=thing
  run bash -c "echo '$template' | '$EXEC' -m"
  [ "$status" -eq 0 ]
  [ "$output" == 'thing' ]
}
