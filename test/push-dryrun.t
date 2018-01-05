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

(
  cd $OWNER/foo
  git config user.name 'PushUser'
  git config user.email 'push@push'
  git subrepo pull --quiet bar
) &> /dev/null || die

bar_before="$(cd $OWNER/bar;git rev-parse HEAD)"
foo_before="$(cd $OWNER/foo;git rev-parse HEAD)"

# Do the subrepo push dryrun and test the output:
{
  message="$(
    cd $OWNER/foo
    git subrepo push --dry-run bar
  )"

  # Test the output:
  like "$message" \
    "Push prepared in branch 'subrepo/bar'" \
    'Dry run prepared'
}

bar_after="$(cd $OWNER/bar;git pull --quiet;git rev-parse HEAD)"
foo_after="$(cd $OWNER/foo;git pull --quiet;git rev-parse HEAD)"

is "$bar_before" "$bar_after" 'No subrepo commit'
is "$foo_before" "$foo_after" 'No repo commit'

# Do the subrepo push and test the output:
{
  message="$(
    cd $OWNER/foo
    git subrepo push bar subrepo/bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '../../../tmp/upstream/bar' (master)." \
    'Continue from dry run'
}

bar_after="$(cd $OWNER/bar;git pull --quiet;git rev-parse HEAD^2)"
foo_after="$(cd $OWNER/foo;git pull --quiet;git rev-parse HEAD^)"

is "$bar_before" "$bar_after" 'Subrepo commit added'
is "$foo_before" "$foo_after" 'Repo commit added'

# Test foo/bar/.gitrepo file contents:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  foo_parent_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-field "remote" "../../../$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_parent_commit"
  test-gitrepo-field "merged" ""
  test-gitrepo-field "cmdver" "`git subrepo --version`"
}

# Do the subrepo push and test the output:
{
  message="$(
    cd $OWNER/foo
    git subrepo push bar subrepo/bar
  )"

  # Test the output:
  is "$message" \
    "Subrepo 'bar' has no new commits to push." \
    'No new changes found'
}

done_testing

teardown
