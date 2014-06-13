# Make sure we have 'git' and it works OK:
ifeq ($(shell which git),)
    $(error 'git' is not installed on this system)
endif


# Set variables:
CMD := git-subrepo

LOCAL_LIB := $(shell pwd)/lib/$(CMD)
LOCAL_MAN := $(shell pwd)/man
LOCAL_MAN1 := $(LOCAL_MAN)/man1
LOCAL_EXT = $(LOCAL_LIB).d
LOCAL_EXTS = $(shell find $(LOCAL_EXT) -type f) \
	    $(shell find $(LOCAL_EXT) -type l)

PREFIX ?= /usr/local
INSTALL_LIB ?= $(shell git --exec-path)
INSTALL_CMD ?= $(INSTALL_LIB)/$(CMD)
INSTALL_EXT ?= $(INSTALL_LIB)/$(CMD).d
INSTALL_MAN ?= $(PREFIX)/share/man/man1



# Basic targets:
.PHONY: default help test
default: help

help:
	@echo 'Makefile rules:'
	@echo ''
	@echo 'test       Run all tests'
	@echo 'install    Install $(CMD)'
	@echo 'uninstall  Uninstall $(CMD)'

test:
ifeq ($(shell which prove),)
	@echo '`make test` requires the `prove` utility'
	@exit 1
endif
	prove $(PROVEOPT:%=% )test/



# Install support:
.PHONY: install install-lib install-doc
install: install-lib install-doc

install-lib:
	install -C -m 0755 $(LOCAL_LIB) $(INSTALL_LIB)/
	install -C -d -m 0755 $(INSTALL_EXT)/
	install -C -m 0755 $(LOCAL_EXTS) $(INSTALL_EXT)/

install-doc:
	install -C -d -m 0755 $(INSTALL_MAN)
	install -C -m 0644 doc/$(CMD).1 $(INSTALL_MAN)



# Uninstall support:
.PHONY: uninstall uninstall-lib uninstall-doc
uninstall: uninstall-lib uninstall-doc

uninstall-lib:
	rm -f $(INSTALL_CMD)
	rm -fr $(INSTALL_EXT)

uninstall-doc:
	rm -f $(INSTALL_MAN)/$(CMD).1


##
# Build rules:
.PHONY: doc
doc: $(LOCAL_MAN1)/$(CMD).1

$(LOCAL_MAN1)/$(CMD).1: $(CMD).1
	mv $< $@

%.1: ReadMe.pod
	pod2man --utf8 $< > $@

ReadMe.pod: doc/$(CMD).kwim
	kwim --to=pod --wrap=1 --complete=1 $< > $@


# Development installation:
.PHONY: dev-install
dev-install:
	ln -fs $(LOCAL_LIB) $(INSTALL_CMD)
	ln -fs $(LOCAL_EXTS) $(INSTALL_EXT)

clean purge:
	rm -fr tmp
