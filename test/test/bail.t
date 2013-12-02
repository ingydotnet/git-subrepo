#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init tests 5

Test::Tap:pass 'test #1'
Test::Tap:pass 'test #2'
Test::Tap:pass 'test #3'

Test::Tap:BAIL_OUT 'Get me outta here'

Test::Tap:pass 'test #4'
Test::Tap:fail 'test #5'
