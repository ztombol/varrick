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

# Test escaping on template `$1'.
test_escape () {
  run bash -c "echo '$1' | \"$EXEC\" -x"
}

# Test escaping on template `$1' when `$var' is set to `value'.
test_escape_var () {
  export var=value
  test_escape "$1"
}

@test 'expanding a reference when escaping is enabled ($var -> value)' {
  test_escape_var '$var'
  [ "$status" -eq 0 ]
  [ "$output" == 'value' ]
}

@test 'expanding a braced reference when escaping is enabled (${var} -> value)' {
  test_escape_var '${var}'
  [ "$status" -eq 0 ]
  [ "$output" == 'value' ]
}

@test 'do not expand an escaped reference (\$var -> $var)' {
  test_escape_var '\$var'
  [ "$status" -eq 0 ]
  [ "$output" == '$var' ]
}

@test 'do not expand an escaped braced reference (\${var} -> ${var})' {
  test_escape_var '\${var}'
  [ "$status" -eq 0 ]
  [ "$output" == '${var}' ]
}

@test 'escaping the escape character (\\ -> \)' {
  test_escape_var '\\'
  [ "$status" -eq 0 ]
  [ "$output" == '\' ]
}

@test 'expand a reference after an escaped escape character (\\$var -> \value)' {
  test_escape_var '\\$var'
  [ "$status" -eq 0 ]
  [ "$output" == '\value' ]
}

@test 'expand a braced reference after an escaped escape character (\\${var} -> \value)' {
  test_escape_var '\\${var}'
  [ "$status" -eq 0 ]
  [ "$output" == '\value' ]
}

@test 'escaping is left-associative (\\\$var -> \$var)' {
  test_escape_var '\\\$var'
  [ "$status" -eq 0 ]
  [ "$output" == '\$var' ]
}

@test 'escaping is left-associative (\\\${var} -> \${var})' {
  test_escape_var '\\\${var}'
  [ "$status" -eq 0 ]
  [ "$output" == '\${var}' ]
}

@test 'escaping is left-associative (\\\\$var -> \\value)' {
  test_escape_var '\\\\$var'
  [ "$status" -eq 0 ]
  [ "$output" == '\\value' ]
}

@test 'escaping is left-associative (\\\\${var} -> \\value)' {
  test_escape_var '\\\\${var}'
  [ "$status" -eq 0 ]
  [ "$output" == '\\value' ]
}

@test "escaping the escape character in substituted values" {
  export var='\\'
  test_escape '$var'
  [ "$status" -eq 0 ]
  [ "$output" == "$var" ]
}

# Testing with other options (tests get_referenced).
@test "escaped variables are not reported by -e when they are missing" {
  export var='\\'
  run bash -c "echo '$var \$missing' | \"$EXEC\" -xe"
  [ "$status" -eq 0 ]
  [ "$output" == '\ $missing' ]
}
