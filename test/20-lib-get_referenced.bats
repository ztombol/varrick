#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'get_referenced <template> <escaping=0>: disable escaping and print all references found in <template>' {
  local template="$(cat "$FIXTURE_ROOT/reference.tmpl")"
  run get_referenced "$template" 0
  assert_success
  assert_equal "${#lines[@]}" 30
  assert_line --index 0 'a1'
  assert_line --index 1 'a10'
  assert_line --index 2 'a11'
  assert_line --index 3 'a12'
  assert_line --index 4 'a13'
  assert_line --index 5 'a14'
  assert_line --index 6 'a15'
  assert_line --index 7 'a16'
  assert_line --index 8 'a17'
  assert_line --index 9 'a18'
  assert_line --index 10 'a19'
  assert_line --index 11 'a2'
  assert_line --index 12 'a20'
  assert_line --index 13 'a21'
  assert_line --index 14 'a22'
  assert_line --index 15 'a23'
  assert_line --index 16 'a24'
  assert_line --index 17 'a25'
  assert_line --index 18 'a26'
  assert_line --index 19 'a27'
  assert_line --index 20 'a28'
  assert_line --index 21 'a29'
  assert_line --index 22 'a3'
  assert_line --index 23 'a30'
  assert_line --index 24 'a4'
  assert_line --index 25 'a5'
  assert_line --index 26 'a6'
  assert_line --index 27 'a7'
  assert_line --index 28 'a8'
  assert_line --index 29 'a9'
}

@test 'get_referenced <template> <escaping=1>: enable escaping and print non-escaped references found in <template>' {
  local template="$(cat "$FIXTURE_ROOT/reference.tmpl")"
  run get_referenced "$template" 1
  assert_success
  assert_equal "${#lines[@]}" 18
  assert_line --index 0 'a13'
  assert_line --index 1 'a14'
  assert_line --index 2 'a15'
  assert_line --index 3 'a16'
  assert_line --index 4 'a17'
  assert_line --index 5 'a18'
  assert_line --index 6 'a19'
  assert_line --index 7 'a20'
  assert_line --index 8 'a21'
  assert_line --index 9 'a22'
  assert_line --index 10 'a23'
  assert_line --index 11 'a24'
  assert_line --index 12 'a25'
  assert_line --index 13 'a26'
  assert_line --index 14 'a27'
  assert_line --index 15 'a28'
  assert_line --index 16 'a29'
  assert_line --index 17 'a30'
}

# Interface.
@test 'get_referenced <template>: return 0 if <template> contains references' {
  local template='$a'
  run get_referenced "$template"
  assert_success
  assert_output 'a'
}

@test 'get_referenced <template>: return 1 if <template> does not contain references' {
  local template=''
  run get_referenced "$template"
  assert_failure 1
  assert_output ''
}

@test 'get_referenced <template>: disable escaping by default' {
  local template='\$a'
  run get_referenced "$template"
  assert_success
  assert_output 'a'
}
