#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init tests 4

Test::Tap:pass 'pass with label'
Test::Tap:pass
Test::Tap:pass 'previous test has no label'
msg="$(Test::Tap:fail 'faaaaailll' 2>/dev/null)"
if [[ "$msg" =~ not\ ok\ 4\ -\ faaaaailll ]]; then
  Test::Tap:pass 'fail works'
fi
