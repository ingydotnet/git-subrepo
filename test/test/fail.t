#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init tests 1

Test::Tap:fail 'I am a failure'
