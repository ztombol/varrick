#!/usr/bin/env bats

load lib-test-helper
load "$LIB_DIR/zhu-li.sh"
fixtures lib

# Correctness.
@test 'preprocess() escapes backslashes and variable references' {
  local template="$(cat "$FIXTURE_ROOT/pre_process.tmpl")"
  run preprocess "$template"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 10 ]
  [ "${lines[0]}" == '\\' ]
  [ "${lines[1]}" == '$' ]
  [ "${lines[2]}" == '\$a' ]
  [ "${lines[3]}" == '${' ]
  [ "${lines[4]}" == '${a' ]
  [ "${lines[5]}" == '${a-' ]
  [ "${lines[6]}" == '${a1' ]
  [ "${lines[7]}" == '${a1-' ]
  [ "${lines[8]}" == '${a1-}' ]
  [ "${lines[9]}" == '\${a1}' ]
}
