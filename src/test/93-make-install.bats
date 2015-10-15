#!/usr/bin/env bats

load make-test-helper

@test "make install-params: display the default paths" {
  # Paths.
  local SRCDIR='./src'
  local DESTDIR=
  local prefix='/usr/local'
  local exec_prefix="${prefix}"
  local bindir="${exec_prefix}/bin"
  local libexecdir="${exec_prefix}/libexec"
  local libdir="${prefix}/lib"
  local datarootdir="${prefix}/share"
  local mandir="${datarootdir}/man"

  # Run command.
  run env -i bash -c "cd '$MAIN_DIR'; make install-params"
  [ "$status" -eq 0 ]

  # Output.
  [ "${lines[0]}" == '-> Parameters' ]
  local -r vars=(SRCDIR DESTDIR prefix exec_prefix bindir libexecdir libdir
                 datarootdir mandir)
  local var i=1
  for var in "${vars[@]}"; do
    [ "${lines[$i]}" == "$(printf '  %-11s = %s\n' "$var" "${!var}")" ]
    (( ++i ))
  done
  [ "${#lines[@]}" -eq "$i" ]
}

@test "make <path...> install-params: display custom paths" {
  # Paths.
  local SRCDIR='./source'
  local DESTDIR='install'
  local prefix='/prefix'
  local exec_prefix="/exec_prefix"
  local bindir="${exec_prefix}/bindir"
  local libexecdir="${exec_prefix}/libexecdir"
  local libdir="${prefix}/libdir"
  local datarootdir="${prefix}/datarootdir"
  local mandir="${datarootdir}/mandir"

  # Run command.
  run env -i bash -c "cd '$MAIN_DIR'; \
                      make SRCDIR='$SRCDIR' \
                           DESTDIR='$DESTDIR' \
                           prefix='$prefix' \
                           exec_prefix='$exec_prefix' \
                           bindir='$bindir' \
                           libexecdir='$libexecdir' \
                           libdir='$libdir' \
                           datarootdir='$datarootdir' \
                           mandir='$mandir' \
                           install-params"
  [ "$status" -eq 0 ]

  # Output.
  [ "${lines[0]}" == '-> Parameters' ]
  local -r vars=(SRCDIR DESTDIR prefix exec_prefix bindir libexecdir libdir
                 datarootdir mandir)
  local var i=1
  for var in "${vars[@]}"; do
    [ "${lines[$i]}" == "$(printf '  %-11s = %s\n' "$var" "${!var}")" ]
    (( ++i ))
  done
  [ "${#lines[@]}" -eq "$i" ]
}

@test "make <path...> install-files: install to custom location" {
  # Paths.
  local DESTDIR='install'
  local prefix='/prefix'
  local exec_prefix='/exec_prefix'
  local bindir="${exec_prefix}/bindir"
  local libexecdir="${exec_prefix}/libexecdir"
  local libdir="${prefix}/libdir"
  local datarootdir="${prefix}/datarootdir"
  local mandir="${datarootdir}/mandir"

  # Run command.
  run env -i bash -c "cd '$MAIN_DIR'; \
                      make build &>/dev/null; \
                      make DESTDIR='$DESTDIR' \
                           prefix='$prefix' \
                           exec_prefix='$exec_prefix' \
                           bindir='$bindir' \
                           libexecdir='$libexecdir' \
                           libdir='$libdir' \
                           datarootdir='$datarootdir' \
                           mandir='$mandir' \
                           install-files"
  [ "$status" -eq 0 ]

  # Files.
  [ "${lines[0]}" == '-> Installing files' ]
  local i=1
  while local file; IFS=$'\n' read -r file; do
    assert_file_exist "${MAIN_DIR}/${file}"
    [ "${lines[$i]}" == "  $file" ]
    ((++i))
  done < <(installed_files)
  [ "${#lines[@]}" -eq "$i" ]
}

@test "make <path...> install-update: update paths in the launcher" {
  # Paths.
  local DESTDIR='install'
  local prefix='/prefix'
  local exec_prefix='/exec_prefix'
  local bindir="${exec_prefix}/bindir"
  local libexecdir="${exec_prefix}/libexecdir"
  local libdir="${prefix}/libdir"
  local datarootdir="${prefix}/datarootdir"
  local mandir="${datarootdir}/mandir"

  # Run command.
  run env -i bash -c "cd '$MAIN_DIR'; \
                      make build &>/dev/null; \
                      make DESTDIR='$DESTDIR' \
                           prefix='$prefix' \
                           exec_prefix='$exec_prefix' \
                           bindir='$bindir' \
                           libexecdir='$libexecdir' \
                           libdir='$libdir' \
                           datarootdir='$datarootdir' \
                           mandir='$mandir' \
                           install-files \
                           install-update \
                        | sed -e '/^-> Updating files$/,$ !d;'"
  [ "$status" -eq 0 ]

  # Updates.
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" == '-> Updating files' ]

  # Launcher.
  local file="${DESTDIR}${bindir}/varrick"
  [ "${lines[1]}" == "  $file" ]
  assert_launcher_var "${MAIN_DIR}/${file}" '_d8e1_LIBEXEC_DIR' "$libexecdir"
  assert_launcher_var "${MAIN_DIR}/${file}" '_d8e1_LIB_DIR' "$libdir"
}

@test "make <path...> install: install the application" {
  # Paths.
  local DESTDIR='install/'
  local prefix='./prefix'
  local exec_prefix='./exec_prefix'
  local bindir="${exec_prefix}/bindir"
  local libexecdir="${exec_prefix}/libexecdir"
  local libdir="${prefix}/libdir"
  local datarootdir="${prefix}/datarootdir"
  local mandir="${datarootdir}/mandir"

  # Run command.
  run env -i bash -c "cd '${MAIN_DIR}'; \
                      make build &>/dev/null; \
                      make DESTDIR='${MAIN_DIR}/${DESTDIR}' \
                           prefix='$prefix' \
                           exec_prefix='$exec_prefix' \
                           bindir='$bindir' \
                           libexecdir='$libexecdir' \
                           libdir='$libdir' \
                           datarootdir='$datarootdir' \
                           mandir='$mandir' \
                           install"
  [ "$status" -eq 0 ]

  # Test paths.
  run env -i bash -c "cd '${MAIN_DIR}/${DESTDIR}'; \
                      echo 'The thing! Do the thing!' | ${bindir}/varrick"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ "$output" == 'The thing! Do the thing!' ]
}


################################################################################
#                                HELPER FUNCTIONS
################################################################################

# Display the install path of files in `${SRCDIR}/bin'. Paths are delimited by
# newlines.
#
# Globals:
#   SRCDIR
#   DESTDIR
#   bindir
# Arguments:
#   none
# Returns:
#   none
# Outputs:
#   STDOUT - list of paths
installed_files_bin () {
  local src src_file
  for src in "${SRCDIR}/bin"/*; do
    src_file="$(basename "$src")"
    echo "${DESTDIR}${bindir}/${src_file}"
  done
}

# Display the install path of files in `${SRCDIR}/libexec'. Paths are delimited
# by newlines.
#
# Globals:
#   SRCDIR
#   DESTDIR
#   libexecdir
# Arguments:
#   none
# Returns:
#   none
# Outputs:
#   STDOUT - list of paths
installed_files_libexec () {
  local src src_file
  for src in "${SRCDIR}/libexec"/*; do
    src_file="$(basename "$src")"
    echo "${DESTDIR}${libexecdir}/${src_file}"
  done
}

# Display the install path of files under `${SRCDIR}/lib' (recursive). Paths are
# delimited by newlines.
#
# Globals:
#   SRCDIR
#   DESTDIR
#   libdir
# Arguments:
#   none
# Returns:
#   none
# Outputs:
#   STDOUT - list of paths
installed_files_lib () {
  local src_base="${SRCDIR}/lib"
  local IFS=$'\n'
  local src
  for src in $(find "$src_base" -type f); do
    echo "${DESTDIR}${libdir}${src#${src_base}}"
  done
}

# Display the install path of files in `${SRCDIR}/man'. Paths are delimited by
# newlines.
#
# Globals:
#   SRCDIR
#   DESTDIR
#   mandir
# Arguments:
#   none
# Returns:
#   none
# Outputs:
#   STDOUT - list of paths
installed_files_man () {
  local src src_file
  for src in "${SRCDIR}/man"/*.[0-9]; do
    src_file="$(basename "$src")"
    echo "${DESTDIR}${mandir}/man${src_file: -1}/${src_file}"
  done
}

# Display the install path of all program files. Path are delimited by newlines,
# and output in the order of `${SRCDIR}/{bin,libexec,lib,man}'.
#
# Globals:
#   SRCDIR
#   DESTDIR
#   bindir
#   libexecdir
#   libdir
#   mandir
# Arguments:
#   none
# Returns:
#   none
# Outputs:
#   STDOUT - list of paths
installed_files () {
  installed_files_bin
  installed_files_libexec
  installed_files_lib
  installed_files_man
}

# Fail and display details if the expected and actual value of the given
# variable in the launcher file do not equal. Details include the filename,
# variable name and the expected and actual values.
#
# Globals:
#   none
# Arguments:
#   $1 - launcher file
#   $2 - name of variable
#   $3 - expected value
# Returns:
#   0 - values equal
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_launcher_var () {
  local file="$1"
  local name="$2"
  local expected="$3"

  local actual="$(sed -r -e "/^export ${name}=/ !d" \
                         -e 's/^[^=]*=//' \
                         -e "s/('(.*)'|\"(.*)\")/\2\3/" \
                      "$file")"

  if [[ $actual != "$expected" ]]; then
    echo '-- Launcher variable differs --' >&2
    echo "file     : $file" >&2
    echo "name     : $name" >&2
    echo "actual   : $actual" >&2
    echo "expected : $expected" >&2
    echo '--' >&2
    return 1
  fi
}
