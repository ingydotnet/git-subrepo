#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

before="$(stat $OWNER/foo/Foo | grep Modify)"

is "$(
  cd $OWNER/foo
  add-new-files bar/file
  git subrepo branch bar
)" \
  "Created branch 'subrepo/bar' and worktree '.git/tmp/subrepo/bar'." \
  "subrepo branch command output is correct"

after="$(stat $OWNER/foo/Foo | grep Modify)"

is "$before" "$after" \
  "No modification on Foo"

test-exists "$OWNER/foo/.git/tmp/subrepo/bar/"

is "$(
  cd $OWNER/foo/.git/tmp/subrepo/bar
  git branch | grep \*
)" \
  "* subrepo/bar" \
  "Correct branch is checked out"

done_testing

teardown
