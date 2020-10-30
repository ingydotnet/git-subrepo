#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  mkdir -p "$OWNER/empty"
  git init "$OWNER/empty"
)

# Test that the repos look ok:
{
  test-exists \
    "$OWNER/foo/.git/" \
    "$OWNER/foo/Foo" \
    "!$OWNER/foo/bar/" \
    "$OWNER/bar/.git/" \
    "$OWNER/bar/Bar" \
    "$OWNER/empty/.git/"
}

# Do the subrepo clone and test the output:
{
  clone_output=$(
    cd "$OWNER/foo"
    git subrepo clone "$UPSTREAM/bar"
  )

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '$UPSTREAM/bar' (master) cloned into 'bar'." \
    'subrepo clone command output is correct'

  is "$(
    cd "$OWNER/foo"
    git remote -v | grep subrepo/bar
  )" \
    "" \
    'No remotes created'

  clone_output_empty=$(
    cd "$OWNER/empty"
    catch git subrepo clone "$UPSTREAM/bar"
  )

  # Check output is correct:
  is "$clone_output_empty" \
    "git-subrepo: You can't clone into an empty repository" \
    'subrepo empty clone command output is correct'
}

# Check that subrepo files look ok:
gitrepo=$OWNER/foo/bar/.gitrepo
{
  test-exists \
    "$OWNER/foo/bar/" \
    "$OWNER/foo/bar/Bar" \
    "$gitrepo" \
    "!$OWNER/empty/bar/"
}

# Test foo/bar/.gitrepo file contents:
{
  foo_clone_commit=$(cd "$OWNER/foo"; git rev-parse HEAD^)
  bar_head_commit=$(cd "$OWNER/bar"; git rev-parse HEAD)
  test-gitrepo-comment-block
  test-gitrepo-field "remote" "$UPSTREAM/bar"
  test-gitrepo-field "branch" "master"
  test-gitrepo-field "commit" "$bar_head_commit"
  test-gitrepo-field "parent" "$foo_clone_commit"
  test-gitrepo-field "cmdver" "$(git subrepo --version)"
}

# Make sure status is clean:
{
  git_status=$(
    cd "$OWNER/foo"
    git status -s
  )

  is "$git_status" \
    "" \
    'status is clean'

  git_status_empty=$(
    cd "$OWNER/empty"
    git status -s
  )

  is "$git_status_empty" \
    "" \
    'status is clean'
}

done_testing

teardown
