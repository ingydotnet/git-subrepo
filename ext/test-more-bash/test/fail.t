#!/usr/bin/env bash

source test/setup

use Test::More

output=$(prove -v test/test/fail1.t 2>&1) || true

like "$output" 'not ok 1 - fail with label' \
  'fail with label'
like "$output" 'not ok 2' \
  'fail with no label'
like "$output" 'not ok 3 - is foo bar' \
  'fail output is correct'
like "$output" "#     got: 'foo'" \
  'difference reporting - got'
like "$output" "#   expected: 'bar'" \
  'difference reporting - want'

done_testing 5
