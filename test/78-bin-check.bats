#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_c_check () {
  local template='\'
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_failure 1
  assert_equal "${#lines[@]}" 2
  assert_line --index 0 'Error: Invalid escaping in the following lines:'
  assert_line --index 1 '1: \'
}

@test '-c: display lines containing invalid escape sequences' {
  test_c_check -c
}

@test '--check: display lines containing invalid escape sequences' {
  test_c_check --check
}

@test '-c: report good status if there are no invalid escapes' {
  local template='\\'
  run bash -c "echo '$template' | '$EXEC' -c"
  assert_success
  assert_output 'Everything looks good!'
}
