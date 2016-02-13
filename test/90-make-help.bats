#!/usr/bin/env bats

load make-test-helper

@test 'make help: display help' {
  run env -i bash -c "cd '$MAIN_DIR'
                      make help"
  [ "$status" -eq 0 ]
  if ! [[ $output =~ ^$'TARGETS:'.*'ENVIRONMENT:'.*'EXAMPLES:'.*'REFERENCES'.*$ ]]; then
    echo 'ERROR: Help is missing one or more sections!' >&2
    echo '-- output --' >&2
    echo "$output" >&2
    false
  fi
}
