#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'get_escaped <template>: print escaped references found in <template>' {
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
@test 'get_escaped <template>: return 0 if <template> contains escaped references' {
  local template='\$a'
  run get_escaped "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'a' ]
}

@test 'get_escaped <template>: return 1 if <template> does not contain escaped references' {
  local template=''
  run get_escaped "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}
