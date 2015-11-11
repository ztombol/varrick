#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"

# Correctness.
@test 'get_missing <template> <escaping=0>: disable escaping and print undefined references found in <template>' {
  local template='$missing1 \$missing2'
  run get_missing "$template" 0
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == 'missing1' ]
  [ "${lines[1]}" == 'missing2' ]
}

@test 'get_missing <template> <escaping=1>: enable escaping and print undefined non-escaped references found in <template>' {
  local template='$missing1 \$missing2'
  run get_missing "$template" 1
  [ "$status" -eq 0 ]
  [ "$output" == 'missing1' ]
}

# Interface.
@test 'get_missing <template>: return 0 if <template> contains undefined references' {
  local template='$missing'
  run get_missing "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'missing' ]
}

@test 'get_missing <template>: return 1 if <template> does not contain undefined references' {
  local template=''
  run get_missing "$template"
  [ "$status" -eq 1 ]
  [ "$output" == '' ]
}

@test 'get_missing <template>: disable escaping by default' {
  local template='\$missing'
  run get_missing "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'missing' ]
}
