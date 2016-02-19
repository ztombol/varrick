#!/usr/bin/env bats

load make-test-helper

@test 'make check: run test suite' {
  # Avoid endless recursion.
  [ "$SKIP_MAKE_CHECK" == 1 ] && skip

  # Export `$PATH' to be able to use programs in non-standard paths.
  run env -i bash -c "export PATH='$PATH'
                      cd '$MAIN_DIR'
                      make SKIP_MAKE_CHECK=1 check"
  assert_success

  # Match tap output.
  assert_output --regexp $'^bats.*?\n[0-9]+\.\.[0-9]+(\nok [0-9]+.*?)+$'
}
