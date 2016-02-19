#!/usr/bin/env bats

load make-test-helper

targets_man () {
  while local target; IFS=$'\n' read -r target; do
    target="${target%.ronn}"
    echo "$target"
  done < <(find "${SRCDIR}/man" -path '*.ronn')
}

@test 'make man: generate ROFF format man pages' {
  run env -i bash -c "cd '$MAIN_DIR'
                      make clean man"
  assert_success
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_man)
}

@test 'make build: build the application' {
  run env -i bash -c "cd '$MAIN_DIR'
                      make clean build"
  assert_success
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_man)
}

@test 'make clean: delete build files' {
  run env -i bash -c "cd '$MAIN_DIR'
                      make build clean"
  assert_success
  while local target; IFS=$'\n' read -r target; do
    assert_file_not_exist "$target"
  done < <(targets_man)
}
