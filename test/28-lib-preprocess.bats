#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'preprocess <template>: print <template> with reference-like strings and backslashes escaped' {
  local template="$(cat "$FIXTURE_ROOT/pre_process.tmpl")"
  run preprocess "$template"
  assert_success
  assert_equal "${#lines[@]}" 10
  assert_line --index 0 '\\'
  assert_line --index 1 '$'
  assert_line --index 2 '\$a'
  assert_line --index 3 '${'
  assert_line --index 4 '${a'
  assert_line --index 5 '${a-'
  assert_line --index 6 '${a1'
  assert_line --index 7 '${a1-'
  assert_line --index 8 '${a1-}'
  assert_line --index 9 '\${a1}'
}
