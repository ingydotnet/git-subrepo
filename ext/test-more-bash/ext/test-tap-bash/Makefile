SHELL := bash

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

DOCKER_IMAGE := ingy/bash-testing:0.0.1

default: help

help:
	@echo 'Rules: test, install, doc'

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

test-all: test docker-test

docker-test:
	-$(call docker-make-test,3.2)
	-$(call docker-make-test,4.0)
	-$(call docker-make-test,4.1)
	-$(call docker-make-test,4.2)
	-$(call docker-make-test,4.3)
	-$(call docker-make-test,4.4)
	-$(call docker-make-test,5.0)
	-$(call docker-make-test,5.1)

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
