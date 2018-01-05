#!/usr/bin/env bash

set -e

source test/setup

use Test::More

unset GIT_{AUTHOR,COMMITTER}_{EMAIL,NAME}

clone-foo-and-bar

# Make various changes to the repos for testing subrepo push:
(
  # In the main repo:
  cd $OWNER/foo

  # Clone the subrepo into a subdir
  git subrepo clone ../../../$UPSTREAM/bar --push-update manual

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

(
  cd $OWNER/foo
  git config user.name 'PushUser'
  git config user.email 'push@push'
  git subrepo pull --quiet bar
) &> /dev/null || die


foo_before="$(cd $OWNER/foo; git rev-parse HEAD)"

# Do the subrepo push and test the output:
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

foo_after="$(cd $OWNER/foo; git rev-parse HEAD)"

is "$foo_before" "$foo_after" 'No local commit'

(
  # In the main repo:
  cd $OWNER/foo
  add-new-files bar/FooBar2
) &> /dev/null || die

{
  message="$(
    cd $OWNER/foo
    catch git subrepo push bar
  )"

  # Test the output:
  is "$message" \
    "git-subrepo: There are new changes upstream, you need to pull first." \
    'We need to pull first'
}

(
  # In the main repo:
  cd $OWNER/foo
  git subrepo pull bar
) &> /dev/null || die

{
  message="$(
    cd $OWNER/foo
    catch git subrepo push bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)." \
    'Now we can push'
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

done_testing

teardown
