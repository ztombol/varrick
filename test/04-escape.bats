#!/usr/bin/env bats

load test-helper

# Test option.
test_x_escape () {
  run bash -c "echo '"'\$escaped'"' | \"$EXEC\" $1"
  [ "$status" -eq 0 ]
  [ "$output" == '$escaped' ]
}

@test "\`-x' enables escaping variable references" {
  test_x_escape -x
}

@test "\`--escape' enables escaping variable references" {
  test_x_escape --escape
}

# Test correctness.
@test 'escaping works correctly' {
  local template="$TMP/escape.tmpl"
  export var=value
  run "$EXEC" -x "$template"
  [ "$status" -eq 0 ]
  # TODO(ztombol): BATS does not save empty lines in `$lines'. In case this
  #                behaviour is changed upstream, adjust the line numbers
  #                below.
  #[ "${#lines[@]}" -eq 23  ]
  [ "${#lines[@]}" -eq 18  ]

  # expanding a reference
  [ "${lines[ 1]}" == 'value' ]
  [ "${lines[ 2]}" == 'value' ]

  # do not expand an escaped reference
  [ "${lines[ 4]}" == '$var' ]
  [ "${lines[ 5]}" == '${var}' ]

  # escaping the escape character
  [ "${lines[ 7]}" == '\' ]

  # expand a reference after an escaped escape character
  [ "${lines[ 9]}" == '\value' ]
  [ "${lines[10]}" == '\value' ]

  # escaping is left-associative
  [ "${lines[12]}" == '\$var' ]
  [ "${lines[13]}" == '\${var}' ]
  [ "${lines[14]}" == '\\value' ]
  [ "${lines[15]}" == '\\value' ]

  # escaping the escape character in substituted values
  [ "${lines[17]}" == '\' ]
}

# Testing with other options (tests get_referenced).
@test "escaped variables are not reported by -e when they are missing" {
  export var='\\'
  run bash -c "echo '$var \$missing' | \"$EXEC\" -xe"
  [ "$status" -eq 0 ]
  [ "$output" == '\ $missing' ]
}
