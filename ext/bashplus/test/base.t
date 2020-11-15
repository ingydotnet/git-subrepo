#!/usr/bin/env bash

source test/setup

source bash+ :std

ok $? "'source bash+' works"

is "$BASHPLUS_VERSION" '0.1.0' 'BASHPLUS_VERSION is 0.1.0'

done_testing 2
