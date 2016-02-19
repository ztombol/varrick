#!/usr/bin/env bats

load lib-test-helper
fixtures lib

# Correctness.
@test 'unescape: remove escape characters in <template> read from STDIN' {
  local template="$FIXTURE_ROOT/reference.tmpl"
  run bash -c ". '$LIB_DIR/zhu-li.sh'
               cat '$template' | escape | unescape"
  assert_success
  assert_equal "${#lines[@]}" 32

  # Escaped.
  assert_line --index 1 '$a1'
  assert_line --index 2 'b$a2'
  assert_line --index 3 '${a3}'
  assert_line --index 4 'b${a4}'
  assert_line --index 5 '${a5}b'
  assert_line --index 6 'b${a6}b'
  assert_line --index 7 '\$a7'
  assert_line --index 8 'b\$a8'
  assert_line --index 9 '\${a9}'
  assert_line --index 10 'b\${a10}'
  assert_line --index 11 '\${a11}b'
  assert_line --index 12 'b\${a12}b'

  # Not escaped.
  assert_line --index 14 '$a13'
  assert_line --index 15 'b$a14'
  assert_line --index 16 '${a15}'
  assert_line --index 17 'b${a16}'
  assert_line --index 18 '${a17}b'
  assert_line --index 19 'b${a18}b'
  assert_line --index 20 '\$a19'
  assert_line --index 21 'b\$a20'
  assert_line --index 22 '\${a21}'
  assert_line --index 23 'b\${a22}'
  assert_line --index 24 '\${a23}b'
  assert_line --index 25 'b\${a24}b'
  assert_line --index 26 '\\$a25'
  assert_line --index 27 'b\\$a26'
  assert_line --index 28 '\\${a27}'
  assert_line --index 29 'b\\${a28}'
  assert_line --index 30 '\\${a29}b'
  assert_line --index 31 'b\\${a30}b'
}
