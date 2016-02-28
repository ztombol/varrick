#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_s_summary () {
  local template='\$_do $_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_success
  assert_equal "${#lines[@]}" 3
  assert_line --index 0 'Referenced variables:'
  assert_line --index 1 '_do'
  assert_line --index 2 '_thing'
}

@test '-s: display referenced variables' {
  test_s_summary -s
}

@test '--summary: display referenced variables' {
  test_s_summary --summary
}

# Test correctness.
test_s_summary_empty () {
  local template=''
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_success
  assert_output ''
}

@test '-s: produce no output if there are no referenced variables' {
  test_s_summary_empty -s
}

@test '-sx: produce no output if there are no referenced variables or escaped references' {
  test_s_summary_empty -sx
}

# Test with other options.
test_s_summary_x_escape () {
  local template='\$_do $_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  assert_success
  assert_equal "${#lines[@]}" 4
  assert_line --index 0 'Escaped variables:'
  assert_line --index 1 '_do'
  assert_line --index 2 'Referenced variables:'
  assert_line --index 3 '_thing'
}

@test '-sx: display referenced and escaped variables' {
  test_s_summary_x_escape -sx
}

@test '--summary --escape: display referenced and escaped variables' {
  test_s_summary_x_escape --summary --escape
}
