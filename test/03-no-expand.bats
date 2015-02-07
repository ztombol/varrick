#!/usr/bin/env bats

load test-helper
fixtures env

# Test option.
test_n_no-expand () {
  load "$FIXTURE_ROOT/missing.bash"
  local template="$TMP/dynamic.tmpl"
  run "$EXEC" $1 "$template"
  [ "$status" -eq 0 ]
  [ "$output" == 'The ${_thing}! Do the $_thing!' ]
}

@test "\`-e' does not expand missing variables" {
  test_n_no-expand -e
}

@test "\`--no-expand' does not expand missing variables" {
  test_n_no-expand --no-expand
}

@test "\`--no-expand' and \`--missing' are mutually exclusive" {
  run bash -c "echo '' | \"$EXEC\" --no-expand --missing"
  [ "$status" -eq 1 ]
  [ "$output" == "Error: \`--missing' (-m) and \`--no-expand' (-e) cannot be specified at the same time!" ]
}
