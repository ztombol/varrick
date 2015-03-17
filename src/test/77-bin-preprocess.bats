#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_p_preprocess () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '\$_thing' ]
}

@test "\`-p' escapes references and slashes" {
  test_p_preprocess -p
}

@test "\`--preprocess' escapes references and slashes" {
  test_p_preprocess --preprocess
}
