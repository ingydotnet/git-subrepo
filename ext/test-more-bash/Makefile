NAME := test-more
DOC  := doc/$(NAME).swim
MAN3 := man/man3

default: help

help:
	@echo 'Rules: test, doc'

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

doc: ReadMe.pod $(MAN3)/$(NAME).3

ReadMe.pod: $(DOC)
	swim --to=pod --complete --wrap $< > $@

$(MAN3)/%.3: doc/%.swim
	swim --to=man $< > $@
