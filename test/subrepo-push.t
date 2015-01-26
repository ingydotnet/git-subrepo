#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Make various changes to the repos for testing subrepo push:
(
  # In the main repo:
  cd $OWNER/foo

  # Clone the subrepo into a subdir
  git subrepo clone ../../../$UPSTREAM/bar

  # Make a series of commits:
  add-new-files bar/FooBar
  add-new-files ./FooBar
  modify-files bar/FooBar
  modify-files ./FooBar
  modify-files ./FooBar bar/FooBar
) &> /dev/null || die

(
  cd $OWNER/bar
  add-new-files bargy
  git push
) &> /dev/null || die

save-original-state "$OWNER/foo" "bar"

echo;echo;echo
# Do the subrepo push and test the output:
{
  message="$(
    cd $OWNER/foo
    git subrepo pull --quiet bar
    git subrepo push bar subrepo/bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)." \
    'push message is correct'
}

# Pull the changes from UPSTREAM/bar in OWNER/bar
(
  cd $OWNER/bar
  git fetch
  git rebase -p
) &> /dev/null || die

test-exists \
  "$OWNER/bar/Bar" \
  "$OWNER/bar/FooBar" \
  "$OWNER/bar/bard/" \
  "$OWNER/bar/bargy" \
  "!$OWNER/bar/.gitrepo" \

# assert-original-state "$OWNER/foo" "bar"

done_testing

teardown
