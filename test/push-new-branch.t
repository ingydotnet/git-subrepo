#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

# Make various changes to the repos for testing subrepo push:
(
  # In the main repo:
  cd $OWNER/foo

  git branch parent_ref
  # Clone the subrepo into a subdir
  git subrepo clone ../../../$UPSTREAM/bar

  # Make a commit:
  add-new-files bar/FooBar
) &> /dev/null || die

# Test foo/bar/.gitrepo file contents:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  foo_parent="$(cd $OWNER/foo; git rev-parse parent_ref)"
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "parent" "$foo_parent"
  test-gitrepo-field "merged" ""
}

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

{
  foo_parent="$(cd $OWNER/foo; git rev-parse parent_ref)"
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "parent" "$foo_parent"
  test-gitrepo-field "merged" ""
}

# Make sure that git doesn't recreate same SHA
# git-subrepo will handle that case as then we will
# say that there are no changes to push
sleep 1

# Do the subrepo push to another branch again:
{
  upstream_head="$(cd $UPSTREAM/bar; git rev-parse newbar)"
  message="$(
    cd $OWNER/foo
    catch git subrepo push bar --branch newbar
  )"

  # Test the output:
  is "$message" \
    "git-subrepo: Can't commit: 'subrepo/bar' doesn't contain upstream HEAD: $upstream_head" \
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
