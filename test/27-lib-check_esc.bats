#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'check_esc <template>: print error message if <template> contains invalid escape sequences' {
  local template="$(cat "$FIXTURE_ROOT/escape.invalid.tmpl")"
  run check_esc "$template"
  assert_failure 1
  assert_equal "${#lines[@]}" 33
  assert_line --index 0 'Error: Invalid escaping in the following lines:'

  # regex #1:
  assert_line --index 1 '2: \'
  assert_line --index 2 '3: \a'
  assert_line --index 3 '4: a\'
  assert_line --index 4 '5: a\a'

  assert_line --index 5 '7: \\\'
  assert_line --index 6 '8: \\\a'
  assert_line --index 7 '9: a\\\'
  assert_line --index 8 '10: a\\\a'

  # regex #2:
  assert_line --index 9 '13: \$'
  assert_line --index 10 '14: \$1'
  assert_line --index 11 '15: a\$'
  assert_line --index 12 '16: a\$1'

  assert_line --index 13 '18: \\\$'
  assert_line --index 14 '19: \\\$1'
  assert_line --index 15 '20: a\\\$'
  assert_line --index 16 '21: a\\\$1'

  # regex #3:
  assert_line --index 17 '24: \${'
  assert_line --index 18 '25: \${1'
  assert_line --index 19 '26: a\${'
  assert_line --index 20 '27: a\${1'

  assert_line --index 21 '29: \\\${'
  assert_line --index 22 '30: \\\${1'
  assert_line --index 23 '31: a\\\${'
  assert_line --index 24 '32: a\\\${1'

  # regex #4:
  assert_line --index 25 '35: \${a'
  assert_line --index 26 '36: \${a-'
  assert_line --index 27 '37: a\${a'
  assert_line --index 28 '38: a\${a-'

  assert_line --index 29 '40: \\\${a'
  assert_line --index 30 '41: \\\${a-'
  assert_line --index 31 '42: a\\\${a'
  assert_line --index 32 '43: a\\\${a-'
}

@test 'check_esc <template>: print OK message if <template> does not contain invalid escape sequences' {
  local template="$(cat "$FIXTURE_ROOT/escape.valid.tmpl")"
  run check_esc "$template"
  assert_success
  assert_output 'Everything looks good!'
}

# Interface.
@test 'check_esc <template>: return 0 if <template> does not contain invalid escape sequences' {
  local template=''
  run check_esc "$template"
  assert_success
}

@test 'check_esc <template>: return 1 if <template> contains invalid escape sequences' {
  local template='\'
  run check_esc "$template"
  assert_failure 1
}
