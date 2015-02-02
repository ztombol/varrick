# Helper for loading test fixtures.
fixtures () {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "$FIXTURE_ROOT")"
}

# Create a temporary directory with the test templates and set path of executable to test.
setup () {
  export TMP="$(mktemp --directory --tmpdir="$BATS_TMPDIR" "bats-expand-template-$BATS_TEST_NAME.XXXXXXXXXX")"
  cp -R "$BATS_TEST_DIRNAME/res"/* "$TMP"
  export EXEC="$BATS_TEST_DIRNAME/../expand-template"
}

# Delete the temporary directory.
teardown () {
  [ -e "$TMP" ] && rm -r "$TMP"
}
