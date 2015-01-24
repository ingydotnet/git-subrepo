.PHONY: test doc

ifeq ($(MAKECMDGOALS),install)
    ifeq "$(shell bpan version 2>/dev/null)" ""
	$(error 'BPAN not installed. See http://bpan.org')
    endif
endif

LOCAL_LIB = lib/bash+.bash
LOCAL_MAN1 = man/man1/bash+.1
LOCAL_MAN3 = man/man3/bash+.3

INSTALL_LIB = $(shell bpan env BPAN_LIB)
INSTALL_DIR = test
INSTALL_MAN1 = $(shell bpan env BPAN_MAN1)
INSTALL_MAN3 = $(shell bpan env BPAN_MAN3)

default: help

help:
	@echo 'Rules: test, install, doc'

test:
	prove $(PROVEOPT:%=% )test/

install:
	install -C -d -m 0755 $(INSTALL_LIB)/$(INSTALL_DIR)/
	install -C -m 0755 $(LOCAL_LIB) $(INSTALL_LIB)/$(INSTALL_DIR)/
	install -C -d -m 0755 $(INSTALL_MAN1)/
	install -C -d -m 0755 $(INSTALL_MAN3)/
	install -C -m 0644 $(LOCAL_MAN1) $(INSTALL_MAN1)/
	install -C -m 0644 $(LOCAL_MAN3) $(INSTALL_MAN3)/

doc: ReadMe.pod $(LOCAL_MAN1) $(LOCAL_MAN3)

ReadMe.pod: doc/bash+.swim
	swim --to=pod --wrap --complete $< > $@

man/man1/%.1 man/man3/%.3: doc/%.swim
	swim --to=man $< > $@
