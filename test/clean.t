#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/foo
  add-new-files bar/file
  git subrepo --quiet branch bar
)

test-exists \
  "$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "$OWNER/foo/.git/refs/subrepo/bar/fetch"

is "$(
  cd $OWNER/foo
  git subrepo clean bar
)" \
  "Removed branch 'subrepo/bar'.
Removed remote 'subrepo/bar'." \
  "subrepo clean command output is correct"

test-exists \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar"

(
  cd $OWNER/foo
  git subrepo clean --force bar
)

test-exists \
  "!$OWNER/foo/.git/refs/subrepo/bar/fetch"

done_testing

teardown
