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
like "$output" 'not ok 4 - command output more' \
  'fail output is correct'
like "$output" 'not ok 5 - command output less' \
  'fail output is correct'
like "$output" 'not ok 6 - command output diff' \
  'fail output is correct'
like "$output" "#     got: 'foo'" \
  'difference reporting - got'
like "$output" "#   expected: 'bar'" \
  'difference reporting - want'

like "$output" "line2. *\+line3." \
  'array comparison (more)'
like "$output" "line1. *-line2." \
  'array comparison (less)'
like "$output" "-line2.*\+foo" \
  'array comparison (diff)'


done_testing 11
