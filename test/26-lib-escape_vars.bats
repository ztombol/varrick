#!/usr/bin/env bats

load lib-test-helper

LIB_DIR="$BATS_TEST_DIRNAME/../lib/expand-template"

# Correctness.
@test 'escape_vars() escapes slashes in the given environment variables' {
  export var1='\' var2='\\'
  run bash <<-EOCMD
    . "$LIB_DIR/expand-template"
    escape_vars var1 var2
    echo "\$var1"
    echo "\$var2"
	EOCMD
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == '\\' ]
  [ "${lines[1]}" == '\\\\' ]
}
