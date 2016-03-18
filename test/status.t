#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

(
  cd $OWNER/foo
  add-new-files bar/file
)

{
  test-exists \
    "!$OWNER/foo/.git/refs/subrepo/bar/branch" \
    "$OWNER/foo/.git/refs/subrepo/bar/fetch"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Status not available: missing branch ref.

See also: git subrepo show ..." \
    'subrepo status (missing branch ref) output is correct'
}

(
  cd $OWNER/foo
  git subrepo --quiet branch bar
)

{
  test-exists \
    "$OWNER/foo/.git/refs/subrepo/bar/branch"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Subrepo is up-to-date with upstream.

See also: git subrepo show ..." \
    'subrepo status (up-to-date) output is correct'
}

rm -f $OWNER/foo/.git/refs/subrepo/bar/fetch

{
  test-exists \
    "!$OWNER/foo/.git/refs/subrepo/bar/fetch"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Status not available: missing fetch ref.

See also: git subrepo show ..." \
    'subrepo status (missing fetch ref) output is correct'
}

rm -f $OWNER/foo/.git/refs/subrepo/bar/branch

{
  test-exists \
    "!$OWNER/foo/.git/refs/subrepo/bar/branch"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Status not available: missing branch and fetch refs.

See also: git subrepo show ..." \
    'subrepo status (missing branch and fetch refs) output is correct'
}

done_testing

teardown
