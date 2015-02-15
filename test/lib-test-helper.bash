# Helper for loading test fixtures.
fixtures () {
  FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
  RELATIVE_FIXTURE_ROOT="$(bats_trim_filename "$FIXTURE_ROOT")"
}

# Set library location.
LIB_DIR="$BATS_TEST_DIRNAME/../lib/varrick"
