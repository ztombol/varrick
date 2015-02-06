#!/usr/bin/env bats

load test-helper
fixtures env

# Test option.
test_s_summary () {
  local template='The \$_thing! \\$_do the $_thing!'
  run bash -c "echo '$template' | \"$EXEC\" $*"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == 'Referenced variables:' ]
  [ "${lines[1]}" == '_do' ]
  [ "${lines[2]}" == '_thing' ]
}

test_s_summary_x_escape () {
  local template='The \$_thing! \\$_do the $_thing!'
  run bash -c "echo '$template' | \"$EXEC\" $*"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 5 ]
  [ "${lines[0]}" == 'Escaped variables:' ]
  [ "${lines[1]}" == '_thing' ]
  [ "${lines[2]}" == 'Referenced variables:' ]
  [ "${lines[3]}" == '_do' ]
  [ "${lines[4]}" == '_thing' ]
}

@test "\`-s' displays list of referenced variables" {
  test_s_summary -s
}

@test "\`--summary' displays list of referenced variables" {
  test_s_summary --summary
}

@test "\`-sx' displays list of referenced and escaped variables" {
  test_s_summary_x_escape -sx
}

@test "\`--summary --escape' displays list of referenced and escaped variables" {
  test_s_summary_x_escape --summary --escape
}
