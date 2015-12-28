#!/usr/bin/env bash

set -e

source test/setup

use Test::More

count=$(
  git subrepo merge-base HEAD HEAD 2>/dev/null | wc -l
)
is $count 3 "merge-base (without --all) produces 3 lines"

count=$(
  git subrepo merge-base --all HEAD HEAD 2>/dev/null | head -n5 | wc -l
)
is $count 5 "merge-base --all produces more lines"

done_testing

teardown
