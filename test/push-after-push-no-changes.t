#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar
subrepo-clone-bar-into-foo

{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar > /dev/null
    add-new-files bar/Bar1
    catch git subrepo push bar
  )

  is "$message" \
    "Subrepo 'bar' pushed to '$UPSTREAM/bar' (master)." \
    "Output OK: Check that 'push' after an empty push works."
}

done_testing 1

teardown
