Test::Tap(1) - TAP Test Base for Bash
=====================================

[![Build Status](https://travis-ci.org/ingydotnet/test-tap-bash.png?branch=master)](https://travis-ci.org/ingydotnet/test-tap-bash)

## Synopsis

    source test/tap.bash

    Test::Tap:plan tests 1

    pass 'Everything is OK!'

## Description

This is a TAP testing base class for Bash. It has all the basic TAP functions, and works properly from a TAP harness, like the `prove` utility.

test-tap-bash is used as the base for test-more-bash, which is what you want
if you are writing tests in bash.

See: https://github.com/ingydotnet/test-more-bash/

## Functions

`Test::Tap:init`::
    Must be called first for every test file/process.

`Test::Tap::plan`::
    Used to set the plan.

    TODO - finish this doc.

## Author

Written by Ingy döt Net <ingy@bpan.org>

## Copyright

Copyright 2013 Ingy döt Net
