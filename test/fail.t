#!/usr/bin/env bash

source test/helper.bash
source lib/test/tap.bash

Test::Tap:init tests 2

output="$(prove -v test/test/fail.t 2>&1)"

# echo "# >>>${output//$'\n'/$'\n'# }<<<" >&2

test-helper:like \
  "$output" \
  'not ok 1 - I am a failure' \
  'Test::Tap:fail works'

test-helper:like \
  "$output" \
  'Failed 1/1 subtests' \
  'Proper summary'
