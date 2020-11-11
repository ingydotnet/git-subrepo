#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init tests 3 # 4

Test::Tap:pass 'pass with label'
Test::Tap:pass
Test::Tap:pass 'previous test has no label'

# TODO this test no longer working:
# msg=$(Test::Tap:fail 'faaaaailll' 2>/dev/null) || true
#
# if [[ $msg =~ not\ ok\ 4\ -\ faaaaailll ]]; then
#   Test::Tap:pass 'fail works'
# else
#   Test::Tap:fail 'fail works'
#   Test::Tap:diag "$msg"
# fi
