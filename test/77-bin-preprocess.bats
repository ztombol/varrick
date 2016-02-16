#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_p_preprocess () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '\$_thing' ]
}

@test '-p: escape references and backslashes' {
  test_p_preprocess -p
}

@test '--preprocess: escape references and backslashes' {
  test_p_preprocess --preprocess
}
