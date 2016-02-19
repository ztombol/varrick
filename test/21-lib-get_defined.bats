#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"

# Correctness.
@test 'get_defined <template> <escaping=0>: disable escaping and print defined references found in <template>' {
  local template='$defined1 \$defined2'
  export defined1=1 defined2=2
  run get_defined "$template" 0
  assert_success
  assert_equal "${#lines[@]}" 2
  assert_line --index 0 'defined1'
  assert_line --index 1 'defined2'
}

@test 'get_defined <template> <escaping=1>: enable escaping and print defined non-escaped references found in <template>' {
  local template='$defined1 \$defined2'
  export defined1=1 defined2=2
  run get_defined "$template" 1
  assert_success
  assert_output 'defined1'
}

# Interface.
@test 'get_defined <template>: return 0 if <template> contains defined references' {
  local template='$defined'
  export defined=1
  run get_defined "$template"
  assert_success
  assert_output 'defined'
}

@test 'get_defined <template>: return 0 if <template> does not contain defined references' {
  local template=''
  run get_defined "$template"
  assert_failure 1
  assert_output ''
}

@test 'get_defined <template>: disable escaping by default' {
  local template='\$defined'
  export defined=1
  run get_defined "$template"
  assert_success
  assert_output 'defined'
}
