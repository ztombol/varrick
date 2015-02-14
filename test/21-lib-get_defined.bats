#!/usr/bin/env bats

load lib-test-helper

LIB_DIR="$BATS_TEST_DIRNAME/../lib/expand-template"
. "$LIB_DIR/expand-template"

# Correctness.
@test 'get_defined() without escaping prints list of defined references' {
  export defined1=1 defined2=2
  local template='$defined1 \$defined2'
  run get_defined "$template" 0
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == 'defined1' ]
  [ "${lines[1]}" == 'defined2' ]
}

@test 'get_defined() with escaping prints list of defined non-escaped references' {
  export defined1=1 defined2=2
  local template='$defined1 \$defined2'
  run get_defined "$template" 1
  [ "$status" -eq 0 ]
  [ "$output" == 'defined1' ]
}

# Interface.
@test 'get_defined() returns 0 when there are defined references' {
  export defined=1
  local template='$defined'
  run get_defined "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'defined' ]
}

@test 'get_defined() returns 1 when there are no defined references' {
  local template=''
  run get_defined "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}

@test 'get_defined() handles escaping by default' {
  export defined=1
  local template='\$defined'
  run get_defined "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}
