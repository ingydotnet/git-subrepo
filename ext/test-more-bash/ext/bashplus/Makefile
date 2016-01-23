ifeq ($(MAKECMDGOALS),install)
  ifeq "$(shell bpan version 2>/dev/null)" ""
    $(error 'BPAN not installed. See http://bpan.org')
  endif
endif

NAME := bash+
LIB  := lib/$(NAME).bash
DOC  := doc/$(NAME).swim
MAN1 := man/man1
MAN3 := man/man3

INSTALL_LIB  ?= $(shell bpan env BPAN_LIB)
INSTALL_DIR  ?= test
INSTALL_MAN1 ?= $(shell bpan env BPAN_MAN1)
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
	install -C -d -m 0755 $(INSTALL_MAN1)/
	install -C -d -m 0755 $(INSTALL_MAN3)/
	install -C -m 0644 $(MAN1)/$(NAME).1 $(INSTALL_MAN1)/
	install -C -m 0644 $(MAN3)/$(NAME).3 $(INSTALL_MAN3)/

.PHONY: doc
doc: ReadMe.pod $(MAN1)/$(NAME).1 $(MAN3)/$(NAME).3

ReadMe.pod: $(DOC)
	swim --to=pod --complete --wrap $< > $@

$(MAN1)/%.1: doc/%.swim
	swim --to=man $< > $@

$(MAN3)/%.3: doc/%.swim
	swim --to=man $< > $@
