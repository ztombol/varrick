#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_x_escape () {
  local template='\$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_success
  assert_output '$_thing'
}

@test '-x: enable escaping' {
  test_x_escape -x
}

@test '--escape: enable escaping' {
  test_x_escape --escape
}
