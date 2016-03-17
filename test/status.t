#!/usr/bin/env bash

set -e

source test/setup

use Test::More

{
  is "$(
    git subrepo status
  )" \
    "See also: git subrepo show ..." \
    'subrepo status command output is correct'
}

done_testing

teardown
