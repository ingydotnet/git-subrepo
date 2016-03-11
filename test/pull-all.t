#!/usr/bin/env bash

set -e

source test/setup

use Test::More

clone-foo-and-bar

(
  cd $OWNER/foo
  git subrepo clone ../bar bar1
  git subrepo clone ../bar bar2
) &> /dev/null || die

(
  cd $OWNER/bar
  modify-files Bar
) &> /dev/null || die

(
  cd $OWNER/foo
  git subrepo pull --all
) &> /dev/null || die

{
  is "$(cat $OWNER/foo/bar1/Bar)" \
    "a new line" \
    'bar1/Bar content correct'
  is "$(cat $OWNER/foo/bar2/Bar)" \
    "a new line" \
    'bar2/Bar content correct'
}

done_testing

teardown
