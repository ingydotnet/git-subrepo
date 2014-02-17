#!/usr/bin/env bash

source test/setup
use Test::More

fail 'fail with label'

fail

is foo bar 'is foo bar'

done_testing 3
