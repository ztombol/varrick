#!/usr/bin/env bats

load bin-test-helper

# Test option.
test_e_no-expand () {
  local template='$_thing'
  run bash -c "echo '$template' | '$EXEC' $*"
  [ "$status" -eq 0 ]
  [ "$output" == '$_thing' ]
}

@test '-e: do not expand undefined references' {
  test_e_no-expand -e
}

@test '--no-expand: do not expand undefined references' {
  test_e_no-expand --no-expand
}

# Test correctness.
@test '-e: do not alter behaviour if all references are defined' {
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
@test '-ex: enable escaping and do not expand undefined references' {
  test_e_no-expand_x_escape -ex
}

@test '--no-expand --escape: enable escaping and do not expand undefined references' {
  test_e_no-expand_x_escape --no-expand --escape
}

@test "-em: return 1 and display an error message on mutually exclusive options" {
  run bash -c "echo '' | '$EXEC' -e -m"
  [ "$status" -eq 1 ]
  [ "$output" == "Error: \`--missing' (-m) and \`--no-expand' (-e) are mutually exclusive!" ]
}
