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

# Do the subrepo push and test the output:
{
  message="$(
    cd $OWNER/foo
    git subrepo pull --quiet bar
    git subrepo push bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)." \
    'push message is correct'
}

(
  # In the main repo:
  cd $OWNER/foo
  add-new-files bar/FooBar2
  modify-files bar/FooBar
) &> /dev/null || die

{
  message="$(
    cd $OWNER/foo
    git subrepo push bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)." \
    'push message is correct'
}

# Pull the changes from UPSTREAM/bar in OWNER/bar
(
  cd $OWNER/bar
  git pull
) &> /dev/null || die

test-exists \
  "$OWNER/bar/Bar" \
  "$OWNER/bar/FooBar" \
  "$OWNER/bar/bard/" \
  "$OWNER/bar/bargy" \
  "!$OWNER/bar/.gitrepo" \

# assert-original-state "$OWNER/foo" "bar"

(
  # In the main repo:
  cd $OWNER/foo
  add-new-files bar/FooBar3
  modify-files bar/FooBar
  git subrepo push bar
  add-new-files bar/FooBar4
  modify-files bar/FooBar3
) &> /dev/null || die

{
  message="$(
    cd $OWNER/foo
    git subrepo push bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)." \
    'Seqential pushes are correct'
}

(
  # In the subrepo
  cd $OWNER/bar
  git pull
  add-new-files barBar2
  git push
) &> /dev/null || die

(
  # In the main repo:
  cd $OWNER/foo
  add-new-files bar/FooBar5
  modify-files bar/FooBar3
) &> /dev/null || die

{
  message="$(
    cd $OWNER/foo
    git subrepo push bar 2>&1 || true
  )"

  # Test the output:
  is "$message" \
    "git-subrepo: Local branch is not updated, perform pull or use '--force' to always trust local branch in conflicts" \
    'Stopped by other push'
}

done_testing

teardown
