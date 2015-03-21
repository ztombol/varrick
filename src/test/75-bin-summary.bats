#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_s_summary () {
  local template='\$_do $_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == 'Referenced variables:' ]
  [ "${lines[1]}" == '_do' ]
  [ "${lines[2]}" == '_thing' ]
}

@test "\`-s' reports referenced variables" {
  test_s_summary -s
}

@test "\`--summary' reports referenced variables" {
  test_s_summary --summary
}

# Test correctness.
test_s_summary_empty () {
  local template=''
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '' ]
}

@test "\`-s' produces empty output when there are no referenced variables" {
  test_s_summary_empty -s
}

@test "\`-sx' produces empty output when there are no referenced variables or escaped references" {
  test_s_summary_empty -sx
}

# Test with other options.
test_s_summary_x_escape () {
  local template='\$_do $_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == 'Escaped variables:' ]
  [ "${lines[1]}" == '_do' ]
  [ "${lines[2]}" == 'Referenced variables:' ]
  [ "${lines[3]}" == '_thing' ]
}

@test "\`-sx' reports referenced variables and variables of escaped references" {
  test_s_summary_x_escape -sx
}

@test "\`--summary --escape' reports referenced variables and variables of escaped references" {
  test_s_summary_x_escape --summary --escape
}
