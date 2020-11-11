NAME := test-more
DOC  := doc/$(NAME).swim
MAN3 := man/man3

DOCKER_IMAGE := ingy/bash-testing:0.0.1
DOCKER_TESTS := 5.1 5.0 4.4 4.3 4.2 4.1 4.0 3.2
DOCKER_TESTS := $(DOCKER_TESTS:%=docker-test-%)

default: help

help:
	@echo 'Rules: test, doc'

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

test-all: test docker-test

docker-test: $(DOCKER_TESTS)

$(DOCKER_TESTS):
	$(call docker-make-test,$(@:docker-test-%=%))

doc: ReadMe.pod $(MAN3)/$(NAME).3

ReadMe.pod: $(DOC)
	swim --to=pod --complete --wrap $< > $@

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
