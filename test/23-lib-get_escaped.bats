#!/usr/bin/env bats

load lib-test-helper
fixtures lib

LIB_DIR="$BATS_TEST_DIRNAME/../lib/expand-template"
. "$LIB_DIR/expand-template"

# Correctness.
@test 'get_escaped() prints list of escaped references' {
  local template="$(cat "$FIXTURE_ROOT/reference.tmpl")"
  run get_escaped "$template"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 12 ]
  [ "${lines[ 0]}" == 'a1' ]
  [ "${lines[ 1]}" == 'a10' ]
  [ "${lines[ 2]}" == 'a11' ]
  [ "${lines[ 3]}" == 'a12' ]
  [ "${lines[ 4]}" == 'a2' ]
  [ "${lines[ 5]}" == 'a3' ]
  [ "${lines[ 6]}" == 'a4' ]
  [ "${lines[ 7]}" == 'a5' ]
  [ "${lines[ 8]}" == 'a6' ]
  [ "${lines[ 9]}" == 'a7' ]
  [ "${lines[10]}" == 'a8' ]
  [ "${lines[11]}" == 'a9' ]
}

# Interface.
@test 'get_escaped() returns 0 when there are escaped references' {
  local template='\$a'
  run get_escaped "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'a' ]
}

@test 'get_escaped() returns 1 when there are no escaped references' {
  local template=''
  run get_escaped "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}
