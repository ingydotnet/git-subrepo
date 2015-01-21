#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
  output="$(git subrepo status)"

  like "$output" "2 subrepos:" \
    "Status intro ok"

  like "$output" "Git subrepo 'ext/bashplus':" \
    "bashplus is in status"

  like "$output" "Git subrepo 'ext/test-more-bash':" \
    "test-more-bash is in status"
}

done_testing 3

teardown
