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

export XYZ=1
is "$(
  cd $OWNER/foo
  git subrepo --force clone ../../../$UPSTREAM/bar
)" \
  "Subrepo 'bar' is up to date." \
  "No reclone if same commit"

(
  cd $OWNER/foo
  git subrepo --quiet clone --force ../../../$UPSTREAM/bar --branch=refs/tags/A
)

test-exists \
  "!$OWNER/foo/bar/bard/"

(
  cd $OWNER/foo
  git subrepo --quiet clone -f ../../../$UPSTREAM/bar --branch=master
)

test-exists \
  "$OWNER/foo/bar/bard/"

done_testing

teardown
