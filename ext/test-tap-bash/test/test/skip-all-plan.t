#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init
Test::Tap:plan skip_all 'Test for skip_all from plan'

Test::Tap:diag "This code should not be run"
Test::Tap:fail
