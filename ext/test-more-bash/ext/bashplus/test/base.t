#!/bin/bash -e

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+ :std

ok $? '`source bash+` works'

is "$BASHPLUS_VERSION" '0.0.6' 'BASHPLUS_VERSION is 0.0.6'

done_testing 2
