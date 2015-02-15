#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"

# Correctness.
@test 'get_missing() without escaping prints list of missing references' {
  local template='$missing1 \$missing2'
  run get_missing "$template" 0
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == 'missing1' ]
  [ "${lines[1]}" == 'missing2' ]
}

@test 'get_missing() with escaping prints list of missing non-escaped references' {
  local template='$missing1 \$missing2'
  run get_missing "$template" 1
  [ "$status" -eq 0 ]
  [ "$output" == 'missing1' ]
}

# Interface.
@test 'get_missing() returns 0 when there are missing references' {
  local template='$missing'
  run get_missing "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'missing' ]
}

@test 'get_missing() returns 1 when there are no missing references' {
  local template=''
  run get_missing "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}

@test 'get_missing() handles escaping by default' {
  local template='\$missing'
  run get_missing "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}
