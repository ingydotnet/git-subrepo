#!/usr/bin/env bash

source test/helper.bash
source lib/test/tap.bash

Test::Tap:init tests 4

for s in plan init; do
  output=$(prove test/test/skip-all-$s.t)

  test-helper:like \
    "$output" \
    "skipped: Test for skip_all from $s" \
    "skip_all from $s: it works"

  test-helper:like \
    "$output" \
    'Result: NOTESTS' \
    "skip_all from $s: No tests run"
done
