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
  "$OWNER/foo/.git/refs/subrepo/bar/upstream"

is "$(
  cd $OWNER/foo
  git subrepo --verbose clean bar
)" \
  "* Remove branch 'subrepo/bar'.
* Remove remote 'subrepo/bar'.
* Remove ref 'refs/subrepo/bar/upstream'." \
  "subrepo clean command output is correct"

test-exists \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "!$OWNER/foo/.git/refs/subrepo/bar/upstream"

done_testing

teardown
