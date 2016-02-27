#!/usr/bin/env bats

load make-test-helper

@test 'make help: display help' {
  run env -i bash -c "cd '$MAIN_DIR'
                      make help"
  assert_success
  assert_line 'TARGETS:'
  assert_line 'ENVIRONMENT:'
  assert_line 'EXAMPLES:'
  assert_line 'REFERENCES:'
}
