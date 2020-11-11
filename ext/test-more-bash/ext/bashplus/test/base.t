#!/usr/bin/env bash

source test/setup

PATH=$PWD/bin:$PATH
source bash+ :std

ok $? "'source bash+' works"

is "$BASHPLUS_VERSION" '0.0.9' 'BASHPLUS_VERSION is 0.0.9'

done_testing 2
