#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'get_referenced <template> <escaping=0>: disable escaping and print all references found in <template>' {
  local template="$(cat "$FIXTURE_ROOT/reference.tmpl")"
  run get_referenced "$template" 0
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 30 ]
  [ "${lines[ 0]}" == 'a1' ]
  [ "${lines[ 1]}" == 'a10' ]
  [ "${lines[ 2]}" == 'a11' ]
  [ "${lines[ 3]}" == 'a12' ]
  [ "${lines[ 4]}" == 'a13' ]
  [ "${lines[ 5]}" == 'a14' ]
  [ "${lines[ 6]}" == 'a15' ]
  [ "${lines[ 7]}" == 'a16' ]
  [ "${lines[ 8]}" == 'a17' ]
  [ "${lines[ 9]}" == 'a18' ]
  [ "${lines[10]}" == 'a19' ]
  [ "${lines[11]}" == 'a2' ]
  [ "${lines[12]}" == 'a20' ]
  [ "${lines[13]}" == 'a21' ]
  [ "${lines[14]}" == 'a22' ]
  [ "${lines[15]}" == 'a23' ]
  [ "${lines[16]}" == 'a24' ]
  [ "${lines[17]}" == 'a25' ]
  [ "${lines[18]}" == 'a26' ]
  [ "${lines[19]}" == 'a27' ]
  [ "${lines[20]}" == 'a28' ]
  [ "${lines[21]}" == 'a29' ]
  [ "${lines[22]}" == 'a3' ]
  [ "${lines[23]}" == 'a30' ]
  [ "${lines[24]}" == 'a4' ]
  [ "${lines[25]}" == 'a5' ]
  [ "${lines[26]}" == 'a6' ]
  [ "${lines[27]}" == 'a7' ]
  [ "${lines[28]}" == 'a8' ]
  [ "${lines[29]}" == 'a9' ]
}

@test 'get_referenced <template> <escaping=1>: enable escaping and print non-escaped references found in <template>' {
  local template="$(cat "$FIXTURE_ROOT/reference.tmpl")"
  run get_referenced "$template" 1
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 18 ]
  [ "${lines[ 0]}" == 'a13' ]
  [ "${lines[ 1]}" == 'a14' ]
  [ "${lines[ 2]}" == 'a15' ]
  [ "${lines[ 3]}" == 'a16' ]
  [ "${lines[ 4]}" == 'a17' ]
  [ "${lines[ 5]}" == 'a18' ]
  [ "${lines[ 6]}" == 'a19' ]
  [ "${lines[ 7]}" == 'a20' ]
  [ "${lines[ 8]}" == 'a21' ]
  [ "${lines[ 9]}" == 'a22' ]
  [ "${lines[10]}" == 'a23' ]
  [ "${lines[11]}" == 'a24' ]
  [ "${lines[12]}" == 'a25' ]
  [ "${lines[13]}" == 'a26' ]
  [ "${lines[14]}" == 'a27' ]
  [ "${lines[15]}" == 'a28' ]
  [ "${lines[16]}" == 'a29' ]
  [ "${lines[17]}" == 'a30' ]
}

# Interface.
@test 'get_referenced <template>: return 0 if <template> contains references' {
  local template='$a'
  run get_referenced "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'a' ]
}

@test 'get_referenced <template>: return 1 if <template> does not contain references' {
  local template=''
  run get_referenced "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}

@test 'get_referenced <template>: disable escaping by default' {
  local template='\$a'
  run get_referenced "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'a' ]
}
