#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'get_escaped <template>: print escaped references found in <template>' {
  local template="$(cat "$FIXTURE_ROOT/reference.tmpl")"
  run get_escaped "$template"
  assert_success
  assert_equal "${#lines[@]}" 12
  assert_line --index 0 'a1'
  assert_line --index 1 'a10'
  assert_line --index 2 'a11'
  assert_line --index 3 'a12'
  assert_line --index 4 'a2'
  assert_line --index 5 'a3'
  assert_line --index 6 'a4'
  assert_line --index 7 'a5'
  assert_line --index 8 'a6'
  assert_line --index 9 'a7'
  assert_line --index 10 'a8'
  assert_line --index 11 'a9'
}

# Interface.
@test 'get_escaped <template>: return 0 if <template> contains escaped references' {
  local template='\$a'
  run get_escaped "$template"
  assert_success
  assert_output 'a'
}

@test 'get_escaped <template>: return 1 if <template> does not contain escaped references' {
  local template=''
  run get_escaped "$template"
  assert_failure 1
  assert_output ''
}
