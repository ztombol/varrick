#!/usr/bin/env bats

load lib-test-helper
fixtures lib

# Correctness.
@test 'unescape: remove escape characters in <template> read from STDIN' {
  local template="$FIXTURE_ROOT/reference.tmpl"
  run bash -c ". '$LIB_DIR/zhu-li.sh'; cat '$template' | escape | unescape"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 32 ]

  # Escaped.
  [ "${lines[ 1]}" == '$a1' ]
  [ "${lines[ 2]}" == 'b$a2' ]
  [ "${lines[ 3]}" == '${a3}' ]
  [ "${lines[ 4]}" == 'b${a4}' ]
  [ "${lines[ 5]}" == '${a5}b' ]
  [ "${lines[ 6]}" == 'b${a6}b' ]
  [ "${lines[ 7]}" == '\$a7' ]
  [ "${lines[ 8]}" == 'b\$a8' ]
  [ "${lines[ 9]}" == '\${a9}' ]
  [ "${lines[10]}" == 'b\${a10}' ]
  [ "${lines[11]}" == '\${a11}b' ]
  [ "${lines[12]}" == 'b\${a12}b' ]

  # Not escaped.
  [ "${lines[14]}" == '$a13' ]
  [ "${lines[15]}" == 'b$a14' ]
  [ "${lines[16]}" == '${a15}' ]
  [ "${lines[17]}" == 'b${a16}' ]
  [ "${lines[18]}" == '${a17}b' ]
  [ "${lines[19]}" == 'b${a18}b' ]
  [ "${lines[20]}" == '\$a19' ]
  [ "${lines[21]}" == 'b\$a20' ]
  [ "${lines[22]}" == '\${a21}' ]
  [ "${lines[23]}" == 'b\${a22}' ]
  [ "${lines[24]}" == '\${a23}b' ]
  [ "${lines[25]}" == 'b\${a24}b' ]
  [ "${lines[26]}" == '\\$a25' ]
  [ "${lines[27]}" == 'b\\$a26' ]
  [ "${lines[28]}" == '\\${a27}' ]
  [ "${lines[29]}" == 'b\\${a28}' ]
  [ "${lines[30]}" == '\\${a29}b' ]
  [ "${lines[31]}" == 'b\\${a30}b' ]
}
