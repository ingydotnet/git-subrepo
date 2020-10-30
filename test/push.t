#!/usr/bin/env bash

set -e

source test/setup

use Test::More

unset GIT_{AUTHOR,COMMITTER}_{EMAIL,NAME}

clone-foo-and-bar

# Make various changes to the repos for testing subrepo push:
(
  # In the main repo:
  cd "$OWNER/foo"

  # Clone the subrepo into a subdir
  git subrepo clone "$UPSTREAM/bar"

  # Make a series of commits:
  add-new-files bar/FooBar
  add-new-files ./FooBar
  modify-files bar/FooBar
  modify-files ./FooBar
  modify-files ./FooBar bar/FooBar
) &> /dev/null || die

(
  cd "$OWNER/bar"
  add-new-files bargy
  git push
) &> /dev/null || die

# Do the subrepo push and test the output:
{
  message=$(
    cd "$OWNER/foo"
    git config user.name 'PushUser'
    git config user.email 'push@push'
    git subrepo pull --quiet bar
    git subrepo push bar
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

{
  pullCommit=$(
    cd "$OWNER/bar"
    git log HEAD -1 --pretty='format:%an %ae %cn %ce'
  )

  is "$pullCommit" \
    "PushUser push@push PushUser push@push" \
    "Pull commit has PushUser as both author and committer"
}

{
  subrepoCommit=$(
    cd "$OWNER/bar"
    git log HEAD^ -1 --pretty='format:%an %ae %cn %ce'
  )

  is "$subrepoCommit" \
    "FooUser foo@foo PushUser push@push" \
    "Subrepo commits has FooUser as author but PushUser as committer"
}

# Check that all commits arrived in subrepo
test-commit-count "$OWNER/bar" HEAD 7

# Test foo/bar/.gitrepo file contents:
# shellcheck disable=2034
gitrepo=$OWNER/foo/bar/.gitrepo
{
  foo_pull_commit=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  bar_head_commit=$(cd "$OWNER/bar"; git rev-parse HEAD)
  test-gitrepo-field "remote" "$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_pull_commit"
  test-gitrepo-field "cmdver" "$(git subrepo --version)"
}

(
  # In the main repo:
  cd "$OWNER/foo"
  add-new-files bar/FooBar2
  modify-files bar/FooBar
) &> /dev/null || die

{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar
  )

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '$UPSTREAM/bar' (master)." \
    'push message is correct'
}

# Pull the changes from UPSTREAM/bar in OWNER/bar
(
  cd "$OWNER/bar"
  git pull
) &> /dev/null || die

test-exists \
  "$OWNER/bar/Bar" \
  "$OWNER/bar/FooBar" \
  "$OWNER/bar/bard/" \
  "$OWNER/bar/bargy" \
  "!$OWNER/bar/.gitrepo" \

(
  # In the main repo:
  cd "$OWNER/foo"
  add-new-files bar/FooBar3
  modify-files bar/FooBar
  git subrepo push bar
  add-new-files bar/FooBar4
  modify-files bar/FooBar3
) &> /dev/null || die

{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar
  )

  # Test the output:
  is "$message" \
    "Subrepo 'bar' pushed to '$UPSTREAM/bar' (master)." \
    'Seqential pushes are correct'
}

(
  # In the subrepo
  cd "$OWNER/bar"
  git pull
  add-new-files barBar2
  git push
) &> /dev/null || die

(
  # In the main repo:
  cd "$OWNER/foo"
  add-new-files bar/FooBar5
  modify-files bar/FooBar3
) &> /dev/null || die

{
  message=$(
    cd "$OWNER/foo"
    git subrepo push bar 2>&1 || true
  )

  # Test the output:
  is "$message" \
    "git-subrepo: There are new changes upstream, you need to pull first." \
    'Stopped by other push'
}

done_testing

teardown
