#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_c_check () {
  local template='\'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == 'Error: Invalid escaping in the following lines:' ]
  [ "${lines[1]}" == '1: \' ]
}

@test '-c: display lines containing invalid escape sequences' {
  test_c_check -c
}

@test '--check: display lines containing invalid escape sequences' {
  test_c_check --check
}

@test '-c: report good status if there are no invalid escapes' {
  local template='\\'
  run bash -c "echo '$template' | '$EXEC' -c"
  [ "$status" -eq 0 ]
  [ "$output" == 'Everything looks good!' ]
}
