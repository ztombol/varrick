#!/usr/bin/env bats

load lib-test-helper

# Correctness.
@test 'escape_vars <variable...>: escape backslashes in <variable...>' {
  export var1='\' var2='\\'
  run bash -c '. '"$LIB_DIR/zhu-li.sh"';
               escape_vars var1 var2;
               echo "$var1";
               echo "$var2";'
  assert_success
  assert_equal "${#lines[@]}" 2
  assert_line --index 0 '\\'
  assert_line --index 1 '\\\\'
}
