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

  # Make a commit:
  add-new-files bar/FooBar
) &> /dev/null || die

# Do the subrepo push to another branch:
{
  message="$(
    cd $OWNER/foo
    git subrepo push bar --branch newbar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (newbar)." \
    'First push message is correct '
}

# Do the subrepo push to another branch again, this time it should complain
# that we need to pull first
{
  message="$(
    cd $OWNER/foo
    git subrepo push bar --branch newbar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' has no new commits to push." \
    'Second push message is correct'
}

# Pull the changes from UPSTREAM/bar in OWNER/bar
(
  cd $OWNER/bar
  git fetch
  git checkout newbar
) &> /dev/null || die

test-exists \
  "$OWNER/bar/FooBar" \

done_testing

teardown
