# Make sure we have 'git' and it works OK:
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
INSTALL_LIB  ?= $(DESTDIR)$(shell git --exec-path)
INSTALL_EXT  ?= $(INSTALL_LIB)/$(NAME).d
INSTALL_MAN1 ?= $(DESTDIR)$(PREFIX)/share/man/man1

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
	prove $(PROVEOPT:%=% )test/

# Install support:
install:
	install -C -d -m 0755 $(INSTALL_LIB)/
	install -C -m 0755 $(LIB) $(INSTALL_LIB)/
	install -C -d -m 0755 $(INSTALL_EXT)/
	install -C -m 0755 $(EXTS) $(INSTALL_EXT)/
	install -C -d -m 0755 $(INSTALL_MAN1)/
	install -C -m 0644 $(MAN1)/$(NAME).1 $(INSTALL_MAN1)/

# Uninstall support:
uninstall:
	rm -f $(INSTALL_LIB)/$(NAME)
	rm -fr $(INSTALL_EXT)
	rm -f $(INSTALL_MAN1)/$(NAME).1

env:
	@echo "export PATH=\"$$PWD/lib:\$$PATH\""
	@echo "export MANPATH=\"$$PWD/man:\$$MANPATH\""

# Doc rules:
.PHONY: doc
update: doc compgen

doc: ReadMe.pod Intro.pod $(MAN1)/$(NAME).1
	perl pkg/bin/generate-help-functions.pl $(DOC) > \
	    $(EXT)/help-functions.bash

ReadMe.pod: $(DOC)
	swim --to=pod --wrap --complete $< > $@

Intro.pod: doc/intro-to-subrepo.swim
	swim --to=pod --wrap --complete $< > $@

$(MAN1)/%.1: doc/%.swim Makefile
	swim --to=man --wrap $< > $@

compgen:
	perl pkg/bin/generate-completion.pl bash $(DOC) $(LIB) > \
	    $(SHARE)/completion.bash
	perl pkg/bin/generate-completion.pl zsh $(DOC) $(LIB) > \
	    $(SHARE)/zsh-completion/_git-subrepo

clean purge:
	rm -fr tmp
