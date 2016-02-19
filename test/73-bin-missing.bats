#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_m_missing () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_failure 1
  assert_equal "${#lines[@]}" 2
  assert_line --index 0 'Error: the variables below are referenced but not defined!'
  assert_line --index 1 '_thing'
}

@test '-m: display missing variables' {
  test_m_missing -m
}

@test '--missing: display missing variables' {
  test_m_missing --missing
}

# Test correctness.
@test '-m: do not alter behaviour if all references are defined' {
  local template='$_thing'
  export _thing=thing
  run bash -c "echo '$template' | '$EXEC' -m"
  assert_success
  assert_output 'thing'
}

# Test with other options.
test_m_missing_x_escape () {
  local template='\$_do $_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_failure 1
  assert_equal "${#lines[@]}" 2
  assert_line --index 0 'Error: the variables below are referenced but not defined!'
  assert_line --index 1 '_thing'
}

@test '-mx: do not display escaped variable references' {
  test_m_missing_x_escape -mx
}

@test '--missing --escape: do not display escaped variable references' {
  test_m_missing_x_escape --missing --escape
}
