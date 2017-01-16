#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

subrepo-clone-bar-into-foo

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
    (use 'git subrepo branch' to update)

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

{
  is "$(
    cd $OWNER/foo
    git subrepo --quiet status
  )" \
    "See also: git subrepo show ..." \
    'subrepo status (quiet) output is correct'
}

(
  cd $OWNER/foo
  add-new-files bar/Foo1
  git subrepo --force --quiet branch bar
) &> /dev/null || die

{
  test-exists \
    "$OWNER/foo/bar/Foo1"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Subrepo is ahead of upstream.
    (use 'git subrepo push' to publish your local commits)

See also: git subrepo show ..." \
    'subrepo status (ahead, post-commit) output is correct'
}

(
  cd $OWNER/bar
  add-new-files Bar2
  git push
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo --quiet fetch bar
) &> /dev/null || die

{
  test-exists \
    "$OWNER/bar/Bar2"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Subrepo and upstream have diverged.
    (use 'git subrepo pull' to merge the remote subrepo into yours)

See also: git subrepo show ..." \
    'subrepo status (diverged) output is correct'
}

(
    cd $OWNER/foo
    git reset --quiet --hard HEAD^
    git subrepo --force --quiet branch bar
) &> /dev/null || die

{
  test-exists \
    "!$OWNER/foo/bar/Foo1"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Subrepo is behind upstream.
    (use 'git subrepo pull' to update your local subrepo)

See also: git subrepo show ..." \
    'subrepo status (behind) output is correct'
}

(
  cd $OWNER/foo
  add-new-files bar/Foo2
  git subrepo pull --quiet bar
  git subrepo --force --quiet branch bar
) &> /dev/null || die

{
  test-exists \
    "$OWNER/foo/bar/Bar2" \
    "$OWNER/foo/bar/Foo2"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Subrepo is ahead of upstream.
    (use 'git subrepo push' to publish your local commits)

See also: git subrepo show ..." \
    'subrepo status (ahead, post-pull) output is correct'
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
    (use 'git subrepo fetch' to update)

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
  Status not available: missing fetch ref.
    (use 'git subrepo fetch' to update)

See also: git subrepo show ..." \
    'subrepo status (using branch head instead of branch ref) output is correct'
}

(
  cd $OWNER/foo
  git subrepo clean --force bar
) &> /dev/null || die

{
  test-exists \
    "!$OWNER/foo/.git/refs/heads/subrepo/bar"

  is "$(
    cd $OWNER/foo
    git subrepo status
  )" \
    "Git subrepo 'bar':
  Status not available: missing branch and fetch refs.
    (use 'git subrepo branch' and 'git subrepo fetch' to update)

See also: git subrepo show ..." \
    'subrepo status (missing branch and fetch refs) output is correct'
}

done_testing

teardown
