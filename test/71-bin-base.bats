#!/usr/bin/env bats

load bin-test-helper

# Usage
test_u_usage () {
  run "$EXEC" $*
  assert_success
  assert_equal "${#lines[@]}" 5
  assert_line --index 0 --regexp '^Varrick v[0-9]+.[0-9]+.[0-9]+$'
  assert_line --index 1 --regexp '^Usage:'
}

@test '-u: display usage' {
  test_u_usage -u
}

@test '--usage: display usage' {
  test_u_usage --usage
}

# Help
test_h_help () {
  run "$EXEC" $*
  assert_success
  assert_equal "${#lines[@]}" 14
  assert_line --index 0 --regexp '^Varrick v[0-9]+.[0-9]+.[0-9]+$'
  assert_line --index 1 --regexp '^Usage:'
}

@test '-h: display help' {
  test_h_help -h
}

@test '--help: display help' {
  test_h_help --help
}

# Version
test_v_version () {
  run "$EXEC" $*
  assert_success
  assert_output --regexp '^Varrick v[0-9]+.[0-9]+.[0-9]+$'
}

@test '-v: display version' {
  test_v_version -v
}

@test '--version: display version' {
  test_v_version --version
}
