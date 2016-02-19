#!/usr/bin/env bats

load bin-test-helper

# Test default behaviour.
@test 'expand a defined reference to its value' {
  local template='$_thing'
  export _thing=thing
  run bash -c "echo '$template' | '$EXEC'"
  assert_success
  assert_output 'thing'
}

@test 'expand an undefined reference to the empty string by default' {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC'"
  assert_success
  assert_output ''
}
