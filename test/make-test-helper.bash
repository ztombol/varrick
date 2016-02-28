#
# # Testing a Makefile
# --------------------
#
# When testing Makefile targets it is recommended to follow the
# following guidelines to avoid inaccurate tests and hard to debug
# problems.
#
#   - Work on a temporary copy of the source.
#   - Use a clean execution environment.
#
#
# ## Work on a temporary copy
# ---------------------------
#
# To ensure that tests always run on a clean and easily reproducible
# copy of the source, it is a good idea to create a temporary copy for
# each test.
#
# For good performance, unless relevant, avoid copying version control
# files, e.g. `.git` directory.
#
# For an example, see the `setup` function.
#
#
# ## Use a clean execution environment
# ------------------------------------
#
# Running commands using `env -i` provides a clean execution environment
# and prevents variables set in the test function (or in `setup`) to
# accidentally contaminate the test environment. This makes any
# modification to the test environment explicit and makes test cases
# easier to understand.
#
#     run env -i bash -c 'make <target-to-test>'
#
# As a side effect, output testing also becomes simpler. Makefiles often
# provide a target to run the test suite. In turn, if you are reading
# this, you have tests that use `make` to test other targets. When
# `make` is used recursively, it emits additional lines of output.
#
#     make[1]: Entering directory...
#     <output to be tested>
#     make[1]: Leaving directory...
#
# Using a clean execution environment avoids the added complexity of
# having to conditionally deal with these additional lines. At the same
# time, when the appearance of these lines are the desired outcome, they
# can be allowed by explicitly specifying `$MAKELEVEL`, the variable
# responsible for this behaviour.
#
#     run env -i bash -c "export MAKELEVEL='$MAKELEVEL'
#                         make <target-to-test>"
#
# For examples, see the tests in `9?-make-*.bats`.
#
# I encountered this hard to debug problem while testing Varrick.
#
# > The `Makefile` exports and sets the default value of a number of
# > variables, notably `$SRCDIR` the path of the directory containing
# > the source of the application. For customisation, this variable is
# > only set when it has not been provided by the environment. For each
# > test, `setup` creates a temporary copy of the project to work on,
# > and sets the `$SRCDIR` global variable to the absolute path of the
# > source directory of the temporary copy. This collides with the
# > variable set the `Makefile`, and since it is exported, the
# > overwritten value will leak into the test environment and prevent
# > `Makefile` to set the default. In turn, this will mess up the output
# > of the `install` target, but only when the test suite is ran via
# > `make check`. Tests pass when the test suite is ran directly with
# > `bats`.
#
# It is a silly mistake that could be easily fixed by using two
# different variables. However it highlights, how easily the test
# environment can be contaminated, and how difficult it is to debug such
# issues. Therefore, it is highly recommended to run tests in a clear
# environment.
#

# Create a temporary copy of the entire project.
setup () {
  # Create a temporary directory.
  local dir_name='bats'
  dir_name+='-varrick'
  dir_name+="-${BATS_TEST_FILENAME##*/}"
  dir_name+="-${BATS_TEST_NUMBER}"
  dir_name+="-${BATS_TEST_NAME}"
  dir_name+='-XXXXXXXXXX'
  export TMP="$(mktemp --directory --tmpdir="$BATS_TMPDIR" "$dir_name")"

  # Copy and clean source.
  local src_main_dir="${BATS_TEST_DIRNAME}/.."
  find "$src_main_dir" -maxdepth 1 -mindepth 1 ! -name .git \
                       -exec cp -a --reflink=auto -t "$TMP" '{}' \+
  env -i bash -c "cd '$TMP'
                  make clean &>/dev/null"

  # Set project paths.
  MAIN_DIR="$TMP"
  SRCDIR="${TMP}/src"
  DOCSDIR="${TMP}/docs"
}

# Delete temporary copy.
teardown () {
  # TODO: Add a debug environment variable that prevents the deletion of `$TMP'.
  [ -e "$TMP" ] && rm -rf "$TMP"
}

# Load a library from the `${BATS_TEST_DIRNAME}/test_helper' directory.
#
# Globals:
#   none
# Arguments:
#   $1 - name of library to load
# Returns:
#   0 - on success
#   1 - otherwise
load_lib() {
  local name="$1"
  load "test_helper/${name}/load"
}

load_lib bats-core
load_lib bats-assert
load_lib bats-file
BATSLIB_FILE_PREFIX="$MAIN_DIR"
