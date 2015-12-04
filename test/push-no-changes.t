#!/usr/bin/env bash

set -e

source test/setup

use Test::More

note "Test output from successful git-subrepo commands"

clone-foo-and-bar

{
  is "$(
    cd $OWNER/bar
    git subrepo --quiet clone ../../../$UPSTREAM/foo
    catch git subrepo push foo
  )" \
    "Subrepo 'foo' has no new commits to push." \
    "Output OK: Check that 'push' requires changes to push"
  (
    cd $OWNER/bar
    git subrepo --quiet clean foo
  )
}

done_testing 1

teardown
