#!/usr/bin/env bats

load test-helper
LIB_DIR="$BATS_TEST_DIRNAME/../lib/expand-template"
. "$LIB_DIR/expand-template"

# Correctness.
@test 'check_esc() prints error and lines containing invalid escapes' {
  local template="$(cat "$TMP/escape.invalid.tmpl")"
  run check_esc "$template"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 33 ]
  [ "${lines[ 0]}" == 'Error: Invalid escaping in the following lines:' ]

  # regex #1:
  [ "${lines[ 1]}" == '2: \' ]
  [ "${lines[ 2]}" == '3: \a' ]
  [ "${lines[ 3]}" == '4: a\' ]
  [ "${lines[ 4]}" == '5: a\a' ]

  [ "${lines[ 5]}" == '7: \\\' ]
  [ "${lines[ 6]}" == '8: \\\a' ]
  [ "${lines[ 7]}" == '9: a\\\' ]
  [ "${lines[ 8]}" == '10: a\\\a' ]

  # regex #2:
  [ "${lines[ 9]}" == '13: \$' ]
  [ "${lines[10]}" == '14: \$1' ]
  [ "${lines[11]}" == '15: a\$' ]
  [ "${lines[12]}" == '16: a\$1' ]

  [ "${lines[13]}" == '18: \\\$' ]
  [ "${lines[14]}" == '19: \\\$1' ]
  [ "${lines[15]}" == '20: a\\\$' ]
  [ "${lines[16]}" == '21: a\\\$1' ]

  # regex #3:
  [ "${lines[17]}" == '24: \${' ]
  [ "${lines[18]}" == '25: \${1' ]
  [ "${lines[19]}" == '26: a\${' ]
  [ "${lines[20]}" == '27: a\${1' ]

  [ "${lines[21]}" == '29: \\\${' ]
  [ "${lines[22]}" == '30: \\\${1' ]
  [ "${lines[23]}" == '31: a\\\${' ]
  [ "${lines[24]}" == '32: a\\\${1' ]

  # regex #4:
  [ "${lines[25]}" == '35: \${a' ]
  [ "${lines[26]}" == '36: \${a-' ]
  [ "${lines[27]}" == '37: a\${a' ]
  [ "${lines[28]}" == '38: a\${a-' ]

  [ "${lines[29]}" == '40: \\\${a' ]
  [ "${lines[30]}" == '41: \\\${a-' ]
  [ "${lines[31]}" == '42: a\\\${a' ]
  [ "${lines[32]}" == '43: a\\\${a-' ]
}

@test 'check_esc() prints OK message when ithere are no invalid escapes' {
  local template="$(cat "$TMP/escape.valid.tmpl")"
  run check_esc "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'Everything looks good!' ]
}

# Interface.
@test 'check_esc() returns 0 when there are no invalid escape sequences' {
  local template=''
  run check_esc "$template"
  [ "$status" -eq 0 ]
}

@test 'check_esc() returns 1 when there are invalid escape sequences' {
  local template='\'
  run check_esc "$template"
  [ "$status" -eq 1 ]
}
