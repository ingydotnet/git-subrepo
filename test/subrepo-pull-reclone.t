#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd $OWNER/foo
  git subrepo --quiet clone ../../../$UPSTREAM/bar
)

test-exists \
  "$OWNER/foo/bar/bard/"

is "$(
  cd $OWNER/foo
  git subrepo pull --strategy=reclone bar
)" \
  "Subrepo 'bar' is up to date" \
  "No reclone if same commit"

(
  cd $OWNER/foo
  git subrepo --quiet pull --strategy=reclone bar --branch=A
)

test-exists \
  "!$OWNER/foo/bar/bard/"

(
  cd $OWNER/foo
  git subrepo --quiet pull --strategy=reclone bar --branch=master
)

test-exists \
  "$OWNER/foo/bar/bard/"

done_testing

teardown
