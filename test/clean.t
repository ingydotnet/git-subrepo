#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/foo
  git subrepo --quiet branch bar
  git subrepo --quiet clone ../../../$UPSTREAM/bar baz
  git subrepo --quiet branch baz
)

test-exists \
  "$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "$OWNER/foo/.git/refs/heads/subrepo/baz" \
  "$OWNER/foo/.git/refs/subrepo/bar/fetch" \
  "$OWNER/foo/.git/refs/subrepo/baz/fetch"

is "$(
  cd $OWNER/foo
  git subrepo clean bar
)" \
  "Removed branch 'subrepo/bar'.
Removed remote 'subrepo/bar'." \
  "'subrepo clean' command output is correct"

test-exists \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar" \
  "$OWNER/foo/.git/refs/subrepo/bar/fetch"

(
  cd $OWNER/foo
  git subrepo clean --force bar
)

test-exists \
  "!$OWNER/foo/.git/refs/subrepo/bar/fetch" \
  "$OWNER/foo/.git/refs/subrepo/baz/fetch"

(
  cd $OWNER/foo
  git subrepo --quiet clone ../../../$UPSTREAM/foo bar/qux
  git subrepo --quiet branch bar/qux
)

test-exists \
  "$OWNER/foo/.git/refs/heads/subrepo/bar/qux" \
  "$OWNER/foo/.git/refs/subrepo/bar/qux/fetch"

is "$(
  cd $OWNER/foo
  git subrepo clean --all
)" \
  "Removed branch 'subrepo/baz'.
Removed remote 'subrepo/baz'." \
  "'subrepo clean --all' command output is correct"

test-exists \
  "$OWNER/foo/.git/refs/heads/subrepo/bar/qux" \
  "!$OWNER/foo/.git/refs/heads/subrepo/baz" \
  "$OWNER/foo/.git/refs/subrepo/baz/fetch"

is "$(
  cd $OWNER/foo
  git subrepo clean --ALL
)" \
  "Removed branch 'subrepo/bar/qux'.
Removed remote 'subrepo/bar/qux'." \
  "'subrepo clean --ALL' command output is correct"

test-exists \
  "!$OWNER/foo/.git/refs/heads/subrepo/bar/qux" \
  "$OWNER/foo/.git/refs/subrepo/bar/qux/fetch"

(
  cd $OWNER/foo
  git subrepo clean --all --force
)

test-exists \
  "$OWNER/foo/.git/refs/subrepo/bar/qux/fetch" \
  "!$OWNER/foo/.git/refs/subrepo/baz/fetch"

(
  cd $OWNER/foo
  git subrepo clean --ALL --force
)

test-exists \
  "!$OWNER/foo/.git/refs/subrepo/bar/qux/fetch"

done_testing

teardown
