#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_e_no-expand () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '$_thing' ]
}

@test "\`-e' does not expand reference of undefined variable" {
  test_e_no-expand -e
}

@test "\`--no-expand' does not expand reference of undefined variable" {
  test_e_no-expand --no-expand
}

# Test correctness.
@test "\`-e' does not affect behaviour when all referenced variables are defined" {
  local template='$_thing'
  export _thing=thing
  run bash -c "echo '$template' | '$EXEC' -e"
  [ "$status" -eq 0 ]
  [ "$output" == 'thing' ]
}

# Test with other options.
test_e_no-expand_x_escape () {
  local template='\$_do $_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '$_do $_thing' ]
}

# NOTE: Testing `-ex' in addition to `-x' does not give more assurance of
#       correctness, because of how `-e' and `-x' are currently defined.
#       However, because both cases are handled by different code paths for
#       cleanness, their tests are included to make sure they are not forgotten
#       when the definitions change in the future.
@test "\`-ex' enables escaping and does not expand reference of undefined variable" {
  test_e_no-expand_x_escape -ex
}

@test "\`--no-expand --escape' enables escaping and does not expand reference of undefined variable" {
  test_e_no-expand_x_escape --no-expand --escape
}

@test "\`-e' and \`-m' are mutually exclusive" {
  run bash -c "echo '' | '$EXEC' -e -m"
  [ "$status" -eq 1 ]
  [ "$output" == "Error: \`--missing' (-m) and \`--no-expand' (-e) are mutually exclusive!" ]
}
