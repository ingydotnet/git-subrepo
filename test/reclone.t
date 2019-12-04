#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd "$OWNER/foo"
  git subrepo --quiet clone "$UPSTREAM/bar"
)

test-exists \
  "$OWNER/foo/bar/bard/"

# Test that reclone is not done if not needed.
export XYZ=1
is "$(
  cd "$OWNER/foo"
  git subrepo --force clone "$UPSTREAM/bar"
)" \
  "Subrepo 'bar' is up to date." \
  "No reclone if same commit"

# Test that reclone of a different ref works.
(
  cd "$OWNER/foo"
  git subrepo --quiet clone --force "$UPSTREAM/bar" --branch=refs/tags/A
)

is "$(git -C "$OWNER"/foo subrepo config bar branch)" \
  "Subrepo 'bar' option 'branch' has value 'refs/tags/A'."
test-exists \
  "!$OWNER/foo/bar/bard/"

# Test that reclone back to (implicit) master works.
(
  cd "$OWNER/foo"
  git subrepo --quiet clone -f "$UPSTREAM/bar"
)

is "$(git -C "$OWNER"/foo subrepo config bar branch)" \
  "Subrepo 'bar' option 'branch' has value 'master'."
test-exists \
  "$OWNER/foo/bar/bard/"

done_testing

teardown
