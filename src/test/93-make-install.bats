#!/usr/bin/env bats

load make-test-helper

installed_files_bin () {
  local src src_file
  for src in "${SRCDIR}/bin"/*; do
    src_file="$(basename "$src")"
    echo "${DESTDIR}${bindir}/${src_file}"
  done
}

installed_files_lib () {
  local src_base="${SRCDIR}/lib"
  local IFS=$'\n'
  local src
  for src in $(find "$src_base" -type f); do
    echo "${DESTDIR}${libdir}${src#${src_base}}"
  done
}

installed_files_man () {
  local src src_file
  for src in "${SRCDIR}/man"/*.[0-9]; do
    src_file="$(basename "$src")"
    echo "${DESTDIR}${mandir}/man${src_file: -1}/${src_file}"
  done
}

installed_files () {
  installed_files_bin
  installed_files_lib
  installed_files_man
}

@test "make install: install to \`/usr/local' by default" {
  # Paths.
  local DESTDIR='install'

  # Run command.
  run env -i bash -c "cd '$MAIN_DIR'; \
                      make build &>/dev/null; \
                      make DESTDIR='$DESTDIR' install \
                        | sed '/^-> Parameters$/,$ !d; /make\[[0-9]\+\]:/ d'"
  [ "$status" -eq 0 ]

  # Paths.
  local prefix='/usr/local'
  local exec_prefix="${prefix}"
  local bindir="${exec_prefix}/bin"
  local libdir="${prefix}/lib"
  local datarootdir="${prefix}/share"
  local mandir="${datarootdir}/man"

  # Parameters.
  [ "${lines[0]}" == '-> Parameters' ]
  [ "${lines[1]}" == "$(printf '  %-11s = %s\n' 'SRCDIR' './src')" ]
  local -r vars=(DESTDIR prefix exec_prefix bindir libdir datarootdir
                 mandir)
  local -i i=2
  local var
  for var in "${vars[@]}"; do \
    [ "${lines[$i]}" == "$(printf '  %-11s = %s\n' "$var" "${!var}")" ]
    (( ++i ))
  done

  # Files.
  [ "${lines[9]}" == '-> Installing files' ]
  i=10
  while local file; IFS=$'\n' read -r file; do
    assert_file_exist "${MAIN_DIR}/${file}"
    [ "${lines[$i]}" == "  $file" ]
    ((++i))
  done < <(installed_files)
}

@test "make <path...> install: install to custom location" {
  # Paths.
  local DESTDIR='install'
  local prefix='/prefix'
  local exec_prefix="/exec_prefix"
  local bindir="${exec_prefix}/bindir"
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
                           libdir='$libdir' \
                           datarootdir='$datarootdir' \
                           mandir='$mandir' \
                           install \
                        | sed '/^-> Parameters$/,$ !d; /make\[[0-9]\+\]:/ d'"
  [ "$status" -eq 0 ]

  # Parameters.
  [ "${lines[0]}" == '-> Parameters' ]
  [ "${lines[1]}" == "$(printf '  %-11s = %s\n' 'SRCDIR' './src')" ]
  local -r vars=(DESTDIR prefix exec_prefix bindir libdir datarootdir
                 mandir)
  local -i i=2
  local var
  for var in "${vars[@]}"; do \
    [ "${lines[$i]}" == "$(printf '  %-11s = %s\n' "$var" "${!var}")" ]
    (( ++i ))
  done

  # Files.
  [ "${lines[9]}" == '-> Installing files' ]
  i=10
  while local file; IFS=$'\n' read -r file; do
    assert_file_exist "${MAIN_DIR}/${file}"
    [ "${lines[$i]}" == "  $file" ]
    ((++i))
  done < <(installed_files)
}
