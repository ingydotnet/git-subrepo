#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init
Test::Tap:plan tests 3

for n in 1 2 3; do
  Test::Tap:pass "Test #$n"
done
