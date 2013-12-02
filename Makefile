.PHONY: default help test

default: help

help:
	@echo 'Makefile targets:'
	@echo ''
	@echo '    test          - Run test suite'
	@echo ''

test:
	prove $(PROVEOPT:%=% )test/

install:
	@echo 'install not implemented yet'
