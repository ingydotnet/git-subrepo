ifeq ($(MAKECMDGOALS),install)
  ifeq "$(shell bpan version 2>/dev/null)" ""
    $(error 'BPAN not installed. See http://bpan.org')
  endif
endif

NAME := test-tap
LIB  := lib/test/tap.bash
MAN3 := man/man3

INSTALL_LIB  ?= $(shell bpan env BPAN_LIB)
INSTALL_DIR  ?= test
INSTALL_MAN3 ?= $(shell bpan env BPAN_MAN3)

default: help

help:
	@echo 'Rules: test, install, doc'

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

install:
	install -C -d -m 0755 $(INSTALL_LIB)/$(INSTALL_DIR)/
	install -C -m 0755 $(LIB) $(INSTALL_LIB)/$(INSTALL_DIR)/
	install -C -d -m 0755 $(INSTALL_MAN3)/
	install -C -m 0644 $(MAN3)/$(NAME).3 $(INSTALL_MAN3)/

.PHONY: doc
doc: ReadMe.pod $(MAN3)/$(NAME).3

ReadMe.pod: doc/test-tap.swim
	swim --to=pod --complete --wrap $< > $@

man/man3/%.3: doc/%.swim
	swim --to=man $< > $@
