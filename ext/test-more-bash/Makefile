NAME = test-more
DOC = doc/$(NAME).swim
MAN = $(MAN3)/$(NAME).3
MAN3 = man/man3

.PHONY: test
test:
	prove $(PROVEOPT:%=% )test/

doc: $(MAN) ReadMe.pod

$(MAN3)/%.3: doc/%.swim swim-check
	swim --to=man $< > $@

ReadMe.pod: $(DOC) swim-check
	swim --to=pod --complete --wrap $< > $@

swim-check:
	@# Need to assert Swim and Swim::Plugin::badge are installed
