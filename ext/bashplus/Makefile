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

DOCKER_IMAGE := ingy/bash-testing:0.0.1
DOCKER_TESTS := 5.1 5.0 4.4 4.3 4.2 4.1 4.0 3.2
DOCKER_TESTS := $(DOCKER_TESTS:%=docker-test-%)

default: help

help:
	@echo 'Rules: test, install, doc'

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

test-all: test docker-test

docker-test: $(DOCKER_TESTS)

$(DOCKER_TESTS):
	$(call docker-make-test,$(@:docker-test-%=%))

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

define docker-make-test
	docker run -i -t --rm \
	    -v $(PWD):/git-subrepo \
	    -w /git-subrepo \
	    $(DOCKER_IMAGE) \
		/bin/bash -c ' \
		    set -x && \
		    [[ -d /bash-$(1) ]] && \
		    export PATH=/bash-$(1)/bin:$$PATH && \
		    bash --version && \
		    make test \
		'
endef
