Bash+(1) - Modern Bash Programming
==================================

[![Build Status](https://travis-ci.org/ingydotnet/bashplus.png?branch=master)](https://travis-ci.org/ingydotnet/bashplus)

## Synopsis

    source bash+ :std :array

    use Foo::Bar this that

    Array.new args "$@"

    if args.empty?; then
        die "I need args!"
    fi

    Foo::Bar.new foo args

    this is awesome     # <= this is a real command! (You just imported it)

## Description

Bash+ is just Bash... *plus* some libraries that can make Bash programming a
lot nicer.

## Installation

Get the source code from GitHub:

    git clone git@github.com:bpan-org/bashplus

Then run:

    make test
    make install        # Possibly with 'sudo'

## Usage

For now look at some libraries the use Bash+:

* https://github.com/bpan-org/git-hub
* https://github.com/bpan-org/json-bash
* https://github.com/bpan-org/test-more-bash

## Status

This stuff is really new. Watch the https://github.com/bpan-org/ for
developments.

If you are interested in chatting about this, `/join #bpan` on
irc.freenode.net.

## Author

Written by Ingy döt Net <ingy@bpan.org>

## Copyright

Copyright 2013 Ingy döt Net
