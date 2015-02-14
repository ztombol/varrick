#!/usr/bin/env bats

load test-helper

# Test option.
test_x_escape () {
  local template='\$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '$_thing' ]
}

@test "\`-x' enables escaping references" {
  test_x_escape -x
}

@test "\`--escape' enables escaping references" {
  test_x_escape --escape
}
