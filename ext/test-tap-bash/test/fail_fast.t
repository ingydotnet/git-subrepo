#!/usr/bin/env bash

source test/helper.bash
source lib/test/tap.bash

Test::Tap:init tests 1

output="$(prove -v test/test/fail_fast.t 2>&1)"

# echo ">>>$output<<<" >&2

test-helper:like \
  "$output" \
  'Further testing stopped:  Bailing out on status=1' \
  'Test::Tap:BAIL_OUT works'
