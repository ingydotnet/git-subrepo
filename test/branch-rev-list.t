#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/foo
  branchpoint=$(git rev-parse HEAD)
  add-new-files bar/file1
  # We push here to force subrepo to handle
  # histories where it's not first parent
  git subrepo push bar
  add-new-files bar/file2
  git checkout -b other $branchpoint
  add-new-files bar/file3
  add-new-files bar/file4
  add-new-files bar/file5
  git merge master
) >& /dev/null || die

test-exists "$OWNER/foo/bar/file1" "$OWNER/foo/bar/file2" "$OWNER/foo/bar/file3" "$OWNER/foo/bar/file4" "$OWNER/foo/bar/file5"

# -F is needed for branch to fetch new information
is "$(
  cd $OWNER/foo
  git subrepo -F branch bar
)" \
  "Created branch 'subrepo/bar' and worktree '.git/tmp/subrepo/bar'." \
  "subrepo branch command output is correct"

is $(
  cd $OWNER/foo
  git rev-list subrepo/bar | wc -l
) \
  5 \
  "We have only created commits for one of the paths"

done_testing

teardown
