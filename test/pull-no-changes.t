#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/bar
  add-new-files Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull bar
) &> /dev/null || die

# Test subrepo file content
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/Bar2" \
    "$gitrepo"
}

# Test foo/bar/.gitrepo file contents
{
  foo_commit_after_first_pull="$(cd $OWNER/foo; git rev-parse HEAD)"
  foo_pull_commit="$(cd $OWNER/foo; git rev-parse HEAD^)"
  bar_head_commit="$(cd $OWNER/bar; git rev-parse HEAD)"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
}

# Do the pull; there should be no changes reported…
{
  is "$(
    cd $OWNER/foo
    git subrepo pull bar
  )" \
    "Subrepo 'bar' is up to date." \
    'subrepo pull command output is correct'
}

# …and no new commit
{
  foo_commit_after_this_pull="$(cd $OWNER/foo; git rev-parse HEAD)"
  is $foo_commit_after_this_pull $foo_commit_after_first_pull "No new commits to foo"
}

# foo/bar/.gitrepo file contents should not have changed:
{
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
}


# Add a new branch at the same revision
(
  cd $OWNER/bar
  git push origin HEAD:a-branch
) &> /dev/null || die

# Do the pull on the new branch; there should be no changes reported…
{
  is "$(
    cd $OWNER/foo
    git subrepo pull bar -b a-branch
  )" \
    "Subrepo 'bar' is up to date." \
    'subrepo pull command output is correct'
}

# …and no new commit
{
  foo_commit_after_this_pull="$(cd $OWNER/foo; git rev-parse HEAD)"
  is $foo_commit_after_this_pull $foo_commit_after_first_pull "No new commits to foo"
}

# foo/bar/.gitrepo file contents should not have changed:
{
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
}

# Do the pull on the new branch again, this time with updates requested.  There
# should be changes reported…
{
  is "$(
    cd $OWNER/foo
    git subrepo pull bar -b a-branch -u
  )" \
    "Subrepo 'bar' pulled from '../../../tmp/upstream/bar' (a-branch)." \
    'subrepo pull command output is correct'
}

# …and a new commit
{
  foo_commit_after_this_pull="$(cd $OWNER/foo; git rev-parse HEAD)"
  foo_commit_before_this_pull="$(cd $OWNER/foo; git rev-parse HEAD^)"
  isnt $foo_commit_after_this_pull $foo_commit_after_first_pull "Got a new commit"
  is $foo_commit_before_this_pull $foo_commit_after_first_pull "Previous commit is the same"
}

# foo/bar/.gitrepo file contents should have changed slightly:
{
  test-gitrepo-field "branch" "a-branch"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_commit_after_first_pull"
}

done_testing

teardown
