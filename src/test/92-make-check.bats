#!/usr/bin/env bats

load make-test-helper

@test 'make check: run test suite' {
  # Avoid endless recursion.
  [ "$SKIP_MAKE_CHECK" == 1 ] && skip

  run env -i bash -c "cd '$MAIN_DIR'; make SKIP_MAKE_CHECK=1 check"
  [ "$status" -eq 0 ]

  # Match tap output.
  if ! [[ "$output" =~ ^bats.*?$'\n'[0-9]+\.\.[0-9]+($'\n'ok [0-9]+.*?)+$ ]]; then
    echo 'ERROR: Something went wrong while running the test suite!' >&2
    echo "$output"
    false
  fi
}
