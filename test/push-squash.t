#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Make various changes to the repos for testing subrepo push:
(
  # In the main repo:
  cd "$OWNER/foo"

  # Clone the subrepo into a subdir
  git subrepo clone "$UPSTREAM/bar"

  # Make a series of commits:
  add-new-files bar/FooBar1
  add-new-files bar/FooBar2
  modify-files bar/FooBar1
  add-new-files ./FooBar
  modify-files ./FooBar bar/FooBar2
) &> /dev/null || die

# Do the subrepo push and test the output:
{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar --squash
  )

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '$UPSTREAM/bar' (master)." \
    'push message is correct'
}

(
  cd "$OWNER/bar"
  git pull
) &> /dev/null || die

# Check that all commits arrived in subrepo
test-commit-count "$OWNER/bar" HEAD 3

test-exists \
  "$OWNER/bar/Bar" \
  "$OWNER/bar/FooBar1" \
  "$OWNER/bar/FooBar2" \
  "!$OWNER/bar/.gitrepo" \

done_testing

teardown
