#!/usr/bin/env bats

load make-test-helper

targets_docs_man () {
  while local target; IFS=$'\n' read -r target; do
    target="${target/%ronn/html}"
    target="${target/#${SRCDIR}/${DOCSDIR}}"
    echo "$target"
  done < <(find "${SRCDIR}/man" -path '*.ronn')
}

targets_docs_img () {
  while local target; IFS=$'\n' read -r target; do
    target="${target/%html/png}"
    # Leaving slashes in the last parameter of the expansion unescaped
    # makes the expression compatible with Travis CI's version of bash
    # (4.2.25).
    target="${target/#${DOCSDIR}\/src/${DOCSDIR}/img}"
    echo "$target"
  done < <(find "${DOCSDIR}/src" -path '*.html')
}

@test 'make docs-man: generate HTML format man pages' {
  run env -i bash -c "cd '$MAIN_DIR'; make docs-clean; make docs-man"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_docs_man)
}

@test 'make docs-img: rasterise HTML pages and save them as PNG' {
  run env -i bash -c "cd '$MAIN_DIR'; make docs-clean; make docs-img"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_docs_img)
}

@test 'make docs: generate documentation' {
  run env -i bash -c "cd '$MAIN_DIR'; make docs-clean; make docs"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_exist "$target"
  done < <(targets_docs_man; targets_docs_img)
}

@test 'make docs-clean: delete generated documentation' {
  run env -i bash -c "cd '$MAIN_DIR'; make docs; make docs-clean"
  [ "$status" -eq 0 ]
  while local target; IFS=$'\n' read -r target; do
    assert_file_not_exist "$target"
  done < <(targets_docs_man; targets_docs_img)
}
