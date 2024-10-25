SHELL := bash
INSTALL ?= install

# Make sure we have git:
ifeq ($(shell which git),)
  $(error 'git' is not installed on this system)
endif

# Set variables:
NAME := git-subrepo
LIB  := lib/$(NAME)
DOC  := doc/$(NAME).swim
MAN1 := man/man1
EXT  := $(LIB).d
EXTS := $(shell find $(EXT) -type f) \
	$(shell find $(EXT) -type l)
SHARE = share

# Install variables:
PREFIX ?= /usr/local
INSTALL_BIN  ?= $(PREFIX)/bin
INSTALL_LIB  ?= $(PREFIX)/share/$(NAME)
INSTALL_EXT  ?= $(INSTALL_LIB)/$(NAME).d
INSTALL_MAN1 ?= $(PREFIX)/share/man/man1
LINK_REL_DIR := $(shell realpath --relative-to=$(INSTALL_BIN) $(INSTALL_LIB))

# Docker variables:
DOCKER_TAG ?= 0.0.6
DOCKER_IMAGE := ingy/bash-testing:$(DOCKER_TAG)
BASH_VERSIONS ?= 5.1 5.0 4.4 4.3 4.2 4.1 4.0
DOCKER_TESTS := $(BASH_VERSIONS:%=docker-test-%)
GIT_VERSIONS := 2.45 2.40 2.30 2.29 2.25 2.17 2.7

prove ?=
test ?= test/
bash ?= 5.1
git ?= 2.45

# Basic targets:
default: help

help:
	@echo 'Makefile rules:'
	@echo ''
	@echo 'test       Run all tests'
	@echo 'install    Install $(NAME)'
	@echo 'uninstall  Uninstall $(NAME)'
	@echo 'env        Show environment variables to set'

.PHONY: test
test:
	prove $(prove) $(test)

test-all: test docker-tests

docker-test:
	$(call docker-make-test,$(bash),$(git))

docker-tests: $(DOCKER_TESTS)

$(DOCKER_TESTS):
	$(call docker-make-test,$(@:docker-test-%=%),$(git))

# Install support:
install:
	$(INSTALL) -d -m 0755 $(DESTDIR)$(INSTALL_LIB)/
	$(INSTALL) -C -m 0755 $(LIB) $(DESTDIR)$(INSTALL_LIB)/
	sed -i 's!^SUBREPO_EXT_DIR=.*!SUBREPO_EXT_DIR=$(INSTALL_EXT)!' $(DESTDIR)$(INSTALL_LIB)/$(NAME)
	$(INSTALL) -d -m 0755 $(DESTDIR)$(INSTALL_BIN)
	ln -s $(LINK_REL_DIR)/$(NAME) $(DESTDIR)$(INSTALL_BIN)/$(NAME)
	$(INSTALL) -d -m 0755 $(DESTDIR)$(INSTALL_EXT)/
	$(INSTALL) -C -m 0644 $(EXTS) $(DESTDIR)$(INSTALL_EXT)/
	$(INSTALL) -d -m 0755 $(DESTDIR)$(INSTALL_MAN1)/
	$(INSTALL) -C -m 0644 $(MAN1)/$(NAME).1 $(DESTDIR)$(INSTALL_MAN1)/

# Uninstall support:
uninstall:
	rm -f $(DESTDIR)$(INSTALL_BIN)/$(NAME)
	rm -fr $(DESTDIR)$(INSTALL_EXT)
	rm -fr $(DESTDIR)$(INSTALL_LIB)
	rm -f $(DESTDIR)$(INSTALL_MAN1)/$(NAME).1

env:
	@echo "export PATH=\"$$PWD/lib:\$$PATH\""
	@echo "export MANPATH=\"$$PWD/man:\$$MANPATH\""

# Doc rules:
.PHONY: doc
update: doc compgen

force:

doc: ReadMe.pod Intro.pod $(MAN1)/$(NAME).1
	perl pkg/bin/generate-help-functions.pl $(DOC) > \
	    $(EXT)/help-functions.bash

ReadMe.pod: $(DOC) force
	swim --to=pod --wrap --complete $< > $@

Intro.pod: doc/intro-to-subrepo.swim force
	swim --to=pod --wrap --complete $< > $@

$(MAN1)/%.1: doc/%.swim Makefile force
	swim --to=man --wrap $< > $@

compgen: force
	perl pkg/bin/generate-completion.pl bash $(DOC) $(LIB) > \
	    $(SHARE)/completion.bash
	perl pkg/bin/generate-completion.pl zsh $(DOC) $(LIB) > \
	    $(SHARE)/zsh-completion/_git-subrepo

clean:
	rm -fr tmp test/tmp test/repo .gitconfig

define docker-make-test
	docker run --rm \
	    -v $(PWD):/git-subrepo \
	    -w /git-subrepo \
	    $(DOCKER_IMAGE) \
		/bin/bash -c ' \
		    set -x && \
		    [[ -d /bash-$(1) ]] && \
		    [[ -d /git-$(2) ]] && \
		    export PATH=/bash-$(1)/bin:/git-$(2)/bin:$$PATH && \
		    bash --version && \
		    git --version && \
		    make test prove=$(prove) test=$(test) \
		'
endef
