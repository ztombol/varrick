#!/usr/bin/env bats

load test-helper
fixtures env

# Test option.
test_s_summary () {
  local template=''
  run bash -c "echo '$template' | \"$EXEC\" $*"
  [ "$status" -eq 0 ]
  [ "$output" == 'Everything looks good!' ]
}

@test "\`-c' checks for invalid escape sequences" {
  test_s_summary -c
}

@test "\`--check' checks for invalid escape sequences" {
  test_s_summary --check
}

# Test correctness.
@test "report success and exit with 0 on a properly escaped template" {
  local template="$TMP/check.valid.tmpl"
  run "$EXEC" -c "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'Everything looks good!' ]
}

@test "report invalid escape sequences and exits with 1 on an ivalidly escaped template" {
  local template="$TMP/check.invalid.tmpl"
  run "$EXEC" -c "$template"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 13  ]
  [ "${lines[ 0]}" == 'Error: Invalid escaping in the following lines:' ]

  # regex #1:
  [ "${lines[ 1]}" == '6: \' ]
  [ "${lines[ 2]}" == '7: b\a1' ]
  [ "${lines[ 3]}" == '8: $\a1' ]
  [ "${lines[ 4]}" == '9: $\{a1}' ]

  # regex #2:
  [ "${lines[ 5]}" == '12: \$' ]
  [ "${lines[ 6]}" == '13: b\$-' ]

  # regex #3:
  [ "${lines[ 7]}" == '16: \${' ]
  [ "${lines[ 8]}" == '17: b\${-' ]
  [ "${lines[ 9]}" == '18: \${-}' ]

  # regex #4:
  [ "${lines[10]}" == '21: \${a1' ]
  [ "${lines[11]}" == '22: b\${a1-' ]
  [ "${lines[12]}" == '23: \${a1-}' ]
}
