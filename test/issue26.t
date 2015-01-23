#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  mkdir -p "$OWNER/empty"
  git init "$OWNER/empty"
)

# Test that the repo looks ok:
{
  test-exists \
    "$OWNER/empty/.git/"
}

# Do the subrepo clone and test the output:
{
  clone_output="$(
    cd $OWNER/empty
    git subrepo clone ../../../$UPSTREAM/bar
  )"

  # Check output is correct:
  is "$clone_output" \
    "Subrepo '../../../tmp/upstream/bar' (master) cloned into 'bar'" \
    'subrepo clone command output is correct'
}

# Check that subrepo files look ok:
gitrepo=$OWNER/empty/bar/.gitrepo
{
  test-exists \
    "$OWNER/empty/bar/" \
    "$OWNER/empty/bar/Bar" \
    "$gitrepo"
}

# Make sure status is clean:
{
  git_status="$(
    cd $OWNER/empty
    git status -s
  )"

  is "$git_status" \
    "" \
    'status is clean'
}

done_testing 6

#teardown
