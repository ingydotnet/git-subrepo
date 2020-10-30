#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd "$OWNER/bar"
  add-new-files Bar2
  git tag -a CoolTag -m "Should stay in subrepo"
  git push
) &> /dev/null || die


# Fetch information
{
  is "$(
    cd "$OWNER/foo"
    git subrepo fetch bar
  )" \
    "Fetched 'bar' from '$UPSTREAM/bar' (master)." \
    'subrepo fetch command output is correct'
}

# Check that there is no tags fetched
{
  is "$(
    cd "$OWNER/foo"
    git tag -l 'CoolTag'
  )" \
    "" \
    'No tag is available'
}

done_testing

teardown
