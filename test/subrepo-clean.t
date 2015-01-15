#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/foo
  git subrepo --quiet checkout bar
)

test-exists \
  "$OWNER/foo/.git/SUBREPO_ORIG_HEAD" \
  "$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "$OWNER/foo/.git/refs/subrepo/remote/bar"

is "$(
  cd $OWNER/foo
  git subrepo --quiet reset
  git subrepo clean bar
)" \
  "Removed branch 'subrepo/bar'
Removed remote 'subrepo/bar'
Removed ref 'refs/subrepo/remote/bar'" \
  "subrepo clean command output is correct"

test-exists \
  "$OWNER/foo/.git/SUBREPO_ORIG_HEAD" \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "!$OWNER/foo/.git/refs/subrepo/remote/bar"

done_testing

teardown
