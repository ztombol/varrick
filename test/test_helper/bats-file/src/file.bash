#
# bats-file - Common file assertions for Bats
#

# Fail and display path of the file (or directory) if it does not exist.
# The shortest prefix matching the pattern BATSLIB_FILE_PATH_PREFIX is
# removed from the path. If the pattern does not match or is unset or
# empty, the unmodified path is displayed.
#
# This function is the logical complement of `assert_file_not_exist'.
#
# Globals:
#   BATSLIB_FILE_PATH_PREFIX
# Arguments:
#   $1 - path
# Returns:
#   0 - file exists
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_file_exist () {
  local -r file="$1"
  if [[ ! -e "$file" ]]; then
    batslib_print_kv_single 4 'path' "\`${file#${BATSLIB_FILE_PREFIX}}'" \
      | batslib_decorate 'file does not exist' \
      | fail
  fi
}

# Fail and display path of the file (or directory) if it exists. The
# shortest prefix matching the pattern BATSLIB_FILE_PATH_PREFIX is
# removed from the path. If the pattern does not match or is unset or
# empty, the unmodified path is displayed.
#
# This function is the logical complement of `assert_file_exist'.
#
# Globals:
#   BATSLIB_FILE_PATH_PREFIX
# Arguments:
#   $1 - path
# Returns:
#   0 - file exists
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_file_not_exist () {
  local -r file="$1"
  if [[ -e "$file" ]]; then
    batslib_print_kv_single 4 'path' "\`${file#${BATSLIB_FILE_PREFIX}}'" \
      | batslib_decorate 'file exists, but it was expected to be absent' \
      | fail
  fi
}
