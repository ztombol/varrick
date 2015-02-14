#!/usr/bin/env bats

load bin-test-helper

# Test default behaviour.
@test 'expand reference of defined variable to its value' {
  local template='$_thing'
  export _thing=thing
  run bash -c "echo '$template' | '$EXEC'"
  [ "$status" -eq 0 ]
  [ "$output" == 'thing' ]
}

@test 'expand reference of undefined variable to the empty string' {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC'"
  [ "$status" -eq 0 ]
  [ "$output" == '' ]
}
