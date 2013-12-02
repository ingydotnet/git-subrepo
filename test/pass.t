#!/usr/bin/env bash

source lib/test/tap.bash

Test::Tap:init tests 3

Test::Tap:pass 'pass 1 - with label'
Test::Tap:pass
Test::Tap:pass 'pass 3 - 2 has no label'
