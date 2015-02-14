#!/usr/bin/env bats

load test-helper

# Test option.
test_e_no-expand () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '$_thing' ]
}

@test "\`-e' does not expand reference of undefined variable" {
  test_e_no-expand -e
}

@test "\`--no-expand' does not expand reference of undefined variable" {
  test_e_no-expand --no-expand
}

# Test default.
@test "\`-e' does not affect behaviour when all referenced variables are defined" {
  local template='$_thing'
  export _thing=thing
  run bash -c "echo '$template' | '$EXEC' -e"
  [ "$status" -eq 0 ]
  [ "$output" == 'thing' ]
}

# Test with other options.
@test "\`-e' and \`-m' are mutually exclusive" {
  run bash -c "echo '' | '$EXEC' -e -m"
  [ "$status" -eq 1 ]
  [ "$output" == "Error: \`--missing' (-m) and \`--no-expand' (-e) cannot be specified at the same time!" ]
}
