#!/usr/bin/env bats

load bin-test-helper

@test 'return 2 and display an error message if the internal prefix is detected in the environment' {
  export _d8e1_=1 _d8e1_a=1
  run "$EXEC"
  assert_failure 2
  assert_equal "${#lines[@]}" 3
  assert_line --index 0 "Error: no variable with the prefix \`_d8e1_' should exist in the environment!"
  assert_line --index 1 '_d8e1_'
  assert_line --index 2 '_d8e1_a'
}
