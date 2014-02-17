#!/usr/bin/env bash

source test/helper.bash
source lib/test/tap.bash

Test::Tap:init tests 1

output=$(prove -v test/test/{b,f}ail.t 2>&1)

test-helper:like \
  "$output" \
  'Bailout called.  Further testing stopped:  Get me outta here' \
  'Test::Tap:BAIL_OUT works'
