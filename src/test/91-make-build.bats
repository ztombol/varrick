#!/usr/bin/env bats

load make-test-helper

targets_man () {
  while local target; IFS=$'\n' read -r target; do
    target="${target%.ronn}"
    echo "$target"
  done < <(find "${SRCDIR}/man" -path '*.ronn')
}

@test 'make man: generate ROFF format man pages' {
  run env -i bash -c "cd '$MAIN_DIR'; make clean; make man"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_man)
}

@test 'make build: build the application' {
  run env -i bash -c "cd '$MAIN_DIR'; make clean; make build"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_man)
}

@test 'make clean: delete build files' {
  run env -i bash -c "cd '$MAIN_DIR'; make build; make clean"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_not_exist "$target"
  done < <(targets_man)
}
