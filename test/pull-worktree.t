#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd $OWNER/foo
  git subrepo clone ../bar bar
  git worktree add -b test ../wt
) &> /dev/null || die

(
  cd $OWNER/bar
  modify-files Bar
) &> /dev/null || die

(
  cd $OWNER/wt
  git subrepo pull --all
) &> /dev/null || die

(
  cd $OWNER/foo
  git merge test
) &> /dev/null || die

{
  is "$(cat $OWNER/foo/bar/Bar)" \
    "a new line" \
    'bar/Bar content correct'
}

done_testing

teardown
