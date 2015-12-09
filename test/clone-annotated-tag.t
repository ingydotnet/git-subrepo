#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd $OWNER/bar
  git tag -a annotated_tag -m "My annotated tag"
  git tag lightweight_tag
) # >& /dev/null || die

# Do the subrepo clone with tag and test the output:
{
  clone_output="$(
    cd $OWNER/foo
    git subrepo clone ../bar/.git -b lightweight_tag light
  )"

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '../bar/.git' (lightweight_tag) cloned into 'light'." \
    'subrepo clone lightweight tag command output is correct'
}

# Do the subrepo clone with tag and test the output:
{
  clone_output="$(
    cd $OWNER/foo
    git subrepo clone ../bar/.git -b annotated_tag ann 2>&1 || true
  )"

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '../bar/.git' (annotated_tag) cloned into 'ann'." \
    'subrepo clone annotated command output is correct'
}

done_testing

teardown
