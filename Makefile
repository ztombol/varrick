# Project parameters.
export SRCDIR      ?= ./src
export DOCSDIR     ?= ./docs
export SCRIPTDIR   ?= ./script

# Installation parameters.
export prefix      ?= /usr/local
export exec_prefix ?= $(prefix)
export bindir      ?= $(exec_prefix)/bin
export libdir      ?= $(prefix)/lib
export datarootdir ?= $(prefix)/share
export mandir      ?= $(datarootdir)/man

.PHONY: build
build: man

# Generate ROFF format man pages from './$(SRCDIR)/man/*.ronn'.
.PHONY: man
man: $(patsubst %.ronn,%,$(wildcard $(SRCDIR)/man/*.ronn)) ;

$(SRCDIR)/man/%: $(SRCDIR)/man/%.ronn
	ronn --warnings --roff $<

.PHONY: docs
docs: docs-man docs-img

# Generate HTML format man pages from './$(SRCDIR)/man/*.ronn' in
# './$(DOCSDIR)/man'.
.PHONY: docs-man
docs-man: $(patsubst $(SRCDIR)/man/%.ronn,$(DOCSDIR)/man/%.html,\
	             $(wildcard $(SRCDIR)/man/*)) ;

$(DOCSDIR)/man/%.html: $(SRCDIR)/man/%.ronn
	ronn --warnings --html $<
	mv $(<:.ronn=.html) $(DOCSDIR)/man

# Rasterise './$(DOCSDIR)/src/*.html' and save in PNG format in
# './$(DOCSDIR)/img'
.PHONY: docs-img
docs-img: $(patsubst $(DOCSDIR)/src/%.html,$(DOCSDIR)/img/%.png,\
	             $(wildcard $(DOCSDIR)/src/*.html)) ;

$(DOCSDIR)/img/%.png: $(DOCSDIR)/src/%.html
	phantomjs "$(SCRIPTDIR)/capture.js" "$<" "$@"

.PHONY: install
install:
# Summary
	@echo '-> Parameters'; \
	vars=(SRCDIR DESTDIR prefix exec_prefix bindir libdir datarootdir \
	      mandir); \
	for var in "$${vars[@]}"; do \
	  printf '  %-11s = %s\n' $$var $${!var}; \
	done; \
	echo

	@echo '-> Installing files'
# Install executables, i.e. all files in './$(SRCDIR)/bin' recursively.
# All files are made executable.
# Does not guard against filenames with newlines.
	@srcdir="$(SRCDIR)/bin" ; \
	depth="$$(echo "$$srcdir/" | grep -o '/' | wc -l)"; \
	IFS=$$'\n'; for file in $$(find "$$srcdir" -type f); do \
	  file_dest="$$(echo "$$file" | sed -r 's:([^/]*/){'"$$depth"'}::')"; \
	  echo "$(bindir)/$${file_dest}"; \
	  install -Dm755 "$$file" "$(DESTDIR)$(bindir)/$${file_dest}"; \
	done
	
# Install libraries, i.e. all files in './$(SRCDIR)/lib' recursively.
# Does not guard against filenames with newlines.
	@srcdir="$(SRCDIR)/lib" ; \
	depth="$$(echo "$$srcdir/" | grep -o '/' | wc -l)"; \
	IFS=$$'\n'; for file in $$(find "$$srcdir" -type f); do \
	  file_dest="$$(echo "$$file" | sed -r 's:([^/]*/){'"$$depth"'}::')"; \
	  echo "$(libdir)/$${file_dest}"; \
	  install -Dm644 "$$file" "$(DESTDIR)$(libdir)/$${file_dest}"; \
	done
	
# Install man pages, i.e. all files in './$(SRCDIR)/man' without '.ronn'
# suffix.
	@srcdir="$(SRCDIR)/man" ; \
	for file in "$$(ls "$$srcdir" | grep -v '\.ronn$$')"; do \
	  file_dest="man$${file: -1}/$${file}"; \
	  echo "$(mandir)/$${file_dest}"; \
	  install -Dm644 "$${srcdir}/$${file}" \
	                 "$(DESTDIR)$(mandir)/$${file_dest}"; \
	done

.PHONY: check
check:
	bats $(SRCDIR)/test

.PHONY: clean
clean:
	# Delete generate ROFF format man pages.
	-rm $(patsubst %.ronn,%,$(wildcard $(SRCDIR)/man/*.ronn))

define HELP_TEXT
TARGETS:

  For packagers:
    build    build application
    install  install application
    check    run test suite
    clean    delete generated files
    help     display this help

  For developers:
    man      generate ROFF format man pages (build-time)
    docs     generate HTML format man pages and images (after editing man pages)


ENVIRONMENT:

  For packagers:
    The following variables customise installation. Their meaning is described
    in the GNU Make manual. [1] [2]

      DESTDIR     = /
      prefix      = /usr/local
      exec_prefix = $$(prefix)
      bindir      = $$(exec_prefix)/bin
      libdir      = $$(prefix)/lib
      datarootdir = $$(prefix)/share
      mandir      = $$(datarootdir)/man

  For developers:
    The following variables may only be interesting to developers.

      DOCSDIR = ./docs   directory containing documentation, e.g. HTML man pages
      SRCDIR  = ./src    path to directory containing the program source.


EXAMPLES:

  Build and then install execuatables in `/usr/bin', libraries in `/usr/lib' and
  man pages in `/usr/share/man'.

    $ make build
    $ make prefix='/usr' install


REFERENCES:

  [1]: http://www.gnu.org/software/make/manual/make.html#Directory-Variables
  [2]: http://www.gnu.org/software/make/manual/make.html#DESTDIR

endef
export HELP_TEXT
.PHONY: help
help:
	@echo "$${HELP_TEXT}"
