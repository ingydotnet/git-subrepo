# Make sure we have 'git' and it works OK:
ifeq ($(shell which git),)
    $(error 'git' is not installed on this system)
endif


# Set variables:
NAME := git-subrepo
LIB := $(shell pwd)/lib/$(NAME)
DOC = doc/$(NAME).swim
MAN := $(shell pwd)/man
MAN1 := $(MAN)/man1
EXT = $(LIB).d
EXTS = $(shell find $(EXT) -type f) \
	    $(shell find $(EXT) -type l)
SHARE = share

PREFIX ?= /usr/local
INSTALL_LIB ?= $(shell git --exec-path)
INSTALL_CMD ?= $(INSTALL_LIB)/$(NAME)
INSTALL_EXT ?= $(INSTALL_LIB)/$(NAME).d
INSTALL_MAN ?= $(PREFIX)/share/man/man1


# Basic targets:
.PHONY: default help test
default: help

help:
	@echo 'Makefile rules:'
	@echo ''
	@echo 'test       Run all tests'
	@echo 'install    Install $(NAME)'
	@echo 'uninstall  Uninstall $(NAME)'
	@echo 'env        Show environment variables to set'

test:
ifeq ($(shell which prove),)
	@echo '`make test` requires the `prove` utility'
	@exit 1
endif
	prove $(PROVEOPT:%=% )test/



# Install support:
env:
	@echo "export PATH=\"$$PWD/lib:\$$PATH\""
	@echo "export MANPATH=\"$$PWD/man:\$$MANPATH\""

.PHONY: install install-lib install-doc
install: install-lib install-doc

install-lib:
	install -C -m 0755 $(LIB) $(INSTALL_LIB)/
	install -C -d -m 0755 $(INSTALL_EXT)/
	install -C -m 0755 $(EXTS) $(INSTALL_EXT)/

install-doc:
	install -C -d -m 0755 $(INSTALL_MAN)
	install -C -m 0644 doc/$(NAME).1 $(INSTALL_MAN)



# Uninstall support:
.PHONY: uninstall uninstall-lib uninstall-doc
uninstall: uninstall-lib uninstall-doc

uninstall-lib:
	rm -f $(INSTALL_CMD)
	rm -fr $(INSTALL_EXT)

uninstall-doc:
	rm -f $(INSTALL_MAN)/$(NAME).1


##
# Doc rules:
.PHONY: doc
update: doc compgen

doc: $(MAN1)/$(NAME).1 Intro.pod

compgen:
	perl pkg/bin/generate-completion.pl $(DOC) > \
	    $(SHARE)/completion.bash

$(MAN1)/$(NAME).1: $(NAME).1
	mv $< $@

%.1: ReadMe.pod
	pod2man --utf8 $< > $@

ReadMe.pod: $(DOC)
	swim --to=pod --wrap --complete $< > $@

Intro.pod: doc/intro-to-subrepo.swim
	swim --to=pod --wrap --complete $< > $@

clean purge:
	rm -fr tmp
