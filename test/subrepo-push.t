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

  # First add a file to the sub repo
  touch bar/FooBar
  git add bar/FooBar
  git commit -m 'added bar/FooBar'

  # Next add a file to the main repo
  touch ./FooBar
  git add ./FooBar
  git commit -m 'added ./FooBar'

  # Now change the subrepo file
  echo 'change 1' >> bar/FooBar
  git add bar/FooBar
  git commit -m 'change 1'

  # Then change the main repo file
  echo 'change 2' >> ./FooBar
  git add ./FooBar
  git commit -m 'change 2'

  # Then change both files in one commit
  echo 'change 3' >> ./FooBar
  echo 'change 3' >> bar/FooBar
  git add ./FooBar bar/FooBar
  git commit -m 'change 3'

  cd -
  cd $OWNER/bar
  touch bargy
  git add bargy
  git commit -m 'bargy'
  git push
) &> /dev/null || die

save-original-state "$OWNER/foo" "bar"

# Do the subrepo push and test the output:
{
  message="$(
    cd $OWNER/foo

    # This command should tease out the commits made to bar, and push them
    # back to UPSTREAM/bar
    git subrepo push bar || true
  )"

  # Test the output:
  is "$message" \
    "git subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)" \
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

assert-original-state "$OWNER/foo" "bar"

done_testing 10

source test/teardown
