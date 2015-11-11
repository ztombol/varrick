#!/usr/bin/env bats

load lib-test-helper

# Correctness.
@test 'escape_vars <variable...>: escape backslashes in <variable...>' {
  export var1='\' var2='\\'
  run bash <<EOCMD
    . "$LIB_DIR/zhu-li.sh"
    escape_vars var1 var2
    echo "\$var1"
    echo "\$var2"
EOCMD
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == '\\' ]
  [ "${lines[1]}" == '\\\\' ]
}
