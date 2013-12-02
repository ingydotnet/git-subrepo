#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init skip_all 'Test for skip_all from init'

Test::Tap:diag "This code should not be run"
Test::Tap:fail
