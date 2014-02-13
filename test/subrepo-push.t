#!/bin/bash

source test/setup

use Test::More

# TODO:
# * Make each commit be from a certain datetime to easily # see/test it.

(
  # foo will act as the main repo
  git clone $UPSTREAM/foo $OWNER/foo

  # bar will act as the subrepo
  git clone $UPSTREAM/bar $OWNER/bar

) &> /dev/null || die

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

) &> /dev/null || die

(
  cd $OWNER/bar
  touch bargy
  git add bargy
  git commit -m 'bargy'
  git push
) &> /dev/null || die

# Do the subrepo push and save the output:
message="$(
  cd $OWNER/foo

  # This command should tease out the commits made to bar, and push them back
  # to UPSTREAM/bar
  git subrepo push bar
)"

# Test the output:
is "$message" \
  "git subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)" \
  "push message is correct"

# Pull the changes from UPSTREAM/bar
(
  cd $OWNER/bar
  git fetch
  git rebase -p
) &> /dev/null || die

# Test the state of the bar repo:
# - Check for right files
# - Check for right file content
# - Check log messages
# - Check commit/tree/blob ids

ok "`[ -f $OWNER/bar/FooBar ]`" \
  "subrepo push file made it upstream"

ok "`[ ! -f $OWNER/bar/.gitrepo ]`" \
  ".gitrepo file was not pushed"

done_testing 3

source test/teardown
